import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaxguide/core/models/article_model.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/modules/Home/article_detail_screen.dart';
import 'package:vaxguide/shared/widgets.dart';

class ArticleCard extends StatelessWidget {
  final ArticleModel article;

  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy/MM/dd', 'ar').format(article.createdAt);

    return GestureDetector(
      onTap: () => navigateTo(context, ArticleDetailScreen(article: article)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: fischerBlue900.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: fischerBlue300.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (article.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  article.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    color: fischerBlue700.withValues(alpha: 0.3),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white38,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontFamily: 'Alexandria',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Body preview
                  Text(
                    article.body,
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.75),
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Footer: author + date
                  Row(
                    children: [
                      if (article.author.isNotEmpty) ...[
                        Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: fischerBlue300,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          article.author,
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            fontSize: 11,
                            color: fischerBlue300,
                          ),
                        ),
                        const Spacer(),
                      ],
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: fischerBlue300,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontFamily: 'Alexandria',
                          fontSize: 11,
                          color: fischerBlue300,
                        ),
                      ),
                      if (article.author.isEmpty) const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
