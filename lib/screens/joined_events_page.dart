import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../util/app_color.dart';

class JoinedEventsSection extends StatefulWidget {
  final String userId;

  const JoinedEventsSection({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<JoinedEventsSection> createState() => _JoinedEventsSectionState();
}

class _JoinedEventsSectionState extends State<JoinedEventsSection> {
  final Logger _logger = Logger();
  bool _showAll = false;

  Future<List<DocumentSnapshot>> _fetchJoinedEvents() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .orderBy('date')
          .get();

      final now = DateTime.now();

      final filtered = querySnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final joinedUsers = (data['joinedUsers'] ?? []) as List<dynamic>;

        DateTime? eventDate;
        final rawDate = data['date'];
        if (rawDate is Timestamp) {
          eventDate = rawDate.toDate();
        } else if (rawDate is String) {
          eventDate = _parseDateFromString(rawDate);
        }

        if (eventDate == null) {
          _logger.w("Event: ${data['eventName']} - Date is null");
          return false;
        }

        final containsUser = joinedUsers.contains(widget.userId);
        final dateValid = eventDate.isAfter(now) || _isSameDay(eventDate, now);

        return containsUser && dateValid;
      }).toList();

      return filtered;
    } catch (e) {
      _logger.e("Error fetching joined events: $e");
      return [];
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime? _parseDateFromString(String rawDate) {
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
    return null;
  }

  DateTime? _labelToDate(String label) {
    final now = DateTime.now();
    if (label == 'Today') return DateTime(now.year, now.month, now.day);
    if (label == 'Tomorrow') return DateTime(now.year, now.month, now.day + 1);

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

  Future<void> _removeUserFromEvent(String eventId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Removal'),
        content: const Text('Are you sure you want to remove yourself from this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, remove me'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final docRef = FirebaseFirestore.instance.collection('events').doc(eventId);

      await docRef.update({
        'joinedUsers': FieldValue.arrayRemove([widget.userId])
      });

      setState(() {}); // Refresh UI

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have been removed from the event.')),
      );
    } catch (e) {
      _logger.e('Error removing user from event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove from event.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _fetchJoinedEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              "You haven't joined any events.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          );
        }

        final groupedEvents = <String, List<DocumentSnapshot>>{};
        final now = DateTime.now();

        for (var doc in snapshot.data!) {
          final data = doc.data() as Map<String, dynamic>;

          final rawDate = data['date'];
          DateTime? date;

          if (rawDate == null) continue;
          if (rawDate is Timestamp) {
            date = rawDate.toDate();
          } else if (rawDate is String) {
            date = _parseDateFromString(rawDate);
          }

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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              child: Container(
                constraints: _showAll ? null : const BoxConstraints(maxHeight: 400),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: (groupedEvents.entries.toList()
                    ..sort((a, b) {
                      if (a.key == 'Today') return -1;
                      if (b.key == 'Today') return 1;
                      final aDate = _labelToDate(a.key);
                      final bDate = _labelToDate(b.key);
                      return (aDate ?? DateTime.now()).compareTo(bDate ?? DateTime.now());
                    }))
                      .map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        ...entry.value.map((doc) => _buildEventCard(doc)),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() => _showAll = !_showAll);
            },
            child: Text(
              _showAll ? 'Collapse' : 'View All',
              style: TextStyle(
                color: AppColors.lightgreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final title = data['eventName'] ?? 'Untitled';
    final desc = data['description'] ?? '';
    final location = data['location'] ?? '';

    final rawDate = data['date'];
    DateTime? date;
    if (rawDate == null) return const SizedBox();
    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else if (rawDate is String) {
      date = _parseDateFromString(rawDate);
    }

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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeUserFromEvent(doc.id),
              ),
            ],
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
              Icon(Icons.location_on, size: 16, color: AppColors.lightgreen),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: AppColors.lightgreen),
              const SizedBox(width: 6),
              Text(
                '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 14),
              ),
              const Spacer(),
              Text(
                '${date.day}/${date.month}/${date.year}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.lightgreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
