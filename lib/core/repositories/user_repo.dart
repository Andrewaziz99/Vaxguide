import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vaxguide/core/models/user_model.dart';

class UserRepo {
  final FirebaseFirestore _firestore;
  static const String _collection = 'users';

  UserRepo({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection(_collection);

  // ── CREATE ──

  /// Create a new user document in Firestore.
  Future<void> createUser(UserModel user) async {
    await _usersRef.doc(user.uid).set(user.toMap());
  }

  // ── READ ──

  /// Get a single user by UID. Returns `null` if not found.
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Check if a user document exists.
  Future<bool> userExists(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    return doc.exists;
  }

  /// Get all users (admin use-case).
  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _usersRef.orderBy('fullName').get();
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  /// Get users by type ('user' or 'admin').
  Future<List<UserModel>> getUsersByType(String userType) async {
    final snapshot = await _usersRef
        .where('userType', isEqualTo: userType)
        .get();
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  /// Stream a single user document for real-time updates.
  Stream<UserModel?> streamUser(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  // ── UPDATE ──

  /// Update specific fields on a user document (partial update).
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _usersRef.doc(uid).update(data);
  }

  /// Replace the entire user document with a new UserModel.
  Future<void> setUser(UserModel user) async {
    await _usersRef.doc(user.uid).set(user.toMap());
  }

  /// Update user profile fields.
  Future<void> updateProfile({
    required String uid,
    String? fullName,
    String? username,
    String? phone,
    String? address,
    String? gender,
  }) async {
    final Map<String, dynamic> data = {};
    if (fullName != null) data['fullName'] = fullName;
    if (username != null) data['username'] = username;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (gender != null) data['gender'] = gender;
    if (data.isNotEmpty) await _usersRef.doc(uid).update(data);
  }

  /// Update user type (e.g. promote to admin).
  Future<void> updateUserType(String uid, String userType) async {
    await _usersRef.doc(uid).update({'userType': userType});
  }

  // ── VACCINE HISTORY ──

  /// Add a vaccine history entry to the user's record.
  Future<void> addVaccineHistory(String uid, VaccineHistoryEntry entry) async {
    await _usersRef.doc(uid).update({
      'vaccineHistory': FieldValue.arrayUnion([entry.toMap()]),
    });
  }

  /// Remove a vaccine history entry from the user's record.
  Future<void> removeVaccineHistory(
    String uid,
    VaccineHistoryEntry entry,
  ) async {
    await _usersRef.doc(uid).update({
      'vaccineHistory': FieldValue.arrayRemove([entry.toMap()]),
    });
  }

  /// Replace the entire vaccine history list.
  Future<void> setVaccineHistory(
    String uid,
    List<VaccineHistoryEntry> history,
  ) async {
    await _usersRef.doc(uid).update({
      'vaccineHistory': history.map((e) => e.toMap()).toList(),
    });
  }

  // ── DELETE ──

  /// Delete a user document from Firestore.
  Future<void> deleteUser(String uid) async {
    await _usersRef.doc(uid).delete();
  }
}
