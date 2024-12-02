import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'diary_entry_details.dart';

class CalendarView extends StatefulWidget {
  final List<Map<String, dynamic>> diaryEntries;
  final VoidCallback onEntryDeleted; // Callback to notify parent of deletion

  CalendarView({required this.diaryEntries, required this.onEntryDeleted});

  @override
  _CalendarViewState createState() {
    print('Received diaryEntries: ${diaryEntries}');
    return _CalendarViewState();
  }
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> _markedDates = {};
  List<Map<String, dynamic>> _selectedEntries = [];

  @override
  void initState() {
    super.initState();
    print('Passed diaryEntries: ${widget.diaryEntries}');
    _groupEntriesByDate();
    _updateSelectedEntries(_selectedDate);
  }

  @override
  void didUpdateWidget(covariant CalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-group and refresh entries when parent updates diaryEntries
    if (oldWidget.diaryEntries != widget.diaryEntries) {
      _groupEntriesByDate();
      _updateSelectedEntries(_selectedDate);
    }
  }

  void _groupEntriesByDate() {
    final Map<DateTime, List<Map<String, dynamic>>> groupedEntries = {};

    for (var entry in widget.diaryEntries) {
      final DateTime entryDate = (entry['date'] as Timestamp).toDate();

      // Normalize date to midnight
      final DateTime normalizedDate =
          DateTime(entryDate.year, entryDate.month, entryDate.day);

      if (!groupedEntries.containsKey(normalizedDate)) {
        groupedEntries[normalizedDate] = [];
      }

      groupedEntries[normalizedDate]?.add(entry);
    }

    setState(() {
      _markedDates = groupedEntries;
    });
  }

  void _updateSelectedEntries(DateTime date) {
    final DateTime normalizedDate = DateTime(date.year, date.month, date.day);
    setState(() {
      _selectedEntries = _markedDates[normalizedDate] ?? [];
    });
  }

  void _showEntryDetails(Map<String, dynamic> entry) {
    showModalBottomSheet(
      context: context,
      builder: (context) => DiaryEntryDetails(
        entry: entry,
        onDelete: () {
          // Call parent's deletion handler and refresh local state
          widget.onEntryDeleted();
        },
      ),
    ).then((_) {
      _updateSelectedEntries(
          _selectedDate); // Refresh entries for selected date
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar View'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 1, 1),
            focusedDay: _selectedDate,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                _updateSelectedEntries(selectedDay);
              });
            },
            eventLoader: (day) =>
                _markedDates[DateTime(day.year, day.month, day.day)]
                    ?.map((e) => e['title'])
                    .toList() ??
                [],
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(),
            ),
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
          ),
          Expanded(
            child: _selectedEntries.isEmpty
                ? Center(child: Text('No entries for this date.'))
                : ListView.builder(
                    itemCount: _selectedEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _selectedEntries[index];
                      return ListTile(
                        title: Text(entry['title'] ?? 'Untitled Entry'),
                        subtitle:
                            Text(entry['text'] ?? 'No details available.'),
                        onTap: () => _showEntryDetails(entry),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
