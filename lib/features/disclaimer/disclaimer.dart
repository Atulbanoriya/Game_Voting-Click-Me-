import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DisclaimerPage extends StatefulWidget {
  const DisclaimerPage({super.key});

  @override
  State<DisclaimerPage> createState() => _DisclaimerPageState();
}

class _DisclaimerPageState extends State<DisclaimerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffa0cf1a),
        title: Text(
          "Disclaimer",
          style: GoogleFonts.habibi(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:  SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Disclaimers for Click Me',
              style: GoogleFonts.habibi(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'If you require any more information or have any questions about our site\'s disclaimer, '
              'please feel free to contact us by email at 2024clickme@gmail.com.\n\n',
              style: GoogleFonts.habibi(fontSize: 16),
            ),
            Text(
              'All the information on this website - clinkme - is published in good faith and for general information purposes only. '
              'Click Me does not make any warranties about the completeness, reliability, and accuracy of this information. '
              'Any action you take upon the information you find on this website (Click Me), is strictly at your own risk. '
              'Click Me will not be liable for any losses and/or damages in connection with the use of our website.\n\n'
              'From our website, you can visit other websites by following hyperlinks to such external sites. '
              'While we strive to provide only quality links to useful and ethical websites, we have no control over the content and nature of these sites. '
              'These links to other websites do not imply a recommendation for all the content found on these sites. '
              'Site owners and content may change without notice and may occur before we have the opportunity to remove a link which may have gone \'bad\'.\n\n'
              'Please be also aware that when you leave our website, other sites may have different privacy policies and terms which are beyond our control. '
              'Please be sure to check the Privacy Policies of these sites as well as their "Terms of Service" before engaging in any business or uploading any information.\n\n',
              style: GoogleFonts.habibi(fontSize: 16),
            ),
            Text(
              'Consent\n',
              style: GoogleFonts.habibi(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'By using our website, you hereby consent to our disclaimer and agree to its terms.\n\n',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Update\n',
              style: GoogleFonts.habibi(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Should we update, amend or make any changes to this document, those changes will be prominently posted here.',
              style: GoogleFonts.habibi(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
