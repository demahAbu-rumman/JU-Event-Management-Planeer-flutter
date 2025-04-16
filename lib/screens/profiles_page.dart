import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ju_event_managment_planner/Util/app_color.dart';
import 'package:ju_event_managment_planner/controller/auth_controller.dart';
import 'package:ju_event_managment_planner/controller/data_controller.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Profiles_Page extends StatefulWidget {
  const Profiles_Page({super.key});

  @override
  State<Profiles_Page> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Profiles_Page> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController joinedDate = TextEditingController();

  final Map<String, String> locationToCollegeMap = {
    "مدرج1 - كلية الطب": 'School of Medicine',
    "مدرج سعيد المفتي - كلية الهندسة": 'School of Engineering',
    "مدرج وصفي التل - مسرح سمير الرفاعي": 'School of Science',
    "كلية العلوم": 'School of Science',
    "مدرج الحسن - عمادة الشؤوون الطلبة": 'School of Educational Sciences',
    "مدرج الايمن - كلية التربية": 'School of Sport Science',
    "مدرج ابن سبنا - كلية التمريض": 'School of Nursing',
    "كلية الصيدلة": 'School of Pharmacy',
    "كلية الحقوق": 'School of Law',
    "مدرج اللوزي _ كلية الملك عبدلله الثاني لتكنولوجيا المعلومات": 'King Abdullah II School of Information Technology',
    "مدرج الكندي - كلية الاداب": 'School of Educational Sciences',
    "مدرج ابن خلدون - كلية الاداب": 'School of Educational Sciences',
    "مدرج الفراهيدي - كلية الاداب": 'School of Educational Sciences',
    "مدرج1 - كلية الاعمال": 'School of Business',
    "مدرج الموسيقى - كلية الفنون": 'School of Arts',
    "مدرج الاعمال الكبير - كلية الاعمال": 'School of Business',
    "مدرج بهجت التهلوني - مجمع القاعات الطبية": 'Public Health Institute',
    "كلية الزراعة": 'School of Agriculture',
    "مرج القدس - كلية التمريض": 'School of Nursing',
    "مدرج الخياط _ كلية الشريعة": 'School of Shari\'a',
  };

  bool _isOpen = false;
  late PanelController _panelController;
  String image = '';
  String collegeName = '';
  String? selectedRole;

  final List<Activity> recentActivities = [
    Activity('Joined Tech Conference', '2 days ago', Icons.people),
    Activity('Submitted Event attendance', '1 week ago', Icons.event_available),
  ];

  AuthController authController = Get.put(AuthController());
  late DataController dataController;

  void initState() {
    super.initState();
    _panelController = PanelController();
    _loadInitialData();
  }

  void _loadInitialData() async {
    try {
      final uid = authController.currentUser?.uid;

      if (uid == null) {
        print("User is not logged in.");
        return;
      }

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          firstNameController.text = data['first'] ?? '';
          lastNameController.text = data['last'] ?? '';
          selectedRole = data['role'] ?? 'Student';
          image = data['image'] ?? '';
          collegeName = data['collegeName'] ?? 'N/A';

          final joinedTimestamp = data['joinedDate'];
          if (joinedTimestamp != null && joinedTimestamp is Timestamp) {
            final joined = joinedTimestamp.toDate();
            joinedDate.text = '${joined.day}/${joined.month}/${joined.year}';
          } else {
            joinedDate.text = 'N/A';
          }
        });
      }
    } catch (e) {
      print("Failed to load user data: $e");
    }
  }


  void _updateProfileData(Map<String, dynamic> data) {
    setState(() {
      firstNameController.text = data['first'] ?? '';
      lastNameController.text = data['last'] ?? '';
      selectedRole = data['role'] ?? 'Student';
      image = data['image'] ?? '';
      collegeName = data['collegeName'] ?? 'N/A';
      joinedDate.text = _formatJoinedDate(data['joinedDate']);
    });
  }

  String _formatJoinedDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      DateTime dateTime;
      if (date is Timestamp) {
        dateTime = date.toDate();
      } else if (date is DateTime) {
        dateTime = date;
      } else {
        return 'N/A';
      }
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      print("Error formatting date: $e");
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    String joined = joinedDate.text;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontFamily: 'gilory',
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.lightgreen,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            height: 250,
            color: Colors.grey.shade100,
            child: Center(
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.white,
                backgroundImage: image.isNotEmpty
                    ? NetworkImage(image) as ImageProvider
                    : null,
                child: image.isEmpty
                    ? Icon(
                  selectedRole == 'Instructor'
                      ? Icons.school
                      : Icons.person,
                  size: 60,
                  color: Colors.blue,
                )
                    : null,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 250),
                _titleSection(),
                _infoSection(joined),
                const SizedBox(height: 24),
                _buildActivitySection(),
                const SizedBox(height: 24),
                if (selectedRole == 'Instructor') ...[
                  _buildSectionTitle('Office Hours'),
                  _buildSchedule(),
                ] else ...[
                  _buildSectionTitle('Upcoming Events'),
                  _buildEventList(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _titleSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "${firstNameController.text} ${lastNameController.text}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            selectedRole ?? 'Role not set',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoSection(String joinedDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _buildInfoCells(joinedDate),
            );
          } else {
            return Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 16,
              runSpacing: 16,
              children: _buildInfoCells(joinedDate),
            );
          }
        },
      ),
    );
  }

  List<Widget> _buildInfoCells(String joinedDate) {
    return [
      if (selectedRole == 'Event Organizer') _buildAdaptiveInfoCell('Events', 'N/A'),
      if (selectedRole == 'Instructor') _buildAdaptiveInfoCell('Courses', 'N/A'),
      _buildAdaptiveInfoCell('College', collegeName.isNotEmpty ? collegeName : 'N/A'),
      _buildAdaptiveInfoCell('Joined', joinedDate.isNotEmpty ? joinedDate : 'N/A'),
    ];
  }

  Widget _buildAdaptiveInfoCell(String title, String value) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 150),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Recent Activity'),
        const SizedBox(height: 8),
        ...recentActivities.map((activity) => _buildActivityItem(activity)),
      ],
    );
  }

  Widget _buildActivityItem(Activity activity) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(activity.icon, color: Colors.blue),
      ),
      title: Text(activity.title),
      subtitle: Text(activity.time),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

