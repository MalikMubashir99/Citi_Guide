import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ Fade Animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // ✅ Scale Animation for Logo
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    // ✅ Navigate after 3 seconds with mounted check
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/onboarding");
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Background Image
          Image.asset(
            "assets/images/splash.jpg",
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: const Color(0xff0984E3),
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  size: 100,
                  color: Colors.white54,
                ),
              ),
            ),
          ),

          /// Gradient Overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(0, 0, 0, 0.20),
                  Color(0xAA0984E3),
                  Color(0xCC00CEC9),
                ],
              ),
            ),
          ),

          /// Animated Content
          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// Glass Logo with Scale Animation
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Image.asset(
                                "assets/images/logo.jpg",
                                width: 100,
                                height: 100,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.broken_image,
                                  size: 80,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        "Citi Guide",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "Explore • Discover • Experience",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 45),

                      /// ✅ Animated Loading Indicator with Text
                      Column(
                        children: [
                          const SizedBox(
                            width: 35,
                            height: 35,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TweenAnimationBuilder<double>(
                            duration: const Duration(seconds: 3),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (_, value, _) => Text(
                              "Loading... ${(value * 100).toInt()}%",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}