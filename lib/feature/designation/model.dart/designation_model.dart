import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────
// Permission Model (per menu item)
// ─────────────────────────────────────────────

class Permission {
  final bool create;
  final bool view;
  final bool edit;
  final bool delete;
  final bool other;

  const Permission({
    this.create = false,
    this.view = false,
    this.edit = false,
    this.delete = false,
    this.other = false,
  });

  factory Permission.fromMap(Map<String, dynamic> map) {
    return Permission(
      create: map['create'] ?? false,
      view: map['view'] ?? false,
      edit: map['edit'] ?? false,
      delete: map['delete'] ?? false,
      other: map['other'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'create': create,
        'view': view,
        'edit': edit,
        'delete': delete,
        'other': other,
      };

  Permission copyWith({
    bool? create,
    bool? view,
    bool? edit,
    bool? delete,
    bool? other,
  }) {
    return Permission(
      create: create ?? this.create,
      view: view ?? this.view,
      edit: edit ?? this.edit,
      delete: delete ?? this.delete,
      other: other ?? this.other,
    );
  }
}

// ─────────────────────────────────────────────
// Staff Management Permissions
// ─────────────────────────────────────────────

class StaffManagementPermissions {
  final Permission addStaff;
  final Permission viewStaff;
  final Permission designation;
  final Permission deletedStaff;

  const StaffManagementPermissions({
    this.addStaff = const Permission(),
    this.viewStaff = const Permission(),
    this.designation = const Permission(),
    this.deletedStaff = const Permission(),
  });

  factory StaffManagementPermissions.fromMap(Map<String, dynamic> map) {
    return StaffManagementPermissions(
      addStaff: Permission.fromMap(map['addStaff'] ?? {}),
      viewStaff: Permission.fromMap(map['viewStaff'] ?? {}),
      designation: Permission.fromMap(map['designation'] ?? {}),
      deletedStaff: Permission.fromMap(map['deletedStaff'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
        'addStaff': addStaff.toMap(),
        'viewStaff': viewStaff.toMap(),
        'designation': designation.toMap(),
        'deletedStaff': deletedStaff.toMap(),
      };
}

// ─────────────────────────────────────────────
// Lead Management Permissions
// ─────────────────────────────────────────────

class LeadManagementPermissions {
  final Permission dashboard;
  final Permission addLead;
  final Permission leadCategory;
  final Permission importLeads;
  final Permission callSettings;
  final Permission callHistory;
  final Permission deletedLeads;
  final Permission unassignedLeads;
  final Permission transferLeads;
  final Permission customFieldSettings;
  final Permission leadsReport;
  final Permission fileManager;
  final Permission phoneCallLog;
  final Permission leadSource;
  final Permission leadStages;

  const LeadManagementPermissions({
    this.dashboard = const Permission(),
    this.addLead = const Permission(),
    this.leadCategory = const Permission(),
    this.importLeads = const Permission(),
    this.callSettings = const Permission(),
    this.callHistory = const Permission(),
    this.deletedLeads = const Permission(),
    this.unassignedLeads = const Permission(),
    this.transferLeads = const Permission(),
    this.customFieldSettings = const Permission(),
    this.leadsReport = const Permission(),
    this.fileManager = const Permission(),
    this.phoneCallLog = const Permission(),
    this.leadSource = const Permission(),
    this.leadStages = const Permission(),
  });

  factory LeadManagementPermissions.fromMap(Map<String, dynamic> map) {
    return LeadManagementPermissions(
      dashboard: Permission.fromMap(map['dashboard'] ?? {}),
      addLead: Permission.fromMap(map['addLead'] ?? {}),
      leadCategory: Permission.fromMap(map['leadCategory'] ?? {}),
      importLeads: Permission.fromMap(map['importLeads'] ?? {}),
      callSettings: Permission.fromMap(map['callSettings'] ?? {}),
      callHistory: Permission.fromMap(map['callHistory'] ?? {}),
      deletedLeads: Permission.fromMap(map['deletedLeads'] ?? {}),
      unassignedLeads: Permission.fromMap(map['unassignedLeads'] ?? {}),
      transferLeads: Permission.fromMap(map['transferLeads'] ?? {}),
      customFieldSettings: Permission.fromMap(map['customFieldSettings'] ?? {}),
      leadsReport: Permission.fromMap(map['leadsReport'] ?? {}),
      fileManager: Permission.fromMap(map['fileManager'] ?? {}),
      phoneCallLog: Permission.fromMap(map['phoneCallLog'] ?? {}),
      leadSource: Permission.fromMap(map['leadSource'] ?? {}),
      leadStages: Permission.fromMap(map['leadStages'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
        'dashboard': dashboard.toMap(),
        'addLead': addLead.toMap(),
        'leadCategory': leadCategory.toMap(),
        'importLeads': importLeads.toMap(),
        'callSettings': callSettings.toMap(),
        'callHistory': callHistory.toMap(),
        'deletedLeads': deletedLeads.toMap(),
        'unassignedLeads': unassignedLeads.toMap(),
        'transferLeads': transferLeads.toMap(),
        'customFieldSettings': customFieldSettings.toMap(),
        'leadsReport': leadsReport.toMap(),
        'fileManager': fileManager.toMap(),
        'phoneCallLog': phoneCallLog.toMap(),
        'leadSource': leadSource.toMap(),
        'leadStages': leadStages.toMap(),
      };
}

// ─────────────────────────────────────────────
// Settings Permissions
// ─────────────────────────────────────────────

class SettingsPermissions {
  final Permission facebookSettings;
  final Permission generalSettings;

  const SettingsPermissions({
    this.facebookSettings = const Permission(),
    this.generalSettings = const Permission(),
  });

  factory SettingsPermissions.fromMap(Map<String, dynamic> map) {
    return SettingsPermissions(
      facebookSettings: Permission.fromMap(map['facebookSettings'] ?? {}),
      generalSettings: Permission.fromMap(map['generalSettings'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
        'facebookSettings': facebookSettings.toMap(),
        'generalSettings': generalSettings.toMap(),
      };
}

// ─────────────────────────────────────────────
// File Manager Permissions
// ─────────────────────────────────────────────

class FileManagerPermissions {
  final Permission view;

  const FileManagerPermissions({
    this.view = const Permission(),
  });

  factory FileManagerPermissions.fromMap(Map<String, dynamic> map) {
    return FileManagerPermissions(
      view: Permission.fromMap(map['view'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
        'view': view.toMap(),
      };
}

// ─────────────────────────────────────────────
// Reports Permissions
// ─────────────────────────────────────────────

class ReportsPermissions {
  final Permission transferLeadReport;
  final Permission totalLeadReport;
  final Permission staffReport;
  final Permission scheduledLeadReport;
  final Permission rejectedLeadReport;

  const ReportsPermissions({
    this.transferLeadReport = const Permission(),
    this.totalLeadReport = const Permission(),
    this.staffReport = const Permission(),
    this.scheduledLeadReport = const Permission(),
    this.rejectedLeadReport = const Permission(),
  });

  factory ReportsPermissions.fromMap(Map<String, dynamic> map) {
    return ReportsPermissions(
      transferLeadReport: Permission.fromMap(map['transferLeadReport'] ?? {}),
      totalLeadReport: Permission.fromMap(map['totalLeadReport'] ?? {}),
      staffReport: Permission.fromMap(map['staffReport'] ?? {}),
      scheduledLeadReport: Permission.fromMap(map['scheduledLeadReport'] ?? {}),
      rejectedLeadReport: Permission.fromMap(map['rejectedLeadReport'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
        'transferLeadReport': transferLeadReport.toMap(),
        'totalLeadReport': totalLeadReport.toMap(),
        'staffReport': staffReport.toMap(),
        'scheduledLeadReport': scheduledLeadReport.toMap(),
        'rejectedLeadReport': rejectedLeadReport.toMap(),
      };
}

// ─────────────────────────────────────────────
// Main Designation Model
// ─────────────────────────────────────────────

class DesignationModel {
  final String? id; // Firestore document ID
  final String designationName;
  final StaffManagementPermissions staffManagement;
  final LeadManagementPermissions leadManagement;
  final SettingsPermissions settings;
  final FileManagerPermissions fileManager;
  final ReportsPermissions reports;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DesignationModel({
    this.id,
    required this.designationName,
    this.staffManagement = const StaffManagementPermissions(),
    this.leadManagement = const LeadManagementPermissions(),
    this.settings = const SettingsPermissions(),
    this.fileManager = const FileManagerPermissions(),
    this.reports = const ReportsPermissions(),
    this.createdAt,
    this.updatedAt,
  });

  /// Create from Firestore DocumentSnapshot
  factory DesignationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DesignationModel(
      id: doc.id,
      designationName: data['designationName'] ?? '',
      staffManagement: StaffManagementPermissions.fromMap(
          data['staffManagement'] ?? {}),
      leadManagement:
          LeadManagementPermissions.fromMap(data['leadManagement'] ?? {}),
      settings: SettingsPermissions.fromMap(data['settings'] ?? {}),
      fileManager: FileManagerPermissions.fromMap(data['fileManager'] ?? {}),
      reports: ReportsPermissions.fromMap(data['reports'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Create from plain Map (e.g. JSON)
  factory DesignationModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return DesignationModel(
      id: id ?? map['id'],
      designationName: map['designationName'] ?? '',
      staffManagement: StaffManagementPermissions.fromMap(
          map['staffManagement'] ?? {}),
      leadManagement:
          LeadManagementPermissions.fromMap(map['leadManagement'] ?? {}),
      settings: SettingsPermissions.fromMap(map['settings'] ?? {}),
      fileManager: FileManagerPermissions.fromMap(map['fileManager'] ?? {}),
      reports: ReportsPermissions.fromMap(map['reports'] ?? {}),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() => {
        'designationName': designationName,
        'staffManagement': staffManagement.toMap(),
        'leadManagement': leadManagement.toMap(),
        'settings': settings.toMap(),
        'fileManager': fileManager.toMap(),
        'reports': reports.toMap(),
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  DesignationModel copyWith({
    String? id,
    String? designationName,
    StaffManagementPermissions? staffManagement,
    LeadManagementPermissions? leadManagement,
    SettingsPermissions? settings,
    FileManagerPermissions? fileManager,
    ReportsPermissions? reports,
  }) {
    return DesignationModel(
      id: id ?? this.id,
      designationName: designationName ?? this.designationName,
      staffManagement: staffManagement ?? this.staffManagement,
      leadManagement: leadManagement ?? this.leadManagement,
      settings: settings ?? this.settings,
      fileManager: fileManager ?? this.fileManager,
      reports: reports ?? this.reports,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
