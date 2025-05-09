import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ju_event_managment_planner/Util/app_color.dart';

class Location extends StatefulWidget {
  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  final List<String> schools = [
    'School of Arts',
    'School of Business',
    'School of Shari\'a',
    'School of Educational Sciences',
    'School of Law',
    'School of Sport Science',
    'School of Arts and Design',
    'Prince Al Hussein Bin Abdullah II School of Political Science and International Studies',
    'School of Foreign Languages',
    'School of Archaeology and Tourism',
    'School of Science',
    'School of Agriculture',
    'School of Engineering',
    'King Abdullah II School of Information Technology',
    'School of Medicine',
    'School of Nursing',
    'School of Pharmacy',
    'School of Dentistry',
    'School of Rehabilitation Sciences',
    'Public Health Institute',
    'Deanship of Scientific Research',
    'Deanship of Student Affairs',
    'School of Graduate Studies',
  ];

  final Map<String, List<String>> schoolToColleges = {
    'School of Medicine': ['مدرج1 - كلية الطب'],
    'School of Engineering': ['مدرج سعيد المفتي - كلية الهندسة'],
    'School of Arts': [
      'مدرج الكندي - كلية الاداب',
      'مدرج ابن خلدون - كلية الاداب',
      'مدرج الفراهيدي - كلية الاداب'
    ],
    'School of Science': ['كلية العلوم'],
    'School of Nursing': [
      'مدرج ابن سينا - كلية التمريض',
      'مرج القدس - كلية التمريض'
    ],
    'School of Pharmacy': ['كلية الصيدلة'],
    'School of Law': ['كلية الحقوق'],
    'King Abdullah II School of Information Technology': [
      'مدرج اللوزي _ كلية الملك عبدلله الثاني لتكنولوجيا المعلومات'
    ],
    'School of Business': [
      'مدرج1 - كلية الاعمال',
      'مدرج الاعمال الكبير - كلية الاعمال'
    ],
    'School of Arts and Design': ['مدرج الموسيقى - كلية الفنون'],
    'School of Shari\'a': ['مدرج الخياط _ كلية الشريعة'],
    'Deanship of Student Affairs': ['مدرج الحسن - عمادة الشؤوون الطلبة'],
    'School of Dentistry': ['مدرج بهجت التهلوني - مجمع القاعات الطبية'],
    'School of Educational Sciences': ['مدرج الايمن - كلية التربية'],
  };

  String? selectedSchool;
  String? selectedCollege;
  List<String> filteredColleges = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Location', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 20),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                'lib/assets/green_loc.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
              ),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select your school',
              ),
              value: selectedSchool,
              isExpanded: true,
              items: schools.map((school) {
                return DropdownMenuItem<String>(
                  value: school,
                  child: Text(school),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSchool = value;
                  selectedCollege = null;
                  filteredColleges = schoolToColleges[value] ?? [];
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Choose the college',
              ),
              value: selectedCollege,
              isExpanded: true,
              items: filteredColleges.isNotEmpty
                  ? filteredColleges.map((college) {
                      return DropdownMenuItem<String>(
                        value: college,
                        child: Text(college),
                      );
                    }).toList()
                  : [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text('لا توجد مدرجات متاحة'),
                      ),
                    ],
              onChanged: (value) {
                setState(() {
                  selectedCollege = value;
                });
              },
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                if (selectedCollege != null) {
                  Get.back(result: selectedCollege);
                } else {
                  Get.snackbar('خطأ', 'يرجى اختيار الكلية',
                      colorText: Colors.white,
                      backgroundColor: Colors.red,
                      snackPosition: SnackPosition.BOTTOM);
                }
              },
              child: Text(
                'Confirm',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
