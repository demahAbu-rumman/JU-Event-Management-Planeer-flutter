import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

   RequestCard({
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
                info("Support Services", data['services']),
                info("Description and Objectives", data['description']),
                const Divider(),
                const Text("Supervisor Info", style: TextStyle(fontWeight: FontWeight.bold)),
                info("Name", data['name_sup']),
                info("Phone", data['telesup']),
                const Divider(),

                const Text("Student Info", style: TextStyle(fontWeight: FontWeight.bold)),

                info("Name", data['name std']),
                info("ID", data['id']),
                info("College", data['collage']),
                const Divider(),

                const Text("Comments", style: TextStyle(fontWeight: FontWeight.bold)),
                info("Comments of the Relevant Division Head", data['comment']),
                info("Comments of the Relevant Department Director", data['comment1']),
                const Divider(),
                info("Dean", data['name_Dean']),
                info("Student Union President", data['nameof_theStudentUnionPresident']),
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
      final allUsersSnapshot =
      await FirebaseFirestore.instance.collection('users').get();

      for (var userDoc in allUsersSnapshot.docs) {
        final userId = userDoc.id;

        await LocalNotificationService.storeNotification(
          title: 'New Event Published!',
          body: 'A new event "$eventTitle" has been published. Check it out!',
          userId: userId,
        );

      }

      print('Notifications sent to all users.');
    } catch (e) {
      print('Error notifying users: $e');
    }
  }

  final Map<String, List<String>> schoolToColleges = {
    'School of Medicine': ['مدرج1 - كلية الطب'],
    'School of Engineering': ['مدرج سعيد المفتي - كلية الهندسة'],
    'School of Arts': [
      'مدرج الكندي - كلية الاداب',
      'مدرج ابن خلدون - كلية الاداب',
      'مدرج الفراهيدي - كلية الاداب'
    ],
    'School of Science': ['كلية العلوم'],
    'School of Nursing': [
      'مدرج ابن سينا - كلية التمريض',
      'مرج القدس - كلية التمريض'
    ],
    'School of Pharmacy': ['كلية الصيدلة'],
    'School of Law': ['كلية الحقوق'],
    'King Abdullah II School of Information Technology': [
      'مدرج اللوزي _ كلية الملك عبدلله الثاني لتكنولوجيا المعلومات'
    ],
    'School of Business': [
      'مدرج1 - كلية الاعمال',
      'مدرج الاعمال الكبير - كلية الاعمال'
    ],
    'School of Arts and Design': ['مدرج الموسيقى - كلية الفنون'],
    'School of Shari\'a': ['مدرج الخياط _ كلية الشريعة'],
    'Deanship of Student Affairs': ['مدرج الحسن - عمادة الشؤوون الطلبة'],
    'School of Dentistry': ['مدرج بهجت التهلوني - مجمع القاعات الطبية'],
    'School of Educational Sciences': ['مدرج الايمن - كلية التربية'],
  };

  Future<void> _approveRequest(String docId, Map<String, dynamic> data) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'No logged-in user found',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final userData = userSnapshot.data();
      final userRole = userData?['role'];
      final userCollege = userData?['collegeName'];

      final requesterRole = data['role'];
      final eventLocation = data['location'];
      final userId = data['uid'];
      final eventTitle = data['eventName'] ?? 'Your event';

      final docRef = FirebaseFirestore.instance.collection('eventRequests').doc(docId);
      final docSnap = await docRef.get();
      final currentData = docSnap.data() ?? {};


      if (requesterRole == 'Event Organizer' && userRole != 'Activities Director') {
        Get.snackbar('Access Denied',
            'Only Activities Director can approve Event Organizer requests.',
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }


      if (userRole == 'Vice Dean') {
        final allowedColleges = schoolToColleges[userCollege] ?? [];
        if (!allowedColleges.contains(eventLocation)) {
          Get.snackbar('Permission Denied',
              'Vice Deans can only approve events in their own college locations.',
              backgroundColor: Colors.orange, colorText: Colors.white);
          return;
        }
      }

      if (userRole != 'Vice Dean' && userRole != 'Activities Director') {
        Get.snackbar('Access Denied',
            'Only Vice Dean or Activities Director can approve events.',
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      final isViceDean = userRole == 'Vice Dean';
      final isActivitiesDirector = userRole == 'Activities Director';

      Map<String, dynamic> updateData = {};
      bool shouldPublish = false;

      if (isViceDean) {
        updateData['viceDeanApproval'] = true;
      } else if (isActivitiesDirector) {
        updateData['activitiesDirectorApproval'] = true;
      }
      final hasViceDeanApproval = isViceDean || currentData['viceDeanApproval'] == true;
      final hasActivitiesApproval = isActivitiesDirector || currentData['activitiesDirectorApproval'] == true;

      if (hasViceDeanApproval && hasActivitiesApproval) {
        updateData['status'] = 'Approved';
        shouldPublish = true;
      }

      await docRef.update(updateData);

      if (shouldPublish) {
        await FirebaseFirestore.instance.collection('events').add({
          ...data,
          'status': 'Approved',
          'instructorApproval': true,
        });

        await LocalNotificationService.storeNotification(
          title: 'Event Approved!',
          body: 'Your event "$eventTitle" has been approved.',
          userId: userId,
        );

        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        final fcmToken = userDoc.data()?['fcmToken'];

        if (fcmToken != null && fcmToken.isNotEmpty) {
          await LocalNotificationService.sendNotification(
            title: 'Event Approved',
            message: 'Your event "$eventTitle" has been approved!',
            token: fcmToken,
          );
        }

        Get.snackbar('Approved', 'Event has been approved and published.',
            backgroundColor: AppColors.lightgreen, colorText: Colors.white);
        await publishEvent(eventTitle: eventTitle);
      } else {
        Get.snackbar('Partially Approved',
            'Approval registered. Waiting for the other approver.',
            backgroundColor: Colors.orange, colorText: Colors.white);
      }
    } catch (e) {
      print("Error approving request: $e");
      Get.snackbar('Error', 'Failed to approve request.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }


  Future<void> _denyRequest(String docId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar('Error', 'No logged-in user found',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final userData = userSnapshot.data();
      final userRole = userData?['role'];
      final userCollege = userData?['collegeName'];

      final docRef = FirebaseFirestore.instance.collection('eventRequests').doc(docId);
      final docSnap = await docRef.get();
      final data = docSnap.data() ?? {};

      final requesterRole = data['role'];
      final requesterCollege = data['collage'];
      final userId = data['userId'];
      final eventTitle = data['eventName'] ?? 'Your event';

      // Permission checks
      if (requesterRole == 'Event Organizer' && userRole != 'Activities Director') {
        Get.snackbar('Access Denied',
            'Only Activities Director can deny Event Organizer requests.',
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      if (userRole == 'Vice Dean' && userCollege != requesterCollege) {
        Get.snackbar('Permission Denied',
            'Vice Deans can only deny events from their own college.',
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      if (userRole != 'Vice Dean' && userRole != 'Activities Director') {
        Get.snackbar('Access Denied',
            'Only Vice Dean or Activities Director can deny events.',
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      await docRef.update({
        'status': 'Denied',
        'instructorApproval': false,
      });

      await LocalNotificationService.storeNotification(
        title: 'Event Denied',
        body: 'Your event "$eventTitle" was not approved.',
        userId: userId,
      );

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final fcmToken = userDoc.data()?['fcmToken'];

      if (fcmToken != null && fcmToken.isNotEmpty) {
        await LocalNotificationService.sendNotification(
          title: 'Event Denied',
          message: 'Your event "$eventTitle" was not approved.',
          token: fcmToken,
        );
      }

      Get.snackbar('Denied', 'Event request has been denied.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      print("Error denying request: $e");
      Get.snackbar('Error', 'Failed to deny request.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }


}
