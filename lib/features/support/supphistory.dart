import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SuppHistory extends StatefulWidget {
  @override
  _SuppHistoryState createState() => _SuppHistoryState();
}

class _SuppHistoryState extends State<SuppHistory> {
  late Future<List<Ticket>> _ticketList;
  int _rowsPerPage = 10;
  final List<int> _availableRowsPerPage = [10, 20, 30];

  @override
  void initState() {
    super.initState();
    _ticketList = fetchTickets();
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Ticket>> fetchTickets() async {
    final String? token = await getToken();

    if (token == null) {
      throw Exception('Failed to load token');
    }

    final response = await http.get(
      Uri.parse('https://vote.nextgex.com/api/ticket_support_list'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Ticket.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load tickets');
    }
  }

  Future<List<TicketReply>> fetchTicketReply(String ticketId) async {
    final String? token = await getToken();

    if (token == null) {
      throw Exception('Failed to load token');
    }

    final String url =
        'https://vote.nextgex.com/api/ticket_support_reply?id=$ticketId';
    print('Fetching ticket reply from: $url');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => TicketReply.fromJson(item)).toList();
      } catch (e) {
        print('Error decoding JSON: $e');
        throw Exception('Failed to parse ticket reply');
      }
    } else {
      print('Error: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to load ticket reply');
    }
  }

  void showTicketReplyDialog(BuildContext context, List<TicketReply> ticketReplies) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Ticket Reply',
            style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ticketReplies.isEmpty
                ? Center(
              child: Text(
                'No Reply',
                style: GoogleFonts.habibi(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              itemCount: ticketReplies.length,
              itemBuilder: (BuildContext context, int index) {
                final reply = ticketReplies[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Message: ${reply.message}',
                        style: GoogleFonts.b612(fontSize: 16),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Date & Time: ${reply.formattedCreatedAt}', // Use formatted date
                        style: GoogleFonts.b612(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Divider(),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Close',
                style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffa0cf1a),
        title: Text(
          'Support History',
          style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Ticket>>(
        future: _ticketList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No tickets found',
                style: GoogleFonts.habibi(
                    fontWeight: FontWeight.bold, fontSize: 25),
              ),
            );
          } else {
            return SingleChildScrollView(
              child: PaginatedDataTable(
                columns: [
                  DataColumn(
                    label: Text(
                      'Sr No',
                      style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Center(
                      child: Text(
                        'Date',
                        style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Ticket ID',
                      style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Center(
                      child: Text(
                        'Query Type',
                        style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Status',
                      style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Center(
                      child: Text(
                        'Reply',
                        style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
                source: _TicketDataSource(
                  snapshot.data!,
                  fetchTicketReply,
                  showTicketReplyDialog,
                  context,
                ),
                rowsPerPage: _rowsPerPage,
                availableRowsPerPage:
                    _availableRowsPerPage, // Set the available rows per page
                onRowsPerPageChanged: (value) {
                  setState(() {
                    _rowsPerPage =
                        value ?? _rowsPerPage; // Update rows per page
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

class Ticket {
  final int id;
  final String createdAt;
  final String querySubject;
  final String status;

  Ticket({
    required this.id,
    required this.createdAt,
    required this.querySubject,
    required this.status,
  });

  String get formattedCreatedAt {
    try {
      final DateTime parsedDate = DateTime.parse(createdAt);
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
    } catch (e) {
      return createdAt; // Return original if parsing fails
    }
  }

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      createdAt: json['created_at'],
      querySubject: json['query_subject'],
      status: json['status'],
    );
  }
}

class TicketReply {
  final String message;
  final String createdAt;

  TicketReply({
    required this.message,
    required this.createdAt,
  });

  String get formattedCreatedAt {
    try {
      final DateTime parsedDate = DateTime.parse(createdAt);
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
    } catch (e) {
      return createdAt;
    }
  }

  factory TicketReply.fromJson(Map<String, dynamic> json) {
    return TicketReply(
      message: json['message'],
      createdAt: json['created_at'],
    );
  }
}

class _TicketDataSource extends DataTableSource {
  final List<Ticket> _data;
  final Future<List<TicketReply>> Function(String ticketId) fetchTicketReply;
  final void Function(BuildContext context, List<TicketReply> ticketReplies)
      showTicketReplyDialog;
  final BuildContext context;

  _TicketDataSource(
    this._data,
    this.fetchTicketReply,
    this.showTicketReplyDialog,
    this.context,
  );

  @override
  DataRow getRow(int index) {
    final ticket = _data[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text('${index + 1}'))),
        DataCell(Text(ticket.formattedCreatedAt)),
        DataCell(Text(ticket.id.toString())),
        DataCell(Text(ticket.querySubject)),
        DataCell(
          Center(
            child: Text(
              ticket.status,
              style: GoogleFonts.habibi(
                fontWeight: FontWeight.bold,
                color: _getStatusColor(ticket.status),
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () async {
                  final List<TicketReply> replies =
                      await fetchTicketReply(ticket.id.toString());
                  showTicketReplyDialog(context, replies);
                },
                child: Container(
                  height: 60,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.blue,
                  ),
                  child: Center(
                    child: Text(
                      "View",
                      style: GoogleFonts.habibi(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ElevatedButton(
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: const Color(0xffa0cf1a),
            //   ),
            //   onPressed: () async {
            //     final List<TicketReply> replies = await fetchTicketReply(ticket.id.toString());
            //     showTicketReplyDialog(context, replies);
            //   },
            //   child: Text(
            //     'Reply',
            //     style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
            //   ),
            // ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'open':
        return Colors.green;
      case 'closed':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _data.length;
  @override
  int get selectedRowCount => 0;
}
