import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ju_event_managment_planner/Util/app_color.dart';
import 'package:ju_event_managment_planner/controller/auth_controller.dart';
import 'package:ju_event_managment_planner/controller/data_controller.dart';
import 'package:ju_event_managment_planner/screens/ApprovedeventsSection.dart';
import 'package:ju_event_managment_planner/screens/CreatedEventsSection.dart';
import 'package:ju_event_managment_planner/screens/RequestedEventsSection.dart';
import 'package:ju_event_managment_planner/screens/UpcomingEventsPage.dart';
import 'package:ju_event_managment_planner/screens/settingsprofile.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'joined_events_page.dart';

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
    "مدرج اللوزي _ كلية الملك عبدلله الثاني لتكنولوجيا المعلومات":
        'King Abdullah II School of Information Technology',
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
    "كلية الملك عبدالله الثاني لتكنولوجيا المعلومات":
        'King Abdullah II School of Information Technology',
    "كلية الاداب": 'School of Educational Sciences',
    "كلية الاعمال": 'School of Business',
    "كلية الفنون": 'School of Arts',
    "المجمع الطبي": 'Public Health Institute',
    "كلية الشريعة": 'School of Shari\'a',
  };

  bool _isOpen = false;
  bool _isExpanded = false;
  int createdEventsCount = 0;

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

  @override
  void initState() {
    super.initState();
    _panelController = PanelController();
    _loadInitialData();
  }
  void _fetchCreatedEventsCount(String uid) async {
    try {
      print("Fetching events for user: $uid"); // Debug print

      final querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('uid', isEqualTo: uid)  // Changed from 'organizerId' to 'uid'
          .get();

      print("Found ${querySnapshot.docs.length} events"); // Debug print

      setState(() {
        createdEventsCount = querySnapshot.docs.length;
      });
    } catch (e) {
      print("Failed to fetch event count: $e");
    }
  }


  // Update the _loadInitialData method to ensure it only gets college from user data
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

        // ✅ Fetch event count AFTER setting role
        if (selectedRole == 'Event Organizer') {
          _fetchCreatedEventsCount(uid);
        }
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingProfile()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // صورة الغلاف الرمادية
          Container(
            height: 250,
            color: Colors.grey.shade100,
          ),

          // محتوى الصفحة بالكامل قابل للتمرير
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),
                // صورة البروفايل
                Center(
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
                const SizedBox(height: 24),
                _titleSection(),
                _infoSection(joined),
                const SizedBox(height: 24),

                if (selectedRole == 'Student' || selectedRole == 'Instructor')
                  _buildJoinedEventsSection(),

                if (selectedRole == 'Event Organizer') ...[
                  _buildCreatedEventsSection(),
                  const SizedBox(height: 24),
                  _buildUpcomingEvents(),
                ] else if (selectedRole == 'Instructor') ...[
                  _buildUpcomingEvents(),
                  _buildSchedule(),
                ] else if (selectedRole == 'Vice Dean') ...[
                  _buildUpcomingEvents(),
                  const SizedBox(height: 24),
                  _buildRequestedEvents(),
                ] else if (selectedRole == 'Activities Director') ...[
                  _buildApprovedActivities(),
                  const SizedBox(height: 24),
                  _buildRequestedEvents(),
                ] else ...[
                  _buildUpcomingEvents(),
                ],

                const SizedBox(height: 32),
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

  Widget _buildCreatedEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Created Events By You "),
        CreatedEventsSection(
          organizerId: authController.currentUser?.uid ?? '',
        ),
      ],
    );
  }

  List<Widget> _buildInfoCells(String joinedDate) {
    return [
      if (selectedRole == 'Event Organizer')
        _buildAdaptiveInfoCell('Events', createdEventsCount.toString()),
      if (selectedRole == 'Instructor')
        _buildAdaptiveInfoCell('Courses', 'N/A'),
      // Remove the college section for Event Organizer
      if (selectedRole != 'Event Organizer' && selectedRole != 'Activities Director')
        _buildAdaptiveInfoCell(
            'College', collegeName.isNotEmpty ? collegeName : 'N/A'),
      _buildAdaptiveInfoCell(
          'Joined', joinedDate.isNotEmpty ? joinedDate : 'N/A'),
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

  Widget _buildJoinedEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Joined Events"),
        JoinedEventsSection(
          userId: authController.currentUser?.uid ?? '',
        ),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'Collapse' : 'View All',
              style: TextStyle(color: AppColors.lightgreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Upcoming Events"),
        UpcomingEventsSection(
          collegeName: collegeName,
          locationToCollegeMap: locationToCollegeMap,
          filterByCollege: true, // or false if you want all events
        ),
      ],
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

  Widget _buildRequestedEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Requested Events'),
        if (selectedRole == 'Activities Director')
          RequestedEventsSection(
            collegeName: null, // Pass null for Activities Director
            locationToCollegeMap: locationToCollegeMap,
            filterByCollege: false, // Disable college filtering
          )
        else
          RequestedEventsSection(
            collegeName: collegeName,
            locationToCollegeMap: locationToCollegeMap,
            filterByCollege: true,
          ),
      ],
    );
  }

  Widget _buildApprovedActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Approved Activities'),
        ApprovedActivitiesSection(
          collegeName: collegeName,
          locationToCollegeMap: locationToCollegeMap,
          filterByCollege: false,
        ),
      ],
    );
  }
}

class Activity {
  final String title;
  final String time;
  final IconData icon;

  Activity(this.title, this.time, this.icon);
}
