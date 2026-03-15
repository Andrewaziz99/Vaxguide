import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// A Firestore-backed vaccine category with dynamic subcategories.
class VaccineCategoryModel {
  final String key; // document ID (e.g. 'preschool', 'school', 'travel', ...)
  final String label; // Arabic display name
  final String icon; // Material icon name string
  final List<String> subcategories;

  const VaccineCategoryModel({
    required this.key,
    required this.label,
    this.icon = 'vaccines_rounded',
    this.subcategories = const [],
  });

  factory VaccineCategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VaccineCategoryModel(
      key: doc.id,
      label: data['label'] ?? '',
      icon: data['icon'] ?? 'vaccines_rounded',
      subcategories: List<String>.from(data['subcategories'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {'label': label, 'icon': icon, 'subcategories': subcategories};
  }

  VaccineCategoryModel copyWith({
    String? key,
    String? label,
    String? icon,
    List<String>? subcategories,
  }) {
    return VaccineCategoryModel(
      key: key ?? this.key,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      subcategories: subcategories ?? this.subcategories,
    );
  }

  /// Whether this category uses country-based travel search instead of subcategory dropdown.
  bool get isTravel => key == 'travel';

  /// Resolve the icon name string to an actual [IconData].
  IconData get iconData => _iconMap[icon] ?? Icons.vaccines_rounded;

  static const Map<String, IconData> _iconMap = {
    'child_care_rounded': Icons.child_care_rounded,
    'school_rounded': Icons.school_rounded,
    'flight_rounded': Icons.flight_rounded,
    'add_circle_outline_rounded': Icons.add_circle_outline_rounded,
    'vaccines_rounded': Icons.vaccines_rounded,
    'local_hospital_rounded': Icons.local_hospital_rounded,
    'health_and_safety_rounded': Icons.health_and_safety_rounded,
    'elderly_rounded': Icons.elderly_rounded,
    'pregnant_woman_rounded': Icons.pregnant_woman_rounded,
    'work_rounded': Icons.work_rounded,
    'pets_rounded': Icons.pets_rounded,
    'science_rounded': Icons.science_rounded,
    'medical_services_rounded': Icons.medical_services_rounded,
    'medication_rounded': Icons.medication_rounded,
    'bloodtype_rounded': Icons.bloodtype_rounded,
    'favorite_rounded': Icons.favorite_rounded,
    'shield_rounded': Icons.shield_rounded,
    'local_pharmacy_rounded': Icons.local_pharmacy_rounded,
    'baby_changing_station_rounded': Icons.baby_changing_station_rounded,
    'family_restroom_rounded': Icons.family_restroom_rounded,
  };

  /// All available icon options for the admin form picker.
  static List<String> get availableIcons => _iconMap.keys.toList();

  /// Resolve any icon name to IconData.
  static IconData resolveIcon(String name) =>
      _iconMap[name] ?? Icons.vaccines_rounded;
}
