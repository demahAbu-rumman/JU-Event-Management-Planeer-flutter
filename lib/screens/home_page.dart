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
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final DataController dataController = Get.find<DataController>();
      dataController.filterEventsBy('Today');
      _loadUserRole();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    final dataController = Get.find<DataController>();
    await dataController.fetchMyDocumentOnce();
    if (dataController.myDocument != null && dataController.myDocument!.exists) {
      final role = dataController.myDocument!.get('role');
      setState(() {
        _userRole = role;
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                          ),
                        ),
                        Text(
                          "JU Planner",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Search events...",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                          prefixIcon: const Icon(Icons.search, color: Colors.white),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
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

          const SizedBox(height: 12),
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

              final events = dataController.filteredEvents
                  .where((event) =>
                  event['eventName'].toString().toLowerCase().contains(_searchQuery))
                  .toList();

              if (events.isEmpty) {
                return const Center(child: Text("There's no event available"));
              }

              return ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
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
      bottomNavigationBar: _userRole == null
          ? const SizedBox()
          : Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                offset: const Offset(-5, -5),
                blurRadius: 10,
              ),
              BoxShadow(
                color: Colors.grey.shade600,
                offset: const Offset(5, 5),
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              backgroundColor: AppColors.white,
              selectedItemColor: AppColors.darkGreen,
              unselectedItemColor: AppColors.grey,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              currentIndex: 0,
              onTap: (index) {
                if (_userRole == 'Student') {
                  switch (index) {
                    case 0:
                      break;
                    case 1:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CalendarPage()));
                      break;
                    case 2:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MessagesPage()));
                      break;
                    case 3:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const Profiles_Page()));
                      break;
                  }
                } else {
                  switch (index) {
                    case 0:
                      break;
                    case 1:
                      Get.to(() => const CalendarPage());
                      break;
                    case 2:
                      Get.to(() => const MessagesPage());
                      break;
                    case 3:
                      Get.to(() => const Profiles_Page());
                      break;
                    case 4:
                      if (_shouldShowCreateEvent()) {
                        Get.to(() => const CreateEventView(
                            event: null, isEditing: false));
                      }
                      break;
                  }
                }
              },
              items: _userRole == 'Student'
                  ? const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month_rounded),
                    label: 'Calendar'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.mark_chat_unread_rounded),
                    label: 'Messages'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle_rounded),
                    label: 'Profile'),
              ]
                  : const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month_rounded),
                    label: 'Calendar'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.mark_chat_unread_rounded),
                    label: 'Messages'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle_rounded),
                    label: 'Profile'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.add_circle_outline_rounded),
                    label: 'Create'),
              ],
            ),
          ),
        ),
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
