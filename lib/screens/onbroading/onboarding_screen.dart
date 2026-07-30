// lib/screens/onbroading/onboarding_screen.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/onboarding_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page View
          PageView.builder(
            controller: _controller,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == onboardingData.length - 1;
              });
            },
            itemBuilder: (context, index) {
              final item = onboardingData[index];

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  Image.asset(
                    item.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      // Fallback matching new palette
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF5C3D24), Color(0xFF1A110A)],
                        ),
                      ),
                    ),
                  ),

                  // Cinematic Dark Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.3),
                          AppColors.splashOverlayDark.withValues(alpha: 0.85),
                          AppColors.primaryDark.withValues(alpha: 0.95),
                        ],
                        stops: const [0.0, 0.25, 0.6, 1.0],
                      ),
                    ),
                  ),

                  // Content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        children: [
                          // Skip Button
                          Align(
                            alignment: Alignment.topRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  "/login",
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white.withValues(alpha: 0.9),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                "Skip",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Title
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w600, // Semi-bold is more modern than full bold
                              height: 1.2,
                              letterSpacing: 0.5,
                              shadows: const [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 15,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Description
                          Text(
                            item.description,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 16, // Slightly smaller for better hierarchy
                              fontWeight: FontWeight.w400,
                              height: 1.6,
                              letterSpacing: 0.3,
                            ),
                          ),

                          // Added spacer to push content up slightly so it doesn't overlap controls
                          const SizedBox(height: 80), 
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Bottom Controls (Floating over the gradient)
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Page Indicator
                SmoothPageIndicator(
                  controller: _controller,
                  count: onboardingData.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppColors.secondary, // Warm Sand color
                    dotColor: Colors.white.withValues(alpha: 0.3),
                    dotHeight: 10,
                    dotWidth: 10,
                    expansionFactor: 3,
                    spacing: 8,
                  ),
                ),

                const SizedBox(height: 32),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLastPage ? AppColors.secondary : AppColors.white,
                      foregroundColor: AppColors.primaryDark, // Dark espresso text on both
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0, // Flat modern design
                    ),
                    onPressed: () {
                      if (isLastPage) {
                        Navigator.pushReplacementNamed(context, "/login");
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastPage ? "Get Started" : "Next",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        if (!isLastPage) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                            color: AppColors.primaryDark,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Skip to Login (only on last page)
                if (isLastPage)
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/login");
                    },
                    child: Text(
                      "Already have an account? Login",
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
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