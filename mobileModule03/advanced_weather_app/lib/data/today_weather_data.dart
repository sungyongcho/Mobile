class TodayWeatherData {
  final List<String> date;
  final List<String> time;
  final List<double> temperature;
  final List<int> weatherCode;
  final List<double> windSpeed;

  TodayWeatherData({
    required this.date,
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.windSpeed,
  });

  // Factory constructor to parse the JSON response
  factory TodayWeatherData.fromJson(Map<String, dynamic> json) {
    final hourly = json['hourly'];

    final List<String> rawTimeList = List<String>.from(hourly['time'] ?? []);
    final List<String> dates = [];
    final List<String> times = [];

    for (var dateTime in rawTimeList) {
      final parts = dateTime.split('T');
      dates.add(parts[0]);
      times.add(parts[1]);
    }

    return TodayWeatherData(
      date: dates,
      time: times,
      temperature: List<double>.from(hourly['temperature_2m'] ?? []),
      weatherCode: List<int>.from(hourly['weather_code'] ?? []),
      windSpeed: List<double>.from(hourly['wind_speed_10m'] ?? []),
    );
  }
}
