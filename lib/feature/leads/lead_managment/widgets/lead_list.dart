// // import 'dart:developer';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:odit_crm_mobile/core/theme/app_colors.dart';
// // import 'package:odit_crm_mobile/feature/home/search_screen.dart';
// // import 'package:odit_crm_mobile/feature/leads/lead_managment/screens/add_lead.dart';
// // import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_cubit.dart';
// // import 'package:odit_crm_mobile/feature/leads/lead_managment/screens/filtering.dart';
// // import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_state.dart';
// // import 'package:odit_crm_mobile/feature/leads/lead_managment/models/lead_data.dart';
// // import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/status_card.dart';
// // import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/section_header.dart';
// // import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/lead_list_widget.dart';
// // import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/report_section.dart';
// // import 'package:sizer/sizer.dart';
// // export 'package:odit_crm_mobile/feature/leads/lead_managment/models/lead_data.dart';

// // // ─────────────────────────────────────────────────────────────────────────────
// // // Data class for Followup grouping (Followup tab display structure)
// // // ─────────────────────────────────────────────────────────────────────────────
// // class FollowupGroups {
// //   /// leadStage == FOLLOWUP  &&  followUpDate inside the active date window.
// //   final List<LeadData> todaysFollowups;

// //   /// (leadStage == FOLLOWUP)  &&  followUpDate before the active date window start.
// //   final List<LeadData> pendingFollowups;

// //   /// leadStage == NEW  &&  createdAt inside the active date window.
// //   final List<LeadData> newLeads;

// //   const FollowupGroups({
// //     required this.todaysFollowups,
// //     required this.pendingFollowups,
// //     required this.newLeads,
// //   });

// //   /// All leads combined in display order: today's followups → pending → today's new
// //   List<LeadData> get all => [...todaysFollowups, ...pendingFollowups, ...newLeads];

// //   int get totalCount => todaysFollowups.length + pendingFollowups.length + newLeads.length;
// // }

// // // ─────────────────────────────────────────────────────────────────────────────
// // // LeadListScreen
// // // ─────────────────────────────────────────────────────────────────────────────
// // class LeadListScreen extends StatefulWidget {
// //   final int selectedTab;

// //   const LeadListScreen({super.key, required this.selectedTab});

// //   @override
// //   State<LeadListScreen> createState() => _LeadListScreenState();
// // }

// // class _LeadListScreenState extends State<LeadListScreen> {
// //   // ── UI state ──────────────────────────────────────────────────────────────
// //   bool _isReportView = false;
// //   String _selectedStatus = 'New';
// //   bool _sortByNewest = true;
// //   bool _isFirstLoad = true;

// //   // ── Filter state ───────────────────────────────────────────────────────────
// //   FilterResult? _appliedFilters;

// //   // ── Swipe / expand state ───────────────────────────────────────────────────
// //   List<ValueNotifier<bool>> _closeNotifiers = [];
// //   final Set<String> _expandedLeadPhones = {};

