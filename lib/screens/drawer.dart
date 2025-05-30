import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:ju_event_managment_planner/screens/Academycalender.dart';
import 'package:ju_event_managment_planner/screens/ITSupport.dart';
import 'package:ju_event_managment_planner/screens/MessagesPage.dart';
import 'package:ju_event_managment_planner/screens/notification_page.dart';
import 'package:ju_event_managment_planner/screens/profiles_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Util/app_color.dart';
import 'add_event.dart';
import 'calender.dart';
import 'requests_page.dart';
import 'login_and_signup.dart';
import '../controller/data_controller.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final dataController = Get.find<DataController>();
    if (dataController.myDocument != null &&
        dataController.myDocument!.exists) {
      setState(() {
        _userRole = dataController.myDocument!.get('role');
      });
    }
  }

  bool _shouldShowCreateEvent() {
    return _userRole != 'Student';
  }

  Future<void> _submitFeedback(String feedback) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('feedback').add({
          'userId': user.uid,
          'feedback': feedback,
          'role': _userRole,
          'timestamp': FieldValue.serverTimestamp(),
        });
        Get.snackbar(
          'Thank you!',
          'Your feedback has been submitted',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit feedback',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
            ),
            child: const Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                fontFamily: 'Roboto',
                shadows: [
                  Shadow(
                    blurRadius: 6.0,
                    color: Colors.black87,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
                letterSpacing: 1.5,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          if (_shouldShowCreateEvent())
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Create Events'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEventView(
                      event: null,
                      isEditing: false,
                    ),
                  ),
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Calendar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_rounded),
            title: const Text('Academic Calendar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AcademyCalendarPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Messages'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MessagesPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Profiles_Page()),
              );
            },
          ),
          ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('IT Support'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ItSupportPage()),
                );
              }),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
          ),
          if (_userRole == 'Vice Dean' || _userRole == 'Activities Director')
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Event Requests'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RequestsPage(),
                  ),
                );
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Exit'),
            onTap: () async {
              final feedback = await showDialog<String>(
                context: context,
                builder: (context) => FeedbackDialog(),
              );

              bool? confirmLogout = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );

              if (confirmLogout == true) {
                if (feedback != null && feedback.isNotEmpty) {
                  await _submitFeedback(feedback);
                }
                await FirebaseAuth.instance.signOut();
                Get.to(() => const LoginView());
              }
            },
          ),
        ],
      ),
    );
  }
}

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _feedbackController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _rating = 0;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('We value your feedback!'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How would you rate your experience?'),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    5,
                    (index) => IconButton(
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 30,
                          ),
                          onPressed: () => setState(() => _rating = index + 1),
                        )),
              ),
              const SizedBox(height: 20),
              const Text('Any suggestions or comments?'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _feedbackController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Please share your experience or suggestions...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your feedback';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Skip'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final feedback = {
                'text': _feedbackController.text,
                'rating': _rating,
              };
              Navigator.of(context).pop(jsonEncode(feedback));
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
