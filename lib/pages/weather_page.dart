import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/models/forecast_model.dart';
import 'package:weather_app/theme/app_colors.dart';
import 'package:intl/intl.dart';

/// Main weather screen with minimalist UI
class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() =>
      _WeatherPageState();
}

class _WeatherPageState
    extends State<WeatherPage> {
  final _weatherService = WeatherService(
    '291cef864197d525c10a970bd57d4006',
  );
  Weather? _weather;
  List<DailyForecast> _forecast = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    try {
      setState(() => _isLoading = true);

      LocationPermission permission =
          await Geolocator.checkPermission();
      if (permission ==
          LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission ==
              LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        throw Exception(
          "Location permission denied",
        );
      }

      Position position =
          await Geolocator.getCurrentPosition(
            locationSettings: LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          );

      final weather = await _weatherService
          .getWeatherByCoords(
            position.latitude,
            position.longitude,
          );

      final forecast = await _weatherService
          .getForecastByCoords(
            position.latitude,
            position.longitude,
          );

      setState(() {
        _weather = weather;
        _forecast = forecast.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      print("ERROR: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors =
        AppColors.getBackgroundGradient(
          _weather?.mainCondition,
          DateTime.now(),
        );
    final textColor = AppColors.getTextColor(
      gradientColors,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(
                  child:
                      CircularProgressIndicator(
                        color: AppColors
                            .primaryWhite,
                      ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          // Weather condition
                          Text(
                            _weather?.mainCondition ??
                                "Clear",
                            style: TextStyle(
                              fontSize: 20,
                              color: textColor
                                  .withOpacity(
                                    0.9,
                                  ),
                              fontWeight:
                                  FontWeight.w300,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),

                          // Large temperature
                          Text(
                            '${_weather?.temperature.round() ?? 0}°',
                            style: TextStyle(
                              fontSize: 96,
                              color: textColor,
                              fontWeight:
                                  FontWeight.w200,
                              height: 1,
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),

                          // City name
                          Text(
                            _weather?.cityName
                                    .toUpperCase() ??
                                "LOADING",
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor
                                  .withOpacity(
                                    0.6,
                                  ),
                              fontWeight:
                                  FontWeight.w500,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 5-day forecast
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                            vertical: 20,
                          ),
                      child: Column(
                        children: [
                          // Hourly forecast icons
                          _buildHourlyForecast(
                            textColor,
                          ),
                          const SizedBox(
                            height: 24,
                          ),

                          // Day tabs
                          _buildDayTabs(
                            textColor,
                          ),
                          const SizedBox(
                            height: 24,
                          ),

                          // Daily forecast list
                          if (_forecast
                              .isNotEmpty)
                            _buildDailyForecast(
                              textColor,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchWeatherData,
        backgroundColor: AppColors.primaryWhite
            .withOpacity(0.9),
        child: const Icon(
          Icons.add,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildHourlyForecast(Color textColor) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final hour = DateTime.now().add(
            Duration(hours: index * 3),
          );
          return Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                hour.hour == DateTime.now().hour
                    ? 'Now'
                    : '${hour.hour}',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(
                    0.7,
                  ),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              Icon(
                _getWeatherIcon(
                  _weather?.mainCondition,
                ),
                color: textColor.withOpacity(0.8),
                size: 24,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDayTabs(Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceEvenly,
        children: [
          _buildDayTab('Today', true, textColor),
          _buildDayTab(
            'Tomorrow',
            false,
            textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDayTab(
    String label,
    bool isActive,
    Color textColor,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: textColor.withOpacity(
              isActive ? 1.0 : 0.5,
            ),
            fontWeight: isActive
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        if (isActive)
          Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
              color: textColor,
              borderRadius: BorderRadius.circular(
                1,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDailyForecast(Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
      ),
      child: Column(
        children: _forecast.map((day) {
          final dayName = DateFormat(
            'EEEE',
          ).format(day.date);
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 13,
                      color: textColor
                          .withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  _getWeatherIcon(
                    day.mainCondition,
                  ),
                  color: textColor.withOpacity(
                    0.8,
                  ),
                  size: 20,
                ),
                SizedBox(
                  width: 60,
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    children: [
                      Text(
                        '${day.tempMax.round()}°',
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' -${day.tempMin.round()}°',
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor
                              .withOpacity(0.5),
                          fontWeight:
                              FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getWeatherIcon(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_outlined;
      case 'clouds':
        return Icons.cloud_outlined;
      case 'rain':
      case 'drizzle':
        return Icons.water_drop_outlined;
      case 'thunderstorm':
        return Icons.flash_on_outlined;
      case 'snow':
        return Icons.ac_unit;
      default:
        return Icons.wb_sunny_outlined;
    }
  }
}
