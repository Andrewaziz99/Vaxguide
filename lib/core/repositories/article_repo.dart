import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vaxguide/core/models/article_model.dart';

class ArticleRepo {
  final FirebaseFirestore _firestore;
  static const String _collection = 'articles';

  ArticleRepo({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _articlesRef =>
      _firestore.collection(_collection);

  /// Stream published articles ordered by newest first.
  Stream<List<ArticleModel>> streamPublishedArticles() {
    return _articlesRef
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ArticleModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get a single article by ID.
  Future<ArticleModel?> getArticleById(String id) async {
    final doc = await _articlesRef.doc(id).get();
    if (!doc.exists) return null;
    return ArticleModel.fromFirestore(doc);
  }

  /// Get published articles (one-time fetch).
  Future<List<ArticleModel>> getPublishedArticles() async {
    final snapshot = await _articlesRef
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => ArticleModel.fromFirestore(doc)).toList();
  }
}
