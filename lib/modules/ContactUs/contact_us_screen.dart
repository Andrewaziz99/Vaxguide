import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaxguide/core/constants/strings.dart';
import 'package:vaxguide/core/models/support_ticket_model.dart';
import 'package:vaxguide/core/models/user_model.dart';
import 'package:vaxguide/core/repositories/support_repo.dart';
import 'package:vaxguide/core/repositories/user_repo.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/core/styles/themeScaffold.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _supportRepo = SupportRepo();

  bool _isSubmitting = false;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final user = await UserRepo().getUserById(uid);
    if (mounted) setState(() => _user = user);
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return ThemedScaffold(
      backgroundImagePath: 'assets/images/bg2.png',
      appBar: AppBar(
        title: const Text(
          contactUsTitle,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    fischerBlue500.withValues(alpha: 0.2),
                    fischerBlue700.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: fischerBlue300.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: fischerBlue100.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.headset_mic_rounded,
                      color: fischerBlue100,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          contactUsSubtitle,
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contactUsDesc,
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.6),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Contact Form ──
            _GlassCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info (auto-filled, read-only)
                    if (_user != null) ...[
                      _ReadOnlyField(
                        icon: Icons.person_rounded,
                        label: contactUsName,
                        value: _user!.fullName,
                      ),
                      const SizedBox(height: 12),
                      _ReadOnlyField(
                        icon: Icons.email_rounded,
                        label: contactUsEmail,
                        value: _user!.email,
                      ),
                      const SizedBox(height: 16),
                      Divider(color: fischerBlue100.withValues(alpha: 0.15)),
                      const SizedBox(height: 16),
                    ],

                    // Subject
                    Text(
                      contactUsSubject,
                      style: TextStyle(
                        fontFamily: 'Alexandria',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _subjectCtrl,
                      style: const TextStyle(
                        fontFamily: 'Alexandria',
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: _inputDecoration(contactUsSubjectHint),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return contactUsFieldRequired;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Message
                    Text(
                      contactUsMessage,
                      style: TextStyle(
                        fontFamily: 'Alexandria',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _messageCtrl,
                      maxLines: 5,
                      style: const TextStyle(
                        fontFamily: 'Alexandria',
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: _inputDecoration(contactUsMessageHint),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return contactUsFieldRequired;
                        }
                        if (v.trim().length < 10) {
                          return contactUsMessageTooShort;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: fischerBlue500,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          disabledBackgroundColor: fischerBlue700.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(
                          _isSubmitting ? contactUsSubmitting : contactUsSubmit,
                          style: const TextStyle(
                            fontFamily: 'Alexandria',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Previous Tickets ──
            if (uid != null) ...[
              Row(
                children: [
                  Icon(Icons.history_rounded, color: fischerBlue100, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    contactUsPreviousTickets,
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: fischerBlue100,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<SupportTicketModel>>(
                stream: _supportRepo.streamUserTickets(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: CircularProgressIndicator(color: fischerBlue100),
                      ),
                    );
                  }

                  final tickets = snapshot.data ?? [];

                  if (tickets.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          contactUsNoTickets,
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: tickets
                        .map((t) => _TicketCard(ticket: t))
                        .toList(),
                  );
                },
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'Alexandria',
        color: Colors.white.withValues(alpha: 0.3),
        fontSize: 13,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: fischerBlue300.withValues(alpha: 0.3)),
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
      fillColor: fischerBlue900.withValues(alpha: 0.4),
      errorStyle: const TextStyle(fontFamily: 'Alexandria', fontSize: 11),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _user == null) return;

    setState(() => _isSubmitting = true);

    try {
      final ticket = SupportTicketModel(
        id: '',
        uid: uid,
        fullName: _user!.fullName,
        email: _user!.email,
        subject: _subjectCtrl.text.trim(),
        message: _messageCtrl.text.trim(),
        createdAt: DateTime.now(),
      );

      await _supportRepo.submitTicket(ticket);

      if (mounted) {
        _subjectCtrl.clear();
        _messageCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              contactUsSuccess,
              style: TextStyle(fontFamily: 'Alexandria'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: red700,
            content: Text(
              '$contactUsError: $e',
              style: const TextStyle(fontFamily: 'Alexandria'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

// ══════════════════════════════════════════
// REUSABLE WIDGETS
// ══════════════════════════════════════════

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReadOnlyField({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: fischerBlue300, size: 18),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Alexandria',
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Alexandria',
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicketModel ticket;
  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat(
      'yyyy/MM/dd – HH:mm',
      'ar',
    ).format(ticket.createdAt);

    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    switch (ticket.status) {
      case 'in_progress':
        statusColor = Colors.amber;
        statusLabel = contactUsStatusInProgress;
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case 'resolved':
        statusColor = Colors.greenAccent;
        statusLabel = contactUsStatusResolved;
        statusIcon = Icons.check_circle_rounded;
        break;
      default:
        statusColor = fischerBlue300;
        statusLabel = contactUsStatusOpen;
        statusIcon = Icons.schedule_rounded;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject & status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ticket.subject,
                        style: const TextStyle(
                          fontFamily: 'Alexandria',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontFamily: 'Alexandria',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Message preview
                Text(
                  ticket.message,
                  style: TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Date
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontFamily: 'Alexandria',
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
