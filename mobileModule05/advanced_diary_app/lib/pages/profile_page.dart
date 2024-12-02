import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:advanced_diary_app/services/auth_service.dart';
import 'package:advanced_diary_app/widgets/diary_entry_details.dart';
import 'package:advanced_diary_app/widgets/diary_entry_form.dart';
import 'package:flutter/material.dart';
import 'package:advanced_diary_app/services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:advanced_diary_app/utils/feelings.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;
  String? firstName;
  String? lastName;
  List<Map<String, dynamic>> _diaryEntries = [];
  int totalEntries = 0;
  Map<String, double> feelingsPercentage = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve username from Navigator arguments
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
      _diaryEntries =
          entries.reversed.toList(); // Reverse to show latest entries
      totalEntries = entries.length;
      _calculateFeelingsPercentage();
    });
  }

  void _calculateFeelingsPercentage() {
    if (_diaryEntries.isEmpty) {
      feelingsPercentage = {};
      return;
    }

    // Count occurrences of each feeling
    final feelingsCount = <String, int>{};
    for (var entry in _diaryEntries) {
      final feeling =
          entry['icon'] ?? 'unknown'; // Default to 'unknown' if no icon
      feelingsCount[feeling] = (feelingsCount[feeling] ?? 0) + 1;
    }

    // Calculate percentages
    final Map<String, double> percentageMap = {};
    feelingsCount.forEach((key, value) {
      percentageMap[key] = (value / totalEntries) * 100;
    });

    setState(() {
      feelingsPercentage = percentageMap;
    });
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
          icon: Icon(Icons.logout), // Logout icon
          onPressed: () {
            // Show a confirmation dialog before logging out
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Logout'),
                content: Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context), // Cancel action
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                      _logout(); // Call logout
                    },
                    child: Text('Logout'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display total number of entries
            Text(
              'Total Entries: $totalEntries',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Display the last 2 entries
            Text(
              'Last 2 Entries',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _diaryEntries.isEmpty
                ? Center(child: Text('No entries found.'))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _diaryEntries.length < 2
                        ? _diaryEntries.length
                        : 2, // Show only the last 2 entries
                    itemBuilder: (context, index) {
                      final entry = _diaryEntries[index];
                      return ListTile(
                        leading: Icon(
                          emotionIcons[entry['icon']] ?? Icons.help,
                          color: Colors.blue,
                        ),
                        title: Text(entry['title'] ?? 'No Title'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (entry['date'] != null)
                              Text(
                                DateFormat('yyyy-MM-dd – kk:mm').format(
                                    (entry['date'] as Timestamp).toDate()),
                              ),
                            Text('Feeling: ${entry['icon'] ?? 'None'}'),
                          ],
                        ),
                        onTap: () => _showReadEntrySheet(entry),
                      );
                    },
                  ),
            // Display feelings percentages
            Text(
              'Feelings Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            feelingsPercentage.isEmpty
                ? Center(child: Text('No feelings recorded.'))
                : ListView(
                    shrinkWrap: true,
                    children: feelingsPercentage.entries.map((entry) {
                      return ListTile(
                        leading: Icon(
                          emotionIcons[entry.key] ?? Icons.help,
                          color: Colors.blue,
                        ),
                        title: Text(entry.key),
                        subtitle: Text('${entry.value.toStringAsFixed(1)}%'),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateEntrySheet,
        child: Icon(Icons.add),
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
        return DiaryEntryDetails(
          entry: entry,
          onDelete: () async {
            await FirestoreService.deleteDiaryEntry(entry['id']);
            Navigator.pop(context); // Close modal
            await _fetchDiaryEntries(); // Refresh entries in MainPage
          },
        );
      },
    );
  }

  Future<void> _logout() async {
    await AuthService.logout(); // Call logout function from AuthService
    Navigator.pushReplacementNamed(context, '/'); // Redirect to login page
  }
}
