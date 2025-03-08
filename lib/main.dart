import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ju_event_managment_planner/screens/notification_service.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'screens/login_and_signup.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  print(message.notification!.toString());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Stripe.publishableKey = publishableKey;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);

  LocalNotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 90),
                Image.asset("lib/assets/1.png",height: 400,width: 400,),
                const SizedBox(height: 49),
                  const Text(
                    "Welcome to JU Event\n Management Planeer",
                    style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontFamily: "gilory",
                    ),
                  ),
                const SizedBox(height: 20),
                const Text(
                  textAlign: TextAlign.center,
                  "Plan University event \n easily and professionally",
                  style: TextStyle(color: Colors.black, fontSize: 14, fontFamily: "gilory req"),
                ),
                const SizedBox(height: 35),
                InkWell(
                  onTap: () {
                    if (_currentPage < 2) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    width: 114,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.green,
                    ),
                    child: const Center(
                      child: Text(
                        "Next",
                        style: TextStyle(color: Colors.white, fontSize: 17, fontFamily: "gilory"),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                AnimatedSmoothIndicator(
                  activeIndex: _currentPage,
                  count: 3,
                  effect: const WormEffect(activeDotColor: Colors.green,type: WormType.thin,dotHeight: 10,dotWidth: 10),
                )
              ],
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 90),
                Image.asset("lib/assets/2.png",height: 400,width: 400,),
                const SizedBox(height: 50),
                const Text(
                  "Time Management",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontFamily: "gilory",
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  textAlign: TextAlign.center,
                  "Organize your time \n and ensure you don't miss any events ",
                  style: TextStyle(color: Colors.black, fontSize: 14, fontFamily: "gilory req"),
                ),
                const SizedBox(height: 50),
                InkWell(
                  onTap: () {
                    if (_currentPage < 2) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    width: 114,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.green,
                    ),
                    child: const Center(
                      child: Text(
                        "Next",
                        style: TextStyle(color: Colors.white, fontSize: 17, fontFamily: "gilory"),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                AnimatedSmoothIndicator(
                  activeIndex: _currentPage,
                  count: 3,
                  effect: const WormEffect(activeDotColor: Colors.green,type: WormType.thin,dotHeight: 10,dotWidth: 10),
                )
              ],
            ),
          ),
              SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 90),
                Image.asset("lib/assets/3.png",height: 400,width: 400,),
                const SizedBox(height: 50),
                const Text(
                  "Collaboration and Sharing",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontFamily: "gilory",
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  textAlign: TextAlign.center,
                  "Share the event schudule \n with your colleagues and students",
                  style: TextStyle(color: Colors.black, fontSize: 14, fontFamily: "gilory req"),
                ),
                const SizedBox(height: 50),
                InkWell(
                  onTap: () {
                    if (_currentPage < 2) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },


                  child: Container(
                    width: 140,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.green,
                    ),
                    child: MaterialButton(
                      onPressed: () {  Get.to(()=> const LoginView()); },
                      child: const Text(
                        "Get Started",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: "gilory"),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                AnimatedSmoothIndicator(
                  activeIndex: _currentPage,
                  count: 3,
                  effect: const WormEffect(activeDotColor: Colors.green,type: WormType.thin,dotHeight: 10,dotWidth: 10),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
