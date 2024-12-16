import 'package:advanced_weather_app/widgets/current_weather_widget.dart';
import 'package:advanced_weather_app/widgets/today_weather_widget.dart';
import 'package:advanced_weather_app/widgets/weekly_weather_widget.dart';
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
  runApp(const AdvancedWeatherApp());
}

class AdvancedWeatherApp extends StatelessWidget {
  const AdvancedWeatherApp({super.key});

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
    // Listener to update UI when swiping or tapping changes the tab
    _tabController.addListener(() {
      if (_tabController.index != _tabController.previousIndex) {
        setState(() {});
      }
    });
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image.png'), // Path to your image
            fit: BoxFit.cover, // Ensures the image covers the entire background
          ),
        ),
        child: searchValue.isNotEmpty
            ? suggestions.isNotEmpty
                ? _buildSuggestionsList()
                : _buildErrorView()
            : error == null
                ? _buildTabBarView()
                : _buildErrorView(),
      ),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.search),
        onPressed: () async {
          if (suggestions.isNotEmpty) {
            final firstSuggestion = suggestions[0];
            await _fetchLocationData(
              firstSuggestion['latitude'],
              firstSuggestion['longitude'],
            );
            await _fetchWeatherData();
            setState(() {
              searchValue = '';
              _inputController.clear();
            });
          }
        },
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
          icon: const Icon(Icons.location_pin),
          onPressed: () async {
            _inputController.clear(); // Clear the search input field
            setState(() {
              searchValue = ''; // Reset the search value
              suggestions = []; // Clear suggestions
              error = null; // Clear any error messages
            });
            try {
              // Re-fetch location and weather data
              await _fetchCurrentLocation();
            } catch (e) {
              // Handle errors gracefully
              _setErrorState('Failed to restore GPS location: $e');
            }
          },
        ),
      ],
      backgroundColor: const Color(0xFF5C5D72),
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
        CurrentWeatherWidget(
          locationData: locationData,
          currentWeatherData: currentWeatherData,
          weatherService: _weatherService,
        ),
        TodayWeatherWidget(
          locationData: locationData,
          todayWeatherData: todayWeatherData,
          weatherService: _weatherService,
        ),
        WeeklyWeatherWidget(
          locationData: locationData,
          weeklyWeatherData: weeklyWeatherData,
          weatherService: _weatherService,
        ),
      ],
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
          setState(() {
            _tabController.animateTo(index);
          });
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
}
