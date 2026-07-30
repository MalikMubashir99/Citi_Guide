// lib/widgets/primary_button.dart
import 'package:app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final String? loadingText;
  final IconData? prefixIcon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.loadingText,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isButtonDisabled = isDisabled || isLoading || onPressed == null;
    final Color effectiveBgColor = backgroundColor ?? AppColors.primary;
    final Color effectiveTextColor = textColor ?? AppColors.white;

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 56,
      child: ElevatedButton(
        onPressed: isButtonDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0, // Flat modern style
          backgroundColor: effectiveBgColor,
          foregroundColor: effectiveTextColor,
          disabledBackgroundColor: AppColors.lightGrey.withValues(alpha: 0.6), // Soft warm grey when disabled
          disabledForegroundColor: AppColors.darkGrey, // Readable text when disabled
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Updated to 16px for consistency
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          // Note: If you want the beautiful "warm glow" shadow from EditProfile, 
          // simply wrap this PrimaryButton in a Container with AppColors.warmGlow
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: effectiveTextColor.withValues(alpha: 0.8),
                    ),
                  ),
                  if (loadingText != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      loadingText!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: effectiveTextColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefixIcon != null) ...[
                    Icon(
                      prefixIcon,
                      size: 20,
                      color: effectiveTextColor,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: effectiveTextColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}