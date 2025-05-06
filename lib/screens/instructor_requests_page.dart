import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Util/app_color.dart';

class InstructorRequestsPage extends StatelessWidget {
  const InstructorRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Requests"),
        backgroundColor: AppColors.lightgreen,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('eventRequests')
            .orderBy('requestDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pending event requests.'));
          }

          final requests = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return !data.containsKey('instructorApproval') || data['instructorApproval'] == null;
          }).toList();

          if (requests.isEmpty) {
            return const Center(child: Text('No pending event requests.'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ExpansionTile(
                  title: Text(data['event_name'] ?? 'No Title'),
                  subtitle: Text("Requested by: ${data['name std'] ?? 'Unknown'}"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          info("Event Type", data['event']),
                          info("Name of the Organization", data['event_name']),
                          info("Location", data['location']),
                          info("Event Date", data['date']),
                          info("Event Time", "${data['start_time']} - ${data['end_time']}"),
                          info("Target Audience", (data['target'] as List<dynamic>?)?.join(', ')),
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
                                  await approveRequest(doc.id, data);
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
                                  await FirebaseFirestore.instance
                                      .collection('eventRequests')
                                      .doc(doc.id)
                                      .update({'instructorApproval': false});
                                  Get.snackbar('Denied', 'Event request denied.',
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white);
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
            },
          );
        },
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

  Future<void> approveRequest(String docId, Map<String, dynamic> data) async {
    try {
      final filteredData = {
        'event': data['event'],
        'event_name': data['event_name'],
        'location': data['location'],
        'date': data['date'],
        'start_time': data['start_time'],
        'end_time': data['end_time'],
        'target': data['target'],
        'Services': data['Services'],
        'description': data['description'],
        'name sup': data['name sup'],
        'telesup': data['telesup'],
        'name std': data['name std'],
        'id': data['id'],
        'collage': data['collage'],
        'comment': data['comment'],
        'comment1': data['comment1'],
        'name Dean': data['name Dean'],
        'Name of the Student Union President': data['Name of the Student Union President'],
        'instructorApproval': true,
        'requestDate': data['requestDate'],
      };

      print("Sending to events: $filteredData");

      await FirebaseFirestore.instance.collection('events').add(filteredData);
      await FirebaseFirestore.instance
          .collection('eventRequests')
          .doc(docId)
          .update({'instructorApproval': true});

      Get.snackbar('Approved', 'Event has been approved and published.',
          backgroundColor: AppColors.lightgreen, colorText: Colors.white);
    } catch (e) {
      print("Error approving request: $e");
      Get.snackbar('Error', 'Failed to approve request.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
