import 'dart:convert';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voter_multi_app/features/candapplyreport/candidateapplyreport.dart';
import 'package:voter_multi_app/features/cityelect/cityelection.dart';
import 'package:voter_multi_app/features/dashboard/applyview.dart';
import 'package:voter_multi_app/features/disclaimer/disclaimer.dart';
import 'package:voter_multi_app/features/givetake/givetake.dart';
import 'package:voter_multi_app/features/referral/referral_history.dart';
import 'package:voter_multi_app/features/statelect/statelection.dart';
import 'package:voter_multi_app/features/support/supportview.dart';
import 'package:voter_multi_app/features/transactionhistory/transactionhistory.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import '../allmyvote/allmyvote.dart';
import '../community_chat/chat_view/community_chat_view.dart';
import '../electionhistory/electionhistory.dart';
import '../notification_view/notification_view.dart';
import '../privacy_policy/privacy_policy.dart';
import '../terms_condidation/terms_condidation.dart';
import '../wallethistory/wallethistory.dart';
import 'package:voter_multi_app/custom/const.dart';

class HomeView extends StatefulWidget {
  final NotchBottomBarController? controller;

  const HomeView({super.key, this.controller});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _profileData;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _fetchProfileData();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _showNoInternetDialog();
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('Please check your internet connection and try again.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
              _userId = userData['id'];
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
        print('Failed to load profile data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffa0cf1a),
        title: Text(
          "Home",
          style: GoogleFonts.habibi(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Text(
                "City Elections",
                style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            Tab(
              child: Text(
                "State Elections",
                style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),

        actions: [

          Row(
            children: [
              IconButton(
                icon: const Icon(
                  CupertinoIcons.bell_fill,
                  size: 35,
                  color: Colors.black,
                ),
                onPressed: () {
                  // Navigate to NotificationView
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationView(),
                    ),
                  );
                },
              ),



              const SizedBox(width: 10),

              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    showMenu(
                      color: Colors.white,
                      context: context,
                      position: const RelativeRect.fromLTRB(100, 100, 0, 0), // Adjust position as per your UI needs
                      items: [
                        PopupMenuItem(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: _profileData?['profile_image'] != null && _profileData!['profile_image'].isNotEmpty
                                        ? NetworkImage('${ConstRes.imageUrl}${_profileData?['profile_image']}')
                                        : const AssetImage('asset/images/placeholder.png'),
                                  ),
                                  const SizedBox(width: 8),
                                   Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (_profileData?['name'] != null && _profileData!['name'].length > 8)
                                            ? _profileData!['name'].substring(0, 8)
                                            : _profileData?['name'] ?? '',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text("Points:- ${_profileData?['wallet_amount']}"),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.person),
                                title: const Text("My Profile"),
                                onTap: () {
                                  Navigator.pushNamed(context, '/profile');
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.logout),
                                title: const Text("Logout"),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Confirm Logout"),
                                        content: const Text("Are you sure you want to logout?"),
                                        actions: [
                                          TextButton(
                                            child: const Text("No"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: const Text("Yes"),
                                            onPressed: () async {
                                              final prefs = await SharedPreferences.getInstance();
                                              await prefs.clear(); // Clear all stored data
                                              Navigator.of(context).pushNamedAndRemoveUntil(
                                                  '/login', (Route<dynamic> route) => false);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
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
                          width: 2,
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
                              ? NetworkImage('${ConstRes.imageUrl}${_profileData?['profile_image']}')
                              : const AssetImage('asset/images/placeholder.png'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            ],
          )

        ],
      ),


      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xffa0cf1a),
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.black,
                  backgroundImage: AssetImage(
                    "asset/images/blacklogo.png",
                  ),
                ),
              ),
            ),


            ListTile(
              leading: const Icon(Icons.home),
              title: Text(
                'Home',
                style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),


            ExpansionTile(
              leading: const Icon(Icons.money),
              title: Text(
                'My Wallet',
                style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.account_balance_outlined),
                  title: Text(
                    'Wallet',
                    style: GoogleFonts.habibi(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const GiveTakeHome()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.money),
                  title: Text(
                    'Wallet History',
                    style: GoogleFonts.habibi(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const WalletHistoryTab()));
                  },
                ),
                ListTile(
                  leading: const Icon(CupertinoIcons.arrow_2_circlepath),
                  title: Text(
                    'Transactions History',
                    style: GoogleFonts.habibi(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const TransactionHistory()));
                  },
                ),
              ],
            ),


            ExpansionTile(
              leading: const Icon(CupertinoIcons.doc_append),
              title: Text(
                'Apply ',
                style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.assignment),
                  title: Text(
                    'Apply For Candidate',
                    style: GoogleFonts.habibi(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ApplyCandidatePage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.assessment_outlined),
                  title: Text(
                    'Candidate Apply History',
                    style: GoogleFonts.habibi(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CandidateApplyReport()));
                  },
                ),
              ],
            ),


            ListTile(
              leading: const Icon(Icons.how_to_vote),
              title: Text(
                'My Votes History',
                style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AllMyVoteHistory()));
              },
            ),


            ListTile(
              leading: const Icon(CupertinoIcons.arrow_up_arrow_down),
              title: Text(
                'Elections History',
                style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ElectionHistory()));
              },
            ),


            ListTile(
              leading: const Icon(Icons.people_outlined),
              title: Text(
                'Community Chat',
                style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CommunityChatView()));
              },
            ),


            ExpansionTile(
              leading: const Icon(CupertinoIcons.rectangle_paperclip),
              title: Text(
                'Referral',
                style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              children: <Widget>[
                ListTile(
                  leading: const Icon(CupertinoIcons.paperclip),
                  title: Text(
                    'Referral code',
                    style: GoogleFonts.habibi(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    final userId = _profileData?['user_id'];
                    if (userId != null) {
                      final referLink = 'https://clinkme.club/';
                      Share.share('Join our platform using my referral link: $referLink Referral code:$userId');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Unable to generate referral link')),
                      );
                    }
                  },
                ),

                ListTile(
                  leading: const Icon(CupertinoIcons.paperplane),
                  title: Text(
                    'Referral History',
                    style: GoogleFonts.habibi(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ReferralHistory()));
                  },
                ),
              ],
            ),


            ListTile(
              leading: const Icon(Icons.support_agent_outlined),
              title: Text(
                'Support',
                style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SupportView()));
              },
            ),


            ListTile(
              leading: const Icon(Icons.discount_outlined),
              title: Text(
                'Disclaimer',
                style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DisclaimerPage()));
              },
            ),

            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(
                'Privacy Policy',
                style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PrivacyPolicy()));
              },
            ),


            ListTile(
              leading: const Icon(Icons.travel_explore_rounded),
              title: Text(
                'Terms & Condidation',
                style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TermsCondidation()));
              },
            ),




            const Divider(),

            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: Text(
                'Logout',
                style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        "Confirm Logout",
                        style: GoogleFonts.habibi(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      content: Text(
                        "Are you sure, you want to logout?",
                        style: GoogleFonts.habibi(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            "No",
                            style: GoogleFonts.habibi(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text(
                            "Yes",
                            style: GoogleFonts.habibi(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () async {
                            final prefs =
                            await SharedPreferences.getInstance();
                            await prefs.clear(); // Clear all stored data
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login', (Route<dynamic> route) => false);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),

          ],
        ),
      ),



      body: TabBarView(
        controller: _tabController,
        children: [
          const CityElectionView(),
          StateElectionView(),
        ],
      ),
    );
  }
}
