import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ApplyCandidatePage extends StatefulWidget {
  const ApplyCandidatePage({super.key});

  @override
  State<ApplyCandidatePage> createState() => _ApplyCandidatePageState();
}

class _ApplyCandidatePageState extends State<ApplyCandidatePage> {
  Map<String, dynamic>? _profileData;
  final _formKey = GlobalKey<FormState>();
  bool _acceptedTerms = false;
  bool _isLoading = false;
  String? _selectedState;
  String? _selectedElectionStartTime;
  List<String> _electionStartTimes = [];
  final List<String> _states = ['city', 'state'];
  final _numberOfFormsController = TextEditingController();
  final _amountController = TextEditingController();
  String? _slotId;

  Map<String, int> startTimeToIdMap = {};

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _numberOfFormsController.addListener(_updateAmount);
  }

  @override
  void dispose() {
    _numberOfFormsController.removeListener(_updateAmount);
    _numberOfFormsController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfileData() async {
    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.get(
        Uri.parse('https://vote.nextgex.com/api/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        print('API Response Data: $responseData');

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('user')) {
          var userData = responseData['user'];
          if (userData.containsKey('wallet_amount')) {
            setState(() {
              _profileData = userData;
            });
          } else {
            print('User data does not contain wallet_amount key');
            throw Exception('User data does not contain wallet_amount key');
          }
        } else {
          print('API Response does not contain user key or is not a Map');
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

  Future<void> fetchElectionStartTime(String type) async {
    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.post(
        Uri.parse('https://vote.nextgex.com/api/getSlot'),
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: {'type': type},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData.containsKey('slots') &&
            responseData['slots'] is List &&
            responseData['slots'].isNotEmpty) {
          List<String> electionStartTimes = [];
          startTimeToIdMap.clear();

          for (var slot in responseData['slots']) {
            if (slot.containsKey('elect_start_time') &&
                slot.containsKey('id')) {
              String startTime = slot['elect_start_time'];
              int slotId = slot['id'];
              electionStartTimes.add(startTime);
              startTimeToIdMap[startTime] = slotId;
            }
          }

          if (electionStartTimes.isNotEmpty) {
            print('Election start times: $electionStartTimes');
            if (mounted) {
              setState(() {
                _electionStartTimes = electionStartTimes;
                _selectedElectionStartTime = _electionStartTimes[0];
                _slotId =
                    startTimeToIdMap[_selectedElectionStartTime]!.toString();
              });
            }
          } else {
            throw Exception('No valid election start times found');
          }
        } else {
          throw Exception('Invalid response data');
        }
      } else {
        throw Exception('Failed to load election start time');
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void onSelectElectionStartTime(String selectedTime) {
    setState(() {
      _selectedElectionStartTime = selectedTime;
      _slotId = startTimeToIdMap[selectedTime]
          .toString(); // Update the slot ID based on the selected time
    });
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void _updateAmount() {
    final numberOfForms = int.tryParse(_numberOfFormsController.text) ?? 0;
    if (_selectedState == 'city') {
      _amountController.text = (numberOfForms * 100).toString();
    } else if (_selectedState == 'state') {
      _amountController.text = (numberOfForms * 1000).toString();
    } else {
      _amountController.text = '0';
    }
  }

  Future<void> submitApplication(int numberOfForms) async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'You must accept the Terms & Conditions before applying.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('Token not found');
      }

      if (_slotId == null) {
        throw Exception('Slot ID not found');
      }

      final response = await http.post(
        Uri.parse('https://vote.nextgex.com/api/candidate_apply'),
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: {
          'slot_id': _slotId!,
          'count': numberOfForms.toString(),
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Handling both 200 and non-200 responses with success messages
      if (response.statusCode == 200 || response.statusCode == 201) {

        _showCustomSnackBar(context, "Ticket Booked successfully");

        setState(() {
          _selectedState = null;
          _selectedElectionStartTime = null;
          _electionStartTimes.clear();
          _acceptedTerms = false;
          _profileData = null;
          _numberOfFormsController.clear();
          _amountController.clear();
        });

        await _fetchProfileData();
      } else if (response.statusCode == 400) {
        var errorResponse = json.decode(response.body);
        if (errorResponse['message'].contains('Account Booked successfully')) {
          _showCustomSnackBar(context, "Ticket Booked successfully");

          setState(() {
            _selectedState = null;
            _selectedElectionStartTime = null;
            _electionStartTimes.clear();
            _acceptedTerms = false;
            _profileData = null;
            _numberOfFormsController.clear();
            _amountController.clear();
          });

          await _fetchProfileData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${errorResponse['message']}')),
          );
        }
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        var errorResponse = json.decode(response.body);

        _showCustomSnackBar(context, "Ticket Booked successfully");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${errorResponse['message']}')),
        );
      } else if (response.statusCode >= 500) {
        _showCustomSnackBar(context, 'Server error, please try again later.');
      } else {
        throw Exception('Unexpected error occurred.');
      }
    } on SocketException {
      _showCustomSnackBar(context, 'No Internet connection');
    } on FormatException {
      _showCustomSnackBar(context, "'Bad response format'");
    } catch (e) {
      _showCustomSnackBar(context, 'Something went wrong: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffa0cf1a),
        title: Text(
          "Apply For Candidate",
          style: GoogleFonts.habibi(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "* Candidate Apply Form instructions :-",
                  style: GoogleFonts.chakraPetch(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                Text(
                  "* 1 point = 1 rupee .",
                  style: GoogleFonts.chakraPetch(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                Text(
                  "* There are two types of Election's. City And State .",
                  style: GoogleFonts.chakraPetch(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                Text(
                  "* If you Apply for City Election, City Election fee is -100 point .",
                  style: GoogleFonts.chakraPetch(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                Text(
                  "* If you Apply for State Election, State Election fee is -1000 point .",
                  style: GoogleFonts.chakraPetch(
                    fontWeight: FontWeight.bold,
                    fontSize: 9.9,
                  ),
                ),
                Text(
                  "* And your Status will declare after your processing .",
                  style: GoogleFonts.chakraPetch(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 30,
                        ),
                        Text(
                          ':- ',
                          style: GoogleFonts.habibi(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          _profileData?['wallet_amount']?.toString() ??
                              'Loading...',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Points',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.paperclip,
                          size: 25,
                        ),
                        Text(
                          ':- ',
                          style: GoogleFonts.habibi(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '${_profileData?['total_income'].toString()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Points',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  value: _selectedState,
                  decoration: InputDecoration(
                    label: Text(
                      "Election Type",
                      style: GoogleFonts.habibi(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _states.map((String state) {
                    return DropdownMenuItem<String>(
                      value: state,
                      child: Text(
                        state,
                        style: GoogleFonts.habibi(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedState = newValue!;
                    });
                    fetchElectionStartTime(_selectedState!);
                    _updateAmount();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an Election Type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  value: _selectedElectionStartTime,
                  decoration: InputDecoration(
                    label: Text(
                      "Election Start Time",
                      style: GoogleFonts.habibi(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _electionStartTimes.map((String time) {
                    return DropdownMenuItem<String>(
                      value: time,
                      child: Text(
                        time,
                        style: GoogleFonts.b612(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      onSelectElectionStartTime(newValue);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an election start time';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _numberOfFormsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          label: Text(
                            "Forms Qty",
                            style: GoogleFonts.habibi(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the number of forms';
                          }
                          final intValue = int.tryParse(value);
                          if (intValue == null || intValue <= 0) {
                            return 'Please enter a valid number of forms';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 100),
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          label: Text(
                            "Amount",
                            style: GoogleFonts.habibi(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the number of forms';
                          }
                          final intValue = int.tryParse(value);
                          if (intValue == null || intValue <= 0) {
                            return 'Please enter a valid number of forms';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      activeColor: const Color(0xffa0cf1a),
                      value: _acceptedTerms,
                      onChanged: (bool? value) {
                        setState(() {
                          _acceptedTerms = value!;
                        });
                      },
                    ),
                    Text(
                      'I accept your Terms & Conditions',
                      style: GoogleFonts.habibi(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _isLoading
                    ? const CircularProgressIndicator()
                    : InkWell(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            submitApplication(
                                int.parse(_numberOfFormsController.text));
                          }
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: _acceptedTerms
                                ? const Color(0xffa0cf1a)
                                : Colors.grey,
                          ),
                          child: Center(
                            child: Text(
                              "Apply",
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
            ),
          ),
        ),
      ),
    );
  }
}
