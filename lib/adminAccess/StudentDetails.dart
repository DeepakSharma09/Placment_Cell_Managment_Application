import 'package:flutter/material.dart';

class StudentsDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students Details'),
        backgroundColor: Colors.red[500],
      ),
      body: Center(
        child: const Text(
          'Students Details Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}