import 'package:equatable/equatable.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/leads_model.dart';

enum SubCategoryStatus { initial, loading, success, failure }

class SubCategoryState extends Equatable {
  final SubCategoryStatus status;
  final List<LeadsModel> subCategories;
  final String? errorMessage;

  /// Whether a write operation (add / update / delete) is in progress
  final bool isSubmitting;

  /// ID of the category currently being deleted (for per-row loader)
  final String? deletingId;

  const SubCategoryState({
    this.status = SubCategoryStatus.initial,
    this.subCategories = const [],
    this.errorMessage,
    this.isSubmitting = false,
    this.deletingId,
  });

  bool get isLoading => status == SubCategoryStatus.loading;
  bool get isSuccess => status == SubCategoryStatus.success;
  bool get isFailure => status == SubCategoryStatus.failure;

  SubCategoryState copyWith({
    SubCategoryStatus? status,
    List<LeadsModel>? subCategories,
    String? errorMessage,
    bool? isSubmitting,
    String? deletingId,
    bool clearError = false,
    bool clearDeletingId = false,
  }) {
    return SubCategoryState(
      status: status ?? this.status,
      subCategories: subCategories ?? this.subCategories,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      deletingId: clearDeletingId ? null : (deletingId ?? this.deletingId),
    );
  }

  @override
  List<Object?> get props => [
        status,
        subCategories,
        errorMessage,
        isSubmitting,
        deletingId,
      ];
}
