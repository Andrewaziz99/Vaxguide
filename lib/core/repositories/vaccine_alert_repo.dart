import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vaxguide/core/models/vaccine_alert_model.dart';

class VaccineAlertRepo {
  final FirebaseFirestore _firestore;
  static const String _collection = 'vaccine_alerts';

  VaccineAlertRepo({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _alertsRef =>
      _firestore.collection(_collection);

  /// Stream active alerts ordered by newest first.
  Stream<List<VaccineAlertModel>> streamActiveAlerts() {
    return _alertsRef
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => VaccineAlertModel.fromFirestore(doc))
              .where((alert) => !alert.isExpired)
              .toList(),
        );
  }

  /// Get active alerts (one-time fetch).
  Future<List<VaccineAlertModel>> getActiveAlerts() async {
    final snapshot = await _alertsRef
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => VaccineAlertModel.fromFirestore(doc))
        .where((alert) => !alert.isExpired)
        .toList();
  }
}
