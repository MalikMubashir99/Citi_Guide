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
  int currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper method to match the colors shown in the designs
  Color _getActiveColor(int index) {
    if (index == 0) return const Color(0xFF2563EB); // Blue
    if (index == 1) return const Color(0xFF22C55E); // Green
    return const Color(0xFFF59E0B); // Orange
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Page View
          PageView.builder(
            controller: _controller,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
                isLastPage = index == onboardingData.length - 1;
              });
            },
            itemBuilder: (context, index) {
              final item = onboardingData[index];

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Full-screen background image
                  Image.asset(
                    item.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1E3A5F), Color(0xFF0D1B2A)],
                        ),
                      ),
                    ),
                  ),

                  // Dark gradient overlay 
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black.withValues(alpha: 0.95),
                        ],
                        stops: const [0.0, 0.4, 0.75, 1.0],
                      ),
                    ),
                  ),

                  // Content (Text and Dots aligned to the left)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Title
                          Text(
                            item.title,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Description
                          Text(
                            item.description,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Page Indicator
                          SmoothPageIndicator(
                            controller: _controller,
                            count: onboardingData.length,
                            effect: ExpandingDotsEffect(
                              activeDotColor: _getActiveColor(index),
                              dotColor: Colors.white.withValues(alpha: 0.4),
                              dotHeight: 6,
                              dotWidth: 6,
                              expansionFactor: 3.5,
                              spacing: 6,
                            ),
                          ),
                          
                          // Extra spacing to account for the white bottom sheet overlapping
                          const SizedBox(height: 160),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // 2. White Bottom Sheet Controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 28,
                right: 28,
                top: 28,
                bottom: MediaQuery.of(context).padding.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLastPage) ...[
                    // Final Page: Full-width "Get Started" Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, "/login");
                        },
                        child: Text(
                          "Get Started",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Pages 1 & 2: Split "Skip" and "Next" Buttons
                    Row(
                      children: [
                        // Skip Button
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFFF3F4F6),
                                foregroundColor: const Color(0xFF4B5563),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, "/login");
                              },
                              child: Text(
                                "Skip",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Next Button
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getActiveColor(currentPage),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                _controller.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Text(
                                "Next",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  
                  // Faint branding text at the bottom center (as seen in screenshots)
                  Text(
                    "CITYGUIDE • MOBILE APP",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: const Color(0xFF9CA3AF).withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}