import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String uid;
  final String fullName;
  final String email;
  final int easeOfUse;
  final int clarityOfInfo;
  final int reliabilityAndAccuracy;
  final int overallExperience;
  final String additionalFeatures;
  final DateTime createdAt;

  const FeedbackModel({
    required this.id,
    required this.uid,
    required this.fullName,
    required this.email,
    required this.easeOfUse,
    required this.clarityOfInfo,
    required this.reliabilityAndAccuracy,
    required this.overallExperience,
    this.additionalFeatures = '',
    required this.createdAt,
  });

  factory FeedbackModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedbackModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      easeOfUse: data['easeOfUse'] ?? 0,
      clarityOfInfo: data['clarityOfInfo'] ?? 0,
      reliabilityAndAccuracy: data['reliabilityAndAccuracy'] ?? 0,
      overallExperience: data['overallExperience'] ?? 0,
      additionalFeatures: data['additionalFeatures'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'easeOfUse': easeOfUse,
      'clarityOfInfo': clarityOfInfo,
      'reliabilityAndAccuracy': reliabilityAndAccuracy,
      'overallExperience': overallExperience,
      'additionalFeatures': additionalFeatures,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  double get averageRating =>
      (easeOfUse + clarityOfInfo + reliabilityAndAccuracy + overallExperience) /
      4.0;
}
