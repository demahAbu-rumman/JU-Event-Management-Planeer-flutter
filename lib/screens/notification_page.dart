import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ju_event_managment_planner/Model/notification_model.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No notifications yet.'));
          }

          final notifications = snapshot.data!.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(notification.title),
                  subtitle: Text(notification.body),
                  trailing: Text(
                    "${notification.timestamp.day}/${notification.timestamp.month}/${notification.timestamp.year}",
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    // Mark as read or navigate to the relevant page
                    // You can also update the notification in Firestore to mark it as read
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
