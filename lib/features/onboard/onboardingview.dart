import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voter_multi_app/features/login/login_view.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onBoarding.length,
                itemBuilder: (BuildContext context, int index) =>
                    OnboardContent(
                  title: onBoarding[index].title,
                  subtitle: onBoarding[index].subtitle,
                  image: onBoarding[index].image,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (_pageController.page == onBoarding.length - 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginView()),
                  );
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                }
              },
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xffa0cf1a)),
                child: const Center(
                  child: Icon(
                    Icons.arrow_forward_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }
}

class Onboard {
  final String title, subtitle, image;

  Onboard(this.title, this.subtitle, this.image);
}

final List<Onboard> onBoarding = [
  Onboard(
    "Welcome to Click Me!",
    "Where your opinions matter! Join our community and participate in exciting Elections on a wide range of topics. Your votes count!",
    "asset/onboard/intro1.png",
  ),
  Onboard(
    "Easy and Quick Voting",
    "With Click Me, voting is effortless. Browse through various Elections, select your choice, and click to vote. It’s that simple!",
    "asset/onboard/intro2.png",
  ),
  Onboard(
    "Get Started Now!",
    "Ready to get started? Sign up or log in to access all features of Click Me. Your votes matter!",
    "asset/onboard/intro3.png",
  ),
];

class OnboardContent extends StatelessWidget {
  const OnboardContent({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
  });

  final String title, subtitle, image;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Image.asset(
          image,
          height: 250,
        ),
        const Spacer(),
        Text(
          title,
          style: GoogleFonts.habibi(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.habibi(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              textBaseline: TextBaseline.alphabetic,
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
