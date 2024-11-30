import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:advanced_weather_app/data/weekly_weather_data.dart';
import 'package:advanced_weather_app/data/location_data.dart';
import 'package:advanced_weather_app/services/weather_service.dart';

class WeeklyWeatherWidget extends StatelessWidget {
  final LocationData? locationData;
  final WeeklyWeatherData? weeklyWeatherData;
  final WeatherService weatherService;

  const WeeklyWeatherWidget({
    super.key,
    required this.locationData,
    required this.weeklyWeatherData,
    required this.weatherService,
  });

  @override
  Widget build(BuildContext context) {
    if (weeklyWeatherData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(locationData?.city ?? 'N/A', style: _cityTextStyle),
          Text(
            '${locationData?.region}, ${locationData?.country}' ?? 'N/A',
            style: _textStyle,
          ),
          ...weeklyWeatherData!.time.asMap().entries.map((entry) {
            final index = entry.key;
            final time = entry.value;
            final temperatureMin = weeklyWeatherData!.temperatureMin[index];
            final temperatureMax = weeklyWeatherData!.temperatureMax[index];
            final weatherDescription =
                weeklyWeatherData!.weatherDescriptions[index];

            return Text(
              '$time  $temperatureMin°C $temperatureMax  $weatherDescription',
              // style: _todayWeatherListStyle,
            );
          }).toList(),
        ],
      ),
    );
  }

  TextStyle get _textStyle => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  TextStyle get _cityTextStyle => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.amber[800],
      );
}
