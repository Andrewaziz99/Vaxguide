import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaxguide/core/blocs/auth/auth_cubit.dart';
import 'package:vaxguide/core/blocs/auth/auth_states.dart';
import 'package:vaxguide/core/constants/strings.dart';
import 'package:vaxguide/core/models/user_model.dart';
import 'package:vaxguide/core/repositories/user_repo.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/modules/Admin/admin_panel_screen.dart';
import 'package:vaxguide/modules/Auth/login_screen.dart';
import 'package:vaxguide/modules/Profile/profile_screen.dart';
import 'package:vaxguide/shared/widgets.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthStates>(
        listener: (context, state) {
          if (state is LogoutSuccessState) {
            navigateAndFinish(context, const LoginScreen());
          } else if (state is LogoutErrorState) {
            Navigator.pop(context); // close drawer
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
          final cubit = AuthCubit.get(context);
          final currentUser = FirebaseAuth.instance.currentUser;
          final uid = currentUser?.uid;

          return Drawer(
            backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  color: fischerBlue900.withValues(alpha: 0.75),
                  child: SafeArea(
                    child: uid == null
                        ? _buildUnauthenticatedDrawer(context, cubit, state)
                        : StreamBuilder<UserModel?>(
                            stream: UserRepo().streamUser(uid),
                            builder: (context, snapshot) {
                              final user = snapshot.data;
                              return _buildDrawerContent(
                                context,
                                cubit,
                                state,
                                uid,
                                user,
                              );
                            },
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Build drawer for unauthenticated state ──
  Widget _buildUnauthenticatedDrawer(
    BuildContext context,
    AuthCubit cubit,
    AuthStates state,
  ) {
    return _buildDrawerContent(context, cubit, state, null, null);
  }

  // ── Build full drawer content ──
  Widget _buildDrawerContent(
    BuildContext context,
    AuthCubit cubit,
    AuthStates state,
    String? uid,
    UserModel? user,
  ) {
    final bool isAdmin = user?.isAdmin ?? false;

    return Column(
      children: [
        // ── Header with user info ──
        _buildDrawerHeaderFromUser(user),

        // ── Divider ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Divider(
            color: fischerBlue100.withValues(alpha: 0.2),
            thickness: 1,
          ),
        ),

        const SizedBox(height: 8),

        // ── Menu Items ──
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            physics: const BouncingScrollPhysics(),
            children: [
              _DrawerItem(
                icon: Icons.person_rounded,
                title: drawerProfile,
                onTap: () {
                  Navigator.pop(context);
                  navigateTo(context, const ProfileScreen());
                },
              ),
              _DrawerItem(
                icon: Icons.notifications_rounded,
                title: drawerNotifications,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to notifications screen
                },
              ),
              _DrawerItem(
                icon: Icons.settings_rounded,
                title: drawerSettings,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to settings screen
                },
              ),

              // ── Admin Panel (only for admins) ──
              if (isAdmin) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Divider(
                    color: Colors.amber.withValues(alpha: 0.2),
                    thickness: 1,
                  ),
                ),
                _DrawerItem(
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'لوحة التحكم',
                  iconColor: Colors.amber,
                  textColor: Colors.amber.shade200,
                  onTap: () {
                    Navigator.pop(context);
                    navigateTo(context, const AdminPanelScreen());
                  },
                ),
              ],

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Divider(
                  color: fischerBlue100.withValues(alpha: 0.15),
                  thickness: 1,
                ),
              ),

              _DrawerItem(
                icon: Icons.info_outline_rounded,
                title: drawerAbout,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to about screen
                },
              ),
              _DrawerItem(
                icon: Icons.headset_mic_rounded,
                title: drawerContactUs,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to contact us screen
                },
              ),
            ],
          ),
        ),

        // ── Logout Button ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Divider(
            color: fischerBlue100.withValues(alpha: 0.15),
            thickness: 1,
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: state is LogoutLoadingState
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: fischerBlue100,
                    ),
                  ),
                )
              : _DrawerItem(
                  icon: Icons.logout_rounded,
                  title: drawerLogout,
                  iconColor: red500,
                  textColor: red300,
                  onTap: () => _showLogoutDialog(context, cubit),
                ),
        ),

        // ── Version ──
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            '$drawerVersion $appVersion',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 12,
              fontFamily: 'Alexandria',
            ),
          ),
        ),
      ],
    );
  }

  // ── Drawer Header from UserModel ──
  Widget _buildDrawerHeaderFromUser(UserModel? user) {
    if (user == null) {
      return _buildHeaderPlaceholder();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: user.isAdmin
                    ? [Colors.amber.shade600, Colors.amber.shade800]
                    : [fischerBlue300, fischerBlue500],
              ),
              boxShadow: [
                BoxShadow(
                  color: (user.isAdmin ? Colors.amber : fischerBlue500)
                      .withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getInitials(user.fullName),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Alexandria',
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Name & Email & Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Alexandria',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontFamily: 'Alexandria',
                  ),
                ),
                if (user.isAdmin) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text(
                      'مسؤول',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Alexandria',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderLoading() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fischerBlue700.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: fischerBlue700.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 160,
                  decoration: BoxDecoration(
                    color: fischerBlue700.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPlaceholder() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fischerBlue700.withValues(alpha: 0.5),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white54,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Alexandria',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  void _showLogoutDialog(BuildContext context, AuthCubit cubit) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: fischerBlue900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: fischerBlue100.withValues(alpha: 0.15)),
        ),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: red500.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.logout_rounded, color: red500, size: 32),
        ),
        title: const Text(
          drawerLogoutConfirmTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Alexandria',
          ),
        ),
        content: const Text(
          drawerLogoutConfirmMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontFamily: 'Alexandria',
            height: 1.5,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          // Cancel
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                drawerLogoutCancel,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'Alexandria',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Confirm Logout
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                cubit.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: red500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: const Text(
                drawerLogoutConfirm,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Alexandria',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Drawer Item Widget ──
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: fischerBlue100.withValues(alpha: 0.1),
          highlightColor: fischerBlue100.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (iconColor ?? fischerBlue100).withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? fischerBlue100,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: 15,
                      fontFamily: 'Alexandria',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: (textColor ?? Colors.white).withValues(alpha: 0.3),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
