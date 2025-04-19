import 'package:cavodi/home.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Rediriger vers l'écran principal après 3 secondes
    Timer(const Duration(seconds: 1115), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) =>   TravelDiaryPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image en arrière-plan
          Image.asset(
            'asset/logo.png'
,            fit: BoxFit.cover,
          ),
          // Couche de couleur sombre pour lisibilité
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          // Texte au centre
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Cavodi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Explorez. Capturez. Partagez.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

           Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    'From',
                                    style: GoogleFonts.abel(
                                        fontSize:11, color: Colors.white),
                                  ),
                                  Text(
                                    'WMAHUB ',
                                    style: GoogleFonts.abel(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
        ],
      ),
    );
  }
}

 