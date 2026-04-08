import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/models/forecast_model.dart';
import 'package:weather_app/theme/app_colors.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() =>
      _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage>
    with SingleTickerProviderStateMixin {
  static const String _apiKey =
      '291cef864197d525c10a970bd57d4006';
  static const int _forecastDays = 5;
  static const int _animDurationMs = 800;
  static const double _animBlurSigma = 8.0;
  static const double _cardBorderRadius = 16.0;
  static const double _forecardIconSize = 34.0;

  final _weatherService = WeatherService(_apiKey);

  Weather? _weather;
  List<DailyForecast> _forecast = [];
  bool _isLoading = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _fetchWeatherData();
  }

  void _setupAnimation() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: _animDurationMs,
      ),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
  }

  Future<void> _fetchWeatherData() async {
    try {
      setState(() => _isLoading = true);
      await _checkLocationPermission();

      final position =
          await _getCurrentPosition();

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
        _forecast = _filterForecast(forecast);
        _isLoading = false;
      });

      _animController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission ==
            LocationPermission.deniedForever) {
      throw Exception(
        'Location permission denied',
      );
    }
  }

  Future<Position> _getCurrentPosition() async {
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Filters forecast to exclude today and return the next 5 days
  List<DailyForecast> _filterForecast(
    List<DailyForecast> forecast,
  ) {
    final today = DateTime.now();
    final todayDate = DateTime(
      today.year,
      today.month,
      today.day,
    );

    return forecast
        .where((daily) {
          final dailyDate = DateTime(
            daily.date.year,
            daily.date.month,
            daily.date.day,
          );
          return dailyDate.isAfter(todayDate);
        })
        .take(_forecastDays)
        .toList();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
              ? _buildLoadingState()
              : _buildWeatherContent(textColor),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryWhite,
      ),
    );
  }

  Widget _buildWeatherContent(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          _buildCityAndIcon(textColor),
          const SizedBox(height: 10),
          _buildTemperature(textColor),
          const SizedBox(height: 6),
          _buildWeatherCondition(textColor),
          const SizedBox(height: 20),
          _buildForecastCard(textColor),
        ],
      ),
    );
  }

  Widget _buildCityAndIcon(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _weather?.cityName.toUpperCase() ?? '',
          style: TextStyle(
            fontSize: 18,
            color: textColor.withOpacity(0.7),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 12),
        Lottie.asset(
          _getWeatherAnimation(
            _weather?.mainCondition,
          ),
          width: 100,
          height: 100,
        ),
      ],
    );
  }

  Widget _buildTemperature(Color textColor) {
    return Text(
      '${_weather?.temperature.round() ?? 0}°',
      style: TextStyle(
        fontSize: 42,
        color: textColor,
      ),
    );
  }

  Widget _buildWeatherCondition(Color textColor) {
    return Text(
      _weather?.mainCondition ?? '',
      style: TextStyle(
        fontSize: 16,
        color: textColor.withOpacity(0.7),
      ),
    );
  }

  Widget _buildForecastCard(Color textColor) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            _cardBorderRadius,
          ),
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
                color: Colors.white.withOpacity(
                  0.07,
                ),
                borderRadius:
                    BorderRadius.circular(
                      _cardBorderRadius,
                    ),
                border: Border.all(
                  color: Colors.white.withOpacity(
                    0.12,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _forecast
                    .map(
                      (dayWeather) =>
                          _buildForecastDay(
                            dayWeather,
                            textColor,
                          ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForecastDay(
    DailyForecast dayWeather,
    Color textColor,
  ) {
    final day = DateFormat(
      'E',
    ).format(dayWeather.date);

    final avgTemp =
        ((dayWeather.tempMin +
            dayWeather.tempMax) /
        2);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            day,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Lottie.asset(
            _getWeatherAnimation(
              dayWeather.mainCondition,
            ),
            width: _forecardIconSize,
            height: _forecardIconSize,
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

  String _getWeatherAnimation(
    String? mainCondition,
  ) {
    switch (mainCondition?.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'lib/assets/cloudy.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'lib/assets/rain.json';
      case 'thunderstorm':
        return 'lib/assets/storm.json';
      case 'clear':
        return 'lib/assets/sunny.json';
      default:
        return 'lib/assets/sunny.json';
    }
  }
}
