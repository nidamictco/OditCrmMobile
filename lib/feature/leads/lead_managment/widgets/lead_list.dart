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

// // export LeadData so that other files importing widgets/lead_list.dart still compile
// export 'package:odit_crm_mobile/feature/leads/lead_managment/models/lead_data.dart';

// class LeadListScreen extends StatefulWidget {
//   /// Passed from LeadManagmentScreen; reserved for tab-specific logic.
//   final int selectedTab;

//   const LeadListScreen({super.key, required this.selectedTab});

//   @override
//   State<LeadListScreen> createState() => _LeadListScreenState();
// }

// class _LeadListScreenState extends State<LeadListScreen> {
//   // ── Report toggle ─────────────────────────────────────────────────────────
//   bool _isReportView = false;

//   // ── Close notifiers for swipe cards ──────────────────────────────────────
//   List<ValueNotifier<bool>> _closeNotifiers = [];

//   // ── Selected status filter ────────────────────────────────────────────────
//   String _selectedStatus = 'New';

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

//     return leads.where((lead) {
//       if (lead.createdAt == null) return false;

//       final date = lead.createdAt!;

//       return date.year == now.year &&
//              date.month == now.month &&
//              date.day == now.day;
//     }).toList();
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

//   List<LeadData> _applyFilters(List<LeadData> leads) {
//     if (_appliedFilters == null) return leads;

//     return leads.where((lead) {
//       // 1. Date Range Filter
//       final start = _parseDate(_appliedFilters!.fromDate);
//       final end = _parseDate(_appliedFilters!.toDate);
//       if (start != null && end != null) {
//         final startOfDay = DateTime(start.year, start.month, start.day);
//         final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
//         if (lead.createdAt == null) return false;
//         if (lead.createdAt!.isBefore(startOfDay) ||
//             lead.createdAt!.isAfter(endOfDay)) {
//           return false;
//         }
//       }

//       // 2. Assigned Staff Filter
//       final selectedStaff = _appliedFilters!.selectedItems['Assigned Staff'];
//       if (selectedStaff != null && selectedStaff.isNotEmpty) {
//         if (!selectedStaff.any(
//           (staff) => lead.assignedTo.toLowerCase() == staff.toLowerCase(),
//         )) {
//           return false;
//         }
//       }

//       // 3. Category Filter
//       final selectedCategory = _appliedFilters!.selectedItems['Category'];
//       if (selectedCategory != null && selectedCategory.isNotEmpty) {
//         if (!selectedCategory.any(
//           (cat) => lead.category.toLowerCase() == cat.toLowerCase(),
//         )) {
//           return false;
//         }
//       }

//       // 4. Priority Filter
//       final selectedPriority = _appliedFilters!.selectedItems['Priority'];
//       if (selectedPriority != null && selectedPriority.isNotEmpty) {
//         if (!selectedPriority.any(
//           (prio) => lead.priority.toLowerCase() == prio.toLowerCase(),
//         )) {
//           return false;
//         }
//       }

//       return true;
//     }).toList();
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

//   List<LeadData> _getFilteredLeads(List<LeadData> allLeads) {
//     final filteredByOther = _applyFilters(allLeads);
//     switch (_selectedStatus) {
//       case 'New':
//         return filteredByOther
//             .where((e) => e.status.toLowerCase() == 'new')
//             .toList();
//       case 'Followup':
//         return filteredByOther
//             .where(
//               (e) =>
//                   e.status.toLowerCase() == 'followup' ||
//                   e.status.toLowerCase() == 'in progress',
//             )
//             .toList();
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
//             .where((e) => e.status.toLowerCase() == 'called')
//             .toList();
//       case 'Missed':
//         return filteredByOther
//             .where((e) => e.status.toLowerCase() == 'missed')
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
//         final todayLeads = _appliedFilters != null ? mappedLeads : _getTodayLeads(mappedLeads);
//         final filteredLeads = _getFilteredLeads(todayLeads);

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

//         _syncCloseNotifiers(mappedLeads.length);

//         final filteredCloseNotifiers = _getFilteredCloseNotifiers(
//           mappedLeads,
//           filteredLeads,
//         );

