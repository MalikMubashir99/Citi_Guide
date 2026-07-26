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
  });

  @override
  Widget build(BuildContext context) {
    final bool isButtonDisabled = isDisabled || isLoading || onPressed == null;

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 56,
      child: ElevatedButton(
        onPressed: isButtonDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          disabledBackgroundColor: AppColors.grey.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: textColor ?? AppColors.white,
                    ),
                  ),
                  if (loadingText != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      loadingText!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor ?? AppColors.white,
                      ),
                    ),
                  ],
                ],
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textColor ?? AppColors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}