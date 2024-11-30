class TodayWeatherData {
  final List<String> date;
  final List<String> time;
  final List<double> temperature;
  final List<String> weather; // Changed to List<String>
  final List<double> windSpeed;

  TodayWeatherData({
    required this.date,
    required this.time,
    required this.temperature,
    required this.weather, // Changed to String
    required this.windSpeed,
  });

  // Factory constructor to parse the JSON response
  factory TodayWeatherData.fromJson(
      Map<String, dynamic> json, Map<int, String> weatherMap) {
    final hourly = json['hourly'];

    final List<String> rawTimeList = List<String>.from(hourly['time'] ?? []);
    final List<String> dates = [];
    final List<String> times = [];

    for (var dateTime in rawTimeList) {
      final parts = dateTime.split('T');
      dates.add(parts[0]);
      times.add(parts[1]);
    }

    final List<int> rawWeatherCodes =
        List<int>.from(hourly['weather_code'] ?? []);
    final List<String> mappedWeatherDescriptions = rawWeatherCodes
        .map((code) =>
            weatherMap[code] ?? 'Unknown') // Map weather codes to descriptions
        .toList();

    return TodayWeatherData(
      date: dates,
      time: times,
      temperature: List<double>.from(hourly['temperature_2m'] ?? []),
      weather: mappedWeatherDescriptions, // Use the mapped descriptions
      windSpeed: List<double>.from(hourly['wind_speed_10m'] ?? []),
    );
  }
}
