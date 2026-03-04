import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaxguide/core/blocs/admin/admin_cubit.dart';
import 'package:vaxguide/core/blocs/admin/admin_states.dart';
import 'package:vaxguide/core/models/vaccine_model.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/core/styles/themeScaffold.dart';

class VaccineFormScreen extends StatefulWidget {
  final VaccineModel? vaccine;
  const VaccineFormScreen({super.key, this.vaccine});

  @override
  State<VaccineFormScreen> createState() => _VaccineFormScreenState();
}

class _VaccineFormScreenState extends State<VaccineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _subcategoryCtrl;
  late final TextEditingController _importanceCtrl;
  late final TextEditingController _scheduleCtrl;
  late final TextEditingController _adminMethodCtrl;
  late final TextEditingController _sideEffectsCtrl;
  late final TextEditingController _locationsCtrl;
  late final TextEditingController _precautionsCtrl;
  late final TextEditingController _warningsCtrl;
  late final TextEditingController _countriesCtrl;

  bool get isEditing => widget.vaccine != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vaccine;
    _nameCtrl = TextEditingController(text: v?.name ?? '');
    _categoryCtrl = TextEditingController(text: v?.category ?? '');
    _subcategoryCtrl = TextEditingController(text: v?.subcategory ?? '');
    _importanceCtrl = TextEditingController(text: v?.importance ?? '');
    _scheduleCtrl = TextEditingController(text: v?.schedule ?? '');
    _adminMethodCtrl = TextEditingController(
      text: v?.administrationMethod ?? '',
    );
    _sideEffectsCtrl = TextEditingController(text: v?.sideEffects ?? '');
    _locationsCtrl = TextEditingController(text: v?.locations ?? '');
    _precautionsCtrl = TextEditingController(text: v?.precautions ?? '');
    _warningsCtrl = TextEditingController(text: v?.warnings ?? '');
    _countriesCtrl = TextEditingController(text: v?.countries.join(', ') ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _subcategoryCtrl.dispose();
    _importanceCtrl.dispose();
    _scheduleCtrl.dispose();
    _adminMethodCtrl.dispose();
    _sideEffectsCtrl.dispose();
    _locationsCtrl.dispose();
    _precautionsCtrl.dispose();
    _warningsCtrl.dispose();
    _countriesCtrl.dispose();
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
                isEditing ? 'تعديل التطعيم' : 'إضافة تطعيم',
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
                  _buildField(_nameCtrl, 'اسم التطعيم', required: true),
                  _buildField(
                    _categoryCtrl,
                    'الفئة (preschool, school, travel, additional)',
                    required: true,
                  ),
                  _buildField(
                    _subcategoryCtrl,
                    'الفئة الفرعية',
                    required: true,
                  ),
                  _buildField(_importanceCtrl, 'أهمية التطعيم', maxLines: 3),
                  _buildField(_scheduleCtrl, 'الجدول الزمني', maxLines: 3),
                  _buildField(_adminMethodCtrl, 'طريقة الإعطاء', maxLines: 2),
                  _buildField(_sideEffectsCtrl, 'الآثار الجانبية', maxLines: 3),
                  _buildField(_locationsCtrl, 'أماكن التلقي', maxLines: 2),
                  _buildField(_precautionsCtrl, 'الاحتياطات', maxLines: 3),
                  _buildField(_warningsCtrl, 'تحذيرات', maxLines: 3),
                  _buildField(
                    _countriesCtrl,
                    'الدول (مفصولة بفاصلة) - لتطعيمات السفر',
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

    final countries = _countriesCtrl.text
        .split(',')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();

    final vaccine = VaccineModel(
      id: widget.vaccine?.id ?? '',
      name: _nameCtrl.text.trim(),
      category: _categoryCtrl.text.trim(),
      subcategory: _subcategoryCtrl.text.trim(),
      importance: _importanceCtrl.text.trim(),
      schedule: _scheduleCtrl.text.trim(),
      administrationMethod: _adminMethodCtrl.text.trim(),
      sideEffects: _sideEffectsCtrl.text.trim(),
      locations: _locationsCtrl.text.trim(),
      precautions: _precautionsCtrl.text.trim(),
      warnings: _warningsCtrl.text.trim(),
      countries: countries,
    );

    if (isEditing) {
      cubit.updateVaccine(vaccine);
    } else {
      cubit.addVaccine(vaccine);
    }
  }
}
