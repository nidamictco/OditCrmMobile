import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/core/utils/bottom_navigation.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_state.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/screens/filtering.dart';
import 'package:odit_crm_mobile/feature/home/search_screen.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/screens/add_lead.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_cubit.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/screens/lead_management.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/dashboard_status_card.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/lead_list.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/quick_action_card.dart';
import 'package:odit_crm_mobile/feature/reports/presentation/lead_report_screen.dart';
import 'package:sizer/sizer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddLeadCubit, AddLeadState>(
      builder: (context, state) {
        if (state.listStatus == LeadListStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
        final monthStart = DateTime(now.year, now.month, 1);

        final totalLeads = state.leads;

        // New Card calculations
        final newLeads = totalLeads
            .where((e) => e.leadStage.toUpperCase() == 'NEW')
            .toList();
        final newCount = newLeads.length;
        final newTodays = newLeads
            .where(
              (e) =>
                  e.createdAt != null &&
                  !e.createdAt!.isBefore(todayStart) &&
                  !e.createdAt!.isAfter(todayEnd),
            )
            .length;
        final missedCount = totalLeads
            .where(
              (e) =>
                  (e.leadStage.toUpperCase() == 'NEW') &&
                  e.createdAt != null &&
                  e.createdAt!.isBefore(todayStart),
            )
            .length;

        // Closed Card calculations
        final closedLeads = totalLeads
            .where((e) => e.leadStage.toUpperCase() == 'CLOSED')
            .toList();
        final closedCount = closedLeads.length;
        final closedTodays = closedLeads
            .where(
              (e) =>
                  (e.calledDate ?? e.createdAt) != null &&
                  !(e.calledDate ?? e.createdAt)!.isBefore(todayStart) &&
                  !(e.calledDate ?? e.createdAt)!.isAfter(todayEnd),
            )
            .length;
        final closedThisMonth = closedLeads
            .where(
              (e) =>
                  (e.calledDate ?? e.createdAt) != null &&
                  !(e.calledDate ?? e.createdAt)!.isBefore(monthStart) &&
                  !(e.calledDate ?? e.createdAt)!.isAfter(todayEnd),
            )
            .length;

        // Active Card calculations
        final activeCount = totalLeads
            .where((e) => e.leadStage.toUpperCase() == 'FOLLOWUP')
            .length;

        final activeTodays = totalLeads
            .where(
              (e) =>
                  e.leadStage.toUpperCase() == 'FOLLOWUP' &&
                  e.followUpDate != null &&
                  !e.followUpDate!.isBefore(todayStart) &&
                  !e.followUpDate!.isAfter(todayEnd),
            )
            .length;

        final activeMissed = totalLeads
            .where(
              (e) =>
                  e.leadStage.toUpperCase() == 'FOLLOWUP' &&
                  e.followUpDate != null &&
                  e.followUpDate!.isBefore(todayStart),
            )
            .length;
        log(
          'activeTodays : $activeTodays  && activeMissed : $activeMissed  \n totalLeads : ${totalLeads.length} \n  ${totalLeads.where((e) => e.leadStage.toUpperCase() == 'NEW').toList()}',
        );
        // Lost Card calculations
        final lostLeads = totalLeads
            .where((e) => e.leadStage.toUpperCase() == 'REJECTED')
            .toList();
        final lostCount = lostLeads.length;
        final lostTodays = lostLeads
            .where(
              (e) =>
                  (e.updatedAt ?? e.createdAt) != null &&
                  !(e.updatedAt ?? e.createdAt)!.isBefore(todayStart) &&
                  !(e.updatedAt ?? e.createdAt)!.isAfter(todayEnd),
            )
            .length;
        final lostThisMonth = lostLeads
            .where(
              (e) =>
                  (e.updatedAt ?? e.createdAt) != null &&
                  !(e.updatedAt ?? e.createdAt)!.isBefore(monthStart) &&
                  !(e.updatedAt ?? e.createdAt)!.isAfter(todayEnd),
            )
            .length;

        return Container(
          color: const Color(0xFFE8EEF7),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Quick Actions ───────────────────────────────────────────
                _QuickActionsCard(),
                SizedBox(height: 2.5.h),

                // ── Stats grid ──────────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column
                    Expanded(
                      child: Column(
                        children: [
                          // New
                          DashboardStatCard(
                            title: 'New',
                            count: newCount.toString(),
                            backgroundColor: const Color(0xFF2E7DD1),
                            watermarkIcon: Icons.person_outline_rounded,
                            variant: StatCardVariant.twoLabel,
                            leftLabel: "Today's",
                            leftValue: newTodays.toString(),
                            rightLabel: 'Missed',
                            rightValue: missedCount.toString(),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LeadReportScreen(
                                    reportType: LeadReportType.newLead,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 2.w),

                          // Closed
                          DashboardStatCard(
                            title: 'Closed',
                            count: closedCount.toString(),
                            backgroundColor: const Color(0xFF3DAA5C),
                            watermarkIcon: Icons.check_circle_outline_rounded,
                            variant: StatCardVariant.twoLabelWithFilter,
                            showFilterButton: false,
                            leftLabel: "Today's",
                            leftValue: closedTodays.toString(),
                            rightLabel: 'This month',
                            rightValue: closedThisMonth.toString(),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LeadReportScreen(
                                    reportType: LeadReportType.closed,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 2.w),

                    // Right column
                    Expanded(
                      child: Column(
                        children: [
                          // Active
                          DashboardStatCard(
                            title: 'Active',
                            count: activeCount.toString(),
                            backgroundColor: const Color(0xFFF5891A),
                            watermarkIcon: Icons.people_outline_rounded,
                            variant: StatCardVariant.twoLabel,

                            // actionIcons: const [
                            //   Icons.people_alt_rounded,
                            //   Icons.category_outlined,
                            //   Icons.assignment_outlined,
                            // ],
                            // onActionTaps: [
                            //   () {},
                            //   () => showFilterBottomSheet(context),
                            //   () {},
                            // ],
                            leftLabel: "Today's",
                            leftValue: activeTodays.toString(), // ✅ fixed
                            rightLabel: 'Missed',
                            rightValue: activeMissed.toString(), // ✅ fixed
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LeadReportScreen(
                                    reportType: LeadReportType.followup,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 2.w),

                          // Lost
                          DashboardStatCard(
                            title: 'Lost',
                            count: lostCount.toString(),
                            backgroundColor: const Color(0xFFD94040),
                            watermarkIcon: Icons.remove_circle_outline_rounded,
                            variant: StatCardVariant.twoLabelWithFilter,
                            showFilterButton: false,
                            leftLabel: "Today's",
                            leftValue: lostTodays.toString(),
                            rightLabel: 'This month',
                            rightValue: lostThisMonth.toString(),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LeadReportScreen(
                                    reportType: LeadReportType.rejected,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Actions card
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: 1.8.h),
          Row(
            children: [
              QuickActionCard(
                title: 'Add Lead',
                icon: Icons.person_add_alt_1_rounded,
                backgroundColor: const Color(0xFFECFDF5),
                iconColor: const Color(0xFF16A34A),
                borderColor: const Color(0xFFBBF7D0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateLeadScreen()),
                  );
                },
              ),
              SizedBox(width: 3.w),
              QuickActionCard(
                title: 'Search',
                icon: Icons.search_rounded,
                backgroundColor: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF3B82F6),
                borderColor: const Color(0xFFBFDBFE),
                onTap: () {
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
              ),
              SizedBox(width: 3.w),
              // QuickActionCard(
              //   // title: 'Call History',
              //   // icon: Icons.history_rounded,
              //   // backgroundColor: const Color(0xFFFFFBEB),
              //   // iconColor: const Color(0xFFF59E0B),
              //   // borderColor: const Color(0xFFFDE68A),
              //   // onTap: () {
              //   //   Navigator.push(
              //   //     context,
              //   //     MaterialPageRoute(
              //   //       builder: (_) => CustomBottomNavScreen(
              //   //         initialStatus: 'Called',
              //   //         index: 1,
              //   //       ),
              //   //     ),
              //   //   );
              //   // },
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
