import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsCondidation extends StatefulWidget {
  const TermsCondidation({super.key});

  @override
  State<TermsCondidation> createState() => _TermsCondidationState();
}

class _TermsCondidationState extends State<TermsCondidation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffa0cf1a),
        title:  Text(
            'Terms & Conditions',
          style: GoogleFonts.habibi(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:  SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Click Me!',
              style: GoogleFonts.habibi(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'These terms and conditions outline the rules and regulations for the use of Click Me\'s Website, '
                  'located at clinkme.\n\n'
                  'By accessing this website we assume you accept these terms and conditions. Do not continue to '
                  'use Click Me if you do not agree to take all of the terms and conditions stated on this page.\n\n'
                  'The following terminology applies to these Terms and Conditions, Privacy Statement and Disclaimer '
                  'Notice and all Agreements: "Client", "You" and "Your" refers to you, the person log on this website '
                  'and compliant to the Company’s terms and conditions. "The Company", "Ourselves", "We", "Our" and "Us", '
                  'refers to our Company. "Party", "Parties", or "Us", refers to both the Client and ourselves. All terms '
                  'refer to the offer, acceptance and consideration of payment necessary to undertake the process of our '
                  'assistance to the Client in the most appropriate manner for the express purpose of meeting the Client’s '
                  'needs in respect of provision of the Company’s stated services, in accordance with and subject to, prevailing '
                  'law of Netherlands. Any use of the above terminology or other words in the singular, plural, capitalization '
                  'and/or he/she or they, are taken as interchangeable and therefore as referring to same.\n\n'
                  'Cookies\nWe employ the use of cookies. By accessing Click Me, you agreed to use cookies in agreement with '
                  'the Click Me\'s Privacy Policy.\n\nMost interactive websites use cookies to let us retrieve the user’s details '
                  'for each visit. Cookies are used by our website to enable the functionality of certain areas to make it easier '
                  'for people visiting our website. Some of our affiliate/advertising partners may also use cookies.\n\n'
                  'License\nUnless otherwise stated, Click Me and/or its licensors own the intellectual property rights for all '
                  'material on Click Me. All intellectual property rights are reserved. You may access this from Click Me for your '
                  'own personal use subjected to restrictions set in these terms and conditions.\n\n'
                  'You must not:\n\n'
                  'Republish material from Click Me\nSell, rent or sub-license material from Click Me\nReproduce, duplicate or '
                  'copy material from Click Me\nRedistribute content from Click Me\n\n'
                  '... (rest of the terms and conditions here) ...',
              style: GoogleFonts.habibi(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
