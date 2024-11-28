class WeeklyWeatherData {
  final List<String> time;
  final List<String> weatherDescriptions; // Mapped weather descriptions
  final List<double> temperatureMax;
  final List<double> temperatureMin;

  WeeklyWeatherData({
    required this.time,
    required this.weatherDescriptions,
    required this.temperatureMax,
    required this.temperatureMin,
  });

  // Factory constructor to parse the JSON response
  factory WeeklyWeatherData.fromJson(
    Map<String, dynamic> json, {
    required List<String> weatherDescriptions,
  }) {
    final daily = json['daily'];
    return WeeklyWeatherData(
      time: List<String>.from(daily['time'] ?? []),
      weatherDescriptions: weatherDescriptions,
      temperatureMax: List<double>.from(daily['temperature_2m_max'] ?? []),
      temperatureMin: List<double>.from(daily['temperature_2m_min'] ?? []),
    );
  }
}
