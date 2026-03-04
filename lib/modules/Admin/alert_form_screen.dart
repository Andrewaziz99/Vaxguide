import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaxguide/core/blocs/admin/admin_cubit.dart';
import 'package:vaxguide/core/blocs/admin/admin_states.dart';
import 'package:vaxguide/core/models/vaccine_alert_model.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/core/styles/themeScaffold.dart';

class AlertFormScreen extends StatefulWidget {
  final VaccineAlertModel? alert;
  const AlertFormScreen({super.key, this.alert});

  @override
  State<AlertFormScreen> createState() => _AlertFormScreenState();
}

class _AlertFormScreenState extends State<AlertFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _messageCtrl;
  late final TextEditingController _vaccineNameCtrl;
  late String _severity;
  late bool _isActive;

  bool get isEditing => widget.alert != null;

  @override
  void initState() {
    super.initState();
    final a = widget.alert;
    _titleCtrl = TextEditingController(text: a?.title ?? '');
    _messageCtrl = TextEditingController(text: a?.message ?? '');
    _vaccineNameCtrl = TextEditingController(text: a?.vaccineName ?? '');
    _severity = a?.severity ?? 'info';
    _isActive = a?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    _vaccineNameCtrl.dispose();
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
                isEditing ? 'تعديل التنبيه' : 'إضافة تنبيه',
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
                  _buildField(_titleCtrl, 'عنوان التنبيه', required: true),
                  _buildField(
                    _messageCtrl,
                    'نص التنبيه',
                    required: true,
                    maxLines: 4,
                  ),
                  _buildField(_vaccineNameCtrl, 'اسم اللقاح (اختياري)'),

                  // Severity dropdown
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: DropdownButtonFormField<String>(
                      value: _severity,
                      dropdownColor: fischerBlue900,
                      style: const TextStyle(
                        fontFamily: 'Alexandria',
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'درجة الخطورة',
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
                        filled: true,
                        fillColor: fischerBlue900.withValues(alpha: 0.5),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'high',
                          child: Text(
                            'عالية',
                            style: TextStyle(fontFamily: 'Alexandria'),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'medium',
                          child: Text(
                            'متوسطة',
                            style: TextStyle(fontFamily: 'Alexandria'),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'info',
                          child: Text(
                            'معلوماتي',
                            style: TextStyle(fontFamily: 'Alexandria'),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _severity = v);
                      },
                    ),
                  ),

                  // Active toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Text(
                          'نشط',
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _isActive,
                          onChanged: (v) => setState(() => _isActive = v),
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
      cubit.updateAlert(widget.alert!.id, {
        'title': _titleCtrl.text.trim(),
        'message': _messageCtrl.text.trim(),
        'vaccineName': _vaccineNameCtrl.text.trim(),
        'severity': _severity,
        'isActive': _isActive,
      });
    } else {
      final alert = VaccineAlertModel(
        id: '',
        title: _titleCtrl.text.trim(),
        message: _messageCtrl.text.trim(),
        vaccineName: _vaccineNameCtrl.text.trim(),
        severity: _severity,
        isActive: _isActive,
        createdAt: DateTime.now(),
      );
      cubit.addAlert(alert);
    }
  }
}
