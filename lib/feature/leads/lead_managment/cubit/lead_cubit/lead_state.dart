
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/activity_model.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/add_lead_model.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/additional_model.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/leads_model.dart';
import 'package:odit_crm_mobile/feature/staff_management/Screen/model/staff_model.dart';


enum AddLeadStatus { initial, loading, success, failure }

enum LeadListStatus { initial, loading, loaded, failure }

class AddLeadState {
  final AddLeadStatus status;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  // ── Search ────────────────────────────────────────────────────────────────
  final List<AddLeadModel> searchResults;
  final bool isSearching;

  // ── Lead list ─────────────────────────────────────────────────────────────
  final List<AddLeadModel> leads;
  final LeadListStatus listStatus;
  final String? listError;
  final bool isDeleting;
  final bool isUpdating;

  // ── Dropdown data ─────────────────────────────────────────────────────────
  final List<LeadsModel> categories;
  final List<LeadsModel> sources;
  final List<LeadsModel> stages;

  // ── Form selections ───────────────────────────────────────────────────────
  final String? selectedCategory;
  final String? selectedSource;
  final String? selectedPriority;
  final String? selectedCallResult;
  final String? selectedLeadTag;
  final String? selectedLeadStage;
  final String? selectedState;
  final String? selectedDistrict;
  final String assignedStaffName;
  final String? assignedStaffId;

  // ── Additional / custom fields ────────────────────────────────────────────
  final List<AdditionalFieldModel> additionalFields;
  final bool isLoadingAdditionalFields;

  final List<StaffModel> staffList;

  // -------pichart count___________
  final Map<String, int> leadChartCounts;
  final List<LeadCategoryTableRow> leadCategoryTableRows;

  // ── Dashboard lead counts ──────────────────────────────────────────────────────────
  final String newLeadCount;
  final String followUpCount;
  final String closedLeadCount;
  final String totalCalledCount;
  final String dashboardTotalCalledCount;
  final String connectedCount;
  final String notConnectedCount;
  final String missedLeadCount;
  final String transferredCount;

  final bool isLoadingCounts;

  final DateTime? selectedDashboardDate;

  final String profileClosedCount;
  final String profileTotalCalledCount;
  final String profileConnectedCount;
  final String profileNotConnectedCount;
  final Map<String, int> profileCallResultCounts;
  final bool isLoadingProfileCounts;

  const AddLeadState({
    this.status = AddLeadStatus.initial,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.searchResults = const [],
    this.isSearching = false,
    this.leads = const [],
    this.listStatus = LeadListStatus.initial,
    this.listError,
    this.isDeleting = false,
    this.isUpdating = false,
    this.categories = const [],
    this.sources = const [],
    this.stages = const [],
    this.selectedCategory,
    this.selectedSource,
    this.selectedPriority,
    this.selectedCallResult,
    this.selectedLeadTag,
    this.selectedLeadStage,
    this.selectedState,
    this.selectedDistrict,
    this.assignedStaffName = '',
    this.assignedStaffId,
    this.additionalFields = const [],
    this.isLoadingAdditionalFields = false,
    this.staffList = const [],
    this.closedLeadCount = '0',
    this.newLeadCount = '0',
    this.followUpCount = '0',
    this.totalCalledCount = '0',
    this.dashboardTotalCalledCount = '0',
    this.connectedCount = '0',
    this.notConnectedCount = '0',
    this.missedLeadCount = '0',
    this.transferredCount = '0',
    this.isLoadingCounts = false,
    this.selectedDashboardDate,
    this.leadChartCounts = const {},
    this.leadCategoryTableRows = const [],
    this.profileClosedCount = '0',
    this.profileTotalCalledCount = '0',
    this.profileConnectedCount = '0',
    this.profileNotConnectedCount = '0',
    this.profileCallResultCounts = const {},
    this.isLoadingProfileCounts = false,
  });

  bool get isLoading => status == AddLeadStatus.loading;
  bool get isListLoading => listStatus == LeadListStatus.loading;

