import 'dart:developer' as dev;
import 'package:app/model/attraction_model.dart';
import 'package:app/model/review_model.dart';
import 'package:app/screens/home/home_screen.dart';
import 'package:app/screens/home/review_screen.dart';
import 'package:app/services/favorite_service.dart';
import 'package:app/services/review_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Local Blue Theme ──────────────────────────────────────────────────────────
class _AppColors {
  static const Color background = Color(0xFFF8FAFC);
  static const Color white = Colors.white;
  static const Color dark = Color(0xFF0F172A);
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color error = Color(0xFFDC2626);
  static const Color lightGrey = Color(0xFFE2E8F0);
  static const Color grey = Color(0xFF64748B);
  static const Color star = Color(0xFFF59E0B);
}

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

  // ─── Core Logic (unchanged) ──────────────────────────────────────────────────

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
    if (mounted) setState(() => isFavorite = favorite);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: _AppColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: _AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _callAttraction() async {
    final phone = widget.attraction.phone.isEmpty
        ? "+33892701239"
        : widget.attraction.phone;
    final Uri url = Uri.parse("tel:$phone");
    if (await canLaunchUrl(url))
      await launchUrl(url);
    else if (mounted)
      _showErrorSnackBar("Unable to make call");
  }

  Future<void> _openWebsite() async {
    String urlString = widget.attraction.website.isEmpty
        ? "https://toureiffel.paris"
        : widget.attraction.website;
    if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
      urlString = 'https://$urlString';
    }
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      _showErrorSnackBar("Unable to open website");
    }
  }

  // ─── UI Helpers ──────────────────────────────────────────────────────────────

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: isClickable ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: _AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _AppColors.dark,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isClickable)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: _AppColors.grey,
              ),
          ],
        ),
      ),
    );
  }

  // ─── Review Tile using ReviewModel ──────────────────────────────────────────
  Widget _buildReviewTile(ReviewModel review) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _AppColors.lightGrey, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _AppColors.primaryLight,
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'U',
                  style: GoogleFonts.poppins(
                    color: _AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: _AppColors.dark,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < review.rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: _AppColors.star,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          review.rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: _AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: _AppColors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            review.comment,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: _AppColors.dark.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      body: Stack(
        children: [
          // ─── Image Header ──────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: widget.attraction.image.isEmpty
                ? Container(
                    height: 380,
                    width: double.infinity,
                    color: _AppColors.lightGrey,
                    child: const Icon(
                      Icons.landscape_rounded,
                      size: 100,
                      color: _AppColors.grey,
                    ),
                  )
                : Image.network(
                    widget.attraction.image,
                    width: double.infinity,
                    height: 380,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 380,
                      color: _AppColors.lightGrey,
                      child: const Icon(
                        Icons.broken_image,
                        size: 100,
                        color: _AppColors.grey,
                      ),
                    ),
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                            height: 380,
                            color: _AppColors.lightGrey,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _AppColors.primary,
                              ),
                            ),
                          ),
                  ),
          ),

          // ─── Floating Actions ──────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ✅ FIXED: Back button with proper navigation
                GestureDetector(
                  onTap: () {
                    dev.log('Back button tapped', name: 'AttractionDetail');
                    dev.log(
                      'Can pop: ${Navigator.canPop(context)}',
                      name: 'AttractionDetail',
                    );
                    dev.log(
                      'Current route: ${ModalRoute.of(context)?.settings.name}',
                      name: 'AttractionDetail',
                    );

                    if (Navigator.canPop(context)) {
                      dev.log(
                        'Navigator can pop, going back...',
                        name: 'AttractionDetail',
                      );
                      Navigator.pop(context);
                    } else {
                      dev.log(
                        'Cannot pop, no previous screen!',
                        name: 'AttractionDetail',
                      );
                      // Fallback: Go to home or close the app
                      // For web, you might want to use:
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                Row(
                  children: [
                    _circleIconButton(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      () async {
                        if (isFavorite) {
                          await favoriteService.removeFavoriteByAttraction(
                            widget.attraction.id,
                          );
                        } else {
                          await favoriteService.addFavorite(
                            widget.attraction.id,
                          );
                        }
                        await loadFavorite();
                      },
                      color: isFavorite ? _AppColors.error : Colors.white,
                    ),
                    const SizedBox(width: 10),
                    _circleIconButton(Icons.share_rounded, () {
                      /* share logic */
                    }),
                  ],
                ),
              ],
            ),
          ),

          // ─── Scrollable Content Sheet ──────────────────────────────────────
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 330),
              child: Container(
                decoration: const BoxDecoration(
                  color: _AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Title & Price ──────────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.attraction.name,
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: _AppColors.dark,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "€26",
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: _AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ─── Category & City ────────────────────────────────────
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Landmark",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: _AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: _AppColors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.attraction.cityId,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: _AppColors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ─── Rating Summary ──────────────────────────────────────
                    FutureBuilder<double>(
                      future: reviewService.getAverageRating(
                        widget.attraction.id,
                      ),
                      builder: (context, ratingSnap) {
                        return FutureBuilder<int>(
                          future: reviewService.getReviewCount(
                            widget.attraction.id,
                          ),
                          builder: (context, countSnap) {
                            final rating = ratingSnap.hasData
                                ? ratingSnap.data!
                                : 0.0;
                            final count = countSnap.hasData
                                ? countSnap.data!
                                : 0;
                            return Row(
                              children: [
                                ...List.generate(
                                  5,
                                  (i) => Icon(
                                    i < rating
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    color: _AppColors.star,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _AppColors.dark,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '(${count > 1000 ? '${(count / 1000).toStringAsFixed(1)}k' : count} reviews)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: _AppColors.grey,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: _AppColors.lightGrey, thickness: 1),
                    ),

                    // ─── Description ──────────────────────────────────────────
                    Text(
                      widget.attraction.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: _AppColors.dark.withOpacity(0.8),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── Info Tiles ────────────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: _AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _AppColors.lightGrey,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildInfoTile(
                            icon: Icons.access_time_rounded,
                            label: "Opening Hours",
                            value: widget.attraction.openingHours.isEmpty
                                ? "9:00 AM – 12:45 AM"
                                : widget.attraction.openingHours,
                          ),
                          const Divider(
                            height: 1,
                            color: _AppColors.lightGrey,
                            indent: 64,
                          ),
                          _buildInfoTile(
                            icon: Icons.location_on_outlined,
                            label: "Address",
                            value: "Champ de Mars, 75007 Paris, France",
                            isClickable: true,
                            onTap: openGoogleMaps,
                          ),
                          const Divider(
                            height: 1,
                            color: _AppColors.lightGrey,
                            indent: 64,
                          ),
                          _buildInfoTile(
                            icon: Icons.phone_outlined,
                            label: "Phone",
                            value: widget.attraction.phone.isEmpty
                                ? "+33 892 70 12 39"
                                : widget.attraction.phone,
                            isClickable: true,
                            onTap: _callAttraction,
                          ),
                          const Divider(
                            height: 1,
                            color: _AppColors.lightGrey,
                            indent: 64,
                          ),
                          _buildInfoTile(
                            icon: Icons.language_outlined,
                            label: "Website",
                            value: widget.attraction.website.isEmpty
                                ? "toureiffel.paris"
                                : widget.attraction.website,
                            isClickable: true,
                            onTap: _openWebsite,
                          ),
                        ],
                      ),
                    ),
               
                   
                    const SizedBox(height: 30),

                    // ─── Reviews Section ──────────────────────────────────────
                    _buildSectionHeader("Reviews"),
                    const SizedBox(height: 12),

                    // ✅ Use StreamBuilder because getReviews returns a Stream
                    StreamBuilder<List<ReviewModel>>(
                      stream: reviewService.getReviews(widget.attraction.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _AppColors.primary,
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text(
                            "Failed to load reviews",
                            style: GoogleFonts.poppins(color: _AppColors.error),
                          );
                        }
                        final reviews = snapshot.data ?? [];
                        if (reviews.isEmpty) {
                          return Text(
                            "No reviews yet",
                            style: GoogleFonts.poppins(
                              color: _AppColors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          );
                        }
                        return Column(
                          children: reviews
                              .map((r) => _buildReviewTile(r))
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // ─── Write Review Button (only if user hasn't reviewed) ──
                    FutureBuilder<bool>(
                      future: reviewService.hasUserReviewed(
                        widget.attraction.id,
                      ),
                      builder: (context, userReviewSnap) {
                        if (userReviewSnap.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink(); // or placeholder
                        }
                        final hasReviewed = userReviewSnap.data ?? false;
                        if (hasReviewed) {
                          return const SizedBox.shrink(); // hide button
                        }
                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReviewScreen(
                                    attraction: widget.attraction,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.rate_review_rounded,
                              color: _AppColors.primary,
                              size: 20,
                            ),
                            label: Text(
                              "Write a Review",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _AppColors.primary,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: _AppColors.primary,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton(
    IconData icon,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color ?? Colors.white, size: 24),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: _AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _AppColors.dark,
          ),
        ),
      ],
    );
  }
}
