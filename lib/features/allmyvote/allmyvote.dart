import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voter_multi_app/features/allmyvote/statehistory/statehistory.dart';

import 'cityhistory/cityhistory.dart';

class AllMyVoteHistory extends StatefulWidget {
  const AllMyVoteHistory({super.key});

  @override
  State<AllMyVoteHistory> createState() => _AllMyVoteHistoryState();
}

class _AllMyVoteHistoryState extends State<AllMyVoteHistory>  with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          "My Vote History",
          style: GoogleFonts.habibi(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Text(
                "City History",
                style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            Tab(
              child: Text(
                "State History",
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
            CityHistoryWin(),
            StateHistoryWin(),
          ]),
    );
  }
}

