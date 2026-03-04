import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaxguide/core/models/vaccine_alert_model.dart';
import 'package:vaxguide/core/styles/colors.dart';

class VaccineAlertBanner extends StatelessWidget {
  final VaccineAlertModel alert;
  final VoidCallback onDismiss;

  const VaccineAlertBanner({
    super.key,
    required this.alert,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _severityColors(alert.severity);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.$1, colors.$2],
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colors.$1.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showAlertDetails(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _severityIcon(alert.severity),
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: const TextStyle(
                          fontFamily: 'Alexandria',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.message,
                        style: TextStyle(
                          fontFamily: 'Alexandria',
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (alert.vaccineName.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '💉 ${alert.vaccineName}',
                            style: const TextStyle(
                              fontFamily: 'Alexandria',
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Dismiss button
                GestureDetector(
                  onTap: onDismiss,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4, top: 2),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 20,
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

  // ── Alert Detail Popup ──
  void _showAlertDetails(BuildContext context) {
    final colors = _severityColors(alert.severity);
    final dateStr = DateFormat(
      'yyyy/MM/dd – HH:mm',
      'ar',
    ).format(alert.createdAt);

    String severityLabel;
    switch (alert.severity) {
      case 'high':
        severityLabel = 'عالية';
        break;
      case 'medium':
        severityLabel = 'متوسطة';
        break;
      default:
        severityLabel = 'معلوماتي';
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: fischerBlue900,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.$1.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.$1.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.$1, colors.$2],
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _severityIcon(alert.severity),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      alert.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Alexandria',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ──
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message
                      Text(
                        alert.message,
                        style: TextStyle(
                          fontFamily: 'Alexandria',
                          fontSize: 13.5,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Meta info chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Severity chip
                          _InfoChip(
                            icon: _severityIcon(alert.severity),
                            label: 'الخطورة: $severityLabel',
                            color: colors.$1,
                          ),
                          // Vaccine name chip
                          if (alert.vaccineName.isNotEmpty)
                            _InfoChip(
                              icon: Icons.vaccines_rounded,
                              label: alert.vaccineName,
                              color: fischerBlue500,
                            ),
                          // Date chip
                          _InfoChip(
                            icon: Icons.access_time_rounded,
                            label: dateStr,
                            color: fischerBlue700,
                          ),
                          // Expiry chip
                          if (alert.expiresAt != null)
                            _InfoChip(
                              icon: Icons.event_rounded,
                              label:
                                  'ينتهي: ${DateFormat('yyyy/MM/dd', 'ar').format(alert.expiresAt!)}',
                              color: Colors.orange.shade700,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Close Button ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.$1.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: colors.$1.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    child: const Text(
                      'إغلاق',
                      style: TextStyle(
                        fontFamily: 'Alexandria',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (Color, Color) _severityColors(String severity) {
    switch (severity) {
      case 'high':
        return (red700, red500);
      case 'medium':
        return (Colors.orange.shade700, Colors.orange.shade500);
      case 'info':
      default:
        return (fischerBlue700, fischerBlue500);
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity) {
      case 'high':
        return Icons.warning_amber_rounded;
      case 'medium':
        return Icons.info_outline_rounded;
      case 'info':
      default:
        return Icons.campaign_rounded;
    }
  }
}

// ── Small info chip used in the alert detail dialog ──
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Alexandria',
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
