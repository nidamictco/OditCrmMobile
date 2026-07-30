import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/core/constant/firebase_constant.dart';
import 'package:odit_crm_mobile/feature/staff_management/model/staff_model.dart';
import 'package:odit_crm_mobile/feature/staff_management/cubit/staff_state.dart';
import 'package:odit_crm_mobile/feature/staff_management/data/staff_repo.dart';

class StaffCubit extends Cubit<StaffState> {
  final StaffRepository _repository;

  StaffCubit({StaffRepository? repository})
      : _repository = repository ?? StaffRepository(),
        super(StaffInitial());


  // ─── Update status ────────────────────────────────────────────────────────

 
  Future<void> updateStatus(String staffId, String newStatus) async {
  try {
    await _repository.updateStaffField(staffId, {'status': newStatus});

    // Update list in-memory if list is loaded
    if (state is StaffListLoaded) {
      final updated = (state as StaffListLoaded).staffList.map((s) {
        return s.id == staffId ? s.copyWith(status: newStatus) : s;
      }).toList();
      emit(StaffListLoaded(updated));
    }

    // Update single staff in-memory if profile is loaded
    if (state is StaffLoaded) {
      final current = (state as StaffLoaded).staff;
      if (current.id == staffId) {
        emit(StaffLoaded(current.copyWith(status: newStatus)));
      }
    }

   
  } catch (e, st) {
    log('[StaffCubit] UpdateStatus error: $e', stackTrace: st);
    emit(StaffError(e.toString()));
  }
}

  // ─── Delete (soft) ────────────────────────────────────────────────────────

  Future<void> deleteStaff(String id, StaffModel staff) async {
    emit(StaffLoading());
    try {
      await _repository.moveToDeleted(staff);
      log('[StaffCubit] Staff moved to deleted: $id');
      emit(StaffDeleted(id));
      await fetchAll();
    } catch (e, st) {
      log('[StaffCubit] Delete error: $e', stackTrace: st);
      emit(StaffError(e.toString()));
    }
  }

  // ─── Fetch single ─────────────────────────────────────────────────────────

  Future<void> getStaff(String id) async {
    emit(StaffLoading());
    try {
      final staff = await _repository.getStaff(id);
      if (staff != null) {
        emit(StaffLoaded(staff));
      } else {
        emit(StaffError('Staff member not found'));
      }
    } catch (e, st) {
      log('[StaffCubit] GetStaff error: $e', stackTrace: st);
      emit(StaffError(e.toString()));
    }
  }

  // ─── Fetch all ────────────────────────────────────────────────────────────

  // Future<void> fetchAll() async {
  //   emit(StaffLoading());
  //   try {
  //     final list = await _repository.fetchAll();
  //     emit(StaffListLoaded(list));
  //   } catch (e, st) {
  //     log('[StaffCubit] FetchAll error: $e', stackTrace: st);
  //     emit(StaffError(e.toString()));
  //   }
  // }

  Future<void> fetchAll() async {
  if (isClosed) return;
  emit(StaffLoading());
  try {
    final list = await _repository.fetchAll();
    if (isClosed) return;
    emit(StaffListLoaded(list));
  } on CompanyNotInitializedException {
    // App is mid-logout/navigating away — nothing to show, don't surface an error.
    return;
  }  catch (e, st) {
    log('[StaffCubit] FetchAll error: $e', stackTrace: st);
    if (isClosed) return;
    emit(StaffError(e.toString()));
  }
}

 
  // ─── Fetch deleted staff ──────────────────────────────────────────────────

  Future<void> fetchDeletedStaff() async {
    emit(StaffLoading());
    try {
      final list = await _repository.fetchDeletedStaff();
      emit(StaffListLoaded(list));
    } catch (e, st) {
      log('[StaffCubit] FetchDeletedStaff error: $e', stackTrace: st);
      emit(StaffError(e.toString()));
    }
  }

  // ─── Delete permanently ───────────────────────────────────────────────────

  Future<void> deleteStaffPermanently(String id) async {
    emit(StaffLoading());
    try {
      await _repository.deleteStaffPermanently(id);
      log('[StaffCubit] Staff deleted permanently: $id');
      emit(StaffDeleted(id));
      await fetchDeletedStaff();
    } catch (e, st) {
      log('[StaffCubit] DeletePermanently error: $e', stackTrace: st);
      emit(StaffError(e.toString()));
    }
  }

 

  // ─── Update field ─────────────────────────────────────────────────────────

  Future<void> updateStaffField(
    String staffId,
    Map<String, dynamic> fields,
  ) async {
    try {
      await _repository.updateStaffField(staffId, fields);
      log('[StaffCubit] Field updated: $staffId → $fields');
      await getStaff(staffId);
    } catch (e, st) {
      log('[StaffCubit] UpdateField error: $e', stackTrace: st);
      emit(StaffError(e.toString()));
    }
  }

  // ─── Reset ────────────────────────────────────────────────────────────────

  void reset() => emit(StaffInitial());
}