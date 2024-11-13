// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class CustomDialog extends StatelessWidget {
//   final String title;
//   final String content;
//
//   CustomDialog({required this.title, required this.content});
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20.0),
//       ),
//       backgroundColor: Colors.transparent,
//       child: Stack(
//         clipBehavior: Clip.none,
//         alignment: Alignment.center,
//         children: <Widget>[
//           Container(
//             width: 300,
//             padding: EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.rectangle,
//               borderRadius: BorderRadius.circular(20.0),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black26,
//                   blurRadius: 10.0,
//                   offset: const Offset(0.0, 10.0),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//
//                 Text(
//                   title,
//                   textAlign: TextAlign.left,
//                   style: GoogleFonts.habibi(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                       fontSize: 18
//                   ),
//                 ),
//                 SizedBox(height: 16.0),
//                 Text(
//                   content,
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.habibi(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                       fontSize: 16
//                   ),
//                 ),
//                 SizedBox(height: 50),
//
//                Align(
//                  alignment: Alignment.bottomRight,
//                  child: GestureDetector(
//                    onTap: () {
//                      Navigator.of(context).pop();
//                    },
//                    child: Container(
//                      height: 30,
//                      width: 80,
//                      decoration: BoxDecoration(
//                          color: Color(0xffa0cf1a),
//                          borderRadius: BorderRadius.circular(8)
//                      ),
//                      child: Center(
//                        child: Text(
//                          'Okay',
//                          style: GoogleFonts.habibi(
//                              fontWeight: FontWeight.bold,
//                              color: Colors.white,
//                              fontSize: 18
//                          ),
//                        ),
//                      ),
//                    ),
//                  ),
//                ),
//
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// void showCustomDialog(BuildContext context, {String title = 'Custom Dialog Title', String content = 'This is a custom-styled dialog box in Flutter. You can add your content here.'}) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return CustomDialog(title: title, content: content);
//     },
//   );
// }