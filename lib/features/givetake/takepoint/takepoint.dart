import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:voter_multi_app/features/dashboard/home.dart';

import '../../../model/p2p_trxs/p2p_trxs_get/trxs_get_model.dart';
import 'package:voter_multi_app/custom/const.dart';

class TakePointView extends StatefulWidget {
  const TakePointView({super.key});

  @override
  State<TakePointView> createState() => _TakePointViewState();
}

class _TakePointViewState extends State<TakePointView> {
  Map<String, dynamic>? _profileData;
  List<Collection> transactions = [];
  final remarkController = TextEditingController();
  int? firstTransactionId;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _fetchTransactionData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Token not found');

      final response = await http.get(
        Uri.parse('https://vote.nextgex.com/api/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('user')) {
          var userData = responseData['user'];
          if (userData.containsKey('wallet_amount')) {
            setState(() {
              _profileData = userData;
            });
          } else {
            throw Exception('User data does not contain wallet_amount key');
          }
        } else {
          throw Exception(
              'API Response does not contain user key or is not a Map');
        }
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchTransactionData() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Token not found');

      final response = await http.get(
        Uri.parse('https://vote.nextgex.com/api/p2p_trxs'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final trnxsModel = trnxsGetModel.fromJson(responseData);

        if (trnxsModel.collection != null) {
          setState(() {
            transactions = trnxsModel.collection!;
            firstTransactionId = trnxsModel.collection!.first.id;
          });
        } else {
          _showCustomSnackBar(context, "No transactions found");
        }
      } else if (response.statusCode == 500) {
        // Handle the specific "Data Not Available" error
        final errorResponse = json.decode(response.body);
        if (errorResponse['error'] == "Data Not Available.") {
          _showCustomSnackBar(
              context, "No transactions available at the moment.");
        } else {
          _showCustomSnackBar(context, "Server error, please try again later");
        }
      } else {
        _showCustomSnackBar(context, "Failed to fetch transaction data");
      }
    } catch (e) {
      print('Error during fetching transactions: $e');
      _showCustomSnackBar(
          context, 'Error occurred while fetching transactions');
    }
  }

// Custom SnackBar function with styles
  void _showCustomSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.habibi(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        elevation: 6.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> approveTransaction() async {
    await _verifyTransaction(status: 1);
  }

  Future<void> rejectTransaction() async {
    if (remarkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remark is required for rejection')),
      );
      return;
    }
    await _verifyTransaction(status: 2);
  }

  Future<void> _verifyTransaction({required int status}) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Token not found');
      if (firstTransactionId == null)
        throw Exception('Transaction ID not found');

      final payload = {
        'trx_id': firstTransactionId.toString(),
        'description': remarkController.text.isNotEmpty
            ? remarkController.text
            : 'No description provided',
        'status': status.toString(),
      };

      final uri = Uri.parse('https://vote.nextgex.com/api/p2p_re_verify');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      print('Request URL: $uri');
      print('Request Headers: $headers');
      print('Request Payload: ${jsonEncode(payload)}');

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(payload),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Transaction ${status == 1 ? 'approved' : 'rejected'} successfully')),
        );
        _fetchTransactionData();
      } else {
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['error'] ?? 'Unknown error';
        throw Exception(
            'Failed to verify transaction. Status code: ${response.statusCode}, Response: $errorMessage');
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> withdraw() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userDataString = prefs.getString('userData');
      final String? token = prefs.getString('token');

      if (userDataString == null || token == null) {
        print("User data or token not found in SharedPreferences");
        return;
      }

      final Map<String, dynamic> userData = json.decode(userDataString);
      final Map<String, dynamic>? user = userData['user'];

      if (user == null) {
        print("User data not found in userData");
        return;
      }

      final int? userId = user['id'];

      if (userId == null) {
        print("User ID not found in user data");
        return;
      }

      final requestPayload = {
        'user_id': userId,
      };

      final response = await http.post(
        Uri.parse('https://vote.nextgex.com/api/p2p_requests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestPayload),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Withdraw successful: $responseData');
        showCustomDialog(
          context,
          title: 'Withdraw Request ',
          content: 'Successfull Done',
          // onPressed: (){
          //   Navigator.push(context, MaterialPageRoute(builder: (_)=> HomeView()));
          // }
        );
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error'] ?? 'Unknown error occurred';
        print('Withdraw failed: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      }
    } catch (e) {
      print('Error during withdraw: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void showCustomDialog(BuildContext context,
      {required String title,
      required String content,
      VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                if (onPressed != null) {
                  onPressed();
                }
              },
              child: Container(
                height: 50,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xffa0cf1a),
                ),
                child: Center(
                  child: Text(
                    "Okay",
                    style: GoogleFonts.habibi(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: withdraw,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xffa0cf1a),
                          ),
                          child: Center(
                            child: Text(
                              "Withdraw",
                              style: GoogleFonts.habibi(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Icon(Icons.arrow_back),
                    Expanded(
                      child: Image.asset(
                        "asset/images/sokarupee.png",
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                thickness: 2,
                color: Colors.black,
              ),
              const SizedBox(
                height: 10,
              ),
              ...transactions.map((transaction) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 350,
                      height: 260,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        boxShadow: const [
                          BoxShadow(
                            offset: Offset(2, 2),
                          )
                        ],
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Request Id :- ${transaction.requestId}",
                                  style: GoogleFonts.b612(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  "Name :- ${transaction.userName}",
                                  style: GoogleFonts.habibi(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  "Phone No.:- ${transaction.memberPhone}",
                                  style: GoogleFonts.b612(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  "UTR No. :- ${transaction.trxNo}",
                                  style: GoogleFonts.b612(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (transaction.image != null &&
                                        transaction.image!.isNotEmpty) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            child: Image.network(
                                                "${ConstRes.imageUrl}${transaction.image}"),
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: SizedBox(
                                    height: 40,
                                    width: 60,
                                    child: Image.network(
                                      "${ConstRes.imageUrl}${transaction.image}",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextFormField(
                            controller: remarkController,
                            decoration: InputDecoration(
                              label: Text(
                                "Remark",
                                style: GoogleFonts.habibi(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 20.0, right: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: approveTransaction,
                                  child: Container(
                                    height: 30,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: const Color(0xffa0cf1a),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Approve",
                                        style: GoogleFonts.habibi(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  "Or",
                                  style: GoogleFonts.habibi(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: rejectTransaction,
                                  child: Container(
                                    height: 30,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: const Color(0xffe03b24),
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class Transaction {
  final String userName;
  final String utrNo;
  final int requestId;

  Transaction(
      {required this.userName, required this.utrNo, required this.requestId});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      userName: json['user_name'] ?? '',
      utrNo: json['utr_no'] ?? '',
      requestId: json['request_id'] ?? 0,
    );
  }
}

class TrxsVerifyModel {
  final int trx_id;
  final String description;
  final int status;

  TrxsVerifyModel(
      {required this.trx_id, required this.description, required this.status});

  factory TrxsVerifyModel.fromJson(Map<String, dynamic> json) {
    return TrxsVerifyModel(
      trx_id: json['trx_id'],
      description: json['description'],
      status: json['status'],
    );
  }
}
