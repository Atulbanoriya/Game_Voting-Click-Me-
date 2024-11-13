import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CityApplyReport extends StatefulWidget {
  const CityApplyReport({super.key});

  @override
  State<CityApplyReport> createState() => _CityApplyReportState();
}

class _CityApplyReportState extends State<CityApplyReport> {
  late Future<List<Map<String, dynamic>>> historyData;
  List<Map<String, dynamic>> filteredData = [];
  final TextEditingController _dateController = TextEditingController();
  late CityApplyReportDataSource dataSource;

  int _rowsPerPage = 10;
  final List<int> _availableRowsPerPage = [10, 25, 50, 75,100];

  @override
  void initState() {
    super.initState();
    historyData = fetchHistoryData();
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Map<String, dynamic>>> fetchHistoryData() async {
    String? token = await getToken();

    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('https://vote.nextgex.com/api/elected_candidate_total_city'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse.containsKey('total_apply')) {
          final totalApplyList = jsonResponse['total_apply'];
          if (totalApplyList is List) {
            return totalApplyList
                .map((item) => item as Map<String, dynamic>)
                .toList();
          } else {
            throw Exception('Unexpected JSON format for total_apply');
          }
        } else {
          throw Exception('Unexpected JSON format');
        }
      } catch (e) {
        throw Exception('Error parsing JSON: $e');
      }
    } else {
      throw Exception(
          'Failed to load data. Status code: ${response.statusCode}');
    }
  }

  void filterDataByDate(String selectedDate) {
    setState(() {
      filteredData = filteredData.where((item) {
        String formattedCreatedAt = formatDateString(item['created_at']);
        bool matches = formattedCreatedAt == selectedDate;
        print(
            "Filtering: ${formattedCreatedAt} == ${selectedDate} => $matches");
        return matches;
      }).toList();
      // Update the data source with the filtered data
      dataSource = CityApplyReportDataSource(filteredData);
    });
    print("Filtered Data: $filteredData");
  }

  String formatDateString(String dateString) {
    try {
      DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      print("Error parsing date: $e");
      return dateString; // Return the original string if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: historyData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No History Available',
                style: GoogleFonts.habibi(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          } else {
            filteredData = snapshot.data!;
            dataSource = CityApplyReportDataSource(filteredData);
            return Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical, // Added scroll for vertical overflow
                            child: SizedBox(
                              width: constraints.maxWidth,
                              child: PaginatedDataTable(
                                columns: [
                                  DataColumn(
                                    label: Text(
                                      'Sr No.',
                                      style: GoogleFonts.habibi(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Row(
                                      children: [
                                        Text(
                                          'Date',
                                          style: GoogleFonts.habibi(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        InkWell(
                                          onTap: () async {
                                            DateTime? pickedDate =
                                            await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2101),
                                            );
                                            if (pickedDate != null) {
                                              String formattedDate =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(pickedDate);
                                              _dateController.text =
                                                  formattedDate;
                                              filterDataByDate(formattedDate);
                                            }
                                          },
                                          child: const Icon(Icons.calendar_month),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Election No.',
                                      style: GoogleFonts.habibi(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Elect. Start Time.',
                                      style: GoogleFonts.habibi(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Win/Lose',
                                      style: GoogleFonts.habibi(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Slot No.',
                                      style: GoogleFonts.habibi(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Win Point',
                                      style: GoogleFonts.habibi(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Status',
                                      style: GoogleFonts.habibi(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                source: dataSource,
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
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

}

class CityApplyReportDataSource extends DataTableSource {
  final List<Map<String, dynamic>> data;

  CityApplyReportDataSource(this.data);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final item = data[index];

    final int winLoseStatus = int.tryParse(item['is_winner'].toString()) ?? 0;

    final DateTime? electStartTime = DateTime.tryParse(item['elect_start_time'] ?? '');
    final DateTime now = DateTime.now();

    String winLoseText;


    if (electStartTime != null && now.isBefore(electStartTime.add(const Duration(hours: 1)))) {
      winLoseText = 'Pending';
    } else {
      if (winLoseStatus == 0) {
        winLoseText = 'Pending';
      } else if (winLoseStatus == 1) {
        winLoseText = 'Win';
      } else if (winLoseStatus == 2) {
        winLoseText = 'Lose';
      } else {
        winLoseText = 'Unknown'; // Handle any unexpected values
      }
    }



    // final DateTime? electStartTime =
    //     DateTime.tryParse(item['elect_start_time'] ?? '');
    // final DateTime now = DateTime.now();

    final String myStatusText =
    (electStartTime == null || now.isAfter(electStartTime.add(const Duration(hours: 1))))
        ? 'Closed'
        : 'Pending';

    final String winPoint = (winLoseStatus == 1) ? '400' : '0';

    return DataRow(
      cells: [
        DataCell(Center(child: Text((index + 1).toString()))),
        DataCell(Text(formatDateString(item['created_at']))),
        DataCell(Center(child: Text(item['group_id'].toString()))),
        DataCell(Center(child: Text(item['elect_start_time']))),
        DataCell(Center(child: Text(winLoseText))),
        DataCell(Center(child: Text(item['slot_id'].toString()))),
        DataCell(Center(child: Text(winPoint))),
        DataCell(Center(child: Text(myStatusText))),
      ],
    );
  }

  String formatDateString(String dateString) {
    try {
      DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      print("Error formatting date: $e");
      return dateString; // Return the original string if parsing fails
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
