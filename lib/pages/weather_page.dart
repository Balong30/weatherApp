import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/models/weather_model.dart';

/// The main screen that displays weather information for the user's current location.
class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() =>
      _WeatherPageState();
}

class _WeatherPageState
    extends State<WeatherPage> {
  // Service responsible for fetching weather data from the API.
  final _weatherService = WeatherService(
    '291cef864197d525c10a970bd57d4006', // OpenWeatherMap API key (keep it secure in production)
  );

  // Holds the currently loaded weather data, or null if not yet loaded.
  Weather? _weather;

  /// Fetches the user's current location and then retrieves weather data for that location.
  /// Updates the UI with the result or prints an error if something fails.
  _fetchWeather() async {
    try {
      // Step 1: Check location permissions
      LocationPermission permission =
          await Geolocator.checkPermission();

      // If permission is not granted, request it
      if (permission ==
          LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      // If permission is denied permanently or still denied, throw an exception
      if (permission ==
              LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        throw Exception(
          "Location permission denied",
        );
      }

      // Step 2: Get the current position (latitude and longitude)
      Position
      position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy
              .high, // Use high accuracy for better results
        ),
      );

      // Step 3: Fetch weather data using coordinates
      final weather = await _weatherService
          .getWeatherByCoords(
            position.latitude,
            position.longitude,
          );

      // Step 4: Update the UI with the new weather data
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      // Log any errors (in a real app you might show a user-friendly message)
      print("ERROR: $e");
    }
  }

  /// Returns the Lottie animation asset path based on the weather condition.
  /// This allows showing a different animation for each weather type.
  String getWeatherAnimation(
    String? mainCondition,
  ) {
    // Switch on the lowercased condition, handling null gracefully.
    switch (mainCondition?.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'lib/assets/cloudy.json'; // Animation for cloudy/foggy conditions
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'lib/assets/rain.json'; // Animation for rainy conditions
      case 'thunderstorm':
        return 'lib/assets/storm.json'; // Animation for thunderstorms
      case 'clear':
        return 'lib/assets/sunny.json'; // Animation for clear skies
      default:
        return 'lib/assets/sunny.json'; // Default fallback animation
    }
  }

  @override
  void initState() {
    super.initState();
    // Start fetching weather as soon as the screen is created.
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            // Display the city name, or a loading text while data is being fetched
            Text(
              _weather?.cityName ??
                  "loading city..",
              style: const TextStyle(
                fontSize: 24,
              ),
            ),
            // Lottie animation based on the current weather condition
            Lottie.asset(
              getWeatherAnimation(
                _weather?.mainCondition,
              ),
              width:
                  200, // Optional: set a fixed size
              height: 200,
            ),
            // Temperature in Celsius, rounded to nearest integer
            Text(
              '${_weather?.temperature.round()}°C',
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            // Text description of the weather condition (e.g., "Clear", "Rain")
            Text(
              _weather?.mainCondition ?? "",
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
