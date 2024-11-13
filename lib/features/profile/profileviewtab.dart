import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voter_multi_app/features/profile/bankingdetails/bankingdetails.dart';
import 'profileviewtab/profileview.dart';




class ConstRes {
  static const String imageUrl = "https://vote.nextgex.com/storage/";
}

class ProfileView extends StatefulWidget {

  const ProfileView({super.key,});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin {

  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  late TabController _tabController;



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchProfileData();
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

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffa0cf1a),
        title: Text(
          "Profile",
          style: GoogleFonts.habibi(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 2.5,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: _profileData?['profile_image'] != null && _profileData!['profile_image'].isNotEmpty
                        ? NetworkImage('${ConstRes.imageUrl}${_profileData?['profile_image']}') as ImageProvider
                        : const AssetImage('asset/images/placeholder.png') as ImageProvider,
                  ),
                ),
              ),
            ),
          )
        ],

        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Text(
                "Profile",
                style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            Tab(
              child: Text(
                "Banking Details",
                style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: const [
          ProfileViewTab(),
          BankingDetails(),
        ],
      ),
    );
  }
}

//   Widget _buildBankingDetailsView() {
//     // Check if UPI ID and QR code image are present
//     bool isUpiLoggedIn = _upiID != null;
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Name: ${_profileData?['name']}",
//                 style: GoogleFonts.habibi(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                   color: Colors.black,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 "Phone No: ${_profileData?['member_phone']}",
//                 style: GoogleFonts.fahkwang(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                   color: Colors.black,
//                 ),
//               ),
//               SizedBox(height: 8),
//               if (isUpiLoggedIn) ...[
//                 Text(
//                   "UPI ID: ${_upiID ?? 'N/A'}",
//                   style: GoogleFonts.fahkwang(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                     color: Colors.black,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Container(
//                   width: 200,
//                   height: 200,
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: Colors.grey,
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: _qrCodeImageUrl != null
//                       ? Image.network(
//                       "${ConstRes.imageUrl}${_qrCodeImageUrl}",
//                     fit: BoxFit.cover,
//                   )
//                       : Center(child: Text('No QR code available')),
//                 ),
//               ] else ...[
//                 TextFormField(
//                   controller: _upiController,
//                   decoration: InputDecoration(
//                     labelText: 'Enter your UPI ID',
//                     prefixIcon: Icon(CupertinoIcons.money_dollar_circle),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your UPI ID';
//                     }
//                     final upiPattern = r'^[\w.\-_]+@[\w.\-]+$';
//                     if (!RegExp(upiPattern).hasMatch(value)) {
//                       return 'Please enter a valid UPI ID';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 InkWell(
//                   onTap: _pickQRCodeImage,
//                   child: Container(
//                     height: 50,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       color: const Color(0xffa0cf1a),
//                     ),
//                     child: Center(
//                       child: Text(
//                         "Upload QR Code",
//                         style: GoogleFonts.habibi(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//               ],
//               if (_qrCodeImage != null || _qrCodeImageUrl != null)
//                 Column(
//                   children: [
//                     const Text(
//                       'QR Code Image:',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     _qrCodeImage != null
//                         ? Image.file(
//                       _qrCodeImage!,
//                       height: 200,
//                       width: 200,
//                     )
//                         : Image.network(
//                       _qrCodeImageUrl!,
//                       height: 200,
//                       width: 200,
//                       fit: BoxFit.cover,
//                     ),
//                   ],
//                 ),
//               const SizedBox(height: 16),
//               if (!_hasUploadedBankingDetails && !isUpiLoggedIn)
//                 InkWell(
//                   onTap: _updateBankingDetails,
//                   child: Container(
//                     height: 50,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       color: const Color(0xffa0cf1a),
//                     ),
//                     child: Center(
//                       child: Text(
//                         "Save Banking Details",
//                         style: GoogleFonts.habibi(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




// class FetchBankDetails {
//   String? upiId;
//   String? qrcodeUrl;
//
//   FetchBankDetails({this.upiId, this.qrcodeUrl});
//
//   FetchBankDetails.fromJson(Map<String, dynamic> json) {
//     upiId = json['upiid'];
//     qrcodeUrl = json['upiqrcode'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['upiid'] = this.upiId;
//     data['upiqrcode'] = this.qrcodeUrl;
//     return data;
//   }
// }
