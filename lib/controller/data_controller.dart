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

  DocumentSnapshot? myDocument;
  var allUsers = <DocumentSnapshot>[].obs;
  var filteredUsers = <DocumentSnapshot>[].obs;
  var allEvents = <DocumentSnapshot>[].obs;
  var filteredEvents = <DocumentSnapshot>[].obs;
  var joinedEvents = <DocumentSnapshot>[].obs;

  var isEventsLoading = true.obs;
  var isMessageSending = false.obs;
  var isUsersLoading = false.obs;

  // Controller for the selected role
  var selectedRole = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getMyDocument();
    getUsers();
    getEvents();

    // Listening for changes in the selectedRole
    ever(selectedRole, (role) {
      if (role == 'Student') {
        hideEventCreatedSection();
      } else {
        // Show all events when the role is not "Student"
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
            return eventDate.isAfter(weekStart) && eventDate.isBefore(weekEnd.add(const Duration(days: 1)));
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


// Helper method to parse date string formatted as "DD-MM-YYYY"
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
  void filterEventsByDate(DateTime selectedDate) {
    isEventsLoading.value = true; // Set loading state to true

    String formattedDate = "${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}";

    // Filter the events that match the selected date
    List<DocumentSnapshot> filteredList = allEvents.where((event) {
      String eventDateStr = event.get('date') as String; // Get date as String
      DateTime eventDate = _parseDateString(eventDateStr); // Parse string to DateTime
      return eventDate.year == selectedDate.year &&
          eventDate.month == selectedDate.month &&
          eventDate.day == selectedDate.day;
    }).toList();

    // Update the filteredEvents with the new filtered list
    filteredEvents.assignAll(filteredList);
    isEventsLoading.value = false; // Set loading state to false
  }

  /// Fetch the current user's document
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

  /// Fetch all users
  void getUsers() {
    isUsersLoading(true);
    FirebaseFirestore.instance.collection('users').snapshots().listen((event) {
      allUsers.assignAll(event.docs);
      filteredUsers.assignAll(allUsers);
      isUsersLoading(false);
    });
  }

  /// Fetch all events
  void getEvents() {
    isEventsLoading(true);
    FirebaseFirestore.instance.collection('events').snapshots().listen((event) {
      allEvents.assignAll(event.docs);
      filteredEvents.assignAll(event.docs);

      // Populate joined events for the current user
      joinedEvents.assignAll(allEvents.where((e) {
        List joinedIds = e.get('joined') ?? [];
        return joinedIds.contains(auth.currentUser?.uid);
      }).toList());

      isEventsLoading(false);
    });
  }

  /// Upload image to Firebase Storage
  Future<String> uploadImageToFirebase(File file) async {
    String fileName = Path.basename(file.path);
    var reference = FirebaseStorage.instance.ref().child('myfiles/$fileName');
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    return await taskSnapshot.ref.getDownloadURL();
  }

  /// Upload thumbnail to Firebase Storage
  Future<String> uploadThumbnailToFirebase(Uint8List file) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    var reference = FirebaseStorage.instance.ref().child('myfiles/$fileName.jpg');
    UploadTask uploadTask = reference.putData(file);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    return await taskSnapshot.ref.getDownloadURL();
  }

  /// Send message to Firebase
  Future<void> sendMessageToFirebase({
    required Map<String, dynamic> data,
    required String lastMessage,
    required String groupId,
    required String recipientToken, // The FCM token of the recipient
  }) async {
    isMessageSending(true);

    // Add the message to Firestore
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(groupId)
        .collection('chatroom')
        .add(data);

    await FirebaseFirestore.instance.collection('chats').doc(groupId).set({
      'lastMessage': lastMessage,
      'groupId': groupId,
      'group': groupId.split('-'),
    }, SetOptions(merge: true));

    isMessageSending(false);

    // Send the FCM notification to the recipient
    await sendFCMNotification(
      title: 'New Message',
      body: lastMessage,
      token: recipientToken,
    );
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
  /// Create a notification
  Future<void> createNotification(String recipientUid, String recipientToken) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(recipientUid)
          .collection('myNotifications')
          .add({
        'message': "Sent you a message.",
        'image': myDocument?.get('image') ?? '',
        'name': "${myDocument?.get('first') ?? ''} ${myDocument?.get('last') ?? ''}",
        'time': DateTime.now(),
      });
      print('Notification added successfully');
    } catch (e) {
      print('Error creating notification: $e');
    }

    // Send the FCM notification to the recipient
    await sendFCMNotification(
      title: 'New Message',
      body: 'You have a new message from ${myDocument?.get('first') ?? ''}',
      token: recipientToken,
    );
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

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }


  Future<bool> createEvent(Map<String, dynamic> eventData) async {
    try {
      // Create the event in Firestore
      await FirebaseFirestore.instance.collection('events').add(eventData);

      // Create a notification for the user
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

// Example method to fetch user tokens
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


  /// Hide the Event Created section for students
  void hideEventCreatedSection() {
    filteredEvents.assignAll(allEvents.where((event) {
      return event.get('creatorRole') != 'Student';
    }).toList());
  }
}
