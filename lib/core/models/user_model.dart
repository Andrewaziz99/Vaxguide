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
  final String username;
  final String email;
  final String phone;
  final String address;
  final String gender;
  final String userType; // 'user' or 'admin'
  final DateTime? createdAt;
  final List<VaccineHistoryEntry> vaccineHistory;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phone,
    required this.address,
    required this.gender,
    this.userType = 'user',
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
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      gender: data['gender'] ?? '',
      userType: data['userType'] ?? 'user',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      vaccineHistory: historyList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'username': username,
      'email': email,
      'phone': phone,
      'address': address,
      'gender': gender,
      'userType': userType,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'vaccineHistory': vaccineHistory.map((e) => e.toMap()).toList(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? username,
    String? email,
    String? phone,
    String? address,
    String? gender,
    String? userType,
    DateTime? createdAt,
    List<VaccineHistoryEntry>? vaccineHistory,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      vaccineHistory: vaccineHistory ?? this.vaccineHistory,
    );
  }

  bool get isAdmin => userType == 'admin';
}
