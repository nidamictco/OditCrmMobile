import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/core/constant/firebase_constant.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/core/theme/assets_resources.dart';
import 'package:odit_crm_mobile/core/utils/launch_phone_and_whatsapp.dart';
import 'package:odit_crm_mobile/feature/leads/lead_details/widgets/followup_form_card.dart';
import 'package:odit_crm_mobile/feature/leads/lead_details/widgets/followup_history_card.dart';
import 'package:odit_crm_mobile/feature/leads/lead_details/widgets/lead_tab_bar.dart';
import 'package:odit_crm_mobile/feature/leads/lead_details/widgets/quick_action_button.dart';
import 'package:odit_crm_mobile/feature/leads/lead_details/widgets/lead_details_tab.dart';
import 'package:odit_crm_mobile/feature/leads/lead_details/widgets/lead_activities_tab.dart';
import 'package:odit_crm_mobile/feature/leads/lead_details/widgets/status_badge.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/screens/add_lead.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_cubit.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_state.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/screens/lead_management.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/add_lead_model.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/lead_card.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class LeadDetailsScreen extends StatefulWidget {
  final AddLeadModel? lead;
  final bool showFollowupForm;
  final String from;

  const LeadDetailsScreen({
    super.key,
    this.lead,
    this.showFollowupForm = false,
    this.from = 'NEW',
  });

  static void show(
    BuildContext context, {
    AddLeadModel? lead,
    bool showFollowupForm = false,
  }) {
    final cubit = context.read<AddLeadCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: LeadDetailsScreen(
          lead: lead,
          showFollowupForm: showFollowupForm,
        ),
      ),
    );
  }

  @override
  State<LeadDetailsScreen> createState() => _LeadDetailsScreenState();
}

class _LeadDetailsScreenState extends State<LeadDetailsScreen> {
  String _selectedTab = 'Follow Up';
  late bool _showFollowupForm;
  final ScrollController _scrollController = ScrollController();
  bool _isEditingFollowup = false;
  FollowUpModel? _editingFollowup;

  // Form Fields State
  String? _selectedCallStatus;
  String? _selectedLeadStage;
  List<String?> _selectedProducts = [null];
  final TextEditingController _costController = TextEditingController(
    text: '0',
  );

  String? _selectedCategory;

  // More Details Fields State
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _whatsaapCntrlr = TextEditingController();
  final TextEditingController _addressCntrlr = TextEditingController();
  final TextEditingController _emailCntrlr = TextEditingController();

  DateTime _nextFollowupDateValue = DateTime.now().add(const Duration(days: 1));
  String? _nextFollowupDate;

  String? _selectedStaff;
  String? _selectedPriority;
  String? _selectedTag;

  // Maps & Options
  final List<String> _productsList = [
    'CRM Software',
    'Mobile App Development',
    'ERP System',
    'Cloud Hosting',
    'SEO & Marketing',
  ];
  final List<String> _staffList = [
    'Fairooza',
    'Farsana',
    'Shahid',
    'Arun',
    'Sreeja',
  ];
  final List<String> _priorityList = ['High', 'Normal', 'Low', 'negative'];

  late AddLeadModel _leadData;

