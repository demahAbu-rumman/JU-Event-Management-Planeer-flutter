import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:ju_event_managment_planner/screens/Academycalender.dart';
import 'package:ju_event_managment_planner/screens/MessagesPage.dart';
import 'package:ju_event_managment_planner/screens/notification_page.dart';
import 'package:ju_event_managment_planner/screens/profiles_page.dart';
import '../Util/app_color.dart';
import 'add_event.dart'; // Import your event creation page
import 'calender.dart'; // Import your calendar page
import 'login_and_signup.dart'; // Import your login page

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

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
                fontWeight: FontWeight.w900, // Extra bold
                fontFamily: 'Roboto', // Or any other modern font
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
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Adding Events'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateEventView(
                    event: null, // No event since it's a new event
                    isEditing: false, // False since it's a new event
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
                MaterialPageRoute(builder: (context) => const AcademyCalendarPage()),
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
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              // Handle notifications action
              Navigator.pop(context);
              // Add notification handling here if needed
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  NotificationPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Exit'),
            onTap: () async {
              // Show confirmation dialog
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

              // Perform logout if confirmed
              if (confirmLogout == true) {
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
