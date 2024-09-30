import 'package:flutter/material.dart';
import 'package:ju_event_managment_planner/screens/drawer.dart';
import 'package:ju_event_managment_planner/util/app_color.dart';
import 'package:ju_event_managment_planner/screens/add_event.dart';
import 'package:ju_event_managment_planner/screens/calender.dart';
import 'package:ju_event_managment_planner/screens/profile_page.dart';
import 'package:ju_event_managment_planner/controller/data_controller.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../widgets/event_fetch.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final DataController dataController = Get.put(DataController());
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('dd-MM-yyyy').format(now);

    // Call the filter method whenever the selected tab changes
    dataController.filterEventsBy(
      _selectedFilterIndex == 0 ? 'Today' :
      _selectedFilterIndex == 1 ? 'Week' :
      _selectedFilterIndex == 2 ? 'Month' : 'Year',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Container(
            height: 250,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/2.png'),
                fit: BoxFit.cover,
                opacity: 0.7,
              ),
              borderRadius: BorderRadius.only(
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
                  const SizedBox(height: 60),
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
                            letterSpacing: 1.5,
                          ),
                        ),
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(
                              Icons.menu,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
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
                        buildFilterTab(0, "Today", dataController),
                        buildFilterTab(1, "Week", dataController),
                        buildFilterTab(2, "Month", dataController),
                        buildFilterTab(3, "Year", dataController),
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
              "Today, $formattedDate",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (dataController.isEventsLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (dataController.filteredEvents.isEmpty) {
                return const Center(child: Text("There's no event available"));
              }
              return ListView.builder(
                itemCount: dataController.filteredEvents.length,
                itemBuilder: (context, index) {
                  return EventItem(dataController.filteredEvents[index]);
                },
              );
            }),
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

  Widget buildFilterTab(int index, String text, DataController dataController) {
    bool isSelected = index == _selectedFilterIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
          // Call the filter method here to update the filtered events
          dataController.filterEventsBy(
            index == 0 ? 'Today' : index == 1 ? 'Week' : index == 2 ? 'Month' : 'Year',
          );
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isSelected ? const Color(0xFF5E2587) : AppColors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 40,
              color: const Color(0xFF5E2587),
            ),
        ],
      ),
    );
  }
}
