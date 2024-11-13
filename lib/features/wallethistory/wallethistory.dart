import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voter_multi_app/features/wallethistory/givehistory/givehistory.dart';
import 'package:voter_multi_app/features/wallethistory/takehistory/takehistory.dart';
class WalletHistoryTab extends StatefulWidget {
  const WalletHistoryTab({super.key});

  @override
  State<WalletHistoryTab> createState() => _WalletHistoryTabState();
}

class _WalletHistoryTabState extends State<WalletHistoryTab> with SingleTickerProviderStateMixin{
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
          "Wallet History",
          style: GoogleFonts.habibi(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Text(
                "Give History",
                style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            Tab(
              child: Text(
                "Take History",
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
            GiveHistory(),
            TakeHistory(),
          ]),
    );
  }
}
