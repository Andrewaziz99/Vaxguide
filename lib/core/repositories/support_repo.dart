import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vaxguide/core/models/support_ticket_model.dart';

class SupportRepo {
  final FirebaseFirestore _firestore;
  static const String _collection = 'support_tickets';

  SupportRepo({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ticketsRef =>
      _firestore.collection(_collection);

  /// Submit a new support ticket.
  Future<String> submitTicket(SupportTicketModel ticket) async {
    final docRef = await _ticketsRef.add(ticket.toMap());
    return docRef.id;
  }

  /// Stream tickets for a specific user, newest first.
  Stream<List<SupportTicketModel>> streamUserTickets(String uid) {
    return _ticketsRef
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SupportTicketModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Stream all tickets for admin, newest first.
  Stream<List<SupportTicketModel>> streamAllTickets() {
    return _ticketsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SupportTicketModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Update ticket status (for admin).
  Future<void> updateTicketStatus(String id, String status) async {
    await _ticketsRef.doc(id).update({'status': status});
  }

  /// Reply to a ticket and set status to in_progress.
  Future<void> replyToTicket(String id, String reply) async {
    await _ticketsRef.doc(id).update({
      'adminReply': reply,
      'repliedAt': Timestamp.now(),
      'status': 'in_progress',
    });
  }

  /// Reply and close a ticket (set status to resolved).
  Future<void> replyAndCloseTicket(String id, String reply) async {
    await _ticketsRef.doc(id).update({
      'adminReply': reply,
      'repliedAt': Timestamp.now(),
      'status': 'resolved',
    });
  }

  /// Delete a ticket.
  Future<void> deleteTicket(String id) async {
    await _ticketsRef.doc(id).delete();
  }
}
