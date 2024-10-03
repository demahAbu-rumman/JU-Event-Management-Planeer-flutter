import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ju_event_managment_planner/Model/notification_model.dart';
import '../Util/app_color.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightgreen,
        title: Text('Notifications', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('userNotifications')
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
                color: notification.isRead ? Colors.white : AppColors.lightgreen.withOpacity(0.1),
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Icon(Icons.notifications, color: AppColors.lightgreen),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    notification.body,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  trailing: Text(
                    "${notification.timestamp.day}/${notification.timestamp.month}/${notification.timestamp.year}",
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () async {
                    await _markAsRead(notification);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('userNotifications')
        .doc(notification.id)
        .update({'isRead': true});
  }
}
