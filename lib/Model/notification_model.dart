import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      timestamp: _parseDate(data['date'] ?? ''), // Parse the date string here
      isRead: data['isRead'] ?? false,
    );
  }

  // Helper method to parse the date string into a DateTime object
  static DateTime _parseDate(String dateString) {
    // Check if the date string is empty
    if (dateString.isEmpty) {
      return DateTime.now(); // or return a default date
    }

    // Split the string by '-' and convert to integers
    List<String> parts = dateString.split('-');
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }
}