  Future<void> _loadLatestLead() async {
    debugPrint('=== _loadLatestLead START ===');
    debugPrint('Lead ID: ${_leadData.id}');

    if (_leadData.id == null || _leadData.id!.isEmpty) {
      debugPrint('❌ CRITICAL: leadId is null or empty in _loadLatestLead!');
      return;
    }

    try {
      debugPrint('📌 Fetching lead document from LEADS/${_leadData.id}...');
      final doc = await FirestorePath.companyCollection(
        'LEADS',
      ).doc(_leadData.id).get();

      if (!mounted) {
        debugPrint('⚠️ Widget unmounted, skipping setState');
        return;
      }

      if (!doc.exists) {
        debugPrint('❌ Lead document does not exist in Firestore!');
        return;
      }

      debugPrint('✅ Lead document exists');
      final updatedLead = AddLeadModel.fromFirestore(doc.data()!, doc.id);

      debugPrint(
        '📌 Fetching FOLLOW_UPS subcollection for lead ${_leadData.id}...',
      );
      final followUpsSnap = await FirestorePath.companyCollection('LEADS')
          .doc(_leadData.id)
          .collection('FOLLOW_UPS')
          .orderBy('createdAt', descending: true)
          .get();

      debugPrint(
        '✅ Follow-ups snap returned ${followUpsSnap.docs.length} docs',
      );

      if (followUpsSnap.docs.isNotEmpty) {
        debugPrint('📌 Sample follow-up doc:');
        debugPrint('   ID: ${followUpsSnap.docs.first.id}');
        debugPrint('   Data: ${followUpsSnap.docs.first.data()}');
      }

      final List<FollowUpModel> followUps = [];
      for (final fupDoc in followUpsSnap.docs) {
        try {
          final fup = FollowUpModel.fromFirestore(fupDoc.data(), fupDoc.id);
          followUps.add(fup);
          debugPrint(
            '✅ Parsed follow-up ${fupDoc.id}: '
            'status=${fup.calledStatus}, stage=${fup.leadStage}',
          );
        } catch (e) {
          debugPrint('❌ Error parsing follow-up ${fupDoc.id}: $e');
        }
      }

      debugPrint('✅ Successfully parsed ${followUps.length} follow-ups');

      final leadWithFollowUps = updatedLead.copyWith(followUp: followUps);

      if (!mounted) {
        debugPrint('⚠️ Widget unmounted before setState, skipping');
        return;
      }

      setState(() {
        _leadData = leadWithFollowUps;
        _whatsaapCntrlr.text = _leadData.whatsappNumber;
        _addressCntrlr.text = _leadData.address;
        _emailCntrlr.text = _leadData.email;
        _selectedPriority = _leadData.priority.isNotEmpty
            ? _leadData.priority
            : 'Normal';
      });

      debugPrint('✅ _loadLatestLead completed successfully');
      debugPrint(
        '📊 Final state: ${_leadData.followUp?.length ?? 0} follow-ups loaded',
      );
    } catch (e, st) {
      debugPrint('❌ _loadLatestLead ERROR: $e');
      debugPrint('Stack: $st');
    }
  }

  @override
  void initState() {
    super.initState();

    log(
      '[LeadDetailsScreen] initState() called - showFollowupForm: ${widget.showFollowupForm}',
    );
    _showFollowupForm = widget.showFollowupForm;
    _leadData =
        widget.lead ??
        const AddLeadModel(
          clientName: '',
          contactNumber: '',
          contactDialCode: '+91',
          assignedStaff: '',
          assignedStaffId: '',
          createdBy: '',
          createdById: '',
        );
    _whatsaapCntrlr.text = _leadData.whatsappNumber;
    _addressCntrlr.text = _leadData.address;
    _emailCntrlr.text = _leadData.email;

    final cubit = context.read<AddLeadCubit>();
    if (cubit.state.stages.isEmpty || cubit.state.categories.isEmpty) {
      log(
        '[LeadDetailsScreen] Cubit stages or categories list is empty. Triggering initialize().',
      );
      cubit.initialize();
    }

    _loadLatestLead();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _costController.dispose();
    _remarksController.dispose();
    _whatsaapCntrlr.dispose();
    _addressCntrlr.dispose();
    _emailCntrlr.dispose();
    super.dispose();
  }

  // ── Date Picker ─────────────────────────────────────────────────────────────
  // Rules:
  //   • firstDate = DateTime.now()  → past dates are unselectable in the picker
  //   • Default initialDate = tomorrow at current time
  //   • After picking, validate that the combined DateTime is strictly after now
  //     to catch the edge-case where the user picks today but chooses a past time.
  Future<void> _pickNextFollowupDate() async {
    final now = DateTime.now();
    // Default to tomorrow so the calendar opens on a valid date
    final initialDate = now.add(const Duration(days: 1));

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now, // ✅ past dates greyed out
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
    );

    if (time == null || !mounted) return;

    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // ✅ Reject if the combined date+time is not strictly in the future
    if (!picked.isAfter(now)) {
      _showError('Please select a future date and time');
      return;
    }

