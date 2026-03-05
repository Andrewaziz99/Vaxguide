import 'package:cloud_firestore/cloud_firestore.dart';

class VaccineHistoryEntry {
  final String vaccineId;
  final String vaccineName;
  final DateTime dateAdministered;
  final String dose;
  final String notes;

  const VaccineHistoryEntry({
    required this.vaccineId,
    required this.vaccineName,
    required this.dateAdministered,
    required this.dose,
    this.notes = '',
  });

  factory VaccineHistoryEntry.fromMap(Map<String, dynamic> map) {
    return VaccineHistoryEntry(
      vaccineId: map['vaccineId'] ?? '',
      vaccineName: map['vaccineName'] ?? '',
      dateAdministered:
          (map['dateAdministered'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dose: map['dose'] ?? '',
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vaccineId': vaccineId,
      'vaccineName': vaccineName,
      'dateAdministered': Timestamp.fromDate(dateAdministered),
      'dose': dose,
      'notes': notes,
    };
  }
}

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final String userType; // 'user' or 'admin'
  final bool firstLogin;
  final DateTime? createdAt;
  final List<VaccineHistoryEntry> vaccineHistory;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    this.userType = 'user',
    this.firstLogin = true,
    this.createdAt,
    this.vaccineHistory = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final historyList =
        (data['vaccineHistory'] as List<dynamic>?)
            ?.map((e) => VaccineHistoryEntry.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];

    return UserModel(
      uid: data['uid'] ?? doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      gender: data['gender'] ?? '',
      userType: data['userType'] ?? 'user',
      firstLogin: data['firstLogin'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      vaccineHistory: historyList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'gender': gender,
      'userType': userType,
      'firstLogin': firstLogin,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'vaccineHistory': vaccineHistory.map((e) => e.toMap()).toList(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phone,
    String? gender,
    String? userType,
    bool? firstLogin,
    DateTime? createdAt,
    List<VaccineHistoryEntry>? vaccineHistory,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      userType: userType ?? this.userType,
      firstLogin: firstLogin ?? this.firstLogin,
      createdAt: createdAt ?? this.createdAt,
      vaccineHistory: vaccineHistory ?? this.vaccineHistory,
    );
  }

  bool get isAdmin => userType == 'admin';
}
