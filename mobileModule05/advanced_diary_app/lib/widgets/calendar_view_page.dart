import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'diary_entry_details_01.dart';
import 'package:advanced_diary_app/utils/feelings.dart';

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
            // Returns a non-empty list if entries exist for that date
            eventLoader: (day) {
              return _markedDates[DateTime(day.year, day.month, day.day)]
                      ?.map((e) => e['title'])
                      .toList() ??
                  [];
            },
            calendarStyle: CalendarStyle(
              todayDecoration:
                  BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              selectedDecoration:
                  BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              // Turn off default marker decoration since we’ll customize it
              markerDecoration: const BoxDecoration(),
              // Force only one marker dot per day
              markersMaxCount: 1,
            ),
            // Provide a singleMarkerBuilder to draw one red dot if day has events
            calendarBuilders: CalendarBuilders(
              singleMarkerBuilder: (context, date, event) {
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(
                      bottom: 2), // spacing under the day text
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red, // marker color
                  ),
                );
              },
            ),
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
          ),
          Expanded(
            child: _selectedEntries.isEmpty
                ? Center(child: Text('No entries for this date.'))
                : Scrollbar(
                    thumbVisibility: true,
                    child: ListView.builder(
                      primary: false,
                      itemCount: _selectedEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _selectedEntries[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey,
                                  width: 1.0), // Add bottom border
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(
                              emotionIcons[entry['icon']] ??
                                  Icons.help, // Map feeling to an icon
                              color: Colors.blue,
                            ),
                            title: Text(entry['title'] ?? 'Untitled Entry'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry['text'] ?? 'No details available.'),
                                if (entry['date'] != null)
                                  Text(
                                    DateFormat(
                                            'yyyy-MM-dd – kk:mm') // Customize the format as needed
                                        .format((entry['date'] as Timestamp)
                                            .toDate()),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey), // Style the date
                                  ),
                              ],
                            ),
                            onTap: () => _showEntryDetails(entry),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
