import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TakeHistory extends StatefulWidget {
  const TakeHistory({super.key});

  @override
  State<TakeHistory> createState() => _TakeHistoryState();
}

class _TakeHistoryState extends State<TakeHistory> {
  late Future<List<TakeRequestHistory>> futureRequestHistory;

  @override
  void initState() {
    super.initState();
    futureRequestHistory = fetchRequestHistory();
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<TakeRequestHistory>> fetchRequestHistory() async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('https://vote.nextgex.com/api/p2p_requests_take_history'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      try {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse is List) {
          return jsonResponse
              .map((data) => TakeRequestHistory.fromJson(data))
              .toList();
        } else {
          print('Unexpected JSON format');
          throw Exception('Unexpected JSON format');
        }
      } catch (e) {
        print('Error parsing JSON: $e');
        print('Response body: ${response.body}');
        throw Exception('Error parsing JSON: $e');
      }
    } else {
      print(
          'Failed to load request history with status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load request history');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<TakeRequestHistory>>(
        future: futureRequestHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load data: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return  Center(child: Text(
                'No Take History',
              style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            ));
          } else if (snapshot.hasData) {
            List<TakeRequestHistory> data = snapshot.data!;
            return TakeRequestHistoryTable(data: data);
          } else {
            return  Center(child: Text(
              'No Take History',
              style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
            ));
          }
        },
      ),
    );
  }
}

class TakeRequestHistoryTable extends StatelessWidget {
  final List<TakeRequestHistory> data;

  TakeRequestHistoryTable({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: PaginatedDataTable(
                columns: [
                  DataColumn(
                      label: Text(
                        'Sr. No',
                        style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
                      )),
                  DataColumn(
                      label: Text(
                        'Date',
                        style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
                      )),
                  DataColumn(
                      label: Text(
                        'Request Id',
                        style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
                      )),
                  DataColumn(
                      label: Text(
                        'Point',
                        style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
                      )),
                  DataColumn(
                      label: Text(
                        'Status',
                        style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
                      )),
                ],
                source: TakeRequestHistoryDataSource(data),
                rowsPerPage: 10,
                availableRowsPerPage: const [10, 25, 50, 75, 100],
                onRowsPerPageChanged: (rowsPerPage) {},
              ),
            ),
          );
        });
  }
}

class TakeRequestHistoryDataSource extends DataTableSource {
  final List<TakeRequestHistory> data;

  TakeRequestHistoryDataSource(this.data);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;

    final request = data[index];

    return DataRow(
      cells: [
        DataCell(Text((index + 1).toString())),
        DataCell(Text(request.createdAt ?? 'N/A')),
        DataCell(Center(child: Text(request.id?.toString() ?? 'N/A'))),
        DataCell(Text("100")),
        DataCell(Text(request.status == '0' ? 'Pending' : 'Approved')),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}

class TakeRequestHistory {
  int? id;
  String? createdAt;
  String? status;

  TakeRequestHistory({this.id, this.createdAt, this.status});

  factory TakeRequestHistory.fromJson(Map<String, dynamic> json) {
    return TakeRequestHistory(
      id: json['id'],
      createdAt: json['created_at'],
      status: json['status'],
    );
  }
}
