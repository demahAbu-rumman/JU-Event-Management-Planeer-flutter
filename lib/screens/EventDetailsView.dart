import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ju_event_managment_planner/controller/data_controller.dart';
import 'package:ju_event_managment_planner/screens/add_event.dart';
import 'package:ju_event_managment_planner/screens/home_page.dart';

class EventDetailsView extends StatefulWidget {
  final DocumentSnapshot event;

  const EventDetailsView({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailsViewState createState() => _EventDetailsViewState();
}

class _EventDetailsViewState extends State<EventDetailsView> {
  final DataController dataController = Get.find();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event['event_name']),
        actions: [
          if (widget.event['uid'] == currentUserId)
            MaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEventView(
                      event: widget.event, // البيانات القديمة
                      isEditing: true, // تمييز أن الصفحة في وضع التعديل
                    ),
                  ),
                ).then((value) {
                  // يتم تنفيذ هذا الكود عند العودة من CreateEventView
                  if (value == true) {
                    // إذا تم التحديث بنجاح، قم بتحديث الصفحة الحالية
                    setState(() {});
                  }
                });
              },
              child: Icon(Icons.edit),
            ),
          if (widget.event['uid'] == currentUserId)
            MaterialButton(
              onPressed: () {
                if (widget.event != null) {
                  print(
                      "Deleting event with ID: ${widget.event.id}"); // استخدام widget.event.id بدلاً من widget.event['id']
                  deleteEvent(widget.event.id);
                  Get.snackbar('Success', 'Event deleted successfully',
                      colorText: Colors.white, backgroundColor: Colors.green);

                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomePage()));
                } else {
                  print("No event to delete.");
                }
              },
              child: Icon(Icons.delete),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event['event_name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Location: ${widget.event['location']}'),
            SizedBox(height: 8),
            Text('Date: ${widget.event['date']}'),
            SizedBox(height: 8),
            Text(
                'Time: ${widget.event['start_time']} - ${widget.event['end_time']}'),
            SizedBox(height: 8),
            Text('Description: ${widget.event['description']}'),
            SizedBox(height: 8),
            Text('Price: ${widget.event['price']}'),
            SizedBox(height: 8),
            Text('Max Entries: ${widget.event['max_entries']}'),
            SizedBox(height: 8),
            Text('Frequency: ${widget.event['frequency_of_event']}'),
            SizedBox(height: 8),
            Text('Who can invite: ${widget.event['who_can_invite']}'),
            SizedBox(height: 16),
            if (widget.event['media'] != null &&
                widget.event['media'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Media:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ...widget.event['media'].map<Widget>((media) {
                    if (media['isImage']) {
                      return Image.network(media['url']);
                    } else {
                      return Image.network(media['thumbnail']);
                    }
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .delete();
      print("Event deleted successfully");
      Get.snackbar('Success', 'Event deleted successfully',
          colorText: Colors.white, backgroundColor: Colors.green);
    } catch (e) {
      print("Error deleting event: $e");
      Get.snackbar('Error', 'Failed to delete event: $e',
          colorText: Colors.white, backgroundColor: Colors.red);
    }
  }
}
