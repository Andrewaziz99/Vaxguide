import 'package:flutter/material.dart';
import 'package:vaxguide/core/blocs/admin/admin_cubit.dart';
import 'package:vaxguide/core/models/vaccine_category_model.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/modules/Admin/category_form_screen.dart';
import 'package:vaxguide/shared/widgets.dart';

class ManageCategoriesTab extends StatelessWidget {
  const ManageCategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = AdminCubit.get(context);

    return Stack(
      children: [
        StreamBuilder<List<VaccineCategoryModel>>(
          stream: cubit.streamCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: fischerBlue100),
              );
            }

            final categories = snapshot.data ?? [];

            if (categories.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد فئات',
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
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _CategoryListTile(category: categories[index]);
              },
            );
          },
        ),
        // FAB
        Positioned(
          bottom: 16,
          left: 16,
          child: FloatingActionButton(
            heroTag: 'addCategory',
            backgroundColor: fischerBlue500,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () => navigateTo(context, const CategoryFormScreen()),
          ),
        ),
      ],
    );
  }
}

class _CategoryListTile extends StatelessWidget {
  final VaccineCategoryModel category;
  const _CategoryListTile({required this.category});

  @override
  Widget build(BuildContext context) {
    final cubit = AdminCubit.get(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: fischerBlue900.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: fischerBlue300.withValues(alpha: 0.15)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: fischerBlue100.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(category.iconData, color: fischerBlue100, size: 22),
          ),
          title: Text(
            category.label,
            style: const TextStyle(
              fontFamily: 'Alexandria',
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'المفتاح: ${category.key}  •  ${category.subcategories.length} فئة فرعية',
              style: TextStyle(
                fontFamily: 'Alexandria',
                color: fischerBlue300,
                fontSize: 11,
              ),
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
                    navigateTo(context, CategoryFormScreen(category: category)),
              ),
              IconButton(
                icon: const Icon(Icons.delete_rounded, color: red500, size: 20),
                onPressed: () => _confirmDelete(context, cubit, category),
              ),
            ],
          ),
          iconColor: fischerBlue300,
          collapsedIconColor: fischerBlue300,
          children: [
            if (category.subcategories.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  'لا توجد فئات فرعية',
                  style: TextStyle(
                    fontFamily: 'Alexandria',
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              )
            else
              ...category.subcategories.map(
                (sub) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.subdirectory_arrow_right_rounded,
                        color: fischerBlue300.withValues(alpha: 0.5),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sub,
                          style: const TextStyle(
                            fontFamily: 'Alexandria',
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: red300.withValues(alpha: 0.7),
                          size: 18,
                        ),
                        onPressed: () => _confirmRemoveSubcategory(
                          context,
                          cubit,
                          category.key,
                          sub,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Add subcategory button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: OutlinedButton.icon(
                onPressed: () =>
                    _showAddSubcategoryDialog(context, cubit, category.key),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  'إضافة فئة فرعية',
                  style: TextStyle(fontFamily: 'Alexandria', fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: fischerBlue100,
                  side: BorderSide(
                    color: fischerBlue100.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    AdminCubit cubit,
    VaccineCategoryModel cat,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: fischerBlue900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: fischerBlue100.withValues(alpha: 0.15)),
        ),
        title: const Text(
          'حذف الفئة',
          style: TextStyle(
            fontFamily: 'Alexandria',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف "${cat.label}"؟\n\nسيؤدي هذا إلى إزالة الفئة وجميع فئاتها الفرعية.',
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
              cubit.deleteCategory(cat.key);
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

  void _confirmRemoveSubcategory(
    BuildContext context,
    AdminCubit cubit,
    String categoryKey,
    String subcategory,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: fischerBlue900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: fischerBlue100.withValues(alpha: 0.15)),
        ),
        title: const Text(
          'حذف الفئة الفرعية',
          style: TextStyle(
            fontFamily: 'Alexandria',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف "$subcategory"؟',
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
              cubit.removeSubcategoryFromCategory(categoryKey, subcategory);
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

  void _showAddSubcategoryDialog(
    BuildContext context,
    AdminCubit cubit,
    String categoryKey,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: fischerBlue900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: fischerBlue100.withValues(alpha: 0.15)),
        ),
        title: const Text(
          'إضافة فئة فرعية',
          style: TextStyle(
            fontFamily: 'Alexandria',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            fontFamily: 'Alexandria',
            color: Colors.white,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'اسم الفئة الفرعية',
            hintStyle: TextStyle(
              fontFamily: 'Alexandria',
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: fischerBlue300.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: fischerBlue300),
            ),
            filled: true,
            fillColor: fischerBlue900.withValues(alpha: 0.5),
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
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(ctx);
                cubit.addSubcategoryToCategory(categoryKey, text);
              }
            },
            child: const Text(
              'إضافة',
              style: TextStyle(
                fontFamily: 'Alexandria',
                color: fischerBlue100,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
