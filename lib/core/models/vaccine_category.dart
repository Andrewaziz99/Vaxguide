import 'package:flutter/material.dart';

enum VaccineCategory {
  preschool(
    key: 'preschool',
    label: 'تطعيمات ما قبل سن المدارس',
    icon: Icons.child_care_rounded,
    subcategories: [
      'عند الميلاد',
      'اول شهر',
      'شهرين',
      '٤ شهور',
      '٦ شهور',
      '٩ شهور',
      '١٢ شهر',
      '١٨ شهر',
    ],
  ),
  school(
    key: 'school',
    label: 'التطعيمات خلال سن المدارس',
    icon: Icons.school_rounded,
    subcategories: [
      'اولى حضانة - ٤ سنوات',
      'اولى ابتدائي - ٦ سنوات',
      'تانية ابتدائي - ٧ سنوات',
      'رابعة ابتدائي - ١٠ سنوات',
      'اولى اعدادى - ١٢ سنة',
      'اولى ثانوي - ١٥ سنة',
    ],
  ),
  travel(
    key: 'travel',
    label: 'تطعيمات السفر',
    icon: Icons.flight_rounded,
    subcategories: [], // searched by country name
  ),
  additional(
    key: 'additional',
    label: 'تطعيمات إضافية',
    icon: Icons.add_circle_outline_rounded,
    subcategories: [], // loaded dynamically from Firestore
  );

  final String key;
  final String label;
  final IconData icon;
  final List<String> subcategories;

  const VaccineCategory({
    required this.key,
    required this.label,
    required this.icon,
    required this.subcategories,
  });

  static VaccineCategory? fromKey(String key) {
    for (final cat in values) {
      if (cat.key == key) return cat;
    }
    return null;
  }
}
