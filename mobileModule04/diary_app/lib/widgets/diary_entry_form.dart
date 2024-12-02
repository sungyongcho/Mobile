import 'package:diary_app/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:diary_app/utils/emotion_icons.dart';

class DiaryEntryForm extends StatefulWidget {
  final String username;
  final VoidCallback onSave;

  DiaryEntryForm({required this.username, required this.onSave});

  @override
  __DiaryEntryFormState createState() => __DiaryEntryFormState();
}

class __DiaryEntryFormState extends State<DiaryEntryForm> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _text = '';
  String _icon = 'satisfied';

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await FirestoreService.saveDiaryEntry(
        username: widget.username,
        title: _title,
        text: _text,
        icon: _icon,
        date: DateTime.now(),
      );

      widget.onSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                onSaved: (value) => _title = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Title is required' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Content'),
                maxLines: 5,
                onSaved: (value) => _text = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Content is required' : null,
              ),
              SizedBox(height: 20),
              // Dropdown for selecting emotion
              DropdownButtonFormField<String>(
                value: _icon,
                items: emotionIcons.keys.map((emotion) {
                  return DropdownMenuItem<String>(
                    value: emotion,
                    child: Row(
                      children: [
                        Icon(emotionIcons[emotion]),
                        SizedBox(width: 10),
                        Text(emotion),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _icon = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Feeling'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEntry,
                child: Text('Save Entry'),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
