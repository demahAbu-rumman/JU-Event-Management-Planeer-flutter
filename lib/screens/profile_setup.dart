import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ju_event_managment_planner/controller/auth_controller.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.find<AuthController>();

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _organizationNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _collegeNameController = TextEditingController();

  // State variables
  File? _profileImage;
  String? _selectedRole;
  bool _isEventOrganizer = false;
  bool _showCollegeField = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileNumberController.dispose();
    _organizationNameController.dispose();
    _genderController.dispose();
    _collegeNameController.dispose();
    super.dispose();
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Choose Image Source'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.camera_alt, size: 30),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            const SizedBox(width: 20),
            IconButton(
              icon: Image.asset(
                'lib/assets/gallary.png',
                width: 25,
                height: 25,
              ),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
        Navigator.pop(context);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: ${e.toString()}');
    }
  }

  // In the _onSavePressed method of profile_setup.dart
  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      _authController.isProfileInformationLoading(true);

      String? imageUrl;
      if (_profileImage != null) {
        imageUrl = await _authController.uploadImageToFirebaseStorage(_profileImage!);
      }

      await _authController.uploadProfileData(
        imageUrl ?? '',
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _mobileNumberController.text.trim(),
        _isEventOrganizer ? _organizationNameController.text.trim() : '',
        _selectedRole!.trim(),
        _genderController.text.trim(),
        _showCollegeField ? _collegeNameController.text.trim() : '',
      );

    } catch (e) {
      Get.snackbar('Error', 'Failed to save profile: ${e.toString()}');
    } finally {
      _authController.isProfileInformationLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for better contrast
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: Get.height * 0.05),

                // Profile Image (unchanged)
                GestureDetector(
                  onTap: _showImagePickerDialog,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff7DDCFB),
                          Color(0xffBC67F2),
                          Color(0xffACF6AF),
                          Color(0xffF95549),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: Colors.white,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? const Icon(
                          Icons.camera_alt,
                          color: Colors.blue,
                          size: 40,
                        )
                            : null,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: Get.height * 0.05),

                // Personal Information Section
                _buildPersonalInfoSection(),

                // Role Selection
                _buildRoleDropdown(),

                // Conditional Fields
                if (_isEventOrganizer) _buildOrganizationField(),
                if (_showCollegeField) _buildCollegeField(),

                // Save Button
                _buildSaveButton(),

                // Terms and Conditions
                _buildTermsText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      children: [
        _buildCustomTextField(
          controller: _firstNameController,
          label: 'First Name',
          icon: Icons.person_outline,
          validator: (input) => input?.isEmpty ?? true ? 'First Name is required.' : null,
        ),
        const SizedBox(height: 16),
        _buildCustomTextField(
          controller: _lastNameController,
          label: 'Last Name',
          icon: Icons.person_outline,
          validator: (input) => input?.isEmpty ?? true ? 'Last Name is required.' : null,
        ),
        const SizedBox(height: 16),
        _buildCustomTextField(
          controller: _mobileNumberController,
          label: 'Mobile Number',
          icon: Icons.phone_android_outlined,
          inputType: TextInputType.phone,
          validator: (input) {
            if (input?.isEmpty ?? true) return 'Mobile Number is required.';
            if (input!.length < 10) return 'Enter a valid phone number.';
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? inputType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueGrey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blueGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: const TextStyle(color: Colors.blueGrey),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedRole,
        hint: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text('Select your role', style: TextStyle(color: Colors.blueGrey)),
        ),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.work_outline, color: Colors.blueGrey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        onChanged: (value) {
          setState(() {
            _selectedRole = value;
            _isEventOrganizer = value == "Event Organizer";
            _showCollegeField = value == "Student" ||
                value == "Instructor" ||
                value == "Vice Dean";

            if (!_isEventOrganizer) _organizationNameController.clear();
            if (!_showCollegeField) _collegeNameController.clear();
          });
        },
        items: const [
          DropdownMenuItem(
            value: "Student",
            child: Text("Student", style: TextStyle(color: Colors.blueGrey)),
          ),
          DropdownMenuItem(
            value: "Instructor",
            child: Text("Instructor", style: TextStyle(color: Colors.blueGrey)),
          ),
          DropdownMenuItem(
            value: "Event Organizer",
            child: Text("Event Organizer", style: TextStyle(color: Colors.blueGrey)),
          ),
          DropdownMenuItem(
            value: "Vice Dean",
            child: Text("Vice Dean", style: TextStyle(color: Colors.blueGrey)),
          ),
          DropdownMenuItem(
            value: "Activities Director",
            child: Text("Activities Director", style: TextStyle(color: Colors.blueGrey)),
          ),
        ],
        validator: (value) => value == null ? 'Please select your role' : null,
        dropdownColor: Colors.white,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }


  Widget _buildOrganizationField() {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildCustomTextField(
          controller: _organizationNameController,
          label: 'Name of the Event Organization',
          icon: Icons.business_outlined,
          validator: (input) => _isEventOrganizer && (input?.isEmpty ?? true)
              ? 'Organization Name is required.'
              : null,
        ),
      ],
    );
  }

  Widget _buildCollegeField() {
    // List of schools from your screenshots
    final List<String> schools = [
      // HUMANITIES SCHOOLS
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

      // SCIENTIFIC SCHOOLS
      'School of Science',
      'School of Agriculture',
      'School of Engineering',
      'King Abdullah II School of Information Technology',

      // HEALTH SCHOOLS
      'School of Medicine',
      'School of Nursing',
      'School of Pharmacy',
      'School of Dentistry',
      'School of Rehabilitation Sciences',
      'Public Health Institute',

      // DEANSHIPS
      'Deanship of Scientific Research',
      'Deanship of Student Affairs',

      // GRADUATE STUDIES
      'School of Graduate Studies',
    ];

    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _collegeNameController.text.isNotEmpty ? _collegeNameController.text : null,
            hint: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('Select your school', style: TextStyle(color: Colors.blueGrey)),
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.school_outlined, color: Colors.blueGrey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            ),
            onChanged: (value) {
              setState(() {
                _collegeNameController.text = value ?? '';
              });
            },
            items: schools.map((school) {
              return DropdownMenuItem(
                value: school,
                child: Text(
                  school,
                  style: const TextStyle(color: Colors.blueGrey),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            validator: (value) => _showCollegeField && (value == null || value.isEmpty)
                ? 'School selection is required.'
                : null,
            dropdownColor: Colors.white,
            style: const TextStyle(fontSize: 16, color: Colors.black),
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Obx(() {
      return _authController.isProfileInformationLoading.value
          ? const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: CircularProgressIndicator(),
      )
          : Container(
        height: 50,
        width: double.infinity,
        margin: const EdgeInsets.only(top: 24, bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [Colors.green, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _onSavePressed,
          child: const Text(
            'Save',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTermsText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: SizedBox(
        width: Get.width * 0.8,
        child: RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'By signing up, you agree to our ',
                style: TextStyle(color: Color(0xff262628), fontSize: 12),
              ),
              TextSpan(
                text: 'terms, Data policy, and cookies policy',
                style: TextStyle(
                  color: Color(0xff262628),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}