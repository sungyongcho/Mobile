import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:advanced_diary_app/utils/emotion_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileView extends StatelessWidget {
  final List<Map<String, dynamic>> diaryEntries;
  final int totalEntries;
  final Map<String, double> feelingsPercentage;
  final Function(Map<String, dynamic>) onReadEntry;

  ProfileView({
    required this.diaryEntries,
    required this.totalEntries,
    required this.feelingsPercentage,
    required this.onReadEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Entries: $totalEntries',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            'Last 2 Entries',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          diaryEntries.isEmpty
              ? Center(child: Text('No entries found.'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: diaryEntries.length < 2 ? diaryEntries.length : 2,
                  itemBuilder: (context, index) {
                    final entry = diaryEntries[index];
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
                      onTap: () => onReadEntry(entry),
                    );
                  },
                ),
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
    );
  }
}
