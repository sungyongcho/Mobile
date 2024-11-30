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
          _buildDailyTemperatureGraph(context),
          const SizedBox(height: 50),
          _buildHourlyWeatherList(context, responsiveFontSize),
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

  Widget _buildLegend() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                Icons.circle, // Use a circular icon
                size: 10,
                color: Colors.green, // Color for Min temperature
              ),
              SizedBox(width: 4),
              Text(
                "Min temperature",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(width: 16), // Spacing between the legends
          Row(
            children: [
              Icon(
                Icons.circle, // Use a circular icon
                size: 10,
                color: Colors.red, // Color for Max temperature
              ),
              SizedBox(width: 4),
              Text(
                "Max temperature",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTemperatureGraph(BuildContext context) {
    final spotsMin = weeklyWeatherData!.time.asMap().entries.map((entry) {
      final index = entry.key;
      return FlSpot(
        index.toDouble(),
        weeklyWeatherData!.temperatureMin[index],
      );
    }).toList();

    final spotsMax = weeklyWeatherData!.time.asMap().entries.map((entry) {
      final index = entry.key;
      return FlSpot(
        index.toDouble(),
        weeklyWeatherData!.temperatureMax[index],
      );
    }).toList();

    final rawMinY = min(
      weeklyWeatherData!.temperatureMin.reduce(min),
      weeklyWeatherData!.temperatureMax.reduce(min),
    );

    final rawMaxY = max(
      weeklyWeatherData!.temperatureMin.reduce(max),
      weeklyWeatherData!.temperatureMax.reduce(max),
    );

// Adjust minY and maxY to nearest multiples of 5
    final minY = (rawMinY / 5).floor() * 5.0; // Round down to nearest 5
    final maxY = (rawMaxY / 5).ceil() * 5.0; // Round up to nearest 5

    final minX = 0.0;
    final maxX = (weeklyWeatherData!.time.length - 1).toDouble();

    // Responsive graph height based on screen height
    final screenHeight = MediaQuery.of(context).size.height;
    final graphHeight = screenHeight * 0.3; // Adjust height proportionally

    return Column(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Weekly Temperatures",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(
          height: graphHeight,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LineChart(
              LineChartData(
                minX: minX,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  verticalInterval:
                      (maxX - minX) / 6, // Dynamic vertical interval
                  horizontalInterval:
                      (maxY - minY) / 6, // Dynamic horizontal interval
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Colors.white30,
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => const FlLine(
                    color: Colors.white30,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (maxY - minY) / 6, // Match horizontal interval
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}°C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final int index = value.toInt();
                        if (index >= 0 &&
                            index < weeklyWeatherData!.time.length) {
                          final time = weeklyWeatherData!.time[index];
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              time,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.white30, width: 1),
                ),
                lineBarsData: [
                  // Line for temperatureMin
                  LineChartBarData(
                    spots: spotsMin,
                    isCurved: true,
                    color: Colors.green, // Adjust color for clarity
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: false,
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: Colors.green,
                      ),
                    ),
                  ),
                  // Line for temperatureMax
                  LineChartBarData(
                    spots: spotsMax,
                    isCurved: true,
                    color: Colors.red, // Adjust color for clarity
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: false,
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildLegend(),
      ],
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
