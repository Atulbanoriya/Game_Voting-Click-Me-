import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voter_multi_app/features/candapplyreport/stateapplyreport/stateapplyreport.dart';
import 'cityapplyreport/cityapplyreport.dart';
class CandidateApplyReport extends StatefulWidget {
  const CandidateApplyReport({super.key});

  @override
  State<CandidateApplyReport> createState() => _CandidateApplyReportState();
}

class _CandidateApplyReportState extends State<CandidateApplyReport> with SingleTickerProviderStateMixin {
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
          "Apply History",
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
            CityApplyReport(),
            StateApplyReport(),
          ]),
    );
  }
}
