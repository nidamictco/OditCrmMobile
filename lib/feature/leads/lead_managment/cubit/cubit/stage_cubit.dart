// lib/features/lead_category/presentation/cubit/lead_category_cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/cubit/stage_state.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/data/lead_stage_repo.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/leads_model.dart';

class LeadStageCubit extends Cubit<LeadStageState> {
  final ILeadStageRepository _repository;
  StreamSubscription? _categoriesSubscription;

  LeadStageCubit({ILeadStageRepository? repository})
      : _repository = repository ?? LeadStageRepository(), 
        super(const LeadStageState());

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  /// Start listening to Firestore in real time.
  void watchCategories() {
    emit(state.copyWith(status: LeadStageStatus.loading));

    _categoriesSubscription?.cancel();
    _categoriesSubscription = _repository.watchCategories().listen(
      (categories) {
        emit(
          state.copyWith(
            status: LeadStageStatus.success,
            stages: [...categories],
            clearError: true,
          ),
        );
      },
      onError: (Object error) {
        emit(
          state.copyWith(
            status: LeadStageStatus.failure,
            errorMessage: _friendlyError(error),
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _categoriesSubscription?.cancel();
    return super.close();
  }

  // ─── Write Operations ─────────────────────────────────────────────────────

  /// Add a new category.
  Future<void> addCategory({
    required String name,
  }) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      await _repository.addCategory(name: name, );
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

  /// Update the name of an existing category.
  Future<void> updateStage({
    required String id,
    required String name,
  }) async {
    if (state.isSubmitting) return;

    final stage = state.stages.firstWhere(
      (s) => s.id == id,
      orElse: () =>  LeadsModel(id: '', name: '', createdBy: '', idOfCreator: '', createdAt: null as dynamic),
    );
    if (stage.id.isNotEmpty && stage.isDefault) {
      emit(state.copyWith(errorMessage: 'This is a default lead stage and cannot be edited or deleted.'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      await _repository.updateCategory(id: id, name: name);
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
  Future<void> deleteStage({required String id}) async {
    if (state.deletingId != null) return;

    final stage = state.stages.firstWhere(
      (s) => s.id == id,
      orElse: () => LeadsModel(id: '', name: '', createdBy: '', idOfCreator: '', createdAt: null as dynamic),
    );
    if (stage.id.isNotEmpty && stage.isDefault) {
      emit(state.copyWith(errorMessage: 'This is a default lead stage and cannot be edited or deleted.'));
      return;
    }

    emit(state.copyWith(deletingId: id, clearError: true));

    try {
      await _repository.deleteCategory(id: id);
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