import 'package:advanced_diary_app/services/auth_service.dart';
import 'package:advanced_diary_app/widgets/calendar_view_page.dart';
import 'package:advanced_diary_app/widgets/diary_entry_details.dart';
import 'package:advanced_diary_app/widgets/diary_entry_form.dart';
import 'package:flutter/material.dart';
import 'package:advanced_diary_app/services/firestore_service.dart';
import 'package:advanced_diary_app/widgets/profile_view_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String? username;
  String? firstName;
  String? lastName;
  List<Map<String, dynamic>> _diaryEntries = [];
  int totalEntries = 0;
  Map<String, double> feelingsPercentage = {};
  int _selectedIndex = 0; // Index to track the selected tab

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    username = args?['username'];
    firstName = args?['first_name'];
    lastName = args?['last_name'];

    if (username != null) {
      _fetchDiaryEntries();
    }
  }

  Future<void> _fetchDiaryEntries() async {
    if (username == null) return;

    final entries = await FirestoreService.getDiaryEntries(username!);
    setState(() {
      _diaryEntries = entries.reversed.toList();
      totalEntries = entries.length;
      _calculateFeelingsPercentage();
    });
  }

  void _calculateFeelingsPercentage() {
    if (_diaryEntries.isEmpty) {
      feelingsPercentage = {};
      return;
    }

    final feelingsCount = <String, int>{};
    for (var entry in _diaryEntries) {
      final feeling = entry['icon'] ?? 'unknown';
      feelingsCount[feeling] = (feelingsCount[feeling] ?? 0) + 1;
    }

    feelingsPercentage = feelingsCount
        .map((key, value) => MapEntry(key, (value / totalEntries) * 100));
  }

  Widget _buildCalendarView() {
    return Center(
      child: Text(
        'Hello World',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Diary Entries'),
            if (firstName != null && lastName != null)
              Text(
                '$firstName $lastName',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () => _logout(),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          ProfileView(
            diaryEntries: _diaryEntries,
            totalEntries: totalEntries,
            feelingsPercentage: feelingsPercentage,
            onReadEntry: _showReadEntrySheet,
          ),
          CalendarView(
            markedDates: {
              for (var entry in _diaryEntries)
                (entry['date'] as Timestamp).toDate(): [
                  entry['title'] ?? 'Untitled'
                ]
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateEntrySheet,
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateEntrySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DiaryEntryForm(
          username: username!,
          onSave: () {
            Navigator.pop(context); // Close the sheet
            _fetchDiaryEntries(); // Refresh the list
          },
        );
      },
    );
  }

  void _showReadEntrySheet(Map<String, dynamic> entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DiaryEntryDetails(entry: entry); // No need for onDelete
      },
    );
  }

  Future<void> _logout() async {
    await AuthService.logout(); // Call logout function from AuthService
    Navigator.pushReplacementNamed(context, '/'); // Redirect to login page
  }
}
