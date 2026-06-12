import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/feature/home/search_screen.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/add_lead.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/filtering.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/analytics_card.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/lead_card.dart';
import 'package:sizer/sizer.dart';

// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────

class StatusCardData {
  final String label;
  final int count;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;

  const StatusCardData({
    required this.label,
    required this.count,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
  });
}

class LeadData {
  final String name;
  final String phone;
  final String assignedTo;
  final String category;
  final String status;
  final Color statusDotColor;
  final int notificationCount;
  bool isExpanded;

  LeadData({
    required this.name,
    required this.phone,
    required this.assignedTo,
    required this.category,
    required this.status,
    required this.statusDotColor,
    required this.notificationCount,
    this.isExpanded = true,
  });
}

// ─────────────────────────────────────────────
// DUMMY DATA
// ─────────────────────────────────────────────

final List<StatusCardData> statusCards = [
  StatusCardData(
    label: 'New',
    count: 40,
    icon: Icons.person_add_alt_1_outlined,
    iconColor: const Color(0xFF3B82F6),
    bgColor: const Color(0xFFEFF6FF),
    borderColor: const Color(0xFFBFDBFE),
  ),
  StatusCardData(
    label: 'Followup',
    count: 185,
    icon: Icons.access_time_rounded,
    iconColor: const Color(0xFFF59E0B),
    bgColor: const Color(0xFFFFFBEB),
    borderColor: const Color(0xFFFDE68A),
  ),
  StatusCardData(
    label: 'Missed',
    count: 206,
    icon: Icons.call_missed_outgoing_rounded,
    iconColor: const Color(0xFFEF4444),
    bgColor: const Color(0xFFFFF1F2),
    borderColor: const Color(0xFFFECACA),
  ),
  StatusCardData(
    label: 'Called',
    count: 0,
    icon: Icons.call_made_rounded,
    iconColor: const Color(0xFF8B5CF6),
    bgColor: const Color(0xFFF5F3FF),
    borderColor: const Color(0xFFDDD6FE),
  ),
  StatusCardData(
    label: 'Transferred',
    count: 2,
    icon: Icons.swap_horiz_rounded,
    iconColor: const Color(0xFF0D9488),
    bgColor: const Color(0xFFF0FDFA),
    borderColor: const Color(0xFF99F6E4),
  ),
  StatusCardData(
    label: 'Closed',
    count: 0,
    icon: Icons.check_circle_outline_rounded,
    iconColor: const Color(0xFF22C55E),
    bgColor: const Color(0xFFF0FDF4),
    borderColor: const Color(0xFFBBF7D0),
  ),
];

// ─────────────────────────────────────────────
// ANALYTICS DUMMY DATA
// ─────────────────────────────────────────────

const List<AnalyticsItem> _agentItems = [
  AnalyticsItem(
    label: 'Fairooza',
    count: 37,
    percentage: 0.92,
    progressColor: Color(0xFF2F80ED),
  ),
  AnalyticsItem(
    label: 'Farsana',
    count: 2,
    percentage: 0.05,
    progressColor: Color(0xFF2F80ED),
  ),
  AnalyticsItem(
    label: 'Shahid',
    count: 1,
    percentage: 0.02,
    progressColor: Color(0xFFFFC107),
  ),
];

const List<AnalyticsItem> _categoryItems = [
  AnalyticsItem(
    label: 'Not Contacted',
    count: 29,
    percentage: 0.72,
    progressColor: Color(0xFFE53935),
  ),
  AnalyticsItem(
    label: 'Need Further Followup',
    count: 8,
    percentage: 0.20,
    progressColor: Color(0xFF43A047),
  ),
  AnalyticsItem(
    label: 'Uncategorized',
    count: 2,
    percentage: 0.05,
    progressColor: Color(0xFFE53935),
  ),
  AnalyticsItem(
    label: 'Fake',
    count: 1,
    percentage: 0.02,
    progressColor: Color(0xFF8E24AA),
  ),
];

