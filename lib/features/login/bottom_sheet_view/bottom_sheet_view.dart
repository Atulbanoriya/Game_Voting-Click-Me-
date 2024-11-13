import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomSheetWidget extends StatefulWidget {

  const BottomSheetWidget({super.key});

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  final TextEditingController emailController = TextEditingController();



  void showCustomDialog(BuildContext context, {required String title, required String content, VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: GoogleFonts.niramit(fontWeight: FontWeight.bold),
          ),
          content: Text(
            content,
            style: GoogleFonts.niramit(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            InkWell(
              onTap: (){
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
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter your email ID',
            style: GoogleFonts.k2d(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration:  InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius:BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 15),

          Center(
            child: InkWell(
              onTap: (){


                String email = emailController.text.trim();
                print("Email entered: $email");

                showCustomDialog(
                    context,
                    title: 'Success',
                    content: 'Password Change Link will be send your Email Id $email',
                );
                // Navigator.pop(context);
              },
              child: Container(
                height: screenHeight * 0.06,
                width: screenWidth * 0.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xffa0cf1a),
                ),
                child: Center(
                  child: Text(
                    "Submit",
                    style: GoogleFonts.habibi(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}