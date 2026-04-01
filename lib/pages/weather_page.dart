import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/theme/app_colors.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() =>
      _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage>
    with SingleTickerProviderStateMixin {
  final _weatherService = WeatherService(
    '291cef864197d525c10a970bd57d4006',
  );

  Weather? _weather;
  bool _isLoading = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

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
            locationSettings:
                const LocationSettings(
                  accuracy: LocationAccuracy.high,
                ),
          );

      final weather = await _weatherService
          .getWeatherByCoords(
            position.latitude,
            position.longitude,
          );

      setState(() {
        _weather = weather;
        _isLoading = false;
      });

      _animController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
    }
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
              ? Center(
                  child:
                      CircularProgressIndicator(
                        color: AppColors
                            .primaryWhite,
                      ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      /// CITY + ICON
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          Text(
                            _weather?.cityName
                                    .toUpperCase() ??
                                '',
                            style: TextStyle(
                              fontSize: 18,
                              color: textColor
                                  .withOpacity(
                                    0.7,
                                  ),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Lottie.asset(
                            _getWeatherAnimation(
                              _weather
                                  ?.mainCondition,
                            ),
                            width: 100,
                            height: 100,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// TEMP
                      Text(
                        '${_weather?.temperature.round() ?? 0}°',
                        style: TextStyle(
                          fontSize: 42,
                          color: textColor,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// CONDITION
                      Text(
                        _weather?.mainCondition ??
                            '',
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor
                              .withOpacity(0.7),
                        ),
                      ),

                      const SizedBox(height: 20),
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: Center(
                          // important: centers the smaller card
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(
                                  16,
                                ),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(
                                    sigmaX: 8,
                                    sigmaY: 8,
                                  ),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal:
                                          8, // small side padding
                                    ),
                                decoration: BoxDecoration(
                                  color: Colors
                                      .white
                                      .withOpacity(
                                        0.07,
                                      ),
                                  borderRadius:
                                      BorderRadius.circular(
                                        16,
                                      ),
                                  border: Border.all(
                                    color: Colors
                                        .white
                                        .withOpacity(
                                          0.12,
                                        ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize
                                          .min, // 🔥 KEY: shrink to content
                                  children: List.generate(5, (
                                    index,
                                  ) {
                                    final date =
                                        DateTime.now().add(
                                          Duration(
                                            days:
                                                index,
                                          ),
                                        );
                                    final day =
                                        DateFormat(
                                          'E',
                                        ).format(
                                          date,
                                        );

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal:
                                            6,
                                      ), // tight spacing
                                      child: Column(
                                        mainAxisSize:
                                            MainAxisSize
                                                .min,
                                        children: [
                                          Text(
                                            day,
                                            style: TextStyle(
                                              color: textColor.withOpacity(
                                                0.7,
                                              ),
                                              fontSize:
                                                  11,
                                            ),
                                          ),
                                          const SizedBox(
                                            height:
                                                2,
                                          ),
                                          Lottie.asset(
                                            'lib/assets/sunny.json',
                                            width:
                                                34,
                                            height:
                                                34,
                                          ),
                                          const SizedBox(
                                            height:
                                                2,
                                          ),
                                          Text(
                                            '${30 + index}°',
                                            style: TextStyle(
                                              color:
                                                  textColor,
                                              fontSize:
                                                  11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
