import 'package:flutter/material.dart';

import '../loginpages/login.dart';
import 'AdminActiveDrives.dart';
import 'PostJobs.dart';
import 'StudentDetails.dart';



class Adminhome extends StatelessWidget {
  final String uid;

  Adminhome({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red[500],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            title: const Text(
              'Admin login page',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.menu, size: 30),
                  onPressed: () {
                    Scaffold.of(context).openDrawer(); // Open Drawer action
                  },
                );
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person, size: 30),
                onPressed: () {
                  // Handle profile action
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
              decoration: BoxDecoration(
                color: Colors.red[500],
              ),
              child: const Center(
                child: Text(
                  'Admin Menu',
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
                // Handle settings action
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
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Logged Out')),
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
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 30.0,
                children: [
                  buildGridItem(
                    context,
                    'Post drives',
                    'Add new',
                    'assets/post_drives.png',
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PostJobs()),
                    ),
                  ),
                  buildGridItem(
                    context,
                    'Active Drives',
                    'Check details',
                    'assets/active_drives.png',
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminActiveDrives()),
                    ),
                  ),
                  buildGridItem(
                    context,
                    'Students details',
                    'Check details',
                    'assets/Students_details.png',
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StudentsDetails()),
                    ),
                  ),
                  buildGridItem(
                    context,
                    'New Updates',
                    'Updates',
                    'assets/updates.png',
                        () {}, // Add navigation if needed
                  ),
                  buildGridItem(
                    context,
                    'Shortlisted Students',
                    'Update',
                    'assets/shortlisted_students.png',
                        () {}, // Add navigation if needed
                  ),
                  buildGridItem(
                    context,
                    'Placed Students',
                    'View Details',
                    'assets/placed_students.png',
                        () {}, // Add navigation if needed
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Logout Function
  void logoutUser(BuildContext context) {
    // Here you would clear any user session data, tokens, etc.
    // Example: Clear shared preferences, Firebase sign-out, etc.

    // Navigate to the login screen (replace this with your login route)
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget buildGridItem(BuildContext context, String title, String buttonText, String imagePath, VoidCallback onPressed) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              height: 80,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[500],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
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
  }
}