import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PostJobs extends StatefulWidget {
  @override
  _PostJobsState createState() => _PostJobsState();
}

class _PostJobsState extends State<PostJobs> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _jobDescriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _packageController = TextEditingController();
  final TextEditingController _joblinks = TextEditingController();
  String? _selectedDriveType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Job Drive'),
        backgroundColor: Colors.red[500],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(_companyNameController, 'Company Name'),
                const SizedBox(height: 10),
                _buildTextField(_jobDescriptionController, 'Job Description', maxLines: 4),
                const SizedBox(height: 10),
                _buildTextField(_locationController, 'Location'),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedDriveType,
                  items: ['On-Campus', 'Off-Campus', 'Walk-in'].map((type) => DropdownMenuItem(
                      value: type, child: Text(type))).toList(),
                  decoration: InputDecoration(labelText: 'Type of Drive'),
                  onChanged: (value) => setState(() => _selectedDriveType = value),
                  validator: (value) => value == null ? 'Please select the type of drive' : null,
                ),
                const SizedBox(height: 10),
                _buildTextField(_packageController, 'Package (in LPA)'),
                const SizedBox(height: 10),
                _buildTextField(_joblinks, 'Link'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _postJobDrive();
                    }
                  },
                  child: const Text('Post Drive'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }

  Future<void> _postJobDrive() async {
    String companyName = _companyNameController.text;
    String jobDescription = _jobDescriptionController.text;
    String location = _locationController.text;
    String typeOfDrive = _selectedDriveType!;
    String package = _packageController.text;
    String formLink = _joblinks.text;

    try {
      await FirebaseFirestore.instance.collection('job_drives').add({
        'companyName': companyName,
        'jobDescription': jobDescription,
        'location': location,
        'typeOfDrive': typeOfDrive,
        'package': package,
        'formLink': formLink,
        'timestamp': FieldValue.serverTimestamp(),
      });

      FirebaseMessaging.instance.subscribeToTopic("students");

      await FirebaseFirestore.instance.collection('notifications').add({
        'title': 'New Job Drive: $companyName',
        'body': 'A new $typeOfDrive drive is available at $location. Apply now!',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job Drive posted successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post job drive: $error')),
      );
    }
  }
}