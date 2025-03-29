import 'package:flutter/material.dart';

import 'HomePage.dart';


class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/images1.png",
      "title": "Bienvenue",
      "subtitle": "Découvrez les fonctionnalités de notre application."
    },
    {
        "image": "assets/images/images2.jpg",
      "title": "Suivi en temps réel",
      "subtitle": "Gardez un œil sur vos activités en temps réel."
    },
    {
  "image": "assets/images/images2.jpg",
      "title": "Prêt à commencer?",
      "subtitle": "Lancez-vous dès maintenant et profitez de nos services."
    },
  ];

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _onboardingData.length,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 12 : 8,
          height: _currentPage == index ? 12 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.teal : const Color.fromARGB(255, 0, 204, 184),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_onboardingData[index]["image"]!),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),

         Positioned(
  bottom: 0,
  left: 0,
  right: 0,
  child: Container(
    width: size.width,
    height: size.height * 0.3,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, -3),
        ),
      ],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Text(
              _onboardingData[_currentPage]["title"]!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.teal,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              _onboardingData[_currentPage]["subtitle"]!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bouton Passer visible seulement si on n'est pas à la dernière page
            _currentPage < _onboardingData.length - 1
                ? TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Passer",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  )
                : const SizedBox(width: 80),
            _buildPageIndicator(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {
                if (_currentPage < _onboardingData.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                }
              },
              child: Text(
                _currentPage < _onboardingData.length - 1 ? "Suivant" : "Commencer",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
)
        ],
      ),
    );
  }
}

class YourHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Bienvenue sur la page d'accueil!"),
      ),
    );
  }
}
