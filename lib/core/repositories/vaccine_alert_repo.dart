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

  /// Stream all alerts (including inactive) for admin.
  Stream<List<VaccineAlertModel>> streamAllAlerts() {
    return _alertsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => VaccineAlertModel.fromFirestore(doc))
              .toList(),
        );
  }

  // ── CREATE ──

  Future<String> addAlert(VaccineAlertModel alert) async {
    final docRef = await _alertsRef.add(alert.toMap());
    return docRef.id;
  }

  // ── UPDATE ──

  Future<void> updateAlert(String id, Map<String, dynamic> data) async {
    await _alertsRef.doc(id).update(data);
  }

  // ── DELETE ──

  Future<void> deleteAlert(String id) async {
    await _alertsRef.doc(id).delete();
  }
}
