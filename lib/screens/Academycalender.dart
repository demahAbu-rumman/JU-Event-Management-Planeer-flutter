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
          'Academic Calendar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/Academy.jpg'),
            fit: BoxFit.contain, // Changed back to contain
            alignment: Alignment.topCenter, // Ensures top alignment
          ),
        ),
      ),
    );
  }
}