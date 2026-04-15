import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/models/forecast_model.dart';
import 'package:weather_app/theme/app_colors.dart';
import 'package:weather_app/widgets/weather_app_bar.dart';
import 'package:weather_app/widgets/loading_indicator.dart';
import 'package:weather_app/widgets/city_weather_header.dart';
import 'package:weather_app/widgets/temperature_display.dart';
import 'package:weather_app/widgets/weather_condition_text.dart';
import 'package:weather_app/widgets/forecast_card.dart';
import 'package:weather_app/widgets/weather_bottom_nav.dart';

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

  // 🔥 SWITCH: true = static data, false = API
  static const bool useMockData = true;

  // --- Services & State ---
  final _weatherService = WeatherService(_apiKey);
  Weather? _weather;
  List<DailyForecast> _forecast = [];
  bool _isLoading = true;
  int _currentNavIndex = 0;

  // --- Animations ---
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _setupAnimation();

    if (useMockData) {
      _loadMockData(); // ✅ STATIC DATA HERE
    } else {
      _fetchWeatherData();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // --- Animation Setup ---
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

  // ================================
  // ✅ MOCK DATA (EDIT HERE FOR TESTING)
  // ================================
  void _loadMockData() {
    setState(() {
      _weather = Weather(
        cityName: "Manila",
        temperature: 30,

        // 🔥🔥 CHANGE THIS VALUE TO TEST ICONS 🔥🔥
        // Examples:
        // "Clear", "Clouds", "Rain", "Thunderstorm", "Snow", "Drizzle", "Mist"
        mainCondition: "Storm",
      );

      _isLoading = false;
    });

    _animController.forward();
  }

  // --- API Fetch (unchanged) ---
  Future<void> _fetchWeatherData() async {
    try {
      setState(() => _isLoading = true);
      await _checkLocationPermission();

      final position =
          await _getCurrentPosition();
      final lat = position.latitude;
      final lon = position.longitude;

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

  void _onNavIndexChanged(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  // --- UI ---
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
        appBar: WeatherAppBar(
          textColor: textColor,
        ),
        body: SafeArea(
          child: _isLoading
              ? const LoadingIndicator()
              : _buildWeatherContent(textColor),
        ),
        bottomNavigationBar: WeatherBottomNav(
          textColor: textColor,
          gradientColors: gradientColors,
          onIndexChanged: _onNavIndexChanged,
          initialIndex: _currentNavIndex,
        ),
      ),
    );
  }

  Widget _buildWeatherContent(Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          CityWeatherHeader(
            cityName: _weather?.cityName ?? '',
            mainCondition:
                _weather?.mainCondition,
            textColor: textColor,
          ),
          const SizedBox(height: 10),
          TemperatureDisplay(
            temperature:
                _weather?.temperature ?? 0,
            textColor: textColor,
          ),
          const SizedBox(height: 6),
          WeatherConditionText(
            condition:
                _weather?.mainCondition ?? '',
            textColor: textColor,
          ),
          const SizedBox(height: 20),
          ForecastCard(
            forecast: _forecast,
            fadeAnimation: _fadeAnim,
            textColor: textColor,
          ),
        ],
      ),
    );
  }
}
