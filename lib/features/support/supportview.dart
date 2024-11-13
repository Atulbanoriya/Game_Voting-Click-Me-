import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voter_multi_app/features/support/supphistory.dart';
import 'package:http/http.dart' as http;

class SupportView extends StatefulWidget {
  const SupportView({super.key});

  @override
  State<SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<SupportView> {
  int _selectedQuery = 0;
  final TextEditingController _messageController = TextEditingController();

  final Map<int, String> _queryLabels = {
    0: "Give/Take Points",
    1: "My Details Change",
    2: "Others",
  };

  void _handleRadioValueChange(int? value) {
    setState(() {
      _selectedQuery = value!;
    });
  }

  Future<void> sendSupportTicket(String querySubject, String queryDescription) async {
    final url = 'https://vote.nextgex.com/api/ticket_support';

    try {
      final token = await getToken();

      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'querySubject': querySubject,
          'queryDescription': queryDescription,
        },
      );

      if (response.statusCode == 200) {
        print('Support ticket sent successfully');
        showCustomDialog(
          context,
          title: 'Thank you for your submission!',
          content: 'Our team will review it and contact you soon',
          onPressed: () {
            Navigator.of(context).pop();
          }, image: Image.asset(
          "asset/images/blacklogo.png",
          width: 45,
          height: 45,
        ),
        );
      } else {
        print('Failed to send support ticket. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to send support ticket');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to send support ticket');
    }
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void showCustomDialog(BuildContext context, {required image,required String title, required String content, VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14),
              ),

              CircleAvatar(
                minRadius: 20,
                child: image,
              )
            ],
          ),
          content: Text(
            content,
            style: TextStyle(fontSize: 14),
          ),
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
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffa0cf1a),
        title: Text(
          "Support",
          style: GoogleFonts.habibi(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SuppHistory()));
              },
              child: Text(
                "History ?",
                style: GoogleFonts.habibi(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Get Assistance, FAQs, and Contact Information",
                style: GoogleFonts.habibi(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              Text(
                "Select Your Query Type:",
                style: GoogleFonts.habibi(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListTile(
                title: Text(
                  "Give/Take Points",
                  style: GoogleFonts.habibi(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: Radio(
                  value: 0,
                  groupValue: _selectedQuery,
                  onChanged: _handleRadioValueChange,
                ),
              ),
              ListTile(
                title: Text(
                  "My Details Change",
                  style: GoogleFonts.habibi(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: Radio(
                  value: 1,
                  groupValue: _selectedQuery,
                  onChanged: _handleRadioValueChange,
                ),
              ),
              ListTile(
                title: Text(
                  "Others",
                  style: GoogleFonts.habibi(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: Radio(
                  value: 2,
                  groupValue: _selectedQuery,
                  onChanged: _handleRadioValueChange,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Please provide more details:",
                style: GoogleFonts.habibi(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your message here...',
                ),
              ),
              SizedBox(height: 15),
              Align(
                alignment: Alignment.bottomRight,
                child: InkWell(
                  onTap: () async {
                    print("Selected Query: ${_queryLabels[_selectedQuery]}");
                    print("Message: ${_messageController.text}");
                    try {
                      await sendSupportTicket(_queryLabels[_selectedQuery]!, _messageController.text);
                    } catch (e) {}
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
                        "Send",
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
