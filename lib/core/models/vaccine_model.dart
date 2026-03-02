import 'package:cloud_firestore/cloud_firestore.dart';

class VaccineModel {
  final String id;
  final String name;
  final String description;
  final String disease;
  final String ageGroup;
  final String doses;
  final String sideEffects;
  final String manufacturer;
  final String notes;

  const VaccineModel({
    required this.id,
    required this.name,
    required this.description,
    required this.disease,
    required this.ageGroup,
    required this.doses,
    required this.sideEffects,
    required this.manufacturer,
    required this.notes,
  });

  factory VaccineModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VaccineModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      disease: data['disease'] ?? '',
      ageGroup: data['ageGroup'] ?? '',
      doses: data['doses'] ?? '',
      sideEffects: data['sideEffects'] ?? '',
      manufacturer: data['manufacturer'] ?? '',
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'disease': disease,
      'ageGroup': ageGroup,
      'doses': doses,
      'sideEffects': sideEffects,
      'manufacturer': manufacturer,
      'notes': notes,
    };
  }
}
