import 'package:flutter/material.dart';

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

class _Ex00HomeState extends State<Ex00Home>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Update BottomNavigationBar index when TabController index changes
    _tabController.addListener(() {
      setState(() {}); // Trigger rebuild to reflect the active tab
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextField(
          decoration: InputDecoration(
            hintText: 'Search',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
          cursorColor: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              // Handle geolocation button press
            },
          ),
        ],
        backgroundColor: Colors.blue,
      ),
      body: TabBarView(
        controller: _tabController,
        children: ['Currently', 'Today', 'Weekly']
            .map((e) => Center(
                  child: Text(
                    e,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ))
            .toList(),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: SizedBox(
          height: 56.0,
          child: Row(
            children: [
              _buildTabItem(
                index: 0,
                label: 'Currently',
              ),
              _buildTabItem(
                index: 1,
                label: 'Today',
              ),
              _buildTabItem(
                index: 2,
                label: 'Weekly',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({required int index, required String label}) {
    return Expanded(
      child: TextButton(
        onPressed: () {
          setState(() {
            _tabController.animateTo(index); // Change TabBarView's active tab
          });
        },
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color:
                _tabController.index == index ? Colors.white : Colors.white70,
            fontWeight: _tabController.index == index
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
