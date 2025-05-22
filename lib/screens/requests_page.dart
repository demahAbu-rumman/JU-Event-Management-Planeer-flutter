import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ju_event_managment_planner/screens/notification_service.dart';
import '../Util/app_color.dart';

class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Requested Events',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.lightgreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('eventRequests')
              .orderBy('requestDate', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error loading data.'));
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return const Center(child: Text('No event requests available.'));
            }

            final requests = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>? ?? {};
              return data.containsKey('eventName') && data.containsKey('requestDate');
            }).toList();

            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final doc = requests[index];
                final data = doc.data() as Map<String, dynamic>? ?? {};

                return RequestCard(
                  docId: doc.id,
                  data: data,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;

  const RequestCard({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'Pending';
    final statusColor = status == 'Approved'
        ? Colors.green
        : status == 'Denied'
        ? Colors.red
        : Colors.orange;


    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ExpansionTile(
        title: Text(data['eventName'] ?? 'No Title'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Requested by: ${data['Organization_name'] ?? 'Unknown'}"),
            Text('Status: $status', style: TextStyle(color: statusColor)),

          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                info("Name of the Event", data['eventName']),
                info("Event Type", data['event']),
                info("Name of the Organization", data['Organization_name']),
                info("Location", data['location']),
                info("Event Date", data['date']),
                info("Event Time", "${data['start_time']} - ${data['end_time']}"),
                info("Target Audience", (data['target'] as List?)?.join(', ')),
                info("Support Services", data['Services']),
                info("Description and Objectives", data['description']),
                const Divider(),
                const Text("Supervisor Info", style: TextStyle(fontWeight: FontWeight.bold)),
                info("Name", data['name sup']),
                info("Phone", data['telesup']),
                const Divider(),
                const Text("Student Info", style: TextStyle(fontWeight: FontWeight.bold)),
                info("Name", data['name std']),
                info("ID", data['id']),
                info("College", data['collage']),
                const Divider(),
                const Text("Comments", style: TextStyle(fontWeight: FontWeight.bold)),
                info("Division Head", data['comment']),
                info("Department Director", data['comment1']),
                const Divider(),
                info("Dean", data['name Dean']),
                info("Student Union President", data['Name of the Student Union President']),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _approveRequest(docId, data);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _denyRequest(docId);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Deny'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget info(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        "$label: ${value ?? 'N/A'}",
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
  Future<void> publishEvent({required String eventTitle}) async {
    try {
      final allUsersSnapshot = await FirebaseFirestore.instance.collection('users').get();

      for (var userDoc in allUsersSnapshot.docs) {
        final userId = userDoc.id;
        final fcmToken = userDoc.data()['fcmToken']; // optional

        // Store the notification in Firestore
        await FirebaseFirestore.instance
            .collection('notifications')
            .doc(userId)
            .collection('userNotifications')
            .add({
          'title': 'New Event Published!',
          'body': 'A new event "$eventTitle" has been published. Check it out!',
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });

        // Optional: Send FCM push notification
        if (fcmToken != null && fcmToken.isNotEmpty) {
          await LocalNotificationService.sendNotification(
            title: 'New Event Published!',
            message: 'Check out the latest event "$eventTitle" now!',
            token: fcmToken,
          );
        }
      }

      print('Notifications sent to all users.');
    } catch (e) {
      print('Error notifying users: $e');
    }
  }

  Future<void> _approveRequest(String docId, Map<String, dynamic> data) async {
    try {
      final filteredData = Map<String, dynamic>.from(data)
        ..['instructorApproval'] = true
        ..['status'] = 'Approved'; //

      await FirebaseFirestore.instance.collection('eventRequests').doc(docId).update({
        'instructorApproval': true,
        'status': 'Approved', //
      });

      await FirebaseFirestore.instance.collection('events').add(filteredData);
      Get.snackbar('Approved', 'Event has been approved and added to events.',
          backgroundColor: AppColors.lightgreen, colorText: Colors.white);
      await publishEvent(eventTitle: data['eventName'] ?? 'A new event');

    } catch (e) {
      print("Error approving request: $e");
      Get.snackbar('Error', 'Failed to approve request.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }


  Future<void> _denyRequest(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('eventRequests').doc(docId).update({
        'instructorApproval': false,
        'status': 'Denied', //
      });

      Get.snackbar('Denied', 'Event request denied.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      print("Error denying request: $e");
      Get.snackbar('Error', 'Failed to deny request.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

}
