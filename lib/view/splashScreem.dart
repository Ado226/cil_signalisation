import 'dart:async';
import 'package:flutter/material.dart';

import 'OnbordingPage.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Cette partie vide pousse le logo vers le centre vertical
          Expanded(
            flex: 1,
            child: Container(
             height: 15,
            ),
          ),
          // Logo au centre
          Image.asset(
            'assets/images/images1.png',
            width: 175,
          ),
          // Cette partie pousse le texte vers le bas
          Expanded(
            flex: 2,
            child: Container(),
          ),
          // Texte en bas de l'écran
          Padding(
            padding: EdgeInsets.only(bottom: 30),
            child: Text(
              "© 2025  Cil_signalisation - Version 1.0.0",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}