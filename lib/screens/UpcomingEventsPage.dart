import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../util/app_color.dart';

class UpcomingEventsSection extends StatefulWidget {
  final String collegeName;
  final Map<String, String> locationToCollegeMap;
  final bool filterByCollege;

  const UpcomingEventsSection({
    Key? key,
    required this.collegeName,
    required this.locationToCollegeMap,
    required this.filterByCollege,
  }) : super(key: key);

  @override
  State<UpcomingEventsSection> createState() => _UpcomingEventsSectionState();
}

class _UpcomingEventsSectionState extends State<UpcomingEventsSection> {
  final Logger _logger = Logger();
  bool _expanded = false;

  Future<List<DocumentSnapshot>> _fetchUpcomingEvents() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .orderBy('date')
          .get();

      if (!widget.filterByCollege) {
        final now = DateTime.now();
        return querySnapshot.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final date = _parseDateFromString(data['date']);
          if (date == null) return false;
          return date.isAfter(now) || _isSameDay(date, now);
        }).toList();
      }

      final filteredEvents = querySnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final location = (data['location'] ?? '').toString();
        final college = (data['college'] ?? '').toString();

        if (college.toLowerCase() == widget.collegeName.toLowerCase()) {
          return true;
        }

        final mappedCollege = widget.locationToCollegeMap.entries
            .firstWhere(
              (e) => location.toLowerCase().contains(e.key.toLowerCase()),
          orElse: () => const MapEntry('', ''),
        )
            .value;

        return mappedCollege.toLowerCase() == widget.collegeName.toLowerCase();
      }).toList();

      final now = DateTime.now();
      return filteredEvents.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final date = _parseDateFromString(data['date']);
        return date != null && (date.isAfter(now) || _isSameDay(date, now));
      }).toList();
    } catch (e) {
      _logger.e("Error fetching events: $e");
      return [];
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime? _parseDateFromString(dynamic rawDate) {
    if (rawDate is String) {
      try {
        final parts = rawDate.split('-');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      } catch (e) {
        _logger.e("Invalid date string format: $rawDate");
      }
    }
    return null;
  }

  DateTime? _labelToDate(String label) {
    final now = DateTime.now();
    if (label == 'Today') return DateTime(now.year, now.month, now.day);
    if (label == 'Tomorrow') {
      final tomorrow = now.add(const Duration(days: 1));
      return DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    }

    try {
      final parts = label.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _fetchUpcomingEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data ?? [];

        final groupedEvents = <String, List<DocumentSnapshot>>{};
        final now = DateTime.now();

        for (var doc in events) {
          final data = doc.data() as Map<String, dynamic>;
          DateTime? date = _parseDateFromString(data['date']);
          if (date == null) continue;

          String label;
          if (_isSameDay(date, now)) {
            label = 'Today';
          } else if (_isSameDay(date, now.add(const Duration(days: 1)))) {
            label = 'Tomorrow';
          } else {
            label = '${date.day}/${date.month}/${date.year}';
          }

          groupedEvents.putIfAbsent(label, () => []).add(doc);
        }

        final allEventsList = (groupedEvents.entries.toList()
          ..sort((a, b) {
            if (a.key == 'Today') return -1;
            if (b.key == 'Today') return 1;
            final aDate = _labelToDate(a.key);
            final bDate = _labelToDate(b.key);
            return (aDate ?? DateTime.now()).compareTo(bDate ?? DateTime.now());
          }));

        final displayEvents = _expanded ? allEventsList : allEventsList.take(1).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Upcoming Events",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (events.isNotEmpty)
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

            if (events.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    "No upcoming events available!",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayEvents.length,
                itemBuilder: (context, index) {
                  final entry = displayEvents[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...entry.value.map((doc) => _buildEventCard(doc)).toList(),
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

  Widget _buildEventCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final title = data['eventName'] ?? 'Untitled';
    final desc = data['description'] ?? '';
    final location = data['location'] ?? '';
    final date = _parseDateFromString(data['date']);
    if (date == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.teal),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.teal),
              const SizedBox(width: 6),
              Text(
                '${data['start_time'] ?? 'N/A'} - ${data['end_time'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 14),
              ),
              const Spacer(),
              Text(
                '${date.day}/${date.month}/${date.year}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
