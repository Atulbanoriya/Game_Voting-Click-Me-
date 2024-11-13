import 'dart:convert';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../custom/const.dart';



class BankingDetails extends StatefulWidget {
  const BankingDetails({super.key});

  @override
  State<BankingDetails> createState() => _BankingDetailsState();
}

class _BankingDetailsState extends State<BankingDetails> {
  Map<String, dynamic>? _profileData;
  final TextEditingController _upiController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _qrCodeImage;
  String? _upiID;
  bool _isQRCodeUploaded = false;
  String? _qrCodeImageUrl;
  bool _hasUploadedBankingDetails = false;

  bool _isLoading = true;



  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _fetchBankingDetails();
    _uploadBankingDetails();
  }



  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
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
        setState(() {
          _profileData = data['user'];
          _upiID = _profileData?['upiid'];
          _qrCodeImageUrl =
          _profileData?['upiqrcode'];
          _upiController.text = _upiID ?? '';
          _isQRCodeUploaded = data['user']['isQRCodeUploaded'] ?? false;
          _isLoading = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to load profile data. Invalid format.')),
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

  Future<void> _pickQRCodeImage() async {
    // Check if the user has already uploaded banking details
    if (_hasUploadedBankingDetails) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR Code has already been uploaded.')),
      );
      return; // Exit the function if already uploaded
    }

    try {
      // Allow user to pick image from gallery
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

      // Check if user actually picked an image
      if (pickedFile != null) {
        setState(() {
          _qrCodeImage = File(pickedFile.path); // Save the picked file
        });
      } else {
        // User canceled the image picking
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected.')),
        );
      }
    } catch (e) {
      // Handle any errors during the image picking process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick QR Code image: $e')),
      );
    }
  }

  Future<void> _updateBankingDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _uploadBankingDetails();
      _showCustomSnackBar(context, 'Success Upload Bank Details');
    }
  }

  bool _isUploading = false;

  Future<void> _uploadBankingDetails() async {

    if (_isUploading) return;

    setState(() {
      _isUploading = true;
    });

    final token = await getToken();

    if (token == null) {
      setState(() {
        _isUploading = false;
      });
      throw Exception('Token not found');
    }

    // Check if UPI ID is provided
    if (_upiController.text.isEmpty) {
      // _showCustomSnackBar(context, 'UPI ID is required.');
      setState(() {
        _isUploading = false;
      });
      return;
    }

    final url = Uri.parse('https://vote.nextgex.com/api/bank_detail_upload');

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['upiId'] = _upiController.text;

      if (_qrCodeImage != null) {
        request.files.add(await http.MultipartFile.fromPath('qrcode', _qrCodeImage!.path));
      } else {
        print('No QR code image found');
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: $responseBody');

      if (response.statusCode == 200) {
        print('Banking details uploaded successfully.');


        await _fetchBankingDetails();

        setState(() {
          _hasUploadedBankingDetails = true;
        });

        _showCustomSnackBar(context, 'Success! Bank details uploaded.');

        await _fetchProfileData();
      } else {
        print('Failed to upload banking details with status code: ${response.statusCode}');
        print('Error Response: $responseBody');
        _showCustomSnackBar(context, 'Failed to upload banking details.');
      }
    } catch (e) {
      print('Error uploading banking details: $e');
      _showCustomSnackBar(context, 'Failed to upload banking details.');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }





  Future<void> _fetchBankingDetails() async {
    if (_hasUploadedBankingDetails) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Banking details have already been uploaded.')),
      );
      return;
    }

    final url = Uri.parse('https://vote.nextgex.com/api/bank_detail_upload');
    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('Token not found');
      }


      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
        try {
          final data = json.decode(response.body);
          print('Decoded JSON data: $data');
          final bankDetails = FetchBankDetails.fromJson(data);
          setState(() {
            _upiID = bankDetails.upiId;
            _qrCodeImageUrl = bankDetails.qrcodeUrl;
            _upiController.text = _upiID ?? '';
            _isQRCodeUploaded = _qrCodeImageUrl != null;
          });
        } catch (e) {
          print('Error parsing banking details JSON: $e');
          _showCustomSnackBar(context, 'Failed to load banking details. Invalid format.');
        }
      } else {
        print('Failed to load banking details with status code: ${response
            .statusCode}');
        print('Response body: ${response.body}');

        _showCustomSnackBar(context, 'Failed to load banking detail.');

      }
    } catch (e) {
      print('Error fetching banking details: $e');

      _showCustomSnackBar(context, 'Failed to Fetch banking detail.');
    }
  }


  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
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
    bool isUpiLoggedIn = _upiID != null && _upiID!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_profileData != null) ...[
                Text(
                  "Name: ${_profileData!['name']}",
                  style: GoogleFonts.k2d(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Phone No: ${_profileData!['member_phone']}",
                  style: GoogleFonts.k2d(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                if (isUpiLoggedIn) ...[
                  Text(
                    "UPI ID: $_upiID",
                    style: GoogleFonts.k2d(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),


                  Container(
                    width: 150,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        if (_qrCodeImageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              "${ConstRes.imageUrl}$_qrCodeImageUrl",
                              width: 150,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          const Center(child: Text('No QR code available')),

                        Positioned(
                          right: 10,
                          top: 10,
                          child: InkWell(
                            onTap: () {
                              if (_qrCodeImageUrl != null) {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.network(
                                          "${ConstRes.imageUrl}$_qrCodeImageUrl",
                                          fit: BoxFit.cover,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(0.1),
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration:  BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.grey
                                ),
                                  child: const Icon(Icons.zoom_out_map),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                ] else ...[
                  TextFormField(
                    controller: _upiController,
                    decoration: InputDecoration(
                      labelText: 'Enter your UPI ID / VPA ID',
                      prefixIcon: const Icon(CupertinoIcons.upload_circle),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your UPI ID';
                      }
                      final upiPattern = r'^[\w.\-_]+@[\w.\-]+$';
                      if (!RegExp(upiPattern).hasMatch(value)) {
                        return 'Please enter a valid UPI ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),





                  Text(
                      "Attach QR Code",
                    style: GoogleFonts.k2d(
                      fontWeight: FontWeight.bold
                    ),
                  ),

                  const SizedBox(height: 8),

                  InkWell(
                    onTap: _pickQRCodeImage,
                    child: DottedBorder(
                      color: Colors.grey,
                      strokeWidth: 2,
                      dashPattern: [6, 3],
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(12),
                      child: Container(
                        width: 150,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xff1D976C), // Dark Teal
                              Color(0xff93F9B9), // Lighter Teal
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          children: [
                            if (_qrCodeImage != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _qrCodeImage!,
                                  width: 150,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                               Center(
                                child: Text(
                                  "No image selected",
                                  style: GoogleFonts.k2d(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: InkWell(
                                onTap: () {
                                  if (_qrCodeImage != null) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.file(
                                              _qrCodeImage!,
                                              fit: BoxFit.cover,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(0.1),
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.grey,
                                    ),
                                    child: const Icon(Icons.zoom_out_map),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),


                  const SizedBox(
                    width: 8,
                  ),



                  const SizedBox(height: 16),
                ],
              ],


              if (!_hasUploadedBankingDetails && !isUpiLoggedIn)
                InkWell(
                  onTap: () async {
                    await _uploadBankingDetails();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xffa0cf1a),
                    ),
                    child: Center(
                      child: Text(
                        "Save Banking Details",
                        style: GoogleFonts.chakraPetch(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
    );
  }

}



class FetchBankDetails {
  String? upiId;
  String? qrcodeUrl;

  FetchBankDetails({this.upiId, this.qrcodeUrl});

  FetchBankDetails.fromJson(Map<String, dynamic> json) {
    upiId = json['upiid'];
    qrcodeUrl = json['upiqrcode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['upiid'] = this.upiId;
    data['upiqrcode'] = this.qrcodeUrl;
    return data;
  }
}