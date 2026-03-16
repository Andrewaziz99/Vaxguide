import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaxguide/core/blocs/admin/admin_cubit.dart';
import 'package:vaxguide/core/blocs/admin/admin_states.dart';
import 'package:vaxguide/core/styles/colors.dart';

class ManageAboutTab extends StatefulWidget {
  const ManageAboutTab({super.key});

  @override
  State<ManageAboutTab> createState() => _ManageAboutTabState();
}

class _ManageAboutTabState extends State<ManageAboutTab> {
  final TextEditingController _aboutController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = AdminCubit.get(context);
    final isSaving = context.watch<AdminCubit>().state is AdminLoadingState;

    return StreamBuilder<String>(
      stream: cubit.streamAboutText(),
      builder: (context, snapshot) {
        if (!_initialized && snapshot.hasData) {
          _aboutController.text = snapshot.data!;
          _initialized = true;
        }

        if (!_initialized &&
            snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: fischerBlue100),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          physics: const BouncingScrollPhysics(),
          children: [
            Text(
              'نص نافذة "حول التطبيق" التي تظهر عند أول دخول للمستخدم.',
              style: TextStyle(
                fontFamily: 'Alexandria',
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: fischerBlue900.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: fischerBlue300.withValues(alpha: 0.2),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _aboutController,
                maxLines: 12,
                minLines: 8,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Alexandria',
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: 'اكتب نص حول التطبيق هنا...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontFamily: 'Alexandria',
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isSaving
                    ? null
                    : () {
                        final text = _aboutController.text.trim();
                        if (text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: red700,
                              content: Text(
                                'نص حول التطبيق لا يمكن أن يكون فارغًا',
                                style: TextStyle(fontFamily: 'Alexandria'),
                              ),
                            ),
                          );
                          return;
                        }

                        cubit.updateAboutText(
                          text: text,
                          updatedBy: FirebaseAuth.instance.currentUser?.uid,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: fischerBlue500,
                  foregroundColor: Colors.white,
                ),
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  isSaving ? 'جارٍ الحفظ...' : 'حفظ النص',
                  style: const TextStyle(
                    fontFamily: 'Alexandria',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
