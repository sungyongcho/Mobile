import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:advanced_weather_app/data/today_weather_data.dart';
import 'package:advanced_weather_app/data/location_data.dart';
import 'package:advanced_weather_app/services/weather_service.dart';

class TodayWeatherWidget extends StatelessWidget {
  final LocationData? locationData;
  final TodayWeatherData? todayWeatherData;
  final WeatherService weatherService;

  const TodayWeatherWidget({
    super.key,
    required this.locationData,
    required this.todayWeatherData,
    required this.weatherService,
  });

  @override
  Widget build(BuildContext context) {
    if (todayWeatherData == null) {
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
          const SizedBox(height: 50),
          _buildTemperatureGraph(),
          const SizedBox(height: 50),
          _buildHourlyWeatherList(),
        ],
      ),
    );
  }

  Widget _buildHourlyWeatherList() {
    return SizedBox(
      height: 100, // Set height for the list
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: todayWeatherData!.time.length,
        itemBuilder: (context, index) {
          final time = todayWeatherData!.time[index];
          final temperature = todayWeatherData!.temperature[index];
          final windSpeed = todayWeatherData!.windSpeed[index];
          final weather = todayWeatherData!.weather[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Icon(
                  weatherService.getWeatherIcon(weather),
                  color: Colors.yellow[800],
                  size: 24,
                ),
                Text(
                  '${temperature.toStringAsFixed(1)}°C',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.air,
                      color: Colors.yellow[800],
                    ),
                    Text(
                      '${windSpeed.toStringAsFixed(1)} km/h',
                      style: _textStyle,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemperatureGraph() {
    final spots = todayWeatherData!.time.asMap().entries.map((entry) {
      final index = entry.key;
      return FlSpot(
        index.toDouble(),
        todayWeatherData!.temperature[index],
      );
    }).toList();

    final minY =
        (todayWeatherData!.temperature.reduce(min) - 5).floorToDouble();
    final maxY = (todayWeatherData!.temperature.reduce(max) + 5).ceilToDouble();
    final minX = 0.0;
    final maxX = (todayWeatherData!.time.length - 1).toDouble();

    return SizedBox(
      height: 250,
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
              verticalInterval: 3,
              horizontalInterval: 5,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.white30,
                strokeWidth: 1,
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: Colors.white30,
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 5,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}°C',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 3,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final int index = value.toInt();
                    if (index >= 0 &&
                        index < todayWeatherData!.time.length &&
                        index % 3 == 0) {
                      final time = todayWeatherData!.time[index];
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          time,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.white30, width: 1),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Colors.orange,
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
                    strokeColor: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ),
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
