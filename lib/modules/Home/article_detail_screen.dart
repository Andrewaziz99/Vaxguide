import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaxguide/core/models/article_model.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/core/styles/themeScaffold.dart';

class ArticleDetailScreen extends StatelessWidget {
  final ArticleModel article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat(
      'yyyy/MM/dd – HH:mm',
      'ar',
    ).format(article.createdAt);

    return ThemedScaffold(
      backgroundImagePath: 'assets/images/bg2.png',
      appBar: AppBar(
        title: const Text(
          'المقال',
          style: TextStyle(
            fontFamily: 'Alexandria',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article image
            if (article.imageUrl.isNotEmpty)
              Image.network(
                article.imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: fischerBlue700.withValues(alpha: 0.3),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white38,
                      size: 50,
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontFamily: 'Alexandria',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Meta info
                  Row(
                    children: [
                      if (article.author.isNotEmpty) ...[
                        Icon(
                          Icons.person_outline_rounded,
                          size: 16,
                          color: fischerBlue300,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          article.author,
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            fontSize: 12,
                            color: fischerBlue300,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: fischerBlue300,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontFamily: 'Alexandria',
                          fontSize: 12,
                          color: fischerBlue300,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Divider
                  Divider(
                    color: fischerBlue300.withValues(alpha: 0.3),
                    thickness: 1,
                  ),

                  const SizedBox(height: 16),

                  // Body
                  Text(
                    article.body,
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.8,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
