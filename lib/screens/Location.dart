import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:ju_event_managment_planner/Util/app_color.dart';

class Location extends StatefulWidget {
  const Location({Key? key}) : super(key: key);

  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
// قائمة بأسماء الكليات في الجامعة الأردنية
  List<String> colleges = [
    "مدرج1_كلية الطب"
        "مدرج سعيد المفتي-كلية الهندسة",
    "مدرج وصفي التل-مسرح سمير الرفاعي",
    "كلية العلوم",
    "مدرج الحسن-عمادة الشؤوون الطلبة",
    "مدرج الايمن -كلية التربية",
    "مدرج ابن سبنا -كلية التمريض"
        "كلية الصيدلة",
    "كلية الحقوق",
    "مدرج اللوزي_كلية الملك عبدلله للتكنولوجيا المعلومات",
    "مدرج الكندي _كلية الاداب",
    "مدرج ابن خلدون-كلية الاداب",
    "مدرج الفراهيدي_كلية الاداب",
    "مدرج1 -كلية الاعمال",
    "مدرج الموسيقى_كلية الفنون",
    "مدرج الاعمال الكبير _كلية الاعمال",
    "مدرج بهجت التهلوني_مجمع القاعات الطبية"
        "كلية الزراعة",
    "مرج القدس-كلية التمريض",
    "مدرج الخياط_كلية الشريعة",
  ];

  // القيمة المختارة
  String? selectedCollege;
  int attendeeCount = 1;
  Map<String, bool> devices = {
    'Projector': false,
    'Microphone': false,
    'Speakers': false,
  };
  void _confirmSelection() {
    if (selectedCollege == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an auditorium.')),
      );
      return;
    }

    if (attendeeCount < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a valid number of attendees.')),
      );
      return;
    }

    print('Selected  colleges: $selectedCollege');
    print('Attendees: $attendeeCount');
    print(
        'Devices: ${devices.entries.where((entry) => entry.value).map((entry) => entry.key).toList()}');
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightgreen,
        title: const Text(
          'Location',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('lib/assets/loc.jpg'),
            DropdownButton<String>(
              hint: Text('Choose the college'),
              value: selectedCollege,
              isExpanded: true,
              items: colleges.map((String college) {
                return DropdownMenuItem<String>(
                  value: college,
                  child: Text(college),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCollege = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            Text('Number of Attendees:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    if (attendeeCount > 1) {
                      setState(() => attendeeCount--);
                    }
                  },
                ),
                Text('$attendeeCount', style: TextStyle(fontSize: 18)),
                IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() => attendeeCount++);
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Available Devices:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Column(
              children: devices.keys.map((device) {
                return CheckboxListTile(
                  title: Text(device),
                  value: devices[device],
                  onChanged: (bool? value) {
                    setState(() {
                      devices[device] = value!;
                    });
                  },
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedCollege != null) {
                  Get.back(
                      result: selectedCollege); // إرجاع الاختيار للصفحة الأولى
                } else {
                  Get.snackbar('error', 'Please select college',
                      colorText: Colors.white, backgroundColor: Colors.red);
                }
              },
              child: Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
