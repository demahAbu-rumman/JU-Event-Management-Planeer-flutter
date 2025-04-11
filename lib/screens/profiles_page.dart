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

  bool _isOpen = false;
  late PanelController _panelController;
  String image = '';
  String collegeName = '';

  String? selectedRole;
  final List<Activity> recentActivities = [
    Activity('Joined Tech Conference', '2 days ago', Icons.people),
    Activity('Submitted Event attendance ', '1 week ago', Icons.event_available),
  ];

  AuthController authController = Get.put(AuthController());
  DataController? dataController;

  @override
  void initState() {
    super.initState();
    _panelController = PanelController();
    dataController = Get.find<DataController>();

    // Initialize with current data first
    _loadInitialData();

    // Then listen for changes
    dataController?.myDocument?.reference.snapshots().listen((doc) {
      if (doc.exists) {
        _updateProfileData(doc.data() as Map<String, dynamic>);
      }
    });
  }

  void _loadInitialData() async {
    if (dataController?.myDocument != null && dataController!.myDocument!.exists) {
      _updateProfileData(dataController!.myDocument!.data() as Map<String, dynamic>);
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
  // Helper method to format joined date
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
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}'; // More detailed format
    } catch (e) {
      print("Error formatting date: $e");
      return 'N/A';
    }
  }


  @override
  Widget build(BuildContext context) {
    // Get the joined date
    String joinedDate = this.joinedDate.text;

    switch (selectedRole?.toLowerCase()) {
      case 'student':
        return _buildStudentProfile(joinedDate);
      case 'event organizer':
        return _buildOrganizerProfile(joinedDate);
      case 'instructor':
        return _buildInstructorProfile(joinedDate);
      default:
        return _buildStudentProfile(joinedDate);
    }
  }

  Widget _buildStudentProfile(String joinedDate) {
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
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: image.isNotEmpty
                    ? NetworkImage(image) as ImageProvider
                    : const AssetImage('lib/assets/profilePic.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SlidingUpPanel(
            controller: _panelController,
            minHeight: MediaQuery.of(context).size.height * 0.4,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            panelBuilder: (controller) => _buildStudentPanel(controller, joinedDate),
            onPanelSlide: (value) {
              if (value >= 0.2 && !_isOpen) {
                setState(() => _isOpen = true);
              }
            },
            onPanelClosed: () => setState(() => _isOpen = false),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentPanel(ScrollController controller, String joinedDate) {
    return SingleChildScrollView(
      controller: controller,
      child: Column(
        children: [
          _titleSection(),
          _infoSection(joinedDate),
          const SizedBox(height: 24),
          _buildActivitySection(),
          const SizedBox(height: 24),
          _buildSectionTitle('Upcoming Events'),
          _buildEventList(),
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

  Widget _buildOrganizerProfile(String joinedDate) {
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
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            color: Colors.blue.shade800,
            child: Center(
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.white,
                backgroundImage: image.isNotEmpty
                    ? NetworkImage(image) as ImageProvider
                    : null,
                child: image.isEmpty
                    ? const Icon(Icons.person, size: 60, color: Colors.blue)
                    : null,
              ),
            ),
          ),
          SlidingUpPanel(
            controller: _panelController,
            minHeight: MediaQuery.of(context).size.height * 0.5,
            panelBuilder: (controller) => _buildOrganizerPanel(controller, joinedDate),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizerPanel(ScrollController controller, String joinedDate) {
    return SingleChildScrollView(
      controller: controller,
      child: Column(
        children: [
          _titleSection(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statItem('24', 'Events'),
              _statItem('1.2K', 'Participants'),
              _statItem('4.8', 'Rating'),
            ],
          ),
          const SizedBox(height: 24),
          _buildActivitySection(),
          const SizedBox(height: 24),
          _buildSectionTitle('Upcoming Events'),
          _buildEventList(),
        ],
      ),
    );
  }

  Widget _buildInstructorProfile(String joinedDate) {
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
        iconTheme: IconThemeData(color: Colors.white),
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
                    ? const Icon(Icons.school, size: 60, color: Colors.blue)
                    : null,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 250),
                _titleSection(),
                _infoSection(joinedDate),
                const SizedBox(height: 24),
                _buildActivitySection(),
                const SizedBox(height: 24),
                _buildSectionTitle('Office Hours'),
                _buildSchedule(),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (selectedRole == 'Event Organizer') ...[
            _infoCell('Events', 'N/A'),
          ],
          if (selectedRole == 'Instructor') ...[
            _infoCell('Courses', 'N/A'),
          ],
          _infoCell('College', collegeName.isNotEmpty ? collegeName : 'N/A'),
          _infoCell('Joined', joinedDate.isNotEmpty ? joinedDate : 'N/A'),
        ],
      ),
    );
  }

  Widget _infoCell(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _statItem(String value, String title) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          title: Text('Event ${index + 1}'),
          subtitle: const Text('Computer Science Department'),
          trailing: const Text('Nov 15'),
        ),
      ),
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