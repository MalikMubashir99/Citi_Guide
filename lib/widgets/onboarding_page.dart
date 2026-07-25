import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background Image
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade300,
                child: const Icon(
                  Icons.broken_image,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
            ),
          ),

          /// Bottom Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color.fromRGBO(0, 0, 0, 0.15),
                  Color.fromRGBO(0, 0, 0, 0.55),
                  Color.fromRGBO(0, 0, 0, 0.90),
                ],
                stops: [0.0, 0.45, 0.72, 1.0],
              ),
            ),
          ),

          /// Text
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 17,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}