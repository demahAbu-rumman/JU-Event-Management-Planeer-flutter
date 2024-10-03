import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../Util/app_color.dart';
import '../controller/data_controller.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final dataController = Get.find<DataController>(); // Find the DataController

  @override
  void initState() {
    super.initState();
    // Fetch events for the initial day (today)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchEventsForSelectedDate(_focusedDay);
    });
  }

  void _fetchEventsForSelectedDate(DateTime selectedDay) {
    // Use the new method to filter events by the selected date
    dataController.filterEventsByDate(selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightgreen,
        title: const Text(
          'Calendar',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _fetchEventsForSelectedDate(selectedDay);
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: AppColors.lightgreen,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppColors.lightgreen.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(color: AppColors.black),
                  weekendTextStyle: TextStyle(color: AppColors.black),
                  outsideDaysVisible: false,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                  leftChevronIcon: Icon(
                      Icons.chevron_left, color: AppColors.black),
                  rightChevronIcon: Icon(
                      Icons.chevron_right, color: AppColors.black),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Obx(() {
                // Observe changes in filteredEvents from dataController
                if (dataController.isEventsLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (dataController.filteredEvents.isEmpty) {
                  return const Center(
                      child: Text("There's no event available for this date."));
                }
                final events = dataController.filteredEvents;
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return _buildEventCard(
                      context,
                      name: event.get('event_name') ?? 'No Name',
                      location: event.get('location') ?? 'No Location',
                      time: "${event.get('start_time')} - ${event.get(
                          'end_time')}",
                      description: event.get('description') ?? 'No Description',
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context,
      {required String name,
        required String location,
        required String time,
        required String description}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Modern shape
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16), // Ensure child widgets follow the rounded corners
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightgreen, // Background color for the header
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(color: Colors.white70),
                          overflow: TextOverflow.ellipsis, // Prevent text overflow
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: AppColors.lightgreen, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "Time: $time",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Description: $description",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }}
