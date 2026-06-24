// lib/features/lead_category/presentation/cubit/lead_category_state.dart

import 'package:equatable/equatable.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/leads_model.dart';

enum LeadCategoryStatus { initial, loading, success, failure }

class LeadCategoryState extends Equatable {
  final LeadCategoryStatus status;
  final List<LeadsModel> categories;
  final String? errorMessage;

  /// Whether a write operation (add / update / delete) is in progress
  final bool isSubmitting;

  /// ID of the category currently being deleted (for per-row loader)
  final String? deletingId;

  const LeadCategoryState({
    this.status = LeadCategoryStatus.initial,
    this.categories = const [],
    this.errorMessage,
    this.isSubmitting = false,
    this.deletingId,
  });

  bool get isLoading => status == LeadCategoryStatus.loading;
  bool get isSuccess => status == LeadCategoryStatus.success;
  bool get isFailure => status == LeadCategoryStatus.failure;

  LeadCategoryState copyWith({
    LeadCategoryStatus? status,
    List<LeadsModel>? categories,
    String? errorMessage,
    bool? isSubmitting,
    String? deletingId,
    bool clearError = false,
    bool clearDeletingId = false,
  }) {
    return LeadCategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      deletingId: clearDeletingId ? null : (deletingId ?? this.deletingId),
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        errorMessage,
        isSubmitting,
        deletingId,
      ];
}