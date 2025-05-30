import 'package:flutter/material.dart';
import '../Util/app_color.dart';

class AcademyCalendarPage extends StatefulWidget {
  const AcademyCalendarPage({Key? key});

  @override
  _AcademyCalendarPage createState() => _AcademyCalendarPage();
}

class _AcademyCalendarPage extends State<AcademyCalendarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.lightgreen,
        title: const Text(
          'AcademyCalendar',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(children: [
              Image.asset(
                'lib/assets/JU.png',
                height: 150,
              ),
              SizedBox(
                height: 40,
              ),
              Table(
                border: TableBorder.all(color: Colors.black),
                columnWidths: {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                },
                children: [
                  _buildTableRow("المناسبة", "التاريخ", isHeader: true),
                  _buildTableRow("بدء دوام الهيئة التدريسية", "16/2/2025"),
                  _buildTableRow("بدء التدريس في الفصل الثاني", "23/2/2025"),
                  _buildTableRow("أسبوع السحب والإضافة", "16/2 - 20/2"),
                  _buildTableRow("أسبوع الإكمال", "23/2 - 27/2"),
                  _buildTableRow("يوم العمال", "1/5/2025"),
                  _buildTableRow("عيد الفطر", "30/3 - 1/4"),
                  _buildTableRow("عيد الأضحى المبارك تحضيريًا", "5/6 - 9/6"),
                  _buildTableRow("آخر يوم تدريس للفصل", "4/6/2025"),
                  _buildTableRow("الامتحانات النهائية", "8/6 - 26/6"),
                  _buildTableRow("إعلان النتائج النهائية", "29/6/2025"),
                  _buildTableRow("حفل التخرج", "1/8 - 9/8"),
                ],
              ),
            ])),
      ),
    );
  }

  TableRow _buildTableRow(String title, String date, {bool isHeader = false}) {
    return TableRow(
      decoration: isHeader
          ? BoxDecoration(color: AppColors.lightGreen)
          : BoxDecoration(color: Colors.white),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                  color: isHeader ? Colors.white : Colors.black)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(date,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                  color: isHeader ? Colors.white : Colors.black)),
        ),
      ],
    );
  }
}
