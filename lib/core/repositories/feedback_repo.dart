import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vaxguide/core/models/feedback_model.dart';

class FeedbackRepo {
  final FirebaseFirestore _firestore;
  static const String _collection = 'user_feedback';

  FeedbackRepo({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _feedbackRef =>
      _firestore.collection(_collection);

  /// Submit new feedback.
  Future<String> submitFeedback(FeedbackModel feedback) async {
    final docRef = await _feedbackRef.add(feedback.toMap());
    return docRef.id;
  }

  /// Check if a user has already submitted feedback.
  Future<bool> hasUserSubmittedFeedback(String uid) async {
    final snapshot = await _feedbackRef
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// Stream all feedback for admin, newest first.
  Stream<List<FeedbackModel>> streamAllFeedback() {
    return _feedbackRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FeedbackModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Delete feedback.
  Future<void> deleteFeedback(String id) async {
    await _feedbackRef.doc(id).delete();
  }
}
