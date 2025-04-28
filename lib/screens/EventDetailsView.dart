import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ju_event_managment_planner/Util/app_color.dart';
import 'package:ju_event_managment_planner/controller/data_controller.dart';
import 'package:ju_event_managment_planner/screens/add_event.dart';
import 'package:ju_event_managment_planner/screens/home_page.dart';

class EventDetailsView extends StatefulWidget {
  DocumentSnapshot event;
  EventDetailsView({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailsViewState createState() => _EventDetailsViewState();
}

class _EventDetailsViewState extends State<EventDetailsView> {
  final DataController dataController = Get.find();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String? userRole;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
  }

  // Fetch user role from Firestore
  Future<void> fetchUserRole() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (userDoc.exists) {
        setState(() {
          userRole = userDoc['role'];
          print('User role fetched: $userRole');
        });
      } else {
        print('User document does not exist!');
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  Future<void> refreshEventData() async {
    DocumentSnapshot updatedEvent = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.event.id)
        .get();
    setState(() {
      widget.event = updatedEvent;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading spinner while user role is being fetched
    if (userRole == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightgreen,
        centerTitle: true,
        title: const Text(
          'Event Detail',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: const Color(0xFFFAFAFA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    widget.event['event_name'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                buildInfoRow(
                    Icons.location_on, 'Location', widget.event['location']),
                buildInfoRow(
                    Icons.calendar_today, 'Date', widget.event['date']),
                buildInfoRow(Icons.access_time, 'Time',
                    '${widget.event['start_time']} - ${widget.event['end_time']}'),
                buildInfoRow(Icons.description, 'Description',
                    widget.event['description']),

                const SizedBox(height: 16),
                if (widget.event['media'] != null &&
                    widget.event['media'].isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Media:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...widget.event['media'].map<Widget>((media) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              media['isImage']
                                  ? media['url']
                                  : media['thumbnail'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),

                // Show Join Button for Students or Instructors
                if (userRole == 'Student' || userRole == 'Instructor')
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        // Join event logic here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightgreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Join Event'),
                    ),
                  ),

                // Show Edit/Delete buttons only if current user is event owner
                if (widget.event['uid'] == currentUserId)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: AppColors.lightgreen),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateEventView(
                                event: widget.event,
                                isEditing: true,
                              ),
                            ),
                          ).then((value) {
                            if (value == true) {
                              refreshEventData();
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: AppColors.lightgreen),
                        onPressed: () {
                          deleteEvent(widget.event.id);
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => HomePage()));
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 16),
                children: [
                  TextSpan(
                      text: '$label: ',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .delete();
      Get.snackbar('Success', 'Event deleted successfully',
          colorText: Colors.white, backgroundColor: Colors.green);
    } catch (e) {
      print("Error deleting event: $e");
      Get.snackbar('Error', 'Failed to delete event: $e',
          colorText: Colors.white, backgroundColor: Colors.red);
    }
  }
}
