import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voter_multi_app/features/givetake/givepoint/givepoint.dart';
import 'package:voter_multi_app/features/givetake/takepoint/takepoint.dart';
import 'package:http/http.dart' as http;
class GiveTakeHome extends StatefulWidget {
  const GiveTakeHome({super.key});

  @override
  State<GiveTakeHome> createState() => _GiveTakeHomeState();
}

class _GiveTakeHomeState extends State<GiveTakeHome>  with SingleTickerProviderStateMixin {

  late TabController _tabController;

  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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

        if (responseData is Map<String, dynamic> && responseData.containsKey('user')) {
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xffa0cf1a),
        title: Text(
          "My Wallet",
          style: GoogleFonts.habibi(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 30,
            color: Colors.black,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text(
              ":- ${_profileData?['wallet_amount']?.toString()}",
              style: GoogleFonts.b612(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),

        ],

        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Text(
                "Give Points",
                style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            Tab(
              child: Text(
                "Take Points",
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

      body: TabBarView(
        controller: _tabController,
          children:[
            GivePointView(),
            TakePointView(),
      ]),
    );
  }
}
