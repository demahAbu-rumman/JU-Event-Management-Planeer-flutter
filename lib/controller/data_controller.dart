import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as Path;
import 'package:http/http.dart' as http;
import '../screens/notification_service.dart';

class DataController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentSnapshot? myDocument;
  var allUsers = <DocumentSnapshot>[].obs;
  var filteredUsers = <DocumentSnapshot>[].obs;
  var allEvents = <DocumentSnapshot>[].obs;
  var filteredEvents = <DocumentSnapshot>[].obs;
  var joinedEvents = <DocumentSnapshot>[].obs;

  var isEventsLoading = true.obs;
  var isMessageSending = false.obs;
  var isUsersLoading = false.obs;

  var selectedRole = ''.obs;

  Future<void> updateEvent(
      String eventId, Map<String, dynamic> eventData) async {
    try {
      eventData.forEach((key, value) {
        if (value == null) {
          print("Warning: Field '$key' is null. Setting default value.");
          eventData[key] = '';
        }
      });

      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .update(eventData);
      print("Event updated successfully");
    } catch (e) {
      print("Error updating event: $e");
      throw e;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      throw e;
    }
  }

  @override
  void onInit() {
    super.onInit();
    getMyDocument();
    getUsers();
    getEvents();
    ever(selectedRole, (role) {
      if (role == 'Student') {
        hideEventCreatedSection();
      } else {
        filteredEvents.assignAll(allEvents);
      }
    });
  }

  void filterEventsBy(String filter) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isEventsLoading.value = true;
      DateTime now = DateTime.now();
      List<DocumentSnapshot> filteredList;

      switch (filter) {
        case 'Today':
          filteredList = allEvents.where((event) {
            String eventDateStr = event.get('date') as String;
            DateTime eventDate = _parseDateString(eventDateStr);
            return eventDate.year == now.year &&
                eventDate.month == now.month &&
                eventDate.day == now.day;
          }).toList();
          break;
        case 'Week':
          DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
          DateTime weekEnd = weekStart.add(const Duration(days: 6));
          filteredList = allEvents.where((event) {
            String eventDateStr = event.get('date') as String;
            DateTime eventDate = _parseDateString(eventDateStr);
            return eventDate.isAfter(weekStart) &&
                eventDate.isBefore(weekEnd.add(const Duration(days: 1)));
          }).toList();
          break;
        case 'Month':
          filteredList = allEvents.where((event) {
            String eventDateStr = event.get('date') as String;
            DateTime eventDate = _parseDateString(eventDateStr);
            return eventDate.year == now.year && eventDate.month == now.month;
          }).toList();
          break;
        case 'Year':
          filteredList = allEvents.where((event) {
            String eventDateStr = event.get('date') as String;
            DateTime eventDate = _parseDateString(eventDateStr);
            return eventDate.year == now.year;
          }).toList();
          break;
        default:
          filteredList = allEvents;
      }

      filteredEvents.assignAll(filteredList);
      isEventsLoading.value = false;
    });
  }

  DateTime _parseDateString(String dateStr) {
    List<String> parts = dateStr.split('-');
    if (parts.length == 3) {
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);
      return DateTime(year, month, day);
    }
    throw const FormatException("Invalid date format");
  }

  String formatJoinedDate(dynamic date) {
    if (date == null) return '2023';
    DateTime dateTime;
    if (date is Timestamp) {
      dateTime = date.toDate();
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return '2023';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void filterEventsByDate(DateTime selectedDate) {
    isEventsLoading.value = true;
    List<DocumentSnapshot> filteredList = allEvents.where((event) {
      String eventDateStr = event.get('date') as String;
      DateTime eventDate = _parseDateString(eventDateStr);
      return eventDate.year == selectedDate.year &&
          eventDate.month == selectedDate.month &&
          eventDate.day == selectedDate.day;
    }).toList();
    filteredEvents.assignAll(filteredList);
    isEventsLoading.value = false;
  }

  void getMyDocument() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser?.uid)
        .snapshots()
        .listen((event) {
      myDocument = event;
      update();
    });
  }

  Future<void> fetchMyDocumentOnce() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser?.uid)
        .get();
    myDocument = doc;
    update();
  }

  void getUsers() {
    isUsersLoading(true);
    FirebaseFirestore.instance.collection('users').snapshots().listen((event) {
      allUsers.assignAll(event.docs);
      isUsersLoading(false);
    }, onError: (error) {
      print('Error fetching users: $error');
      isUsersLoading(false);
    });
  }

  void getEvents() {
    isEventsLoading(true);
    FirebaseFirestore.instance.collection('events').snapshots().listen((event) {
      allEvents.assignAll(event.docs);
      filteredEvents.assignAll(event.docs);
      joinedEvents.assignAll(allEvents.where((e) {
        List joinedIds = e.get('joined') ?? [];
        return joinedIds.contains(auth.currentUser?.uid);
      }).toList());
      isEventsLoading(false);
    });
  }

  void filterEventsBySearch(String query) {
    if (query.isEmpty) {
      filteredEvents.assignAll(allEvents);
    } else {
      List<DocumentSnapshot> filteredList = allEvents.where((event) {
        String eventName = event.get('eventName') as String;
        String eventLocation = event.get('location') as String;
        return eventName.toLowerCase().contains(query.toLowerCase()) ||
            eventLocation.toLowerCase().contains(query.toLowerCase());
      }).toList();
      filteredEvents.assignAll(filteredList);
    }
  }

  Future<String> uploadImageToFirebase(File file) async {
    String fileName = Path.basename(file.path);
    var reference = FirebaseStorage.instance.ref().child('myfiles/$fileName');
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<String> uploadThumbnailToFirebase(Uint8List file) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var reference =
        FirebaseStorage.instance.ref().child('myfiles/$fileName.jpg');
    UploadTask uploadTask = reference.putData(file);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    return await taskSnapshot.ref.getDownloadURL();
  }

  Stream<QuerySnapshot> getUserChatsStream() {
    return _firestore
        .collection('chats')
        .where('group', arrayContains: uid)
        .orderBy('lastMessage', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getChatMessagesStream(String groupId) {
    return _firestore
        .collection('chats')
        .doc(groupId)
        .collection('chatroom')
        .where('message', isNotEqualTo: null)
        .orderBy('message')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendFCMNotification({
    required String title,
    required String body,
    required String token,
  }) async {
    const String serverKey = 'AIzaSyCAMFJ190lUpBvY3od1dA-vPBDbxEWDyBg';

    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{'body': body, 'title': title},
            'priority': 'high',
            'to': token,
          },
        ),
      );
    } catch (e) {
      print('Error sending FCM notification: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchTodaysEvents() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day + 1);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay)
        .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<bool> hasEventConflict(Map<String, dynamic> newEventData) async {
    try {
      // Check required fields
      if (!newEventData.containsKey('date') ||
          !newEventData.containsKey('start_time') ||
          !newEventData.containsKey('end_time') ||
          !newEventData.containsKey('location')) {
        print('Missing required event data');
        return false;
      }

      // Parse date and time
      String newDateStr = newEventData['date'];
      DateTime newDate = _parseDateString(newDateStr);
      String newLocation = newEventData['location'];

      TimeOfDay newStartTime = _parseTimeString(newEventData['start_time']);
      TimeOfDay newEndTime = _parseTimeString(newEventData['end_time']);

      DateTime newStartDateTime = DateTime(
          newDate.year, newDate.month, newDate.day,
          newStartTime.hour, newStartTime.minute);
      DateTime newEndDateTime = DateTime(
          newDate.year, newDate.month, newDate.day,
          newEndTime.hour, newEndTime.minute);

      // Check sanity
      if (newEndDateTime.isBefore(newStartDateTime)) {
        print("End time is before start time");
        return true;
      }

      // Get existing events with same date
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('date', isEqualTo: newDateStr)
          .get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> existingEvent = doc.data() as Map<String, dynamic>;

        // Skip if same event being updated
        if (newEventData.containsKey('id') && doc.id == newEventData['id']) {
          continue;
        }

        // Check for exact match on location, start_time, and end_time
        if (existingEvent['location'] == newLocation &&
            existingEvent['start_time'] == newEventData['start_time'] &&
            existingEvent['end_time'] == newEventData['end_time']) {
          print('Conflict with event: ${doc.id}');
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Error in hasEventConflict: $e');
      return false;
    }
  }

  TimeOfDay _parseTimeString(String timeStr) {
    try {
      // Handle formats like "10:00 AM" or "10:00:00 AM"
      final parts = timeStr.split(' ');
      final timePart = parts[0];
      final period = parts.length > 1 ? parts[1] : 'AM';

      final timeComponents = timePart.split(':');
      int hour = int.parse(timeComponents[0]);
      int minute = int.parse(timeComponents[1]);

      // Convert to 24-hour format
      if (period.toUpperCase() == 'PM' && hour != 12) {
        hour += 12;
      } else if (period.toUpperCase() == 'AM' && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print('Error parsing time string: $timeStr');
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  Future<bool> createEvent(Map<String, dynamic> eventData) async {
    try {
      await FirebaseFirestore.instance.collection('events').add(eventData);

      await LocalNotificationService.storeNotification(
        title: "New Event Created",
        body: "You have a new event scheduled for today!",
        userId: FirebaseAuth.instance.currentUser!.uid,
      );

      Get.snackbar('Event Uploaded', 'Event is uploaded successfully.',
          colorText: Colors.white, backgroundColor: Colors.lightGreen);
      return true;
    } catch (e) {
      print('Error creating event: $e');
      return false;
    }
  }

  Future<List<String>> fetchUserTokens() async {
    List<String> tokens = [];
    var snapshot = await FirebaseFirestore.instance.collection('users').get();
    for (var user in snapshot.docs) {
      if (user.data()['fcmToken'] != null) {
        tokens.add(user.data()['fcmToken']);
      }
    }
    return tokens;
  }

  void hideEventCreatedSection() {
    filteredEvents.assignAll(allEvents.where((event) {
      return event.get('creatorRole') != 'Student';
    }).toList());
  }
}
