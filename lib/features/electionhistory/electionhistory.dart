import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voter_multi_app/custom/const.dart';

class ElectionHistory extends StatefulWidget {
  const ElectionHistory({super.key});

  @override
  State<ElectionHistory> createState() => _ElectionHistoryState();
}

class _ElectionHistoryState extends State<ElectionHistory> {
  List<Map<String, dynamic>> elections = [];
  List<Map<String, dynamic>> filteredElections = [];
  final TextEditingController _dateController = TextEditingController();
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  final List<int> _availableRowsPerPage = [10, 25,50, 75,100];

  @override
  void initState() {
    super.initState();
    fetchElectionData();
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchElectionData() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.get(
        Uri.parse('https://vote.nextgex.com/api/slot_election_history_total'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.headers['content-type'] != null &&
            response.headers['content-type']!.contains('application/json')) {
          final List<dynamic> data = json.decode(response.body);

          // Debugging: Print out the response to see the structure
          print('Response data: $data');

          setState(() {
            elections = data.map((election) {
              return {
                'id': election['id']?.toString() ?? '',
                'date': election['start_date']?.toString() ?? 'N/A',
                'slotTiming': election['start_time']?.toString() ?? 'N/A',
                'type': election['type']?.toString() ?? 'N/A',
                'totalElection': election['total']?.toString() ?? '0',
                'winnerList':
                    election['winnerList']?.toString() ?? 'No winners',
              };
            }).toList();
            filteredElections = elections;
          });
        } else {
          print('Unexpected content type: ${response.headers['content-type']}');
          print('Response body: ${response.body}');
        }
      } else {
        print(
            'Failed to fetch election data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffa0cf1a),
        title: Text(
          'Election History',
          style: GoogleFonts.habibi(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: TextField(
          //     controller: _dateController,
          //     decoration: InputDecoration(
          //       labelText: 'Select Date',
          //       prefixIcon: Icon(Icons.calendar_today),
          //       border: OutlineInputBorder(),
          //     ),
          //     readOnly: true,
          //     onTap: () async {
          //       DateTime? pickedDate = await showDatePicker(
          //         context: context,
          //         initialDate: DateTime.now(),
          //         firstDate: DateTime(2000),
          //         lastDate: DateTime(2101),
          //       );
          //       if (pickedDate != null) {
          //         String formattedDate =
          //             DateFormat('yyyy-MM-dd').format(pickedDate);
          //         _dateController.text = formattedDate;
          //         setState(() {
          //           filteredElections = elections.where((election) {
          //             return election['date'] == formattedDate;
          //           }).toList();
          //         });
          //       }
          //     },
          //   ),
          // ),
          Expanded(
            child: SingleChildScrollView(
              child: PaginatedDataTable(
                columns: [
                  DataColumn(
                      label: Center(
                          child: Text(
                    'Sr No.',
                    style: GoogleFonts.habibi(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ))),
                  DataColumn(
                    label: Row(
                      children: [
                        Text(
                          'Date',
                          style: GoogleFonts.habibi(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5),
                        InkWell(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              String formattedDate =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                              _dateController.text = formattedDate;
                              setState(() {
                                filteredElections = elections.where((election) {
                                  return election['date'] == formattedDate;
                                }).toList();
                              });
                            }
                          },
                          child: Icon(Icons.calendar_month),
                        ),
                      ],
                    ),
                  ),
                  DataColumn(
                      label: Center(
                          child: Text(
                    'Slot Timing',
                    style: GoogleFonts.habibi(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ))),
                  DataColumn(
                      label: Center(
                          child: Text(
                    'Elec. Type',
                    style: GoogleFonts.habibi(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ))),
                  DataColumn(
                      label: Center(
                          child: Text(
                    'Total Election',
                    style: GoogleFonts.habibi(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ))),
                  DataColumn(
                      label: Center(
                          child: Text(
                    'Winner List',
                    style: GoogleFonts.habibi(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ))),
                ],
                source: _ElectionDataSource(context, filteredElections),
                rowsPerPage: _rowsPerPage,
                availableRowsPerPage: _availableRowsPerPage,
                onRowsPerPageChanged: (value) {
                  setState(() {
                    _rowsPerPage = value ?? _rowsPerPage;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ElectionDataSource extends DataTableSource {
  final BuildContext context;
  final List<Map<String, dynamic>> elections;

  _ElectionDataSource(this.context, this.elections);

  @override
  DataRow? getRow(int index) {
    if (index >= elections.length) return null;
    final election = elections[index];

    return DataRow(cells: [
      DataCell(Center(child: Text(election['id']))),
      DataCell(Text(election['date'])),
      DataCell(Text(election['slotTiming'])),
      DataCell(Text(election['type'])),
      DataCell(Center(child: Text(election['totalElection']))),
      DataCell(
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WinnerListView(
                  id: election['id'].toString(),
                ),
              ),
            );

            print('${election['id'].toString()}');
          },
          child: Container(
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xffa0cf1a),
            ),
            child: Center(
              child: Text(
                "View",
                style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  @override
  int get rowCount => elections.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

class WinnerListView extends StatefulWidget {
  final String id;

  WinnerListView({required this.id});

  @override
  State<WinnerListView> createState() => _WinnerListViewState();
}

class _WinnerListViewState extends State<WinnerListView> {
  List<dynamic> _electionHistory = [];
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  void initState() {
    super.initState();
    _fetchElectionHistory(widget.id);
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchElectionHistory(String id) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.post(
        Uri.parse(
            'https://vote.nextgex.com/api/slot_election_history_total_winner'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          'id': id,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('Response body: $responseBody'); // Debugging: Print response body

        final data = json.decode(responseBody);
        if (data.isNotEmpty) {
          setState(() {
            _electionHistory = data;
          });
        } else {
          print('No data available.');
          setState(() {
            _electionHistory = [];
          });
        }
      } else if (response.statusCode == 302) {
        final newUrl = response.headers['location'];
        if (newUrl != null) {
          final redirectedResponse = await http.post(
            Uri.parse(newUrl),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(<String, String>{
              'id': id,
            }),
          );

          if (redirectedResponse.statusCode == 200) {
            final responseBody = redirectedResponse.body;
            print('Response body from redirected URL: $responseBody');
            setState(() {
              _electionHistory = json.decode(responseBody);
            });
          } else {
            print(
                'Failed to load redirected election history. Status code: ${redirectedResponse.statusCode}');
            print('Response body: ${redirectedResponse.body}');
          }
        } else {
          print('Redirection URL is missing');
        }
      } else {
        final responseBody = response.body;
        print(
            'Failed to load election history. Status code: ${response.statusCode}');
        print('Response body: $responseBody');
        if (responseBody.contains('Data Not Available')) {
          // Handle the specific case where data is not available
          print('Data is not available for the requested ID.');
        }
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffa0cf1a),
        title: const Text('Winner List'),
      ),
      body: SingleChildScrollView(
        child: PaginatedDataTable(
          columns: [
            DataColumn(
                label: Center(
                    child: Text(
              'Sr No.',
              style: GoogleFonts.habibi(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ))),
            DataColumn(
                label: Center(
                    child: Text(
              'Date',
              style: GoogleFonts.habibi(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ))),
            DataColumn(
                label: Center(
                    child: Text(
              'Type',
              style: GoogleFonts.habibi(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ))),
            DataColumn(
                label: Center(
                    child: Text(
              'Winner Name',
              style: GoogleFonts.habibi(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ))),
            DataColumn(
                label: Center(
                    child: Text(
              'Winner Image',
              style: GoogleFonts.habibi(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ))),
          ],
          source: _WinnerDataSource(context, _electionHistory),
          rowsPerPage: _rowsPerPage,
          onRowsPerPageChanged: (value) {
            setState(() {
              _rowsPerPage = value ?? _rowsPerPage;
            });
          },
        ),
      ),
    );
  }
}

class _WinnerDataSource extends DataTableSource {
  final BuildContext context;
  final List<dynamic> winners;

  _WinnerDataSource(this.context, this.winners);

  @override
  DataRow? getRow(int index) {
    if (index >= winners.length) return null;
    final winner = winners[index];

    return DataRow(cells: [
      DataCell(Center(child: Text((index + 1).toString()))),
      DataCell(Text(winner['elect_start_time'] ?? 'N/A')),
      DataCell(Text(winner['type'] ?? 'N/A')),
      DataCell(Text(winner['user_name'] ?? 'N/A')),
      DataCell(
        winner['profile_image'] != null
            ? Center(
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    '${ConstRes.imageUrl}${winner['profile_image']}',
                  ),
                  // child: Image.network(winner['profile_image'], width: 50, height: 50)
                ),
              )
            : Center(
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage("asset/images/placeholder.png"),
                ),
              ),
      ),
    ]);
  }

  @override
  int get rowCount => winners.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
