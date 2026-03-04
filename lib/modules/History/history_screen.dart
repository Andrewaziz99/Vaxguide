import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaxguide/core/constants/strings.dart';
import 'package:vaxguide/core/models/user_model.dart';
import 'package:vaxguide/core/repositories/user_repo.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/core/utils/dose_schedule_helper.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final userRepo = UserRepo();

    if (uid == null) {
      return const Center(
        child: Text(
          profileNotFound,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontFamily: 'Alexandria',
          ),
        ),
      );
    }

    return StreamBuilder<UserModel?>(
      stream: userRepo.streamUser(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: fischerBlue100),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              profileLoadError,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontFamily: 'Alexandria',
              ),
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const Center(
            child: Text(
              profileNotFound,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontFamily: 'Alexandria',
              ),
            ),
          );
        }

        final history = user.vaccineHistory.reversed.toList();

        if (history.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.vaccines_outlined,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
                const SizedBox(height: 16),
                Text(
                  profileNoVaccineHistory,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 16,
                    fontFamily: 'Alexandria',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ابحث عن تطعيم وسجّل جرعتك الأولى',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 13,
                    fontFamily: 'Alexandria',
                  ),
                ),
              ],
            ),
          );
        }

        // Calculate upcoming doses
        final upcomingDoses = _calculateUpcomingDoses(history);

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Upcoming dose reminders ──
            if (upcomingDoses.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'الجرعات القادمة',
                        style: TextStyle(
                          fontFamily: 'Alexandria',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final upcoming = upcomingDoses[index];
                  return _UpcomingDoseCard(info: upcoming);
                }, childCount: upcomingDoses.length),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Divider(
                    color: fischerBlue100.withValues(alpha: 0.15),
                    thickness: 1,
                  ),
                ),
              ),
            ],

            // ── History header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      color: fischerBlue100,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'سجل التطعيمات',
                      style: TextStyle(
                        fontFamily: 'Alexandria',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: fischerBlue100,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${history.length} جرعة',
                      style: TextStyle(
                        fontFamily: 'Alexandria',
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── History list ──
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _HistoryCard(entry: history[index]),
                );
              }, childCount: history.length),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        );
      },
    );
  }

  /// Analyze history entries to find vaccines with pending next doses.
  List<_UpcomingDoseInfo> _calculateUpcomingDoses(
    List<VaccineHistoryEntry> history,
  ) {
    // Group entries by vaccineId
    final Map<String, List<VaccineHistoryEntry>> grouped = {};
    for (final entry in history) {
      grouped.putIfAbsent(entry.vaccineId, () => []).add(entry);
    }

    final List<_UpcomingDoseInfo> upcoming = [];

    for (final entry in grouped.entries) {
      final vaccineId = entry.key;
      final entries = entry.value;
      if (entries.isEmpty) continue;

      // Sort by date ascending
      entries.sort((a, b) => a.dateAdministered.compareTo(b.dateAdministered));
      final latest = entries.last;

      final scheduleInfo = DoseScheduleHelper.getScheduleInfo(
        latest.vaccineName,
        '', // We don't have the schedule text here, but the helper works with name
      );

      final dosesTaken = entries.length;
      if (dosesTaken >= scheduleInfo.totalDoses) continue;

      final nextDoseDate = scheduleInfo.getNextDoseDate(
        dosesTaken,
        latest.dateAdministered,
      );
      if (nextDoseDate == null) continue;

      upcoming.add(
        _UpcomingDoseInfo(
          vaccineId: vaccineId,
          vaccineName: latest.vaccineName,
          nextDoseNumber: dosesTaken + 1,
          nextDoseLabel: scheduleInfo.getDoseLabel(dosesTaken + 1),
          scheduledDate: nextDoseDate,
          totalDoses: scheduleInfo.totalDoses,
          dosesTaken: dosesTaken,
        ),
      );
    }

    // Sort by nearest date first
    upcoming.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    return upcoming;
  }
}

// ── Data class for upcoming doses ──
class _UpcomingDoseInfo {
  final String vaccineId;
  final String vaccineName;
  final int nextDoseNumber;
  final String nextDoseLabel;
  final DateTime scheduledDate;
  final int totalDoses;
  final int dosesTaken;

  const _UpcomingDoseInfo({
    required this.vaccineId,
    required this.vaccineName,
    required this.nextDoseNumber,
    required this.nextDoseLabel,
    required this.scheduledDate,
    required this.totalDoses,
    required this.dosesTaken,
  });
}

// ── Upcoming Dose Card ──
class _UpcomingDoseCard extends StatelessWidget {
  final _UpcomingDoseInfo info;
  const _UpcomingDoseCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy/MM/dd', 'ar').format(info.scheduledDate);
    final now = DateTime.now();
    final daysLeft = info.scheduledDate.difference(now).inDays;
    final isOverdue = daysLeft < 0;
    final isToday = daysLeft == 0;

    Color statusColor;
    String statusText;
    if (isOverdue) {
      statusColor = red500;
      statusText = 'متأخر بـ ${-daysLeft} يوم';
    } else if (isToday) {
      statusColor = Colors.amber;
      statusText = 'اليوم!';
    } else if (daysLeft <= 7) {
      statusColor = Colors.amber;
      statusText = 'بعد $daysLeft أيام';
    } else {
      statusColor = fischerBlue300;
      statusText = 'بعد $daysLeft يوم';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor.withValues(alpha: 0.12),
                  statusColor.withValues(alpha: 0.05),
                ],
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: statusColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isOverdue
                        ? Icons.warning_amber_rounded
                        : Icons.notifications_active_rounded,
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.vaccineName,
                        style: const TextStyle(
                          fontFamily: 'Alexandria',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            info.nextDoseLabel,
                            style: TextStyle(
                              fontFamily: 'Alexandria',
                              fontSize: 11,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• $dateStr',
                            style: TextStyle(
                              fontFamily: 'Alexandria',
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
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

class _HistoryCard extends StatelessWidget {
  final VaccineHistoryEntry entry;

  const _HistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                // Vaccine icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: fischerBlue100.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.vaccines_rounded,
                    color: fischerBlue100,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.vaccineName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Alexandria',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Dose
                          Icon(
                            Icons.format_list_numbered_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$profileDose: ${entry.dose}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                              fontFamily: 'Alexandria',
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Date
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat(
                              'yyyy/MM/dd',
                            ).format(entry.dateAdministered),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                              fontFamily: 'Alexandria',
                            ),
                          ),
                        ],
                      ),
                      if (entry.notes.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.notes_rounded,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                entry.notes,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 11,
                                  fontFamily: 'Alexandria',
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
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
