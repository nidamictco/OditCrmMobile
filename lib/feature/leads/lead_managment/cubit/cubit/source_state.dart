// lib/features/lead_category/presentation/cubit/lead_category_state.dart

import 'package:equatable/equatable.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/leads_model.dart';

enum LeadSourceStatus { initial, loading, success, failure }

class LeadSourceState extends Equatable {
  final LeadSourceStatus status;
  final List<LeadsModel> sources;
  final String? errorMessage;

  /// Whether a write operation (add / update / delete) is in progress
  final bool isSubmitting;

  /// ID of the category currently being deleted (for per-row loader)
  final String? deletingId;

  const LeadSourceState({
    this.status = LeadSourceStatus.initial,
    this.sources = const [],
    this.errorMessage,
    this.isSubmitting = false,
    this.deletingId,
  });

  bool get isLoading => status == LeadSourceStatus.loading;
  bool get isSuccess => status == LeadSourceStatus.success;
  bool get isFailure => status == LeadSourceStatus.failure;

  LeadSourceState copyWith({
    LeadSourceStatus? status,
    List<LeadsModel>? sources,
    String? errorMessage,
    bool? isSubmitting,
    String? deletingId,
    bool clearError = false,
    bool clearDeletingId = false,
  }) {
    return LeadSourceState(
      status: status ?? this.status,
      sources: sources ?? this.sources,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      deletingId: clearDeletingId ? null : (deletingId ?? this.deletingId),
    );
  }

  @override
  List<Object?> get props => [
        status,
        sources,
        errorMessage,
        isSubmitting,
        deletingId,
      ];
}