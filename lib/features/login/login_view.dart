import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voter_multi_app/custom/loading_view.dart';
import 'dart:convert';
import '../dashboard/dashboard.dart';
import '../register/signup.dart';
import 'bottom_sheet_view/bottom_sheet_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final ipResponse = await http.get(Uri.parse('https://api.ipify.org?format=json'));
    String ipAddress = jsonDecode(ipResponse.body)['ip'];

    final url = Uri.parse('https://vote.nextgex.com/api/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _emailController.text,
        'password': _passwordController.text,
        'ip': ipAddress,
      }),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final responseBody = response.body;

        final String token;
        if (responseBody.contains('|')) {
          token = responseBody.split('|').last;
        } else {
          final responseData = json.decode(responseBody);
          if (responseData is Map<String, dynamic> && responseData.containsKey('token')) {
            token = responseData['token'];
          } else {
            throw Exception('Invalid response format');
          }
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        final profileUrl = Uri.parse('https://vote.nextgex.com/api/user');
        final profileResponse = await http.get(
          profileUrl,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (profileResponse.statusCode == 200) {
          final profileData = json.decode(profileResponse.body);
          await prefs.setString('userData', json.encode(profileData));

          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => DashBoardView(token: token)),
          // );

          showCustomDialog(
            context,
            title: 'Success',
            content: 'Login Successfull',
            onPressed: (){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashBoardView(token: token)),
              );
            }
          );



        } else {
          throw Exception('Failed to load user profile');
        }
      } catch (e) {
        print(e);
      }
    } else {
      String errorMessage = 'OOPS! Your mail or Password is wrong. Please try again.';

      try {
        final errorData = json.decode(response.body);
        if (errorData is Map<String, dynamic> && errorData.containsKey('error')) {
          errorMessage = errorData['error'];
        }
      } catch (e) {
        print('Error parsing error response: $e');
      }

      showCustomDialog(
        context,
        title: 'Login Failed',
        content: errorMessage,
      );
    }
  }

  void showCustomDialog(BuildContext context, {required String title, required String content, VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
          ),
          content: Text(
            content,
            style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            InkWell(
              onTap: (){
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
      appBar: AppBar(
        backgroundColor: const Color(0xffa0cf1a),
        title: Text(
          "Login",
          style: GoogleFonts.habibi(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // The form view, hidden when _isLoading is true
          Visibility(
            visible: !_isLoading,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Image.asset(
                      "asset/images/logvi.jpg",
                      height: 200,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Welcome Back to Your Account !!!",
                          style: GoogleFonts.habibi(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: GoogleFonts.habibi(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: GoogleFonts.habibi(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
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
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 8),

                       Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                backgroundColor: Colors.white,
                                context: context,
                                builder: (context) => const BottomSheetWidget(),
                              );
                            },
                            child: Text(
                              "Forget Password",
                              style: GoogleFonts.k2d(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),


                          const SizedBox(height: 15),

                          InkWell(
                            onTap: _login,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xffa0cf1a),
                              ),
                              child: Center(
                                child: Text(
                                  "Login",
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an Account?",
                                style: GoogleFonts.habibi(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 5),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const SignView()),
                                  );
                                },
                                child: Text(
                                  "Sign-Up",
                                  style: GoogleFonts.habibi(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),


          if (_isLoading)
            const Center(
              child: CustomLoader(),
            ),
        ],
      ),
    );
  }
}
