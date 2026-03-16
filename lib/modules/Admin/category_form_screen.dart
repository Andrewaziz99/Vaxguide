import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaxguide/core/blocs/admin/admin_cubit.dart';
import 'package:vaxguide/core/blocs/admin/admin_states.dart';
import 'package:vaxguide/core/models/vaccine_category_model.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/core/styles/themeScaffold.dart';

class CategoryFormScreen extends StatefulWidget {
  final VaccineCategoryModel? category;
  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _keyCtrl;
  late final TextEditingController _labelCtrl;
  late final TextEditingController _displayOrderCtrl;
  late String _selectedIcon;
  late List<String> _subcategories;
  final _subcategoryCtrl = TextEditingController();

  bool get isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _keyCtrl = TextEditingController(text: c?.key ?? '');
    _labelCtrl = TextEditingController(text: c?.label ?? '');
    _displayOrderCtrl = TextEditingController(
      text: c?.displayOrder?.toString() ?? '',
    );
    _selectedIcon = c?.icon ?? 'vaccines_rounded';
    _subcategories = List<String>.from(c?.subcategories ?? []);
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _labelCtrl.dispose();
    _displayOrderCtrl.dispose();
    _subcategoryCtrl.dispose();
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
                isEditing ? 'تعديل الفئة' : 'إضافة فئة',
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
                  // Key field
                  _buildField(
                    _keyCtrl,
                    'المفتاح (مثال: preschool, travel)',
                    required: true,
                    enabled: !isEditing,
                    hint: 'يستخدم كمعرف فريد - لا يمكن تغييره لاحقاً',
                  ),
                  // Label field
                  _buildField(_labelCtrl, 'اسم الفئة (عربي)', required: true),
                  _buildField(
                    _displayOrderCtrl,
                    'ترتيب العرض (اختياري)',
                    hint:
                        'رقم أصغر يظهر أولاً - اتركه فارغاً للترتيب الافتراضي',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final text = (v ?? '').trim();
                      if (text.isEmpty) return null;
                      final parsed = int.tryParse(text);
                      if (parsed == null || parsed < 0) {
                        return 'أدخل رقم صحيح 0 أو أكبر';
                      }
                      return null;
                    },
                  ),
                  // Icon picker
                  _buildIconPicker(),
                  const SizedBox(height: 20),
                  // Subcategories section
                  _buildSubcategoriesSection(),
                  const SizedBox(height: 28),
                  // Submit button
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
    bool enabled = true,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        enabled: enabled,
        keyboardType: keyboardType,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontFamily: 'Alexandria',
          color: enabled ? Colors.white : Colors.white54,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: label,
          helperText: hint,
          helperStyle: TextStyle(
            fontFamily: 'Alexandria',
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 11,
          ),
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
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: fischerBlue300.withValues(alpha: 0.15),
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
        validator:
            validator ??
            (required
                ? (v) =>
                      (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null
                : null),
      ),
    );
  }

  Widget _buildIconPicker() {
    final icons = VaccineCategoryModel.availableIcons;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأيقونة',
            style: TextStyle(
              fontFamily: 'Alexandria',
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: fischerBlue900.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: fischerBlue300.withValues(alpha: 0.3)),
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: icons.map((iconName) {
                final isSelected = _selectedIcon == iconName;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = iconName),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? fischerBlue100.withValues(alpha: 0.25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? Border.all(color: fischerBlue100, width: 2)
                          : Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                    ),
                    child: Icon(
                      VaccineCategoryModel.resolveIcon(iconName),
                      color: isSelected ? fischerBlue100 : Colors.white54,
                      size: 22,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الفئات الفرعية',
          style: TextStyle(
            fontFamily: 'Alexandria',
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: fischerBlue900.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: fischerBlue300.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              // Existing subcategories
              if (_subcategories.isNotEmpty) ...[
                ..._subcategories.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
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
                            entry.value,
                            style: const TextStyle(
                              fontFamily: 'Alexandria',
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _subcategories.removeAt(entry.key);
                            });
                          },
                          child: Icon(
                            Icons.close_rounded,
                            color: red300.withValues(alpha: 0.7),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],
              // Add new subcategory input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subcategoryCtrl,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: 'Alexandria',
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: 'اكتب اسم الفئة الفرعية...',
                        hintStyle: TextStyle(
                          fontFamily: 'Alexandria',
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 12,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: fischerBlue300.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: fischerBlue300),
                        ),
                        filled: true,
                        fillColor: fischerBlue900.withValues(alpha: 0.3),
                      ),
                      onSubmitted: (_) => _addSubcategory(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _addSubcategory,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: fischerBlue500,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addSubcategory() {
    final text = _subcategoryCtrl.text.trim();
    if (text.isNotEmpty && !_subcategories.contains(text)) {
      setState(() {
        _subcategories.add(text);
        _subcategoryCtrl.clear();
      });
    }
  }

  void _submit(AdminCubit cubit) {
    if (!_formKey.currentState!.validate()) return;

    final key = _keyCtrl.text.trim().toLowerCase().replaceAll(' ', '_');
    final orderText = _displayOrderCtrl.text.trim();
    final category = VaccineCategoryModel(
      key: isEditing ? widget.category!.key : key,
      label: _labelCtrl.text.trim(),
      icon: _selectedIcon,
      displayOrder: orderText.isEmpty ? null : int.parse(orderText),
      subcategories: _subcategories,
    );

    if (isEditing) {
      cubit.updateCategory(category);
    } else {
      cubit.addCategory(category);
    }
  }
}
