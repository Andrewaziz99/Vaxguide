import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaxguide/core/blocs/admin/admin_cubit.dart';
import 'package:vaxguide/core/models/support_ticket_model.dart';
import 'package:vaxguide/core/styles/colors.dart';

class ManageSupportTab extends StatelessWidget {
  const ManageSupportTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = AdminCubit.get(context);

    return StreamBuilder<List<SupportTicketModel>>(
      stream: cubit.streamSupportTickets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: fischerBlue100),
          );
        }

        final tickets = snapshot.data ?? [];

        if (tickets.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.support_agent_rounded,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
                const SizedBox(height: 12),
                Text(
                  'لا توجد تذاكر دعم',
                  style: TextStyle(
                    fontFamily: 'Alexandria',
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
          physics: const BouncingScrollPhysics(),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            return _TicketListTile(ticket: tickets[index]);
          },
        );
      },
    );
  }
}

class _TicketListTile extends StatelessWidget {
  final SupportTicketModel ticket;
  const _TicketListTile({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat(
      'yyyy/MM/dd – HH:mm',
      'ar',
    ).format(ticket.createdAt);

    final (Color statusColor, String statusLabel, IconData statusIcon) =
        _statusInfo(ticket.status);

    return GestureDetector(
      onTap: () => _openTicketDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: fischerBlue900.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: fischerBlue300.withValues(alpha: 0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
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
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(
                    color: statusColor,
                    label: statusLabel,
                    icon: statusIcon,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // User info
              Row(
                children: [
                  Icon(Icons.person_rounded, size: 14, color: fischerBlue300),
                  const SizedBox(width: 4),
                  Text(
                    ticket.fullName,
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      fontSize: 12,
                      color: fischerBlue300,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.email_rounded,
                    size: 14,
                    color: fischerBlue300.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      ticket.email,
                      style: TextStyle(
                        fontFamily: 'Alexandria',
                        fontSize: 11,
                        color: fischerBlue300.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

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

              // Date & reply indicator
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
                  if (ticket.hasReply) ...[
                    const Spacer(),
                    Icon(
                      Icons.reply_rounded,
                      size: 14,
                      color: Colors.greenAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'تم الرد',
                      style: TextStyle(
                        fontFamily: 'Alexandria',
                        fontSize: 11,
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openTicketDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          _TicketDetailSheet(ticket: ticket, cubit: AdminCubit.get(context)),
    );
  }

  (Color, String, IconData) _statusInfo(String status) {
    switch (status) {
      case 'in_progress':
        return (Colors.amber, 'قيد المعالجة', Icons.hourglass_top_rounded);
      case 'resolved':
        return (Colors.greenAccent, 'تم الحل', Icons.check_circle_rounded);
      default:
        return (fischerBlue300, 'مفتوح', Icons.schedule_rounded);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final Color color;
  final String label;
  final IconData icon;

  const _StatusBadge({
    required this.color,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Alexandria',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// TICKET DETAIL BOTTOM SHEET
// ═══════════════════════════════════════════

class _TicketDetailSheet extends StatefulWidget {
  final SupportTicketModel ticket;
  final AdminCubit cubit;

  const _TicketDetailSheet({required this.ticket, required this.cubit});

  @override
  State<_TicketDetailSheet> createState() => _TicketDetailSheetState();
}

class _TicketDetailSheetState extends State<_TicketDetailSheet> {
  final _replyCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    if (widget.ticket.hasReply) {
      _replyCtrl.text = widget.ticket.adminReply;
    }
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;
    final dateStr = DateFormat(
      'yyyy/MM/dd – HH:mm',
      'ar',
    ).format(ticket.createdAt);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (ctx, scrollCtrl) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: fischerBlue900.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border.all(
                  color: fischerBlue300.withValues(alpha: 0.2),
                ),
              ),
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: fischerBlue100.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: fischerBlue100,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'تفاصيل التذكرة',
                              style: TextStyle(
                                fontFamily: 'Alexandria',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'ID: ${ticket.id.substring(0, 8)}...',
                              style: TextStyle(
                                fontFamily: 'Alexandria',
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status dropdown
                      _buildStatusDropdown(),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // User info card
                  _InfoCard(
                    children: [
                      _InfoRow(
                        icon: Icons.person_rounded,
                        label: 'الاسم',
                        value: ticket.fullName,
                      ),
                      _InfoRow(
                        icon: Icons.email_rounded,
                        label: 'البريد',
                        value: ticket.email,
                      ),
                      _InfoRow(
                        icon: Icons.access_time_rounded,
                        label: 'التاريخ',
                        value: dateStr,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Subject
                  _InfoCard(
                    children: [
                      Text(
                        'الموضوع',
                        style: TextStyle(
                          fontFamily: 'Alexandria',
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticket.subject,
                        style: const TextStyle(
                          fontFamily: 'Alexandria',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Message
                  _InfoCard(
                    children: [
                      Text(
                        'الرسالة',
                        style: TextStyle(
                          fontFamily: 'Alexandria',
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ticket.message,
                        style: TextStyle(
                          fontFamily: 'Alexandria',
                          fontSize: 13.5,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Previous admin reply
                  if (ticket.hasReply) ...[
                    _InfoCard(
                      borderColor: Colors.greenAccent.withValues(alpha: 0.2),
                      bgColor: Colors.greenAccent.withValues(alpha: 0.05),
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.reply_rounded,
                              size: 16,
                              color: Colors.greenAccent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'الرد السابق',
                              style: TextStyle(
                                fontFamily: 'Alexandria',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent,
                              ),
                            ),
                            if (ticket.repliedAt != null) ...[
                              const Spacer(),
                              Text(
                                DateFormat(
                                  'yyyy/MM/dd',
                                  'ar',
                                ).format(ticket.repliedAt!),
                                style: TextStyle(
                                  fontFamily: 'Alexandria',
                                  fontSize: 10,
                                  color: Colors.greenAccent.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ticket.adminReply,
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Reply text field
                  Text(
                    ticket.hasReply ? 'تعديل الرد' : 'كتابة رد',
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _replyCtrl,
                    maxLines: 4,
                    style: const TextStyle(
                      fontFamily: 'Alexandria',
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'اكتب ردك هنا...',
                      hintStyle: TextStyle(
                        fontFamily: 'Alexandria',
                        color: Colors.white.withValues(alpha: 0.3),
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
                  ),

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      // Reply button
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: _isSending ? null : _reply,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: fischerBlue500,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: _isSending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send_rounded, size: 18),
                            label: const Text(
                              'إرسال الرد',
                              style: TextStyle(
                                fontFamily: 'Alexandria',
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Reply & Close button
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: _isSending ? null : _replyAndClose,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.greenAccent.withValues(
                                alpha: 0.15,
                              ),
                              foregroundColor: Colors.greenAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.greenAccent.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.done_all_rounded, size: 18),
                            label: const Text(
                              'رد وإغلاق',
                              style: TextStyle(
                                fontFamily: 'Alexandria',
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Delete button
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: red500,
                        side: BorderSide(color: red500.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.delete_rounded, size: 18),
                      label: const Text(
                        'حذف التذكرة',
                        style: TextStyle(
                          fontFamily: 'Alexandria',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    final items = [
      ('open', 'مفتوح', fischerBlue300),
      ('in_progress', 'قيد المعالجة', Colors.amber),
      ('resolved', 'تم الحل', Colors.greenAccent),
    ];

    return PopupMenuButton<String>(
      onSelected: (status) {
        widget.cubit.updateTicketStatus(widget.ticket.id, status);
        Navigator.pop(context);
      },
      icon: Icon(
        Icons.more_vert_rounded,
        color: Colors.white.withValues(alpha: 0.6),
      ),
      color: fischerBlue900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: fischerBlue300.withValues(alpha: 0.2)),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: Text(
            'تغيير الحالة',
            style: TextStyle(
              fontFamily: 'Alexandria',
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ),
        ...items.map(
          (item) => PopupMenuItem<String>(
            value: item.$1,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: item.$3,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.$2,
                  style: TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 13,
                    color: widget.ticket.status == item.$1
                        ? item.$3
                        : Colors.white,
                    fontWeight: widget.ticket.status == item.$1
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (widget.ticket.status == item.$1) ...[
                  const Spacer(),
                  Icon(Icons.check_rounded, size: 16, color: item.$3),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _reply() async {
    if (_replyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: red700,
          content: Text(
            'الرجاء كتابة الرد أولاً',
            style: TextStyle(fontFamily: 'Alexandria'),
          ),
        ),
      );
      return;
    }
    setState(() => _isSending = true);
    await widget.cubit.replyToTicket(widget.ticket.id, _replyCtrl.text.trim());
    if (mounted) {
      setState(() => _isSending = false);
      Navigator.pop(context);
    }
  }

  Future<void> _replyAndClose() async {
    if (_replyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: red700,
          content: Text(
            'الرجاء كتابة الرد أولاً',
            style: TextStyle(fontFamily: 'Alexandria'),
          ),
        ),
      );
      return;
    }
    setState(() => _isSending = true);
    await widget.cubit.replyAndCloseTicket(
      widget.ticket.id,
      _replyCtrl.text.trim(),
    );
    if (mounted) {
      setState(() => _isSending = false);
      Navigator.pop(context);
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: fischerBlue900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: fischerBlue100.withValues(alpha: 0.15)),
        ),
        title: const Text(
          'حذف التذكرة',
          style: TextStyle(
            fontFamily: 'Alexandria',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف تذكرة "${widget.ticket.subject}"؟',
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
              Navigator.pop(ctx); // close dialog
              Navigator.pop(context); // close detail sheet
              widget.cubit.deleteTicket(widget.ticket.id);
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

// ═══════════════════════════════════════════
// REUSABLE WIDGETS
// ═══════════════════════════════════════════

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  final Color? borderColor;
  final Color? bgColor;

  const _InfoCard({required this.children, this.borderColor, this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: fischerBlue300),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontFamily: 'Alexandria',
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Alexandria',
                fontSize: 13,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
