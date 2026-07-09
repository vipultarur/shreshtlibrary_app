import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF1EFFC); // Original scaffold bg
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF917CFF); // Original primary
  static const Color lightOnPrimary = Color(0xFF140C2C); // Original text on primary
  static const Color lightPrimaryContainer = Color(0xFFF1EFFC); // Used for auth surface/container
  static const Color lightSecondary = Color(0xFFC4B8FF); // Original secondary/unselected
  static const Color lightTextPrimary = Color(0xFF140C2C); // Original dark text
  static const Color lightTextSecondary = Color(0xFF1E2442); // Original secondary text
  static const Color lightError = Color(0xFFEF4444); // Red 500
  static const Color lightBorder = Color(0xFFCBB9FF); // Replaces Gray 200 with the purple border color

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212); // Smooth standard dark background
  static const Color darkSurface = Color(0xFF1E1E1E); // Smooth dark surface
  static const Color darkAppBarBg = Color(0xFF121212); // Match background
  static const Color darkPrimary = Color(0xFF8B5CF6); // Pleasing Violet 500 accent
  static const Color darkPrimaryLight = Color(0xFFA78BFA); // Violet 400
  static const Color darkNavSelectedBg = Color(0xFF2D2445); // Subtle violet tint for pill bg
  static const Color darkPrimaryText = Color(0xFFF9FAFB); // Gray 50
  static const Color darkNavUnselected = Color(0xFF9CA3AF); // Gray 400
  static const Color darkSecondary = Color(0xFF10B981); // Emerald 500
  static const Color darkTextPrimary = Color(0xFFF9FAFB); // Gray 50
  static const Color darkTextSecondary = Color(0xFF9CA3AF); // Gray 400
  static const Color darkError = Color(0xFFEF4444); // Red 500
  static const Color darkBorder = Color(0xFF4B4B4B); // Neutral visible border
  static const Color darkPrimaryContainer = Color(0xFF262626); // Slightly lighter than surface for text fields
}
