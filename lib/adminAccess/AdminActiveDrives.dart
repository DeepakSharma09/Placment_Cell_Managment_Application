import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminActiveDrives extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Active Drives"),
        backgroundColor: Colors.red[500],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30.0),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('job_drives').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading drives.'));
          }

          final jobDrives = snapshot.data?.docs ?? [];

          if (jobDrives.isEmpty) {
            return const Center(child: Text('No active drives available.'));
          }

          return ListView.builder(
            itemCount: jobDrives.length,
            itemBuilder: (context, index) {
              final jobDrive = jobDrives[index];
              final jobData = jobDrive.data() as Map<String, dynamic>;
              final companyName = jobData['companyName'] ?? 'Unknown';
              final jobDescription =
                  jobData['jobDescription'] ?? 'No job description';
              final location = jobData['location'] ?? 'Unknown location';
              final typeofDrive =
                  jobData['typeOfDrive'] ?? 'Unknown drive type';
              final package = jobData['package'] ?? 'N/A';
              final formLink = jobData['formLink'] ?? '';

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Company details (name, job description, location)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              companyName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              jobDescription,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),

                      // Apply Now Button
                      ElevatedButton(
                        onPressed: () async {
                          // Show a confirmation dialog before deleting
                          final confirmDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Drive'),
                              content: const Text(
                                  'Are you sure you want to delete this drive?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirmDelete ?? false) {
                            await FirebaseFirestore.instance
                                .collection('job_drives')
                                .doc(jobDrive.id)
                                .delete();
                          }
                        },
                        child: const Text("Delete Drive"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
