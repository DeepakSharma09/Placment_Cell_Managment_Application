import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../loginpages/login.dart';
import 'NotificationPages.dart';
import 'activeDrives.dart';
import 'applications.dart';
import 'model/silder_model.dart';
import 'model/slider_data.dart';
 // Import Notifications Page
import 'updateProfile.dart';

class StudentHome extends StatefulWidget {
  final String uid;

  StudentHome({super.key, required this.uid});

  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  List<sliderModel> slider = [];
  int activeIndex = 0;

  @override
  void initState() {
    super.initState();
    slider = getSliders(); // Initialize the slider data
    setupFCM(); // Initialize Firebase Cloud Messaging
  }

  void setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permissions for iOS
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // Handle incoming messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        String title = message.notification!.title ?? "New Notification";
        String body = message.notification!.body ?? "";

        // Show a snackbar for the notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$title: $body")),
        );

        // Save the notification to Firestore
        saveNotificationToFirestore(title, body);
      }
    });

    // Handle when a notification is clicked and opens the app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NotificationsPage(uid: widget.uid)),
      );
    });
  }

  Future<void> saveNotificationToFirestore(String title, String body) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'studentId': widget.uid,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red[500],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
          ),
          child: AppBar(
            title: const Text(
              'Student',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, size: 35),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications, size: 35),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationsPage(uid: widget.uid)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.red[500]),
              child: const Center(
                child: Text(
                  'Student Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Carousel slider
            CarouselSlider.builder(
              itemCount: slider.length,
              itemBuilder: (context, index, realIndex) {
                String? res = slider[index].image;
                return buildImage(res!, index);
              },
              options: CarouselOptions(
                height: 250,
                autoPlay: true,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    activeIndex = index;
                  });
                },
              ),
            ),

            const SizedBox(height: 10.0),
            Center(child: buildIndicator()),

            const SizedBox(height: 10.0),

            // Grid Section
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20.0,
              mainAxisSpacing: 15.0,
              childAspectRatio: 0.90,
            ),
            children: [
              buildGridItem('My profile', 'Update', 'assets/Student_update.png', Colors.red[500]!, context),
              buildGridItem('Active Drives', 'Apply now', 'assets/active_drives.png', Colors.red[500]!, context),
              buildGridItem('My applications', 'Check details', 'assets/applications.png', Colors.red[500]!, context),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }

  Widget buildIndicator() => AnimatedSmoothIndicator(
    activeIndex: activeIndex,
    count: slider.length,
    effect: const ExpandingDotsEffect(
      dotWidth: 7,
      dotHeight: 7,
      activeDotColor: Colors.red,
    ),
  );

  Widget buildImage(String image, int index) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 5.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        image,
        height: 250,
        fit: BoxFit.cover,
        width: MediaQuery.of(context).size.width,
      ),
    ),
  );

  Widget buildGridItem(String title, String buttonText, String imagePath,
      Color color, BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35.0)),
      elevation: 7,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              color: color.withOpacity(0),
              child: Image.asset(
                imagePath,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                if (title == 'My profile') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileUpdate()),
                  );
                } else if (title == 'Active Drives') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Activedrives()),
                  );
                } else if (title == 'My applications') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Applications()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }}