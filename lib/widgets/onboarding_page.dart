import 'package:flutter/material.dart';
import 'package:app/core/constants/app_colors.dart';

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final int currentIndex;
  final int totalPages;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    this.currentIndex = 0,
    this.totalPages = 3,
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
                color: AppColors.lightGrey,
                child: Icon(
                  Icons.broken_image,
                  size: 100,
                  color: AppColors.grey,
                ),
              ),
            ),
          ),

          /// Gradient Overlay - Brownish tones
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.brown.shade900.withValues(alpha: 0.1),
                  Colors.brown.shade900.withValues(alpha: 0.5),
                  Colors.brown.shade900.withValues(alpha: 0.85),
                  Colors.brown.shade900.withValues(alpha: 0.95),
                ],
                stops: const [0.0, 0.3, 0.55, 0.75, 1.0],
              ),
            ),
          ),

          /// Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  /// Skip Button
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () {
                        // Navigate to home
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  /// Page Indicator Dots
                  Row(
                    children: List.generate(
                      totalPages,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        width: currentIndex == index ? 30 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: currentIndex == index
                              ? AppColors.secondary
                              : Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Title with Playfair Display
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Description
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 17,
                        height: 1.7,
                        letterSpacing: 0.3,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  /// Next Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Next page or navigate to home
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.secondary.withValues(alpha: 0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentIndex == totalPages - 1
                                ? 'Get Started'
                                : 'Next',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (currentIndex != totalPages - 1) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 22,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}