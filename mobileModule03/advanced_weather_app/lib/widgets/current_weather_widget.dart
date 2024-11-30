import 'package:flutter/material.dart';
import 'package:advanced_weather_app/data/current_weather_data.dart';
import 'package:advanced_weather_app/data/location_data.dart';
import 'package:advanced_weather_app/services/weather_service.dart';

class CurrentWeatherWidget extends StatelessWidget {
  final LocationData? locationData;
  final CurrentWeatherData? currentWeatherData;
  final WeatherService weatherService;

  const CurrentWeatherWidget({
    super.key,
    required this.locationData,
    required this.currentWeatherData,
    required this.weatherService,
  });

  @override
  Widget build(BuildContext context) {
    if (currentWeatherData == null) {
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
          const SizedBox(height: 40),
          Text(
            '${currentWeatherData?.temperature ?? 'N/A'}°C',
            style: TextStyle(fontSize: 48, color: Colors.yellow[800]),
          ),
          const SizedBox(height: 40),
          Text(
            '${currentWeatherData?.weather ?? 'N/A'}',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Icon(
            weatherService.getWeatherIcon(currentWeatherData?.weather),
            size: 64,
            color: Colors.yellow[800],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.air,
                color: Colors.yellow[800],
                size: 24,
              ),
              const SizedBox(width: 8), // Add spacing
              Text(
                '${currentWeatherData?.windSpeed ?? 'N/A'} km/h',
                style: _textStyle,
              ),
            ],
          ),
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
