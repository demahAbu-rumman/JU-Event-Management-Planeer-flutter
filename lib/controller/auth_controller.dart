import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ju_event_managment_planner/Util/app_color.dart';
import 'package:ju_event_managment_planner/screens/home_page.dart';
import 'package:ju_event_managment_planner/screens/notification_service.dart';
import 'package:ju_event_managment_planner/screens/verify_email_page.dart';
import 'package:path/path.dart' as Path;

class AuthController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? get currentUser => auth.currentUser;
  var isLoading = false.obs;

  // Private variable to hold user data
  Map<String, dynamic>? _userData;

  // Method to retrieve user data
  Map<String, dynamic>? getUserData() {
    return _userData;
  }

  // Check if user has submitted feedback
  Future<bool> hasSubmittedFeedback() async {
    try {
      String uid = auth.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      return userDoc.exists && userDoc.get('hasSubmittedFeedback') == true;
    } catch (e) {
      print("Error checking feedback status: $e");
      return false;
    }
  }

  // Submit feedback and mark user as having submitted
  Future<void> submitFeedback(String feedback, int rating) async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        // Add to feedback collection
        await FirebaseFirestore.instance.collection('feedback').add({
          'userId': user.uid,
          'feedback': feedback,
          'rating': rating,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Mark user as having submitted feedback
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'hasSubmittedFeedback': true,
        }, SetOptions(merge: true));

        Get.snackbar(
          'Thank you!',
          'Your feedback has been submitted',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit feedback',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Method to save user data
  Future<void> saveUserData(String name, String mobile, String role,
      String organizationName, String imageUrl, String collegeName) async {
    String uid = auth.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'name': name,
      'mobile': mobile,
      'role': role,
      'organizationName': organizationName,
      'imageUrl': imageUrl,
      'collegeName': collegeName,
      'joinedDate': FieldValue.serverTimestamp(),
      'first': name.split(' ').first,
      'last': name.split(' ').length > 1 ? name.split(' ').last : '',
      'hasSubmittedFeedback': false, // Initialize feedback flag
    }, SetOptions(merge: true));

    // Also store locally
    _userData = {
      'name': name,
      'mobile': mobile,
      'role': role,
      'organizationName': organizationName,
      'imageUrl': imageUrl,
      'collegeName': collegeName,
      'joinedDate': DateTime.now(),
    };
  }


  // Login method
  void login({String? email, String? password}) {
    isLoading(true);

    auth
        .signInWithEmailAndPassword(email: email!, password: password!)
        .then((value) async {
      await fetchUserData();
      isLoading(false);
      storeToken();

      // 🔔 Save a local notification (if needed)
      await LocalNotificationService.storeNotification(
        title: 'Welcome Back !',
        body: ' ',
        userId: FirebaseAuth.instance.currentUser!.uid,
      );

      // 👉 Navigate to home
      Get.to(() => const HomePage());

      Get.snackbar(
        'Welcome Back!  🎉 ',
        'Glad to see you again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.lightgreen,
        colorText: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        duration: const Duration(seconds: 3),
      );

    }).catchError((e) {
      isLoading(false);
      Get.snackbar(
        'Login Failed',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    });
  }

  // Store FCM token
  static storeToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({'fcmToken': token!}, SetOptions(merge: true));
    } catch (e) {
      print("Error storing token: $e");
    }
  }

  // SignUp method with role parameter
  void signUp({String? email, String? password, String? role}) async {

    final validRoles = ['Student', 'Instructor', 'Event Organizer', 'Vice Dean', 'Activities Director'];
    if (role != null && !validRoles.contains(role)) {
      isLoading(false);
      Get.snackbar('Error', 'Invalid role selected');
      return;
    }

    isLoading(true);

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email!,
        password: password!,
      );

      String uid = userCredential.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'role': role,
        'hasSubmittedFeedback': false, // Initialize feedback flag
      });

      await fetchUserData();
      isLoading(false);

      if (userCredential.user != null) {
        Get.to(() => const VerifyEmailPage());
      }

    } on FirebaseAuthException catch (e) {
      isLoading(false);
      if (e.code == 'email-already-in-use') {
        LocalNotificationService.sendNotification(
          title: 'Signup Failed',
          token: 'The email address is already in use by another account.',
        );
      }
      Get.snackbar('Error', e.message ?? 'Something went wrong');
    }
  }

  // Forget password method
  void forgetPassword(String email) {
    auth.sendPasswordResetEmail(email: email).then((value) {
      Get.back();
      Get.snackbar('Email Sent', 'We have sent password reset email');
    }).catchError((e) {
      print("Error in sending password reset email is $e");
    });
  }

  // Google Sign-In method
  signInWithGoogle() async {
    isLoading(true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      isLoading(false);
    } catch (e) {
      isLoading(false);
      print("Error in Google Sign-In: $e");
    }
  }

  var isProfileInformationLoading = false.obs;

  // Upload image to Firebase Storage
  Future<String> uploadImageToFirebaseStorage(File image) async {
    try {
      String fileName = Path.basename(image.path);
      var reference = FirebaseStorage.instance.ref().child('profileImages/$fileName');
      UploadTask uploadTask = reference.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      rethrow;
    }
  }

  // Upload profile data to Firestore
  uploadProfileData(
      String imageUrl,
      String firstName,
      String lastName,
      String mobileNumber,
      String organizationName,
      String role,
      String gender,
      String collegeName,

      ) async {
    String uid = auth.currentUser!.uid;
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);

    try {
      await docRef.set({
        'uid': uid,
        'image': imageUrl,
        'first': firstName,
        'last': lastName,
        'name': '$firstName $lastName',
        'mobile': mobileNumber,
        'gender': gender,
        'role': role,
        'organizationName': organizationName,
        'collegeName': collegeName,
        'joinedDate': FieldValue.serverTimestamp(),
        'hasSubmittedFeedback': false, // Ensure feedback flag is initialized
      }, SetOptions(merge: true));

      isProfileInformationLoading(false);
      Get.offAll(() => HomePage());
    } catch (e) {
      isProfileInformationLoading(false);
      Get.snackbar('Error', 'Failed to save profile: $e');
      print("Error uploading profile data: $e");
    }
  }

  // Fetch user data from Firestore
  Future<void> fetchUserData() async {
    try {
      String uid = auth.currentUser!.uid;
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        _userData = userSnapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

}