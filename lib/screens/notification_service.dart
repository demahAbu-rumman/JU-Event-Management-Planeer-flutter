import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class LocalNotificationService {
  static String serverKey = '';
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize() {
    const InitializationSettings initializationSettings =
    InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/ic_launcher"));
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void display(RemoteMessage message) async {
    try {
      print("In Notification method");
      Random random = Random();
      int id = random.nextInt(1000);
      const NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            "mychanel",
            "my chanel",
            importance: Importance.max,
            priority: Priority.high,
          )

      );
      print("my id is ${id.toString()}");
      await _flutterLocalNotificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,);
    } on Exception catch (e) {
      print('Error>>>$e');
    }
  }

  static Future<void> sendNotification(
      {String? title, String? message, String? token}) async {
    print("\n\n\n\n\n\n\n\n\n\n\n\n");
    print("token is $token");
    print("\n\n\n\n\n\n\n\n\n\n\n\n");

    final data = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      'message': message
    };

    try {
      http.Response r = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':

          'key=$serverKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{'body': message, 'title': title},
            'priority': 'high',
            'data': data,
            "to": "$token"
          },
        ),
      );

      print(r.body);
      if (r.statusCode == 200) {
        print('Done');
      } else {
        print(r.statusCode);
      }
    } catch (e) {
      print('exception $e');
    }
  }


  static storeToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      print(token);
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({'fcmToken': token!}, SetOptions(merge: true));
    } catch (e) {
      print("error is $e");
    }
  }

  static Future<void> storeNotification({
    required String title,
    required String body,
    required String userId,
  }) async {
    try {
      print("Storing notification for user: $userId");
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(userId)
          .collection('userNotifications')
          .add({
        'title': title,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'userId': userId,
      });
      print("Notification stored successfully");
    } catch (e) {
      print("Error storing notification: $e");
    }
  }
}