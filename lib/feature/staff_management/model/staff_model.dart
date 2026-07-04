import 'package:cloud_firestore/cloud_firestore.dart';

class StaffModel {
  final String? id;
  final String name;
  final String password;
  final String phone;
  final String? email;
  final String? designationId;
  final String? designation;
  final String? staffType;
  final String? joiningDate;
  final String? salary;
  final String? openingBalance;
  final String? openingBalanceDate;
  final String status;
  final bool accessWhatsapp;
  final bool accessCallLog;
  final bool hasSalaryAccount;
  final bool hasPettyCash;
  final String? imageUrl;
  final String? documentName;
  final String? documentUrl;
  final String? accessibleUsers;
  final DateTime? createdAt;
  final DateTime? deletedAt;
  final String? companyType;
  final String? companyId;
  final String? companyStatus;

  const StaffModel({
    this.id,
    required this.name,
    required this.password,
    required this.phone,
    this.email,
    this.designationId,
    this.designation,
    this.staffType,
    this.joiningDate,
    this.salary,
    this.openingBalance,
    this.openingBalanceDate,
    this.status = 'Active',
    this.accessWhatsapp = false,
    this.accessCallLog = false,
    this.hasSalaryAccount = true,
    this.hasPettyCash = false,
    this.imageUrl,
    this.documentName,
    this.documentUrl,
    this.accessibleUsers,
    this.createdAt,
    this.deletedAt,
    this.companyType,
    this.companyId,
    this.companyStatus,
  });

  // ─── copyWith ────────────────────────────────────────────────────────────

  StaffModel copyWith({
    String? id,
    String? name,
    String? password,
    String? phone,
    String? email,
    String? designationId,
    String? designation,
    String? staffType,
    String? joiningDate,
    String? salary,
    String? openingBalance,
    String? openingBalanceDate,
    String? status,
    bool? accessWhatsapp,
    bool? accessCallLog,
    bool? hasSalaryAccount,
    bool? hasPettyCash,
    String? imageUrl,
    String? documentName,
    String? documentUrl,
    String? accessibleUsers,
    DateTime? createdAt,
    DateTime? deletedAt,
    String? companyType,
    String? companyId,
    String? companyStatus,
  }) {
    return StaffModel(
      id: id ?? this.id,
      name: name ?? this.name,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      designationId: designationId ?? this.designationId,
      designation: designation ?? this.designation,
      staffType: staffType ?? this.staffType,
      joiningDate: joiningDate ?? this.joiningDate,
      salary: salary ?? this.salary,
      openingBalance: openingBalance ?? this.openingBalance,
      openingBalanceDate: openingBalanceDate ?? this.openingBalanceDate,
      status: status ?? this.status,
      accessWhatsapp: accessWhatsapp ?? this.accessWhatsapp,
      accessCallLog: accessCallLog ?? this.accessCallLog,
      hasSalaryAccount: hasSalaryAccount ?? this.hasSalaryAccount,
      hasPettyCash: hasPettyCash ?? this.hasPettyCash,
      imageUrl: imageUrl ?? this.imageUrl,
      documentName: documentName ?? this.documentName,
      documentUrl: documentUrl ?? this.documentUrl,
      accessibleUsers: accessibleUsers ?? this.accessibleUsers,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      companyType: companyType ?? this.companyType,
      companyId: companyId ?? this.companyId,
      companyStatus: companyStatus ?? this.companyStatus,
    );
  }

  // ─── Firestore ────────────────────────────────────────────────────────────

