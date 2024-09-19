import 'package:flutter/material.dart';
import 'Util/app_color.dart';
import 'add_event.dart';
import 'calender.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedFilterIndex = 1; // Default to "Week"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Updated AppBar with background image and gradient
          Container(
            height: 250,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('lib/asset/2.png'), // Use the entire image as background
                fit: BoxFit.cover,
                opacity: 0.7, // Reduce the opacity of the image
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 60), // Space for status bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "JU Planner",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5, // Add some letter spacing for professionalism
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Tabs for Today, Week, Month, Year
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        buildFilterTab(0, "Today"),
                        buildFilterTab(1, "Week"),
                        buildFilterTab(2, "Month"),
                        buildFilterTab(3, "Year"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Today, 25 June, Saturday",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Rest of the UI like event cards...
          Expanded(
            child: ListView(
              children: [
                EventCard(
                  eventName: "Meeting with Aunt Lily",
                  eventTime: "01 PM - 02 PM",
                  location: "Birch Grove Str.",
                  tag: "Soon!",
                  icon: Icons.notifications_active,
                  iconColor: Colors.redAccent,
                ),
                EventCard(
                  eventName: "Rammstein Concert",
                  eventTime: "09 PM - 10 PM",
                  location: "Dark Stage, USA",
                  icon: Icons.location_on,
                  iconColor: AppColors.grey,
                ),
                EventCard(
                  eventName: "Starting Events",
                  eventTime: "05 PM - 06 PM",
                  location: "USA",
                  icon: Icons.location_on,
                  iconColor: AppColors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.darkGreen,
        unselectedItemColor: AppColors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateEventView(),
              ),
            );
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CalendarPage(),
              ),
            );
          }
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              ),
            );
          }
        },


        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Function to build each tab
  Widget buildFilterTab(int index, String text) {
    bool isSelected = index == _selectedFilterIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isSelected ? Color(0xFF5E2587) : AppColors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 40,
              color: Color(0xFF5E2587), // Purple underline
            ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String eventName;
  final String eventTime;
  final String location;
  final String? tag; // Optional tag like "Soon!"
  final IconData icon;
  final Color iconColor;

  const EventCard({
    super.key,
    required this.eventName,
    required this.eventTime,
    required this.location,
    this.tag,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    eventName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
                if (tag != null)
                  Row(
                    children: [
                      Text(
                        tag!,
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        icon,
                        color: iconColor,
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: AppColors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  eventTime,
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  location,
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
