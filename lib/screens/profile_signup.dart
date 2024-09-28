import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ju_event_managment_planner/Util/app_color.dart';
import 'package:ju_event_managment_planner/controller/auth_controller.dart';
import 'package:ju_event_managment_planner/screens/home_page.dart';
import '../../../widgets/my_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController eventOrganizationNameController = TextEditingController();
  //TextEditingController role = TextEditingController();
  TextEditingController gender = TextEditingController();

  File? profileImage;

  AuthController? authController;
  String? selectedRole;
  bool isEventOrganizer = false;

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();
  }

  imagePickDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () async {
                  final ImagePicker picker0 = ImagePicker();
                  final XFile? image =
                  await picker0.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    profileImage = File(image.path);
                    setState(() {});
                    Navigator.pop(context);
                  }
                },
                child: const Icon(
                  Icons.camera_alt,
                  size: 30,
                ),
              ),
              const SizedBox(width: 20),
              InkWell(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    profileImage = File(image.path);
                    setState(() {});
                    Navigator.pop(context);
                  }
                },
                child: Image.asset(
                  'lib/assets/gallary.png',
                  width: 25,
                  height: 25,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(height: Get.width * 0.1),
                InkWell(
                  onTap: () {
                    imagePickDialog();
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(top: 35),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.lightgreen,
                      borderRadius: BorderRadius.circular(70),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff7DDCFB),
                          Color(0xffBC67F2),
                          Color(0xffACF6AF),
                          Color(0xffF95549),
                        ],
                      ),
                    ),
                    child: profileImage == null
                        ? const CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.blue,
                        size: 50,
                      ),
                    )
                        : CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.white,
                      backgroundImage: FileImage(
                        profileImage!,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Get.width * 0.1),
                textField(
                    text: 'First Name',
                    controller: firstNameController,
                    validator: (String input) {
                      if (input.isEmpty) {
                        return 'First Name is required.';
                      }
                      return null;
                    }),
                textField(
                    text: 'Last Name',
                    controller: lastNameController,
                    validator: (String input) {
                      if (input.isEmpty) {
                        return 'Last Name is required.';
                      }
                      return null;
                    }),
                textField(
                    text: 'Mobile Number',
                    inputType: TextInputType.phone,
                    controller: mobileNumberController,
                    validator: (String input) {
                      if (input.isEmpty) {
                        return 'Mobile Number is required.';
                      }
                      if (input.length < 10) {
                        return 'Enter a valid phone number.';
                      }
                      return null;
                    }),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black), // Black line
                    borderRadius: BorderRadius.circular(8.0), // Matching shape
                    color: Colors.white, // Matching color
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12), // Padding to align text properly
                  child: DropdownButtonFormField<String>(
                    value: selectedRole,
                    hint: const Text('Select your role'),
                    decoration: const InputDecoration.collapsed(hintText: ''), // Removes the underline
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value;
                        isEventOrganizer = value == "Event Organizer";
                        if (!isEventOrganizer) {
                          eventOrganizationNameController.clear(); // Clear the organization name
                        }
                      });
                    },
                    items: const [
                      DropdownMenuItem(
                        value: "Student",
                        child: Text("Student"),
                      ),
                      DropdownMenuItem(
                        value: "Administrator",
                        child: Text("Administrator"),
                      ),
                      DropdownMenuItem(
                        value: "Event Organizer",
                        child: Text("Event Organizer"),
                      ),
                    ],
                    validator: (value) {
                      if (value == null) {
                        return 'Please select your role';
                      }
                      return null;
                    },
                  ),
                ),
                if (isEventOrganizer) ...[
                  const SizedBox(height: 16),
                  textField(
                    text: 'Name of the Event Organization',
                    controller: eventOrganizationNameController
                    ,
                    validator: (String input) {
                      if (input.isEmpty) {
                        return 'Event Organization Name is required.';
                      }
                      return null;
                    },
                  ),
                ],

                Obx(() => authController!.isProfileInformationLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : Container(
                  height: 50,
                  margin: EdgeInsets.only(top: Get.height * 0.02),
                  width: Get.width,
                  child: elevatedButton(
                    text: 'Save',
                    onpress: () async {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      authController!.isProfileInformationLoading(true);

                      String? imageUrl;
                      if (profileImage != null) {
                        imageUrl = await authController!
                            .uploadImageToFirebaseStorage(profileImage!);
                      }


                      authController!.saveUserData(
                        firstNameController.text.trim() + " " + lastNameController.text.trim(),
                        mobileNumberController.text.trim(),
                        selectedRole!.toString().trim(),
                        isEventOrganizer ? eventOrganizationNameController.text.trim() : "",
                        profileImage != null ? await authController!.uploadImageToFirebaseStorage(profileImage!) : '',
                      );

                      authController!.uploadProfileData(
                        imageUrl ?? '',
                        firstNameController.text.trim(),
                        lastNameController.text.trim(),
                        mobileNumberController.text.trim(),
                       // selectedRole!,
                       eventOrganizationNameController.text.trim(),
                        selectedRole!.toString().trim(),
                        gender.text.trim(),
                      );

                      Get.to(()=>   const HomePage());
                    },
                  ),
                )),
                SizedBox(height: Get.height * 0.03),
                SizedBox(
                  width: Get.width * 0.8,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(children: [
                      TextSpan(
                          text: 'By signing up, you agree to our ',
                          style: TextStyle(
                              color: Color(0xff262628), fontSize: 12)),
                      TextSpan(
                          text: 'terms, Data policy, and cookies policy',
                          style: TextStyle(
                              color: Color(0xff262628),
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
