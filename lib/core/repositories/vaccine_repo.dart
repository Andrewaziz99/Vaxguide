import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vaxguide/core/models/vaccine_model.dart';

class VaccineRepo {
  final FirebaseFirestore _firestore;
  static const String _collection = 'vaccines';

  VaccineRepo({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _vaccinesRef =>
      _firestore.collection(_collection);

  // ── CREATE ──

  /// Add a new vaccine document. Firestore auto-generates the ID.
  Future<String> addVaccine(VaccineModel vaccine) async {
    final docRef = await _vaccinesRef.add(vaccine.toMap());
    return docRef.id;
  }

  /// Add a new vaccine with a specific document ID.
  Future<void> setVaccine(VaccineModel vaccine) async {
    await _vaccinesRef.doc(vaccine.id).set(vaccine.toMap());
  }

  // ── READ ──

  /// Get a single vaccine by its document ID. Returns `null` if not found.
  Future<VaccineModel?> getVaccineById(String id) async {
    final doc = await _vaccinesRef.doc(id).get();
    if (!doc.exists) return null;
    return VaccineModel.fromFirestore(doc);
  }

  /// Get all vaccines ordered by name.
  Future<List<VaccineModel>> getAllVaccines() async {
    final snapshot = await _vaccinesRef.orderBy('name').get();
    return snapshot.docs.map((doc) => VaccineModel.fromFirestore(doc)).toList();
  }

  /// Get vaccines by category (e.g. 'preschool', 'school', 'travel', 'additional').
  Future<List<VaccineModel>> getVaccinesByCategory(String category) async {
    final snapshot = await _vaccinesRef
        .where('category', isEqualTo: category)
        .orderBy('name')
        .get();
    return snapshot.docs.map((doc) => VaccineModel.fromFirestore(doc)).toList();
  }

  /// Get vaccines by category and subcategory.
  Future<List<VaccineModel>> getVaccinesByCategoryAndSubcategory(
    String category,
    String subcategory,
  ) async {
    final snapshot = await _vaccinesRef
        .where('category', isEqualTo: category)
        .where('subcategory', isEqualTo: subcategory)
        .orderBy('name')
        .get();
    return snapshot.docs.map((doc) => VaccineModel.fromFirestore(doc)).toList();
  }

  /// Search travel vaccines by country name (uses array-contains).
  Future<List<VaccineModel>> searchTravelVaccinesByCountry(
    String country,
  ) async {
    final snapshot = await _vaccinesRef
        .where('category', isEqualTo: 'travel')
        .where('countries', arrayContains: country)
        .get();
    return snapshot.docs.map((doc) => VaccineModel.fromFirestore(doc)).toList();
  }

  /// Get all distinct subcategories for a given category.
  Future<List<String>> getSubcategoriesForCategory(String category) async {
    final snapshot = await _vaccinesRef
        .where('category', isEqualTo: category)
        .get();
    return snapshot.docs
        .map((doc) => (doc.data()['subcategory'] ?? '') as String)
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  /// Get all distinct country names from travel vaccines.
  Future<List<String>> getTravelCountries() async {
    final snapshot = await _vaccinesRef
        .where('category', isEqualTo: 'travel')
        .get();
    final countries = <String>{};
    for (final doc in snapshot.docs) {
      final list = List<String>.from(doc.data()['countries'] ?? []);
      countries.addAll(list);
    }
    return countries.toList()..sort();
  }

  /// Stream all vaccines for real-time updates.
  Stream<List<VaccineModel>> streamAllVaccines() {
    return _vaccinesRef
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => VaccineModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Stream a single vaccine document for real-time updates.
  Stream<VaccineModel?> streamVaccine(String id) {
    return _vaccinesRef.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return VaccineModel.fromFirestore(doc);
    });
  }

  // ── UPDATE ──

  /// Update specific fields on a vaccine document (partial update).
  Future<void> updateVaccine(String id, Map<String, dynamic> data) async {
    await _vaccinesRef.doc(id).update(data);
  }

  /// Replace the entire vaccine document with a new VaccineModel.
  Future<void> replaceVaccine(VaccineModel vaccine) async {
    await _vaccinesRef.doc(vaccine.id).set(vaccine.toMap());
  }

  // ── DELETE ──

  /// Delete a vaccine document from Firestore.
  Future<void> deleteVaccine(String id) async {
    await _vaccinesRef.doc(id).delete();
  }
}
