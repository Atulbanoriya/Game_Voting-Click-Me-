import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/p2p_trxs_id_model/p2p_trxs_id.dart';

class ReGivePayment extends StatefulWidget {
  final String requestId;

  const ReGivePayment({super.key, required this.requestId});

  @override
  State<ReGivePayment> createState() => _ReGivePaymentState();
}

class _ReGivePaymentState extends State<ReGivePayment> {
  Request? _request;
  File? _selectedImage;
  final TextEditingController _utrController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchP2PRequestData();
  }

  Future<void> _fetchP2PRequestData() async {
    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.get(
        Uri.parse('https://vote.nextgex.com/api/p2p_trxs/${widget.requestId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        print('P2P Request Response: $responseData');

        if (responseData is Map<String, dynamic>) {
          setState(() {
            _request = PepTrxsId.fromJson(responseData).request;
          });
        } else {
          throw Exception('P2P request response is not a Map');
        }
      } else {
        throw Exception('Failed to load P2P request data');
      }
    } catch (e) {
      print('Error fetching P2P request data: $e');
    }
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> submitPayment() async {
    if (_utrController.text.isEmpty || _utrController.text.length != 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid UTR number with 16 characters')),
      );
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload an image')),
      );
      return;
    }

    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('Token not found');
      }

      final uri = Uri.parse('https://vote.nextgex.com/api/p2p_trxs');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['remark'] = '${_request?.remark}'
        ..fields['trx_no'] = _utrController.text
        ..fields['from_user_id'] = '${_request?.fromUserId}'
        ..fields['to_user_id'] = '${_request?.toUserId}'
        ..fields['request_id'] = widget.requestId
        ..files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        showCustomDialog(
          context,
          title: 'Payment Successful',
          content: 'Payment has been successfully submitted',
        );
        Get.back();

      } else {
        throw Exception('Failed to submit payment: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        print('Image selected: ${_selectedImage?.path}');
      });
    } else {
      print('No image selected');
    }
  }

  void showCustomDialog(BuildContext context, {required String title, required String content, VoidCallback? onPressed}) {
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
      appBar: AppBar(
        backgroundColor: Color(0xffa0cf1a),
        title: Text(
          'Re Give Point',
          style: GoogleFonts.habibi(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_request != null) ...[
                Text(
                  'Request ID: ${_request!.requestId}',  // Assuming 'description' is the name field
                  style: GoogleFonts.cabin(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Name: ${_request!.name}',  // Assuming 'description' is the name field
                  style: GoogleFonts.habibi(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Phone No: ${_request!.memberPhone}',  // Assuming 'toUserId' is the phone number field
                  style: GoogleFonts.cabin(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'UPI ID: ${_request!.upiid}',  // Assuming 'trxNo' is the UPI ID field
                  style: GoogleFonts.cabin(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Remark of Rejection : ${_request!.remark}',  // Assuming 'trxNo' is the UPI ID field
                  style: GoogleFonts.habibi(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      'QR Code Image:',
                      style: GoogleFonts.cabin(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _request!.image != null
                        ? Image.network(
                      'https://vote.nextgex.com/storage/${_request!.upiqrcode!}',
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    )
                        : const Text('Loading...'),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              TextFormField(
                controller: _utrController,
                decoration: InputDecoration(
                  label: Text(
                    "Enter UTR No.",
                    style: GoogleFonts.habibi(fontWeight: FontWeight.bold),
                  ),
                  prefixIcon: const Icon(Icons.transfer_within_a_station),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(16),
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your UTR number';
                  }
                  if (value.length != 16) {
                    return 'Please enter a valid UTR number with 16 characters';
                  }
                  return null;
                },
              ),


              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Attach Screenshot:",
                      style: GoogleFonts.cabin(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color(0xffa0cf1a),
                      ),
                      child: Center(
                        child: InkWell(
                          onTap: _pickImage,
                          child: Text(
                            "Upload",
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
              const SizedBox(height: 10),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(
                    _selectedImage!,
                    height: 100,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),


              const SizedBox(height: 20),
              Center(
                child: InkWell(
                  onTap: submitPayment,
                  child: Container(
                    height: 50,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xffa0cf1a),
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: GoogleFonts.habibi(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
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
      ),
    );
  }
}
