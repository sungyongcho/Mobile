import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:advanced_diary_app/services/auth_service.dart';
import 'package:advanced_diary_app/widgets/diary_entry_details.dart';
import 'package:advanced_diary_app/widgets/diary_entry_form.dart';
import 'package:flutter/material.dart';
import 'package:advanced_diary_app/services/firestore_service.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;
  String? firstName;
  String? lastName;
  List<Map<String, dynamic>> _diaryEntries = []; // Diary entries list

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
      _diaryEntries = entries;
    });
  }

  Future<void> _deleteEntry(String documentId) async {
    await FirestoreService.deleteDiaryEntry(documentId);
    _fetchDiaryEntries(); // Refresh the list after deletion
  }

  void _showCreateEntrySheet() {
    // Show modal bottom sheet for creating a new diary entry
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
    // Show modal bottom sheet for reading an entry
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DiaryEntryDetails(entry: entry);
      },
    );
  }

  Future<void> _logout() async {
    await AuthService.logout(); // Call logout function from AuthService
    Navigator.pushReplacementNamed(context, '/'); // Redirect to login page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
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
          icon: Icon(Icons.arrow_back), // Custom back arrow
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
      body: _diaryEntries.isEmpty
          ? Center(child: Text('No entries found.'))
          : ListView.builder(
              itemCount: _diaryEntries.length,
              itemBuilder: (context, index) {
                final entry = _diaryEntries[index];
                return ListTile(
                  title: Text(entry['title'] ?? 'No Title'),
                  subtitle: Text(
                    entry['date'] != null
                        ? DateFormat('yyyy-MM-dd – kk:mm').format(
                            (entry['date'] as Timestamp)
                                .toDate()) // Convert Timestamp to DateTime
                        : 'No Date',
                  ),
                  onTap: () => _showReadEntrySheet(entry),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteEntry(entry['id']),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateEntrySheet,
        child: Icon(Icons.add),
      ),
    );
  }
}
