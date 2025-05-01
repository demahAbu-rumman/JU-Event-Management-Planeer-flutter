import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ju_event_managment_planner/Util/app_color.dart';
import 'package:ju_event_managment_planner/controller/auth_controller.dart';
import 'package:ju_event_managment_planner/controller/data_controller.dart';
import 'package:ju_event_managment_planner/screens/settingsprofile.dart';
import 'package:ju_event_managment_planner/widgets/event_fetch.dart';
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
    // Existing mappings
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

    // Add alternative spellings or common variations
    "كلية الطب": 'School of Medicine',
    "كلية الهندسة": 'School of Engineering',
    "المسرح الرئيسي": 'School of Science',
    "عمادة الشؤون الطلبة": 'School of Educational Sciences',
    "كلية التربية": 'School of Sport Science',
    "كلية التمريض": 'School of Nursing',
    "كلية الملك عبدالله الثاني لتكنولوجيا المعلومات": 'King Abdullah II School of Information Technology',
    "كلية الاداب": 'School of Educational Sciences',
    "كلية الاعمال": 'School of Business',
    "كلية الفنون": 'School of Arts',
    "المجمع الطبي": 'Public Health Institute',
    "كلية الشريعة": 'School of Shari\'a',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingProfile()));
            },
          ),
        ],
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

                if (selectedRole != 'Vice Dean' && selectedRole != 'Activities Director')
                  _buildActivitySection(),

                const SizedBox(height: 24),
                if (selectedRole == 'Instructor') ...[
                  _buildSectionTitle('Office Hours'),
                  _buildSchedule(),
                ] else if (selectedRole == 'Vice Dean') ...[
                  _buildSectionTitle('Upcoming Events'),
                  _buildRequestedEvents(),
                  _buildEventList(),
                ] else if (selectedRole == 'Activities Director') ...[
                  _buildApprovedActivities(),
                  _buildRequestedEvents(),
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
      if (collegeName.isEmpty || collegeName == 'N/A') {
        print("College name not set properly");
        return [];
      }

      // Get current date (without time component)
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Fetch events from today onward (including all of today)
      final querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('date', isGreaterThanOrEqualTo: todayStart)
          .where('date', isLessThanOrEqualTo: todayEnd)
          .orderBy('date')
          .limit(20) // Increased limit to ensure we capture today's events
          .get();

      // Debug: Print all fetched events
      print('Fetched ${querySnapshot.docs.length} events from Firestore');
      querySnapshot.docs.forEach((doc) {
        final eventDate = (doc.data()['date'] as Timestamp).toDate();
        print('Event: ${doc.data()['event_name']} on ${eventDate.toString()}');
      });

      // Filter events based on college
      final filteredEvents = querySnapshot.docs.where((doc) {
        final eventData = doc.data() as Map<String, dynamic>;
        final eventLocation = (eventData['location'] as String? ?? '').trim();

        // First try direct college field if it exists
        if (eventData.containsKey('college')) {
          final match = (eventData['college'] as String? ?? '').toLowerCase() ==
              collegeName.toLowerCase();
          if (match) return true;
        }

        // Then try location mapping
        final eventCollege = locationToCollegeMap.entries.firstWhere(
              (entry) => eventLocation.toLowerCase().contains(entry.key.toLowerCase()),
          orElse: () => MapEntry('', ''),
        ).value;

        final collegeMatch = eventCollege.toLowerCase() == collegeName.toLowerCase();

        // Debug: Print matching info
        if (collegeMatch) {
          print('Matched event: ${eventData['event_name']}');
          print('Location: $eventLocation');
          print('Mapped college: $eventCollege');
          print('User college: $collegeName');
        }

        return collegeMatch;
      }).toList();

      print('Found ${filteredEvents.length} matching events for college $collegeName');
      return filteredEvents;
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

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No upcoming events in your college',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final events = snapshot.data!;
        final Map<String, List<DocumentSnapshot>> groupedEvents = {};

        for (var doc in events) {
          final data = doc.data() as Map<String, dynamic>;
          final timestamp = data['date'] as Timestamp?;
          if (timestamp == null) continue;

          final date = timestamp.toDate();
          final now = DateTime.now();
          String label;

          if (_isSameDay(date, now)) {
            label = 'Today';
          } else if (_isSameDay(date, now.add(Duration(days: 1)))) {
            label = 'Tomorrow';
          } else {
            label = '${date.day}/${date.month}/${date.year}';
          }

          groupedEvents.putIfAbsent(label, () => []).add(doc);
        }

        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: groupedEvents.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ...entry.value.map((doc) => EventItem(doc)).toList(),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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

  Widget _buildRequestedEvents() {
    return _buildSectionTitle('Requested Events'); // Placeholder
    // You can replace with actual Firestore call to fetch where status == 'requested'
  }

  Widget _buildApprovedActivities() {
    return _buildSectionTitle('Approved Activities'); // Placeholder
    // You can replace with actual Firestore call to fetch where status == 'approved'
  }
}

class Activity {
  final String title;
  final String time;
  final IconData icon;

  Activity(this.title, this.time, this.icon);
}
