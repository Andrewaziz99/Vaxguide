import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaxguide/core/constants/strings.dart';
import 'package:vaxguide/core/models/user_model.dart';
import 'package:vaxguide/core/repositories/user_repo.dart';
import 'package:vaxguide/core/styles/colors.dart';

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
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          physics: const BouncingScrollPhysics(),
          itemCount: history.length,
          itemBuilder: (context, index) {
            return _HistoryCard(entry: history[index]);
          },
        );
      },
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
