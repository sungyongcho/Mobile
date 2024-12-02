import 'package:advanced_diary_app/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:advanced_diary_app/utils/emotion_icons.dart';
import 'package:intl/intl.dart';

class DiaryEntryForm extends StatefulWidget {
  final String email;
  final VoidCallback onSave;

  DiaryEntryForm({required this.email, required this.onSave});

  @override
  __DiaryEntryFormState createState() => __DiaryEntryFormState();
}

class __DiaryEntryFormState extends State<DiaryEntryForm> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _text = '';
  String _icon = 'satisfied';
  DateTime _selectedDate = DateTime.now();

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await FirestoreService.saveDiaryEntry(
        email: widget.email,
        title: _title,
        text: _text,
        icon: _icon,
        date: _selectedDate,
      );

      widget.onSave();
    }
  }

  void _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text('Pick Date'),
                  ),
                ],
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
