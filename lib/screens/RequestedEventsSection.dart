import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Util/app_color.dart';

class RequestedEventsSection extends StatefulWidget {
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
  State<RequestedEventsSection> createState() => _RequestedEventsSectionState();
}

class _RequestedEventsSectionState extends State<RequestedEventsSection> {
  bool _expanded = false;

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

          if (widget.filterByCollege && widget.collegeName != null) {
            final location = data['location'];
            final mappedCollege = widget.locationToCollegeMap[location];
            if (mappedCollege != widget.collegeName) return false;
          }

          return data['status'] == 'Pending';
        }).toList();

        if (requestedEvents.isEmpty) {
          return SizedBox(
            height: 150,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "No pending events found!",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final displayEvents = _expanded
            ? requestedEvents
            : requestedEvents.take(1).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title + View All / Collapse
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Requested Events",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _expanded = !_expanded;
                      });
                    },
                    child: Text(
                      _expanded ? 'Collapse' : 'View All',
                      style: TextStyle(color: AppColors.lightgreen),
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayEvents.length,
              itemBuilder: (context, index) {
                final event = displayEvents[index].data() as Map<String, dynamic>;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: ListTile(
                    title: Text(event['eventName'] ?? 'No name for the event'),
                    subtitle: Text("Requested by: ${event['Organization_name'] ?? 'Unknown'}"),
                    trailing: Text(
                      event['status'],
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
