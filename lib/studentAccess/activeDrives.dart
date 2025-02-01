import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class Activedrives extends StatelessWidget {
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
              final jobDrive = jobDrives[index].data() as Map<String, dynamic>;
              final companyName = jobDrive['companyName'] ?? 'Unknown';
              final jobDescription =
                  jobDrive['jobDescription'] ?? 'No job description';
              final location = jobDrive['location'] ?? 'Unknown location';
              final typeofDrive =
                  jobDrive['typeOfDrive'] ?? 'Unknown drive type';
              final package = jobDrive['package'] ?? 'N/A';
              final formLink = jobDrive['formLink'] ?? '';

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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CompanyOverviewPage(
                                company: {
                                  'name': companyName,
                                  'job': jobDescription,
                                  'location': location,
                                  'drive': typeofDrive,
                                  'package': package,
                                  'formLink': formLink,
                                },
                              ),
                            ),
                          );
                        },
                        child: const Text("Apply Now"),
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

class CompanyOverviewPage extends StatelessWidget {
  final Map<String, String> company;

  const CompanyOverviewPage({required this.company});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(company['name'] ?? 'Unknown'),
        backgroundColor: Colors.red[500],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30.0),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Name
            Text(
              company['name'] ?? 'Unknown',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Job Description
            Text(
              "Job: ${company['job'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),

            // Drive Type
            Text(
              "Drive Type: ${company['drive'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),

            // Package
            Text(
              "Package: ${company['package'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),

            // Job Location
            Text(
              "Location: ${company['location'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Link to fill the form
            ElevatedButton(
              onPressed: () async {
                final formLink = company['formLink'] ?? '';
                if (formLink.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No form link available')),
                  );
                  return;
                }

                final Uri url = Uri.parse(formLink);

                if (await canLaunchUrl(url)) {
                  await launchUrl(
                    url,
                    mode: LaunchMode.inAppBrowserView, // Ensures it opens in the browser
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not launch $formLink')),
                  );
                }
              },
              child: const Text('Fill Application Form'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('applications')
                      .add({
                    'name': company['name'] ?? 'N/A',
                    'job': company['job'] ?? 'N/A',
                    'drive': company['drive'] ?? 'N/A',
                    'package': company['package'] ?? 'N/A',
                    'appliedAt': Timestamp.now(),
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${company['name']} applied')),
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Error in submission")));
                }
              },
              child: const Text('Applied'),
            ),
          ],
        ),
      ),
    );
  }
}
