import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

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
                color: AppColors.primarySurface, // Warm tint fallback
                child: const Icon(
                  Icons.broken_image_outlined,
                  size: 100,
                  color: AppColors.grey,
                ),
              ),
            ),
          ),

          /// Gradient Overlay - Deep Espresso Tones
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.dark.withValues(alpha: 0.2), // Rich Dark Brown fading in
                  AppColors.splashOverlayDark.withValues(alpha: 0.6), // Deep dark brown
                  AppColors.splashOverlayDark.withValues(alpha: 0.85),
                  AppColors.splashOverlayDark, // Solid deep dark brown at bottom
                ],
                stops: const [0.0, 0.3, 0.5, 0.75, 1.0],
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
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.secondaryLight, // Pale peach for visibility on dark
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
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
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(right: 8),
                        width: currentIndex == index ? 32 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: currentIndex == index
                              ? AppColors.secondary // Warm Sand
                              : AppColors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// Title
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: AppColors.dark, // Warm shadow instead of black
                            blurRadius: 15,
                            offset: Offset(0, 4),
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
                        color: AppColors.white.withValues(alpha: 0.8),
                        fontSize: 16,
                        height: 1.7,
                        letterSpacing: 0.3,
                        shadows: [
                          Shadow(
                            color: AppColors.dark.withValues(alpha: 0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  /// Next Button
                  Container(
                    width: double.infinity,
                    height: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.warmGlow, // Golden glow instead of standard shadow
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        // Next page or navigate to home
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary, // Warm Sand
                        foregroundColor: AppColors.dark, // Deep Espresso text (looks much classier than white on sand)
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0, // Elevation handled by box shadow
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentIndex == totalPages - 1
                                ? 'Get Started'
                                : 'Next',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (currentIndex != totalPages - 1) ...[
                            const SizedBox(width: 8),
                            const Icon(
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