// Add this to the _ProfilePageState class

  Future<List<DocumentSnapshot>> _fetchUpcomingEvents() async {
    try {
      if (collegeName.isEmpty || collegeName == 'N/A') return [];

      final now = DateTime.now();
      final events = await FirebaseFirestore.instance
          .collection('events')
          .where('date', isGreaterThanOrEqualTo: now)
          .orderBy('date')
          .limit(3) // Limit to 3 upcoming events
          .get();

      // Filter events based on the user's college
      return events.docs.where((doc) {
        final eventData = doc.data() as Map<String, dynamic>;
        final eventLocation = eventData['location'] as String? ?? '';
        final eventCollege = locationToCollegeMap[eventLocation] ?? '';
        return eventCollege == collegeName;
      }).toList();
    } catch (e) {
      print("Error fetching upcoming events: $e");
      return [];
    }
  }

  Widget _buildEventList() {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _fetchUpcomingEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No upcoming events in your college',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final events = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            final eventData = event.data() as Map<String, dynamic>;
            final eventDate = eventData['date'] as Timestamp?;
            String formattedDate = 'Date not set';

            if (eventDate != null) {
              final date = eventDate.toDate();
              formattedDate = '${date.day}/${date.month}/${date.year}';
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(eventData['event_name'] ?? 'Unnamed Event'),
                subtitle: Text(eventData['location'] ?? 'Location not specified'),
                trailing: Text(formattedDate),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSchedule() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Monday'),
            subtitle: const Text('9:00 AM - 11:00 AM'),
            trailing: const Text('CS101'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Wednesday'),
            subtitle: const Text('1:00 PM - 3:00 PM'),
            trailing: const Text('CS201'),
          ),
        ],
      ),
    );
  }
}

class Activity {
  final String title;
  final String time;
  final IconData icon;

  Activity(this.title, this.time, this.icon);
}
