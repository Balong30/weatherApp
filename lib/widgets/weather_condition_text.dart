import 'package:flutter/material.dart';

class WeatherConditionText extends StatelessWidget {
  final String condition;
  final Color textColor;

  const WeatherConditionText({
    super.key,
    required this.condition,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      condition,
      style: TextStyle(
        fontSize: 16,
        color: textColor.withOpacity(0.7),
      ),
    );
  }
}