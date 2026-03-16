import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vaxguide/core/constants/strings.dart';

class AppContentRepo {
  final FirebaseFirestore _firestore;

  static const String _collection = 'app_content';
  static const String _aboutDocId = 'about';

  AppContentRepo({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _aboutRef =>
      _firestore.collection(_collection).doc(_aboutDocId);

  Stream<String> streamAboutText() {
    return _aboutRef.snapshots().map((doc) {
      final text = doc.data()?['text'] as String?;
      if (text == null || text.trim().isEmpty) return aboutDescription;
      return text;
    });
  }

  Future<String> getAboutText() async {
    final doc = await _aboutRef.get();
    final text = doc.data()?['text'] as String?;
    if (text == null || text.trim().isEmpty) return aboutDescription;
    return text;
  }

  Future<void> updateAboutText({
    required String text,
    String? updatedBy,
  }) async {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      throw ArgumentError('About text cannot be empty');
    }

    await _aboutRef.set({
      'text': normalized,
      'updatedAt': FieldValue.serverTimestamp(),
      if (updatedBy != null) 'updatedBy': updatedBy,
    }, SetOptions(merge: true));
  }
}
