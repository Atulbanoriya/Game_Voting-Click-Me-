import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../givetake/givetake.dart';
import 'home.dart';
import 'applyview.dart';
import '../profile/profileviewtab.dart';

class DashBoardView extends StatefulWidget {
  final String token;

  const DashBoardView({super.key, required this.token});

  @override
  State<DashBoardView> createState() => _DashBoardViewState();
}

class _DashBoardViewState extends State<DashBoardView> {
  final PageController _pageController = PageController(initialPage: 0);
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> bottomBarPages = [
      const HomeView(),
      const GiveTakeHome(),
      const ApplyCandidatePage(),
      const ProfileView(),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: bottomBarPages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xffa0cf1a),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'My Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Apply',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white, // Adjust as needed
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
        selectedLabelStyle: GoogleFonts.chakraPetch(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: GoogleFonts.chakraPetch(fontWeight: FontWeight.bold, fontSize: 14),
        type: BottomNavigationBarType.fixed, // Add this line to ensure background color is applied
      ),
    );
  }
}

