/// Helper class that determines dose count and intervals for vaccines
/// based on their schedule description text.
class DoseScheduleHelper {
  /// Common dose intervals in days for multi-dose vaccines.
  /// Returns a list of intervals between consecutive doses.
  /// e.g. [60, 60] means dose 2 is 60 days after dose 1, dose 3 is 60 days after dose 2.
  static DoseScheduleInfo getScheduleInfo(String vaccineName, String schedule) {
    final lower = vaccineName.toLowerCase();
    final scheduleLower = schedule.toLowerCase();

    // ── Pentavalent / الخماسي ──
    if (lower.contains('خماسي') || lower.contains('pentavalent')) {
      return const DoseScheduleInfo(
        totalDoses: 3,
        doseIntervalDays: [60, 60], // 2m, 4m, 6m
        doseLabels: ['الجرعة الأولى', 'الجرعة الثانية', 'الجرعة الثالثة'],
      );
    }

    // ── OPV / شلل الأطفال الفموي ──
    if ((lower.contains('شلل') || lower.contains('opv')) &&
        !lower.contains('معطّل') &&
        !lower.contains('ipv')) {
      if (lower.contains('صفرية') ||
          lower.contains('opv0') ||
          lower.contains('ميلاد')) {
        return const DoseScheduleInfo(
          totalDoses: 1,
          doseIntervalDays: [],
          doseLabels: ['جرعة الميلاد'],
        );
      }
      return const DoseScheduleInfo(
        totalDoses: 4,
        doseIntervalDays: [60, 60, 60],
        doseLabels: [
          'الجرعة الأولى',
          'الجرعة الثانية',
          'الجرعة الثالثة',
          'الجرعة الرابعة',
        ],
      );
    }

    // ── Rotavirus / الروتا ──
    if (lower.contains('روتا') || lower.contains('rotavirus')) {
      return const DoseScheduleInfo(
        totalDoses: 2,
        doseIntervalDays: [60],
        doseLabels: ['الجرعة الأولى', 'الجرعة الثانية'],
      );
    }

    // ── MMR / الحصبة والنكاف ──
    if (lower.contains('mmr') ||
        (lower.contains('حصبة') && lower.contains('نكاف'))) {
      return const DoseScheduleInfo(
        totalDoses: 2,
        doseIntervalDays: [180],
        doseLabels: ['الجرعة الأولى', 'الجرعة الثانية'],
      );
    }

    // ── Hepatitis B / التهاب الكبد ب ──
    if (lower.contains('التهاب الكبد ب') ||
        lower.contains('hepb') ||
        lower.contains('hepatitis b')) {
      if (lower.contains('صفرية') || lower.contains('birth')) {
        return const DoseScheduleInfo(
          totalDoses: 1,
          doseIntervalDays: [],
          doseLabels: ['الجرعة الصفرية'],
        );
      }
      return const DoseScheduleInfo(
        totalDoses: 3,
        doseIntervalDays: [30, 150],
        doseLabels: ['الجرعة الأولى', 'الجرعة الثانية', 'الجرعة الثالثة'],
      );
    }

    // ── Hepatitis A / التهاب الكبد أ ──
    if (lower.contains('التهاب الكبد أ') || lower.contains('hepatitis a')) {
      return const DoseScheduleInfo(
        totalDoses: 2,
        doseIntervalDays: [180],
        doseLabels: ['الجرعة الأولى', 'الجرعة الثانية'],
      );
    }

    // ── COVID-19 / كوفيد ──
    if (lower.contains('كوفيد') || lower.contains('covid')) {
      return const DoseScheduleInfo(
        totalDoses: 2,
        doseIntervalDays: [21],
        doseLabels: ['الجرعة الأولى', 'الجرعة الثانية'],
      );
    }

    // ── Influenza / الإنفلونزا ──
    if (lower.contains('إنفلونزا') ||
        lower.contains('influenza') ||
        lower.contains('flu')) {
      return const DoseScheduleInfo(
        totalDoses: 1,
        doseIntervalDays: [],
        doseLabels: ['الجرعة السنوية'],
      );
    }

    // ── BCG ──
    if (lower.contains('بي سي جي') || lower.contains('bcg')) {
      return const DoseScheduleInfo(
        totalDoses: 1,
        doseIntervalDays: [],
        doseLabels: ['جرعة واحدة'],
      );
    }

    // ── Try to parse from schedule text ──
    // Look for Arabic numbers or digits indicating dose count
    final doseCountMatch = RegExp(r'(\d+)\s*جرع').firstMatch(schedule);
    if (doseCountMatch != null) {
      final count = int.tryParse(doseCountMatch.group(1)!) ?? 1;
      if (count > 1) {
        // Default interval: 30 days between doses
        return DoseScheduleInfo(
          totalDoses: count,
          doseIntervalDays: List.filled(count - 1, 30),
          doseLabels: List.generate(
            count,
            (i) => 'الجرعة ${_arabicOrdinal(i + 1)}',
          ),
        );
      }
    }

    // If schedule mentions "جرعة واحدة" or single dose
    if (scheduleLower.contains('جرعة واحدة') ||
        scheduleLower.contains('single')) {
      return const DoseScheduleInfo(
        totalDoses: 1,
        doseIntervalDays: [],
        doseLabels: ['جرعة واحدة'],
      );
    }

    // Default: single dose
    return const DoseScheduleInfo(
      totalDoses: 1,
      doseIntervalDays: [],
      doseLabels: ['جرعة واحدة'],
    );
  }

  static String _arabicOrdinal(int n) {
    switch (n) {
      case 1:
        return 'الأولى';
      case 2:
        return 'الثانية';
      case 3:
        return 'الثالثة';
      case 4:
        return 'الرابعة';
      case 5:
        return 'الخامسة';
      default:
        return '$n';
    }
  }
}

class DoseScheduleInfo {
  final int totalDoses;

  /// Intervals in days between consecutive doses. Length = totalDoses - 1
  final List<int> doseIntervalDays;
  final List<String> doseLabels;

  const DoseScheduleInfo({
    required this.totalDoses,
    required this.doseIntervalDays,
    required this.doseLabels,
  });

  /// Given dose number (1-based) and the date it was taken,
  /// returns the recommended date for the next dose, or null if no more doses.
  DateTime? getNextDoseDate(int currentDose, DateTime currentDoseDate) {
    if (currentDose >= totalDoses) return null;
    final intervalIndex = currentDose - 1;
    if (intervalIndex < 0 || intervalIndex >= doseIntervalDays.length) {
      return null;
    }
    return currentDoseDate.add(Duration(days: doseIntervalDays[intervalIndex]));
  }

  /// Get label for a specific dose (1-based).
  String getDoseLabel(int doseNumber) {
    if (doseNumber < 1 || doseNumber > doseLabels.length) {
      return 'جرعة $doseNumber';
    }
    return doseLabels[doseNumber - 1];
  }
}
