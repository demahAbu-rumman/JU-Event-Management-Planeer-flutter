import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'Util/app_color.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightgreen,
        title: const Text('Calendar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,  // Remove AppBar shadow for a cleaner look
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          children: [
            // Calendar widget with updated padding
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
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppColors.darkGreen,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(color: AppColors.black),
                  weekendTextStyle: TextStyle(color: AppColors.black),
                  outsideDaysVisible: false,  // Hide days from outside the current month
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.black),
                  rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.black),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Event list display with more structure and styling
            Expanded(
              child: ListView(
                children: [
                  _buildEventCard(
                    context,
                    title: "Design Meeting",
                    time: "Saturday, July 04th\n09:50 - 10:20 AM",
                    priority: "Priority: Very High",
                    priorityColor: Colors.redAccent,
                    additionalInfo: null,
                  ),
                  const SizedBox(height: 16),
                  _buildEventCard(
                    context,
                    title: "Analytics Meeting",
                    time: "Monday, July 05th\n10:30 - 12:00 PM",
                    priority: null,
                    priorityColor: null,
                    additionalInfo: "Project Marshmallow Website Handover\n"
                        "Client Daniel Web App Design Handover\n"
                        "Fintech Web App Re-design Handover",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(
      BuildContext context, {
        required String title,
        required String time,
        String? priority,
        Color? priorityColor,
        String? additionalInfo,
      }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, color: AppColors.lightGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
            if (priority != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.priority_high, color: priorityColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    priority,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ],
            if (additionalInfo != null) ...[
              const SizedBox(height: 12),
              Text(
                additionalInfo,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
