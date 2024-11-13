import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voter_multi_app/features/regivepayment/regivepayment.dart';

class GiveHistory extends StatefulWidget {
  const GiveHistory({super.key});

  @override
  State<GiveHistory> createState() => _GiveHistoryState();
}

class _GiveHistoryState extends State<GiveHistory> {
  List<Map<String, dynamic>> transactions = [];
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  final List<int> _availableRowsPerPage = [10, 25, 50, 75, 100];
  int _sortColumnIndex = 1;
  bool _sortAscending = true;

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

            // Sort transactions by date
            transactions.sort((a, b) => _sortAscending
                ? a['created_at'].compareTo(b['created_at'])
                : b['created_at'].compareTo(a['created_at']));
          });
        } else {
          print('Unexpected response format. Keys: ${data.keys}');
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  void _sort<T>(
      Comparable<T> Function(Map<String, dynamic> d) getField,
      int columnIndex,
      bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      transactions.sort((a, b) {
        if (!ascending) {
          final Map<String, dynamic> c = a;
          a = b;
          b = c;
        }
        final Comparable<T> aValue = getField(a);
        final Comparable<T> bValue = getField(b);
        return Comparable.compare(aValue, bValue);
      });
    });
  }

  void _handleReject(String requestId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReGivePayment(requestId: requestId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: transactions.isEmpty
          ? Center(
        child: Text(
          'No Given History',
          style: GoogleFonts.habibi(
              fontWeight: FontWeight.bold, fontSize: 20),
        ),
      )
          : LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: PaginatedDataTable(
                columns: [
                  const DataColumn(label: Text('Sr No')),
                  DataColumn(
                      label: const Text('Date'),
                      onSort: (columnIndex, ascending) =>
                          _sort<String>((d) => d['created_at'],
                              columnIndex, ascending)),
                  const DataColumn(label: Text('To Request Id')),
                  const DataColumn(label: Text('To Member')),
                  const DataColumn(label: Text('Member No.')),
                  const DataColumn(label: Text('Point')),
                  const DataColumn(label: Text('UTR No.')),
                  const DataColumn(label: Text('Status')),
                ],
                source: _DataTableSource(
                    transactions, _handleReject, context),
                rowsPerPage: _rowsPerPage,
                availableRowsPerPage: _availableRowsPerPage,
                onRowsPerPageChanged: (value) {
                  setState(() {
                    _rowsPerPage = value!;
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DataTableSource extends DataTableSource {
  final List<Map<String, dynamic>> _data;
  final void Function(String) onReject;
  final BuildContext context;

  _DataTableSource(this._data, this.onReject, this.context);

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _data.length) return null as DataRow;
    final transaction = _data[index];

    Widget statusWidget;
    var status = transaction['status'];

    if (status is String) {
      status = int.tryParse(status) ?? -1;
    } else if (status is int) {
      status = -1;
    }

    switch (status) {
      case 0:
        statusWidget = const Text('Pending');
        break;
      case 1:
        statusWidget = const Text('Approve');
        break;
      case 2:
        statusWidget = Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              onReject(transaction['id'].toString());
            },
            child: Container(
              height: 60,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.red,
              ),
              child: Center(
                child: Text(
                  "Reject",
                  style: GoogleFonts.habibi(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
        break;
      default:
        statusWidget = const Text('Unknown');
    }

    return DataRow.byIndex(index: index, cells: [
      DataCell(Text((index + 1).toString())),
      DataCell(Text(transaction['created_at'] ?? '')),
      DataCell(Center(child: Text(transaction['request_id'].toString() ?? ''))),
      DataCell(Text(transaction['user_name'] ?? '')),
      DataCell(Row(
        children: [
          Text(transaction['member_phone'] ?? ''),
          IconButton(
            icon: const Icon(Icons.copy, size: 16, color: Colors.blue),
            onPressed: () {
              Clipboard.setData(
                  ClipboardData(text: transaction['member_phone']));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Member number copied to clipboard!')),
              );
            },
          ),
        ],
      )),
      const DataCell(Text('100')),
      DataCell(Text(transaction['trx_no'] ?? '')),
      DataCell(statusWidget),
    ]);
  }

  @override
  int get rowCount => _data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}








