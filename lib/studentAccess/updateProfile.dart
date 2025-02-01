
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileUpdate extends StatefulWidget {
  @override
  _ProfileUpdateState createState() => _ProfileUpdateState();
}

class _ProfileUpdateState extends State<ProfileUpdate> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String dob = '';
  String email = '';
  String address = '';
  String gender = '';
  List<Map<String, String>> qualifications = [];
  bool isSubmitted = false;
  final TextEditingController _dobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Profile Banner with Image Upload Icon
              Stack(
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        'My Profile',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt, size: 40, color: Colors.blue),
                      onPressed: () {
                        // Handle image upload
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20), // Spacing

              // Name field
              TextFormField(
                decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) {
                  name = value!;
                },
              ),
              SizedBox(height: 20), // Spacing

              // Date of Birth field
              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(labelText: 'Date of Birth', border: OutlineInputBorder()),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now());
                  if (pickedDate != null) {
                    setState(() {
                      dob = DateFormat('yyyy-MM-dd').format(pickedDate);
                      _dobController.text = dob;
                    });
                  }
                },
              ),
              SizedBox(height: 20), // Spacing

              // Email field
              TextFormField(
                decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onSaved: (value) {
                  email = value!;
                },
              ),
              SizedBox(height: 20), // Spacing

              // Address field
              TextFormField(
                decoration: InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
                onSaved: (value) {
                  address = value!;
                },
              ),
              SizedBox(height: 20), // Spacing

              // Gender field
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                items: ['Male', 'Female', 'Other'].map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    gender = value!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20), // Spacing

              // Qualifications List with Edit Option
              Column(
                children: [
                  Text(
                    'Qualifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...qualifications.map((qualification) {
                    int index = qualifications.indexOf(qualification);
                    return ListTile(
                      title: Text(qualification['qualification'] ?? ''),
                      subtitle: Text('${qualification['college']} - ${qualification['passingYear']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddQualificationForm(
                                    qualification: qualifications[index])),
                          );
                          if (result != null) {
                            setState(() {
                              qualifications[index] = result;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                  TextButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Add Qualification'),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddQualificationForm()),
                      );
                      if (result != null) {
                        setState(() {
                          qualifications.add(result);
                        });
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 20), // Spacing

              // Submit button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await saveProfileData(); // Save data to Firestore
                    setState(() {
                      isSubmitted = true;
                    });
                  }
                },
                child: Text('Save Updates'),
              ),

              // Display the updated information
              if (isSubmitted)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30),
                    Text(
                      'Updated Information:',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text('Name: $name', style: TextStyle(fontSize: 18)),
                    Text('Date of Birth: $dob', style: TextStyle(fontSize: 18)),
                    Text('Email: $email', style: TextStyle(fontSize: 18)),
                    Text('Address: $address', style: TextStyle(fontSize: 18)),
                    Text('Gender: $gender', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),
                    Text(
                      'Qualifications:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ...qualifications.map((qualification) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '${qualification['qualification']} from ${qualification['college']} (${qualification['passingYear']})',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveProfileData() async {
    CollectionReference profiles = FirebaseFirestore.instance.collection('profiles');

    try {
      // Add the profile data and get the document ID
      DocumentReference profileDoc = await profiles.add({
        'name': name,
        'dob': dob,
        'email': email,
        'address': address,
        'gender': gender
      });

      // Add each qualification to a 'qualifications' subcollection for this profile
      for (var qualification in qualifications) {
        await profileDoc.collection('qualifications').add(qualification);
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile saved successfully')));
    } catch (e) {
      print('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save profile')));
    }
  }
}

class AddQualificationForm extends StatefulWidget {
  final Map<String, String>? qualification;

  AddQualificationForm({this.qualification});

  @override
  _AddQualificationFormState createState() => _AddQualificationFormState();
}

class _AddQualificationFormState extends State<AddQualificationForm> {
  final _formKey = GlobalKey<FormState>();
  String qualification = '';
  String college = '';
  String board = '';
  String passingYear = '';
  String percentage = '';

  @override
  void initState() {
    super.initState();
    if (widget.qualification != null) {
      qualification = widget.qualification!['qualification'] ?? '';
      college = widget.qualification!['college'] ?? '';
      board = widget.qualification!['board'] ?? '';
      passingYear = widget.qualification!['passingYear'] ?? '';
      percentage = widget.qualification!['percentage'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Qualification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: qualification,
                decoration: InputDecoration(labelText: 'Qualification', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the qualification';
                  }
                  return null;
                },
                onSaved: (value) {
                  qualification = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: college,
                decoration: InputDecoration(labelText: 'College', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the college name';
                  }
                  return null;
                },
                onSaved: (value) {
                  college = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: board,
                decoration: InputDecoration(labelText: 'Board/University', border: OutlineInputBorder()),
                onSaved: (value) {
                  board = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: passingYear,
                decoration: InputDecoration(labelText: 'Passing Year', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the passing year';
                  }
                  return null;
                },
                onSaved: (value) {
                  passingYear = value!;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: percentage,
                decoration: InputDecoration(labelText: 'Percentage', border: OutlineInputBorder()),
                onSaved: (value) {
                  percentage = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.pop(context, {
                      'qualification': qualification,
                      'college': college,
                      'board': board,
                      'passingYear': passingYear,
                      'percentage': percentage,
                    });
                  }
                },
                child: Text('Save Qualification'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

