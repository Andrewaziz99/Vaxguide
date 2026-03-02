import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vaxguide/core/constants/strings.dart';
import 'package:vaxguide/core/models/user_model.dart';
import 'package:vaxguide/core/repositories/user_repo.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/core/styles/themeScaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userRepo = UserRepo();
  final _uid = FirebaseAuth.instance.currentUser?.uid;

  bool _isEditing = false;

  // Controllers for edit mode
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedGender;

  bool _isSaving = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _populateControllers(UserModel user) {
    _fullNameController.text = user.fullName;
    _usernameController.text = user.username;
    _phoneController.text = user.phone;
    _addressController.text = user.address;
    _selectedGender = user.gender;
  }

  Future<void> _saveProfile() async {
    if (_uid == null) return;
    setState(() => _isSaving = true);

    try {
      await _userRepo.updateProfile(
        uid: _uid,
        fullName: _fullNameController.text.trim(),
        username: _usernameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        gender: _selectedGender,
      );

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              profileEditSuccess,
              style: TextStyle(fontFamily: 'Alexandria'),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              profileEditError,
              style: TextStyle(fontFamily: 'Alexandria'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return ThemedScaffold(
        appBar: _buildAppBar(),
        body: const Center(
          child: Text(
            profileNotFound,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontFamily: 'Alexandria',
            ),
          ),
        ),
      );
    }

    return ThemedScaffold(
      appBar: _buildAppBar(),
      body: StreamBuilder<UserModel?>(
        stream: _userRepo.streamUser(_uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: fischerBlue100),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                profileLoadError,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontFamily: 'Alexandria',
                ),
              ),
            );
          }

          final user = snapshot.data;
          if (user == null) {
            return Center(
              child: Text(
                profileNotFound,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontFamily: 'Alexandria',
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ── Avatar Header ──
                _buildAvatarHeader(user),
                const SizedBox(height: 24),

                // ── Personal Info Section ──
                _buildSectionTitle(
                  profilePersonalInfo,
                  Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),
                _isEditing ? _buildEditForm(user) : _buildInfoCards(user),
                const SizedBox(height: 28),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        profileTitle,
        style: TextStyle(
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
      actions: [
        if (!_isEditing)
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: fischerBlue100),
            onPressed: () {
              // Populate controllers from the latest stream data
              final uid = _uid;
              if (uid != null) {
                _userRepo.getUserById(uid).then((user) {
                  if (user != null && mounted) {
                    _populateControllers(user);
                    setState(() => _isEditing = true);
                  }
                });
              }
            },
          )
        else ...[
          IconButton(
            icon: const Icon(Icons.close_rounded, color: red300),
            onPressed: () => setState(() => _isEditing = false),
          ),
        ],
      ],
    );
  }

  // ── Avatar Header ──
  Widget _buildAvatarHeader(UserModel user) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [fischerBlue300, fischerBlue500],
            ),
            boxShadow: [
              BoxShadow(
                color: fischerBlue500.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _getInitials(user.fullName),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Alexandria',
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          user.fullName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Alexandria',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '@${user.username}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 14,
            fontFamily: 'Alexandria',
          ),
        ),
        if (user.createdAt != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: Colors.white.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 6),
              Text(
                '$profileMemberSince ${DateFormat('yyyy/MM/dd').format(user.createdAt!)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                  fontFamily: 'Alexandria',
                ),
              ),
            ],
          ),
        ],
        if (user.isAdmin) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: fischerBlue100.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: fischerBlue100.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'مسؤول',
              style: TextStyle(
                color: fischerBlue100,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Alexandria',
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Section Title ──
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: fischerBlue100, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: fischerBlue100,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            fontFamily: 'Alexandria',
          ),
        ),
      ],
    );
  }

  // ── Info Cards (view mode) ──
  Widget _buildInfoCards(UserModel user) {
    return Column(
      children: [
        _BlurryInfoRow(
          icon: Icons.person_rounded,
          label: fullName,
          value: user.fullName,
        ),
        _BlurryInfoRow(
          icon: Icons.alternate_email_rounded,
          label: username,
          value: user.username,
        ),
        _BlurryInfoRow(
          icon: Icons.email_rounded,
          label: email,
          value: user.email,
        ),
        _BlurryInfoRow(
          icon: Icons.phone_rounded,
          label: phone,
          value: user.phone,
        ),
        _BlurryInfoRow(
          icon: Icons.location_on_rounded,
          label: address,
          value: user.address,
        ),
        _BlurryInfoRow(
          icon: Icons.wc_rounded,
          label: gender,
          value: user.gender,
        ),
        _BlurryInfoRow(
          icon: Icons.admin_panel_settings_rounded,
          label: userType,
          value: user.isAdmin ? 'مسؤول' : 'مستخدم',
        ),
      ],
    );
  }

  // ── Edit Form ──
  Widget _buildEditForm(UserModel user) {
    return Column(
      children: [
        _BlurryEditField(
          icon: Icons.person_rounded,
          label: fullName,
          controller: _fullNameController,
        ),
        _BlurryEditField(
          icon: Icons.alternate_email_rounded,
          label: username,
          controller: _usernameController,
        ),
        _BlurryEditField(
          icon: Icons.phone_rounded,
          label: phone,
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
        _BlurryEditField(
          icon: Icons.location_on_rounded,
          label: address,
          controller: _addressController,
        ),
        // Gender dropdown
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.wc_rounded,
                      color: fischerBlue100,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value:
                              (_selectedGender == 'ذكر' ||
                                  _selectedGender == 'أنثى')
                              ? _selectedGender
                              : null,
                          hint: Text(
                            gender,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontFamily: 'Alexandria',
                              fontSize: 14,
                            ),
                          ),
                          dropdownColor: fischerBlue900,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white70,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Alexandria',
                            fontSize: 14,
                          ),
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'ذكر', child: Text(male)),
                            DropdownMenuItem(
                              value: 'أنثى',
                              child: Text(female),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedGender = value),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Save button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveProfile,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: fischerBlue900,
                    ),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(
              profileSave,
              style: const TextStyle(
                fontFamily: 'Alexandria',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: fischerBlue100,
              foregroundColor: fischerBlue900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
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
}

// ── Blurry Info Row (view mode) ──
class _BlurryInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _BlurryInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Icon(icon, color: fischerBlue100, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                          fontFamily: 'Alexandria',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value.isNotEmpty ? value : '—',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'Alexandria',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Blurry Edit Field ──
class _BlurryEditField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _BlurryEditField({
    required this.icon,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Icon(icon, color: fischerBlue100, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Alexandria',
                    ),
                    decoration: InputDecoration(
                      labelText: label,
                      floatingLabelAlignment: FloatingLabelAlignment.start,
                      alignLabelWithHint: true,
                      labelStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontFamily: 'Alexandria',
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
