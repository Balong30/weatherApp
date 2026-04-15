import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/utils/weather_animation_helper.dart';

class CityWeatherHeader extends StatelessWidget {
  final String cityName;
  final String? mainCondition;
  final Color textColor;

  const CityWeatherHeader({
    super.key,
    required this.cityName,
    required this.mainCondition,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          cityName.toUpperCase(),
          style: TextStyle(
            fontSize: 18,
            color: textColor.withOpacity(0.7),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 12),
        Lottie.asset(
          WeatherAnimationHelper.getWeatherAnimation(mainCondition),
          width: 100,
          height: 100,
        ),
      ],
    );
  }
}