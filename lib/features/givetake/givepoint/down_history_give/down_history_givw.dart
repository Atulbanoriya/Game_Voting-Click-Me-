import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GivenDownHistory extends StatefulWidget {
  const GivenDownHistory({super.key});

  @override
  State<GivenDownHistory> createState() => _GivenDownHistoryState();
}

class _GivenDownHistoryState extends State<GivenDownHistory> {
  List<Map<String, dynamic>> transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchData() async {
    const url = 'https://vote.nextgex.com/api/p2p_re_verify';
    try {
      final token = await getToken();
      if (token == null) {
        print('Token not found');
        return;
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.containsKey('Request')) {
          setState(() {
            transactions = (data['Request'] as List)
                .map((e) => e as Map<String, dynamic>)
                .toList();
            _loading = false;
          });
        } else {
          print('Unexpected response format. Keys: ${data.keys}');
          setState(() {
            _loading = false;
          });
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      print('An error occurred: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
         onRefresh: () async{
           fetchData();
         },
            child: transactions.isEmpty
                ? const Center(
                    child: Text(
                      'No Given History',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TransactionCard(transaction: transaction),
                      );
                    },
                  ),
          ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.4;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xffc5f3b5),
        border: Border.all(color: Colors.black, width: 1.2),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.blueGrey,
            offset: Offset(0, 0),
            blurRadius: 6,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  "Name: ${transaction['user_name'] ?? 'N/A'}",
                  style: GoogleFonts.k2d(
                    fontWeight: FontWeight.bold,

                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "${transaction['point'] ?? '100'} Points",
                    style: GoogleFonts.k2d(
                      fontWeight: FontWeight.bold,

                    ),
                  ),
                  const SizedBox(width: 2),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Num No.- ${transaction['member_phone'] ?? 'N/A'}",
                style: GoogleFonts.k2d(

                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "UTR: ${transaction['trx_no'] ?? 'N/A'}",
                style: GoogleFonts.k2d(

                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "Date: ${transaction['created_at'] ?? 'N/A'}",
                      style: GoogleFonts.k2d(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    "Status: ${_getStatusText(transaction['status'])}",
                    style: GoogleFonts.k2d(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(transaction['status']),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusText(dynamic status) {
    int parsedStatus = int.tryParse(status.toString()) ?? -1;
    switch (parsedStatus) {
      case 0:
        return 'Pending';
      case 1:
        return 'Done';
      case 2:
        return 'Reject';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(dynamic status) {
    int parsedStatus = int.tryParse(status.toString()) ?? -1;
    switch (parsedStatus) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
