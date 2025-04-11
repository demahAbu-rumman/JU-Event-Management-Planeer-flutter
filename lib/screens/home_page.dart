import 'package:flutter/material.dart';
import 'package:ju_event_managment_planner/screens/EventDetailsView.dart';
import 'package:ju_event_managment_planner/screens/MessagesPage.dart';
import 'package:ju_event_managment_planner/screens/drawer.dart';
import 'package:ju_event_managment_planner/screens/profiles_page.dart';
import 'package:ju_event_managment_planner/util/app_color.dart';
import 'package:ju_event_managment_planner/screens/add_event.dart';
import 'package:ju_event_managment_planner/screens/calender.dart';
import 'package:ju_event_managment_planner/controller/data_controller.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../widgets/event_fetch.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedFilterIndex = 0;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final DataController dataController = Get.find<DataController>();
      dataController.filterEventsBy('Today');
      _loadUserRole();
    });
  }

  Future<void> _loadUserRole() async {
    final dataController = Get.find<DataController>();
    if (dataController.myDocument != null && dataController.myDocument!.exists) {
      setState(() {
        _userRole = dataController.myDocument!.get('role');
      });
    }
  }

  bool _shouldShowCreateEvent() {
    final dataController = Get.find<DataController>();
    final role = dataController.myDocument?.get('role') ?? 'Student';
    return role != 'Student';
  }

  @override
  Widget build(BuildContext context) {
    final DataController dataController = Get.put(DataController());
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('dd-MM-yyyy').format(now);

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
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Builder(
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
                      title: Text(
                        "JU Planner",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
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
                  final event = dataController.filteredEvents[index];
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => EventDetailsView(event: event));
                    },
                    child: EventItem(event),
                  );
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
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          if (_userRole == 'Student') {
            // Student navigation items: [Home, Calendar, Messages, Profile]
            switch (index) {
              case 0: // Home - do nothing
                break;
              case 1: // Calendar
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalendarPage()),
                );
                break;
              case 2: // Messages
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MessagesPage()),
                );
                break;
              case 3: // Profile
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Profiles_Page()),
                );
                break;
            }
          } else {
            // Admin/Staff navigation items: [Home, Events, Calendar, Messages, Profile]
            switch (index) {
              case 0: // Home - do nothing
                break;
              case 1: // Events
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEventView(
                      event: null,
                      isEditing: false,
                    ),
                  ),
                );
                break;
              case 2: // Calendar
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalendarPage()),
                );
                break;
              case 3: // Messages
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MessagesPage()),
                );
                break;
              case 4: // Profile
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Profiles_Page()),
                );
                break;
            }
          }
        },
        items: _userRole == 'Student'
            ? [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ]
            : [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Events',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          const BottomNavigationBarItem(
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
          dataController.filterEventsBy(
            index == 0
                ? 'Today'
                : index == 1
                ? 'Week'
                : index == 2
                ? 'Month'
                : 'Year',
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