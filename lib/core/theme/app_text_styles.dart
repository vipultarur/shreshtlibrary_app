import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Light Theme Text Styles
  static const TextStyle lightHeadline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.lightTextPrimary,
    letterSpacing: -1.0,
  );

  static const TextStyle lightHeadline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.lightTextPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle lightBody = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.lightTextPrimary,
  );

  static const TextStyle lightBodySecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.lightTextSecondary,
  );

  static const TextStyle lightButton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Dark Theme Text Styles
  static const TextStyle darkHeadline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.darkTextPrimary,
    letterSpacing: -1.0,
  );

  static const TextStyle darkHeadline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle darkBody = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.darkTextPrimary,
  );

  static const TextStyle darkBodySecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.darkTextSecondary,
  );

  static const TextStyle darkButton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.darkTextPrimary,
  );
}
