import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'Util/app_color.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Use AppColors for background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "HOME",
          style: TextStyle(
            color: AppColors.lightgreen, // Use darkGreen for the title color
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu, color: AppColors.lightgreen), // Use darkGreen for the icon
          onPressed: () {
            // Open menu
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: AssetImage(
                        'lib/asset/homephoto1.png', // Replace with your image
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
                Positioned(
                  left: 30,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "King Abdullah II Auditorium",
                        style: TextStyle(
                          color: AppColors.white, // Use white color
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Amman, Jordan",
                        style: TextStyle(
                          color: AppColors.white, // Use white color for subtext
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilterButton(text: "Today"),
                  FilterButton(text: "Tomorrow"),
                  FilterButton(text: "This Week"),
                  FilterButton(text: "This Month"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  EventCard(
                    eventName: "College of Medicine doctors meeting",
                    eventDate: "21 Jan 2019",
                    image: Image.asset(
                      'lib/asset/homephoto2.png',
                      fit: BoxFit.cover,
                      height: 180,
                      width: double.infinity,
                    ),
                  ),
                  EventCard(
                    eventName: "ISO award for the University of Jordan",
                    eventDate: "27 Apr 2022",
                    image: Image.asset(
                      'lib/asset/homephoto3.png',
                      fit: BoxFit.cover,
                      height: 180,
                      width: double.infinity,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Text(
                "UpComing Events",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black, // Use black from AppColors
                ),
              ),
            ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TableCalendar for upcoming events
            TableCalendar(
              firstDay: DateTime.utc(2020, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: DateTime.now(),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.lightgreen, // Light green for today's highlight
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.darkGreen, // Dark green for selected day
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 20), // Spacing
          ],
        ),
      )])),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.white, // Use white from AppColors
        selectedItemColor: AppColors.darkGreen, // Use darkGreen for selected items
        unselectedItemColor: AppColors.grey, // Use grey for unselected items
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String text;

  const FilterButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightgreen, // Use darkGreen for button background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      onPressed: () {},
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.white, // Use white for button text
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String eventName;
  final String eventDate;
  final Widget image;

  const EventCard({
    super.key,
    required this.eventName,
    required this.eventDate,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          image,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              eventName,
              style: TextStyle(fontSize: 18, color: AppColors.black), // Use black for event name
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              eventDate,
              style: TextStyle(color: AppColors.grey), // Use grey for event date
            ),
          ),
        ],
      ),
    );
  }
}
