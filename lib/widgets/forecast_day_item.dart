import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/forecast_model.dart';
import 'package:weather_app/utils/weather_animation_helper.dart';

class ForecastDayItem extends StatelessWidget {
  final DailyForecast dayWeather;
  final Color textColor;

  static const double _iconSize = 34.0;

  const ForecastDayItem({
    super.key,
    required this.dayWeather,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final dayLabel = DateFormat('E').format(dayWeather.date);
    final avgTemp = ((dayWeather.tempMin + dayWeather.tempMax) / 2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dayLabel,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Lottie.asset(
            WeatherAnimationHelper.getWeatherAnimation(
              dayWeather.mainCondition,
            ),
            width: _iconSize,
            height: _iconSize,
          ),
          const SizedBox(height: 2),
          Text(
            '${avgTemp.round()}°',
            style: TextStyle(
              color: textColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}