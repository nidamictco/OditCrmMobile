// lib/feature/permission/cubit/permission_cubit.dart

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/core/constant/firebase_constant.dart';
import 'package:odit_crm_mobile/feature/designation/model.dart/designation_model.dart';

part 'permission_state.dart';

class PermissionCubit extends Cubit<PermissionState> {
  PermissionCubit() : super(PermissionInitial());

  DesignationModel? _designation;

  /// Call after login or session restore
  Future<void> loadPermissions(String? designationId) async {
    if (designationId == null || designationId.trim().isEmpty) {
      log('[PermissionCubit] No designationId → admin, full access');
      _designation = null;
      emit(PermissionLoaded(null));
      return;
    }
    try {
      emit(PermissionLoading());
      final doc = await FirestorePath.companyCollection('DESIGNATIONS')
          .doc(designationId)
          .get();
 
      if (!doc.exists) {
        log('[PermissionCubit] Doc not found for id: $designationId');
        _designation = null;
        emit(PermissionLoaded(null));
        return;
      }
      _designation = DesignationModel.fromFirestore(doc);
      log('[PermissionCubit] Loaded: ${_designation!.designationName}');
      emit(PermissionLoaded(_designation));
    } catch (e) {
      log('[PermissionCubit] Error loading permissions: $e');
      _designation = null;
      emit(PermissionLoaded(null));
    }
  }

  void clear() {
    _designation = null;
    emit(PermissionInitial());
  }

  // ─── Core helper ─────────────────────────────────────────────────────────
  // If _designation is null → user is admin → always return true
  bool _p(Permission? perm, String type) {
    if (_designation == null) return true;
    if (perm == null) return false;
    switch (type) {
      case 'create': return perm.create;
      case 'view':   return perm.view;
      case 'edit':   return perm.edit;
      case 'delete': return perm.delete;
      case 'other':  return perm.other;
      default:       return false;
    }
  }

  // ─── Staff Management ─────────────────────────────────────────────────────
  bool get canViewStaff         => _p(_designation?.staffManagement.viewStaff,    'view');
  bool get canAddStaff          => _p(_designation?.staffManagement.addStaff,     'create');
  bool get canEditStaff         => _p(_designation?.staffManagement.viewStaff,    'edit');
  bool get canDeleteStaff       => _p(_designation?.staffManagement.viewStaff,    'delete');
  bool get canViewDesignation   => _p(_designation?.staffManagement.designation,  'view');
  bool get canAddDesignation    => _p(_designation?.staffManagement.designation,  'create');
  bool get canEditDesignation   => _p(_designation?.staffManagement.designation,  'edit');
  bool get canDeleteDesignation => _p(_designation?.staffManagement.designation,  'delete');
  bool get canViewDeletedStaff  => _p(_designation?.staffManagement.deletedStaff, 'view');

  // ─── Lead Management ──────────────────────────────────────────────────────
  bool get canViewDashboard       => _p(_designation?.leadManagement.dashboard,           'view');
  bool get canAddLead             => _p(_designation?.leadManagement.addLead,             'create');
  bool get canEditLead            => _p(_designation?.leadManagement.dashboard,           'edit');
  bool get canDeleteLead          => _p(_designation?.leadManagement.dashboard,           'delete');
  bool get canViewLeadsReport     => _p(_designation?.leadManagement.leadsReport,         'view');
  bool get canViewLeadCategory    => _p(_designation?.leadManagement.leadCategory,        'view');
  bool get canAddLeadCategory     => _p(_designation?.leadManagement.leadCategory,        'create');
  bool get canImportLeads         => _p(_designation?.leadManagement.importLeads,         'create');
  bool get canViewCallHistory     => _p(_designation?.leadManagement.callHistory,         'view');
  bool get canViewCallSettings    => _p(_designation?.leadManagement.callSettings,        'view');
  bool get canViewDeletedLeads    => _p(_designation?.leadManagement.deletedLeads,        'view');
  bool get canViewUnassignedLeads => _p(_designation?.leadManagement.unassignedLeads,     'view');
  bool get canTransferLeads       => _p(_designation?.leadManagement.transferLeads,       'create');
  bool get canViewTransferLeads   => _p(_designation?.leadManagement.transferLeads,       'view');
  bool get canViewCustomFields    => _p(_designation?.leadManagement.customFieldSettings, 'view');
  bool get canViewFileManagerLead => _p(_designation?.leadManagement.fileManager,         'view');
  bool get canViewPhoneCallLog    => _p(_designation?.leadManagement.phoneCallLog,        'view');
  bool get canViewLeadSource      => _p(_designation?.leadManagement.leadSource,          'view');
  bool get canAddLeadSource       => _p(_designation?.leadManagement.leadSource,          'create');
  bool get canViewLeadStages      => _p(_designation?.leadManagement.leadStages,          'view');

  // ─── Settings ─────────────────────────────────────────────────────────────
  bool get canViewFacebookSettings => _p(_designation?.settings.facebookSettings, 'view');
  bool get canViewGeneralSettings  => _p(_designation?.settings.generalSettings,  'view');

  // ─── File Manager ─────────────────────────────────────────────────────────
  bool get canViewFileManager => _p(_designation?.fileManager.view, 'view');

  // ─── Reports ──────────────────────────────────────────────────────────────
  bool get canViewTransferReport  => _p(_designation?.reports.transferLeadReport,  'view');
  bool get canViewTotalReport     => _p(_designation?.reports.totalLeadReport,     'view');
  bool get canViewStaffReport     => _p(_designation?.reports.staffReport,         'view');
  bool get canViewScheduledReport => _p(_designation?.reports.scheduledLeadReport, 'view');
  bool get canViewRejectedReport  => _p(_designation?.reports.rejectedLeadReport,  'view');
}