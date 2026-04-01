import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:http/http.dart' as http;

/// Handles all communication with the OpenWeatherMap API.
/// Provides methods to fetch weather data by coordinates and to get the current city name.
class WeatherService {
  static const BASE_URL =
      'http://api.openweathermap.org/data/2.5/weather'; // API endpoint

  final String
  apiKey; // API key required for authentication

  WeatherService(this.apiKey);

  /// Retrieves weather data for the given latitude and longitude.
  ///
  /// - [lat]: Latitude of the location
  /// - [lon]: Longitude of the location
  /// Returns a [Weather] object if successful, otherwise throws an exception.
  Future<Weather> getWeatherByCoords(
    double lat,
    double lon,
  ) async {
    // Build the complete URL with query parameters: lat, lon, appid, units (metric for Celsius)
    final response = await http.get(
      Uri.parse(
        '$BASE_URL?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
      ),
    );

    // Log the raw JSON response for debugging purposes
    print(response.body);

    // If the request succeeded (HTTP 200), parse the JSON into a Weather object
    if (response.statusCode == 200) {
      return Weather.fromJson(
        jsonDecode(response.body),
      );
    } else {
      // If something went wrong (e.g., invalid API key, network issue), throw an error
      throw Exception(
        'Failed to load weather data',
      );
    }
  }

  /// Retrieves the name of the city where the user is currently located.
  ///
  /// Uses the device's GPS to get coordinates, then performs reverse geocoding.
  /// Returns the city name as a string, or an empty string if it cannot be determined.
  Future<String> getCurrentCity() async {
    // Check location permissions (same as in WeatherPage)
    LocationPermission permission =
        await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    // Configure location settings: high accuracy and a distance filter of 100 meters
    LocationSettings locationSettings =
        LocationSettings(
          accuracy:
              LocationAccuracy.bestForNavigation,
        );

    // Get the current position
    Position position =
        await Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        );

    // Reverse geocode the coordinates to obtain a list of placemarks
    List<Placemark> placemarks =
        await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

    // Extract the locality (city) from the first placemark
    String? city = placemarks[0].locality;

    // Return the city name or an empty string if none found
    return city ?? "";
  }
}
