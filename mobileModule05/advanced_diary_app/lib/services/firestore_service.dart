import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get all diary entries for a specific user
  static Future<List<Map<String, dynamic>>> getDiaryEntries(
      String username) async {
    final querySnapshot = await _db
        .collection('notes')
        .where('username', isEqualTo: username)
        // .orderBy('date', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Include document ID
      return data;
    }).toList();
  }

  // Save a new diary entry
  static Future<void> saveDiaryEntry({
    required String username,
    required String title,
    required String text,
    required String icon,
    required DateTime date,
  }) async {
    await _db.collection('notes').add({
      'username': username,
      'title': title,
      'text': text,
      'icon': icon,
      'date': Timestamp.fromDate(date),
    });
  }

  // Delete a diary entry
  static Future<void> deleteDiaryEntry(String documentId) async {
    await _db.collection('notes').doc(documentId).delete();
  }
}
