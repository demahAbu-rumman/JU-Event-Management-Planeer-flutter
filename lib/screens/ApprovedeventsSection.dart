import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ApprovedActivitiesSection extends StatefulWidget {
  final String? collegeName;
  final Map<String, String> locationToCollegeMap;
  final bool filterByCollege;

  const ApprovedActivitiesSection({
    Key? key,
    required this.collegeName,
    required this.locationToCollegeMap,
    required this.filterByCollege,
  }) : super(key: key);

  @override
  State<ApprovedActivitiesSection> createState() => _ApprovedActivitiesSectionState();
}

class _ApprovedActivitiesSectionState extends State<ApprovedActivitiesSection> {
  Future<List<DocumentSnapshot>> _fetchApprovedEvents() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .orderBy('date', descending: true)
        .get();

    final docs = snapshot.docs.where((doc) {
      if (!widget.filterByCollege) return true;

      final data = doc.data() as Map<String, dynamic>;
      final location = (data['location'] ?? '').toString().trim();
      final eventCollege = widget.locationToCollegeMap.entries.firstWhere(
            (entry) => location.toLowerCase().contains(entry.key.toLowerCase()),
        orElse: () => const MapEntry('', ''),
      ).value;

      return eventCollege.toLowerCase() == widget.collegeName?.toLowerCase();
    }).toList();

    return docs;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _fetchApprovedEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No approved events available.'),
          );
        }

        final events = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final data = events[index].data() as Map<String, dynamic>;

                final eventName = data['eventName'] ?? 'Untitled Event';
                final location = data['location'] ?? 'N/A';
                final dateValue = data['date'];
                String formattedDate = 'N/A';

                if (dateValue is Timestamp) {
                  formattedDate = dateValue.toDate().toString().split(' ')[0];
                }

                final startTime = data['start_time'] ?? 'N/A';
                final endTime = data['end_time'] ?? 'N/A';

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Approved and Published",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '$startTime - $endTime',
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    ],
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