  factory StaffModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data()!;
    final isUsersCollection = doc.reference.parent.path == 'USERS';
    final companyIdVal = map['companyId'] as String?;
    final resolvedId = (isUsersCollection && companyIdVal != null && companyIdVal.isNotEmpty)
        ? "admin-$companyIdVal"
        : doc.id;
    return StaffModel(
      id: resolvedId,
      name: map['name'] ?? '',
      password: map['password'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      designationId: map['designationId'],
      designation: map['designation'],
      staffType: map['staffType'] ??
          map['role'] ??
          (isUsersCollection ? 'Admin' : null),
      joiningDate: map['joiningDate'],
      salary: map['salary'],
      openingBalance: map['openingBalance'],
      openingBalanceDate: map['openingBalanceDate'],
      status: map['status'] as String? ?? 'Active',
      accessWhatsapp: map['accessWhatsapp'] ?? false,
      accessCallLog: map['accessCallLog'] ?? false,
      hasSalaryAccount: map['hasSalaryAccount'] ?? true,
      hasPettyCash: map['hasPettyCash'] ?? false,
      imageUrl: map['imageUrl'],
      documentName: map['documentName'],
      documentUrl: map['documentUrl'],
      accessibleUsers: map['accessibleUsers'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      deletedAt: (map['deletedAt'] as Timestamp?)?.toDate(),
      companyType: map['companyType'] ?? '',
      companyId:
          map['companyId'] ??
          (() {
            final segments = doc.reference.path.split('/');
            if (segments.length >= 2 && segments[0] == 'COMPANY') {
              return segments[1];
            }
            return null;
          }()),
      companyStatus: map['companyStatus'] ?? 'PENDING',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'password': password,
      'phone': phone,
      'email': email,
      'designationId': designationId,
      'designation': designation,
      'staffType': staffType,
      'joiningDate': joiningDate,
      'salary': salary,
      'openingBalance': openingBalance,
      'openingBalanceDate': openingBalanceDate,
      'status': status,
      'accessWhatsapp': accessWhatsapp,
      'accessCallLog': accessCallLog,
      'hasSalaryAccount': hasSalaryAccount,
      'hasPettyCash': hasPettyCash,
      'imageUrl': imageUrl,
      'documentName': documentName,
      'documentUrl': documentUrl,
      'accessibleUsers': accessibleUsers,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
      'companyType': companyType,
      'companyId': companyId,
      'companyStatus': companyStatus,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'password': password,
      'phone': phone,
      'email': email,
      'designationId': designationId,
      'designation': designation,
      'staffType': staffType,
      'joiningDate': joiningDate,
      'salary': salary,
      'openingBalance': openingBalance,
      'openingBalanceDate': openingBalanceDate,
      'status': status,
      'accessWhatsapp': accessWhatsapp,
      'accessCallLog': accessCallLog,
      'hasSalaryAccount': hasSalaryAccount,
      'hasPettyCash': hasPettyCash,
      'imageUrl': imageUrl,
      'documentName': documentName,
      'documentUrl': documentUrl,
      'accessibleUsers': accessibleUsers,
      'createdAt': createdAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'companyType': companyType,
      'companyId': companyId,
      'companyStatus': companyStatus,
    };
  }

  factory StaffModel.fromJson(Map<String, dynamic> map) {
    return StaffModel(
      id: map['id'],
      name: map['name'] ?? '',
      password: map['password'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      designationId: map['designationId'],
      designation: map['designation'],
      staffType: map['staffType'],
      joiningDate: map['joiningDate'],
      salary: map['salary'],
      openingBalance: map['openingBalance'],
      openingBalanceDate: map['openingBalanceDate'],
      status: map['status'] as String? ?? 'Active',
      accessWhatsapp: map['accessWhatsapp'] ?? false,
      accessCallLog: map['accessCallLog'] ?? false,
      hasSalaryAccount: map['hasSalaryAccount'] ?? true,
      hasPettyCash: map['hasPettyCash'] ?? false,
      imageUrl: map['imageUrl'],
      documentName: map['documentName'],
      documentUrl: map['documentUrl'],
      accessibleUsers: map['accessibleUsers'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'])
          : null,
      deletedAt: map['deletedAt'] != null
          ? DateTime.tryParse(map['deletedAt'])
          : null,
      companyType: map['companyType'] ?? '',
      companyId: map['companyId'],
      companyStatus: map['companyStatus'] ?? 'PENDING',
    );
  }
}