// //   // ── Lifecycle ─────────────────────────────────────────────────────────────
// //   @override
// //   void initState() {
// //     super.initState();
// //     log('[LeadListScreen] initState() called');
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (mounted) {
// //         log('[LeadListScreen] fetchLeads() on init');
// //         context.read<AddLeadCubit>().fetchLeads();
// //       }
// //     });
// //   }

// //   @override
// //   void dispose() {
// //     for (final n in _closeNotifiers) {
// //       n.dispose();
// //     }
// //     super.dispose();
// //   }

// //   // ══════════════════════════════════════════════════════════════════════════
// //   // ① COMMON DATE HELPER (Single Source of Truth)
// //   // ══════════════════════════════════════════════════════════════════════════

// //   /// Returns true when [date] falls within the active date window.
// //   /// • No filter → window is today midnight-to-midnight.
// //   /// • Filter active → window is [fromDate…toDate] both inclusive, full days.
// //   bool _isInSelectedDateRange(DateTime date) {
// //     final startOfWindow = _activeWindowStart();
// //     final endOfWindow = _activeWindowEnd();
// //     return !date.isBefore(startOfWindow) && !date.isAfter(endOfWindow);
// //   }

// //   /// Start boundary of the active date window (start of today or fromDate).
// //   DateTime _activeWindowStart() {
// //     if (_appliedFilters == null) {
// //       // No filter — start of today
// //       final now = DateTime.now();
// //       return DateTime(now.year, now.month, now.day);
// //     }
// //     final start = _parseDate(_appliedFilters!.fromDate);
// //     if (start == null) {
// //       final now = DateTime.now();
// //       return DateTime(now.year, now.month, now.day);
// //     }
// //     return DateTime(start.year, start.month, start.day);
// //   }

// //   /// End boundary of the active date window (end of today or toDate).
// //   DateTime _activeWindowEnd() {
// //     if (_appliedFilters == null) {
// //       // No filter — end of today
// //       final now = DateTime.now();
// //       return DateTime(now.year, now.month, now.day, 23, 59, 59);
// //     }
// //     final end = _parseDate(_appliedFilters!.toDate);
// //     if (end == null) {
// //       final now = DateTime.now();
// //       return DateTime(now.year, now.month, now.day, 23, 59, 59);
// //     }
// //     return DateTime(end.year, end.month, end.day, 23, 59, 59);
// //   }

// //   // ══════════════════════════════════════════════════════════════════════════
// //   // ② MAPPING ── raw Firestore model → LeadData
// //   // ══════════════════════════════════════════════════════════════════════════

// //   List<LeadData> _mapLeads(List<dynamic> firestoreLeads) {
// //     return firestoreLeads.map((lead) {
// //       return LeadData(
// //         id: lead.id ?? '',
// //         name: lead.clientName.isEmpty ? 'Unknown' : lead.clientName,
// //         phone: lead.contactNumber,
// //         assignedTo: lead.assignedStaff,
// //         category: lead.leadCategory.isEmpty ? 'Uncategorized' : lead.leadCategory,
// //         status: lead.leadStage,
// //         notificationCount: 0,
// //         isExpanded: _expandedLeadPhones.contains(lead.contactNumber),
// //         source: lead.leadSource,
// //         priority: lead.priority,
// //         createdAt: lead.createdAt,
// //       );
// //     }).toList();
// //   }

// //   // ══════════════════════════════════════════════════════════════════════════
// //   // ③ SECONDARY FILTERS (staff, category, priority — not date range)
// //   // ══════════════════════════════════════════════════════════════════════════

// //   bool _passesSecondaryFilters(LeadData lead) {
// //     if (_appliedFilters == null) return true;

// //     // Assigned Staff
// //     final selectedStaff = _appliedFilters!.selectedItems['Assigned Staff'];
// //     if (selectedStaff != null && selectedStaff.isNotEmpty) {
// //       if (!selectedStaff.any((s) => lead.assignedTo.toLowerCase() == s.toLowerCase())) {
// //         return false;
// //       }
// //     }

// //     // Category
// //     final selectedCategory = _appliedFilters!.selectedItems['Category'];
// //     if (selectedCategory != null && selectedCategory.isNotEmpty) {
// //       if (!selectedCategory.any((c) => lead.category.toLowerCase() == c.toLowerCase())) {
// //         return false;
// //       }
// //     }

// //     // Priority
// //     final selectedPriority = _appliedFilters!.selectedItems['Priority'];
// //     if (selectedPriority != null && selectedPriority.isNotEmpty) {
// //       if (!selectedPriority.any((p) => lead.priority.toLowerCase() == p.toLowerCase())) {
// //         return false;
// //       }
// //     }

// //     return true;
// //   }

// //   // ══════════════════════════════════════════════════════════════════════════
// //   // ④ STATUS PREDICATES (each uses _isInSelectedDateRange or related helpers)
// //   // ══════════════════════════════════════════════════════════════════════════

// //   // ── NEW ────────────────────────────────────────────────────────────────────
// //   /// leadStage == 'NEW'  &&  createdAt inside active date window.
// //   bool _isNewLead(LeadData lead) {
// //     if (lead.status.toUpperCase() != 'NEW') return false;
// //     if (lead.createdAt == null) return false;
// //     return _isInSelectedDateRange(lead.createdAt!);
// //   }

// //   // ── CALLED ────────────────────────────────────────────────────────────────
// //   /// Latest followup call date is inside the active date window.
// //   bool _isCalledInWindow(LeadData lead, List<dynamic> rawLeads) {
// //     final original = _findRaw(lead.id, rawLeads);
// //     if (original == null) return false;

// //     final followups = original.followUp;
// //     if (followups == null || followups.isEmpty) return false;

// //     // Find latest followup by calledDate
// //     dynamic latest;
// //     for (final f in followups) {
// //       if (latest == null || f.calledDate.isAfter(latest.calledDate)) {
// //         latest = f;
// //       }
// //     }
// //     if (latest == null) return false;

// //     return _isInSelectedDateRange(latest.calledDate as DateTime);
// //   }

// //   // ── MISSED ────────────────────────────────────────────────────────────────
// //   /// Missed leads: (leadStage == FOLLOWUP OR NEW)  &&  date is before window start.
// //   bool _isMissedLead(LeadData lead, List<dynamic> rawLeads) {
// //     final original = _findRaw(lead.id, rawLeads);
// //     if (original == null) return false;

// //     final stage = original.leadStage.toString().toUpperCase();
// //     final windowStart = _activeWindowStart();

// //     // ── For NEW leads: createdAt before window start ──────────────────────
// //     if (stage == 'NEW') {
// //       if (lead.createdAt == null) return false;
// //       return lead.createdAt!.isBefore(windowStart);
// //     }

// //     // ── For FOLLOWUP leads: followUpDate before window start ────────────────
// //     if (stage == 'FOLLOWUP') {
// //       final followUpDate = original.followUpDate as DateTime?;
// //       if (followUpDate == null) return false;
// //       return followUpDate.isBefore(windowStart);
// //     }

// //     return false;
// //   }

// //   // ══════════════════════════════════════════════════════════════════════════
// //   // ⑤ FOLLOWUP GROUPING (for Followup tab only)
// //   // ══════════════════════════════════════════════════════════════════════════

// //   FollowupGroups _buildFollowupGroups(
// //     List<LeadData> mappedLeads,
// //     List<dynamic> rawLeads,
// //   ) {
// //     final todaysFollowups = <LeadData>[];
// //     final pendingFollowups = <LeadData>[];
// //     final newLeads = <LeadData>[];

// //     for (final lead in mappedLeads) {
// //       if (!_passesSecondaryFilters(lead)) continue;

// //       final original = _findRaw(lead.id, rawLeads);
// //       if (original == null) continue;

// //       final stage = original.leadStage.toString().toUpperCase();
// //       final followUpDate = original.followUpDate as DateTime?;
// //       final windowStart = _activeWindowStart();

// //       // ── Group 1: FOLLOWUP  &&  followUpDate in window ─────────────────────
// //       if (stage == 'FOLLOWUP' &&
// //           followUpDate != null &&
// //           _isInSelectedDateRange(followUpDate)) {
// //         todaysFollowups.add(lead);
// //         continue;
// //       }

// //       // ── Group 2: FOLLOWUP  &&  followUpDate before window start ───────────
// //       if (stage == 'FOLLOWUP' &&
// //           followUpDate != null &&
// //           followUpDate.isBefore(windowStart)) {
// //         pendingFollowups.add(lead);
// //         continue;
// //       }

// //     }

// //     // ── Sort Group 1: nearest followup time first ───────────────────────────
// //     todaysFollowups.sort((a, b) {
// //       final aRaw = _findRaw(a.id, rawLeads);
// //       final bRaw = _findRaw(b.id, rawLeads);
// //       final aDate = aRaw?.followUpDate as DateTime?;
// //       final bDate = bRaw?.followUpDate as DateTime?;
// //       if (aDate == null) return 1;
// //       if (bDate == null) return -1;
// //       return aDate.compareTo(bDate);
// //     });

// //     // ── Sort Group 2: most overdue first (oldest first) ─────────────────────
// //     pendingFollowups.sort((a, b) {
// //       final aRaw = _findRaw(a.id, rawLeads);
// //       final bRaw = _findRaw(b.id, rawLeads);
// //       final aDate = aRaw?.followUpDate as DateTime?;
// //       final bDate = bRaw?.followUpDate as DateTime?;
// //       if (aDate == null) return 1;
// //       if (bDate == null) return -1;
// //       return aDate.compareTo(bDate); // oldest first
// //     });

// //     return FollowupGroups(
// //       todaysFollowups: todaysFollowups,
// //       pendingFollowups: pendingFollowups,
// //       newLeads: newLeads,
// //     );
// //   }

// //   // ══════════════════════════════════════════════════════════════════════════
// //   // ⑥ UNIFIED FILTERED LIST (used for both list view and counts)
// //   // ══════════════════════════════════════════════════════════════════════════

// //   List<LeadData> _getFilteredLeads(
// //     List<LeadData> mappedLeads,
// //     List<dynamic> rawLeads,
// //   ) {
// //     switch (_selectedStatus) {
// //       case 'New':
// //         return mappedLeads
// //             .where((l) => _passesSecondaryFilters(l) && _isNewLead(l))
// //             .toList();

// //       case 'Followup':
// //         return _buildFollowupGroups(mappedLeads, rawLeads).all;

// //       case 'Called':
// //         return mappedLeads
// //             .where((l) => _passesSecondaryFilters(l) && _isCalledInWindow(l, rawLeads))
// //             .toList();

// //       case 'Missed':
// //         return mappedLeads
// //             .where((l) => _passesSecondaryFilters(l) && _isMissedLead(l, rawLeads))
// //             .toList();

// //       case 'Transferred':
// //         return mappedLeads
// //             .where((l) =>
// //                 _passesSecondaryFilters(l) &&
// //                 l.status.toUpperCase() == 'TRANSFERRED')
// //             .toList();

// //       case 'Closed':
// //         return mappedLeads
// //             .where((l) =>
// //                 _passesSecondaryFilters(l) &&
// //                 l.status.toUpperCase() == 'CLOSED')
// //             .toList();

// //       default:
// //         return mappedLeads.where(_passesSecondaryFilters).toList();
// //     }
// //   }

// //   // ══════════════════════════════════════════════════════════════════════════
// //   // ⑦ STATUS CARD COUNTS (uses same predicates as the list)
// //   // ══════════════════════════════════════════════════════════════════════════

// //   Map<String, int> _buildStatusCounts(
// //     List<LeadData> mappedLeads,
// //     List<dynamic> rawLeads,
// //   ) {
// //     // Start with secondary-filtered candidates
// //     final candidates = mappedLeads.where(_passesSecondaryFilters).toList();

// //     return {
// //       'New': candidates.where(_isNewLead).length,
// //       'Followup': _buildFollowupGroups(mappedLeads, rawLeads).totalCount,
// //       'Called': candidates
// //           .where((l) => _isCalledInWindow(l, rawLeads))
// //           .length,
// //       'Missed': candidates
// //           .where((l) => _isMissedLead(l, rawLeads))
// //           .length,
// //       'Transferred': candidates
// //           .where((l) => l.status.toUpperCase() == 'TRANSFERRED')
// //           .length,
// //       'Closed': candidates
// //           .where((l) => l.status.toUpperCase() == 'CLOSED')
// //           .length,
// //     };
// //   }

// //   // ══════════════════════════════════════════════════════════════════════════
// //   // ⑧ SORTING (applied after filtering, except Followup uses group order)
// //   // ══════════════════════════════════════════════════════════════════════════

// //   List<LeadData> _applySorting(List<LeadData> leads) {
// //     // Followup tab preserves the internal group order set in _buildFollowupGroups.
// //     if (_selectedStatus == 'Followup') return leads;

// //     final sorted = List<LeadData>.from(leads);
// //     sorted.sort((a, b) {
// //       if (a.createdAt == null) return 1;
// //       if (b.createdAt == null) return -1;
// //       return _sortByNewest
// //           ? b.createdAt!.compareTo(a.createdAt!)
// //           : a.createdAt!.compareTo(b.createdAt!);
// //     });
// //     return sorted;
// //   }

// //   // ══════════════════════════════════════════════════════════════════════════
// //   // HELPERS
// //   // ══════════════════════════════════════════════════════════════════════════

// //   dynamic _findRaw(String id, List<dynamic> rawLeads) {
// //     for (final e in rawLeads) {
// //       if (e != null && e.id == id) return e;
// //     }
// //     return null;
// //   }

// //   DateTime? _parseDate(String dateStr) {
// //     try {
// //       final parts = dateStr.split('-');
// //       if (parts.length == 3) {
// //         return DateTime(
// //           int.parse(parts[2]),
// //           int.parse(parts[1]),
// //           int.parse(parts[0]),
// //         );
// //       }
// //     } catch (_) {}
// //     return null;
// //   }

// //   String _getTodayString() {
// //     final d = DateTime.now();
// //     return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
// //   }

// //   bool get _isFilterActive {
// //     if (_appliedFilters == null) return false;
// //     final todayStr = _getTodayString();
// //     if (_appliedFilters!.fromDate != todayStr || _appliedFilters!.toDate != todayStr) {
// //       return true;
// //     }
// //     return _appliedFilters!.selectedItems.values.any((v) => v.isNotEmpty);
// //   }

// //   void _syncCloseNotifiers(int length) {
// //     if (_closeNotifiers.length != length) {
// //       for (final n in _closeNotifiers) n.dispose();
// //       _closeNotifiers = List.generate(length, (_) => ValueNotifier(false));
// //     }
// //   }

// //   bool _getAreAllExpanded(List<LeadData> leads) =>
// //       leads.isNotEmpty && leads.every((l) => l.isExpanded);

// //   void _toggleAllExpanded(List<LeadData> leads) {
// //     final expand = !_getAreAllExpanded(leads);
// //     setState(() {
// //       for (final lead in leads) {
// //         if (expand) {
// //           _expandedLeadPhones.add(lead.phone);
// //         } else {
// //           _expandedLeadPhones.remove(lead.phone);
// //         }
// //       }
// //     });
// //   }

// //   List<ValueNotifier<bool>> _getFilteredCloseNotifiers(
// //     List<LeadData> allLeads,
// //     List<LeadData> filteredLeads,
// //   ) {
// //     return filteredLeads
// //         .map((lead) => _closeNotifiers[allLeads.indexOf(lead)])
// //         .toList();
// //   }

// //   // ══════════════════════════════════════════════════════════════════════════
// //   // BUILD
// //   // ══════════════════════════════════════════════════════════════════════════

// //   @override
// //   Widget build(BuildContext context) {
// //     log('[LeadListScreen] build() triggered');

// //     return BlocBuilder<AddLeadCubit, AddLeadState>(
// //       builder: (context, state) {
// //         if (state.listStatus == LeadListStatus.loading) {
// //           return const Scaffold(
// //             body: Center(child: CircularProgressIndicator()),
// //           );
// //         }

// //         // Auto-expand all leads on first load
// //         if (_isFirstLoad && state.leads.isNotEmpty) {
// //           for (final lead in state.leads) {
// //             _expandedLeadPhones.add(lead.contactNumber);
// //           }
// //           _isFirstLoad = false;
// //         }

// //         final mappedLeads = _mapLeads(state.leads);
// //         _syncCloseNotifiers(mappedLeads.length);

// //         // ── Filtered + sorted list for the active status tab ──────────────────
// //         final filteredLeads = _applySorting(
// //           _getFilteredLeads(mappedLeads, state.leads),
// //         );

// //         final filteredCloseNotifiers = _getFilteredCloseNotifiers(
// //           mappedLeads,
// //           filteredLeads,
// //         );

// //         // ── Status card counts ────────────────────────────────────────────────
// //         final statusCounts = _buildStatusCounts(mappedLeads, state.leads);

// //         final updatedStatusCards = statusCards.map((card) {
// //           return card.copyWith(count: statusCounts[card.label] ?? 0);
// //         }).toList();

// //         return RefreshIndicator(
// //           onRefresh: () => context.read<AddLeadCubit>().fetchLeads(),
// //           child: Container(
// //             color: const Color(0xFFF3F4F6),
// //             child: CustomScrollView(
// //               physics: const BouncingScrollPhysics(
// //                 parent: AlwaysScrollableScrollPhysics(),
// //               ),
// //               slivers: [
// //                 // ── Static top section ──────────────────────────────────────
// //                 SliverToBoxAdapter(
// //                   child: Padding(
// //                     padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 0),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             Text(
// //                               'Lead Status',
// //                               style: TextStyle(
// //                                 fontSize: 17.sp,
// //                                 fontWeight: FontWeight.w700,
// //                                 color: const Color(0xFF111827),
// //                                 letterSpacing: -0.3,
// //                               ),
// //                             ),
// //                             GestureDetector(
// //                               onTap: () =>
// //                                   context.read<AddLeadCubit>().fetchLeads(),
// //                               child: Container(
// //                                 width: 9.w,
// //                                 height: 4.5.h,
// //                                 decoration: BoxDecoration(
// //                                   color: Colors.white,
// //                                   borderRadius: BorderRadius.circular(2.5.w),
// //                                   boxShadow: [
// //                                     BoxShadow(
// //                                       color: Colors.black.withValues(alpha: 0.06),
// //                                       blurRadius: 8,
// //                                       offset: const Offset(0, 2),
// //                                     ),
// //                                   ],
// //                                 ),
// //                                 child: Icon(
// //                                   Icons.sync_rounded,
// //                                   size: 4.5.w,
// //                                   color: const Color(0xFF6B7280),
// //                                 ),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                         SizedBox(height: 1.8.h),

// //                         // Status cards grid
// //                         GridView.builder(
// //                           shrinkWrap: true,
// //                           physics: const NeverScrollableScrollPhysics(),
// //                           itemCount: updatedStatusCards.length,
// //                           gridDelegate:
// //                               SliverGridDelegateWithFixedCrossAxisCount(
// //                                 crossAxisCount: 3,
// //                                 crossAxisSpacing: 2.w,
// //                                 mainAxisSpacing: 2.w,
// //                                 childAspectRatio: 0.88,
// //                               ),
// //                           itemBuilder: (context, index) => StatusCard(
// //                             data: updatedStatusCards[index],
// //                             isSelected: _selectedStatus == updatedStatusCards[index].label,
// //                             onTap: () => setState(
// //                               () => _selectedStatus = updatedStatusCards[index].label,
// //                             ),
// //                           ),
// //                         ),
// //                         SizedBox(height: 2.h),

// //                         SectionHeader(
// //                           title: 'Leads',
// //                           subtitle: '${filteredLeads.length} Leads',
// //                           isReportActive: _isReportView,
// //                           areAllExpanded: _getAreAllExpanded(mappedLeads),
// //                           isFilterActive: _isFilterActive,
// //                           sortIcon: _sortByNewest
// //                               ? Icons.arrow_downward_rounded
// //                               : Icons.arrow_upward_rounded,
// //                           sortBgColor: _sortByNewest
// //                               ? const Color(0xFFF3F4F6)
// //                               : AppColors.bottomNavBlue,
// //                           sortIconColor: _sortByNewest
// //                               ? const Color(0xFF6B7280)
// //                               : Colors.white,
// //                           onAdd: () async {
// //                             await Navigator.push(
// //                               context,
// //                               MaterialPageRoute(
// //                                 builder: (_) => CreateLeadScreen(),
// //                               ),
// //                             );
// //                             if (context.mounted) {
// //                               context.read<AddLeadCubit>().fetchLeads();
// //                             }
// //                           },
// //                           onChart: () => setState(() => _isReportView = !_isReportView),
// //                           onFilter: () async {
// //                             final result = await showFilterBottomSheet(
// //                               context,
// //                               initialFilters: _appliedFilters,
// //                             );
// //                             if (result != null) {
// //                               setState(() {
// //                                 final todayStr = _getTodayString();
// //                                 final hasActiveDate =
// //                                     result.fromDate != todayStr ||
// //                                     result.toDate != todayStr;
// //                                 final hasActiveCheckbox = result
// //                                     .selectedItems.values
// //                                     .any((s) => s.isNotEmpty);

// //                                 _appliedFilters =
// //                                     (hasActiveDate || hasActiveCheckbox)
// //                                     ? result
// //                                     : null;
// //                               });
// //                             }
// //                           },
// //                           onSearch: () {
// //                             Navigator.push(
// //                               context,
// //                               MaterialPageRoute(
// //                                 builder: (_) => BlocProvider.value(
// //                                   value: context.read<AddLeadCubit>(),
// //                                   child: const SearchScreen(),
// //                                 ),
// //                               ),
// //                             );
// //                           },
// //                           onDownload: () {
// //                             setState(() => _sortByNewest = !_sortByNewest);
// //                           },
// //                           onmenu: () => _toggleAllExpanded(mappedLeads),
// //                         ),
// //                         SizedBox(height: 1.5.h),
// //                       ],
// //                     ),
// //                   ),
// //                 ),

// //                 // ── Animated list / report section ──────────────────────────
// //                 SliverToBoxAdapter(
// //                   child: AnimatedSwitcher(
// //                     duration: const Duration(milliseconds: 300),
// //                     switchInCurve: Curves.easeOut,
// //                     switchOutCurve: Curves.easeIn,
// //                     transitionBuilder: (child, animation) => FadeTransition(
// //                       opacity: animation,
// //                       child: SlideTransition(
// //                         position: Tween<Offset>(
// //                           begin: const Offset(0, 0.04),
// //                           end: Offset.zero,
// //                         ).animate(animation),
// //                         child: child,
// //                       ),
// //                     ),
// //                     child: _isReportView
// //                         ? Padding(
// //                             padding: EdgeInsets.only(bottom: 16.w),
// //                             child: ReportSection(
// //                               key: const ValueKey('report'),
// //                               leads: filteredLeads,
// //                               selectedStatus: _selectedStatus,
// //                             ),
// //                           )
// //                         : Padding(
// //                             padding: EdgeInsets.only(bottom: 13.w),
// //                             child: LeadListWidget(
// //                               key: const ValueKey('leads'),
// //                               leads: filteredLeads,
// //                               closeNotifiers: filteredCloseNotifiers,
// //                               onToggleExpand: (index) {
// //                                 final lead = filteredLeads[index];
// //                                 setState(() {
// //                                   if (_expandedLeadPhones.contains(lead.phone)) {
// //                                     _expandedLeadPhones.remove(lead.phone);
// //                                   } else {
// //                                     _expandedLeadPhones.add(lead.phone);
// //                                   }
// //                                 });
// //                               },
// //                               onSwipeOpen: (index) {
// //                                 for (int i = 0; i < _closeNotifiers.length; i++) {
// //                                   if (i != index) {
// //                                     _closeNotifiers[i].value = true;
// //                                     Future.microtask(
// //                                       () => _closeNotifiers[i].value = false,
// //                                     );
// //                                   }
// //                                 }
// //                               },
// //                             ),
// //                           ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }

// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:odit_crm_mobile/core/theme/app_colors.dart';
// import 'package:odit_crm_mobile/feature/home/search_screen.dart';
// import 'package:odit_crm_mobile/feature/leads/lead_managment/screens/add_lead.dart';
// import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_cubit.dart';
// import 'package:odit_crm_mobile/feature/leads/lead_managment/screens/filtering.dart';
// import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_state.dart';
// import 'package:odit_crm_mobile/feature/leads/lead_managment/models/lead_data.dart';
// import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/status_card.dart';
// import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/section_header.dart';
// import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/lead_list_widget.dart';
// import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/report_section.dart';
// import 'package:sizer/sizer.dart';
// export 'package:odit_crm_mobile/feature/leads/lead_managment/models/lead_data.dart';

// class LeadListScreen extends StatefulWidget {
//   final int selectedTab;
//   final String? initialStatus;
//   const LeadListScreen({super.key, required this.selectedTab, this.initialStatus='New'});

//   @override
//   State<LeadListScreen> createState() => _LeadListScreenState();
// }

// class _LeadListScreenState extends State<LeadListScreen> {
//   @override
//   void initState() {
//     super.initState();
//      _selectedStatus = widget.initialStatus!;

//     log('[LeadListScreen] initState() called');
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         log(
//           '[LeadListScreen] Automatically calling fetchLeads() during screen initialization',
//         );
//         context.read<AddLeadCubit>().fetchLeads();
//       }
//     });
//   }

//   // ── Report toggle ─────────────────────────────────────────────────────────
//   bool _isReportView = false;

//   // ── Close notifiers for swipe cards ──────────────────────────────────────
//   List<ValueNotifier<bool>> _closeNotifiers = [];

//   // ── Selected status filter ────────────────────────────────────────────────

//  late String _selectedStatus ;

//   // ── Applied filters ───────────────────────────────────────────────────────
//   FilterResult? _appliedFilters;

//   // ── Expanded lead phones ──────────────────────────────────────────────────
//   final Set<String> _expandedLeadPhones = {};
//   bool _isFirstLoad = true;
//   bool _sortByNewest = true;

//   void _syncCloseNotifiers(int length) {
//     if (_closeNotifiers.length != length) {
//       for (final n in _closeNotifiers) {
//         n.dispose();
//       }
//       _closeNotifiers = List.generate(length, (_) => ValueNotifier(false));
//     }
//   }

//   List<LeadData> _getTodayLeads(List<LeadData> leads) {
//     final now = DateTime.now();
//     final startOfToday = DateTime(now.year, now.month, now.day);

//     return leads.where((lead) {
//       if (lead.createdAt == null) return false;
//       final date = lead.createdAt!;
//       return date.year == now.year &&
//           date.month == now.month &&
//           date.day == now.day;
//     }).toList();
//   }

//   /// Checks if a date falls within the active filter window.
//   /// No filter = today only | Filter active = fromDate…toDate
//   bool _isDateInWindow(DateTime date) {
//     if (_appliedFilters == null) {
//       // No filter: check if date is today
//       final now = DateTime.now();
//       return date.year == now.year &&
//           date.month == now.month &&
//           date.day == now.day;
//     }

//     // Filter active: check if date is within fromDate…toDate
//     final start = _parseDate(_appliedFilters!.fromDate);
//     final end = _parseDate(_appliedFilters!.toDate);
//     if (start == null || end == null) return true;

//     final startOfDay = DateTime(start.year, start.month, start.day);
//     final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
//     return !date.isBefore(startOfDay) && !date.isAfter(endOfDay);
//   }

//   /// Get the start of the active filter window (for "before window" comparisons).
//   DateTime _getWindowStart() {
//     if (_appliedFilters == null) {
//       final now = DateTime.now();
//       return DateTime(now.year, now.month, now.day);
//     }
//     final start = _parseDate(_appliedFilters!.fromDate);
//     if (start == null) {
//       final now = DateTime.now();
//       return DateTime(now.year, now.month, now.day);
//     }
//     return DateTime(start.year, start.month, start.day);
//   }

//   bool _isMissedLead(LeadData lead, List<dynamic> rawLeads) {
//     dynamic original;
//     for (final e in rawLeads) {
//       if (e != null && e.id == lead.id) {
//         original = e;
//         break;
//       }
//     }
//     if (original == null) return false;

//     final stage = original.leadStage.toString().toUpperCase();
//     final windowStart = _getWindowStart();

//     // NEW leads: missed if createdAt is before window start
//     if (stage == 'NEW') {
//       if (lead.createdAt == null) return false;
//       return lead.createdAt!.isBefore(windowStart);
//     }

//     // FOLLOWUP leads: missed if followUpDate is before window start
//     if (stage == 'FOLLOWUP') {
//       final followUpDate = original.followUpDate;
//       if (followUpDate == null) return false;
//       return (followUpDate as DateTime).isBefore(windowStart);
//     }
// if(stage=='TRANSFFERRED'){
//   return (original.followUpDate as DateTime).isBefore(windowStart);
// }
//     return false;
//   }

//   bool _isCalledToday(LeadData lead, List<dynamic> rawLeads) {
//     dynamic original;
//     for (final e in rawLeads) {
//       if (e != null && e.id == lead.id) {
//         original = e;
//         break;
//       }
//     }
//     if (original == null) return false;

//     final followups = original.followUp;
//     if (followups == null || followups.isEmpty) return false;

//     dynamic latestFollowup;
//     for (final f in followups) {
//       if (latestFollowup == null) {
//         latestFollowup = f;
//       } else if (f.calledDate.isAfter(latestFollowup.calledDate)) {
//         latestFollowup = f;
//       }
//     }
//     if (latestFollowup == null) return false;

//     // Check if the latest call date is in the active window
//     return _isDateInWindow(latestFollowup.calledDate as DateTime);
//   }

//   bool _isFollowupToday(dynamic lead) {
//     if (lead.leadStage.toUpperCase() != 'FOLLOWUP') {
//       return false;
//     }

//     final followupDate = lead.followUpDate;
//     if (followupDate == null) return false;

//     // Check if followupDate is in the active window
//     return _isDateInWindow(followupDate as DateTime);
//   }

//   bool _isFollowupPending(dynamic lead) {
//     if (lead.leadStage.toUpperCase() != 'FOLLOWUP') {
//       return false;
//     }

//     final followupDate = lead.followUpDate;
//     if (followupDate == null) return false;

//     // Pending if followupDate is before the window start
//     return (followupDate as DateTime).isBefore(_getWindowStart());
//   }

//   bool _isNewLeadInWindow(LeadData lead) {
//     if (lead.status.toUpperCase() != 'NEW') return false;
//     if (lead.createdAt == null) return false;
//     return _isDateInWindow(lead.createdAt!);
//   }

//   String _getTodayString() {
//     final d = DateTime.now();
//     return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
//   }

//   List<LeadData> _mapLeads(List<dynamic> firestoreLeads) {
//     return firestoreLeads.map((lead) {
//       return LeadData(
//         id: lead.id ?? '',
//         name: lead.clientName.isEmpty ? 'Unknown' : lead.clientName,
//         phone: lead.contactNumber,
//         assignedTo: lead.assignedStaff,
//         category: lead.leadCategory.isEmpty
//             ? 'Uncategorized'
//             : lead.leadCategory,
//         status: lead.leadStage,
//         notificationCount: 0,
//         isExpanded: _expandedLeadPhones.contains(lead.contactNumber),
//         source: lead.leadSource,
//         priority: lead.priority,
//         createdAt: lead.createdAt,
//       );
//     }).toList();
//   }

//   bool _passesSecondaryFilters(LeadData lead) {
//     if (_appliedFilters == null) return true;

//     // Assigned Staff
//     final selectedStaff = _appliedFilters!.selectedItems['Assigned Staff'];
//     if (selectedStaff != null && selectedStaff.isNotEmpty) {
//       if (!selectedStaff.any(
//         (s) => lead.assignedTo.toLowerCase() == s.toLowerCase(),
//       )) {
//         return false;
//       }
//     }

//     // Category
//     final selectedCategory = _appliedFilters!.selectedItems['Category'];
//     if (selectedCategory != null && selectedCategory.isNotEmpty) {
//       if (!selectedCategory.any(
//         (c) => lead.category.toLowerCase() == c.toLowerCase(),
//       )) {
//         return false;
//       }
//     }

//     // Priority
//     final selectedPriority = _appliedFilters!.selectedItems['Priority'];
//     if (selectedPriority != null && selectedPriority.isNotEmpty) {
//       if (!selectedPriority.any(
//         (p) => lead.priority.toLowerCase() == p.toLowerCase(),
//       )) {
//         return false;
//       }
//     }

//     return true;
//   }

//   DateTime? _parseDate(String dateStr) {
//     try {
//       final parts = dateStr.split('-');
//       if (parts.length == 3) {
//         return DateTime(
//           int.parse(parts[2]),
//           int.parse(parts[1]),
//           int.parse(parts[0]),
//         );
//       }
//     } catch (_) {}
//     return null;
//   }

//   List<LeadData> _getFilteredLeads(
//     List<LeadData> allLeads,
//     List<dynamic> rawLeads,
//   ) {
//     final filteredByOther = allLeads.where(_passesSecondaryFilters).toList();

//     switch (_selectedStatus) {
//       case 'New':
//         return filteredByOther.where((e) => _isNewLeadInWindow(e)).toList();

//       case 'Followup':
//         // Group 1: Today's followups
//         final todaysFollowups = <LeadData>[];
//         for (final lead in filteredByOther) {
//           dynamic original;
//           for (final l in rawLeads) {
//             if (l != null && l.id == lead.id) {
//               original = l;
//               break;
//             }
//           }
//           if (original != null && _isFollowupToday(original)) {
//             todaysFollowups.add(lead);
//           }
//         }

//         // Sort Group 1: nearest followup time first
//         todaysFollowups.sort((a, b) {
//           dynamic aRaw, bRaw;
//           for (final l in rawLeads) {
//             if (l != null && l.id == a.id) aRaw = l;
//             if (l != null && l.id == b.id) bRaw = l;
//           }
//           final aDate = aRaw?.followUpDate as DateTime?;
//           final bDate = bRaw?.followUpDate as DateTime?;
//           if (aDate == null) return 1;
//           if (bDate == null) return -1;
//           return aDate.compareTo(bDate);
//         });

//         // Group 2: Pending followups (before window start)
// final pendingFollowups = <LeadData>[];
// for (final lead in filteredByOther) {
//   dynamic original;
//   for (final l in rawLeads) {
//     if (l != null && l.id == lead.id) {
//       original = l;
//       break;
//     }
//   }
//   if (original != null && _isFollowupPending(original)) {
//     pendingFollowups.add(lead);
//   }
// }

// // Sort Group 2: nearest followup time first
// pendingFollowups.sort((a, b) {
//   dynamic aRaw, bRaw;
//   for (final l in rawLeads) {
//     if (l != null && l.id == a.id) aRaw = l;
//     if (l != null && l.id == b.id) bRaw = l;
//   }
//   final aDate = aRaw?.followUpDate as DateTime?;
//   final bDate = bRaw?.followUpDate as DateTime?;
//   if (aDate == null) return 1;
//   if (bDate == null) return -1;
//   return aDate.compareTo(bDate);
// });

// // Return all groups in order
// return [...todaysFollowups, ...pendingFollowups];

//       case 'Transferred':
//         return filteredByOther
//             .where((e) => e.status.toLowerCase() == 'transferred')
//             .toList();

//       case 'Closed':
//         return filteredByOther
//             .where((e) => e.status.toLowerCase() == 'closed')
//             .toList();

//       case 'Called':
//         return filteredByOther
//             .where((e) => _isCalledToday(e, rawLeads))
//             .toList();

//       case 'Missed':
//         return filteredByOther
//             .where((e) => _isMissedLead(e, rawLeads))
//             .toList();

//       default:
//         return filteredByOther;
//     }
//   }

//   List<ValueNotifier<bool>> _getFilteredCloseNotifiers(
//     List<LeadData> allLeads,
//     List<LeadData> filteredLeads,
//   ) {
//     return filteredLeads
//         .map((lead) => _closeNotifiers[allLeads.indexOf(lead)])
//         .toList();
//   }

//   bool _getAreAllExpanded(List<LeadData> allLeads) =>
//       allLeads.isNotEmpty && allLeads.every((lead) => lead.isExpanded);

//   void _toggleAllExpanded(List<LeadData> allLeads) {
//     final expand = !_getAreAllExpanded(allLeads);
//     setState(() {
//       for (final lead in allLeads) {
//         if (expand) {
//           _expandedLeadPhones.add(lead.phone);
//         } else {
//           _expandedLeadPhones.remove(lead.phone);
//         }
//       }
//     });
//   }

//   // ── Report button handler ─────────────────────────────────────────────────
//   void _onChartTap() => setState(() => _isReportView = !_isReportView);

//   bool get _isFilterActive {
//     if (_appliedFilters == null) return false;
//     final todayStr = _getTodayString();
//     if (_appliedFilters!.fromDate != todayStr ||
//         _appliedFilters!.toDate != todayStr) {
//       return true;
//     }
//     for (final val in _appliedFilters!.selectedItems.values) {
//       if (val.isNotEmpty) {
//         return true;
//       }
//     }
//     return false;
//   }

//   @override
//   void dispose() {
//     for (final n in _closeNotifiers) {
//       n.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     log(
//       '[LeadListScreen] build() / UI rebuild triggered with status: ${context.read<AddLeadCubit>().state.listStatus}',
//     );
//     return BlocBuilder<AddLeadCubit, AddLeadState>(
//       builder: (context, state) {
//         if (state.listStatus == LeadListStatus.loading) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (_isFirstLoad && state.leads.isNotEmpty) {
//           for (final lead in state.leads) {
//             _expandedLeadPhones.add(lead.contactNumber);
//           }
//           _isFirstLoad = false;
//         }

//         final mappedLeads = _mapLeads(state.leads);
//         final filteredLeads = _getFilteredLeads(mappedLeads, state.leads);

//         if (_sortByNewest) {
//           filteredLeads.sort((a, b) {
//             if (a.createdAt == null) return 1;
//             if (b.createdAt == null) return -1;
//             return b.createdAt!.compareTo(a.createdAt!);
//           });
//         } else {
//           filteredLeads.sort((a, b) {
//             if (a.createdAt == null) return 1;
//             if (b.createdAt == null) return -1;
//             return a.createdAt!.compareTo(b.createdAt!);
//           });
//         }

//         // Skip sorting for Followup tab (preserve group order)
//         if (_selectedStatus == 'Followup') {
//           // Keep the order from _getFilteredLeads (groups are already sorted)
//         }

//         _syncCloseNotifiers(mappedLeads.length);

//         final filteredCloseNotifiers = _getFilteredCloseNotifiers(
//           mappedLeads,
//           filteredLeads,
//         );

//         // Calculate status counts using the same logic
//         final filteredByOther = mappedLeads
//             .where(_passesSecondaryFilters)
//             .toList();

//         final newCount = filteredByOther
//             .where((e) => _isNewLeadInWindow(e))
//             .length;

//         // Followup count (all three groups)
//         int followupCount = 0;
//         for (final lead in filteredByOther) {
//           dynamic original;
//           for (final l in state.leads) {
//             if (l != null && l.id == lead.id) {
//               original = l;
//               break;
//             }
//           }
//           if (original != null) {
//             if (_isFollowupToday(original)) {
//               followupCount++;
//             }
//           }
//         }

//         final missedCount = filteredByOther
//             .where((e) => _isMissedLead(e, state.leads))
//             .length;

//         final calledCount = filteredByOther
//             .where((e) => _isCalledToday(e, state.leads))
//             .length;

//         final transferredCount = filteredByOther
//             .where((e) => e.status.toLowerCase() == 'transferred')
//             .length;

//         final closedCount = filteredByOther
//             .where((e) => e.status.toLowerCase() == 'closed')
//             .length;

//         final Map<String, int> statusCounts = {
//           'New': newCount,
//           'Followup': followupCount,
//           'Missed': missedCount,
//           'Called': calledCount,
//           'Transferred': transferredCount,
//           'Closed': closedCount,
//         };

//         final updatedStatusCards = statusCards.map((card) {
//           final count = statusCounts[card.label] ?? 0;
//           return card.copyWith(count: count);
//         }).toList();

//         return RefreshIndicator(
//           onRefresh: () => context.read<AddLeadCubit>().fetchLeads(),
//           child: Container(
//             color: const Color(0xFFF3F4F6),
//             child: CustomScrollView(
//               physics: const BouncingScrollPhysics(
//                 parent: AlwaysScrollableScrollPhysics(),
//               ),
//               slivers: [
//                 // ── Static top section ──────────────────────────────────────────
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Lead Status heading + refresh icon
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Lead Status',
//                               style: TextStyle(
//                                 fontSize: 17.sp,
//                                 fontWeight: FontWeight.w700,
//                                 color: const Color(0xFF111827),
//                                 letterSpacing: -0.3,
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: () =>
//                                   context.read<AddLeadCubit>().fetchLeads(),
//                               child: Container(
//                                 width: 9.w,
//                                 height: 4.5.h,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(2.5.w),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withValues(
//                                         alpha: 0.06,
//                                       ),
//                                       blurRadius: 8,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Icon(
//                                   Icons.sync_rounded,
//                                   size: 4.5.w,
//                                   color: const Color(0xFF6B7280),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 1.8.h),

//                         // Status cards grid
//                         GridView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: updatedStatusCards.length,
//                           gridDelegate:
//                               SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 3,
//                                 crossAxisSpacing: 2.w,
//                                 mainAxisSpacing: 2.w,
//                                 childAspectRatio: 0.88,
//                               ),
//                           itemBuilder: (context, index) => StatusCard(
//                             data: updatedStatusCards[index],
//                             isSelected:
//                                 _selectedStatus ==
//                                 updatedStatusCards[index].label,
//                             onTap: () => setState(
//                               () => _selectedStatus =
//                                   updatedStatusCards[index].label,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 2.h),

//                         SectionHeader(
//                           title: 'Leads',
//                           subtitle: '${filteredLeads.length} Leads',
//                           isReportActive: _isReportView,
//                           areAllExpanded: _getAreAllExpanded(mappedLeads),
//                           isFilterActive: _isFilterActive,
//                           sortIcon: _sortByNewest
//                               ? Icons.arrow_downward_rounded
//                               : Icons.arrow_upward_rounded,
//                           sortBgColor: _sortByNewest
//                               ? const Color(0xFFF3F4F6)
//                               : AppColors.bottomNavBlue,
//                           sortIconColor: _sortByNewest
//                               ? const Color(0xFF6B7280)
//                               : Colors.white,
//                           onAdd: () async {
//                             await Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => CreateLeadScreen(),
//                               ),
//                             );
//                             if (context.mounted) {
//                               context.read<AddLeadCubit>().fetchLeads();
//                             }
//                           },
//                           onChart: _onChartTap,
//                           onFilter: () async {
//                             final result = await showFilterBottomSheet(
//                               context,
//                               initialFilters: _appliedFilters,
//                             );
//                             if (result != null) {
//                               setState(() {
//                                 final todayStr = _getTodayString();
//                                 final hasActiveDate =
//                                     result.fromDate != todayStr ||
//                                     result.toDate != todayStr;
//                                 final hasActiveCheckbox = result
//                                     .selectedItems
//                                     .values
//                                     .any((s) => s.isNotEmpty);

//                                 if (hasActiveDate || hasActiveCheckbox) {
//                                   _appliedFilters = result;
//                                 } else {
//                                   _appliedFilters = null;
//                                 }
//                               });
//                             }
//                           },
//                           onSearch: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => BlocProvider.value(
//                                   value: context.read<AddLeadCubit>(),
//                                   child: const SearchScreen(),
//                                 ),
//                               ),
//                             );
//                           },
//                           onDownload: () {
//                             setState(() {
//                               _sortByNewest = !_sortByNewest;
//                             });
//                           },
//                           onmenu: () => _toggleAllExpanded(mappedLeads),
//                         ),
//                         SizedBox(height: 1.5.h),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // ── Animated content section ────────────────────────────────
//                 SliverToBoxAdapter(
//                   child: AnimatedSwitcher(
//                     duration: const Duration(milliseconds: 300),
//                     switchInCurve: Curves.easeOut,
//                     switchOutCurve: Curves.easeIn,
//                     transitionBuilder: (child, animation) => FadeTransition(
//                       opacity: animation,
//                       child: SlideTransition(
//                         position: Tween<Offset>(
//                           begin: const Offset(0, 0.04),
//                           end: Offset.zero,
//                         ).animate(animation),
//                         child: child,
//                       ),
//                     ),
//                     child: _isReportView
//                         ? Padding(
//                             padding: EdgeInsets.only(bottom: 16.w),
//                             child: ReportSection(
//                               key: const ValueKey('report'),
//                               leads: filteredLeads,
//                               selectedStatus: _selectedStatus,
//                             ),
//                           )
//                         : Padding(
//                             padding: EdgeInsets.only(bottom: 13.w),
//                             child: LeadListWidget(
//                               key: const ValueKey('leads'),
//                               leads: filteredLeads,
//                               closeNotifiers: filteredCloseNotifiers,
//                               onToggleExpand: (index) {
//                                 final lead = filteredLeads[index];
//                                 setState(() {
//                                   if (_expandedLeadPhones.contains(
//                                     lead.phone,
//                                   )) {
//                                     _expandedLeadPhones.remove(lead.phone);
//                                   } else {
//                                     _expandedLeadPhones.add(lead.phone);
//                                   }
//                                 });
//                               },
//                               onSwipeOpen: (index) {
//                                 for (
//                                   int i = 0;
//                                   i < _closeNotifiers.length;
//                                   i++
//                                 ) {
//                                   if (i != index) {
//                                     _closeNotifiers[i].value = true;
//                                     Future.microtask(
//                                       () => _closeNotifiers[i].value = false,
//                                     );
//                                   }
//                                 }
//                               },
//                             ),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }


import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/feature/home/search_screen.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/screens/add_lead.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_cubit.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/screens/filtering.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_state.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/lead_data.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/status_card.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/section_header.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/lead_list_widget.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/report_section.dart';
import 'package:sizer/sizer.dart';
export 'package:odit_crm_mobile/feature/leads/lead_managment/models/lead_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LeadFilter — single source of truth for all filtering and counting rules.
//
// Rules (no date filter active):
//   New          → leadStage == NEW  (no date restriction)
//   Followup     → leadStage == FOLLOWUP && (followUpDate == today
//                   OR followUpDate < today) && NOT completed today
//   Missed       → (NEW && createdAt < today)
//                   OR (FOLLOWUP && followUpDate < today)
//                   OR (TRANSFERRED && followUpDate < today)
//   Called       → latest followUp.calledDate == today
//   Transferred  → leadStage == TRANSFERRED  (no date restriction)
//   Closed       → leadStage == CLOSED       (no date restriction)
//
// Rules (date filter active — replace "today" with the selected window):
//   New          → leadStage == NEW && createdAt inside [from, to]
//   Followup     → leadStage == FOLLOWUP && (followUpDate inside [from, to]
//                   OR followUpDate < from) && NOT completed inside [from, to]
//   Missed       → (NEW && createdAt < from)
//                   OR (FOLLOWUP && followUpDate < from)
//                   OR (TRANSFERRED && followUpDate < from)
//   Called       → latest followUp.calledDate inside [from, to]
//   Transferred  → leadStage == TRANSFERRED && createdAt inside [from, to]
//   Closed       → leadStage == CLOSED && createdAt inside [from, to]
// ─────────────────────────────────────────────────────────────────────────────
class LeadFilter {
  final FilterResult? appliedFilters;

  // Cached window boundaries so we don't recompute on every call.
  late final DateTime _windowStart;
  late final DateTime _windowEnd;
  late final bool _hasDateFilter;

  LeadFilter(this.appliedFilters) {
    _hasDateFilter = _computeHasDateFilter();
    _windowStart = _computeWindowStart();
    _windowEnd = _computeWindowEnd();
  }

  // ── Window boundary helpers ───────────────────────────────────────────────

  bool _computeHasDateFilter() {
    if (appliedFilters == null) return false;
    final today = _todayString();
    return appliedFilters!.fromDate != today || appliedFilters!.toDate != today;
  }

  DateTime _computeWindowStart() {
    if (!_hasDateFilter || appliedFilters == null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }
    final parsed = _parseDate(appliedFilters!.fromDate);
    if (parsed == null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  DateTime _computeWindowEnd() {
    if (!_hasDateFilter || appliedFilters == null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, 23, 59, 59);
    }
    final parsed = _parseDate(appliedFilters!.toDate);
    if (parsed == null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, 23, 59, 59);
    }
    return DateTime(parsed.year, parsed.month, parsed.day, 23, 59, 59);
  }

  /// True when [date] falls within [_windowStart, _windowEnd] inclusive.
  bool _isInWindow(DateTime date) =>
      !date.isBefore(_windowStart) && !date.isAfter(_windowEnd);

  /// True when [date] is strictly before the window start.
  bool _isBeforeWindow(DateTime date) => date.isBefore(_windowStart);

  // ── Raw-lead lookup ───────────────────────────────────────────────────────

  dynamic _rawFor(String id, List<dynamic> rawLeads) {
    for (final r in rawLeads) {
      if (r != null && r.id == id) return r;
    }
    return null;
  }

  // ── Secondary (non-date) filter ───────────────────────────────────────────

  bool passesSecondaryFilters(LeadData lead) {
    if (appliedFilters == null) return true;

    final staff = appliedFilters!.selectedItems['Assigned Staff'];
    if (staff != null && staff.isNotEmpty) {
      if (!staff.any((s) => lead.assignedTo.toLowerCase() == s.toLowerCase())) {
        return false;
      }
    }

    final category = appliedFilters!.selectedItems['Category'];
    if (category != null && category.isNotEmpty) {
      if (!category.any((c) => lead.category.toLowerCase() == c.toLowerCase())) {
        return false;
      }
    }

    final priority = appliedFilters!.selectedItems['Priority'];
    if (priority != null && priority.isNotEmpty) {
      if (!priority.any((p) => lead.priority.toLowerCase() == p.toLowerCase())) {
        return false;
      }
    }

    return true;
  }

  // ── Per-status predicates ─────────────────────────────────────────────────

  /// NEW tab.
  /// No filter → all NEW leads (no date restriction).
  /// Filter active → NEW leads whose createdAt is inside the window.
  bool isNew(LeadData lead) {
    if (lead.status.toUpperCase() != 'NEW') return false;
    if (!_hasDateFilter) return true;
    if (lead.createdAt == null) return false;
    return _isInWindow(lead.createdAt!);
  }

  /// FOLLOWUP tab.
  /// Include: followUpDate inside window OR followUpDate before window start.
  /// Exclude: completed followups (calledDate inside window).
  bool isFollowup(LeadData lead, List<dynamic> rawLeads) {
    final raw = _rawFor(lead.id, rawLeads);
    if (raw == null) return false;
    if (raw.leadStage.toString().toUpperCase() != 'FOLLOWUP') return false;

    final followUpDate = raw.followUpDate as DateTime?;
    if (followUpDate == null) return false;

    final inWindow = _isInWindow(followUpDate);
    final beforeWindow = _isBeforeWindow(followUpDate);

    if (!inWindow && !beforeWindow) return false;

    // Exclude if already completed (latest calledDate inside window).
    if (_isCompletedInWindow(raw)) return false;

    return true;
  }

  /// True when the latest followUp entry has a calledDate inside the window.
  bool _isCompletedInWindow(dynamic raw) {
    final followups = raw.followUp;
    if (followups == null || followups.isEmpty) return false;
    dynamic latest;
    for (final f in followups) {
      if (latest == null || (f.calledDate as DateTime).isAfter(latest.calledDate as DateTime)) {
        latest = f;
      }
    }
    if (latest == null) return false;
    return _isInWindow(latest.calledDate as DateTime);
  }

  /// Sub-predicate: followUpDate is inside the window (used for group sorting).
  bool isFollowupInWindow(dynamic raw) {
    if (raw.leadStage.toString().toUpperCase() != 'FOLLOWUP') return false;
    final followUpDate = raw.followUpDate as DateTime?;
    if (followUpDate == null) return false;
    return _isInWindow(followUpDate) && !_isCompletedInWindow(raw);
  }

  /// Sub-predicate: followUpDate is before the window start (pending).
  bool isFollowupPending(dynamic raw) {
    if (raw.leadStage.toString().toUpperCase() != 'FOLLOWUP') return false;
    final followUpDate = raw.followUpDate as DateTime?;
    if (followUpDate == null) return false;
    return _isBeforeWindow(followUpDate) && !_isCompletedInWindow(raw);
  }

  /// MISSED tab.
  /// NEW   && (createdAt < windowStart)
  /// FOLLOWUP && (followUpDate < windowStart)
  /// TRANSFERRED && (followUpDate < windowStart)
  bool isMissed(LeadData lead, List<dynamic> rawLeads) {
    final raw = _rawFor(lead.id, rawLeads);
    if (raw == null) return false;

    final stage = raw.leadStage.toString().toUpperCase();

    if (stage == 'NEW') {
      if (lead.createdAt == null) return false;
      return _isBeforeWindow(lead.createdAt!);
    }

    if (stage == 'FOLLOWUP') {
      final followUpDate = raw.followUpDate as DateTime?;
      if (followUpDate == null) return false;
      return _isBeforeWindow(followUpDate);
    }

    if (stage == 'TRANSFERRED') {
      final followUpDate = raw.followUpDate as DateTime?;
      if (followUpDate == null) return false;
      return _isBeforeWindow(followUpDate);
    }

    return false;
  }

  /// CALLED tab.
  /// Latest followUp.calledDate is inside the window.
  bool isCalled(LeadData lead, List<dynamic> rawLeads) {
    final raw = _rawFor(lead.id, rawLeads);
    if (raw == null) return false;

    final followups = raw.followUp;
    if (followups == null || followups.isEmpty) return false;

    dynamic latest;
    for (final f in followups) {
      if (latest == null ||
          (f.calledDate as DateTime).isAfter(latest.calledDate as DateTime)) {
        latest = f;
      }
    }
    if (latest == null) return false;

    return _isInWindow(latest.calledDate as DateTime);
  }

  /// TRANSFERRED tab.
  /// No filter → all TRANSFERRED leads (no date restriction).
  /// Filter active → TRANSFERRED leads whose createdAt is inside the window.
  bool isTransferred(LeadData lead) {
    if (lead.status.toUpperCase() != 'TRANSFERRED') return false;
    if (!_hasDateFilter) return true;
    if (lead.createdAt == null) return false;
    return _isInWindow(lead.createdAt!);
  }

  /// CLOSED tab.
  /// No filter → all CLOSED leads (no date restriction).
  /// Filter active → CLOSED leads whose createdAt is inside the window.
  bool isClosed(LeadData lead) {
    if (lead.status.toUpperCase() != 'CLOSED') return false;
    if (!_hasDateFilter) return true;
    if (lead.createdAt == null) return false;
    return _isInWindow(lead.createdAt!);
  }

  // ── Utilities ─────────────────────────────────────────────────────────────

  DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}
    return null;
  }

  static String _todayString() {
    final d = DateTime.now();
    return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LeadListScreen
// ─────────────────────────────────────────────────────────────────────────────
class LeadListScreen extends StatefulWidget {
  final int selectedTab;
  final String? initialStatus;

  const LeadListScreen({
    super.key,
    required this.selectedTab,
    this.initialStatus = 'New',
  });

  @override
  State<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen> {
  // ── UI state ──────────────────────────────────────────────────────────────
  bool _isReportView = false;
  late String _selectedStatus;
  bool _sortByNewest = true;
  bool _isFirstLoad = true;

  // ── Filter state ──────────────────────────────────────────────────────────
  FilterResult? _appliedFilters;

  // ── Swipe / expand state ──────────────────────────────────────────────────
  List<ValueNotifier<bool>> _closeNotifiers = [];
  final Set<String> _expandedLeadPhones = {};

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus ?? 'New';
    log('[LeadListScreen] initState() called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        log('[LeadListScreen] fetchLeads() on init');
        context.read<AddLeadCubit>().fetchLeads();
      }
    });
  }

  @override
  void dispose() {
    for (final n in _closeNotifiers) {
      n.dispose();
    }
    super.dispose();
  }

  // ── Mapped leads ──────────────────────────────────────────────────────────

  List<LeadData> _mapLeads(List<dynamic> firestoreLeads) {
    return firestoreLeads.map((lead) {
      return LeadData(
        id: lead.id ?? '',
        name: lead.clientName.isEmpty ? 'Unknown' : lead.clientName,
        phone: lead.contactNumber,
        assignedTo: lead.assignedStaff,
        category: lead.leadCategory.isEmpty ? 'Uncategorized' : lead.leadCategory,
        status: lead.leadStage,
        notificationCount: 0,
        isExpanded: _expandedLeadPhones.contains(lead.contactNumber),
        source: lead.leadSource,
        priority: lead.priority,
        createdAt: lead.createdAt,
      );
    }).toList();
  }

  // ── Filtered list for the active status tab ───────────────────────────────
  // Uses LeadFilter for all predicates — same object used for counts, so the
  // number on the card always matches the list behind it.

  List<LeadData> _getFilteredLeads(
    List<LeadData> mappedLeads,
    List<dynamic> rawLeads,
    LeadFilter filter,
  ) {
    final candidates = mappedLeads.where(filter.passesSecondaryFilters).toList();

    switch (_selectedStatus) {
      case 'New':
        return candidates.where(filter.isNew).toList();

      case 'Followup':
        // Split into two groups so we can sort them independently,
        // then concatenate in display order.
        final todayGroup = <LeadData>[];
        final pendingGroup = <LeadData>[];

        for (final lead in candidates) {
          dynamic raw;
          for (final r in rawLeads) {
            if (r != null && r.id == lead.id) {
              raw = r;
              break;
            }
          }
          if (raw == null) continue;

          if (filter.isFollowupInWindow(raw)) {
            todayGroup.add(lead);
          } else if (filter.isFollowupPending(raw)) {
            pendingGroup.add(lead);
          }
        }

        // Sort group 1: nearest followUpDate first.
        todayGroup.sort((a, b) {
          dynamic aRaw, bRaw;
          for (final r in rawLeads) {
            if (r != null && r.id == a.id) aRaw = r;
            if (r != null && r.id == b.id) bRaw = r;
          }
          final aDate = aRaw?.followUpDate as DateTime?;
          final bDate = bRaw?.followUpDate as DateTime?;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return aDate.compareTo(bDate);
        });

        // Sort group 2: most overdue first (oldest followUpDate first).
        pendingGroup.sort((a, b) {
          dynamic aRaw, bRaw;
          for (final r in rawLeads) {
            if (r != null && r.id == a.id) aRaw = r;
            if (r != null && r.id == b.id) bRaw = r;
          }
          final aDate = aRaw?.followUpDate as DateTime?;
          final bDate = bRaw?.followUpDate as DateTime?;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return aDate.compareTo(bDate);
        });

        return [...todayGroup, ...pendingGroup];

      case 'Missed':
        return candidates.where((l) => filter.isMissed(l, rawLeads)).toList();

      case 'Called':
        return candidates.where((l) => filter.isCalled(l, rawLeads)).toList();

      case 'Transferred':
        return candidates.where(filter.isTransferred).toList();

      case 'Closed':
        return candidates.where(filter.isClosed).toList();

      default:
        return candidates;
    }
  }

  // ── Status card counts — mirrors _getFilteredLeads predicates exactly ─────

  Map<String, int> _buildStatusCounts(
    List<LeadData> mappedLeads,
    List<dynamic> rawLeads,
    LeadFilter filter,
  ) {
    final candidates = mappedLeads.where(filter.passesSecondaryFilters).toList();

    // Followup count: in-window group + pending group, with completed excluded.
    int followupCount = 0;
    for (final lead in candidates) {
      dynamic raw;
      for (final r in rawLeads) {
        if (r != null && r.id == lead.id) {
          raw = r;
          break;
        }
      }
      if (raw != null &&
          (filter.isFollowupInWindow(raw) || filter.isFollowupPending(raw))) {
        followupCount++;
      }
    }

    return {
      'New': candidates.where(filter.isNew).length,
      'Followup': followupCount,
      'Missed': candidates.where((l) => filter.isMissed(l, rawLeads)).length,
      'Called': candidates.where((l) => filter.isCalled(l, rawLeads)).length,
      'Transferred': candidates.where(filter.isTransferred).length,
      'Closed': candidates.where(filter.isClosed).length,
    };
  }

  // ── Sorting (Followup preserves group order) ──────────────────────────────

  List<LeadData> _applySorting(List<LeadData> leads) {
    if (_selectedStatus == 'Followup') return leads; // group order is meaningful
    final sorted = List<LeadData>.from(leads);
    sorted.sort((a, b) {
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return _sortByNewest
          ? b.createdAt!.compareTo(a.createdAt!)
          : a.createdAt!.compareTo(b.createdAt!);
    });
    return sorted;
  }

  // ── Filter-active indicator ───────────────────────────────────────────────

  String _getTodayString() {
    final d = DateTime.now();
    return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  }

  bool get _isFilterActive {
    if (_appliedFilters == null) return false;
    final todayStr = _getTodayString();
    if (_appliedFilters!.fromDate != todayStr ||
        _appliedFilters!.toDate != todayStr) return true;
    return _appliedFilters!.selectedItems.values.any((v) => v.isNotEmpty);
  }

  // ── Swipe / expand helpers ────────────────────────────────────────────────

  void _syncCloseNotifiers(int length) {
    if (_closeNotifiers.length != length) {
      for (final n in _closeNotifiers) {
        n.dispose();
      }
      _closeNotifiers = List.generate(length, (_) => ValueNotifier(false));
    }
  }

  List<ValueNotifier<bool>> _getFilteredCloseNotifiers(
    List<LeadData> allLeads,
    List<LeadData> filteredLeads,
  ) {
    return filteredLeads
        .map((lead) => _closeNotifiers[allLeads.indexOf(lead)])
        .toList();
  }

  bool _getAreAllExpanded(List<LeadData> leads) =>
      leads.isNotEmpty && leads.every((l) => l.isExpanded);

  void _toggleAllExpanded(List<LeadData> leads) {
    final expand = !_getAreAllExpanded(leads);
    setState(() {
      for (final lead in leads) {
        if (expand) {
          _expandedLeadPhones.add(lead.phone);
        } else {
          _expandedLeadPhones.remove(lead.phone);
        }
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    log('[LeadListScreen] build() triggered');

    return BlocBuilder<AddLeadCubit, AddLeadState>(
      builder: (context, state) {
        if (state.listStatus == LeadListStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Auto-expand all leads on first load.
        if (_isFirstLoad && state.leads.isNotEmpty) {
          for (final lead in state.leads) {
            _expandedLeadPhones.add(lead.contactNumber);
          }
          _isFirstLoad = false;
        }

        final mappedLeads = _mapLeads(state.leads);
        _syncCloseNotifiers(mappedLeads.length);

        // Single LeadFilter instance — shared by counts and list.
        final filter = LeadFilter(_appliedFilters);

        final filteredLeads = _applySorting(
          _getFilteredLeads(mappedLeads, state.leads, filter),
        );

        final filteredCloseNotifiers = _getFilteredCloseNotifiers(
          mappedLeads,
          filteredLeads,
        );

        final statusCounts = _buildStatusCounts(mappedLeads, state.leads, filter);

        final updatedStatusCards = statusCards.map((card) {
          return card.copyWith(count: statusCounts[card.label] ?? 0);
        }).toList();

        return RefreshIndicator(
          onRefresh: () => context.read<AddLeadCubit>().fetchLeads(),
          child: Container(
            color: const Color(0xFFF3F4F6),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // ── Static top section ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Lead Status',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                                letterSpacing: -0.3,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  context.read<AddLeadCubit>().fetchLeads(),
                              child: Container(
                                width: 9.w,
                                height: 4.5.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2.5.w),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.sync_rounded,
                                  size: 4.5.w,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.8.h),

                        // Status cards grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: updatedStatusCards.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 2.w,
                                mainAxisSpacing: 2.w,
                                childAspectRatio: 0.88,
                              ),
                          itemBuilder: (context, index) => StatusCard(
                            data: updatedStatusCards[index],
                            isSelected:
                                _selectedStatus == updatedStatusCards[index].label,
                            onTap: () => setState(
                              () => _selectedStatus = updatedStatusCards[index].label,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),

                        SectionHeader(
                          title: 'Leads',
                          subtitle: '${filteredLeads.length} Leads',
                          isReportActive: _isReportView,
                          areAllExpanded: _getAreAllExpanded(mappedLeads),
                          isFilterActive: _isFilterActive,
                          sortIcon: _sortByNewest
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          sortBgColor: _sortByNewest
                              ? const Color(0xFFF3F4F6)
                              : AppColors.bottomNavBlue,
                          sortIconColor: _sortByNewest
                              ? const Color(0xFF6B7280)
                              : Colors.white,
                          onAdd: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateLeadScreen(),
                              ),
                            );
                            if (context.mounted) {
                              context.read<AddLeadCubit>().fetchLeads();
                            }
                          },
                          onChart: () =>
                              setState(() => _isReportView = !_isReportView),
                          onFilter: () async {
                            final result = await showFilterBottomSheet(
                              context,
                              initialFilters: _appliedFilters,
                            );
                            if (result != null) {
                              setState(() {
                                final todayStr = _getTodayString();
                                final hasActiveDate =
                                    result.fromDate != todayStr ||
                                    result.toDate != todayStr;
                                final hasActiveCheckbox = result
                                    .selectedItems.values
                                    .any((s) => s.isNotEmpty);
                                _appliedFilters =
                                    (hasActiveDate || hasActiveCheckbox)
                                        ? result
                                        : null;
                              });
                            }
                          },
                          onSearch: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<AddLeadCubit>(),
                                  child: const SearchScreen(),
                                ),
                              ),
                            );
                          },
                          onDownload: () {
                            setState(() => _sortByNewest = !_sortByNewest);
                          },
                          onmenu: () => _toggleAllExpanded(mappedLeads),
                        ),
                        SizedBox(height: 1.5.h),
                      ],
                    ),
                  ),
                ),

                // ── Animated list / report section ────────────────────────────
                SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.04),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _isReportView
                        ? Padding(
                            padding: EdgeInsets.only(bottom: 16.w),
                            child: ReportSection(
                              key: const ValueKey('report'),
                              leads: filteredLeads,
                              selectedStatus: _selectedStatus,
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.only(bottom: 13.w),
                            child: LeadListWidget(
                              key: const ValueKey('leads'),
                              leads: filteredLeads,
                              closeNotifiers: filteredCloseNotifiers,
                              onToggleExpand: (index) {
                                final lead = filteredLeads[index];
                                setState(() {
                                  if (_expandedLeadPhones.contains(lead.phone)) {
                                    _expandedLeadPhones.remove(lead.phone);
                                  } else {
                                    _expandedLeadPhones.add(lead.phone);
                                  }
                                });
                              },
                              onSwipeOpen: (index) {
                                for (int i = 0;
                                    i < _closeNotifiers.length;
                                    i++) {
                                  if (i != index) {
                                    _closeNotifiers[i].value = true;
                                    Future.microtask(
                                      () => _closeNotifiers[i].value = false,
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}