// lib/features/lead_category/presentation/cubit/lead_category_cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/cubit/source_state.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/data/lead_source_repo.dart';

class LeadSourceCubit extends Cubit<LeadSourceState> {
  final ILeadSourceRepository _repository;
  StreamSubscription? _sourcesSubscription;

  LeadSourceCubit({ILeadSourceRepository? repository})
      : _repository = repository ?? LeadSourceRepository(), 
        super(const LeadSourceState());

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  /// Start listening to Firestore in real time.
  void watchSources() {
    emit(state.copyWith(status: LeadSourceStatus.loading));

    _sourcesSubscription?.cancel();
    _sourcesSubscription = _repository.watchSource().listen(
      (sources) {
        emit(
          state.copyWith(
            status: LeadSourceStatus.success,
            sources: [...sources],
            clearError: true,
          ),
        );
      },
      onError: (Object error) {
        emit(
          state.copyWith(
            status: LeadSourceStatus.failure,
            errorMessage: _friendlyError(error),
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _sourcesSubscription?.cancel();
    return super.close();
  }

  // ─── Write Operations ─────────────────────────────────────────────────────

  /// Add a new category.
  Future<void> addSource({
    required String name,
  }) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      await _repository.addSource(name: name, );
      emit(state.copyWith(isSubmitting: false));
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: _friendlyError(e),
        ),
      );
    }
  }

  //  Future<void> fetchLeadSource() async {
  //   emit(state.copyWith(status: LeadSourceStatus.loading));

  //   _sourcesSubscription?.cancel();
  //   _sourcesSubscription = _repository.watchSource().listen(
  //     (sources) {
  //       emit(
  //         state.copyWith(
  //           status: LeadSourceStatus.success,
  //           sources: [...sources],
  //           clearError: true,
  //         ),
  //       );
  //     },
  //     onError: (Object error) {
  //       emit(
  //         state.copyWith(
  //           status: LeadSourceStatus.failure,
  //           errorMessage: _friendlyError(error),
  //         ),
  //       );
  //     },
  //   );
  // } 

  /// Update the name of an existing category.
  Future<void> updateSource({
    required String id,
    required String name,
  }) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      await _repository.updateSource(id: id, name: name);
      emit(state.copyWith(isSubmitting: false));
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: _friendlyError(e),
        ),
      );
    }
  }

  /// Delete a category by its Firestore document ID.
  Future<void> deleteSource({required String id}) async {
    if (state.deletingId != null) return;
    emit(state.copyWith(deletingId: id, clearError: true));

    try {
      await _repository.deleteSource(id: id);
      emit(state.copyWith(clearDeletingId: true));
    } catch (e) {
      emit(
        state.copyWith(
          clearDeletingId: true,
          errorMessage: _friendlyError(e),
        ),
      );
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _friendlyError(Object error) {
    final msg = error.toString();
    if (msg.contains('permission-denied')) {
      return 'You do not have permission to perform this action.';
    }
    if (msg.contains('network') || msg.contains('unavailable')) {
      return 'Network error. Please check your connection.';
    }
    if (msg.contains('not-found')) {
      return 'Record not found. It may have been deleted already.';
    }
    return 'Something went wrong. Please try again.';
  }
}