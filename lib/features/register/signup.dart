import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../login/login_view.dart';



class SignView extends StatefulWidget {
  const SignView({super.key});

  @override
  State<SignView> createState() => _SignViewState();
}

class _SignViewState extends State<SignView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _sponsorIdController = TextEditingController();

  bool _adultCheck = false;
  bool _acceptedTerms = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Future<void> _signup() async {
  //   if (_formKey.currentState!.validate()) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //
  //     try {
  //       final ipResponse = await http.get(Uri.parse('https://api.ipify.org?format=json'));
  //       String ipAddress = jsonDecode(ipResponse.body)['ip'];
  //
  //       DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //       String? macAddress;
  //       if (Platform.isAndroid) {
  //         AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //         macAddress = androidInfo.model;
  //       } else if (Platform.isIOS) {
  //         IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  //         macAddress = iosInfo.identifierForVendor;
  //       }
  //
  //       // Preparing the request data
  //       Map<String, String> requestBody = {
  //         'name': _nameController.text,
  //         'member_phone': _whatsappController.text,
  //         'email': _emailController.text,
  //         'password': _passwordController.text,
  //         'password_confirmation': _confirmPasswordController.text,
  //         if (_sponsorIdController.text.isNotEmpty) 'sponsor_id': _sponsorIdController.text,
  //         'ip': ipAddress,
  //         'mac_id': macAddress ?? '',
  //       };
  //
  //       Map<String, String> requestHeaders = {
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       };
  //
  //       // Print the request headers and body
  //       print('Request Headers: $requestHeaders');
  //       print('Request Body: ${jsonEncode(requestBody)}');
  //
  //       final response = await http.post(
  //         Uri.parse('https://vote.nextgex.com/api/signup'),
  //         headers: requestHeaders,
  //         body: jsonEncode(requestBody),
  //       );
  //
  //       setState(() {
  //         _isLoading = false;
  //       });
  //
  //       if (response.statusCode == 200 || response.statusCode == 201) {
  //         final Map<String, dynamic> data = json.decode(response.body);
  //         if (data['user'] != null) {
  //           print('Signup successful: ${data['user']}');
  //           _clearForm();
  //           _showSuccessDialog();
  //         } else {
  //           print('Signup error: ${data['message']}');
  //           _showErrorDialog(data['message']);
  //         }
  //       } else {
  //         final Map<String, dynamic> data = json.decode(response.body);
  //         String errorMessage = _parseErrorMessages(data);
  //
  //         print('Signup failed with status: ${response.statusCode}');
  //         print('Response body: ${response.body}');
  //         _showErrorDialog(errorMessage);
  //       }
  //     } catch (e) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       print('Signup error: $e');
  //       _showErrorDialog('An error occurred. Please try again.');
  //     }
  //   }
  // }








  //-------------------Sign_UP Function For only Testing --------------------//
  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get the IP address
        final ipResponse = await http.get(Uri.parse('https://api.ipify.org?format=json'));
        String ipAddress = jsonDecode(ipResponse.body)['ip'];


        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();




        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;


        String serialNumber = androidInfo.serialNumber;
        String fingerprint = androidInfo.fingerprint;
        String device = androidInfo.device;


        String uniqueDeviceId = sha256.convert(utf8.encode('$serialNumber$fingerprint$device')).toString();

        print('Unique Device ID: $uniqueDeviceId');


        // Preparing the request data
        Map<String, String> requestBody = {
          'name': _nameController.text,
          'member_phone': _whatsappController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'password_confirmation': _confirmPasswordController.text,
          if (_sponsorIdController.text.isNotEmpty) 'sponsor_id': _sponsorIdController.text,
          'ip': ipAddress,
          'mac_id': uniqueDeviceId,
          // 'device_uuid': deviceUuid, // Custom UUID
        };

        Map<String, String> requestHeaders = {
          'Content-Type': 'application/json; charset=UTF-8',
        };

        // Print the request headers and body
        print('Request Headers: $requestHeaders');
        print('Request Body: ${jsonEncode(requestBody)}');

        final response = await http.post(
          Uri.parse('https://vote.nextgex.com/api/signup'),
          headers: requestHeaders,
          body: jsonEncode(requestBody),
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data['user'] != null) {
            print('Signup successful: ${data['user']}');
            _clearForm();
            _showSuccessDialog();
          } else {
            print('Signup error: ${data['message']}');
            _showErrorDialog(data['message']);
          }
        } else {
          final Map<String, dynamic> data = json.decode(response.body);
          String errorMessage = _parseErrorMessages(data);

          print('Signup failed with status: ${response.statusCode}');
          print('Response body: ${response.body}');
          _showErrorDialog(errorMessage);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print('Signup error: $e');
        _showErrorDialog('An error occurred. Please try again.');
      }
    }
  }

