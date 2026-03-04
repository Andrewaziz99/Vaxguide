import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vaxguide/core/blocs/admin/admin_cubit.dart';
import 'package:vaxguide/core/models/user_model.dart';
import 'package:vaxguide/core/styles/colors.dart';

class ManageUsersTab extends StatelessWidget {
  const ManageUsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('fullName')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: fischerBlue100),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Text(
              'لا يوجد مستخدمين',
              style: TextStyle(
                fontFamily: 'Alexandria',
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          );
        }

        final users = docs.map((doc) => UserModel.fromFirestore(doc)).toList();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          physics: const BouncingScrollPhysics(),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _UserListTile(user: user);
          },
        );
      },
    );
  }
}

class _UserListTile extends StatelessWidget {
  final UserModel user;
  const _UserListTile({required this.user});

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
        leading: CircleAvatar(
          backgroundColor: user.isAdmin
              ? Colors.amber.withValues(alpha: 0.2)
              : fischerBlue700.withValues(alpha: 0.5),
          child: Icon(
            user.isAdmin
                ? Icons.admin_panel_settings_rounded
                : Icons.person_rounded,
            color: user.isAdmin ? Colors.amber : fischerBlue100,
            size: 22,
          ),
        ),
        title: Text(
          user.fullName,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.email,
                style: TextStyle(
                  fontFamily: 'Alexandria',
                  color: fischerBlue300,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: user.isAdmin
                      ? Colors.amber.withValues(alpha: 0.15)
                      : fischerBlue500.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  user.isAdmin ? 'مسؤول' : 'مستخدم',
                  style: TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: user.isAdmin ? Colors.amber : fischerBlue300,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          color: fischerBlue900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: fischerBlue300.withValues(alpha: 0.15)),
          ),
          onSelected: (value) {
            switch (value) {
              case 'promote':
                _confirmAction(
                  context,
                  cubit,
                  'ترقية إلى مسؤول',
                  'هل أنت متأكد من ترقية "${user.fullName}" إلى مسؤول؟',
                  () => cubit.updateUserType(user.uid, 'admin'),
                );
                break;
              case 'demote':
                _confirmAction(
                  context,
                  cubit,
                  'تخفيض إلى مستخدم',
                  'هل أنت متأكد من تخفيض "${user.fullName}" إلى مستخدم عادي؟',
                  () => cubit.updateUserType(user.uid, 'user'),
                );
                break;
              case 'delete':
                _confirmAction(
                  context,
                  cubit,
                  'حذف المستخدم',
                  'هل أنت متأكد من حذف "${user.fullName}"؟ هذا الإجراء لا يمكن التراجع عنه.',
                  () => cubit.deleteUser(user.uid),
                  isDestructive: true,
                );
                break;
            }
          },
          itemBuilder: (context) => [
            if (!user.isAdmin)
              const PopupMenuItem(
                value: 'promote',
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.amber,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'ترقية إلى مسؤول',
                      style: TextStyle(
                        fontFamily: 'Alexandria',
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            if (user.isAdmin)
              const PopupMenuItem(
                value: 'demote',
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      color: fischerBlue300,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'تخفيض إلى مستخدم',
                      style: TextStyle(
                        fontFamily: 'Alexandria',
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_rounded, color: red500, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'حذف المستخدم',
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      color: red500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmAction(
    BuildContext context,
    AdminCubit cubit,
    String title,
    String message,
    VoidCallback onConfirm, {
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: fischerBlue900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: fischerBlue100.withValues(alpha: 0.15)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Alexandria',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
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
              onConfirm();
            },
            child: Text(
              'تأكيد',
              style: TextStyle(
                fontFamily: 'Alexandria',
                color: isDestructive ? red500 : fischerBlue300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
