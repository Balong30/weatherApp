import 'dart:ui';
import 'package:flutter/material.dart';
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
  // --- Constants ---
  static const String _apiKey =
      '291cef864197d525c10a970bd57d4006';
  static const int _forecastDays = 5;
  static const int _animDurationMs = 800;
  static const double _animBlurSigma = 8.0;
  static const double _cardBorderRadius = 16.0;
  static const double _forecardIconSize = 34.0;

  // --- Services & State ---
  final _weatherService = WeatherService(_apiKey);
  Weather? _weather;
  List<DailyForecast> _forecast = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  // --- Animations ---
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _fetchWeatherData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // --- Initialization & Logic ---

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
      final lat = position.latitude;
      final lon = position.longitude;

      // Fetch weather and forecast in parallel
      final weather = await _weatherService
          .getWeatherByCoords(lat, lon);
      final forecast = await _weatherService
          .getForecastByCoords(lat, lon);

      if (!mounted) return;

      setState(() {
        _weather = weather;
        _forecast = _filterForecast(forecast);
        _isLoading = false;
      });

      _animController.forward();
    } catch (e) {
      if (mounted)
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
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

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

  // --- UI Components ---

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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(textColor),
        bottomNavigationBar: _buildNavigationBar(
          textColor,
          gradientColors,
        ),
        body: SafeArea(
          child: _isLoading
              ? _buildLoadingState()
              : _buildWeatherContent(textColor),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    Color textColor,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: textColor),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.menu,
            color: AppColors.primaryWhite,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _forecast
                      .map(
                        (day) =>
                            _buildForecastDay(
                              day,
                              textColor,
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

  Widget _buildForecastDay(
    DailyForecast dayWeather,
    Color textColor,
  ) {
    final dayLabel = DateFormat(
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
            dayLabel,
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

  Widget _buildNavigationBar(
    Color textColor,
    List<Color> gradientColors,
  ) {
    // Get a vibrant accent color from the gradient
    final accentColor = gradientColors.first;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(
                  0.1,
                ),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Home',
                    index: 0,
                    textColor: textColor,
                    accentColor: accentColor,
                  ),
                  _buildNavItem(
                    icon: Icons.search_outlined,
                    activeIcon: Icons.search,
                    label: 'Search',
                    index: 1,
                    textColor: textColor,
                    accentColor: accentColor,
                  ),
                  _buildNavItem(
                    icon: Icons
                        .location_on_outlined,
                    activeIcon: Icons.location_on,
                    label: 'Locations',
                    index: 2,
                    textColor: textColor,
                    accentColor: accentColor,
                  ),
                  _buildNavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    label: 'Settings',
                    index: 3,
                    textColor: textColor,
                    accentColor: accentColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required Color textColor,
    required Color accentColor,
  }) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: isSelected
            ? BoxDecoration(
                borderRadius:
                    BorderRadius.circular(12),
                color: accentColor.withOpacity(
                  0.15,
                ),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? accentColor
                  : textColor.withOpacity(0.4),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? accentColor
                    : textColor.withOpacity(0.4),
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
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
        return 'lib/assets/partly_shower.json';
      case 'thunderstorm':
        return 'lib/assets/storm.json';
      case 'clear':
        return 'lib/assets/sunny.json';
      default:
        return 'lib/assets/sunny.json';
    }
  }
}
