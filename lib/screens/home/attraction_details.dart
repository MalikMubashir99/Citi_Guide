// lib/screens/home/attraction_detail_screen.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:app/model/attraction_model.dart';
import 'package:app/screens/home/review_screen.dart';
import 'package:app/services/favorite_service.dart';
import 'package:app/services/review_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AttractionDetailScreen extends StatefulWidget {
  final AttractionModel attraction;

  const AttractionDetailScreen({super.key, required this.attraction});

  @override
  State<AttractionDetailScreen> createState() => _AttractionDetailScreenState();
}

class _AttractionDetailScreenState extends State<AttractionDetailScreen> {
  final FavoriteService favoriteService = FavoriteService();
  final ReviewService reviewService = ReviewService();

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadFavorite();
  }

  Future<void> openGoogleMaps() async {
    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${widget.attraction.latitude},${widget.attraction.longitude}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      _showErrorSnackBar("Unable to open Google Maps");
    }
  }

  Future<void> loadFavorite() async {
    bool favorite = await favoriteService.isFavorite(widget.attraction.id);
    if (mounted) {
      setState(() {
        isFavorite = favorite;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: AppColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Warm Linen
      appBar: AppBar(
        title: Text(
          widget.attraction.name,
          style: GoogleFonts.poppins(
            color: AppColors.dark,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? AppColors.error : AppColors.dark, // Burnt Sienna when active
            ),
            onPressed: () async {
              if (isFavorite) {
                await favoriteService.removeFavoriteByAttraction(widget.attraction.id);
              } else {
                await favoriteService.addFavorite(widget.attraction.id);
              }
              await loadFavorite();
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.dark),
            onPressed: () {
              // Share attraction logic
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                widget.attraction.image.isEmpty
                    ? Container(
                        height: 280,
                        width: double.infinity,
                        color: AppColors.lightGrey,
                        child: Icon(Icons.landscape_rounded, size: 100, color: AppColors.grey),
                      )
                    : Image.network(
                        widget.attraction.image,
                        width: double.infinity,
                        height: 280,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 280,
                          width: double.infinity,
                          color: AppColors.lightGrey,
                          child: Icon(Icons.broken_image, size: 100, color: AppColors.grey),
                        ),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 280,
                            width: double.infinity,
                            color: AppColors.lightGrey,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            ),
                          );
                        },
                      ),
                
                // Espresso tinted gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.splashOverlayDark.withValues(alpha: 0.6),
                          AppColors.splashOverlayDark.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Rating badge
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FutureBuilder<double>(
                    future: reviewService.getAverageRating(widget.attraction.id),
                    builder: (context, ratingSnapshot) {
                      return FutureBuilder<int>(
                        future: reviewService.getReviewCount(widget.attraction.id),
                        builder: (context, countSnapshot) {
                          final rating = ratingSnapshot.hasData ? ratingSnapshot.data! : 0.0;
                          final count = countSnapshot.hasData ? countSnapshot.data! : 0;

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary, // Rich Cognac
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, color: AppColors.white, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: GoogleFonts.poppins(
                                    color: AppColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (count > 0) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '($count)',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.white.withValues(alpha: 0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                
                // City badge
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          widget.attraction.cityId,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.dark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Attraction Name
                  Text(
                    widget.attraction.name,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Star Rating Row
                  FutureBuilder<double>(
                    future: reviewService.getAverageRating(widget.attraction.id),
                    builder: (context, ratingSnapshot) {
                      return FutureBuilder<int>(
                        future: reviewService.getReviewCount(widget.attraction.id),
                        builder: (context, countSnapshot) {
                          if (ratingSnapshot.connectionState == ConnectionState.waiting ||
                              countSnapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            );
                          }

                          final rating = ratingSnapshot.hasData ? ratingSnapshot.data! : 0.0;
                          final count = countSnapshot.hasData ? countSnapshot.data! : 0;

                          return Row(
                            children: [
                              ...List.generate(
                                5,
                                (index) => Icon(
                                  index < rating.floor()
                                      ? Icons.star_rounded
                                      : index < rating
                                          ? Icons.star_half_rounded
                                          : Icons.star_outline_rounded,
                                  color: AppColors.secondary, // Warm Sand stars
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                rating.toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '($count reviews)',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.grey, // Warm Grey
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // About Section Header
                  _buildSectionHeader("About"),
                  const SizedBox(height: 12),
                  
                  // Description Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface, // Pure white
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.7), width: 1),
                    ),
                    child: Text(
                      widget.attraction.description,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: AppColors.darkGrey, // Warm Charcoal
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Contact Section Header
                  _buildSectionHeader("Contact Information"),
                  const SizedBox(height: 12),

                  // Info Tiles
                  _buildInfoTile(
                    icon: Icons.access_time_rounded,
                    label: "Opening Hours",
                    value: widget.attraction.openingHours.isEmpty ? "Not available" : widget.attraction.openingHours,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoTile(
                    icon: Icons.phone_rounded,
                    label: "Phone",
                    value: widget.attraction.phone.isEmpty ? "Not available" : widget.attraction.phone,
                    isClickable: widget.attraction.phone.isNotEmpty,
                    onTap: () => _callAttraction(),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoTile(
                    icon: Icons.language_rounded,
                    label: "Website",
                    value: widget.attraction.website.isEmpty ? "Not available" : widget.attraction.website,
                    isClickable: widget.attraction.website.isNotEmpty,
                    onTap: () => _openWebsite(),
                  ),
                  const SizedBox(height: 28),

                  // Actions Header
                  _buildSectionHeader("Actions"),
                  const SizedBox(height: 12),

                  // Google Maps Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: openGoogleMaps,
                      icon: const Icon(Icons.map_rounded, color: AppColors.white, size: 22),
                      label: Text(
                        "Open in Google Maps",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0, // Flat modern style
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Write Review Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ReviewScreen(attraction: widget.attraction)),
                        );
                      },
                      icon: const Icon(Icons.rate_review_rounded, color: AppColors.primary, size: 22),
                      label: Text(
                        "Write Review",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primaryLight, width: 1.5), // Softer border
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Section Header Widget
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary, // Cognac accent bar
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.7), width: 1),
      ),
      child: InkWell(
        onTap: isClickable ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1), // Very light cognac bg
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: AppColors.dark,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isClickable)
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _callAttraction() async {
    if (widget.attraction.phone.isEmpty) return;
    final Uri url = Uri.parse("tel:${widget.attraction.phone}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (!mounted) return;
      _showErrorSnackBar("Unable to make call");
    }
  }

  Future<void> _openWebsite() async {
    if (widget.attraction.website.isEmpty) return;
    String urlString = widget.attraction.website;
    if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
      urlString = 'https://$urlString';
    }
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      _showErrorSnackBar("Unable to open website");
    }
  }
}