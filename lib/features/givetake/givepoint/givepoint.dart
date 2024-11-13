// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:voter_multi_app/features/dashboard/dashboard.dart';
//
// class GivePointView extends StatefulWidget {
//   const GivePointView({super.key});
//
//   @override
//   State<GivePointView> createState() => _GivePointViewState();
// }
//
// class _GivePointViewState extends State<GivePointView> {
//   String? _upiID;
//   int? _requestid;
//   String? _name;
//   String? _number;
//   String? _upiQRCode;
//   File? _qrCodeImage;
//   File? _selectedImage;
//   TextEditingController _utrController = TextEditingController();
//   Map<String, dynamic>? _profileData;
//   int? _userId;
//   int? _requestId;
//   bool _isPayButtonClicked = false;
//   int? userLoginid;
//   int? _fromId;
//   bool _isLoading = false;
//   bool _hasWithdrawRequest = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkLockState();
//     _fetchProfileData();
//     _fetchP2PRequestData();
//   }
//
//   Future<void> _checkLockState() async {
//     final prefs = await SharedPreferences.getInstance();
//     final lockTime = prefs.getString('lock_time');
//
//     if (lockTime != null) {
//       final lockStartTime = DateTime.parse(lockTime);
//       final now = DateTime.now();
//       final remainingLockTime = lockStartTime.add(Duration(minutes: 5)).difference(now);
//
//       if (remainingLockTime > Duration.zero) { // Check if the remaining time is positive
//         _navigateToLockPage(lockStartTime);
//       } else {
//         await prefs.remove('lock_time');
//       }
//     }
//   }
//
//
//   void _lockUser() async {
//     final prefs = await SharedPreferences.getInstance();
//     final lockStartTime = DateTime.now();
//     await prefs.setString('lock_time', lockStartTime.toIso8601String());
//
//     _navigateToLockPage(lockStartTime);
//   }
//
//   void _navigateToLockPage(DateTime lockStartTime) {
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(
//         builder: (context) => LockPage(lockStartTime: lockStartTime),
//       ),
//     );
//   }
//
//   Future<void> _fetchProfileData() async {
//     try {
//       final token = await getToken();
//
//       if (token == null) {
//         throw Exception('Token not found');
//       }
//
//       final response = await http.get(
//         Uri.parse('https://vote.nextgex.com/api/user'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         var responseData = json.decode(response.body);
//         print('API Response Data: $responseData');
//
//         if (responseData is Map<String, dynamic> && responseData.containsKey('user')) {
//           var userData = responseData['user'];
//           if (userData.containsKey('wallet_amount') && userData.containsKey('id')) {
//             setState(() {
//               _profileData = userData;
//               _userId = userData['id'];
//               userLoginid = _userId;
//             });
//           } else {
//             print('User data does not contain wallet_amount or id key');
//             throw Exception('User data does not contain wallet_amount or id key');
//           }
//         } else {
//           print('API Response does not contain user key or is not a Map');
//           throw Exception('API Response does not contain user key or is not a Map');
//         }
//       } else {
//         throw Exception('Failed to load profile data');
//       }
//     } catch (e) {
//       print('Exception: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     }
//   }
//
//   Future<void> _fetchP2PRequestData() async {
//     try {
//       final token = await getToken();
//
//       if (token == null) {
//         throw Exception('Token not found');
//       }
//
//       final response = await http.get(
//         Uri.parse('https://vote.nextgex.com/api/p2p_requests'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         var responseData = json.decode(response.body);
//         print('P2P Request Response: $responseData');
//
//         if (responseData is Map<String, dynamic> &&
//             responseData['name'] != null &&
//             responseData['upiid'] != null &&
//             responseData['member_phone'] != null) {
//           setState(() {
//             _hasWithdrawRequest = true;
//             _requestid = responseData['id'];
//             _name = responseData['name'];
//             _upiQRCode = responseData['upiqrcode'];
//             _upiID = responseData['upiid'];
//             _requestId = responseData['id'];
//             _number = responseData['member_phone'];
//             _fromId = responseData['user_id'];
//           });
//         } else {
//           setState(() {
//             _hasWithdrawRequest = false;
//           });
//         }
//       }
//     } catch (e) {
//       print('Exception: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     }
//   }
//
//
//
//   Future<String?> getToken() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _profileData == null
//           ? Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 20),
//           child: Column(
//             children: [
//               SizedBox(height: 20),
//               _hasWithdrawRequest
//                   ? Row(
//                 children: [
//                   Expanded(
//                     child: Image.asset(
//                       "asset/images/sokarupee.png",
//                       width: 60,
//                       height: 60,
//                     ),
//                   ),
//
//
//
//                   Icon(Icons.arrow_forward_outlined),
//
//                   SizedBox(width: 20),
//
//                   Expanded(
//                     child: InkWell(
//                       onTap: () {
//                         setState(() {
//                           _isPayButtonClicked = true;
//                           _lockUser();  // Lock the user when they click PAY
//                         });
//                       },
//                       child: Container(
//                         height: 60,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           color: Color(0xffa0cf1a),
//                         ),
//                         child: Center(
//                           child: Text(
//                             "PAY",
//                             style: GoogleFonts.habibi(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   Divider(
//                     thickness: 2,
//                     color: Colors.black,
//                   ),
//                   SizedBox(height: 20),
//                   _isPayButtonClicked
//                       ? Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                     ],
//                   )
//                       : Container(),
//                 ],
//               )
//                   : Center(
//                 child: Text(
//                   'No withdrawal requests available',
//                   style: GoogleFonts.habibi(
//                     fontSize: 20,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // LockPage widget
// class LockPage extends StatefulWidget {
//   final DateTime lockStartTime;
//
//   LockPage({required this.lockStartTime});
//
//   @override
//   _LockPageState createState() => _LockPageState();
// }
//
// class _LockPageState extends State<LockPage> {
//   late Timer _timer;
//   Duration _remainingTime = Duration(minutes: 5);
//
//   String? _upiID;
//   int? _requestid;
//   String? _name;
//   String? _number;
//   String? _upiQRCode;
//   File? _qrCodeImage;
//   File? _selectedImage;
//   TextEditingController _utrController = TextEditingController();
//   Map<String, dynamic>? _profileData;
//   int? _userId;
//   int? _requestId;
//   bool _isPayButtonClicked = false;
//   int? userLoginid;
//   int? _fromId;
//   bool _isLoading = false;
//   bool isPaymentSuccessful = false;
//
//
//   @override
//   void initState() {
//     super.initState();
//     _startLockTimer();
//     _fetchProfileData();
//     _fetchP2PRequestData();
//   }
//
//   Future<void> _fetchProfileData() async {
//     try {
//       final token = await getToken();
//
//       if (token == null) {
//         throw Exception('Token not found');
//       }
//
//       final response = await http.get(
//         Uri.parse('https://vote.nextgex.com/api/user'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         var responseData = json.decode(response.body);
//         print('API Response Data: $responseData');
//
//         if (responseData is Map<String, dynamic> && responseData.containsKey('user')) {
//           var userData = responseData['user'];
//           if (userData.containsKey('wallet_amount') && userData.containsKey('id')) {
//             setState(() {
//               _profileData = userData;
//               _userId = userData['id'];
//               userLoginid = _userId;
//             });
//           } else {
//             print('User data does not contain wallet_amount or id key');
//             throw Exception('User data does not contain wallet_amount or id key');
//           }
//         } else {
//           print('API Response does not contain user key or is not a Map');
//           throw Exception('API Response does not contain user key or is not a Map');
//         }
//       } else {
//         throw Exception('Failed to load profile data');
//       }
//     } catch (e) {
//       print('Exception: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     }
//   }
//
//   bool _noDataAvailable = false;
//
//   bool _hasWithdrawRequest = false;
//
//   Future<void> _fetchP2PRequestData() async {
//     try {
//       final token = await getToken();
//
//       if (token == null) {
//         throw Exception('Token not found');
//       }
//
//       final response = await http.get(
//         Uri.parse('https://vote.nextgex.com/api/p2p_requests'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         var responseData = json.decode(response.body);
//         print('P2P Request Response: $responseData');
//
//         if (responseData is Map<String, dynamic> &&
//             responseData['name'] != null &&
//             responseData['upiid'] != null &&
//             responseData['member_phone'] != null) {
//           setState(() {
//             _hasWithdrawRequest = true;
//             _requestid = responseData['id'];
//             _name = responseData['name'];
//             _upiQRCode = responseData['upiqrcode'];
//             _upiID = responseData['upiid'];
//             _requestId = responseData['id'];
//             _number = responseData['member_phone'];
//             _fromId = responseData['user_id'];
//           });
//         } else {
//           setState(() {
//             _hasWithdrawRequest = false;
//           });
//         }
//       }
//     } catch (e) {
//       print('Exception: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     }
//   }
//
//
//
//   Future<void> _pickImage() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//         print('Image selected: ${_selectedImage?.path}');
//       });
//     } else {
//       print('No image selected');
//     }
//   }
//
//   Future<void> submitPayment() async {
//     if (_utrController.text.isEmpty || _utrController.text.length != 16) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please enter a valid UTR number with 16 characters')),
//       );
//       return;
//     }
//
//     if (_selectedImage == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please upload an image')),
//       );
//       return;
//     }
//
//     try {
//       setState(() {
//         _isLoading = true; // Show loader
//       });
//
//       final token = await getToken();
//
//       if (token == null) {
//         throw Exception('Token not found');
//       }
//
//       final uri = Uri.parse('https://vote.nextgex.com/api/p2p_trxs');
//       final request = http.MultipartRequest('POST', uri)
//         ..headers['Authorization'] = 'Bearer $token'
//         ..fields['trx_no'] = _utrController.text
//         ..fields['from_user_id'] = userLoginid.toString()
//         ..fields['to_user_id'] = _fromId.toString()
//         ..fields['request_id'] = _requestId.toString()
//         ..files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));
//
//       final response = await request.send();
//
//       if (response.statusCode == 200) {
//         showCustomDialog(
//           context,
//           title: 'Payment Successful',
//           content: 'Payment was successfully submitted.',
//         );
//
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (context) => DashBoardView(token: token ?? 'default_token'), // Provide a default value or handle null case
//           ),
//         );
//
//         _clearForm(); // Clear form after successful submission
//       } else {
//         throw Exception('Failed to submit payment');
//       }
//     } catch (e) {
//       print('Exception: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false; // Hide loader
//       });
//     }
//   }
//
//   void _clearForm() {
//     _utrController.clear();
//     _selectedImage = null;
//     _isPayButtonClicked = false;
//     _upiID = null;
//     _name = null;
//     _number = null;
//     _upiQRCode = null;
//   }
//
//   Future<String?> getToken() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }
//
//   void showCustomDialog(BuildContext context, {required String title, required String content, VoidCallback? onPressed}) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title),
//           content: Text(content),
//           actions: <Widget>[
//             InkWell(
//               onTap: () {
//                 Navigator.of(context).pop();
//                 if (onPressed != null) {
//                   onPressed();
//                 }
//               },
//               child: Container(
//                 height: 50,
//                 width: 80,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   color: const Color(0xffa0cf1a),
//                 ),
//                 child: Center(
//                   child: Text(
//                     "Okay",
//                     style: GoogleFonts.habibi(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 20,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//
//
//   void _startLockTimer() {
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       setState(() {
//         final now = DateTime.now();
//         _remainingTime = widget.lockStartTime.add(Duration(minutes: 5)).difference(now);
//
//         if (_remainingTime.isNegative) {
//           _timer.cancel();
//           _unlockApp();
//         }
//       });
//     });
//   }
//
//   void _unlockApp() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('lock_time');
//
//     String? token = await getToken();
//
//
//
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(
//         builder: (context) => DashBoardView(token: token ?? 'default_token'), // Provide a default value or handle null case
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _startLockTimer();
//     _timer.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Center(
//           child: Container(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Text(
//                   "Do not Refresh This page!",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 20),
//                 Text(
//                   "Remaining time: ${_remainingTime.inMinutes}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}",
//                   style: TextStyle(fontSize: 25),
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   "Welcome, ${_profileData?['name']}",
//                   style: GoogleFonts.habibi(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   "Please  Submit payment Details \ Before Remaining Time!",
//                   style: GoogleFonts.habibi(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.red,
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(height: 20),
//
//                     Text(
//                       'Name: $_name',
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 20),
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       'Number: $_number',
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 20),
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       'UPI ID: $_upiID',
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 20),
//                     ),
//                     SizedBox(height: 20),
//                     _upiQRCode != null
//                         ? Image.network('https://vote.nextgex.com/storage/${_upiQRCode!}', width: 200, height: 200)
//                         : Text("UPI QR Code not available"),
//                     SizedBox(height: 20),
//                     TextField(
//                       controller: _utrController,
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(),
//                         labelText: 'Enter UTR Number',
//                       ),
//                       inputFormatters: [
//                         LengthLimitingTextInputFormatter(16),
//                         // FilteringTextInputFormatter.allow(RegExp(r'[ A-z ,0-9]')),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: _pickImage,
//                       child: Text("Upload Screenshot"),
//                     ),
//                     _selectedImage != null
//                         ? Image.file(_selectedImage!, width: 100, height: 100)
//                         : Text("No image selected"),
//                     SizedBox(height: 20),
//                     Center(
//                       child: InkWell(
//                         onTap: submitPayment, // Submit payment
//                         child: Container(
//                           height: 60,
//                           width: 150,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8),
//                             color: Color(0xffa0cf1a),
//                           ),
//                           child: Center(
//                             child: Text(
//                               "Submit",
//                               style: GoogleFonts.habibi(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:voter_multi_app/features/dashboard/dashboard.dart';
import 'down_history_give/down_history_givw.dart';
import 'package:dotted_border/dotted_border.dart';

class GivePointView extends StatefulWidget {
  const GivePointView({super.key});

  @override
  State<GivePointView> createState() => _GivePointViewState();
}

class _GivePointViewState extends State<GivePointView> {
  List<Map<String, dynamic>> transactions = [];

  String? _upiID;
  int? _requestid;
  String? _name;
  String? _number;
  String? _upiQRCode;
  File? _qrCodeImage;
  File? _selectedImage;
  TextEditingController _utrController = TextEditingController();
  Map<String, dynamic>? _profileData;
  int? _userId;
  int? _requestId;
  bool _isPayButtonClicked = false;
  int? userLoginid;
  int? _fromId;
  bool _isLoading = false;
  bool _hasWithdrawRequest = false;

  @override
  void initState() {
    super.initState();
    _checkLockState();
    _fetchProfileData();
    _fetchP2PRequestData();
  }

  Future<void> _checkLockState() async {
    final prefs = await SharedPreferences.getInstance();
    final lockTime = prefs.getString('lock_time');
    final isPaymentSuccessful = prefs.getBool('is_payment_successful') ?? false;

    if (lockTime != null && !isPaymentSuccessful) {
      final lockStartTime = DateTime.parse(lockTime);
      final now = DateTime.now();
      final remainingLockTime =
          lockStartTime.add(const Duration(minutes: 5)).difference(now);

      if (remainingLockTime > Duration.zero) {
        _navigateToLockPage(lockStartTime);
      } else {
        await prefs.remove('lock_time');
      }
    } else {
      await prefs.remove('lock_time');
    }
  }

  void _lockUser() async {
    final prefs = await SharedPreferences.getInstance();
    final lockStartTime = DateTime.now();
    await prefs.setString('lock_time', lockStartTime.toIso8601String());

    _navigateToLockPage(lockStartTime);
  }

  void _navigateToLockPage(DateTime lockStartTime) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LockPage(lockStartTime: lockStartTime),
      ),
    );
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
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
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('user')) {
          var userData = responseData['user'];
          setState(() {
            _profileData = userData;
            _userId = userData['id'];
            userLoginid = _userId;
          });
        } else {
          throw Exception('Unexpected API response');
        }
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _fetchP2PRequestData() async {
    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.get(
        Uri.parse('https://vote.nextgex.com/api/p2p_requests'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic> &&
            responseData['name'] != null &&
            responseData['upiid'] != null &&
            responseData['member_phone'] != null) {
          setState(() {
            _hasWithdrawRequest = true;
            _requestid = responseData['id'];
            _name = responseData['name'];
            _upiQRCode = responseData['upiqrcode'];
            _upiID = responseData['upiid'];
            _requestId = responseData['id'];
            _number = responseData['member_phone'];
            _fromId = responseData['user_id'];
          });
        } else {
          setState(() {
            _hasWithdrawRequest = false;
          });
        }
      } else {
        throw Exception('Failed to fetch P2P request data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _sendHoldRequest() async {
    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.post(
        Uri.parse('https://vote.nextgex.com/api/p2p_holdRequest'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'request_id': _requestid,
        }),
      );

      if (response.statusCode == 200) {
        print('Hold request successful');
      } else {
        print('Failed to send hold request');
        throw Exception('Failed to send hold request');
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _profileData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _hasWithdrawRequest
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Image.asset(
                                  "asset/images/sokarupee.png",
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                              const Icon(Icons.arrow_forward_outlined),
                              const SizedBox(width: 20),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    setState(() {
                                      _isPayButtonClicked = true;
                                    });

                                    // await _sendHoldRequest();

                                    _lockUser();
                                  },
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: const Color(0xffa0cf1a),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "PAY",
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
                            ],
                          ),
                        )
                      : Center(
                          child: Text(
                            'No withdrawal requests available',
                            style: GoogleFonts.habibi(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(thickness: 2, color: Colors.black),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        Text(
                          "Given History",
                          textAlign: TextAlign.start,
                          style: GoogleFonts.cabinCondensed(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const GivenDownHistory()));
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: Text(
                              "View All ",
                              textAlign: TextAlign.start,
                              style: GoogleFonts.cabinCondensed(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.56,
                    child: const GivenDownHistory(),
                  ),
                ],
              ),
            ),
    );
  }
}

