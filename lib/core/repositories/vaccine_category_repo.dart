import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vaxguide/core/models/vaccine_category_model.dart';

class VaccineCategoryRepo {
  final FirebaseFirestore _firestore;
  static const String _collection = 'vaccine_categories';

  VaccineCategoryRepo({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(_collection);

  // ── CREATE ──

  /// Add or replace a category document (uses key as doc ID).
  Future<void> setCategory(VaccineCategoryModel category) async {
    await _ref.doc(category.key).set(category.toMap());
  }

  // ── READ ──

  /// Get all categories, ordered by label.
  Future<List<VaccineCategoryModel>> getAllCategories() async {
    final snapshot = await _ref.orderBy('label').get();
    return snapshot.docs
        .map((doc) => VaccineCategoryModel.fromFirestore(doc))
        .toList();
  }

  /// Get a single category by key.
  Future<VaccineCategoryModel?> getCategoryByKey(String key) async {
    final doc = await _ref.doc(key).get();
    if (!doc.exists) return null;
    return VaccineCategoryModel.fromFirestore(doc);
  }

  /// Stream all categories for real-time updates.
  Stream<List<VaccineCategoryModel>> streamAllCategories() {
    return _ref
        .orderBy('label')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => VaccineCategoryModel.fromFirestore(doc))
              .toList(),
        );
  }

  // ── UPDATE ──

  /// Update specific fields on a category document.
  Future<void> updateCategory(String key, Map<String, dynamic> data) async {
    await _ref.doc(key).update(data);
  }

  /// Add a subcategory to an existing category.
  Future<void> addSubcategory(String categoryKey, String subcategory) async {
    await _ref.doc(categoryKey).update({
      'subcategories': FieldValue.arrayUnion([subcategory]),
    });
  }

  /// Remove a subcategory from a category.
  Future<void> removeSubcategory(String categoryKey, String subcategory) async {
    await _ref.doc(categoryKey).update({
      'subcategories': FieldValue.arrayRemove([subcategory]),
    });
  }

  // ── DELETE ──

  /// Delete a category document.
  Future<void> deleteCategory(String key) async {
    await _ref.doc(key).delete();
  }
}
