import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ConstRes {
  static const String imageUrl = "https://vote.nextgex.com/storage/"; // Replace with your actual image URL
}

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _profileImagePath;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  void _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImagePath = pickedFile.path;
      });
    }
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

        if (responseData is Map<String, dynamic> && responseData.containsKey('user')) {
          var userData = responseData['user'];
          if (userData.containsKey('wallet_amount') && userData.containsKey('id')) {
            setState(() {
              _profileData = userData;
              _nameController.text = userData['name'] ?? '';
              _phoneController.text = userData['member_phone'] ?? '';
            });
          } else {
            print('User data does not contain wallet_amount or id key');
            throw Exception('User data does not contain wallet_amount or id key');
          }
        } else {
          print('API Response does not contain user key or is not a Map');
          throw Exception('API Response does not contain user key or is not a Map');
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

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      final uri = Uri.parse('https://vote.nextgex.com/api/userUpdate');
      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token';

      request.fields['name'] = _nameController.text;
      request.fields['member_phone'] = _phoneController.text;

      if (_profileImagePath != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image',
          _profileImagePath!,
        ));
      }

      final response = await request.send();

      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);
      print('Update Response Status: ${response.statusCode}');
      print('Update Response Body: $responseBody');

      if (response.statusCode == 200) {
        print('Update Response Data: $responseData');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
        // Navigate to DashBoardView
        Navigator.pushReplacementNamed(context, '/profile');
      } else {
        throw Exception('Failed to update profile');
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
      appBar: AppBar(
        backgroundColor: Color(0xffa0cf1a),
        title: Text(
          'Update Profile',
          style: GoogleFonts.habibi(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              children: [
                Row(
                  children: [
                    _profileImagePath == null
                        ? CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.person, size: 40),
                    )
                        : CircleAvatar(
                      radius: 40,
                      backgroundImage: FileImage(File(_profileImagePath!)),
                    ),
                    SizedBox(width: 15),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 30,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xffa0cf1a),
                        ),
                        child: Center(
                          child: Text(
                            "Select Profile Image",
                            style: GoogleFonts.habibi(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    label: Text(
                      _profileData?['name'] ?? 'Name',
                      style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
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
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    label: Text(
                      _profileData?['member_phone'] ?? 'Enter WhatsApp No.',
                      style: GoogleFonts.b612(fontWeight: FontWeight.bold),
                    ),
                    prefixIcon: const Icon(CupertinoIcons.phone_circle),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                GestureDetector(
                  onTap: updateProfile,
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xffa0cf1a),
                    ),
                    child: Center(
                      child: Text(
                        "Update Profile",
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
        ),
      ),
    );
  }
}
