import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/data/subCategory.dart';
import 'sub_category_state.dart';

class SubCategoryCubit extends Cubit<SubCategoryState> {
  final ISubCategoryRepository _repository;
  StreamSubscription? _subCategoriesSubscription;

  SubCategoryCubit({
    required String categoryId,
    ISubCategoryRepository? repository,
  })  : _repository = repository ?? SubCategoryRepository(categoryId: categoryId),
        super(const SubCategoryState());

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  /// Start listening to Firestore in real time.
  void watchSubCategories() {
    emit(state.copyWith(status: SubCategoryStatus.loading));

    _subCategoriesSubscription?.cancel();
    _subCategoriesSubscription = _repository.watchSubCategories().listen(
      (subCategories) {
        emit(
          state.copyWith(
            status: SubCategoryStatus.success,
            subCategories: [...subCategories],
            clearError: true,
          ),
        );
      },
      onError: (Object error) {
        emit(
          state.copyWith(
            status: SubCategoryStatus.failure,
            errorMessage: _friendlyError(error),
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _subCategoriesSubscription?.cancel();
    return super.close();
  }

  // ─── Write Operations ─────────────────────────────────────────────────────

  /// Add a new sub category.
  Future<void> addSubCategory({
    required String name,
  }) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      await _repository.addSubCategory(name: name);
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

  /// Update the name of an existing sub category.
  Future<void> updateSubCategory({
    required String id,
    required String name,
  }) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      await _repository.updateSubCategory(id: id, name: name);
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

  /// Delete a sub category by its Firestore document ID.
  Future<void> deleteSubCategory({required String id}) async {
    if (state.deletingId != null) return;
    emit(state.copyWith(deletingId: id, clearError: true));

    try {
      await _repository.deleteSubCategory(id: id);
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
