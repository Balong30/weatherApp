import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/models/forecast_model.dart';
import 'package:http/http.dart' as http;

/// Handles all communication with the OpenWeatherMap API.
class WeatherService {
  static const String _baseUrl =
      'http://api.openweathermap.org/data/2.5/weather';
  static const String _forecastUrl =
      'http://api.openweathermap.org/data/2.5/forecast';
  static const String _units = 'metric';

  final String apiKey;

  WeatherService(this.apiKey);

  /// Retrieves current weather data for given coordinates
  Future<Weather> getWeatherByCoords(
    double lat,
    double lon,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl?lat=$lat&lon=$lon&appid=$apiKey&units=$_units',
        ),
      );

      if (response.statusCode == 200) {
        return Weather.fromJson(
          jsonDecode(response.body),
        );
      }
      throw Exception(
        'Failed to load weather data: ${response.statusCode}',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves 5-day forecast data for given coordinates
  Future<List<DailyForecast>> getForecastByCoords(
    double lat,
    double lon,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_forecastUrl?lat=$lat&lon=$lon&appid=$apiKey&units=$_units',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> forecastList =
            data['list'];

        final entries = forecastList
            .map(
              (json) =>
                  ForecastEntry.fromJson(json),
            )
            .toList();

        return DailyForecast.fromForecastList(
          entries,
        );
      }
      throw Exception(
        'Failed to load forecast data: ${response.statusCode}',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves the current city name using device GPS
  Future<String> getCurrentCity() async {
    try {
      LocationPermission permission =
          await Geolocator.checkPermission();
      if (permission ==
          LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      final locationSettings = LocationSettings(
        accuracy:
            LocationAccuracy.bestForNavigation,
      );

      final position =
          await Geolocator.getCurrentPosition(
            locationSettings: locationSettings,
          );

      final placemarks =
          await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );

      return placemarks.first.locality ?? '';
    } catch (e) {
      rethrow;
    }
  }
}
