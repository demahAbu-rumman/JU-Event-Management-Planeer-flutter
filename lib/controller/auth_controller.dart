import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ju_event_managment_planner/screens/home_page.dart';
import 'package:ju_event_managment_planner/screens/notification_service.dart';
import 'package:ju_event_managment_planner/screens/verify_email_page.dart';
import 'package:path/path.dart' as Path;



class AuthController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  var isLoading = false.obs;

  // Private variable to hold user data
  Map<String, dynamic>? _userData;

  // Method to retrieve user data
  Map<String, dynamic>? getUserData() {
    return _userData;
  }

  // Method to save user data
  // In auth_controller.dart, modify the saveUserData method
  Future<void> saveUserData(String name, String mobile, String role,
      String organizationName, String imageUrl, String collegeName) async {
    String uid = auth.currentUser!.uid;
    DateTime joinedDate = DateTime.now(); // Get current date/time

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'mobile': mobile,
      'role': role,
      'organizationName': organizationName,
      'imageUrl': imageUrl,
      'collegeName': collegeName,
      'joinedDate': FieldValue.serverTimestamp(), // Use server timestamp for accuracy
      // Also include the first and last names separately for easy access
      'first': name.split(' ').first,
      'last': name.split(' ').length > 1 ? name.split(' ').last : '',
    }, SetOptions(merge: true));

    // Also store locally
    _userData = {
      'name': name,
      'mobile': mobile,
      'role': role,
      'organizationName': organizationName,
      'imageUrl': imageUrl,
      'collegeName': collegeName,
      'joinedDate': joinedDate,
    };
  }
  // Login method
  void login({String? email, String? password}) {
    isLoading(true);

    auth
        .signInWithEmailAndPassword(email: email!, password: password!)
        .then((value) async {
      // Fetch user data after successful login
      await fetchUserData();

      isLoading(false);
      storeToken();
      Get.to(() => const HomePage());
    }).catchError((e) {
      isLoading(false);
      Get.snackbar('Error', "$e");
    });
  }

  // Store FCM token
  static storeToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      print(token);
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({'fcmToken': token!}, SetOptions(merge: true));
    } catch (e) {
      print("error is $e");
    }
  }

  // SignUp method with role parameter
  void signUp({String? email, String? password, String? role}) async {
    isLoading(true);

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email!,
        password: password!,
      );

      // Save user role to Firestore
      String uid = userCredential.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'role': role,
      });

      // Fetch user data after successful signup
      await fetchUserData();

      isLoading(false);

      // Redirect user to the verify page unless the email is already in use
      if (userCredential.user != null) {
        Get.to(() => const VerifyEmailPage());
      }

    } on FirebaseAuthException catch (e) {
      isLoading(false);

      if (e.code == 'email-already-in-use') {
        // Trigger a local notification for the error
        LocalNotificationService.sendNotification(
          title: 'Signup Failed',
          token: 'The email address is already in use by another account.',
        );
      }

      // Show error message in Snackbar
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
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      isLoading(false);

      ///Successfully logged in
      // Get.to(() => BottomBarView());
    }).catchError((e) {
      /// Error in getting Login
      isLoading(false);
      print("Error is $e");
    });
  }

  var isProfileInformationLoading = false.obs;

  // Upload image to Firebase Storage
  Future<String> uploadImageToFirebaseStorage(File image) async {
    String imageUrl = '';
    String fileName = Path.basename(image.path);

    var reference =
        FirebaseStorage.instance.ref().child('profileImages/$fileName');
    UploadTask uploadTask = reference.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    await taskSnapshot.ref.getDownloadURL().then((value) {
      imageUrl = value;
    }).catchError((e) {
      print("Error happened $e");
    });

    return imageUrl;
  }

  // Upload profile data to Firestore
  // Update the uploadProfileData method to include joinedDate
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
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);

    try {
      // Upload profile info with merge to preserve existing fields like joinedDate
      // In uploadProfileData method, update to use consistent field names
      await docRef.set({
        'image': imageUrl,
        'first': firstName,
        'last': lastName,
        'name': '$firstName $lastName',
        'mobile': mobileNumber,  // Changed from 'phone' to 'mobile'
        'gender': gender,
        'role': role,
        'organizationName': organizationName,
        'collegeName': collegeName,
        'joinedDate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Ensure joinedDate exists (add only if missing)
      final doc = await docRef.get();
      if (!doc.data()!.containsKey('joinedDate')) {
        await docRef.set({
          'joinedDate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

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
