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
          backgroundColor: AppColors.lightgreen,
          title: const Text(
            'AcademyCalendar',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Container(
          width: double.infinity, // عرض كامل الشاشة
          // أي ارتفاع تريده
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/Academy.jpg'),
              fit: BoxFit.fill, // يجعل الصورة تملأ المساحة بالكامل
            ),
          ),
        ));
  }
}
