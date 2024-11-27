import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
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
      body: TabBarView(
        controller: _tabController,
        children: ['Currently', 'Today', 'Weekly']
            .map(
              (e) => Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Centers children vertically
                  crossAxisAlignment: CrossAxisAlignment
                      .center, // Centers children horizontally
                  children: [
                    Text(
                      e,
                      style: TextStyle(
                        fontSize: screenWidth * 0.08, // Responsive font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02), // Responsive spacing
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: screenWidth * 0.08, // Responsive font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
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
