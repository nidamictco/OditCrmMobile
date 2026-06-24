import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/lead_data.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/analytics_card.dart';
import 'package:sizer/sizer.dart';

const List<Color> _kColors = [
  Color(0xFF2F80ED), // Blue
  Color(0xFF43A047), // Green
  Color(0xFFFFC107), // Yellow
  Color(0xFFE53935), // Red
  Color(0xFF8E24AA), // Purple
  Color(0xFF56CCF2), // Cyan
  Color(0xFFF2C94C), // Amber
  Color(0xFF27AE60), // Emerald
];

class ReportSection extends StatelessWidget {
  final List<LeadData> leads;
  final String selectedStatus;

  const ReportSection({
    super.key,
    required this.leads,
    required this.selectedStatus,
  });

  String _formatName(String raw, String defaultName) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return defaultName;
    return trimmed.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _getSummaryLabel(String status) {
    switch (status.trim()) {
      case 'New':
        return 'Total New Generated';
      case 'Followup':
        return 'Total Followup Leads';
      case 'Missed':
        return 'Total Missed Leads';
      case 'Called':
        return 'Total Called Leads';
      case 'Transferred':
        return 'Total Transferred Leads';
      case 'Closed':
        return 'Total Closed Leads';
      default:
        return 'Total $status Leads';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (leads.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Text(
            'No Report Data Available',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    final totalLeads = leads.length;

    // Agent Wise Report
    final Map<String, int> agentCounts = {};
    for (final lead in leads) {
      final name = _formatName(lead.assignedTo, 'Unassigned');
      agentCounts[name] = (agentCounts[name] ?? 0) + 1;
    }

    final agentEntries = agentCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final List<AnalyticsItem> agentItems = [];
    for (int i = 0; i < agentEntries.length; i++) {
      final entry = agentEntries[i];
      agentItems.add(
        AnalyticsItem(
          label: entry.key,
          count: entry.value,
          percentage: totalLeads > 0 ? (entry.value / totalLeads) : 0.0,
          progressColor: _kColors[i % _kColors.length],
        ),
      );
    }

    // Category Wise Report
    final Map<String, int> categoryCounts = {};
    for (final lead in leads) {
      final name = _formatName(lead.category, 'Uncategorized');
      categoryCounts[name] = (categoryCounts[name] ?? 0) + 1;
    }

    final categoryEntries = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final List<AnalyticsItem> categoryItems = [];
    for (int i = 0; i < categoryEntries.length; i++) {
      final entry = categoryEntries[i];
      categoryItems.add(
        AnalyticsItem(
          label: entry.key,
          count: entry.value,
          percentage: totalLeads > 0 ? (entry.value / totalLeads) : 0.0,
          progressColor: _kColors[i % _kColors.length],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: AnalyticsCard(
        agentItems: agentItems,
        categoryItems: categoryItems,
        summaryLabel: _getSummaryLabel(selectedStatus),
        summaryValue: '$totalLeads ${totalLeads == 1 ? "Lead" : "Leads"}',
      ),
    );
  }
}
