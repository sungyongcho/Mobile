import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Import the geolocator package

void main() {
  runApp(const Ex00App());
}

class Ex00App extends StatelessWidget {
  const Ex00App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Ex00Home(),
    );
  }
}

class Ex00Home extends StatefulWidget {
  const Ex00Home({super.key});

  @override
  _Ex00HomeState createState() => _Ex00HomeState();
}

class _Ex00HomeState extends State<Ex00Home> with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _inputController;
  late String value;
  double? latitude;
  double? longitude;
  String? error;

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
      body: error == null
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
                              fontSize:
                                  screenWidth * 0.08, // Responsive font size
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${latitude?.toStringAsFixed(4)} ${longitude?.toStringAsFixed(4)}',
                            style: TextStyle(
                              fontSize:
                                  screenWidth * 0.06, // Responsive font size
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                              height:
                                  screenHeight * 0.02), // Responsive spacing
                          Text(
                            value,
                            style: TextStyle(
                              fontSize:
                                  screenWidth * 0.08, // Responsive font size
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
