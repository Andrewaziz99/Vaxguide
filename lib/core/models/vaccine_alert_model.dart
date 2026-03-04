import 'package:cloud_firestore/cloud_firestore.dart';

class VaccineAlertModel {
  final String id;
  final String title;
  final String message;
  final String severity; // 'high', 'medium', 'info'
  final String vaccineName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const VaccineAlertModel({
    required this.id,
    required this.title,
    required this.message,
    this.severity = 'info',
    this.vaccineName = '',
    this.isActive = true,
    required this.createdAt,
    this.expiresAt,
  });

  factory VaccineAlertModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VaccineAlertModel(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      severity: data['severity'] ?? 'info',
      vaccineName: data['vaccineName'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'severity': severity,
      'vaccineName': vaccineName,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}
