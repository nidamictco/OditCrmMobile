import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/feature/staff_management/model/staff_model.dart';
import 'package:odit_crm_mobile/feature/staff_management/cubit/staff_state.dart';
import 'package:odit_crm_mobile/feature/staff_management/data/staff_repo.dart';

class StaffCubit extends Cubit<StaffState> {
  final StaffRepository _repository;

  StaffCubit({StaffRepository? repository})
      : _repository = repository ?? StaffRepository(),
        super(StaffInitial());

//   // ─── Add ──────────────────────────────────────────────────────────────────

//  Future<void> addStaff(
//   StaffModel staff, {
//   File? imageFile,
//   Uint8List? imageBytes,
//   String? imageFileName,
//   File? documentFile,
//   Uint8List? documentBytes,
//   String? documentFileName,
// }) async {
//   emit(StaffSaving());
//   try {
//     final docId = await _repository.addStaff(
//       staff,
//       imageFile: imageFile,
//       imageBytes: imageBytes,
//       imageFileName: imageFileName,
//       documentFile: documentFile,
//       documentBytes: documentBytes,
//       documentFileName: documentFileName,
//     );
//     emit(StaffSaved(docId));
//   } catch (e, st) {
//     emit(StaffError(e.toString()));
//   }
// }

  // ─── Update ───────────────────────────────────────────────────────────────

//   Future<void> updateStaff(
//   StaffModel staff, {
//   File? imageFile,
//   Uint8List? imageBytes,
//   String? imageFileName,
//   File? documentFile,
//   Uint8List? documentBytes,
//   String? documentFileName,
// }) async {
//   emit(StaffSaving());
//   try {
//     await _repository.updateStaff(
//       staff,
//       imageFile: imageFile,
//       imageBytes: imageBytes,
//       imageFileName: imageFileName,
//       documentFile: documentFile,
//       documentBytes: documentBytes,
//       documentFileName: documentFileName,
//     );
//     log('[StaffCubit] Staff updated: ${staff.id}');
//     emit(StaffSaved(staff.id!, isUpdate: true));
//   } catch (e, st) {
//     log('[StaffCubit] Update error: $e', stackTrace: st);
//     emit(StaffError(e.toString()));
//   }
// }

  // ─── Update status ────────────────────────────────────────────────────────

  // Future<void> updateStatus(String staffId, String newStatus) async {
  //   try {
  //     await _repository.updateStaffField(staffId, {'status': newStatus});
  //     log('[StaffCubit] Status updated: $staffId → $newStatus');
  //     await getStaff(staffId);
  //   } catch (e, st) {
  //     log('[StaffCubit] UpdateStatus error: $e', stackTrace: st);
  //     emit(StaffError(e.toString()));
  //   }
  // }
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
  } catch (e, st) {
    log('[StaffCubit] FetchAll error: $e', stackTrace: st);
    if (isClosed) return;
    emit(StaffError(e.toString()));
  }
}

  // // ─── Restore deleted staff ────────────────────────────────────────────────

  // Future<void> restoreStaff(
  //   StaffModel staff, {
  //   File? imageFile,
  //   File? documentFile,
  // }) async {
  //   emit(StaffSaving());
  //   try {
  //     final docId = await _repository.restoreStaff(
  //       staff,
  //       imageFile: imageFile,
  //       documentFile: documentFile,
  //     );
  //     log('[StaffCubit] Staff restored: $docId');
  //     emit(StaffSaved(docId));
  //     await fetchDeletedStaff();
  //   } catch (e, st) {
  //     log('[StaffCubit] Restore error: $e', stackTrace: st);
  //     emit(StaffError(e.toString()));
  //   }
  // }

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

  // // ─── Notes ────────────────────────────────────────────────────────────────

  // Future<void> addNotes(String staffId, List<NoteModel> notes) async {
  //   try {
  //     for (final note in notes) {
  //       await _repository.addNote(staffId, note);
  //     }
  //     log('[StaffCubit] All notes saved: $staffId');
  //     emit(NoteSaved());
  //   } catch (e, st) {
  //     log('[StaffCubit] AddNotes error: $e', stackTrace: st);
  //     emit(StaffError(e.toString()));
  //   }
  // }

  // Future<void> fetchNotes(String staffId) async {
  //   emit(NotesLoading());
  //   try {
  //     final notes = await _repository.fetchNotes(staffId);
  //     emit(NotesLoaded(notes));
  //   } catch (e, st) {
  //     log('[StaffCubit] FetchNotes error: $e', stackTrace: st);
  //     emit(StaffError(e.toString()));
  //   }
  // }

  // Future<void> deleteNote(String staffId, String noteId) async {
  //   try {
  //     await _repository.deleteNote(staffId, noteId);
  //     log('[StaffCubit] Note deleted: $noteId');
  //     await fetchNotes(staffId);
  //   } catch (e, st) {
  //     log('[StaffCubit] DeleteNote error: $e', stackTrace: st);
  //     emit(StaffError(e.toString()));
  //   }
  // }

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