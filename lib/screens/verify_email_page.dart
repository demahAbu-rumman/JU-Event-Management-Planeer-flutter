import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ju_event_managment_planner/screens/profile_signup.dart';
import 'login_and_signup.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPage();
}

class _VerifyEmailPage extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        Duration(seconds: 3),
            (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      String errorMessage = 'An unknown error occurred';

      if (e is FirebaseAuthException) {
        errorMessage = e.message ?? 'Firebase authentication error';
      } else {
        errorMessage = e.toString();
      }
      Utils.showSnackBar(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isEmailVerified
        ? Scaffold(
      appBar: AppBar(
        title: Text(
          'Email Verified',
          style: TextStyle(fontFamily: 'gilory'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/assets/verified-icon.png', height: 150),
            SizedBox(height: 24),
            Text(
              'Your email has been successfully verified!',
              style: TextStyle(
                fontFamily: 'gilory',
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Text(
              'Please press the button below to continue.',
              style: TextStyle(
                fontFamily: 'gilory',
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(),
                  ),
                );
              },
              child: Text(
                'Continue',
                style: TextStyle(fontFamily: 'gilory', fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    )
        : Scaffold(
      appBar: AppBar(
        title: Text(
          'Verify Email',
          style: TextStyle(fontFamily: 'gilory'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'A verification email has been sent to your email.',
              style: TextStyle(
                fontFamily: 'gilory',
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                maximumSize: Size.fromHeight(50),
              ),
              icon: Icon(
                Icons.email,
                size: 32,
                color: Colors.green,
              ),
              label: Text(
                'Resend Email',
                style: TextStyle(
                  fontFamily: 'gilory',
                  fontSize: 24,
                  color: Colors.green,
                ),
              ),
              onPressed: canResendEmail ? sendVerificationEmail : null,
            ),
            SizedBox(height: 8),
            TextButton(
              style: ElevatedButton.styleFrom(
                maximumSize: Size.fromHeight(50),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'gilory',
                  fontSize: 24,
                  color: Colors.green,
                ),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginView()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Utils {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}