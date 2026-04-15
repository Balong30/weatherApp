import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weather_app/models/forecast_model.dart';
import 'package:weather_app/widgets/forecast_day_item.dart';

class ForecastCard extends StatelessWidget {
  final List<DailyForecast> forecast;
  final Animation<double> fadeAnimation;
  final Color textColor;

  static const double _cardBorderRadius = 16.0;
  static const double _animBlurSigma = 8.0;

  const ForecastCard({
    super.key,
    required this.forecast,
    required this.fadeAnimation,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_cardBorderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: _animBlurSigma,
              sigmaY: _animBlurSigma,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 6,
                horizontal: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(_cardBorderRadius),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: forecast
                      .map(
                        (day) => ForecastDayItem(
                          dayWeather: day,
                          textColor: textColor,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}