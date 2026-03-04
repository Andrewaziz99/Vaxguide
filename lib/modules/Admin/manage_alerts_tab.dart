import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaxguide/core/blocs/admin/admin_cubit.dart';
import 'package:vaxguide/core/models/vaccine_alert_model.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/modules/Admin/alert_form_screen.dart';
import 'package:vaxguide/shared/widgets.dart';

class ManageAlertsTab extends StatelessWidget {
  const ManageAlertsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = AdminCubit.get(context);

    return Stack(
      children: [
        StreamBuilder<List<VaccineAlertModel>>(
          stream: cubit.streamAlerts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: fischerBlue100),
              );
            }

            final alerts = snapshot.data ?? [];

            if (alerts.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد تنبيهات',
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
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return _AlertListTile(alert: alert);
              },
            );
          },
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: FloatingActionButton(
            heroTag: 'addAlert',
            backgroundColor: fischerBlue500,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () => navigateTo(context, const AlertFormScreen()),
          ),
        ),
      ],
    );
  }
}

class _AlertListTile extends StatelessWidget {
  final VaccineAlertModel alert;
  const _AlertListTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final cubit = AdminCubit.get(context);
    final dateStr = DateFormat('yyyy/MM/dd', 'ar').format(alert.createdAt);

    Color severityColor;
    switch (alert.severity) {
      case 'high':
        severityColor = red500;
        break;
      case 'medium':
        severityColor = Colors.orange;
        break;
      default:
        severityColor = fischerBlue300;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: fischerBlue900.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fischerBlue300.withValues(alpha: 0.15)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 8,
          height: 40,
          decoration: BoxDecoration(
            color: severityColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          alert.title,
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
                  color: alert.isActive
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  alert.isActive ? 'نشط' : 'غير نشط',
                  style: TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 10,
                    color: alert.isActive ? Colors.greenAccent : Colors.grey,
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
                  navigateTo(context, AlertFormScreen(alert: alert)),
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: red500, size: 20),
              onPressed: () => _confirmDelete(context, cubit, alert),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    AdminCubit cubit,
    VaccineAlertModel a,
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
          'حذف التنبيه',
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
              cubit.deleteAlert(a.id);
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
