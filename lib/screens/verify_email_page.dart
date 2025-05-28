import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ju_event_managment_planner/screens/profile_setup.dart';
import 'login_and_signup.dart';
import 'package:ju_event_managment_planner/Util/app_color.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPage();
}

class _VerifyEmailPage extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;
  Timer? resendTimer;
  int countdown = 60;
  bool isLoading = false;
  bool hasNavigated = false;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();
      startEmailVerificationCheck();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToProfile();
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    resendTimer?.cancel();
    super.dispose();
  }

  void startEmailVerificationCheck() {
    timer = Timer.periodic(
      const Duration(seconds: 3),
          (_) => checkEmailVerified(),
    );
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    if (mounted) {
      setState(() {
        isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      });

      if (isEmailVerified) {
        timer?.cancel();
        if (!hasNavigated) {
          _navigateToProfile();
        }
      }
    }
  }

  void _navigateToProfile() {
    if (!hasNavigated && mounted) {
      hasNavigated = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
      );
    }
  }

  Future<void> sendVerificationEmail() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      canResendEmail = false;
      countdown = 60;
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      if (mounted) {
        Utils.showSnackBar(context, 'Verification email sent successfully');
      }

      resendTimer?.cancel();
      resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (countdown > 0) {
          setState(() => countdown--);
        } else {
          setState(() => canResendEmail = true);
          timer.cancel();
        }
      });
    } catch (e) {
      String errorMessage = 'Failed to send verification email';
      if (e is FirebaseAuthException) {
        errorMessage = e.message ?? errorMessage;
      }
      if (mounted) {
        Utils.showSnackBar(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEmailVerified) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Redirecting to profile...',
                style: TextStyle(
                  color: AppColors.darkGreen,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Verify Email',
          style: TextStyle(
            fontFamily: 'gilory',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.lightgreen,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildVerificationUI(),
        ),
      ),
    );
  }

  Widget _buildVerificationUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'lib/assets/verified-icon.png',
          height: 180,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 32),
        Text(
          'Verify Your Email',
          style: TextStyle(
            fontFamily: 'gilory',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGreen,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'We\'ve sent a verification email to your registered email address. Please check your inbox and follow the instructions to verify your account.',
          style: TextStyle(
            fontFamily: 'gilory',
            fontSize: 16,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (!canResendEmail)
          Text(
            'Resend available in $countdown seconds',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
            canResendEmail && !isLoading ? sendVerificationEmail : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightgreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.email, color: Colors.white),
            label: Text(
              isLoading ? 'Sending...' : 'Resend Verification Email',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () async {
            final user = FirebaseAuth.instance.currentUser;

            try {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .delete();

              await user.delete();
            } catch (e) {
              print("Error deleting user or Firestore data: $e");
            }

            await FirebaseAuth.instance.signOut();

            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginView()),
              );
            }
          },
          child: const Text(
            'Cancel Verification',
            style: TextStyle(
              fontSize: 16,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class Utils {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}