// --- START OF FILE api_service.dart ---

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/off_day.dart';
import '../models/past_response.dart';
import '../models/question.dart';
import '../models/user.dart';
import '../models/weekend_day.dart';

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<T>> _fetchData<T>(String collectionName, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final snapshot = await _firestore.collection(collectionName).get();
      return snapshot.docs.map((doc) => fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Error fetching $collectionName: $e');
    }
  }

  Future<List<User>> fetchUsers() async {
    return _fetchData('users', (json) => User.fromJson(json));
  }

  Future<List<PastResponse>> fetchPastResponses() async {
    return _fetchData('pastResponses', (json) => PastResponse.fromJson(json));
  }

  Future<List<Question>> fetchQuestions() async {
    return _fetchData('questions', (json) => Question.fromJson(json));
  }

  Future<List<OffDay>> fetchOffDays() async {
    return _fetchData('offDays', (json) => OffDay.fromJson(json));
  }

  Future<List<WeekendDay>> fetchWeekendDays() async {
    return _fetchData('weekendDays', (json) => WeekendDay.fromJson(json));
  }

  Future<void> updateStandup(String id, Map<String, dynamic> standupData) async {
    try {
      // Use .set with merge:true to update or create if it doesn't exist.
      await _firestore.collection('pastResponses').doc(id).set(standupData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update standup: $e');
    }
  }

  Future<void> postStandup(Map<String, dynamic> standupData) async {
    try {
      // The ID is generated client-side, so we use .set to create the document.
      final id = standupData['id'];
      if (id == null) {
        throw Exception('Standup data must include an ID');
      }
      await _firestore.collection('pastResponses').doc(id).set(standupData);
    } catch (e) {
      throw Exception('Failed to post standup: $e');
    }
  }
}
// --- END OF FILE api_service.dart ---