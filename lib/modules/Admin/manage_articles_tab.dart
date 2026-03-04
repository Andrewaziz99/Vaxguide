import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaxguide/core/blocs/admin/admin_cubit.dart';
import 'package:vaxguide/core/models/article_model.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/modules/Admin/article_form_screen.dart';
import 'package:vaxguide/shared/widgets.dart';

class ManageArticlesTab extends StatelessWidget {
  const ManageArticlesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = AdminCubit.get(context);

    return Stack(
      children: [
        StreamBuilder<List<ArticleModel>>(
          stream: cubit.streamArticles(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: fischerBlue100),
              );
            }

            final articles = snapshot.data ?? [];

            if (articles.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد مقالات',
                  style: TextStyle(
                    fontFamily: 'Alexandria',
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              physics: const BouncingScrollPhysics(),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return _ArticleListTile(article: article);
              },
            );
          },
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: FloatingActionButton(
            heroTag: 'addArticle',
            backgroundColor: fischerBlue500,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () => navigateTo(context, const ArticleFormScreen()),
          ),
        ),
      ],
    );
  }
}

class _ArticleListTile extends StatelessWidget {
  final ArticleModel article;
  const _ArticleListTile({required this.article});

  @override
  Widget build(BuildContext context) {
    final cubit = AdminCubit.get(context);
    final dateStr = DateFormat('yyyy/MM/dd', 'ar').format(article.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: fischerBlue900.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fischerBlue300.withValues(alpha: 0.15)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        title: Text(
          article.title,
          style: const TextStyle(
            fontFamily: 'Alexandria',
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(
                dateStr,
                style: TextStyle(
                  fontFamily: 'Alexandria',
                  color: fischerBlue300,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: article.isPublished
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  article.isPublished ? 'منشور' : 'مسودة',
                  style: TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 10,
                    color: article.isPublished
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.edit_rounded,
                color: fischerBlue100,
                size: 20,
              ),
              onPressed: () =>
                  navigateTo(context, ArticleFormScreen(article: article)),
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: red500, size: 20),
              onPressed: () => _confirmDelete(context, cubit, article),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminCubit cubit, ArticleModel a) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: fischerBlue900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: fischerBlue100.withValues(alpha: 0.15)),
        ),
        title: const Text(
          'حذف المقال',
          style: TextStyle(
            fontFamily: 'Alexandria',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف "${a.title}"؟',
          style: const TextStyle(
            fontFamily: 'Alexandria',
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Alexandria', color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              cubit.deleteArticle(a.id);
            },
            child: const Text(
              'حذف',
              style: TextStyle(fontFamily: 'Alexandria', color: red500),
            ),
          ),
        ],
      ),
    );
  }
}
