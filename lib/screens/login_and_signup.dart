import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ju_event_managment_planner/widgets/my_widgets.dart';
import '../Util/app_color.dart';
import '../controller/auth_controller.dart';
import 'profile_signup.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  int selectedRadio = 0;
  TextEditingController forgetEmailController = TextEditingController();

  void setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  bool isSignUp = false;

  late AuthController authController;

  @override
  void initState() {
    super.initState();
    authController = Get.put(AuthController());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: Get.width * 0.05),
            child: Column(
              children: [
                SizedBox(
                  height: Get.height * 0.08,
                ),
                isSignUp
                    ? myText(
                        text: 'Sign Up',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightgreen,
                        ),
                      )
                    : myText(
                        text: 'Login',
                        style: GoogleFonts.poppins(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightgreen,
                        ),
                      ),
                SizedBox(
                  height: Get.height * 0.03,
                ),
                isSignUp
                    ? Container(
                        alignment: Alignment.center,
                        child: Image.asset(
                          'lib/assets/JU.png',
                          width: Get.width * 0.4,
                          height: Get.height * 0.2,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Container(
                        alignment: Alignment.center,
                        child: Image.asset(
                          'lib/assets/JU.png',
                          width: Get.width * 0.4,
                          height: Get.height * 0.2,
                          fit: BoxFit.contain,
                        ),
                      ),
                SizedBox(
                  height: Get.height * 0.03,
                ),
                SizedBox(
                  width: Get.width * 0.55,
                  child: TabBar(
                    labelPadding: EdgeInsets.all(Get.height * 0.01),
                    unselectedLabelColor: AppColors.lightGreen,
                    labelColor: AppColors.darkGreen,
                    indicatorColor: AppColors.darkGreen,
                    onTap: (v) {
                      setState(() {
                        isSignUp = !isSignUp;
                      });
                    },
                    tabs: [
                      myText(
                        text: 'Login',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: AppColors.lightgreen),
                      ),
                      myText(
                        text: 'Sign Up',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: AppColors.lightgreen,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.04,
                ),
                SizedBox(
                  width: Get.width,
                  height: Get.height * 0.6,
                  child: Form(
                    key: formKey,
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        LoginWidget(),
                        SignUpWidget(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget LoginWidget() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              myTextField(
                bool: false,
                icon: 'lib/assets/mail.png',
                text: 'hubgfyedfb@ju.edu.jo',
                validator: (String input) {
                  if (input.isEmpty) {
                    Get.snackbar('Warning', 'Email is required.',
                        colorText: AppColors.white,
                        backgroundColor: AppColors.darkGreen);
                    return '';
                  }

                  if (!input.contains('@')) {
                    Get.snackbar('Warning', 'Email is invalid.',
                        colorText: AppColors.white,
                        backgroundColor: AppColors.darkGreen);
                    return '';
                  }
                },
                controller: emailController,
              ),
              SizedBox(
                height: Get.height * 0.02,
              ),
              myTextField(
                bool: true,
                icon: 'lib/assets/lock.png',
                text: 'password',
                validator: (String input) {
                  if (input.isEmpty) {
                    Get.snackbar('Warning', 'Password is required.',
                        colorText: AppColors.white,
                        backgroundColor: AppColors.darkGreen);
                    return '';
                  }

                  if (input.length < 6) {
                    Get.snackbar('Warning', 'Password should be 6+ characters.',
                        colorText: AppColors.white,
                        backgroundColor: AppColors.darkGreen);
                    return '';
                  }
                },
                controller: passwordController,
              ),
              InkWell(
                onTap: () {
                  Get.defaultDialog(
                      title: 'Forget Password?',
                      content: SizedBox(
                        width: Get.width,
                        child: Column(
                          children: [
                            myTextField(
                              bool: false,
                              icon: 'lib/assets/lock.png',
                              text: 'enter your email...',
                              controller: forgetEmailController,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            MaterialButton(
                              color: AppColors.lightgreen,
                              onPressed: () {
                                authController.forgetPassword(
                                    forgetEmailController.text.trim());
                              },
                              minWidth: double.infinity,
                              child: const Text("Sent"),
                            )
                          ],
                        ),
                      ));
                },
                child: Container(
                  margin: EdgeInsets.only(
                    top: Get.height * 0.02,
                  ),
                  child: myText(
                      text: 'Forgot password?',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w400,
                        color: AppColors.lightGreen,
                      )),
                ),
              ),
            ],
          ),
          Obx(() => authController.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Container(
                  height: 50,
                  margin: EdgeInsets.symmetric(vertical: Get.height * 0.04),
                  width: Get.width,
                  child: elevatedButton(
                    text: 'Login',
                    onpress: () {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }
                      authController.login(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim());
                    },
                  ),
                )),
          SizedBox(
            height: Get.height * 0.02,
          ),
          myText(
            text: 'Or Connect With',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w400,
              color: AppColors.darkGreen,
            ),
          ),
          SizedBox(
            height: Get.height * 0.01,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              socialAppsIcons(
                text: 'lib/assets/facebook.png.png',
                onPressed: () {
                  Get.to(() => ProfileScreen());
                },
              ),
              socialAppsIcons(
                text: 'lib/assets/googleg.png',
                onPressed: () {
                  authController.signInWithGoogle();
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget SignUpWidget() {
    return SingleChildScrollView(
      child: Column(
        children: [
          myTextField(
            bool: false,
            icon: 'lib/assets/mail.png',
            text: 'hubgfyedfb@ju.edu.jo',
            validator: (String input) {
              if (input.isEmpty) {
                Get.snackbar('Warning', 'Email is required.',
                    colorText: AppColors.white,
                    backgroundColor: AppColors.darkGreen);
                return '';
              }

              if (!input.contains('@')) {
                Get.snackbar('Warning', 'Email is invalid.',
                    colorText: AppColors.white,
                    backgroundColor: AppColors.darkGreen);
                return '';
              }
            },
            controller: emailController,
          ),
          SizedBox(
            height: Get.height * 0.02,
          ),
          myTextField(
            bool: true,
            icon: 'lib/assets/lock.png',
            text: 'password',
            validator: (String input) {
              if (input.isEmpty) {
                Get.snackbar('Warning', 'Password is required.',
                    colorText: AppColors.white,
                    backgroundColor: AppColors.darkGreen);
                return '';
              }

              if (input.length < 6) {
                Get.snackbar('Warning', 'Password should be 6+ characters.',
                    colorText: AppColors.white,
                    backgroundColor: AppColors.darkGreen);
                return '';
              }
            },
            controller: passwordController,
          ),
          SizedBox(
            height: Get.height * 0.02,
          ),
          myTextField(
            bool: true,
            icon: 'lib/assets/lock.png',
            text: 'Confirm Password',
            validator: (String input) {
              if (input != passwordController.text) {
                Get.snackbar('Warning', 'Password mismatch.',
                    colorText: AppColors.white,
                    backgroundColor: AppColors.darkGreen);
                return '';
              }
            },
            controller: confirmPasswordController,
          ),
          SizedBox(
            height: Get.height * 0.02,
          ),
          Obx(() => authController.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Container(
                  height: 50,
                  margin: EdgeInsets.symmetric(vertical: Get.height * 0.04),
                  width: Get.width,
                  child: elevatedButton(
                    text: 'Sign Up',
                    onpress: () {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }
                      authController.signUp(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                    },
                  ),
                )),
          SizedBox(
            height: Get.height * 0.02,
          ),
          myText(
            text: 'Or Connect With',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w400,
              color: AppColors.darkGreen,
            ),
          ),
          SizedBox(
            height: Get.height * 0.01,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              socialAppsIcons(
                text: 'lib/assets/facebook.png.png',
                onPressed: () {
                  Get.to(() => ProfileScreen());
                },
              ),
              socialAppsIcons(
                text: 'lib/assets/googleg.png',
                onPressed: () {
                  authController.signInWithGoogle();
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
