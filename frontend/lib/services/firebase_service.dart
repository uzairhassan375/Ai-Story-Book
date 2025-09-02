import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Submit feedback to Firestore
  static Future<void> submitFeedback({
    required String reason,
    required String type,
    required DateTime reportedAt,
  }) async {
    try {
      await _firestore.collection('reported_messages').add({
        'reason': reason,
        'type': type,
        'reportedAt': reportedAt,
      });
    } catch (e) {
      print('Error submitting feedback: $e');
      rethrow;
    }
  }

  // Get feedback statistics
  static Future<Map<String, dynamic>> getFeedbackStats() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('reported_messages')
          .get();
      
      int totalFeedback = snapshot.docs.length;
      int positiveFeedback = 0;
      int negativeFeedback = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['type'] == 'Positive') {
          positiveFeedback++;
        } else if (data['type'] == 'Negative') {
          negativeFeedback++;
        }
      }

      return {
        'total': totalFeedback,
        'positive': positiveFeedback,
        'negative': negativeFeedback,
      };
    } catch (e) {
      print('Error getting feedback stats: $e');
      return {
        'total': 0,
        'positive': 0,
        'negative': 0,
      };
    }
  }

  // Test Firebase connection
  static Future<bool> testConnection() async {
    try {
      await _firestore.collection('test').limit(1).get();
      return true;
    } catch (e) {
      print('Firebase connection test failed: $e');
      return false;
    }
  }
}
