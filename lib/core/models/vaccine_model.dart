import 'package:cloud_firestore/cloud_firestore.dart';

class VaccineModel {
  final String id;
  final String name;
  final String category; // 'preschool', 'school', 'travel', 'additional'
  final String subcategory; // age/grade label or condition
  final String importance; // أهمية التطعيم والأمراض التي يقي منها
  final String schedule; // الجدول الزمني وعدد الجرعات ومدة فعاليته
  final String administrationMethod; // طريقة الإعطاء
  final String sideEffects; // الآثار الجانبية والأدوية اللازمة لها
  final String locations; // أماكن تلقي التطعيم
  final String precautions; // الاحتياطات اللازمة قبل أو بعد تلقي التطعيم
  final String warnings; // متى يجب تجنبه أو نصائح أو تحذيرات
  final List<String> countries; // for travel vaccines

  const VaccineModel({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    this.importance = '',
    this.schedule = '',
    this.administrationMethod = '',
    this.sideEffects = '',
    this.locations = '',
    this.precautions = '',
    this.warnings = '',
    this.countries = const [],
  });

  factory VaccineModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VaccineModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      subcategory: data['subcategory'] ?? '',
      importance: data['importance'] ?? '',
      schedule: data['schedule'] ?? '',
      administrationMethod: data['administrationMethod'] ?? '',
      sideEffects: data['sideEffects'] ?? '',
      locations: data['locations'] ?? '',
      precautions: data['precautions'] ?? '',
      warnings: data['warnings'] ?? '',
      countries: List<String>.from(data['countries'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'subcategory': subcategory,
      'importance': importance,
      'schedule': schedule,
      'administrationMethod': administrationMethod,
      'sideEffects': sideEffects,
      'locations': locations,
      'precautions': precautions,
      'warnings': warnings,
      'countries': countries,
    };
  }
}
