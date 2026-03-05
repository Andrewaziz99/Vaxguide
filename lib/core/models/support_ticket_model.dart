import 'package:cloud_firestore/cloud_firestore.dart';

class SupportTicketModel {
  final String id;
  final String uid;
  final String fullName;
  final String email;
  final String subject;
  final String message;
  final String status; // 'open', 'in_progress', 'resolved'
  final String adminReply;
  final DateTime createdAt;
  final DateTime? repliedAt;

  const SupportTicketModel({
    required this.id,
    required this.uid,
    required this.fullName,
    required this.email,
    required this.subject,
    required this.message,
    this.status = 'open',
    this.adminReply = '',
    required this.createdAt,
    this.repliedAt,
  });

  factory SupportTicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupportTicketModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      subject: data['subject'] ?? '',
      message: data['message'] ?? '',
      status: data['status'] ?? 'open',
      adminReply: data['adminReply'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      repliedAt: (data['repliedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'subject': subject,
      'message': message,
      'status': status,
      'adminReply': adminReply,
      'createdAt': Timestamp.fromDate(createdAt),
      'repliedAt': repliedAt != null ? Timestamp.fromDate(repliedAt!) : null,
    };
  }

  bool get hasReply => adminReply.isNotEmpty;
}
