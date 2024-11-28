import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Import the geolocator package
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const Ex01App());
}

class Ex01App extends StatelessWidget {
  const Ex01App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Ex01Home(),
    );
  }
}

class Ex01Home extends StatefulWidget {
  const Ex01Home({super.key});

  @override
  _Ex01HomeState createState() => _Ex01HomeState();
}

class _Ex01HomeState extends State<Ex01Home> with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _inputController;
  late String value;
  double? latitude;
  double? longitude;
  String? error;
  List<dynamic> suggestions = []; // List to store suggestions
  String temperature = 'Loading';

  @override
  void initState() {
    super.initState();
    _getLocation();
    _tabController = TabController(length: 3, vsync: this);
    _inputController = TextEditingController();
    value = '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  // Function to determine the current position
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request permissions if they are denied
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are still denied
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Permissions are granted, get the position
    return await Geolocator.getCurrentPosition();
  }

  // Function to fetch suggestions from the Open-Meteo Geocoding API
  Future<void> fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        suggestions = [];
      });
      return;
    }

    final cityUrl =
        'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5';
    try {
      final response = await http.get(Uri.parse(cityUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          suggestions = data['results'] ?? [];
        });
      } else {
        setState(() {
          suggestions = [];
        });
      }
    } catch (e) {
      setState(() {
        suggestions = [];
      });
    }
  }

  Future<void> fetchWeather(double latitude, double longitude) async {
    final weatherUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m';
    try {
      final response = await http.get(Uri.parse(weatherUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Parse the temperature and unit
        final current = data['current'];
        final temperatureValue = current['temperature_2m'];
        final temperatureUnit = data['current_units']['temperature_2m'];

        // Store them in the `temperature` string
        setState(() {
          temperature = "$temperatureValue $temperatureUnit";
        });

        print(temperature); // For debugging
      } else {
        print("Failed to fetch weather data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching weather data: $e");
    }
  }

  // Function to get the current location
  void _getLocation() async {
    try {
      Position position = await _determinePosition();
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        latitude = null;
        longitude = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.search)),
        title: TextField(
          controller: _inputController,
          onChanged: (input) {
            setState(() {
              value = input;
              fetchSuggestions(input);
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search location...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Colors.white70, fontSize: 12.0, // Responsive font size
            ),
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.0, // Responsive font size
          ),
          cursorColor: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_pin),
            onPressed: () {
              setState(() {
                _inputController.text = '';
                value = 'Geolocation';
              });
            },
          ),
        ],
        backgroundColor: Color.fromARGB(255, 92, 93, 114),
      ),
      body: value.isNotEmpty && suggestions.isNotEmpty
          ? ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];

                return ListTile(
                  title: Text(
                    suggestion['name'] ?? 'Unknown City',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${suggestion['admin1'] ?? 'Unknown Region'}, ${suggestion['country'] ?? 'Unknown Country'}',
                  ),
                  onTap: () {
                    // Handle the selection of a suggestion
                    setState(() {
                      value = suggestion['name'];
                      suggestions = [];
                      // _inputController.text = suggestion['name'];
                      fetchWeather(
                          suggestion['latitude'], suggestion['longitude']);
                      latitude = suggestion['latitude'];
                      longitude = suggestion['longitude'];
                      _inputController.text = '';
                    });
                  },
                );
              },
            )
          : error == null
              ? TabBarView(
                  controller: _tabController,
                  children: ['Currently', 'Today', 'Weekly']
                      .map(
                        (e) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment
                                .center, // Centers children vertically
                            crossAxisAlignment: CrossAxisAlignment
                                .center, // Centers children horizontally
                            children: [
                              Text(
                                e,
                                style: TextStyle(
                                  fontSize: screenWidth *
                                      0.08, // Responsive font size
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${latitude?.toStringAsFixed(4)} ${longitude?.toStringAsFixed(4)}',
                                style: TextStyle(
                                  fontSize: screenWidth *
                                      0.06, // Responsive font size
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                  height: screenHeight *
                                      0.02), // Responsive spacing
                              Text(
                                value,
                                style: TextStyle(
                                  fontSize: screenWidth *
                                      0.08, // Responsive font size
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                temperature,
                                style: TextStyle(
                                  fontSize: screenWidth *
                                      0.08, // Responsive font size
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                )
              : Container(
                  color: Color.fromARGB(255, 233, 233, 247),
                  child: Center(
                    child: Text(
                      'Geolocation is not available, please enable it in your App settings',
                      style: TextStyle(
                        fontSize: screenWidth * 0.06, // Responsive font size
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 92, 93, 114),
        child: SizedBox(
          child: Row(
            children: [
              _buildTabItem(
                index: 0,
                label: 'Currently',
                icon: Icons.settings,
                screenWidth: screenWidth,
              ),
              _buildTabItem(
                index: 1,
                label: 'Today',
                icon: Icons.today,
                screenWidth: screenWidth,
              ),
              _buildTabItem(
                index: 2,
                label: 'Weekly',
                icon: Icons.calendar_month,
                screenWidth: screenWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String label,
    required IconData icon,
    required double screenWidth,
  }) {
    return Expanded(
      child: TextButton(
        onPressed: () {
          setState(() {
            _tabController.animateTo(index); // Change TabBarView's active tab
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.0, // Responsive icon size
              color: Colors.white,
            ),
            const SizedBox(height: 5.0), // Responsive spacing
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12, // Responsive font size
                color: _tabController.index == index
                    ? Colors.white
                    : Colors.white70,
                fontWeight: _tabController.index == index
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
