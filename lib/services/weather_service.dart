import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/models/forecast_model.dart';
import 'package:http/http.dart' as http;

/// Handles all communication with the OpenWeatherMap API.
class WeatherService {
  static const BASE_URL =
      'http://api.openweathermap.org/data/2.5/weather';
  static const FORECAST_URL =
      'http://api.openweathermap.org/data/2.5/forecast';

  final String apiKey;

  WeatherService(this.apiKey);

  /// Retrieves current weather data for given coordinates
  Future<Weather> getWeatherByCoords(
    double lat,
    double lon,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$BASE_URL?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
      ),
    );

    if (response.statusCode == 200) {
      return Weather.fromJson(
        jsonDecode(response.body),
      );
    } else {
      throw Exception(
        'Failed to load weather data',
      );
    }
  }

  /// Retrieves 5-day forecast data for given coordinates
  Future<List<DailyForecast>> getForecastByCoords(
    double lat,
    double lon,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$FORECAST_URL?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> forecastList =
          data['list'];

      // Convert to ForecastEntry objects
      final entries = forecastList
          .map(
            (json) =>
                ForecastEntry.fromJson(json),
          )
          .toList();

      // Aggregate into daily forecasts
      return DailyForecast.fromForecastList(
        entries,
      );
    } else {
      throw Exception(
        'Failed to load forecast data',
      );
    }
  }

  /// Retrieves the current city name using device GPS
  Future<String> getCurrentCity() async {
    LocationPermission permission =
        await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    LocationSettings locationSettings =
        LocationSettings(
          accuracy:
              LocationAccuracy.bestForNavigation,
        );

    Position position =
        await Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        );

    List<Placemark> placemarks =
        await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

    String? city = placemarks[0].locality;
    return city ?? "";
  }
}