// ─────────────────────────────────────────────
// LEAD LIST SCREEN
// ─────────────────────────────────────────────

class LeadListScreen extends StatefulWidget {
  /// Passed from LeadManagmentScreen; reserved for tab-specific logic.
  final int selectedTab;

  const LeadListScreen({super.key, required this.selectedTab});

  @override
  State<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen> {
  // ── Report toggle ─────────────────────────────────────────────────────────
  bool _isReportView = false;

  // ── Close notifiers for swipe cards ──────────────────────────────────────
  late final List<ValueNotifier<bool>> _closeNotifiers;

  // // ── Lead data ─────────────────────────────────────────────────────────────
  final List<LeadData> _leads = [
    LeadData(
      name: 'AJMAL',
      phone: '+917034561968',
      assignedTo: 'Farsana',
      category: 'Uncategorized',
      status: 'Transferred',
      statusDotColor: AppColors.teal,
      notificationCount: 2,
    ),
    LeadData(
      name: 'unknown number',
      phone: '+91907503430',
      assignedTo: 'Farsana',
      category: 'Uncategorized',
      status: 'New',
      statusDotColor: AppColors.skyBlue,
      notificationCount: 0,
    ),
    LeadData(
      name: 'RAHUL NAIR',
      phone: '+919876543210',
      assignedTo: 'Arun',
      category: 'Hot Lead',
      status: 'Followup',
      statusDotColor: const Color(0xFFF59E0B),
      notificationCount: 1,
    ),
    LeadData(
      name: 'PRIYA MENON',
      phone: '+918765432109',
      assignedTo: 'Sreeja',
      category: 'Uncategorized',
      status: 'Closed',
      statusDotColor: const Color(0xFF22C55E),
      notificationCount: 0,
    ),
  ];
  // ── Lead data ─────────────────────────────────────────────────────────────
  // final List<LeadData> _leads = List.generate(
  //   5,
  //   (index) => LeadData(
  //     name: 'PRIYA MENON',
  //     phone: '+918765432109',
  //     assignedTo: 'Sreeja',
  //     category: 'Uncategorized',
  //     status: 'New',
  //     statusDotColor: const Color(0xFF22C55E),
  //     notificationCount: 1,
  //   ),
  // );

  // ── Selected status filter ────────────────────────────────────────────────
  String _selectedStatus = 'New';

  // ── Filtered leads getter ─────────────────────────────────────────────────
  List<LeadData> get _filteredLeads {
    switch (_selectedStatus) {
      case 'New':
        return _leads.where((e) => e.status == 'New').toList();
      case 'Followup':
        return _leads.where((e) => e.status == 'Followup').toList();
      case 'Transferred':
        return _leads.where((e) => e.status == 'Transferred').toList();
      case 'Closed':
        return _leads.where((e) => e.status == 'Closed').toList();
      case 'Called':
        return _leads.where((e) => e.status == 'Followup').toList();
      case 'Missed':
        return _leads;
      default:
        return _leads;
    }
  }

  // ── Notifiers sliced to match _filteredLeads ──────────────────────────────
  List<ValueNotifier<bool>> get _filteredCloseNotifiers {
    return _filteredLeads
        .map((lead) => _closeNotifiers[_leads.indexOf(lead)])
        .toList();
  }

  // ── Computed getter ───────────────────────────────────────────────────────
  bool get _areAllExpanded => _leads.every((lead) => lead.isExpanded);

  // ── Global expand/collapse toggle ─────────────────────────────────────────
  void _toggleAllExpanded() {
    final expand = !_areAllExpanded;
    setState(() {
      for (final lead in _leads) {
        lead.isExpanded = expand;
      }
    });
  }

  // ── Report button handler ─────────────────────────────────────────────────
  void _onChartTap() => setState(() => _isReportView = !_isReportView);

  @override
  void initState() {
    super.initState();
    _closeNotifiers = List.generate(_leads.length, (_) => ValueNotifier(false));
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
    return Container(
      color: const Color(0xFFF3F4F6),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
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
                      Container(
                        width: 9.w,
                        height: 4.5.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2.5.w),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
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
                    ],
                  ),
                  SizedBox(height: 1.8.h),

                  // Status cards grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: statusCards.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2.w,
                      mainAxisSpacing: 2.w,
                      childAspectRatio: 0.88,
                    ),
                    itemBuilder: (context, index) => StatusCard(
                      data: statusCards[index],
                      isSelected: _selectedStatus == statusCards[index].label,
                      onTap: () => setState(
                        () => _selectedStatus = statusCards[index].label,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Section header
                  SectionHeader(
                    title: 'New Leads',
                    subtitle: '40 Leads',
                    isReportActive: _isReportView,
                    areAllExpanded: _areAllExpanded,
                    onAdd: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CreateLeadScreen()),
                      );
                    },
                    onChart: _onChartTap,
                    onFilter: () => showFilterBottomSheet(context),
                    onSearch: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchScreen()),
                      );
                    },
                    onDownload: () {},
                    onmenu: _toggleAllExpanded,
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
                      child: _ReportSection(key: const ValueKey('report')),
                    )
                  : Padding(
                      padding: EdgeInsets.only(bottom: 13.w),
                      // child: _LeadListSection(
                      //   key: const ValueKey('leads'),
                      //   leads: _leads,
                      //   closeNotifiers: _closeNotifiers,
                      //   onToggleExpand: (index) {
                      //     setState(() {
                      //       _leads[index].isExpanded =
                      //           !_leads[index].isExpanded;
                      //     });
                      //   },
                      //   onSwipeOpen: (index) {
                      //     for (int i = 0; i < _closeNotifiers.length; i++) {
                      //       if (i != index) {
                      //         _closeNotifiers[i].value = true;
                      //         Future.microtask(
                      //           () => _closeNotifiers[i].value = false,
                      //         );
                      //       }
                      //     }
                      //   },
                      // ),
                      child: LeadListWidget(
                        key: const ValueKey('leads'),
                        leads: _filteredLeads,
                        closeNotifiers: _filteredCloseNotifiers,
                        onToggleExpand: (index) {
                          final lead = _filteredLeads[index];
                          setState(() => lead.isExpanded = !lead.isExpanded);
                        },
                        onSwipeOpen: (index) {
                          for (int i = 0; i < _closeNotifiers.length; i++) {
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
    );
  }
}

// ─────────────────────────────────────────────
// LEAD LIST SECTION
// ─────────────────────────────────────────────

// class _LeadListSection extends StatelessWidget {
//   final List<LeadData> leads;
//   final List<ValueNotifier<bool>> closeNotifiers;
//   final void Function(int index) onToggleExpand;
//   final void Function(int index) onSwipeOpen;

//   const _LeadListSection({
//     super.key,
//     required this.leads,
//     required this.closeNotifiers,
//     required this.onToggleExpand,
//     required this.onSwipeOpen,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 3.h),
//       child: Column(
//         children: List.generate(leads.length, (index) {
//           return Padding(
//             padding: EdgeInsets.only(bottom: 1.2.h),
//             child: LeadCard(
//               data: leads[index],
//               closeNotifier: closeNotifiers[index],
//               onSwipeOpen: () => onSwipeOpen(index),
//               onToggleExpand: () => onToggleExpand(index),
//               onCall: () {},
//               onMessage: () {},
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
class LeadListWidget extends StatelessWidget {
  final List<LeadData> leads;
  final List<ValueNotifier<bool>> closeNotifiers;
  final void Function(int index) onToggleExpand;
  final void Function(int index) onSwipeOpen;

  const LeadListWidget({
    super.key,
    required this.leads,
    required this.closeNotifiers,
    required this.onToggleExpand,
    required this.onSwipeOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 3.h),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: leads.length,
        separatorBuilder: (_, __) => SizedBox(height: 1.2.h),
        itemBuilder: (_, index) => LeadCard(
          data: leads[index],
          closeNotifier: closeNotifiers[index],
          onSwipeOpen: () => onSwipeOpen(index),
          onToggleExpand: () => onToggleExpand(index),
          onCall: () {},
          onMessage: () {},
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REPORT SECTION
// ─────────────────────────────────────────────

class _ReportSection extends StatelessWidget {
  const _ReportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: AnalyticsCard(
        agentItems: _agentItems,
        categoryItems: _categoryItems,
        summaryLabel: 'Total New Generated',
        summaryValue: '40 Leads',
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STATUS CARD
// ─────────────────────────────────────────────

class StatusCard extends StatelessWidget {
  final StatusCardData data;
  final bool isSelected;
  final VoidCallback onTap;

  const StatusCard({
    super.key,
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? data.bgColor.withOpacity(0.85) : data.bgColor,
          borderRadius: BorderRadius.circular(5.w),
          border: Border.all(
            color: isSelected ? data.iconColor : data.borderColor,
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? data.iconColor.withOpacity(0.22)
                  : data.iconColor.withOpacity(0.08),
              blurRadius: isSelected ? 18 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.8.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 9.5.w,
              padding: EdgeInsets.all(0.5.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? data.iconColor.withOpacity(0.20)
                    : data.iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(2.8.w),
              ),
              child: Icon(data.icon, color: data.iconColor, size: 6.w),
            ),
            SizedBox(height: 1.h),
            Text(
              data.count.toString(),
              style: TextStyle(
                fontSize: 17.5.sp,
                fontWeight: FontWeight.w800,
                color: data.iconColor,
                height: 1.1,
              ),
            ),
            SizedBox(height: 0.4.h),
            Text(
              data.label,
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? data.iconColor : const Color(0xFF6B7280),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isReportActive;
  final bool areAllExpanded;
  final VoidCallback onAdd;
  final VoidCallback onChart;
  final VoidCallback onFilter;
  final VoidCallback onSearch;
  final VoidCallback onDownload;
  final VoidCallback onmenu;

  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.isReportActive = false,
    this.areAllExpanded = false,
    required this.onAdd,
    required this.onChart,
    required this.onFilter,
    required this.onSearch,
    required this.onDownload,
    required this.onmenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15.5.sp,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              ActionButton(
                icon: Icons.add_rounded,
                onTap: onAdd,
                bgColor: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF16A34A),
              ),
              SizedBox(width: 1.5.w),
              ActionButton(
                icon: Icons.bar_chart_rounded,
                onTap: onChart,
                bgColor: isReportActive
                    ? AppColors.bottomNavBlue.withOpacity(0.15)
                    : const Color(0xFFF3F4F6),
                iconColor: isReportActive
                    ? AppColors.bottomNavBlue
                    : const Color(0xFF6B7280),
              ),
              SizedBox(width: 1.5.w),
              ActionButton(
                icon: Icons.tune_rounded,
                onTap: onFilter,
                bgColor: const Color(0xFFF3F4F6),
                iconColor: const Color(0xFF6B7280),
              ),
              SizedBox(width: 1.5.w),
              ActionButton(
                icon: Icons.search_rounded,
                onTap: onSearch,
                bgColor: AppColors.bottomNavBlue,
                iconColor: Colors.white,
              ),
              SizedBox(width: 1.5.w),
              ActionButton(
                icon: Icons.arrow_downward_rounded,
                onTap: onDownload,
                bgColor: const Color(0xFFF3F4F6),
                iconColor: const Color(0xFF6B7280),
              ),
              SizedBox(width: 1.5.w),
              ActionButton(
                icon: areAllExpanded
                    ? Icons.table_rows
                    : Icons.table_rows_outlined,
                onTap: onmenu,
                bgColor: const Color(0xFFF3F4F6),
                iconColor: const Color(0xFF6B7280),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ACTION BUTTON
// ─────────────────────────────────────────────

class ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color bgColor;
  final Color iconColor;

  const ActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 8.5.w,
        height: 4.2.h,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(2.5.w),
        ),
        child: Icon(icon, size: 4.3.w, color: iconColor),
      ),
    );
  }
}
