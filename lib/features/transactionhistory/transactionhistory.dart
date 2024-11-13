import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  List transactions = [];
  List filteredTransactions = [];
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController _dateController = TextEditingController();

  int _rowsPerPage = 10;

  final List<int> _availableRowsPerPage = [10, 25 , 50, 75, 100];

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchTransactions() async {
    try {
      final token = await getToken();
      if (token == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'Token not found';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('https://vote.nextgex.com/api/transaction_record'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          transactions = data['transactions'];
          filteredTransactions = transactions;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load transactions: ${response.reasonPhrase}';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred: $error';
      });
    }
  }

  void filterTransactionsByDate(String selectedDate) {
    setState(() {
      filteredTransactions = transactions.where((transaction) {
        return transaction['trns_date'] == selectedDate;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffa0cf1a),
        title: Text(
          "Transaction History",
          style: GoogleFonts.habibi(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : filteredTransactions.isEmpty
          ? Center(
        child: Text(
          "No transactions found",
          style: GoogleFonts.habibi(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : SingleChildScrollView(
        child: PaginatedDataTable(
          columns: [
            DataColumn(
                label: Text(
                  'SR No.',
                  style: GoogleFonts.habibi(
                    fontWeight: FontWeight.bold,
                  ),
                )),
            DataColumn(
                label: Row(
                  children: [
                    Text(
                      'Date',
                      style: GoogleFonts.habibi(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
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
                            DateFormat('yyyy-MM-dd')
                                .format(pickedDate);
                            _dateController.text = formattedDate;
                            filterTransactionsByDate(formattedDate);
                          }
                        },
                        child: Icon(Icons.calendar_month)),
                  ],
                )),
            DataColumn(
                label: Text(
                  'Points',
                  style: GoogleFonts.habibi(
                    fontWeight: FontWeight.bold,
                  ),
                )),
            DataColumn(
                label: Text(
                  'Transaction No.',
                  style: GoogleFonts.habibi(
                    fontWeight: FontWeight.bold,
                  ),
                )),
            DataColumn(
                label: Text(
                  'To Member',
                  style: GoogleFonts.habibi(
                    fontWeight: FontWeight.bold,
                  ),
                )),
            DataColumn(
                label: Text(
                  'To Member ID',
                  style: GoogleFonts.habibi(
                    fontWeight: FontWeight.bold,
                  ),
                )),
            DataColumn(
                label: Text(
                  'Remark',
                  style: GoogleFonts.habibi(
                    fontWeight: FontWeight.bold,
                  ),
                )),
          ],
          source: TransactionDataSource(filteredTransactions),
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
      ),
    );
  }

}

class TransactionDataSource extends DataTableSource {
  final List transactions;

  TransactionDataSource(this.transactions);

  @override
  DataRow? getRow(int index) {
    if (index >= transactions.length) return null;
    final transaction = transactions[index];
    return DataRow(
      cells: [
        DataCell(Text((index + 1).toString())), // Display SR No. as index + 1
        DataCell(Text(transaction['trns_date'])),
        DataCell(
          Text(
            "${transaction['trns_amount'] ?? 'N/A'} / ${transaction['trns_type']}",
            style: GoogleFonts.cabin(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: transaction['trns_type'] == 'Cr' ? Colors.green : Colors.red,
            ),
          ),
        ),
        DataCell(Text(transaction['trans_ref_no'])),
        DataCell(Center(child: Text(transaction['user_name']))),
        DataCell(Center(child: Text(transaction['to_member_id'] ?? 'N/A'))),
        DataCell(Text(transaction['trns_remark'])),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => transactions.length;

  @override
  int get selectedRowCount => 0;
}
