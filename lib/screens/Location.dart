import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ju_event_managment_planner/Util/app_color.dart';

class Location extends StatefulWidget {
  const Location({Key? key}) : super(key: key);

  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  // قائمة بأسماء الكليات في الجامعة الأردنية
  List<String> colleges = [
    "مدرج1 - كلية الطب",
    "مدرج سعيد المفتي - كلية الهندسة",
    "مدرج وصفي التل - مسرح سمير الرفاعي",
    "كلية العلوم",
    "مدرج الحسن - عمادة الشؤوون الطلبة",
    "مدرج الايمن - كلية التربية",
    "مدرج ابن سبنا - كلية التمريض",
    "كلية الصيدلة",
    "كلية الحقوق",
    "مدرج اللوزي _ كلية الملك عبدلله الثاني لتكنولوجيا المعلومات",
    "مدرج الكندي - كلية الاداب",
    "مدرج ابن خلدون - كلية الاداب",
    "مدرج الفراهيدي - كلية الاداب",
    "مدرج1 - كلية الاعمال",
    "مدرج الموسيقى - كلية الفنون",
    "مدرج الاعمال الكبير - كلية الاعمال",
    "مدرج بهجت التهلوني - مجمع القاعات الطبية",
    "كلية الزراعة",
    "مرج القدس - كلية التمريض",
    "مدرج الخياط _ كلية الشريعة",
  ];

  String? selectedCollege;
  int attendeeCount = 1;
  Map<String, bool> devices = {
    'Projector': false,
    'Microphone': false,
    'Speakers': false,
  };
  final TextEditingController _textController = TextEditingController();

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

    print('Selected colleges: $selectedCollege');
    print('Attendees: $attendeeCount');
    print(
        'Devices: ${devices.entries.where((entry) => entry.value).map((entry) => entry.key).toList()}');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.lightgreen,
        title: const Text(
          'Location',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
              SizedBox(height: 24),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
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
              SizedBox(height: 24),
              Text(
                'Number of Attendees:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline, size: 28),
                    onPressed: () {
                      if (attendeeCount > 1) {
                        setState(() {
                          attendeeCount--;
                          _textController.text = attendeeCount.toString();
                        });
                      }
                    },
                  ),
                  Container(
                    width: 80,
                    child: TextField(
                      controller: _textController..text = attendeeCount.toString(),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            attendeeCount = int.tryParse(value) ?? 1;
                          });
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, size: 28),
                    onPressed: () {
                      setState(() {
                        attendeeCount++;
                        _textController.text = attendeeCount.toString();
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                'Available Devices:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ...devices.keys.map((device) {
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
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: AppColors.lightgreen,
                ),
                onPressed: () {
                  if (selectedCollege != null) {
                    Get.back(result: selectedCollege);
                  } else {
                    Get.snackbar('Error', 'Please select college',
                        colorText: Colors.white,
                        backgroundColor: Colors.red,
                        snackPosition: SnackPosition.BOTTOM);
                  }
                },
                child: Text(
                  'Confirm',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}