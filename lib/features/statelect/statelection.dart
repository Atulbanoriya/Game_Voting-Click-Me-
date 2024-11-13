import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voter_multi_app/features/dashboard/dashboard.dart';
import '../../main.dart';
import 'package:voter_multi_app/custom/const.dart';

import '../../model/sliderelectionmodel/slider_election_state/slider_election_state.dart';

class StateElectionView extends StatefulWidget {
  @override
  _StateElectionViewState createState() => _StateElectionViewState();
}

class _StateElectionViewState extends State<StateElectionView> {
  Map<String, List<Candidate>> groupedCandidates = {};
  bool isLoading = true;
  Map<String, int?> votedCandidateIndices = {};
  final LocalStorageService localStorageService = LocalStorageService();

  Map<String, dynamic>? _profileData;
  int? _userId;

  late Timer _timer;
  String _formattedDateTime = '';

  int totalUser = 0;
  int totalElection = 0;
  int totalTodayElection = 0;
  String userName = 'N/A';
  String userWalletAmount = 'N/A';
  int totalVoter = 0;
  int todayVoter = 0;

  bool hasElections = false;

  int voteTotal = 0;
  int countPendingVote = 0;
  int countTotalVote = 0;

  Map<String, bool> groupLoadingStates = {};

  Map<String, bool> groupHasVoted = {};

  List<ElectedCandidates> candidates = [];

   bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserTotalRecord('state');
    _updateDateTime();
    loadCandidates();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _updateDateTime();
    });
    _fetchProfileData();
    fetchStateData();
  }

  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy/MM/dd - EEEE - HH:mm:ss');
    setState(() {
      _formattedDateTime = formatter.format(now);
    });
  }

  // Future<void> fetchStateData() async {
  //   final url = 'https://vote.nextgex.com/api/elected_candidate_state';
  //   final token = await localStorageService.getToken();
  //   final headers = {
  //     'Content-Type': 'application/json',
  //     if (token != null) 'Authorization': 'Bearer $token',
  //   };
  //
  //   final response = await http.get(Uri.parse(url), headers: headers);
  //   if (response.statusCode == 200) {
  //     final groups = parseCandidates(response.body);
  //     hasElections =
  //         groups.isNotEmpty; // Update hasElections based on the fetched data
  //     for (var groupKey in groups.keys) {
  //       int groupId = groups[groupKey]?.first.groupId ?? 0;
  //
  //       // Fetch vote counts for the group
  //       final voteCounts = await fetchVoteCount(groupId);
  //
  //       // Update the group with vote counts
  //       groups[groupKey]?.forEach((candidate) {
  //         candidate.voteTotal = voteCounts['voteTotal'] ?? 0;
  //         candidate.countPendingVote = voteCounts['countPendingVote'] ?? 0;
  //         candidate.countTotalVote = voteCounts['countTotalVote'] ?? 0;
  //       });
  //     }
  //
  //     setState(() {
  //       groupedCandidates = groups;
  //       isLoading = false;
  //     });
  //   } else {
  //     print('Error fetching data. Status code: ${response.statusCode}');
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  Future<void> fetchStateData() async {
    final url = 'https://vote.nextgex.com/api/elected_candidate_state';
    final token = await localStorageService.getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      final groups = parseCandidates(response.body);
      hasElections = groups.isNotEmpty;

      for (var groupKey in groups.keys) {
        int groupId = groups[groupKey]?.first.groupId ?? 0;

        // Fetch vote counts for the group
        final voteCounts = await fetchVoteCount(groupId);

        // Update the group with vote counts
        groups[groupKey]?.forEach((candidate) {
          candidate.voteTotal = voteCounts['voteTotal'] ?? 0;
          candidate.countPendingVote = voteCounts['countPendingVote'] ?? 0;
          candidate.countTotalVote = voteCounts['countTotalVote'] ?? 0;
        });
      }

      if (mounted) {
        setState(() {
          groupedCandidates = groups;
          isLoading = false;
        });
      }
    } else {
      print('Error fetching data. Status code: ${response.statusCode}');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

// Fetches vote counts for a specific group
  Future<Map<String, int>> fetchVoteCount(int groupId) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.post(
      Uri.parse('https://vote.nextgex.com/api/group_vote_count'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'group_id': groupId.toString(),
        'type': 'state',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return {
        'voteTotal': data['voteTotal'] ?? 0,
        'countPendingVote': data['countPendingVote'] ?? 0,
        'countTotalVote': data['countTotalVote'] ?? 0,
      };
    } else {
      print(
          'Failed to load vote count for group $groupId. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      return {
        'voteTotal': 0,
        'countPendingVote': 0,
        'countTotalVote': 0,
      };
    }
  }

  Future<void> castVote(
      int candidateId, String candidateType, String groupKey) async {
    // Show loader
    setState(() {
      groupLoadingStates[groupKey] = true;
    });

    // API details
    final url = 'https://vote.nextgex.com/api/vote_apply';
    final token = await localStorageService.getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    // Prepare request body
    final body = jsonEncode({
      'booking_id': candidateId,
      'type': candidateType,
    });

    print("Sending vote request: $body");

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final voteResponse = Votevote.fromJson(json.decode(response.body));

        setState(() {
          votedCandidateIndices[groupKey] = groupedCandidates[groupKey]!
              .indexWhere((candidate) =>
                  candidate.id == voteResponse.voter.candidateId);
          // groupHasVoted[groupKey] = true;
          groupLoadingStates[groupKey] = false;
        });

        await Future.delayed(const Duration(milliseconds: 200));

        setState(() {
          groupedCandidates.remove(groupKey);
        });

        // Fetch updated records
        fetchUserTotalRecord('state');
      } else {
        // Handle non-successful vote
        showCustomDialog(
          context,
          title: 'Wait Few Second',
          content: 'Too many Request wait',
        );

        print('Error voting. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        setState(() {
          groupLoadingStates[groupKey] = false;
        });
      }
    } catch (error) {
      print('Error occurred while voting: $error');
      setState(() {
        groupLoadingStates[groupKey] = false;
      });
    } finally {
      if (groupLoadingStates[groupKey] != false) {
        setState(() {
          groupLoadingStates[groupKey] = false;
        });
      }
    }
  }

  Map<String, List<Candidate>> parseCandidates(String responseBody) {
    final parsed = json.decode(responseBody);
    final dynamic data = parsed['elected_candidates'];

    if (data is Map<String, dynamic>) {
      return (data as Map<String, dynamic>)
          .map<String, List<Candidate>>((key, value) {
        return MapEntry(
            key,
            (value as List<dynamic>)
                .map((json) => Candidate.fromJson(json))
                .toList());
      });
    } else {
      return {};
      throw Exception('Unexpected JSON format');
    }
  }

  // Future<void> _fetchProfileData() async {
  //   try {
  //     final token = await getToken();
  //
  //     if (token == null) {
  //       throw Exception('Token not found');
  //     }
  //
  //     final response = await http.get(
  //       Uri.parse('https://vote.nextgex.com/api/user'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       var responseData = json.decode(response.body);
  //       print('API Response Data: $responseData');
  //
  //       if (responseData is Map<String, dynamic> &&
  //           responseData.containsKey('user')) {
  //         var userData = responseData['user'];
  //         if (userData.containsKey('wallet_amount') &&
  //             userData.containsKey('id')) {
  //           setState(() {
  //             _profileData = userData;
  //             _userId = userData['id'];
  //           });
  //         } else {
  //           print('User data does not contain wallet_amount or id key');
  //           throw Exception(
  //               'User data does not contain wallet_amount or id key');
  //         }
  //       } else {
  //         print('API Response does not contain user key or is not a Map');
  //         throw Exception(
  //             'API Response does not contain user key or is not a Map');
  //       }
  //     } else {
  //       print(
  //           'Failed to load profile data. Status code: ${response.statusCode}');
  //       print('Response body: ${response.body}');
  //       throw Exception('Failed to load profile data');
  //     }
  //   } catch (e) {
  //     print('Exception: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: ${e.toString()}')),
  //     );
  //   }
  // }

  Future<void> _fetchProfileData() async {
    try {
      final token = await localStorageService.getToken();
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

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('user')) {
          var userData = responseData['user'];
          if (userData.containsKey('wallet_amount') &&
              userData.containsKey('id')) {
            if (mounted) {
              setState(() {
                _profileData = userData;
                _userId = userData['id'];
              });
            }
          } else {
            print('User data does not contain wallet_amount or id key');
            throw Exception('User data does not contain wallet_amount or id key');
          }
        } else {
          print('API Response does not contain user key or is not a Map');
          throw Exception('API Response does not contain user key or is not a Map');
        }
      } else if (response.statusCode == 429) {
        print('Error fetching data: Too many requests (Status code: 429)');
        throw Exception('Too many requests. Please try again later.');
      } else {
        print('Failed to load profile data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      print('Exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }



  // Future<void> fetchUserTotalRecord(String type) async {
  //   final url = 'https://vote.nextgex.com/api/user_total_record';
  //   final token = await localStorageService.getToken();
  //   final headers = {
  //     'Content-Type': 'application/json',
  //     if (token != null) 'Authorization': 'Bearer $token',
  //   };
  //
  //   final body = jsonEncode({
  //     'type': type,
  //   });
  //
  //   final response =
  //       await http.post(Uri.parse(url), headers: headers, body: body);
  //
  //   if (response.statusCode == 200) {
  //     final recordData = json.decode(response.body);
  //     setState(() {
  //       totalUser = recordData['total_user'];
  //       totalElection = recordData['total_election'];
  //       totalTodayElection = recordData['total_today_election'];
  //       userName = recordData['user_name'];
  //       userWalletAmount = recordData['user_wallet_amount'];
  //       totalVoter = recordData['total_voter'];
  //       todayVoter = recordData['today_voter'];
  //     });
  //   } else {
  //     print(
  //         'Error fetching user total record data. Status code: ${response.statusCode}');
  //     print('Response Body: ${response.body}');
  //   }
  // }

  Future<void> fetchUserTotalRecord(String type) async {
    final url = 'https://vote.nextgex.com/api/user_total_record';
    final token = await localStorageService.getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'type': type,
    });

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final recordData = json.decode(response.body);
      if (mounted) {
        setState(() {
          totalUser = recordData['total_user'];
          totalElection = recordData['total_election'];
          totalTodayElection = recordData['total_today_election'];
          userName = recordData['user_name'];
          userWalletAmount = recordData['user_wallet_amount'];
          totalVoter = recordData['total_voter'];
          todayVoter = recordData['today_voter'];
        });
      }
    } else {
      print(
          'Error fetching user total record data. Status code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
  }

  void showCustomDialog(BuildContext context,
      {required String title,
      required String content,
      VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: 18),
          ),
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

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  String getElectionStatusText() {
    DateTime now = DateTime.now();
    DateTime startTime;

    if (now.hour >= 0 && now.hour < 11) {
      // Election starts today at 10:00 AM
      startTime = DateTime(now.year, now.month, now.day, 10, 0);
      return "Election Will Start At ${formatDate(startTime)}";
    } else if (now.hour >= 11 && now.hour < 17) {
      // Election starts today at 4:00 PM
      startTime = DateTime(now.year, now.month, now.day, 16, 0);
      return "Election Will Start At ${formatDate(startTime)}";
    } else {
      // After 5:00 PM, the election starts tomorrow at 10:00 AM
      startTime = DateTime(now.year, now.month, now.day + 1, 10, 0);
      return "Election Will Start At ${formatDate(startTime)}";
    }
  }

  String formatDate(DateTime dateTime) {
    // Format the date and time to the desired format: "YYYY/MM/DD - 10:00 AM"
    String date =
        "${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}";
    String time =
        "${dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour < 12 ? 'AM' : 'PM'}";
    return "$date - $time";
  }

  Future<List<ElectedCandidates>> fetchCandidates() async {
    final token = await localStorageService.getToken();

    final response = await http.get(
      Uri.parse(
          'https://vote.nextgex.com/api/elected_candidate_state_image_data'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<dynamic> candidatesJson = data['elected_candidates'];
      return candidatesJson
          .map<ElectedCandidates>((json) => ElectedCandidates.fromJson(json))
          .toList();
      setState(() {});
    } else {
      throw Exception('Failed to load candidates');
    }
  }

  void loadCandidates() async {
    try {

      var fetchedCandidates = await fetchCandidates();
      if (mounted) {
        setState(() {
          candidates = fetchedCandidates;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding:
                  EdgeInsets.all(screenWidth * 0.025),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(
                        screenWidth * 0.015),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                "User Id:- ${_profileData?['user_id'] != null ? (_profileData!['user_id'].toString().length > 8 ? _profileData!['user_id'].toString().substring(0, 8) : _profileData!['user_id'].toString()) : ''}",
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth *
                                      0.04, // Responsive font size
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                "Name:- ${userName.length > 8 ? userName.substring(0, 8) : userName}",
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth *
                                      0.04, // Responsive font size
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                "Total Voters:- $totalUser",
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                "My Wallet:- $userWalletAmount",
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                "Total Election:- $totalElection",
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                "Total Votes:- $totalVoter",
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                "Today Election:- $totalTodayElection",
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                "Today Votes:- $todayVoter",
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 2,
                    color: Colors.grey,
                  ),
                  Center(
                    child: Container(
                      height: screenHeight * 0.05,
                      width: screenWidth * 0.9,
                      decoration: BoxDecoration(
                        color: const Color(0xffa0cf1a),
                        border: Border.all(
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          _formattedDateTime,
                          style: GoogleFonts.chakraPetch(
                            fontSize:
                                screenWidth * 0.04, // Responsive font size
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    thickness: 2,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 10),
                  if (isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else if (groupedCandidates.isEmpty)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Text(
                            getElectionStatusText(),
                            style: GoogleFonts.chakraPetch(
                                fontSize: screenWidth * 0.040,
                                fontWeight:
                                    FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: screenHeight * 0.4,
                          child: buildCarouselSlider(
                              candidates),
                        ),
                      ],
                    )
                  else
                    ...groupedCandidates.entries.map((entry) {
                      return Column(
                        children: [
                          Text(
                            'Election ${entry.key}',
                            style: GoogleFonts.habibi(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth *
                                    0.045),
                          ),
                          const Divider(
                            thickness: 2,
                            color: Colors.black,
                          ),
                          const SizedBox(height: 5),
                          buildCandidatesContainer(entry.value, entry.key),
                        ],
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCandidatesContainer(List<Candidate> candidates, String groupKey) {
    if (groupHasVoted[groupKey] == true) {
      // Return an empty container if the group has been voted and removed
      return const SizedBox.shrink();
    }

    final voteTotal = candidates.isNotEmpty ? candidates.first.voteTotal : 0;
    final countPendingVote =
        candidates.isNotEmpty ? candidates.first.countPendingVote : 0;
    final countTotalVote =
        candidates.isNotEmpty ? candidates.first.countTotalVote : 0;

    return Stack(
      children: [
        Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(9.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Total Votes: $voteTotal",
                      style: GoogleFonts.b612(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: Colors.black),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Pending Voters: $countPendingVote",
                      style: GoogleFonts.b612(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: Colors.black),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Submitted Votes: $countTotalVote",
                      style: GoogleFonts.b612(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: Colors.black),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: candidates.length,
                    itemBuilder: (context, index) {
                      final candidate = candidates[index];
                      final isVoted = votedCandidateIndices[groupKey] == index;

                      return GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: MediaQuery.of(context).size.width *
                              0.15, // Adjusted width to ensure each candidate has sufficient space
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xffa0cf1a),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 4,
                              ),
                              Center(
                                child: CircleAvatar(
                                  radius:
                                      MediaQuery.of(context).size.width * 0.04,
                                  backgroundImage: candidate.profileImage !=
                                              null &&
                                          candidate.profileImage!.isNotEmpty
                                      ? NetworkImage(
                                          '${ConstRes.imageUrl}${candidate.profileImage!}')
                                      : const AssetImage(
                                              'asset/images/placeholder.png')
                                          as ImageProvider,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(candidate.userName,
                                  maxLines: 1,
                                  style: GoogleFonts.habibi(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8)),
                              const SizedBox(height: 5),
                              const SizedBox(height: 10),
                              if (votedCandidateIndices[groupKey] == null)
                                InkWell(
                                  onTap: () {
                                    castVote(candidate.id, "state", groupKey);
                                  },
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.03, // Increased button height
                                    width: MediaQuery.of(context).size.width *
                                        0.13, // Increased button width
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Color(0xff035afc),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Vote",
                                        style: GoogleFonts.habibi(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                )
                              else if (isVoted)
                                Container(
                                  height: MediaQuery.of(context).size.height *
                                      0.03, // Increased button height
                                  width: MediaQuery.of(context).size.width *
                                      0.13, // Increased button width
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: const Color(0xfff53302),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Voted",
                                      style: GoogleFonts.habibi(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (groupLoadingStates[groupKey] == true)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildCarouselSlider(List<ElectedCandidates> candidates) {
    if (candidates.isEmpty) {
      return Center(
        child: Text(
          'No candidates available',
          style: GoogleFonts.chakraPetch(
              fontSize: 14, fontWeight: FontWeight.bold),
        ),
      );
    }

    return CarouselSlider.builder(
      itemCount: candidates.length,
      itemBuilder: (context, index, realIdx) {
        ElectedCandidates candidate = candidates[index];
        return Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xffa0cf1a),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.black.withOpacity(0.15),
              width: 0.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                offset: Offset(0, 0),
                blurRadius: 6,
                spreadRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(5, 5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: Text(
                          "Next Candidate:-",
                          style: GoogleFonts.chakraPetch(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.03,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: MediaQuery.of(context).size.width * 0.25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xffedf50c),
                          offset: Offset(0, 0),
                          blurRadius: 6,
                          spreadRadius: 8,
                        ),
                      ],
                      image: DecorationImage(
                        image: candidate.profileImage != null
                            ? NetworkImage(
                            '${ConstRes.imageUrl}${candidate.profileImage!}')
                            : const AssetImage("asset/images/placeholder.png"),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0), // Add padding around text
                  child: Column(
                    children: [
                      Text(
                        'Candidate:- ${candidate.userName}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.chakraPetch(
                            fontSize: MediaQuery.of(context).size.width * 0.03,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Elec.- ${candidate.totalElec}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.chakraPetch(
                            fontSize: MediaQuery.of(context).size.width * 0.032,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Win/Loss:- ${candidate.totalElecWin}/${candidate.totalElecLoss}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.chakraPetch(
                            fontSize: MediaQuery.of(context).size.width * 0.032,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height * 0.35,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        viewportFraction: 0.95,
      ),
    );
  }
}

class Candidate {
  final int id;
  final String userName;
  final String? profileImage;
  final int groupId;

  int voteTotal;
  int countPendingVote;
  int countTotalVote;

  bool hasVoted;

  Candidate({
    required this.id,
    required this.userName,
    this.profileImage,
    required this.groupId,
    this.hasVoted = false,
    this.voteTotal = 0,
    this.countPendingVote = 0,
    this.countTotalVote = 0,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['id'],
      userName: json['user_name'],
      profileImage: json['profile_image'],
      groupId: json['group_id'],
      hasVoted: json['has_voted'] ?? false,
    );
  }
}

class Votevote {
  final Voter voter;

  Votevote({
    required this.voter,
  });

  factory Votevote.fromJson(Map<String, dynamic> json) {
    return Votevote(
      voter: Voter.fromJson(json['voter']),
    );
  }
}

class Voter {
  final int candidateId;

  Voter({
    required this.candidateId,
  });

  factory Voter.fromJson(Map<String, dynamic> json) {
    return Voter(
      candidateId: json['candidate_id'],
    );
  }
}
