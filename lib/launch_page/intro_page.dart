import 'package:flutter/material.dart';
import 'dart:async';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../auth/register.dart';
import 'package:lbrikol/launch_page/onboarding.dart';

// SplashScreen: The initial screen displayed when the app is launched.
// It shows a logo/icon for 3 seconds before navigating to the OnboardingScreen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start a timer to delay for 3 seconds before navigating to the onboarding screen.
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor:
          Color(0xFF40189D), // Background color of the splash screen
      body: Center(
        child: Icon(
          Icons.school, // Display a school icon
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }
}

// OnboardingScreen: A screen that introduces the app to users through multiple pages.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller =
      PageController(); // Controls page navigation
  int _currentIndex = 0; // Tracks the current page index
  final int _totalPages = 3; // Total number of onboarding pages

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Skip button to allow users to go directly to the registration screen.
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
            child: Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    color: Color(0xFF40189D),
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          // PageView to display multiple onboarding pages (3 onboarding pages).
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: const [
                OnboardingPage(
                  title: "Turn Time into Opportunity",
                  description:
                      "Are you a student looking for a flexible way to earn money? With L’Bricool, you can find short-term gigs that fit your schedule—whether it’s babysitting, tutoring, running errands, or more. Work when you want, earn what you need!",
                ),
                OnboardingPage(
                  title: "Find Reliable Help in One Tap",
                  description:
                      "Need a babysitter, a tutor, or someone to run errands? L’Bricool connects you with verified students ready to assist you. Fast, easy, and reliable—you get the help you need while supporting local students.",
                ),
                OnboardingPage(
                  title: "A Secure & Trusted Community",
                  description:
                      "We verify student profiles and ensure secure payments for a smooth experience. Whether you’re working or hiring, L’Bricool makes it easy, transparent, and trustworthy for everyone.",
                ),
              ],
            ),
          ),
          // Page indicator to show the progress of the onboarding steps (the 3 dots in the bottom).
          SmoothPageIndicator(
            controller: _controller,
            count: _totalPages,
            effect: const WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: Color(0xFF40189D),
            ),
          ),
          // Navigation buttons (Back and Next)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    if (_currentIndex > 0) {
                      _controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
                // Next button
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF40189D),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    onPressed: () {
                      if (_currentIndex == _totalPages - 1) {
                        // If it's the last page, go to the RegisterPage
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterPage()),
                        );
                      } else {
                        // Otherwise, go to the next page
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
