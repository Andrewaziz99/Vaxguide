import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleModel {
  final String id;
  final String title;
  final String body;
  final String imageUrl;
  final String author;
  final DateTime createdAt;
  final bool isPublished;

  const ArticleModel({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl = '',
    this.author = '',
    required this.createdAt,
    this.isPublished = true,
  });

  factory ArticleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ArticleModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      author: data['author'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPublished: data['isPublished'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'author': author,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPublished': isPublished,
    };
  }
}
