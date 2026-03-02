import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vaxguide/core/constants/strings.dart';
import 'package:vaxguide/core/models/vaccine_model.dart';
import 'package:vaxguide/core/styles/colors.dart';
import 'package:vaxguide/core/styles/themeScaffold.dart';

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

            // Detail cards
            if (vaccine.description.isNotEmpty)
              _DetailCard(
                icon: Icons.info_outline_rounded,
                title: vaccineDescription,
                content: vaccine.description,
              ),
            if (vaccine.disease.isNotEmpty)
              _DetailCard(
                icon: Icons.coronavirus_rounded,
                title: vaccineDisease,
                content: vaccine.disease,
              ),
            if (vaccine.ageGroup.isNotEmpty)
              _DetailCard(
                icon: Icons.child_care_rounded,
                title: vaccineAgeGroup,
                content: vaccine.ageGroup,
              ),
            if (vaccine.doses.isNotEmpty)
              _DetailCard(
                icon: Icons.format_list_numbered_rounded,
                title: vaccineDoses,
                content: vaccine.doses,
              ),
            if (vaccine.sideEffects.isNotEmpty)
              _DetailCard(
                icon: Icons.warning_amber_rounded,
                title: vaccineSideEffects,
                content: vaccine.sideEffects,
              ),
            if (vaccine.manufacturer.isNotEmpty)
              _DetailCard(
                icon: Icons.factory_rounded,
                title: vaccineManufacturer,
                content: vaccine.manufacturer,
              ),
            if (vaccine.notes.isNotEmpty)
              _DetailCard(
                icon: Icons.notes_rounded,
                title: vaccineNotes,
                content: vaccine.notes,
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
