import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import '../../../custom/const.dart';

class ProfileViewTab extends StatefulWidget {
  const ProfileViewTab({super.key});

  @override
  State<ProfileViewTab> createState() => _ProfileViewTabState();
}

class _ProfileViewTabState extends State<ProfileViewTab> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  String? _profileImagePath;
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchProfileData() async {
    final token = await getToken();

    if (token == null) {
      throw Exception('Token not found');
    }

    final url = Uri.parse('https://vote.nextgex.com/api/user');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          _profileData = data['user'];
          _nameController.text = _profileData?['name'] ?? '';
          _phoneController.text = _profileData?['member_phone'] ?? '';
          _cityController.text = prefs.getString('city') ?? _profileData?['city_name'] ?? '';
          _pinController.text = prefs.getString('pin_code') ?? _profileData?['pin_code'] ?? '';
          _isLoading = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile data. Invalid format.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile data')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> updateCityPinCodeAndProfileImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Token not found');
      }

      final uri = Uri.parse('https://vote.nextgex.com/api/userUpdate');
      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['city'] = _cityController.text
        ..fields['pincode'] = _pinController.text;

      if (_profileImagePath != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image',
          _profileImagePath!,
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('city', _cityController.text);
        await prefs.setString('pin_code', _pinController.text);
        
        _showCustomSnackBar(context, "Profile updated successfully");

      } else {

        _showCustomSnackBar(context, "Failed to update profile: ${responseData['error']}");
        throw Exception('Failed to update profile');
      }
    } catch (e) {

      _showCustomSnackBar(context, '${e.toString()}');

    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImagePath = pickedFile.path;
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




  void showCustomDialog(BuildContext context, {required String title, required String content, VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              title,
            style: const TextStyle(
              fontSize: 18
            ),
          ),
          content: Text(content),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xffa0cf1a),
                          width: 4,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 1.2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _profileImagePath != null
                              ? FileImage(File(_profileImagePath!))
                              : (_profileData?['profile_image'] != null && _profileData!['profile_image'].isNotEmpty
                              ? NetworkImage('${ConstRes.imageUrl}${_profileData?['profile_image']}')
                              : const AssetImage('asset/images/placeholder.png')) as ImageProvider,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 70.0, left: 48),
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.black,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 25,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16.0 , right: 16),
              child: TextFormField(
                readOnly: true,
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16.0 , right: 16),
              child: TextFormField(
                readOnly: true,
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(CupertinoIcons.phone_circle),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(10),
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')), // This allows only alphanumeric characters
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16.0 , right: 16),
              child: TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  prefixIcon: const Icon(Icons.cabin),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16.0 , right: 16),
              child: TextFormField(
                controller: _pinController,
                decoration: InputDecoration(
                  labelText: 'Pin Code',
                  prefixIcon: const Icon(CupertinoIcons.map_pin_ellipse),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(6),
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')), // This allows only alphanumeric characters
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your pin code';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16.0 , right: 16),
              child: _buildTextField(
                label: "Email",
                value: _profileData?['email'],
                icon: CupertinoIcons.mail,
                readOnly: true,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16.0 , right: 16),
              child: _buildTextField(
                label: "Date Joined",
                value: _profileData?['date_join'],
                icon: Icons.location_history,
                readOnly: true,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: updateCityPinCodeAndProfileImage,
                  child: Container(
                    height: 50,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xffa0cf1a),
                    ),
                    child: Center(
                      child: Text(
                        'Update',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required IconData icon,
    bool readOnly = false,
  }) {
    return TextFormField(
      readOnly: readOnly,
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
