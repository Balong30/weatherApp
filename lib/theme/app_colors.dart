import 'package:flutter/material.dart';

/// App color palette for minimalist weather UI
/// Defines gradient backgrounds based on weather conditions and time of day
class AppColors {
  // Primary white for minimalist theme
  static const Color primaryWhite = Color(
    0xFFFFFFFF,
  );
  static const Color textPrimary = Color(
    0xFF2D2D2D,
  );
  static const Color textSecondary = Color(
    0xFF8B8B8B,
  );
  static const Color cardBackground = Color(
    0xFFF8F8F8,
  );

  // Sunny day gradient (pink/blue morning)
  static const List<Color> sunnyDay = [
    Color(0xFFFFC4D6), // Soft pink
    Color(0xFFFFE5EC), // Lighter pink
    Color(0xFFE3F2FD), // Light blue
    Color(0xFFBBDEFB), // Sky blue
  ];

  // Clear evening/sunset gradient (purple/orange)
  static const List<Color> clearEvening = [
    Color(0xFF4A2C4E), // Deep purple
    Color(0xFF7B4B6F), // Purple-pink
    Color(0xFFD97663), // Coral
    Color(0xFFFFB88C), // Peach
  ];

  // Clear night gradient (dark blue)
  static const List<Color> clearNight = [
    Color(0xFF1A2847), // Deep navy
    Color(0xFF2C4670), // Navy blue
    Color(0xFF3D5A80), // Medium blue
    Color(0xFF5A7A9E), // Light navy
  ];

  // Cloudy day gradient (gray/blue)
  static const List<Color> cloudyDay = [
    Color(0xFFB8C6DB), // Light gray-blue
    Color(0xFFD5DFE8), // Lighter gray-blue
    Color(0xFFE8EEF4), // Very light blue
    Color(0xFFF0F4F8), // Almost white
  ];

  // Rainy gradient (dark gray/blue)
  static const List<Color> rainy = [
    Color(0xFF4A5568), // Dark gray
    Color(0xFF5F6C7B), // Medium gray
    Color(0xFF7A8A9E), // Light gray
    Color(0xFF9BAAB8), // Lighter gray
  ];

  // Storm gradient (dark purple/gray)
  static const List<Color> storm = [
    Color(0xFF2D2A40), // Deep purple-gray
    Color(0xFF3E3B52), // Purple-gray
    Color(0xFF5B5570), // Medium purple-gray
    Color(0xFF786F8D), // Light purple-gray
  ];

  /// Returns gradient colors based on weather condition and time of day
  static List<Color> getBackgroundGradient(
    String? weatherCondition,
    DateTime time,
  ) {
    final hour = time.hour;
    final isNight = hour < 6 || hour >= 20;
    final isEvening = hour >= 17 && hour < 20;

    switch (weatherCondition?.toLowerCase()) {
      case 'clear':
        if (isNight) return clearNight;
        if (isEvening) return clearEvening;
        return sunnyDay;

      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'fog':
        return cloudyDay;

      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return rainy;

      case 'thunderstorm':
        return storm;

      default:
        if (isNight) return clearNight;
        if (isEvening) return clearEvening;
        return sunnyDay;
    }
  }

  /// Returns text color based on background brightness
  static Color getTextColor(
    List<Color> gradientColors,
  ) {
    // Calculate average brightness
    final firstColor = gradientColors.first;
    final luminance = firstColor
        .computeLuminance();

    // Return white for dark backgrounds, dark for light backgrounds
    return luminance > 0.5
        ? textPrimary
        : primaryWhite;
  }
}