//         // Calculate real counts for each status type dynamically
//         final filteredByOther = _applyFilters(todayLeads);
//         final newCount = filteredByOther
//             .where((e) => e.status.toLowerCase() == 'new')
//             .length;
//         final followupCount = filteredByOther
//             .where(
//               (e) =>
//                   e.status.toLowerCase() == 'followup' ||
//                   e.status.toLowerCase() == 'in progress',
//             )
//             .length;
//         final missedCount = filteredByOther
//             .where((e) => e.status.toLowerCase() == 'missed')
//             .length;
//         final calledCount = filteredByOther
//             .where((e) => e.status.toLowerCase() == 'called')
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

//                 // ── Animated content section ────────────────────────────────────
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

// Color getStatusColor(String stage) {
//   switch (stage.toLowerCase()) {
//     case 'new':
//       return AppColors.skyBlue;
//     case 'followup':
//       return const Color(0xFFF59E0B);
//     case 'transferred':
//       return AppColors.teal;
//     case 'closed':
//       return const Color(0xFF22C55E);
//     default:
//       return Colors.grey;
//   }
// }

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

class LeadListScreen extends StatefulWidget {
  final int selectedTab;

  const LeadListScreen({super.key, required this.selectedTab});

  @override
  State<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen> {
  // ── Report toggle ─────────────────────────────────────────────────────────
  bool _isReportView = false;

  // ── Close notifiers for swipe cards ──────────────────────────────────────
  List<ValueNotifier<bool>> _closeNotifiers = [];

  // ── Selected status filter ────────────────────────────────────────────────
  String _selectedStatus = 'New';

  // ── Applied filters ───────────────────────────────────────────────────────
  FilterResult? _appliedFilters;

  // ── Expanded lead phones ──────────────────────────────────────────────────
  final Set<String> _expandedLeadPhones = {};
  bool _isFirstLoad = true;
  bool _sortByNewest = true;

  void _syncCloseNotifiers(int length) {
    if (_closeNotifiers.length != length) {
      for (final n in _closeNotifiers) {
        n.dispose();
      }
      _closeNotifiers = List.generate(length, (_) => ValueNotifier(false));
    }
  }

  List<LeadData> _getTodayLeads(List<LeadData> leads) {
    final now = DateTime.now();

    return leads.where((lead) {
      if (lead.createdAt == null) return false;

      final date = lead.createdAt!;

      return date.year == now.year &&
             date.month == now.month &&
             date.day == now.day;
    }).toList();
  }

  bool _isMissedLead(LeadData lead, List<dynamic> rawLeads) {
    dynamic original;
    for (final e in rawLeads) {
      if (e != null && e.id == lead.id) {
        original = e;
        break;
      }
    }
    if (original == null) return false;

    final stage = original.leadStage.toString().toUpperCase();
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    if (stage == 'FOLLOWUP' || stage == 'IN PROGRESS') {
      final nextFollowup = original.followUpDate;
      return nextFollowup != null && nextFollowup.isBefore(startOfToday);
    }

    if (stage == 'NEW') {
      return lead.createdAt != null && lead.createdAt!.isBefore(startOfToday);
    }

    return false;
  }

  bool _isCalledToday(LeadData lead, List<dynamic> rawLeads) {
    dynamic original;
    for (final e in rawLeads) {
      if (e != null && e.id == lead.id) {
        original = e;
        break;
      }
    }
    if (original == null) return false;

    final followups = original.followUp;
    if (followups == null || followups.isEmpty) return false;

    dynamic latestFollowup;
    for (final f in followups) {
      if (latestFollowup == null) {
        latestFollowup = f;
      } else if (f.calledDate.isAfter(latestFollowup.calledDate)) {
        latestFollowup = f;
      }
    }
    if (latestFollowup == null) return false;

    final calledDate = latestFollowup.calledDate;
    final now = DateTime.now();
    return calledDate.year == now.year &&
           calledDate.month == now.month &&
           calledDate.day == now.day;
  }

  String _getTodayString() {
    final d = DateTime.now();
    return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  }

  List<LeadData> _mapLeads(List<dynamic> firestoreLeads) {
    return firestoreLeads.map((lead) {
      return LeadData(
        id: lead.id ?? '',
        name: lead.clientName.isEmpty ? 'Unknown' : lead.clientName,
        phone: lead.contactNumber,
        assignedTo: lead.assignedStaff,
        category: lead.leadCategory.isEmpty
            ? 'Uncategorized'
            : lead.leadCategory,
        status: lead.leadStage,
        notificationCount: 0,
        isExpanded: _expandedLeadPhones.contains(lead.contactNumber),
        source: lead.leadSource,
        priority: lead.priority,
        createdAt: lead.createdAt,
      );
    }).toList();
  }

  List<LeadData> _applyFilters(List<LeadData> leads) {
    if (_appliedFilters == null) return leads;

    return leads.where((lead) {
      // 1. Date Range Filter
      final start = _parseDate(_appliedFilters!.fromDate);
      final end = _parseDate(_appliedFilters!.toDate);
      if (start != null && end != null) {
        final startOfDay = DateTime(start.year, start.month, start.day);
        final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
        if (lead.createdAt == null) return false;
        if (lead.createdAt!.isBefore(startOfDay) ||
            lead.createdAt!.isAfter(endOfDay)) {
          return false;
        }
      }

      // 2. Assigned Staff Filter
      final selectedStaff = _appliedFilters!.selectedItems['Assigned Staff'];
      if (selectedStaff != null && selectedStaff.isNotEmpty) {
        if (!selectedStaff.any(
          (staff) => lead.assignedTo.toLowerCase() == staff.toLowerCase(),
        )) {
          return false;
        }
      }

      // 3. Category Filter
      final selectedCategory = _appliedFilters!.selectedItems['Category'];
      if (selectedCategory != null && selectedCategory.isNotEmpty) {
        if (!selectedCategory.any(
          (cat) => lead.category.toLowerCase() == cat.toLowerCase(),
        )) {
          return false;
        }
      }

      // 4. Priority Filter
      final selectedPriority = _appliedFilters!.selectedItems['Priority'];
      if (selectedPriority != null && selectedPriority.isNotEmpty) {
        if (!selectedPriority.any(
          (prio) => lead.priority.toLowerCase() == prio.toLowerCase(),
        )) {
          return false;
        }
      }

      return true;
    }).toList();
  }

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

  List<LeadData> _getFilteredLeads(List<LeadData> allLeads, List<dynamic> rawLeads) {
    final filteredByOther = _applyFilters(allLeads);
    switch (_selectedStatus) {
      case 'New':
        return filteredByOther
            .where((e) => e.status.toLowerCase() == 'new')
            .toList();
      case 'Followup':
        return filteredByOther
            .where(
              (e) =>
                  e.status.toLowerCase() == 'followup' ||
                  e.status.toLowerCase() == 'in progress',
            )
            .toList();
      case 'Transferred':
        return filteredByOther
            .where((e) => e.status.toLowerCase() == 'transferred')
            .toList();
      case 'Closed':
        return filteredByOther
            .where((e) => e.status.toLowerCase() == 'closed')
            .toList();
      case 'Called':
        return filteredByOther
            .where((e) => _isCalledToday(e, rawLeads))
            .toList();
      case 'Missed':
        return filteredByOther
            .where((e) => _isMissedLead(e, rawLeads))
            .toList();
      default:
        return filteredByOther;
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

  bool _getAreAllExpanded(List<LeadData> allLeads) =>
      allLeads.isNotEmpty && allLeads.every((lead) => lead.isExpanded);

  void _toggleAllExpanded(List<LeadData> allLeads) {
    final expand = !_getAreAllExpanded(allLeads);
    setState(() {
      for (final lead in allLeads) {
        if (expand) {
          _expandedLeadPhones.add(lead.phone);
        } else {
          _expandedLeadPhones.remove(lead.phone);
        }
      }
    });
  }

  // ── Report button handler ─────────────────────────────────────────────────
  void _onChartTap() => setState(() => _isReportView = !_isReportView);

  bool get _isFilterActive {
    if (_appliedFilters == null) return false;
    final todayStr = _getTodayString();
    if (_appliedFilters!.fromDate != todayStr ||
        _appliedFilters!.toDate != todayStr) {
      return true;
    }
    for (final val in _appliedFilters!.selectedItems.values) {
      if (val.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    for (final n in _closeNotifiers) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddLeadCubit, AddLeadState>(
      builder: (context, state) {
        if (state.listStatus == LeadListStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_isFirstLoad && state.leads.isNotEmpty) {
          for (final lead in state.leads) {
            _expandedLeadPhones.add(lead.contactNumber);
          }
          _isFirstLoad = false;
        }

        final mappedLeads = _mapLeads(state.leads);
        final todayLeads = _appliedFilters != null ? mappedLeads : _getTodayLeads(mappedLeads);
        final filteredLeads = _getFilteredLeads(todayLeads, state.leads);

        if (_sortByNewest) {
          filteredLeads.sort((a, b) {
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;
            return b.createdAt!.compareTo(a.createdAt!);
          });
        } else {
          filteredLeads.sort((a, b) {
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;
            return a.createdAt!.compareTo(b.createdAt!);
          });
        }

        _syncCloseNotifiers(mappedLeads.length);

        final filteredCloseNotifiers = _getFilteredCloseNotifiers(
          mappedLeads,
          filteredLeads,
        );

        // Calculate real counts for each status type dynamically
        final filteredByOther = _applyFilters(todayLeads);
        final newCount = filteredByOther
            .where((e) => e.status.toLowerCase() == 'new')
            .length;
        final followupCount = filteredByOther
            .where(
              (e) =>
                  e.status.toLowerCase() == 'followup' ||
                  e.status.toLowerCase() == 'in progress',
            )
            .length;
        final missedCount = filteredByOther
            .where((e) => _isMissedLead(e, state.leads))
            .length;
        final calledCount = filteredByOther
            .where((e) => _isCalledToday(e, state.leads))
            .length;
        final transferredCount = filteredByOther
            .where((e) => e.status.toLowerCase() == 'transferred')
            .length;
        final closedCount = filteredByOther
            .where((e) => e.status.toLowerCase() == 'closed')
            .length;

        final Map<String, int> statusCounts = {
          'New': newCount,
          'Followup': followupCount,
          'Missed': missedCount,
          'Called': calledCount,
          'Transferred': transferredCount,
          'Closed': closedCount,
        };

        final updatedStatusCards = statusCards.map((card) {
          final count = statusCounts[card.label] ?? 0;
          return card.copyWith(count: count);
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
                // ── Static top section ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Lead Status heading + refresh icon
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
                                      color: Colors.black.withValues(
                                        alpha: 0.06,
                                      ),
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
                                _selectedStatus ==
                                updatedStatusCards[index].label,
                            onTap: () => setState(
                              () => _selectedStatus =
                                  updatedStatusCards[index].label,
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
                          onChart: _onChartTap,
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
                                    .selectedItems
                                    .values
                                    .any((s) => s.isNotEmpty);

                                if (hasActiveDate || hasActiveCheckbox) {
                                  _appliedFilters = result;
                                } else {
                                  _appliedFilters = null;
                                }
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
                            setState(() {
                              _sortByNewest = !_sortByNewest;
                            });
                          },
                          onmenu: () => _toggleAllExpanded(mappedLeads),
                        ),
                        SizedBox(height: 1.5.h),
                      ],
                    ),
                  ),
                ),

                // ── Animated content section ────────────────────────────────────
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
                                  if (_expandedLeadPhones.contains(
                                    lead.phone,
                                  )) {
                                    _expandedLeadPhones.remove(lead.phone);
                                  } else {
                                    _expandedLeadPhones.add(lead.phone);
                                  }
                                });
                              },
                              onSwipeOpen: (index) {
                                for (
                                  int i = 0;
                                  i < _closeNotifiers.length;
                                  i++
                                ) {
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

Color getStatusColor(String stage) {
  switch (stage.toLowerCase()) {
    case 'new':
      return AppColors.skyBlue;
    case 'followup':
      return const Color(0xFFF59E0B);
    case 'transferred':
      return AppColors.teal;
    case 'closed':
      return const Color(0xFF22C55E);
    default:
      return Colors.grey;
  }
}
