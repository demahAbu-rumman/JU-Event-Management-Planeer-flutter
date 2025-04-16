import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ju_event_managment_planner/controller/auth_controller.dart';
import 'package:ju_event_managment_planner/Util/app_color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingProfile extends StatefulWidget {
  const SettingProfile({Key? key}) : super(key: key);

  @override
  _SettingProfileState createState() => _SettingProfileState();
}

class _SettingProfileState extends State<SettingProfile> {
  final AuthController authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _organizationController;

  late String _currentRole;

  @override
  void initState() {
    super.initState();
    final userData = authController.getUserData();
    _firstNameController = TextEditingController(text: userData?['first'] ?? '');
    _lastNameController = TextEditingController(text: userData?['last'] ?? '');
    _phoneController = TextEditingController(text: userData?['mobile'] ?? '');
    _organizationController = TextEditingController(text: userData?['organizationName'] ?? '');
    _currentRole = userData?['role'] ?? 'Student';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _organizationController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Show full-screen loading overlay
        Get.dialog(
          const Center(
            child: CircularProgressIndicator(),
          ),
          barrierDismissible: false,
          barrierColor: Colors.black.withOpacity(0.3),
        );

        final userData = authController.getUserData();

        await authController.uploadProfileData(
          userData?['image'] ?? '',
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          _phoneController.text.trim(),
          _organizationController.text.trim(),
          _currentRole,
          userData?['gender'] ?? '',
          userData?['collegeName'] ?? '',
        );

        // Close loading overlay
        Get.back();

        // Show success snackbar
        Get.snackbar(
          'Profile updated successfully',
          'Success',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.lightgreen,  // Use your light green color from AppColors
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          margin: const EdgeInsets.all(12),
          borderRadius: 10,
        );


        // Refresh local data
        await authController.fetchUserData();

        // Removed Get.back() to prevent navigation and stay on the same page
      } catch (e) {
        Get.back();
        Get.snackbar(
          'Error',
          'Failed to update profile: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'gilory',
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: AppColors.lightgreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              if (_currentRole == 'Event Organizer')
                TextFormField(
                  controller: _organizationController,
                  decoration: const InputDecoration(
                    labelText: 'Organization Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_currentRole == 'Event Organizer' &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter your organization name';
                    }
                    return null;
                  },
                ),
              if (_currentRole == 'Event Organizer') const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightgreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _updateProfile,
                  child: const Text(
                    'Update Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