// Function to get or create UUID
  Future<void> getUniqueDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    // Accessing the serialNumber, fingerprint, and device properties
    String serialNumber = androidInfo.serialNumber;
    String fingerprint = androidInfo.fingerprint;
    String device = androidInfo.device;

    // Combine the values and generate a hash for a unique device ID
    String uniqueDeviceId = sha256.convert(utf8.encode('$serialNumber$fingerprint$device')).toString();

    print('Unique Device ID: $uniqueDeviceId');
  }



  String _parseErrorMessages(Map<String, dynamic> data) {
    if (data.containsKey('errors')) {
      final errors = data['errors'] as Map<String, dynamic>;
      List<String> errorMessages = [];

      errors.forEach((key, value) {
        if (value is List) {
          value.forEach((error) {
            errorMessages.add(_mapErrorKeyToMessage(key, error));
          });
        } else {
          errorMessages.add(_mapErrorKeyToMessage(key, value.toString()));
        }
      });

      return errorMessages.join('\n');
    }

    return 'Device All Ready Exist!.';
  }

  String _mapErrorKeyToMessage(String key, String message) {
    switch (key) {
      case 'member_phone':
        return 'Phone number: $message';
      case 'email':
        return 'Email: $message';
      case 'password':
        return 'Password: $message';
    // Add more cases for other keys as needed
      default:
        return '$key: $message';
    }
  }


  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _whatsappController.clear();
    _sponsorIdController.clear();
    setState(() {
      _adultCheck = false;
      _acceptedTerms = false;
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Sign-Up Successful',
            style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Your account has been created successfully. \nPlease verify your email.',
            style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginView()),
                );
              },
              child: Container(
                height: 50,
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign-Up Failed'),
        content: Text(message),
        actions: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 50,
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
          "Sign-Up",
          style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Create An Account !!!",
                        style: GoogleFonts.habibi(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            label: Text(
                              "Name ",
                              style: GoogleFonts.habibi(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14
                              ),
                            ),
                            prefixIcon: const Icon(CupertinoIcons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            label: Text(
                              "Email Id",
                              style: GoogleFonts.habibi(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14
                              ),
                            ),
                            prefixIcon: const Icon(CupertinoIcons.mail),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _whatsappController,
                          decoration: InputDecoration(
                            label: Text(
                              "Enter WhatsApp No.",
                              style: GoogleFonts.habibi(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14
                              ),
                            ),
                            prefixIcon: const Icon(CupertinoIcons.phone_circle),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your WhatsApp number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            label: Text(
                              "Password Must be 8 Characters",
                              style: GoogleFonts.habibi(
                                  fontWeight: FontWeight.bold,
                                fontSize: 14
                              ),
                            ),
                            prefixIcon: const Icon(CupertinoIcons.lock_circle),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? CupertinoIcons.eye
                                    : CupertinoIcons.eye_slash,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password Abc@1234 like this ';
                            }
                            if (value.length < 8) {
                              return 'Password must be at 8 characters long &  Abc@1234 like this ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          decoration: InputDecoration(
                            label: Text(
                              "Confirm Password ",
                              style: GoogleFonts.habibi(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14
                              ),
                            ),
                            prefixIcon: const Icon(CupertinoIcons.lock_circle_fill),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? CupertinoIcons.eye
                                    : CupertinoIcons.eye_slash,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _sponsorIdController,
                          decoration: InputDecoration(
                            label: Text(
                              "Referral code (Optional)",
                              style: GoogleFonts.habibi(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14
                              ),
                            ),
                            prefixIcon: const Icon(CupertinoIcons.person_2_square_stack),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        CheckboxListTile(
                          title: Text(
                            "Are you above 18 years of age? If yes, please click here.",
                            style: GoogleFonts.habibi(
                                fontWeight: FontWeight.bold,
                              fontSize: 12
                            ),
                          ),
                          value: _adultCheck,
                          onChanged: (newValue) {
                            setState(() {
                              _adultCheck = newValue ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        CheckboxListTile(
                          title: Text(
                            "I have read and accepted terms and conditions",
                            style: GoogleFonts.habibi(
                                fontWeight: FontWeight.bold,
                              fontSize: 12
                            ),
                          ),
                          value: _acceptedTerms,
                          onChanged: (newValue) {
                            setState(() {
                              _acceptedTerms = newValue ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _signup,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xffa0cf1a),
                            ),
                            child: Center(
                              child: Text(
                                "Sign Up",
                                style: GoogleFonts.habibi(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xffa0cf1a)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
