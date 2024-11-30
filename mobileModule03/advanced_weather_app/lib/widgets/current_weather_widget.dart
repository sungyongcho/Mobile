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

    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive font sizes
    final baseFontSize = screenWidth * 0.05; // Adjust as needed
    final largeFontSize = screenWidth * 0.12; // Adjust as needed

    // Icon size
    final iconSize = screenWidth * 0.2; // Adjust as needed

    // Spacing sizes
    final spacingLarge = screenHeight * 0.05; // Adjust as needed
    final spacingMedium = screenHeight * 0.03; // Adjust as needed
    final spacingSmall = screenHeight * 0.02; // Adjust as needed

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight *
              0.9, // Use 90% of screen height to prevent overflow
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              locationData?.city ?? 'N/A',
              style: _cityTextStyle.copyWith(fontSize: baseFontSize),
              textAlign: TextAlign.center,
            ),
            Text(
              '${locationData?.region}, ${locationData?.country}' ?? 'N/A',
              style: _textStyle.copyWith(fontSize: baseFontSize),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacingLarge),
            Text(
              '${currentWeatherData?.temperature ?? 'N/A'}°C',
              style:
                  TextStyle(fontSize: largeFontSize, color: Colors.yellow[800]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacingLarge),
            Text(
              '${currentWeatherData?.weather ?? 'N/A'}',
              style: TextStyle(fontSize: baseFontSize, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacingMedium),
            Icon(
              weatherService.getWeatherIcon(currentWeatherData?.weather),
              size: iconSize,
              color: Colors.yellow[800],
            ),
            SizedBox(height: spacingMedium),
            Row(
              mainAxisSize: MainAxisSize.min, // Center the row contents
              children: [
                Icon(
                  Icons.air,
                  color: Colors.yellow[800],
                  size: baseFontSize * 1.5,
                ),
                SizedBox(width: screenWidth * 0.02), // Adjust spacing
                Text(
                  '${currentWeatherData?.windSpeed ?? 'N/A'} km/h',
                  style: _textStyle.copyWith(fontSize: baseFontSize),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _textStyle => TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  TextStyle get _cityTextStyle => TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.amber[800],
      );
}
