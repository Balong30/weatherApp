import 'package:flutter/material.dart';

class TemperatureDisplay extends StatelessWidget {
  final double temperature;
  final Color textColor;

  const TemperatureDisplay({
    super.key,
    required this.temperature,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '${temperature.round()}°',
      style: TextStyle(
        fontSize: 42,
        color: textColor,
      ),
    );
  }
}