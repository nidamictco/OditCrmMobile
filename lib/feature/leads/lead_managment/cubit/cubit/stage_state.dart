// lib/features/lead_category/presentation/cubit/lead_category_state.dart

import 'package:equatable/equatable.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/leads_model.dart';

enum LeadStageStatus { initial, loading, success, failure }

class LeadStageState extends Equatable {
  final LeadStageStatus status;
  final List<LeadsModel> stages;
  final String? errorMessage;

  /// Whether a write operation (add / update / delete) is in progress
  final bool isSubmitting;

  /// ID of the category currently being deleted (for per-row loader)
  final String? deletingId;

  const LeadStageState({
    this.status = LeadStageStatus.initial,
    this.stages = const [],
    this.errorMessage,
    this.isSubmitting = false,
    this.deletingId,
  });

  bool get isLoading => status == LeadStageStatus.loading;
  bool get isSuccess => status == LeadStageStatus.success;
  bool get isFailure => status == LeadStageStatus.failure;

  LeadStageState copyWith({
    LeadStageStatus? status,
    List<LeadsModel>? stages,
    String? errorMessage,
    bool? isSubmitting,
    String? deletingId,
    bool clearError = false,
    bool clearDeletingId = false,
  }) {
    return LeadStageState(
      status: status ?? this.status,
      stages: stages ?? this.stages,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      deletingId: clearDeletingId ? null : (deletingId ?? this.deletingId),
    );
  }

  @override
  List<Object?> get props => [
        status,
        stages,
        errorMessage,
        isSubmitting,
        deletingId,
      ];
}