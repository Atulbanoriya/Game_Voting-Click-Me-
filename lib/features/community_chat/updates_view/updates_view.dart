import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'status_view/status_view.dart';

class UpdatesView extends StatefulWidget {
  const UpdatesView({super.key});

  @override
  State<UpdatesView> createState() => _UpdatesViewState();
}

class _UpdatesViewState extends State<UpdatesView> {
  final List<Map<String, dynamic>> statuses = [
    {
      "name": "Click Me!!",
      "profileImage": "asset/images/blacklogo.png",
      "statusImages": [
        "asset/images/status1.png",
        "asset/images/status2.png",
        "asset/images/status3.png",
        "asset/images/status4.png",
        "asset/images/status5.png",
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.add, size: 30, color: Colors.grey[700]),
                ),
                const SizedBox(width: 10),
                Text(
                  "My status",
                  style: GoogleFonts.habibi(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: statuses.length,
              itemBuilder: (context, index) {
                final status = statuses[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to status view screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatusViewScreen(
                          userName: status['name'],
                          statusImages: status['statusImages'],
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(status['profileImage']),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          status['name'],
                          style: GoogleFonts.habibi(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),




          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "Disclaimer:-This is only View our Developer working on this.",
                style: GoogleFonts.k2d(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



