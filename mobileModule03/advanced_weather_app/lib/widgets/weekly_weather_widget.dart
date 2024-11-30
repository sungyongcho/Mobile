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

    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveFontSize = screenWidth * 0.04;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(locationData?.city ?? 'N/A',
              style: _cityTextStyle.copyWith(fontSize: responsiveFontSize)),
          Text(
            '${locationData?.region}, ${locationData?.country}' ?? 'N/A',
            style: _textStyle.copyWith(fontSize: responsiveFontSize),
          ),
          const SizedBox(height: 50),
          _buildHourlyWeatherList(context, responsiveFontSize)
          // ...weeklyWeatherData!.time.asMap().entries.map((entry) {
          //   final index = entry.key;
          //   final time = entry.value;
          //   final temperatureMin = weeklyWeatherData!.temperatureMin[index];
          //   final temperatureMax = weeklyWeatherData!.temperatureMax[index];
          //   final weatherDescription =
          //       weeklyWeatherData!.weatherDescriptions[index];

          //   return Text(
          //     '$time  $temperatureMin°C $temperatureMax  $weatherDescription',
          //     // style: _todayWeatherListStyle,
          //   );
          // }).toList(),
        ],
      ),
    );
  }

  Widget _buildHourlyWeatherList(BuildContext context, double fontSize) {
    double screenHeight = MediaQuery.of(context).size.height;
    double listHeight = screenHeight * 0.15; // Adjust the percentage as needed

    return SizedBox(
      height: listHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weeklyWeatherData!.time.length,
        itemBuilder: (context, index) {
          final time = weeklyWeatherData!.time[index];
          final temperatureMin = weeklyWeatherData!.temperatureMin[index];
          final temperatureMax = weeklyWeatherData!.temperatureMax[index];
          final weather = weeklyWeatherData!.weatherDescriptions[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize * 0.6,
                  ),
                ),
                const SizedBox(height: 12),
                Icon(
                  weatherService.getWeatherIcon(weather),
                  color: Colors.yellow[800],
                  size: fontSize * 1.2, // Adjust icon size proportionally
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${temperatureMin.toStringAsFixed(1)}°C ',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize * 0.6,
                        ),
                      ),
                      TextSpan(
                        text: 'min',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.normal,
                          fontSize:
                              fontSize * 0.4, // Smaller font size for 'min'
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${temperatureMax.toStringAsFixed(1)}°C ',
                        style: TextStyle(
                          color: Colors.green[900],
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize * 0.6,
                        ),
                      ),
                      TextSpan(
                        text: 'max',
                        style: TextStyle(
                          color: Colors.green[900],
                          fontWeight: FontWeight.normal,
                          fontSize:
                              fontSize * 0.4, // Smaller font size for 'max'
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
