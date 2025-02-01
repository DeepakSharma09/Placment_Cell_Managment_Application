import 'package:cloud_firestore/cloud_firestore.dart';

class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, String>>> fetchJobPostings() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('job_drives').get();
      return snapshot.docs.map((doc) {
        return {
          'title': doc['title']?.toString() ?? 'No Title',
          'salary': doc['salary']?.toString() ?? 'Not Specified',
          'description': doc['description']?.toString() ?? 'No Description',
        };
      }).toList();
    } catch (e) {
      print('Error fetching job postings: $e');
      return [];
    }
  }
}