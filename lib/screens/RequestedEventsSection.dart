import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Util/app_color.dart';

class RequestedEventsSection extends StatelessWidget {
  final String? collegeName;
  final Map<String, String> locationToCollegeMap;
  final bool filterByCollege;

  const RequestedEventsSection({
    Key? key,
    required this.collegeName,
    required this.locationToCollegeMap,
    required this.filterByCollege,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('eventRequests')
          .orderBy('requestDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No requested events found."));
        }

        final requestedEvents = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          if (filterByCollege && collegeName != null) {
            final location = data['location'];
            final mappedCollege = locationToCollegeMap[location];
            if (mappedCollege != collegeName) return false;
          }

          // Keep only pending requests
          return data['status'] == 'Pending';
        }).toList();

        if (requestedEvents.isEmpty) {
          return SizedBox(
            height: 150, // Adjust this height as needed
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "No pending events found  !",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requestedEvents.length,
          itemBuilder: (context, index) {
            final event = requestedEvents[index].data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: ListTile(
                title: Text(event['eventName'] ?? 'No name for the event'),
                subtitle: Text("Requested by: ${event['Organization_name'] ?? 'Unknown'}"),
                trailing: Text(
                  event['status'],
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