  AddLeadState copyWith({
    AddLeadStatus? status,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    List<AddLeadModel>? searchResults,
    bool? isSearching,
    List<AddLeadModel>? leads,
    LeadListStatus? listStatus,
    String? listError,
    bool? isDeleting,
    bool? isUpdating,
    List<LeadsModel>? categories,
    List<LeadsModel>? sources,
    List<LeadsModel>? stages,
    String? selectedCategory,
    String? selectedSource,
    String? selectedPriority,
    String? selectedCallResult,
    String? selectedLeadTag,
    String? selectedLeadStage,
    String? selectedState,
    String? selectedDistrict,
    String? assignedStaffName,
    String? assignedStaffId,
    List<AdditionalFieldModel>? additionalFields,
    List<StaffModel>? staffList,
    bool? isLoadingAdditionalFields,
    String? newLeadCount,
    String? followUpCount,
    String? closedLeadCount,
    String? totalCalledCount,
    String? dashboardTotalCalledCount,
    String? connectedCount,
    String? notConnectedCount,
    String? missedLeadCount,
    String? transferredCount,
    bool? isLoadingCounts,
    DateTime? selectedDashboardDate,
    Map<String, int>? leadChartCounts,
    List<LeadCategoryTableRow>? leadCategoryTableRows,
    String? profileClosedCount,
    String? profileTotalCalledCount,
    String? profileConnectedCount,
    String? profileNotConnectedCount,
    Map<String, int>? profileCallResultCounts,
    bool? isLoadingProfileCounts,
    // ── clear flags ──────────────────────────────────────────────────────────
    bool clearError = false,
    bool clearSuccess = false,
    bool clearListError = false,
    bool clearState = false,
    bool clearDistrict = false,
    bool clearCategory = false,
    bool clearSource = false,
    bool clearPriority = false,
    bool clearLeadStage = false,
    bool clearCallResult = false,
    bool clearLeadTag = false,
  }) {
    return AddLeadState(
      status: status ?? this.status,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      leads: leads ?? this.leads,
      listStatus: listStatus ?? this.listStatus,
      listError: clearListError ? null : (listError ?? this.listError),
      isDeleting: isDeleting ?? this.isDeleting,
      isUpdating: isUpdating ?? this.isUpdating,
      categories: categories ?? this.categories,
      sources: sources ?? this.sources,
      stages: stages ?? this.stages,
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      selectedSource: clearSource
          ? null
          : (selectedSource ?? this.selectedSource),
      selectedPriority: clearPriority
          ? null
          : (selectedPriority ?? this.selectedPriority),
      selectedLeadStage: clearLeadStage
          ? null
          : (selectedLeadStage ?? this.selectedLeadStage),
      selectedState: clearState ? null : (selectedState ?? this.selectedState),
      selectedDistrict: clearDistrict
          ? null
          : (selectedDistrict ?? this.selectedDistrict),
      selectedCallResult: clearCallResult
          ? null
          : (selectedCallResult ?? this.selectedCallResult),
      selectedLeadTag: clearLeadTag
          ? null
          : (selectedLeadTag ?? this.selectedLeadTag),
      assignedStaffName: assignedStaffName ?? this.assignedStaffName,
      assignedStaffId: assignedStaffId ?? this.assignedStaffId,
      additionalFields: additionalFields ?? this.additionalFields,
      isLoadingAdditionalFields:
          isLoadingAdditionalFields ?? this.isLoadingAdditionalFields,
      staffList: staffList ?? this.staffList,
      newLeadCount: newLeadCount ?? this.newLeadCount,
      followUpCount: followUpCount ?? this.followUpCount,
      closedLeadCount: closedLeadCount ?? this.closedLeadCount,
      totalCalledCount: totalCalledCount ?? this.totalCalledCount,
      dashboardTotalCalledCount:
          dashboardTotalCalledCount ?? this.dashboardTotalCalledCount,
      connectedCount: connectedCount ?? this.connectedCount,
      notConnectedCount: notConnectedCount ?? this.notConnectedCount,
      missedLeadCount: missedLeadCount ?? this.missedLeadCount,
      transferredCount: transferredCount ?? this.transferredCount,
      isLoadingCounts: isLoadingCounts ?? this.isLoadingCounts,
      selectedDashboardDate:
          selectedDashboardDate ?? this.selectedDashboardDate,
      leadChartCounts: leadChartCounts ?? this.leadChartCounts,
      leadCategoryTableRows:
          leadCategoryTableRows ?? this.leadCategoryTableRows,
      profileClosedCount: profileClosedCount ?? this.profileClosedCount,
      profileTotalCalledCount:
          profileTotalCalledCount ?? this.profileTotalCalledCount,
      profileConnectedCount:
          profileConnectedCount ?? this.profileConnectedCount,
      profileNotConnectedCount:
          profileNotConnectedCount ?? this.profileNotConnectedCount,
      profileCallResultCounts:
          profileCallResultCounts ?? this.profileCallResultCounts,
      isLoadingProfileCounts:
          isLoadingProfileCounts ?? this.isLoadingProfileCounts,
    );
  }
}
