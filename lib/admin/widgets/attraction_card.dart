// lib/admin/widgets/attraction_card.dart
import 'package:app/admin/models/attraction_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Direct colors (no AppColors) ──
class _CardColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color dark = Color(0xFF0F172A);
  static const Color darkGrey = Color(0xFF334155);
  static const Color grey = Color(0xFF64748B);
  static const Color lightGrey = Color(0xFFE2E8F0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color background = Color(0xFFF8FAFC);
}

class AttractionCard extends StatelessWidget {
  final AttractionModel attraction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AttractionCard({
    super.key,
    required this.attraction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _CardColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _CardColors.lightGrey.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Image ──
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 70,
              height: 70,
              color: _CardColors.lightGrey.withOpacity(0.4),
              child: attraction.image.isNotEmpty
                  ? Image.network(
                      attraction.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.broken_image,
                        color: _CardColors.grey,
                        size: 30,
                      ),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _CardColors.primary,
                            ),
                          ),
                        );
                      },
                    )
                  : Icon(
                      Icons.landscape_rounded,
                      color: _CardColors.grey,
                      size: 36,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // ── Info ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attraction.name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _CardColors.dark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: _CardColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        attraction.cityId,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _CardColors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: _CardColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      attraction.rating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _CardColors.dark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (attraction.phone.isNotEmpty)
                      Text(
                        attraction.phone,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _CardColors.grey,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // ── Modern Edit & Delete Buttons ──
          Row(
            children: [
              // Edit button with rounded background
              Container(
                decoration: BoxDecoration(
                  color: _CardColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.edit_rounded,
                    color: _CardColors.primary,
                    size: 20,
                  ),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  tooltip: 'Edit',
                ),
              ),
              const SizedBox(width: 4),
              // Delete button with rounded background
              Container(
                decoration: BoxDecoration(
                  color: _CardColors.error.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: _CardColors.error,
                    size: 20,
                  ),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  tooltip: 'Delete',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}