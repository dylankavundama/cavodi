import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cavodi/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> onboardingData = [
    {
      "image":
          "asset/a.jpeg",
      "title": "Bienvenue sur Cavodi",
      "description": "Explorez. Capturez. Partagez vos plus beaux souvenirs."
    },
    {
      "image":
          "asset/c.webp",
      "title": "Créez votre journal de voyage",
      "description": "Ajoutez des photos, des notes et localisez vos aventures."
    },
    {
      "image":
          "asset/d.jpeg",
      "title": "Partagez avec vos amis",
      "description": "Connectez-vous et échangez vos expériences uniques."
    },
  ];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < onboardingData.length - 1) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() async {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenOnboarding', true);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => TravelDiaryPage()),
      );
    }
  }

  Widget _buildPage(Map<String, String> data) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          data["image"]!,
          fit: BoxFit.cover,
        ),
        Container(
          color: Colors.black.withOpacity(0.5),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Text(
              data["title"]!,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                data["description"]!,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (_, index) => _buildPage(onboardingData[index]),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        _currentPage == index ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentPage == onboardingData.length - 1
                    ? 'Commencer'
                    : 'Suivant',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From',
                  style: GoogleFonts.abel(fontSize: 11, color: Colors.white),
                ),
                Text(
                  'WMAHUB',
                  style: GoogleFonts.abel(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
