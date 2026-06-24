import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_cubit.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_state.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/screens/filtering.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/add_lead_model.dart';
import 'package:sizer/sizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// REPORT SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  FilterResult? _reportFilters;

  @override
  void initState() {
    super.initState();
    context.read<AddLeadCubit>().fetchStaff();
  }

  String _getTodayString() {
    final d = DateTime.now();
    return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  }

  List<AddLeadModel> _getFilteredReportLeads(List<AddLeadModel> leads) {
    if (_reportFilters == null || _reportFilters!.isCleared) return leads;

    final todayStr = _getTodayString();
    final hasDateFilter = _reportFilters!.fromDate != todayStr || _reportFilters!.toDate != todayStr;
    final staffSet = _reportFilters!.selectedItems['Assigned Staff'];
    final hasStaffFilter = staffSet != null && staffSet.isNotEmpty;

    if (!hasDateFilter && !hasStaffFilter) {
      return leads;
    }

    return leads.where((lead) {
      // 1. Date filter
      if (hasDateFilter) {
        final start = _parseDate(_reportFilters!.fromDate);
        final end = _parseDate(_reportFilters!.toDate);
        if (start != null && end != null) {
          final startOfDay = DateTime(start.year, start.month, start.day);
          final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
          if (lead.createdAt == null) return false;
          if (lead.createdAt!.isBefore(startOfDay) ||
              lead.createdAt!.isAfter(endOfDay)) {
            return false;
          }
        }
      }

      // 2. Staff filter
      if (hasStaffFilter) {
        if (!staffSet.contains(lead.assignedStaff)) {
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

  String _getDateText() {
    if (_reportFilters == null || _reportFilters!.isCleared) return 'Showing all data';
    final todayStr = _getTodayString();
    final hasDateFilter = _reportFilters!.fromDate != todayStr || _reportFilters!.toDate != todayStr;
    final staffSet = _reportFilters!.selectedItems['Assigned Staff'];
    final hasStaffFilter = staffSet != null && staffSet.isNotEmpty;

    if (!hasDateFilter && !hasStaffFilter) {
      return 'Showing all data';
    }

    final staffText = hasStaffFilter
        ? '\nStaff : ${staffSet.join(', ')}'
        : '';
    return '${_reportFilters!.fromDate} → ${_reportFilters!.toDate}$staffText';
  }

  Future<void> _handleFilterTap() async {
    final result = await showFilterBottomSheet(
      context,
      initialFilters: _reportFilters,
      isReportFilter: true,
    );
    if (result != null) {
      final todayStr = _getTodayString();
      final hasDateFilter = result.fromDate != todayStr || result.toDate != todayStr;
      final hasStaffFilter = result.selectedItems['Assigned Staff']?.isNotEmpty ?? false;
      final hasFilters = !result.isCleared && (hasDateFilter || hasStaffFilter);

      setState(() {
        if (hasFilters) {
          _reportFilters = result;
        } else {
          _reportFilters = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddLeadCubit, AddLeadState>(
      builder: (context, state) {
        if (state.listStatus == LeadListStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredLeads = _getFilteredReportLeads(state.leads);

        return Container(
          color: const Color(0xFFEFF7FF),
          child: RefreshIndicator(
            onRefresh: () => context.read<AddLeadCubit>().fetchLeads(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SECTION 1: Call Status Report
                  ReportHeaderWidget(
                    icon: Icons.phone_outlined,
                    title: 'Call Status Report',
                    dateText: _getDateText(),
                    updatedTime: 'Real-time',
                    onFilterTap: _handleFilterTap,
                  ),
                  SizedBox(height: 1.5.h),
                  CallStatusReportCard(leads: filteredLeads),
                  SizedBox(height: 3.h),

                  // SECTION 2: Active Lead Summary
                  ReportHeaderWidget(
                    icon: Icons.pie_chart_outline,
                    title: 'Active Lead Summary',
                    dateText: _getDateText(),
                    updatedTime: 'Real-time',
                    onFilterTap: _handleFilterTap,
                  ),
                  SizedBox(height: 1.5.h),
                  ActiveLeadSummaryCard(leads: filteredLeads),
                  SizedBox(height: 3.h),

                  // SECTION 3: Lead Source Report
                  ReportHeaderWidget(
                    icon: Icons.folder_open_outlined,
                    title: 'Lead Source Report',
                    dateText: _getDateText(),
                    updatedTime: 'Real-time',
                    onFilterTap: _handleFilterTap,
                  ),
                  SizedBox(height: 1.5.h),
                  LeadSourceCard(leads: filteredLeads),
                  SizedBox(height: 3.h),

                  // SECTION 4: Category Report
                  ReportHeaderWidget(
                    icon: Icons.category_outlined,
                    title: 'Category Report',
                    dateText: _getDateText(),
                    updatedTime: 'Real-time',
                    onFilterTap: _handleFilterTap,
                  ),
                  SizedBox(height: 1.5.h),
                  CategoryReportCard(leads: filteredLeads),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class ReportHeaderWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String dateText;
  final String updatedTime;
  final VoidCallback? onFilterTap;

  const ReportHeaderWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.dateText,
    required this.updatedTime,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(
                color: const Color(0xFFDCEFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.bottomNavBlue, size: 20.sp),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E3A59),
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 0.3.h),
                        child: Icon(
                          Icons.calendar_today_outlined,
                          size: 14.sp,
                          color: const Color(0xFF2F80ED),
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          dateText,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: const Color(0xFF2F80ED),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionButton(Icons.filter_alt_outlined, onFilterTap),
              ],
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Padding(
          padding: EdgeInsets.only(left: 14.w),
          child: Row(
            children: [
              Icon(Icons.history, size: 13.sp, color: Colors.grey.shade400),
              SizedBox(width: 1.w),
              Text(
                updatedTime,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
              ),
              SizedBox(width: 1.5.w),
              GestureDetector(
                onTap: () {
                  context.read<AddLeadCubit>().fetchLeads();
                },
                child: Icon(
                  Icons.refresh,
                  size: 14.sp,
                  color: const Color(0xFF2F80ED),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData iconData, VoidCallback? onPressed) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5FF),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(iconData, color: AppColors.bottomNavBlue, size: 17.sp),
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double borderRadiusValue;

  const ReportCard({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderRadiusValue = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadiusValue),
        boxShadow: [
          if (backgroundColor == Colors.white)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: child,
    );
  }
}

class ProgressAnalyticsRow extends StatelessWidget {
  final String title;
  final int count;
  final double percentage;
  final Color progressColor;
  final bool isDarkBackground;

  const ProgressAnalyticsRow({
    super.key,
    required this.title,
    required this.count,
    required this.percentage,
    required this.progressColor,
    this.isDarkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleColor = isDarkBackground
        ? Colors.grey.shade400
        : Colors.black54;

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor,
                ),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isDarkBackground
                      ? progressColor
                      : AppColors.bottomNavBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 10,
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: isDarkBackground
                    ? Colors.grey.shade800
                    : progressColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INDIVIDUAL CARDS
// ─────────────────────────────────────────────────────────────────────────────

class CallStatusReportCard extends StatelessWidget {
  final List<AddLeadModel> leads;

  const CallStatusReportCard({super.key, required this.leads});

  @override
  Widget build(BuildContext context) {
    final connected = leads
        .where((e) => e.callResult?.toLowerCase() == 'connected')
        .length;
    final busy = leads
        .where((e) => e.callResult?.toLowerCase() == 'busy')
        .length;
    final rejected = leads
        .where((e) => e.callResult?.toLowerCase() == 'rejected')
        .length;
    final switchedOff = leads
        .where((e) => e.callResult?.toLowerCase() == 'switched off')
        .length;
    final outOfCoverage = leads
        .where((e) => e.callResult?.toLowerCase().contains('coverage') == true)
        .length;
    final notAttended = leads
        .where((e) => e.callResult?.toLowerCase() == 'not attended')
        .length;

    final total =
        connected + busy + rejected + switchedOff + outOfCoverage + notAttended;

    double pct(int count) => total > 0 ? count / total : 0.0;

    return ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Response Analytics',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E3A59),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Total: $total',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2F80ED),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          ProgressAnalyticsRow(
            title: 'Connected',
            count: connected,
            percentage: pct(connected),
            progressColor: const Color(0xFF2F80ED),
          ),
          ProgressAnalyticsRow(
            title: 'Busy',
            count: busy,
            percentage: pct(busy),
            progressColor: const Color(0xFF56CCF2),
          ),
          ProgressAnalyticsRow(
            title: 'Rejected',
            count: rejected,
            percentage: pct(rejected),
            progressColor: const Color(0xFFEB5757),
          ),
          ProgressAnalyticsRow(
            title: 'Switched off',
            count: switchedOff,
            percentage: pct(switchedOff),
            progressColor: const Color(0xFFF2C94C),
          ),
          ProgressAnalyticsRow(
            title: 'Out of Coverage Area',
            count: outOfCoverage,
            percentage: pct(outOfCoverage),
            progressColor: const Color(0xFF27AE60),
          ),
          ProgressAnalyticsRow(
            title: 'Not Attended',
            count: notAttended,
            percentage: pct(notAttended),
            progressColor: const Color(0xFF9B51E0),
          ),
        ],
      ),
    );
  }
}

class CircularSummaryCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const CircularSummaryCard({
    super.key,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 75,
              height: 75,
              child: CircularProgressIndicator(
                value: count > 0 ? 0.75 : 0.0,
                strokeWidth: 6,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

class ActiveLeadSummaryCard extends StatelessWidget {
  final List<AddLeadModel> leads;

  const ActiveLeadSummaryCard({super.key, required this.leads});

  @override
  Widget build(BuildContext context) {
    final followup = leads
        .where(
          (e) =>
              e.leadStage.toUpperCase() == 'FOLLOWUP' ||
              e.leadStage.toUpperCase() == 'FOLLOW UP',
        )
        .length;
    final transferred = leads
        .where((e) => e.leadStage.toUpperCase() == 'TRANSFERRED')
        .length;

    return ReportCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircularSummaryCard(
            count: followup,
            label: 'Follow Up',
            color: const Color(0xFFF2C94C),
          ),
          CircularSummaryCard(
            count: transferred,
            label: 'Transferred',
            color: const Color(0xFF27AE60),
          ),
        ],
      ),
    );
  }
}

class LeadSourceCard extends StatefulWidget {
  final List<AddLeadModel> leads;

  const LeadSourceCard({super.key, required this.leads});

  @override
  State<LeadSourceCard> createState() => _LeadSourceCardState();
}

class _LeadSourceCardState extends State<LeadSourceCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final leads = widget.leads;

    final Map<String, int> sourceCounts = {};
    for (var lead in leads) {
      final src = lead.leadSource.isNotEmpty ? lead.leadSource : 'Unknown';
      sourceCounts[src] = (sourceCounts[src] ?? 0) + 1;
    }

    final total = leads.length;
    final sortedSources = sourceCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final displayedSources = _isExpanded
        ? sortedSources
        : sortedSources.take(5).toList();

    return ReportCard(
      backgroundColor: Colors.black,
      child: Column(
        children: [
          if (sortedSources.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Text(
                'No source data available',
                style: TextStyle(color: Colors.white70, fontSize: 14.sp),
              ),
            )
          else
            ...displayedSources.map((entry) {
              final pct = total > 0 ? entry.value / total : 0.0;
              return ProgressAnalyticsRow(
                title: entry.key,
                count: entry.value,
                percentage: pct,
                progressColor: const Color(0xFF2F80ED),
                isDarkBackground: true,
              );
            }),
          if (sortedSources.length > 5) ...[
            SizedBox(height: 1.h),
            Center(
              child: InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 14.sp,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      _isExpanded ? 'Show Less' : 'Show More',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CategoryReportCard extends StatefulWidget {
  final List<AddLeadModel> leads;

  const CategoryReportCard({super.key, required this.leads});

  @override
  State<CategoryReportCard> createState() => _CategoryReportCardState();
}

class _CategoryReportCardState extends State<CategoryReportCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final leads = widget.leads;

    final Map<String, int> categoryCounts = {};
    for (var lead in leads) {
      final cat = lead.leadCategory.isNotEmpty
          ? lead.leadCategory
          : 'Uncategorized';
      categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
    }

    final total = leads.length;
    final sortedCategories = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final displayedCategories = _isExpanded
        ? sortedCategories
        : sortedCategories.take(5).toList();

    return ReportCard(
      child: Column(
        children: [
          if (sortedCategories.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Text(
                'No category data available',
                style: TextStyle(color: Colors.black54, fontSize: 14.sp),
              ),
            )
          else
            ...displayedCategories.map((entry) {
              final pct = total > 0 ? entry.value / total : 0.0;
              return ProgressAnalyticsRow(
                title: entry.key,
                count: entry.value,
                percentage: pct,
                progressColor: const Color(0xFF2F80ED),
              );
            }),
          if (sortedCategories.length > 5) ...[
            SizedBox(height: 1.h),
            Center(
              child: InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: const Color(0xFF2F80ED),
                      size: 14.sp,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      _isExpanded ? 'Show Less' : 'Show More',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2F80ED),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
