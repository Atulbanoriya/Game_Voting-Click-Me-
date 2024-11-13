import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../custom/const.dart';
import '../../../model/applhestory/cityhistoryapply.dart';


class StateHistoryWin extends StatefulWidget {
  const StateHistoryWin({super.key});

  @override
  State<StateHistoryWin> createState() => _StateHistoryWinState();
}

class _StateHistoryWinState extends State<StateHistoryWin> {
  late Future<TodayVoterResponse> futureTodayVoter;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  final List<int> _availableRowsPerPage = [10, 25, 50, 75 ,100];

  @override
  void initState() {
    super.initState();
    futureTodayVoter = fetchVotingHistory();
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<TodayVoterResponse> fetchVotingHistory() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final requestBody = jsonEncode({'type': 'state'});

    final response = await http.post(
      Uri.parse('https://vote.nextgex.com/api/my_vote_list'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    // Log the token, status code, response body, and request body for debugging
    print('Token: $token');
    print('Request Body: $requestBody');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return TodayVoterResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load voting history: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<TodayVoterResponse>(
        future: futureTodayVoter,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.todayVoter.isEmpty) {
            return Center(child: Text(
              'No voting history found.',
              style: GoogleFonts.habibi(
                  fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ));
          } else {
            var detail = snapshot.data!.todayVoter.expand((voter) => voter.details).toList();
            return SingleChildScrollView(
              child: PaginatedDataTable(
                columns: [
                  DataColumn(
                    label: Center(
                      child: Text(
                        'Sr No.',
                        style: GoogleFonts.habibi(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Center(
                      child: Text(
                        'Date & Time',
                        style: GoogleFonts.habibi(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Center(
                      child: Text(
                        'My Vote To',
                        style: GoogleFonts.habibi(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Center(
                      child: Text(
                        'Win Votes',
                        style: GoogleFonts.habibi(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Center(
                      child: Text(
                        'Election ID',
                        style: GoogleFonts.habibi(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Center(
                      child: Text(
                        'Winner Name & Image',
                        style: GoogleFonts.habibi(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Center(
                      child: Text(
                        'CR/DR Point',
                        style: GoogleFonts.habibi(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
                source: _VoteDataSource(context, detail),
                rowsPerPage: _rowsPerPage,
                availableRowsPerPage:
                _availableRowsPerPage,
                onRowsPerPageChanged: (value) {
                  setState(() {
                    _rowsPerPage = value ?? _rowsPerPage;
                  });
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class _VoteDataSource extends DataTableSource {
  final BuildContext context;
  final List<Detail> votes;

  _VoteDataSource(this.context, this.votes);

  @override
  DataRow? getRow(int index) {
    if (index >= votes.length) return null;
    final vote = votes[index];

    return DataRow(cells: [
      DataCell(Center(child: Text((index + 1).toString()))),
      DataCell(Center(child: Text('${vote.date} - ${vote.time}'))),
      DataCell(Text(vote.byVoteName.toString())),
      DataCell(Center(child: Text(vote.totalVotesWinning.toString()))),
      DataCell(Center(child: Text(vote.electionId.toString()))),
      DataCell(Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(vote.winnerName.toString()),
              const SizedBox(
                width: 5,
              ),
              CircleAvatar(
                backgroundImage: vote.winnerWithImage != null
                    ? NetworkImage('${ConstRes.imageUrl}${vote.winnerWithImage!}')
                    : const AssetImage('asset/images/placeholder.png')
                as ImageProvider,
                radius: 15,
              ),
            ],
          ))),
      DataCell(Center(child: Text("${vote.creditPoint.toString()} Pts"))),
    ]);
  }

  @override
  int get rowCount => votes.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
