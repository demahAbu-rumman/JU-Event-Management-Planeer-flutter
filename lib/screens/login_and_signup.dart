import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ju_event_managment_planner/screens/profiles_page.dart';
import 'package:ju_event_managment_planner/widgets/my_widgets.dart';
import '../Util/app_color.dart';
import '../controller/auth_controller.dart';
import 'profile_setup.dart';

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
  bool _obscureLoginPassword = true;
  bool _obscureSignupPassword = true;
  bool _obscureConfirmPassword = true;

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
              SizedBox(height: Get.height * 0.02),
              Stack(
                children: [
                  myTextField(
                    bool: _obscureLoginPassword,
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
                  Positioned(
                    right: 10,
                    top: 10,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscureLoginPassword = !_obscureLoginPassword;
                        });
                      },
                      child: Icon(
                        _obscureLoginPassword ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.lightGreen,
                      ),
                    ),
                  ),
                ],
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
                          const SizedBox(height: 10),
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
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(top: Get.height * 0.02),
                  child: myText(
                    text: 'Forgot password?',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w400,
                      color: AppColors.lightGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Obx(() => authController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
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
                  password: passwordController.text.trim(),
                );
              },
            ),
          )),
          SizedBox(height: Get.height * 0.02),
          myText(
            text: 'Or Connect With',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w400,
              color: AppColors.darkGreen,
            ),
          ),
          SizedBox(height: Get.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              socialAppsIcons(
                text: 'lib/assets/facebook.png.png',
                onPressed: () {
                  Get.to(() => Profiles_Page());
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
    String passwordStrength = '';
    Color strengthColor = Colors.transparent;
    bool showPasswordHints = false;

    void checkPasswordStrength(String password) {
      if (password.isEmpty) {
        setState(() {
          passwordStrength = '';
          strengthColor = Colors.transparent;
          showPasswordHints = false;
        });
        return;
      }

      bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
      bool hasDigits = password.contains(RegExp(r'[0-9]'));
      bool hasLowercase = password.contains(RegExp(r'[a-z]'));
      bool hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      bool hasMinLength = password.length >= 8;

      setState(() {
        showPasswordHints = true;

        if (!hasMinLength) {
          passwordStrength = 'Password must be at least 8 characters';
          strengthColor = Colors.red;
        } else if (!(hasUppercase && hasDigits && hasLowercase && hasSpecialChars)) {
          passwordStrength = 'Include uppercase, lowercase, numbers & special chars';
          strengthColor = Colors.orange;
        } else {
          passwordStrength = 'Strong password!';
          strengthColor = Colors.green;
        }
      });
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Email field (unchanged)
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
          SizedBox(height: Get.height * 0.02),

          // First Password Field with Strength Indicator
          Stack(
            children: [
              myTextField(
                bool: _obscureSignupPassword,
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
                onChanged: checkPasswordStrength,
              ),
              Positioned(
                right: 10,
                top: 10,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscureSignupPassword = !_obscureSignupPassword;
                    });
                  },
                  child: Icon(
                    _obscureSignupPassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.lightGreen,
                  ),
                ),
              ),
            ],
          ),

          // Password Strength Hints (appears under first password box)
          if (showPasswordHints)
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 12, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Strength indicator
                  Text(
                    passwordStrength,
                    style: TextStyle(
                      color: strengthColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  // Requirements list
                  Text(
                    'Requirements:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• 8+ characters', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        Text('• Uppercase letter (A-Z)', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        Text('• Lowercase letter (a-z)', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        Text('• Number (0-9)', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        Text('• Special character (!@#\$%^&*)', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Confirm Password Field (unchanged)
          SizedBox(height: Get.height * 0.02),
          Stack(
            children: [
              myTextField(
                bool: _obscureConfirmPassword,
                icon: 'lib/assets/lock.png',
                text: 'Confirm Password',
                validator: (String input) {
                  if (input.isEmpty) {
                    Get.snackbar('Warning', 'Confirm Password is required.',
                        colorText: AppColors.white,
                        backgroundColor: AppColors.darkGreen);
                    return '';
                  }
                  if (input != passwordController.text) {
                    Get.snackbar('Warning', 'Password mismatch.',
                        colorText: AppColors.white,
                        backgroundColor: AppColors.darkGreen);
                    return '';
                  }
                },
                controller: confirmPasswordController,
              ),
              Positioned(
                right: 10,
                top: 10,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  child: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.lightGreen,
                  ),
                ),
              ),
            ],
          ),

          // Rest of your sign up form remains unchanged...
          SizedBox(height: Get.height * 0.02),
          Obx(() => authController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
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
          SizedBox(height: Get.height * 0.02),
          myText(
            text: 'Or Connect With',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w400,
              color: AppColors.darkGreen,
            ),
          ),
          SizedBox(height: Get.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              socialAppsIcons(
                text: 'lib/assets/facebook.png.png',
                onPressed: () {
                  Get.to(() => Profiles_Page());
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
  }}
