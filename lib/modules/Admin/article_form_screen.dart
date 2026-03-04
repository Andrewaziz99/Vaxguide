import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaxguide/core/blocs/admin/admin_cubit.dart';
import 'package:vaxguide/core/blocs/admin/admin_states.dart';
import 'package:vaxguide/core/models/article_model.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/core/styles/themeScaffold.dart';

class ArticleFormScreen extends StatefulWidget {
  final ArticleModel? article;
  const ArticleFormScreen({super.key, this.article});

  @override
  State<ArticleFormScreen> createState() => _ArticleFormScreenState();
}

class _ArticleFormScreenState extends State<ArticleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  late final TextEditingController _imageUrlCtrl;
  late final TextEditingController _authorCtrl;
  late bool _isPublished;

  bool get isEditing => widget.article != null;

  @override
  void initState() {
    super.initState();
    final a = widget.article;
    _titleCtrl = TextEditingController(text: a?.title ?? '');
    _bodyCtrl = TextEditingController(text: a?.body ?? '');
    _imageUrlCtrl = TextEditingController(text: a?.imageUrl ?? '');
    _authorCtrl = TextEditingController(text: a?.author ?? '');
    _isPublished = a?.isPublished ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _imageUrlCtrl.dispose();
    _authorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminCubit(),
      child: BlocConsumer<AdminCubit, AdminStates>(
        listener: (context, state) {
          if (state is AdminSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: fischerBlue700,
                content: Text(
                  state.message,
                  style: const TextStyle(fontFamily: 'Alexandria'),
                ),
              ),
            );
            Navigator.pop(context);
          } else if (state is AdminErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: red700,
                content: Text(
                  state.error,
                  style: const TextStyle(fontFamily: 'Alexandria'),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = AdminCubit.get(context);
          final isLoading = state is AdminLoadingState;

          return ThemedScaffold(
            backgroundImagePath: 'assets/images/bg2.png',
            appBar: AppBar(
              title: Text(
                isEditing ? 'تعديل المقال' : 'إضافة مقال',
                style: const TextStyle(
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
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildField(_titleCtrl, 'عنوان المقال', required: true),
                  _buildField(
                    _bodyCtrl,
                    'محتوى المقال',
                    required: true,
                    maxLines: 8,
                  ),
                  _buildField(_imageUrlCtrl, 'رابط الصورة (اختياري)'),
                  _buildField(_authorCtrl, 'اسم الكاتب'),

                  // Published toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Text(
                          'منشور',
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _isPublished,
                          onChanged: (v) => setState(() => _isPublished = v),
                          activeColor: fischerBlue300,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _submit(cubit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: fischerBlue500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEditing ? 'تحديث' : 'إضافة',
                              style: const TextStyle(
                                fontFamily: 'Alexandria',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label, {
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(
          fontFamily: 'Alexandria',
          color: Colors.white,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'Alexandria',
            color: Colors.white.withValues(alpha: 0.6),
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: red500),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: red500),
          ),
          filled: true,
          fillColor: fischerBlue900.withValues(alpha: 0.5),
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null
            : null,
      ),
    );
  }

  void _submit(AdminCubit cubit) {
    if (!_formKey.currentState!.validate()) return;

    if (isEditing) {
      cubit.updateArticle(widget.article!.id, {
        'title': _titleCtrl.text.trim(),
        'body': _bodyCtrl.text.trim(),
        'imageUrl': _imageUrlCtrl.text.trim(),
        'author': _authorCtrl.text.trim(),
        'isPublished': _isPublished,
      });
    } else {
      final article = ArticleModel(
        id: '',
        title: _titleCtrl.text.trim(),
        body: _bodyCtrl.text.trim(),
        imageUrl: _imageUrlCtrl.text.trim(),
        author: _authorCtrl.text.trim(),
        createdAt: DateTime.now(),
        isPublished: _isPublished,
      );
      cubit.addArticle(article);
    }
  }
}
