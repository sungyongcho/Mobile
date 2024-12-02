import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:advanced_diary_app/utils/feelings.dart';
import 'package:advanced_diary_app/services/firestore_service.dart';

class DiaryEntryDetails extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback onDelete; // Add callback for deletion

  DiaryEntryDetails({required this.entry, required this.onDelete});

  Future<void> _deleteEntry(BuildContext context, String documentId) async {
    try {
      await FirestoreService.deleteDiaryEntry(
          documentId); // Call Firestore delete
      onDelete(); // Notify parent widget about deletion
      Navigator.pop(context); // Close the modal after deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Entry deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete entry: $e')),
      );
    }
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  final documentId = entry['id'];
                  if (documentId != null) {
                    _deleteEntry(context, documentId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid entry ID!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Delete button color
                ),
                child: Text('Delete'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
