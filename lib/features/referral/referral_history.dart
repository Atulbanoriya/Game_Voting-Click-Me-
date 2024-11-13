import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReferralHistory extends StatefulWidget {
  const ReferralHistory({super.key});

  @override
  State<ReferralHistory> createState() => _ReferralHistoryState();
}

class _ReferralHistoryState extends State<ReferralHistory> {
  late Future<List<ReferralData>> _referralHistory;
  int _rowsPerPage = 10;
  final List<int> _availableRowsPerPage = [10, 20, 30];

  @override
  void initState() {
    super.initState();
    _referralHistory = fetchReferralHistory();
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<ReferralData>> fetchReferralHistory() async {
    final String? token = await getToken();

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('https://vote.nextgex.com/api/referal_amount_history'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Print the response body for debugging
      print("Response body: ${response.body}");

      try {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse.containsKey('transactions')) {
          List<dynamic> transactions = jsonResponse['transactions'];
          return transactions
              .map((data) => ReferralData.fromJson(data))
              .toList();
        } else {
          throw Exception('Unexpected JSON format');
        }
      } catch (e) {
        throw Exception('Failed to parse JSON: ${e.toString()}');
      }
    } else {
      print("Failed to load data. Status code: ${response.statusCode}");
      print("Response body: ${response.body}");
      throw Exception(
          'Failed to load referral history with status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffa0cf1a),
        title: Text(
          "Referral History",
          style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<ReferralData>>(
        future: _referralHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return  Center(child: Text(
                'No Referral History found.',
              style: GoogleFonts.habibi(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),
            ));
          }

          return SingleChildScrollView(
            child: PaginatedDataTable(
              columns: [
                DataColumn(
                    label: Center(
                  child: Text(
                    'Sr No.',
                    style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
                  ),
                )),
                DataColumn(
                    label: Center(
                  child: Text(
                    'Date',
                    style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
                  ),
                )),
                DataColumn(
                    label: Center(
                  child: Text(
                    'Point',
                    style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
                  ),
                )),
                DataColumn(
                    label: Center(
                  child: Text(
                    'Name',
                    style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
                  ),
                )),
              ],
              source: ReferralDataTableSource(snapshot.data!),
              rowsPerPage: _rowsPerPage,
              availableRowsPerPage:
              _availableRowsPerPage, // Set the available rows per page
              onRowsPerPageChanged: (value) {
                setState(() {
                  _rowsPerPage = value ??
                      _rowsPerPage; // Update rows per page
                });
              },
            ),
          );
        },
      ),
    );
  }
}

class ReferralData {
  final String trnsDate;
  final String trnsAmount;
  final String userName;

  ReferralData(
      {required this.trnsDate,
      required this.trnsAmount,
      required this.userName});

  factory ReferralData.fromJson(Map<String, dynamic> json) {
    return ReferralData(
      trnsDate: json['trns_date'],
      trnsAmount: json['trns_amount'],
      userName: json['user_name'],
    );
  }
}

class ReferralDataTableSource extends DataTableSource {
  final List<ReferralData> data;

  ReferralDataTableSource(this.data);

  @override
  DataRow getRow(int index) {
    final referral = data[index];
    return DataRow(cells: [
      DataCell(Center(child: Text('${index + 1}'))), // Sr No.
      DataCell(Text(referral.trnsDate)), // Date
      DataCell(Text(
        referral.trnsAmount,
        style: TextStyle(
          color: Color(0xffa0cf1a)
        ),
      )), // Point
      DataCell(Text(referral.userName)), // Name
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
