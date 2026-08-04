// lib/widgets/search_bar_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Local blue palette (mirroring the home screen’s _AppColors) ──────────
class _SearchColors {
  static const Color surface = Colors.white;
  static const Color primary = Color(0xFF2563EB);   // blue
  static const Color lightGrey = Color(0xFFE2E8F0);
  static const Color dark = Color(0xFF0F172A);
  static const Color grey = Color(0xFF64748B);
}

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSearch;
  final ValueChanged<String>? onChanged;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onSearch,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: _SearchColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _SearchColors.lightGrey.withOpacity(0.6),
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
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(
          color: _SearchColors.dark,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: "Search places, attractions...",
          hintStyle: GoogleFonts.poppins(
            color: _SearchColors.grey,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _SearchColors.primary,
            size: 22,
          ),
          // ─── CRUCIAL: kill all borders ────────────────────────────────
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          // ────────────────────────────────────────────────────────────────
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: _SearchColors.grey,
                  size: 20,
                ),
                onPressed: () {
                  controller.clear();
                  if (onSearch != null) onSearch!();
                  if (onChanged != null) onChanged!('');
                },
              );
            },
          ),
        ),
        onChanged: onChanged,
        onSubmitted: (_) {
          if (onSearch != null) onSearch!();
        },
      ),
    );
  }
}