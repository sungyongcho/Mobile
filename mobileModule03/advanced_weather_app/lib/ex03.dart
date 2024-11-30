import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:advanced_weather_app/data/location_data.dart';
import 'package:advanced_weather_app/data/today_weather_data.dart';
import 'package:advanced_weather_app/data/weekly_weather_data.dart';
import 'package:advanced_weather_app/services/weather_service.dart';
import 'package:advanced_weather_app/data/current_weather_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

void main() {
  runApp(const Ex03App());
}

class Ex03App extends StatelessWidget {
  const Ex03App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WeatherHome(),
    );
  }
}

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _inputController;
  final WeatherService _weatherService = WeatherService();

  String? error;
  String searchValue = '';
  List<dynamic> suggestions = [];
  LocationData? locationData;
  CurrentWeatherData? currentWeatherData;
  TodayWeatherData? todayWeatherData;
  WeeklyWeatherData? weeklyWeatherData;

  @override
  void initState() {
    super.initState();
    _initializeState();
    _tabController.addListener(() {
      setState(() {}); // Rebuild the widget when tab index changes
    });
  }

  @override
  void dispose() {
    _tabController
        .removeListener(() {}); // Remove the listener to avoid memory leaks
    _tabController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _initializeState() {
    _tabController = TabController(length: 3, vsync: this);
    _inputController = TextEditingController();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      final position = await _determinePosition();
      await _fetchLocationData(position.latitude, position.longitude);
      await _fetchWeatherData();
    } catch (e) {
      _setErrorState(e.toString());
    }
  }

  Future<Position> _determinePosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw 'Location services are disabled.';
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw 'Location permissions are denied.';
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _fetchLocationData(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          locationData = LocationData(
            city: place.locality ?? 'Unknown City',
            region: place.administrativeArea ?? 'Unknown Region',
            country: place.country ?? 'Unknown Country',
            latitude: latitude,
            longitude: longitude,
          );
          error = null;
        });
      }
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  Future<void> _fetchWeatherData() async {
    if (locationData == null) return;

    try {
      final weatherDataForCurrent =
          await _weatherService.fetchCurrentWeatherData(
        locationData!.latitude,
        locationData!.longitude,
      );
      final weatherDataForToday = await _weatherService.fetchTodayWeatherData(
          locationData!.latitude, locationData!.longitude);
      final weatherDataForWeekly = await _weatherService.fetchWeeklyWeatherData(
          locationData!.latitude, locationData!.longitude);
      setState(() {
        currentWeatherData = weatherDataForCurrent;
        todayWeatherData = weatherDataForToday;
        weeklyWeatherData = weatherDataForWeekly;
        error = null;
      });
    } catch (e) {
      _setErrorState(e.toString());
    }
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        suggestions = [];
        error = null;
      });
      return;
    }

    const baseUrl = 'https://geocoding-api.open-meteo.com/v1/search';
    final cityUrl = '$baseUrl?name=$query&count=5';

    try {
      final response = await http.get(Uri.parse(cityUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          suggestions = data['results'] ?? [];
          if (suggestions.isEmpty) {
            error = 'No results found for "$query".';
          } else {
            error = null;
          }
        });
      } else {
        setState(() {
          suggestions = [];
          error = 'Error fetching suggestions.';
        });
      }
    } catch (_) {
      setState(() {
        suggestions = [];
        error = 'Connection error. Please try again later.';
      });
    }
  }

  void _setErrorState(String errorMessage) {
    setState(() {
      error = errorMessage;
      // Optionally clear weather data if needed
      currentWeatherData = null;
      todayWeatherData = null;
      weeklyWeatherData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(children: [
        Positioned.fill(
          child: Image.asset(
            'assets/image.png', // Path to your image
            fit: BoxFit.cover, // Ensures the image covers the entire background
          ),
        ),
        searchValue.isNotEmpty
            ? suggestions.isNotEmpty
                ? _buildSuggestionsList()
                : _buildErrorView()
            : error == null
                ? _buildTabBarView()
                : _buildErrorView(),
      ]),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: const Icon(
        Icons.search,
        color: Colors.white,
      ),
      title: TextField(
        controller: _inputController,
        onChanged: (input) {
          setState(() {
            searchValue = input;
            _fetchSuggestions(input);
          });
        },
        decoration: const InputDecoration(
          labelText: 'Search location...',
          labelStyle: TextStyle(color: Colors.white70, fontSize: 12.0),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
        style: const TextStyle(color: Colors.white, fontSize: 16.0),
        cursorColor: Colors.white,
      ),
      actions: [
        // Add the VerticalDivider here
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: VerticalDivider(
            color: Colors.white70,
            thickness: 1.0,
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.location_pin,
            color: Colors.white,
          ),
          onPressed: () {
            _inputController.clear();
            setState(() {});
          },
        ),
      ],
      backgroundColor: const Color.fromARGB(255, 91, 81, 212),
    );
  }

  Widget _buildSuggestionsList() {
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return Padding(
          padding: const EdgeInsets.only(left: 16.0), // Add horizontal padding
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey, // Color of the underline
                  width: 1.0, // Thickness of the underline
                ),
              ),
            ),
            child: ListTile(
              title: Row(
                children: [
                  const Icon(
                    Icons.location_city,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 16.0), // Add some spacing
                  Text(
                    suggestion['name'] ?? 'Unknown City',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8.0), // Add some spacing
                  Expanded(
                    child: Text(
                      '${suggestion['admin1'] ?? 'Unknown Region'}, ${suggestion['country'] ?? 'Unknown Country'}',
                      style:
                          const TextStyle(fontSize: 12.0, color: Colors.grey),
                      textAlign:
                          TextAlign.left, // Align the subtitle to the right
                      overflow:
                          TextOverflow.ellipsis, // Handle long text gracefully
                    ),
                  ),
                ],
              ),
              // this looks much better
              // subtitle: Text(
              //   '${suggestion['admin1'] ?? 'Unknown Region'}, ${suggestion['country'] ?? 'Unknown Country'}',
              // ),
              onTap: () async {
                await _fetchLocationData(
                  suggestion['latitude'],
                  suggestion['longitude'],
                );
                await _fetchWeatherData();
                setState(() {
                  searchValue = '';
                  _inputController.text = '';
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildCurrentWeather(),
        _buildTodayWeather(),
        _buildWeeklyWeather(),
      ],
    );
  }

  Widget _buildCurrentWeather() {
    if (currentWeatherData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(locationData?.city ?? 'N/A', style: _cityTextStyle),
          Text('${locationData?.region}, ${locationData?.country}' ?? 'N/A',
              style: _textStyle),
          SizedBox(height: 40),
          Text(
            '${currentWeatherData?.temperature ?? 'N/A'}°C',
            style: TextStyle(fontSize: 48, color: Colors.yellow[800]),
          ),
          SizedBox(height: 40),
          Text(
            '${currentWeatherData?.weather ?? 'N/A'}',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          Icon(
            _weatherService.getWeatherIcon(currentWeatherData?.weather),
            size: 64,
            color: Colors.yellow[800],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.air,
                color: Colors.yellow[800],
                size: 24,
              ),
              const SizedBox(
                  width: 8), // Add some spacing between the icon and text
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
                SizedBox(
                  height: 12,
                ),
                Icon(
                  _weatherService.getWeatherIcon(weather),
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
    // Prepare the data points for the chart
    final spots = todayWeatherData!.time.asMap().entries.map((entry) {
      final index = entry.key;
      return FlSpot(
        index.toDouble(),
        todayWeatherData!.temperature[index],
      );
    }).toList();

    // Calculate the minimum and maximum values for Y-axis
    final minY =
        (todayWeatherData!.temperature.reduce(min) - 5).floorToDouble();
    final maxY = (todayWeatherData!.temperature.reduce(max) + 5).ceilToDouble();

    // Set the range for X-axis
    final minX = 0.0;
    final maxX = (todayWeatherData!.time.length - 1).toDouble();

    return Container(
      height: 250,
      width: double.infinity, // Make the width responsive
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16.0), // Add padding to left and right
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
                  3, // Adjust vertical grid lines to every 3 units
              horizontalInterval: 5, // Adjust horizontal grid lines
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
                  interval: 5, // Y-axis labels interval
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
                  interval: 3, // X-axis labels every 3 hours
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
                    color: Colors.white, // Center color of the dot
                    strokeWidth: 2,
                    strokeColor: Colors.orange, // Border color of the dot
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayWeather() {
    if (currentWeatherData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(locationData?.city ?? 'N/A', style: _cityTextStyle),
          Text('${locationData?.region}, ${locationData?.country}' ?? 'N/A',
              style: _textStyle),
          SizedBox(
            height: 50,
          ),
          _buildTemperatureGraph(),
          SizedBox(
            height: 50,
          ),
          _buildHourlyWeatherList()
          // ...todayWeatherData!.time.asMap().entries.map((entry) {
          //   final index = entry.key;
          //   final time = entry.value;
          //   final temperature = todayWeatherData!.temperature[index];
          //   final windSpeed = todayWeatherData!.windSpeed[index];

          //   return Text(
          //     '$time  $temperature°C  $windSpeed km/h',
          //     style: _todayWeatherListStyle,
          //   );
          // }).toList(),
        ],
      ),
    );
  }

  Widget _buildWeeklyWeather() {
    if (currentWeatherData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(locationData?.city ?? 'N/A', style: _textStyle),
          Text(locationData?.region ?? 'N/A', style: _textStyle),
          Text(locationData?.country ?? 'N/A', style: _textStyle),
          ...weeklyWeatherData!.time.asMap().entries.map((entry) {
            final index = entry.key;
            final time = entry.value;
            final temperatureMin = weeklyWeatherData!.temperatureMin[index];
            final temperatureMax = weeklyWeatherData!.temperatureMax[index];
            final weatherDescription =
                weeklyWeatherData!.weatherDescriptions[index];

            return Text(
              '$time  $temperatureMin°C $temperatureMax  $weatherDescription',
              style: _todayWeatherListStyle,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String label) {
    return Center(
      child: Text(label, style: _textStyle),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            error ?? 'An unexpected error occurred.',
            style: _textStyle.copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // ElevatedButton(
          //   onPressed: () {
          //     if (searchValue.isNotEmpty) {
          //       _fetchSuggestions(searchValue);
          //     } else if (locationData != null) {
          //       _fetchWeatherData();
          //     } else {
          //       _fetchCurrentLocation();
          //     }
          //   },
          //   child: const Text('Retry'),
          // ),
        ],
      ),
    );
  }

  Widget _buildBottomAppBar() {
    final List<Map<String, dynamic>> tabs = [
      {'label': 'Currently', 'icon': Icons.settings},
      {'label': 'Today', 'icon': Icons.today},
      {'label': 'Weekly', 'icon': Icons.calendar_month},
    ];

    return BottomAppBar(
      color: const Color.fromARGB(255, 119, 183, 211),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          return _buildTabItem(index, tab['label']!, tab['icon'] as IconData);
        }),
      ),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    final isSelected = _tabController.index == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: 16.0,
            ),
            const SizedBox(height: 5.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.0,
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _textStyle => const TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white);
  TextStyle get _cityTextStyle => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.amber[800],
      );
  TextStyle get _todayWeatherListStyle => const TextStyle(
        fontSize: 14,
      );
}
