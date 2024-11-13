import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusViewScreen extends StatefulWidget {
  final String userName;
  final List<String> statusImages;

  const StatusViewScreen({
    super.key,
    required this.userName,
    required this.statusImages,
  });

  @override
  _StatusViewScreenState createState() => _StatusViewScreenState();
}

class _StatusViewScreenState extends State<StatusViewScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Do not use MediaQuery here as the context is not fully built yet
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Preload images using MediaQuery inside didChangeDependencies
    for (String imagePath in widget.statusImages) {
      precacheImage(AssetImage(imagePath), context);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStatus() {
    if (_currentIndex < widget.statusImages.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStatus() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (details) {
          double screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 2) {
            _previousStatus();
          } else {
            _nextStatus();
          }
        },
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.statusImages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 90.0),
                  child: Center(
                    child: Image.asset(
                      widget.statusImages[index],
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.9,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 40,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: GoogleFonts.habibi(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Status progress indicator
                  Row(
                    children: List.generate(
                      widget.statusImages.length, (index) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2.0),
                          height: MediaQuery.of(context).size.width * 0.01, // Adjust size as needed
                          color: index <= _currentIndex
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                        ),
                      );
                    },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