class LockPage extends StatefulWidget {
  final DateTime lockStartTime;

  LockPage({required this.lockStartTime});

  @override
  _LockPageState createState() => _LockPageState();
}

class _LockPageState extends State<LockPage> {
  late Timer _timer;
  Duration _remainingTime = const Duration(minutes: 5);

  String? _upiID;
  int? _requestid;
  String? _name;
  String? _number;
  String? _upiQRCode;
  File? _qrCodeImage;
  File? _selectedImage;
  TextEditingController _utrController = TextEditingController();
  Map<String, dynamic>? _profileData;
  int? _userId;
  int? _requestId;
  bool _isPayButtonClicked = false;
  int? userLoginid;
  int? _fromId;
  bool _isLoading = false;
  bool isPaymentSuccessful = false;
  bool _hasWithdrawRequest = false;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _fetchP2PRequestData();
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
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
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('user')) {
          var userData = responseData['user'];
          setState(() {
            _profileData = userData;
            _userId = userData['id'];
            userLoginid = _userId;
          });
        } else {
          throw Exception('Unexpected API response');
        }
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

// Modify the _fetchP2PRequestData function
  Future<void> _fetchP2PRequestData() async {
    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.get(
        Uri.parse('https://vote.nextgex.com/api/p2p_requests'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic> &&
            responseData['name'] != null &&
            responseData['upiid'] != null &&
            responseData['member_phone'] != null) {
          setState(() {
            _hasWithdrawRequest = true;
            _requestid = responseData['id'];
            _name = responseData['name'];
            _upiQRCode = responseData['upiqrcode'];
            _upiID = responseData['upiid'];
            _requestId = responseData['id'];
            _number = responseData['member_phone'];
            _fromId = responseData['user_id'];
          });

          // Start the timer only if there is a withdraw request
          if (_hasWithdrawRequest) {
            _startLockTimer();
          }
        } else {
          setState(() {
            _hasWithdrawRequest = false;
          });
        }
      } else {
        throw Exception('Failed to fetch P2P request data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        print('Image selected: ${_selectedImage?.path}');
      });
    } else {
      print('No image selected');
    }
  }

  Future<void> submitPayment() async {
    if (_utrController.text.isEmpty || _utrController.text.length != 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid UTR number with 16 characters'),
        ),
      );
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final token = await getToken();

      if (token == null) {
        throw Exception('Token not found');
      }

      final uri = Uri.parse('https://vote.nextgex.com/api/p2p_trxs');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['trx_no'] = _utrController.text
        ..fields['from_user_id'] = userLoginid.toString()
        ..fields['to_user_id'] = _fromId.toString()
        ..fields['request_id'] = _requestId.toString()
        ..files.add(
            await http.MultipartFile.fromPath('image', _selectedImage!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        showCustomDialog(
          context,
          title: 'Payment Successful',
          content: 'Payment was successfully submitted.',
          onPressed: _handlePaymentSuccess,
        );
      } else {
        throw Exception('Failed to submit payment');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handlePaymentSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_payment_successful', true);
    await prefs.remove('lock_time');
    _unlockApp();
  }

  void _clearForm() {
    _utrController.clear();
    _selectedImage = null;
    _isPayButtonClicked = false;
    _upiID = null;
    _name = null;
    _number = null;
    _upiQRCode = null;
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

  void _startLockTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        final elapsed = DateTime.now().difference(widget.lockStartTime);
        final remaining = const Duration(minutes: 5) - elapsed;

        if (remaining <= Duration.zero) {
          timer.cancel();
          _unlockApp();
        } else {
          _remainingTime = remaining;
        }
      });
    });
  }

  Future<void> _unlockApp() async {
    String? token = await getToken();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => DashBoardView(token: token ?? 'default_token'),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _hasWithdrawRequest
          ? SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    const Text(
                      'Please Do not Refresh the page:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Remaining Time: ${_remainingTime.inMinutes}:${_remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(
                        height:
                            screenHeight * 0.01), // 10 based on screen height
                    Text(
                      "Welcome, ${_profileData?['name'] ?? 'User'}",
                      style: GoogleFonts.habibi(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      "Please Submit payment Details Before Remaining Time!",
                      style: GoogleFonts.habibi(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request Id:- ${_requestId ?? 'N/A'}',
                            style: GoogleFonts.k2d(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            'Name: ${_name ?? 'N/A'}',
                            style: GoogleFonts.k2d(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            'Number: ${_number ?? 'N/A'}',
                            style: GoogleFonts.k2d(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            'Point: 100',
                            style: GoogleFonts.k2d(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: SelectableText(
                                  'UPI Id :- ${_upiID ?? 'N/A'}',
                                  style: GoogleFonts.k2d(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                              if (_upiID != null)
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: () {
                                    Clipboard.setData(
                                        ClipboardData(text: _upiID!));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text("UPI ID copied to clipboard"),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: _upiQRCode != null
                                    ? Column(
                                        children: [

                                          Text(
                                            "QR Code",
                                            style: GoogleFonts.k2d(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          SizedBox(
                                            height: screenHeight * 0.01,
                                          ),

                                          DottedBorder(
                                            color: Colors.grey,
                                            strokeWidth: 2,
                                            dashPattern: [6, 3],
                                            borderType: BorderType.RRect,
                                            radius: const Radius.circular(12),
                                            child: Container(
                                              height: screenHeight * 0.25,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: Colors.grey.shade500,
                                              ),
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    child: Image.network(
                                                      'https://vote.nextgex.com/storage/${_upiQRCode!}',
                                                      width: double.infinity,
                                                      height:
                                                          screenHeight * 0.25,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),

                                                  // Positioned zoom icon
                                                  Positioned(
                                                    right: 10,
                                                    top: 10,
                                                    child: InkWell(
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              Dialog(
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Image.network(
                                                                  'https://vote.nextgex.com/storage/${_upiQRCode!}',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.1),
                                                        child: Container(
                                                          height: 30,
                                                          width: 30,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                            color: Colors.grey,
                                                          ),
                                                          child: const Icon(Icons
                                                              .zoom_out_map),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  Positioned(
                                                    bottom: 10,
                                                    right: 10,
                                                    child: InkWell(
                                                      onTap:_downloadQRCode,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0.1),
                                                        child: Container(
                                                          height: 30,
                                                          width: 30,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                            color: Colors
                                                                .grey.shade500,
                                                          ),
                                                          child: const Icon(Icons
                                                              .download_for_offline_outlined),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Text("UPI QR Code not available"),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Attach ScreenShot",
                                      style: GoogleFonts.k2d(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: screenHeight * 0.01,
                                    ),
                                    DottedBorder(
                                      color: Colors.grey,
                                      strokeWidth: 2,
                                      dashPattern: [6, 3],
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(8),
                                      child: InkWell(
                                        onTap: _pickImage,
                                        child: Container(
                                          height: screenHeight * 0.25,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Colors.grey.shade200,
                                          ),
                                          child: Center(
                                            child: _selectedImage != null
                                                ? Image.file(
                                                    _selectedImage!,
                                                    width: double.infinity,
                                                    height: screenHeight * 0.25,
                                                    fit: BoxFit.cover,
                                                  )
                                                : const Text(
                                                    "No image selected",
                                                    style: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // SizedBox(height: screenHeight * 0.033),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          TextField(
                            controller: _utrController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              label: Text(
                                'Enter UTR Number',
                                style: GoogleFonts.k2d(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(16),
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[ A-z,0-9]')),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Center(
                            child: InkWell(
                              onTap: submitPayment,
                              child: Container(
                                height: screenHeight * 0.06,
                                width: screenWidth * 0.4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(0xffa0cf1a),
                                ),
                                child: Center(
                                  child: Text(
                                    "Submit",
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const Center(
              child: Text(
                'There is no withdraw request',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
    );
  }

  void _showQRCodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("UPI QR Code"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _upiQRCode != null
                  ? Image.network(
                      'https://vote.nextgex.com/storage/${_upiQRCode!}',
                      width: 400,
                      height: 300,
                      fit: BoxFit.cover,
                    )
                  : const Text("UPI QR Code not available"),
            ],
          ),
          actions: <Widget>[
            InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                }, // Submit payment
                child: Container(
                  height: 30,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xffa0cf1a),
                  ),
                  child: Center(
                    child: Text(
                      "Close",
                      style: GoogleFonts.habibi(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )),
          ],
        );
      },
    );
  }

  Future<void> _downloadQRCode() async {
    try {
      if (_upiQRCode != null) {
        // Check for storage permission
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            throw Exception('Storage permission denied');
          }
        }

        final url = 'https://vote.nextgex.com/storage/${_upiQRCode!}';
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;

          Directory? directory;
          if (Platform.isAndroid) {
            directory = await getExternalStorageDirectory(); // App-specific directory
            // Create a "Download" folder if it doesn't exist
            String newPath = '';
            List<String> paths = directory!.path.split('/');
            for (int x = 1; x < paths.length; x++) {
              String folder = paths[x];
              if (folder == "Android") break;
              newPath += "/" + folder;
            }
            newPath = newPath + "/Download";
            directory = Directory(newPath);
            if (!(await directory.exists())) {
              await directory.create(recursive: true); // Create download folder
            }
          } else if (Platform.isIOS) {
            directory = await getApplicationDocumentsDirectory();
          }

          final path = '${directory!.path}/${_upiID!}.png';
          final file = File(path);
          await file.writeAsBytes(bytes);

          print('QR Code saved at: $path');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('QR Code downloaded to $path')),
          );
        } else {
          throw Exception('Failed to download QR Code');
        }
      } else {
        throw Exception('QR Code not available');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading QR Code: $e')),
      );
    }
  }
}
