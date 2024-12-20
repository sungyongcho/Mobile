import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:medium_weather_app/data/current_weather_data.dart';
import 'package:medium_weather_app/data/today_weather_data.dart';
import 'package:medium_weather_app/data/weekly_weather_data.dart';

class WeatherService {
  final Map _weatherMap = {
    0: 'Sunny',
    1: 'Mainly Clear',
    2: 'Partly Sunny',
    3: 'Overcast',
    45: 'Foggy',
    48: 'Foggy',
    51: 'Light Drizzle',
    53: 'Moderate Drizzle',
    55: 'Dense Drizzle',
    56: 'Light Freezing Drizzle',
    57: 'Dense Freezing Drizzle',
    61: 'Slightly Rainy',
    63: 'Moderately Rainy',
    65: 'Heavily Rainy',
    66: 'Light Freezing Rainy',
    67: 'Heavy Freezing Rainy',
    71: 'Slightly Snowy',
    73: 'Moderately Snowy',
    75: 'Heavily Snowy',
    77: 'Snowy',
    80: 'Slight Rain Shower',
    81: 'Moderate Rain Shower',
    82: 'Violent Rain Shower',
    85: 'Slight Snow Shower',
    86: 'Violent Snow Shower',
    95: 'Slight Thunderstorm',
    96: 'Thunderstorm with slight hail',
    99: 'Thunderstorm with heavy hail'
  };

  Future<CurrentWeatherData> fetchCurrentWeatherData(
      double latitude, double longitude) async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,weather_code,wind_speed_10m';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['current'] != null) {
        return CurrentWeatherData(
          latitude: data['latitude'],
          longitude: data['longitude'],
          temperature: data['current']['temperature_2m'],
          weather: _weatherMap[data['current']['weather_code']],
          windSpeed: data['current']['wind_speed_10m'],
        );
      } else {
        throw Exception(
            'Weather data not available for the selected location.');
      }
    } else {
      throw Exception(
          'The service connection is lost. please check your internet connection or try again later.');
    }
  }

  Future<TodayWeatherData> fetchTodayWeatherData(
      double latitude, double longitude) async {
    final todayUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,weather_code,wind_speed_10m&forecast_days=1';
    final response = await http.get(Uri.parse(todayUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['hourly'] != null) {
        return TodayWeatherData.fromJson(data);
      } else {
        throw Exception(
            'Weather data not available for the selected location.');
      }
    } else {
      throw Exception(
          "The service connection is lost, please check your internet connection or try again later");
    }
  }

  Future<WeeklyWeatherData> fetchWeeklyWeatherData(
      double latitude, double longitude) async {
    final weeklyUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&daily=weathercode,temperature_2m_max,temperature_2m_min';
    final response = await http.get(Uri.parse(weeklyUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['daily'] != null) {
        // Map weather codes to their descriptions
        final List<int> rawWeatherCodes =
            List<int>.from(data['daily']['weathercode']?.cast<int>() ?? []);
        final List<String> mappedWeatherDescriptions = rawWeatherCodes
            .map((code) => _weatherMap[code]?.toString() ?? 'Unknown')
            .toList();

        return WeeklyWeatherData.fromJson(
          data,
          weatherDescriptions:
              mappedWeatherDescriptions, // Pass mapped descriptions
        );
      } else {
        throw Exception(
            'Weather data not available for the selected location.');
      }
    } else {
      throw Exception(
          "The service connection is lost, please check your internet connection or try again later");
    }
  }
}
