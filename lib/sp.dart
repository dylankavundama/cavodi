import 'package:flutter/material.dart';
import 'dart:async';

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
    Timer(const Duration(seconds: 1111), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
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
          Image.network(
            'https://images.pexels.com/photos/3360711/pexels-photo-3360711.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
            fit: BoxFit.cover,
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
                  'Carnet de Voyage',
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
        ],
      ),
    );
  }
}

// Exemple d'écran suivant
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Page d\'accueil')),
    );
  }
}
