import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vaxguide/core/constants/strings.dart';
import 'package:vaxguide/core/models/vaccine_model.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/core/styles/themeScaffold.dart';
import 'package:vaxguide/modules/VaccineSearch/record_dose_sheet.dart';

class VaccineDetailScreen extends StatelessWidget {
  final VaccineModel vaccine;

  const VaccineDetailScreen({super.key, required this.vaccine});

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: AppBar(
        title: Text(
          vaccine.name,
          style: const TextStyle(
            fontFamily: 'Alexandria',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onPressed: () => showRecordDoseSheet(context, vaccine),
        backgroundColor: fischerBlue500,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'سجّل جرعة',
          style: TextStyle(
            fontFamily: 'Alexandria',
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Vaccine icon header
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: fischerBlue100.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.vaccines_rounded,
                size: 40,
                color: fischerBlue100,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              vaccine.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Alexandria',
              ),
            ),
            const SizedBox(height: 24),

            // Detail sections
            if (vaccine.importance.isNotEmpty)
              _DetailCard(
                icon: Icons.shield_rounded,
                title: vaccineDetailImportance,
                content: vaccine.importance,
              ),
            if (vaccine.schedule.isNotEmpty)
              _DetailCard(
                icon: Icons.calendar_month_rounded,
                title: vaccineDetailSchedule,
                content: vaccine.schedule,
              ),
            if (vaccine.administrationMethod.isNotEmpty)
              _DetailCard(
                icon: Icons.medical_services_rounded,
                title: vaccineDetailAdministration,
                content: vaccine.administrationMethod,
              ),
            if (vaccine.sideEffects.isNotEmpty)
              _DetailCard(
                icon: Icons.warning_amber_rounded,
                title: vaccineDetailSideEffects,
                content: vaccine.sideEffects,
              ),
            if (vaccine.locations.isNotEmpty)
              _DetailCard(
                icon: Icons.location_on_rounded,
                title: vaccineDetailLocations,
                content: vaccine.locations,
              ),
            if (vaccine.precautions.isNotEmpty)
              _DetailCard(
                icon: Icons.checklist_rounded,
                title: vaccineDetailPrecautions,
                content: vaccine.precautions,
              ),
            if (vaccine.warnings.isNotEmpty)
              _DetailCard(
                icon: Icons.do_not_disturb_alt_rounded,
                title: vaccineDetailWarnings,
                content: vaccine.warnings,
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: fischerBlue100, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: fischerBlue100,
                          fontFamily: 'Alexandria',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontFamily: 'Alexandria',
                    height: 1.6,
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