    setState(() {
      _nextFollowupDateValue = picked;
      _nextFollowupDate = DateFormat('dd-MM-yyyy hh:mm a').format(picked);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Reset form ──────────────────────────────────────────────────────────────
  void _resetForm() {
    if (!mounted) return;
    setState(() {
      _showFollowupForm = false;
      _isEditingFollowup = false;
      _editingFollowup = null;
      _selectedCallStatus = null;
      _selectedLeadStage = null;
      _selectedProducts = [null];
      _costController.text = '0';
      _selectedCategory = null;
      _selectedTag = null;
      _remarksController.clear();
      _whatsaapCntrlr.text = _leadData.whatsappNumber;
      _addressCntrlr.text = _leadData.address;
      _emailCntrlr.text = _leadData.email;
      _nextFollowupDateValue = DateTime.now().add(const Duration(days: 1));
      _nextFollowupDate = null;
      _selectedStaff = null;
      _selectedPriority = _leadData.priority.isNotEmpty
          ? _leadData.priority
          : 'Normal';
    });
  }

  // ── Submit ──────────────────────────────────────────────────────────────────
  void _submitFollowup() {
    debugPrint('=== FOLLOWUP SUBMISSION START ===');
    debugPrint('Lead ID: ${_leadData.id}');
    debugPrint('Lead Name: ${_leadData.clientName}');

    // ── Validation ────────────────────────────────────────────────────────────

    // 1. Call Status
    if (_selectedCallStatus == null) {
      _showError('Please select Call Status');
      return;
    }

    // 2. Lead Stage
    if (_selectedLeadStage == null || _selectedLeadStage!.isEmpty) {
      _showError('Please select Lead Stage');
      return;
    }

    // 5. Lead ID guard
    if (_leadData.id == null || _leadData.id!.isEmpty) {
      debugPrint('❌ CRITICAL: leadId is null or empty!');
      _showError('Lead ID is missing. Cannot save follow-up.');
      return;
    }
    String whatsappNumber = _whatsaapCntrlr.text.trim();
    if (whatsappNumber.isNotEmpty && whatsappNumber.length != 10) {
      _showError('WhatsApp Number must be 10 digits');
      return;
    }

    String email = _emailCntrlr.text.trim();
    if (email.isNotEmpty) {
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
      );
      if (!emailRegex.hasMatch(email)) {
        _showError('Enter a valid email address');
        return;
      }
    }
    if (_selectedTag == null && _selectedLeadStage == 'REJECTED') {
      _showError('Please select Lead Tag');
      return;
    }

    final DateTime nextFollowUpDate = _nextFollowupDateValue;

    final cubit = context.read<AddLeadCubit>();
    cubit.selectLeadStage(_selectedLeadStage!);
    cubit.selectCategory(_selectedCategory);
    cubit.selectPriority(_selectedPriority);
    cubit.selectLeadTag(_selectedTag);

    debugPrint('📌 Follow-up Details:');
    debugPrint('   - Call Status: $_selectedCallStatus');
    debugPrint('   - Lead Stage: $_selectedLeadStage');
    debugPrint('   - Category: $_selectedCategory');
    debugPrint('   - Priority: $_selectedPriority');
    debugPrint('   - Next Followup: $nextFollowUpDate');

    cubit
        .submitFollowUp(
          leadId: _leadData.id!,
          leadName: _leadData.clientName,
          leadPhone: _leadData.contactNumber,
          leadWhatsappNo: _whatsaapCntrlr.text.trim().isNotEmpty
              ? _whatsaapCntrlr.text.trim()
              : (_leadData.whatsappNumber.isNotEmpty
                    ? _leadData.whatsappNumber
                    : _leadData.contactNumber),
          leadWhatsappDialCode: '+91',
          calledDate: DateTime.now(),
          nextFollowUpDate: nextFollowUpDate,
          leadTag: _selectedTag ?? _leadData.leadTag ?? '',
          calledStatus: _selectedCallStatus!.trim(),
          remarks: _remarksController.text.isNotEmpty
              ? _remarksController.text
              : 'N/A',
          fromPage: _isEditingFollowup ? 'EDIT' : widget.from,
          address: _addressCntrlr.text.trim().isNotEmpty
              ? _addressCntrlr.text.trim()
              : _leadData.address,
          email: _emailCntrlr.text.trim().isNotEmpty
              ? _emailCntrlr.text.trim()
              : _leadData.email,
          editId: _isEditingFollowup ? (_editingFollowup?.id ?? '') : '',
          previousStage: _leadData.leadStage ?? '',
          previousCategory: _leadData.leadCategory ?? '',
          previousPriority: _leadData.priority ?? '',
        )
        .then((_) async {
          debugPrint('✅ submitFollowUp() completed');
          debugPrint('📌 Now calling _loadLatestLead()...');

          await _loadLatestLead();

          final wasEditing = _isEditingFollowup;
          await _loadLatestLead();

          debugPrint(
            '✅ _loadLatestLead() completed. Followups: ${_leadData.followUp?.length ?? 0}',
          );

          if (mounted) {
            debugPrint('📌 setState() triggered');
            setState(() {});
          }

          _showSuccess(
            wasEditing
                ? 'Follow-up updated successfully'
                : 'Follow-up added successfully',
          );
        })
        .catchError((error, stackTrace) {
          debugPrint('❌ ERROR in submitFollowUp chain: $error');
          debugPrint('Stack: $stackTrace');
          if (mounted) {
            _showError('Failed to save follow-up: $error');
          }
        });
  }

  void _showMoreOptionsDropdown(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(0, 14.w), ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      items: [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              const Icon(
                Icons.edit_outlined,
                color: AppColors.bottomNavBlue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Edit',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'delete',
          onTap: () {
            context.read<AddLeadCubit>().deleteLead(_leadData.id!, _leadData);
            context.read<AddLeadCubit>().fetchLeads();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    LeadManagmentScreen(initialStatus: 'Followup'),
              ),
            );
          },
          child: Row(
            children: [
              const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Delete',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (!context.mounted) return;
      if (value == 'edit') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CreateLeadScreen(from: 'EDIT', lead: _leadData),
          ),
        ).then((_) async {
          if (context.mounted) {
            context.read<AddLeadCubit>().fetchLeads();
            await _loadLatestLead();
          }
        });
      } else if (value == 'delete') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The lead has been deleted successfully.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.h,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: const _CustomLeadDetailsHeader(),
          body: BlocListener<AddLeadCubit, AddLeadState>(
            listenWhen: (previous, current) =>
                previous.isSubmitting == true && current.isSubmitting == false,
            listener: (context, state) async {
              if (state.status == AddLeadStatus.success) {
                final wasEditing = _isEditingFollowup;
                await _loadLatestLead();
                if (!mounted) return;
                _resetForm();
                context.read<AddLeadCubit>().fetchLeads();
                //              _showSuccess(
                //   wasEditing
                //       ? 'Follow-up updated successfully'
                //       : 'Follow-up added successfully',
                // );
              } else if (state.status == AddLeadStatus.failure &&
                  state.errorMessage != null) {
                if (!mounted) return;
                _showError(state.errorMessage!);
              }
            },
            child: BlocBuilder<AddLeadCubit, AddLeadState>(
              buildWhen: (previous, current) =>
                  previous.stages != current.stages ||
                  previous.categories != current.categories ||
                  previous.isSubmitting != current.isSubmitting ||
                  previous.status != current.status,
              builder: (context, state) {
                final stages = state.stages.map((st) => st.name).toList();
                final categories = state.categories.map((c) => c.name).toList();

                log(
                  '[LeadDetailsScreen] builder check: state.status: ${state.status}, stages: ${stages.length}, categories: ${categories.length}, selectedLeadStage: $_selectedLeadStage, selectedCategory: $_selectedCategory, showFollowupForm: $_showFollowupForm',
                );

                final followupStages = stages
                    .where((stage) => stage.toUpperCase() != 'NEW')
                    .toList();

                if (stages.isNotEmpty) {
                  if (!_isEditingFollowup) {
                    if (_selectedLeadStage == null ||
                        !followupStages.contains(_selectedLeadStage)) {
                      if (followupStages.contains('FOLLOWUP')) {
                        _selectedLeadStage = 'FOLLOWUP';
                      } else if (followupStages.isNotEmpty) {
                        _selectedLeadStage = followupStages.first;
                      }
                    }
                  } else {
                    if (_selectedLeadStage == null ||
                        !stages.contains(_selectedLeadStage)) {
                      final leadStage = _leadData.leadStage.isNotEmpty
                          ? _leadData.leadStage.toUpperCase()
                          : null;
                      _selectedLeadStage =
                          (leadStage != null && stages.contains(leadStage))
                          ? leadStage
                          : stages.first;
                    }
                  }
                }

                if (categories.isNotEmpty) {
                  if (_selectedCategory == null ||
                      !categories.contains(_selectedCategory)) {
                    final leadCategory = _leadData.leadCategory.isNotEmpty
                        ? _leadData.leadCategory.toUpperCase()
                        : null;
                    _selectedCategory =
                        (leadCategory != null &&
                            categories.contains(leadCategory))
                        ? leadCategory
                        : null;
                  }
                }

                return SafeArea(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LeadSummaryCard(lead: _leadData),
                        SizedBox(height: 3.h),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            QuickActionButton(
                              icon: Icons.call,
                              backgroundColor: const Color(0xFFE8F7EA),
                              iconColor: const Color(0xFF2E7D32),
                              label: 'Call',
                              onTap: () {
                                launchPhoneCall(
                                  context,
                                  _leadData.contactNumber,
                                );
                              },
                            ),
                            QuickActionButton(
                              iconAsset: AssetResources.whatsapp,
                              backgroundColor: const Color(0xFFE8F7EA),

                              label: 'WhatsApp',
                              onTap: () {
                                if (_leadData.whatsappNumber.isNotEmpty) {
                                  launchWhatsApp(
                                    context,
                                    _leadData.whatsappNumber,
                                  );
                                } else {
                                  launchWhatsApp(
                                    context,
                                    _leadData.contactNumber,
                                  );
                                }
                              },
                            ),
                            QuickActionButton(
                              icon: Icons.share,
                              backgroundColor: const Color(0xFFF3ECE9),
                              iconColor: const Color(0xFFC85C32),
                              label: 'Share',
                              onTap: _shareLeadOnWhatsApp,
                            ),
                            Builder(
                              builder: (buttonContext) {
                                return QuickActionButton(
                                  icon: Icons.more_vert,
                                  backgroundColor: const Color(0xFFF1F3F5),
                                  iconColor: const Color(0xFF555555),
                                  label: 'More',
                                  onTap: () {
                                    _showMoreOptionsDropdown(buttonContext);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),

                        LeadTabBar(
                          selectedTab: _selectedTab,
                          tabs: const ['Follow Up', 'Activities', 'Details'],
                          onTabChanged: (tab) {
                            setState(() {
                              _selectedTab = tab;
                            });
                          },
                        ),
                        SizedBox(height: 2.5.h),

                        if (_selectedTab == 'Follow Up') ...[
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Column(
                              children: [
                                if (!_showFollowupForm) ...[
                                  SizedBox(
                                    width: double.infinity,
                                    height: 7.h,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _showFollowupForm = true;
                                          _isEditingFollowup = false;
                                          _selectedLeadStage = null;
                                          // ✅ Reset date to tomorrow whenever
                                          // a fresh form is opened
                                          _nextFollowupDateValue =
                                              DateTime.now().add(
                                                const Duration(days: 1),
                                              );
                                          _nextFollowupDate = null;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.white,
                                        size: 6.w,
                                      ),
                                      label: Text(
                                        'Add New Follow Up',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.bottomNavBlue,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 2.5.h),
                                ] else ...[
                                  SizedBox(
                                    width: double.infinity,
                                    height: 7.h,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _showFollowupForm = false;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 6.w,
                                      ),
                                      label: Text(
                                        'Close Follow Up Form',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.bottomNavBlue,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 2.5.h),

                                  if (stages.isNotEmpty &&
                                      categories.isNotEmpty &&
                                      _selectedLeadStage != null)
                                    FollowupFormCard(
                                      calledDate: DateFormat(
                                        'dd-MM-yyyy hh:mm a',
                                      ).format(DateTime.now()),
                                      selectedCallStatus: _selectedCallStatus,
                                      onCallStatusChanged: (val) {
                                        setState(() {
                                          _selectedCallStatus = val;
                                        });
                                      },
                                      selectedLeadStage: _selectedLeadStage!,
                                      onLeadStageChanged: (val) {
                                        // setState(() {
                                        //   _selectedLeadStage =
                                        //       val ??
                                        //       (_isEditingFollowup
                                        //           ? stages.first
                                        //           : followupStages.first);
                                        //   if (_selectedLeadStage !=
                                        //       'FOLLOWUP') {
                                        //     _nextFollowupDateValue =
                                        //         DateTime.now()
                                        //             .add(
                                        //           const Duration(days: 1),
                                        //         );
                                        //     _nextFollowupDate = null;
                                        //   }
                                        // });
                                        setState(() {
                                          _selectedLeadStage =
                                              val ??
                                              (_isEditingFollowup
                                                  ? stages.first
                                                  : followupStages.first);
                                        });
                                      },
                                      leadStagesList: _isEditingFollowup
                                          ? stages
                                          : followupStages,
                                      selectedCategory: _selectedCategory,
                                      onCategoryChanged: (val) {
                                        setState(() {
                                          _selectedCategory =
                                              val ?? categories.first;
                                          // _leadTag = null;
                                        });
                                      },
                                      categoryList: categories,
                                      // selectedSubCategory: _selectedSubCategory,
                                      // subCategoryList:
                                      //     _subCategoriesMap[_selectedCategory] ??
                                      //     [],
                                      // onSubCategoryChanged: (val) {
                                      //   setState(() {
                                      //     _selectedSubCategory = val;
                                      //   });
                                      // },
                                      priorityList: _priorityList,
                                      onPriorityChanged: (val) {
                                        setState(() {
                                          _selectedPriority = val;
                                        });
                                      },
                                      remarksController: _remarksController,
                                      nextFollowupDate:
                                          _nextFollowupDate ??
                                          DateFormat(
                                            'dd-MM-yyyy hh:mm a',
                                          ).format(
                                            DateTime.now().add(
                                              const Duration(days: 1),
                                            ),
                                          ),
                                      onPickNextFollowupDate:
                                          _pickNextFollowupDate,
                                      selectedStaff: _selectedStaff,
                                      staffList: _staffList,
                                      onStaffChanged: (val) {
                                        setState(() {
                                          _selectedStaff = val;
                                        });
                                      },
                                      selectedPriority: _selectedPriority,
                                      whtsppController: _whatsaapCntrlr,
                                      addressController: _addressCntrlr,
                                      emailController: _emailCntrlr,
                                      selectedTag: _selectedTag,
                                      onTagChanged: (val) {
                                        setState(() {
                                          _selectedTag = val;
                                        });
                                      },
                                    )
                                  else if (state.status ==
                                      AddLeadStatus.loading)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 24,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  else
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 24,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Failed to load lead stages and categories. Please verify your connection or database setup.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),

                                  SizedBox(height: 2.5.h),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 7.h,
                                    child: ElevatedButton(
                                      onPressed: state.isSubmitting
                                          ? null
                                          : _submitFollowup,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppColors.bottomNavBlue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: state.isSubmitting
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              _isEditingFollowup
                                                  ? 'Update Followup'
                                                  : 'Submit',
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                  SizedBox(height: 2.5.h),
                                ],
                              ],
                            ),
                          ),
                          (() {
                            final rawFollowups = _leadData.followUp ?? [];

                            if (rawFollowups.isEmpty) {
                              final leadCreationHistory = LeadCreationHistory(
                                staffName: _leadData.assignedStaff.isNotEmpty
                                    ? _leadData.assignedStaff
                                    : _leadData.createdBy,
                                createdDate: _leadData.createdAt != null
                                    ? DateFormat(
                                        'dd-MM-yyyy hh:mm a',
                                      ).format(_leadData.createdAt!)
                                    : '',
                                remarks: _leadData.remarks.isNotEmpty
                                    ? _leadData.remarks
                                    : 'N/A',
                              );
                              return LeadCreationCard(
                                history: leadCreationHistory,
                              );
                            } else {
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: rawFollowups.length,
                                itemBuilder: (context, index) {
                                  final f = rawFollowups[index];
                                  final fNo = (rawFollowups.length - index) + 1;
                                  final DateTime? scheduledDate =
                                      (index < rawFollowups.length - 1)
                                      ? rawFollowups[index + 1].nextFollowUpDate
                                      : _leadData.createdAt;
                                  return FollowupHistoryCard(
                                    followup: f,
                                    followupNumber: fNo,
                                    scheduledDate: scheduledDate,
                                    canEditDelete: index == 0,
                                    onEdit: () async {
                                      await _loadLatestLead();
                                      setState(() {
                                        _isEditingFollowup = true;
                                        _editingFollowup = f;
                                        _showFollowupForm = true;
                                        _selectedCallStatus =
                                            f.calledStatus.isNotEmpty
                                            ? f.calledStatus
                                            : null;
                                        _selectedLeadStage =
                                            f.leadStage.isNotEmpty
                                            ? f.leadStage.toUpperCase()
                                            : null;
                                        _selectedCategory =
                                            f.leadCategory.isNotEmpty
                                            ? f.leadCategory.toUpperCase()
                                            : null;
                                        // _selectedSubCategory =
                                        //     f.leadTag.isNotEmpty
                                        //     ? f.leadTag
                                        //     : null;
                                        _selectedTag = f.leadTag.isNotEmpty
                                            ? f.leadTag
                                            : null;
                                        _remarksController.text = f.remarks;
                                        _whatsaapCntrlr.text = f.leadWhatsappNo;
                                        _addressCntrlr.text = f.adress;
                                        _emailCntrlr.text = f.email;
                                        _selectedStaff =
                                            f.assignedStaff.isNotEmpty
                                            ? f.assignedStaff
                                            : null;
                                        _selectedPriority =
                                            f.priority.isNotEmpty
                                            ? f.priority
                                            : 'Normal';

                                        // ✅ Pre-fill date from existing follow-up
                                        if (f.nextFollowUpDate != null) {
                                          _nextFollowupDateValue =
                                              f.nextFollowUpDate!;
                                          _nextFollowupDate = DateFormat(
                                            'dd-MM-yyyy hh:mm a',
                                          ).format(f.nextFollowUpDate!);
                                        }
                                      });
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            if (_scrollController.hasClients) {
                                              _scrollController.animateTo(
                                                0.0,
                                                duration: const Duration(
                                                  milliseconds: 500,
                                                ),
                                                curve: Curves.easeInOut,
                                              );
                                            }
                                          });
                                    },
                                    onDelete: () {
                                      if (f.id != null) {
                                        showDialog(
                                          context: context,
                                          builder: (dialogContext) => AlertDialog(
                                            backgroundColor: Colors.white,
                                            title: const Text(
                                              'Delete Follow-up',
                                            ),
                                            content: const Text(
                                              'Are you sure you want to delete this follow-up?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  dialogContext,
                                                ),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(dialogContext);
                                                  context
                                                      .read<AddLeadCubit>()
                                                      .deleteFollowUp(
                                                        leadId:
                                                            _leadData.id ?? '',
                                                        followUpId: f.id!,
                                                        changedByName: state
                                                            .assignedStaffName,
                                                        changedById:
                                                            state
                                                                .assignedStaffId ??
                                                            '',
                                                        leadName: _leadData
                                                            .clientName,
                                                        leadPhone: _leadData
                                                            .contactNumber,
                                                      )
                                                      .then((_) async {
                                                        context
                                                            .read<
                                                              AddLeadCubit
                                                            >()
                                                            .fetchLeads();
                                                        await _loadLatestLead();
                                                        setState(() {});
                                                      });
                                                },
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                  );
                                },
                              );
                            }
                          })(),
                        ] else if (_selectedTab == 'Activities') ...[
                          LeadActivitiesTab(lead: _leadData),
                        ] else if (_selectedTab == 'Details') ...[
                          LeadDetailsTab(lead: _leadData),
                        ] else ...[
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: Text(
                                'No $_selectedTab Logs Found',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF888888),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  //   void _shareLeadOnWhatsApp() {
  //   final name = _leadData.clientName;
  //   final contact = _leadData.contactNumber;

  //   final message = Uri.encodeComponent(
  //     'Lead Details\n'
  //     '━━━━━━━━━━━━━━━━\n'
  //     'Name    : $name\n'
  //     'Contact : $contact\n'
  //     '━━━━━━━━━━━━━━━━',
  //   );

  //   final uri = Uri.parse('whatsapp://send?text=$message');

  //   launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('WhatsApp is not installed on this device'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //     return false;
  //   });
  // }
  void _shareLeadOnWhatsApp() {
    final name = _leadData.clientName;
    final contact = _leadData.contactNumber;
    final leadId = _leadData.id ?? '';

    // Deep link — your app must handle this scheme
    final deepLink = 'oxdocrm://lead/$leadId';

    final message = Uri.encodeComponent(
      'Lead Details\n'
      '━━━━━━━━━━━━━━━━\n'
      'Name    : $name\n'
      'Contact : $contact\n'
      // 'Link    : $deepLink\n'
      '━━━━━━━━━━━━━━━━',
    );

    final uri = Uri.parse('whatsapp://send?text=$message');

    launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp is not installed on this device'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    });
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────

class _CustomLeadDetailsHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const _CustomLeadDetailsHeader();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Container(
        decoration: const BoxDecoration(color: AppColors.bottomNavBlue),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 8.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  SizedBox(width: 4.w),
                  Text(
                    'Lead Details',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: Colors.white, size: 20.sp),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(12.h);
}

// ─── Lead Summary Card ────────────────────────────────────────────────────────

class LeadSummaryCard extends StatelessWidget {
  final AddLeadModel lead;

  const LeadSummaryCard({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.clientName,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D2433),
                      ),
                    ),
                    if (lead.address.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_pin,
                            size: 15.sp,
                            color: Color(0xFF888888),
                          ),
                          Expanded(
                            child: Text(
                              lead.address,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF555555),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              StatusBadge(
                label: lead.leadStage=='FOLLOWUP'?'Follow Up':lead.leadStage,
                backgroundColor: getStatusColor(
                  lead.leadStage,
                ).withValues(alpha: 0.1),
                textColor: getStatusColor(lead.leadStage),
                border: Border.all(
                  color: getStatusColor(lead.leadStage).withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              StatusBadge(
                label: lead.leadCategory.isNotEmpty
                    ? lead.leadCategory
                    : 'Uncategorized',
                backgroundColor: const Color(0xFFFFEBEB),
                textColor: Colors.red,
              ),
              SizedBox(width: 4.w),
              Container(
                width: 2.w,
                height: 2.w,
                decoration: BoxDecoration(
                  color: getPriorityColor(lead.priority),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 1.5.w),
              Text(
                lead.priority,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF555555),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          const Divider(color: Color(0xFFE0E0E0), height: 1),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.phone_android,
                  value: lead.contactNumber,
                ),
              ),
              Expanded(
                child: _InfoTile(
                  icon: Icons.person_outline,
                  value: lead.assignedStaff,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.calendar_month,
                  value: lead.createdAt != null
                      ? DateFormat('dd/MM/yyyy').format(lead.createdAt!)
                      : '',
                ),
              ),
              Expanded(
                child: _InfoTile(
                  icon: Icons.folder_open,
                  value: lead.leadSource.isNotEmpty ? lead.leadSource : 'N/A',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String value;

  const _InfoTile({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF888888), size: 5.5.w),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF555555),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Lead Creation Card ───────────────────────────────────────────────────────

class LeadCreationHistory {
  final String staffName;
  final String createdDate;
  final String remarks;

  LeadCreationHistory({
    required this.staffName,
    required this.createdDate,
    required this.remarks,
  });
}

class LeadCreationCard extends StatelessWidget {
  final LeadCreationHistory history;

  const LeadCreationCard({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF9ED1FF), width: 1),
      ),
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.person,
                  color: const Color(0xFF888888),
                  size: 6.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  history.staffName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2433),
                  ),
                ),
              ),
              StatusBadge(
                label: 'New',
                backgroundColor: AppColors.bottomNavBlue,
                textColor: Colors.white,
              ),
              SizedBox(width: 1.5.w),
              Text(
                '( Pending )',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                color: AppColors.bottomNavBlue,
                size: 4.5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Created Date: ${history.createdDate}',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF555555),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          // Padding(
          //   padding: EdgeInsets.only(left: 6.5.w),
          //   child: Container(
          //     padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
          //     decoration: BoxDecoration(
          //       color: const Color(0xFFDDF5D8),
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     child: Text(
          //       'F.No : 1',
          //       style: TextStyle(
          //         fontSize: 12.sp,
          //         fontWeight: FontWeight.w600,
          //         color: const Color(0xFF2E7D32),
          //       ),
          //     ),
          //   ),
          // ),
          // SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.only(left: 6.5.w),
            child: Text(
              'Remarks:  ${history.remarks}',
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF555555),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
