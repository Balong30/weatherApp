/// Represents a single forecast entry (3-hour interval)
class ForecastEntry {
  final DateTime dateTime;
  final double temperature;
  final double tempMin;
  final double tempMax;
  final String mainCondition;
  final String description;

  ForecastEntry({
    required this.dateTime,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    required this.mainCondition,
    required this.description,
  });

  factory ForecastEntry.fromJson(
    Map<String, dynamic> json,
  ) {
    return ForecastEntry(
      dateTime:
          DateTime.fromMillisecondsSinceEpoch(
            json['dt'] * 1000,
          ),
      temperature: json['main']['temp']
          .toDouble(),
      tempMin: json['main']['temp_min']
          .toDouble(),
      tempMax: json['main']['temp_max']
          .toDouble(),
      mainCondition: json['weather'][0]['main'],
      description:
          json['weather'][0]['description'],
    );
  }
}

/// Represents daily aggregated forecast data
class DailyForecast {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String mainCondition;
  final String description;

  DailyForecast({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.mainCondition,
    required this.description,
  });

  /// Aggregates 3-hour forecasts into daily forecasts
  static List<DailyForecast> fromForecastList(
    List<ForecastEntry> entries,
  ) {
    Map<String, List<ForecastEntry>> dailyMap =
        {};

    // Group entries by day
    for (var entry in entries) {
      final dateKey =
          '${entry.dateTime.year}-${entry.dateTime.month}-${entry.dateTime.day}';
      dailyMap
          .putIfAbsent(dateKey, () => [])
          .add(entry);
    }

    // Create daily forecasts from grouped entries
    List<DailyForecast> dailyForecasts = [];
    dailyMap.forEach((dateKey, dayEntries) {
      if (dayEntries.isEmpty) return;

      final minTemp = dayEntries
          .map((e) => e.tempMin)
          .reduce((a, b) => a < b ? a : b);
      final maxTemp = dayEntries
          .map((e) => e.tempMax)
          .reduce((a, b) => a > b ? a : b);

      // Use the most common condition for the day
      final conditions = dayEntries
          .map((e) => e.mainCondition)
          .toList();
      final mainCondition = _getMostFrequent(
        conditions,
      );

      dailyForecasts.add(
        DailyForecast(
          date: dayEntries.first.dateTime,
          tempMin: minTemp,
          tempMax: maxTemp,
          mainCondition: mainCondition,
          description:
              dayEntries.first.description,
        ),
      );
    });

    return dailyForecasts
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Helper to find most frequent item in list
  static String _getMostFrequent(
    List<String> items,
  ) {
    if (items.isEmpty) return '';

    Map<String, int> frequency = {};
    for (var item in items) {
      frequency[item] =
          (frequency[item] ?? 0) + 1;
    }

    return frequency.entries
        .reduce(
          (a, b) => a.value > b.value ? a : b,
        )
        .key;
  }
}
