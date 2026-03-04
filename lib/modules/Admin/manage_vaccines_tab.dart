import 'package:flutter/material.dart';
import 'package:vaxguide/core/blocs/admin/admin_cubit.dart';
import 'package:vaxguide/core/models/vaccine_model.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/modules/Admin/vaccine_form_screen.dart';
import 'package:vaxguide/shared/widgets.dart';

class ManageVaccinesTab extends StatelessWidget {
  const ManageVaccinesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = AdminCubit.get(context);

    return Stack(
      children: [
        StreamBuilder<List<VaccineModel>>(
          stream: cubit.streamVaccines(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: fischerBlue100),
              );
            }

            final vaccines = snapshot.data ?? [];

            if (vaccines.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد تطعيمات',
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
              itemCount: vaccines.length,
              itemBuilder: (context, index) {
                final vaccine = vaccines[index];
                return _VaccineListTile(vaccine: vaccine);
              },
            );
          },
        ),
        // FAB
        Positioned(
          bottom: 16,
          left: 16,
          child: FloatingActionButton(
            heroTag: 'addVaccine',
            backgroundColor: fischerBlue500,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () => navigateTo(context, const VaccineFormScreen()),
          ),
        ),
      ],
    );
  }
}

class _VaccineListTile extends StatelessWidget {
  final VaccineModel vaccine;
  const _VaccineListTile({required this.vaccine});

  @override
  Widget build(BuildContext context) {
    final cubit = AdminCubit.get(context);

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
          vaccine.name,
          style: const TextStyle(
            fontFamily: 'Alexandria',
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${vaccine.category} • ${vaccine.subcategory}',
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
                  navigateTo(context, VaccineFormScreen(vaccine: vaccine)),
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: red500, size: 20),
              onPressed: () => _confirmDelete(context, cubit, vaccine),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminCubit cubit, VaccineModel v) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: fischerBlue900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: fischerBlue100.withValues(alpha: 0.15)),
        ),
        title: const Text(
          'حذف التطعيم',
          style: TextStyle(
            fontFamily: 'Alexandria',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف "${v.name}"؟',
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
              cubit.deleteVaccine(v.id);
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
