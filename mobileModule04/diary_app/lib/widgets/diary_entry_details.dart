import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:diary_app/utils/emotion_icons.dart'; // Import emotionIcons

class DiaryEntryDetails extends StatelessWidget {
  final Map<String, dynamic> entry;

  DiaryEntryDetails({required this.entry});
  // Define a map of feelings to Material icons
  @override
  Widget build(BuildContext context) {
    IconData emotionIcon = emotionIcons[entry['icon']] ?? Icons.help_outline;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry['title'] ?? 'No Title',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(
                emotionIcon,
                size: 40,
                color: Colors.blueGrey,
              ),
              SizedBox(width: 10),
              Text(
                entry['icon'] ?? 'No Feeling',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
          Text(
            (entry['date'] as Timestamp).toDate().toString(),
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 20),
          Text(
            entry['text'] ?? 'No Content',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}
