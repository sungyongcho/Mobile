import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:advanced_diary_app/utils/feelings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:advanced_diary_app/utils/strings_extensions.dart';

class ProfileView extends StatefulWidget {
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
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    final diaryEntries = widget.diaryEntries;
    final completeFeelingsPercentage = {
      for (var feeling in feelingsOrder)
        feeling: widget.feelingsPercentage[feeling] ?? 0.0,
    };

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last 2 Entries',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            diaryEntries.isEmpty
                ? Center(child: Text('No entries found.'))
                : ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount:
                          diaryEntries.length < 2 ? diaryEntries.length : 2,
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
                                  DateFormat('yyyy-MM-dd').format(
                                      (entry['date'] as Timestamp).toDate()),
                                ),
                              Text('Feeling: ${entry['icon'] ?? 'None'}'),
                            ],
                          ),
                          onTap: () => widget.onReadEntry(entry),
                        );
                      },
                    ),
                  ),
            Text(
              'Feelings Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              'Total Entries: ${widget.totalEntries}',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: feelingsOrder.length,
              itemBuilder: (context, index) {
                final feeling = feelingsOrder[index];
                return ListTile(
                  leading: Icon(
                    emotionIcons[feeling] ?? Icons.help,
                    color: Colors.blue,
                  ),
                  title: Text(feeling.replaceAll('_', ' ').capitalize()),
                  subtitle: Text(
                    '${completeFeelingsPercentage[feeling]!.toStringAsFixed(1)}%',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
