import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/core/utils/app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_cubit.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/dashboard_screen.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/lead_list.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/report_screen.dart';
import 'package:sizer/sizer.dart';

class LeadManagmentScreen extends StatelessWidget {
  const LeadManagmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LeadManagmentScreenBody();
  }
}

class LeadManagmentScreenBody extends StatefulWidget {
  const LeadManagmentScreenBody({super.key});

  @override
  State<LeadManagmentScreenBody> createState() => _LeadManagmentScreenBodyState();
}

class _LeadManagmentScreenBodyState extends State<LeadManagmentScreenBody> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        avatarImagePath: null,
        onAvatarTap: () {},
        onNotificationTap: () {},
        onMoreTap: () {},
      ),
      body: Column(
        children: [
          // ── Segmented Tab Bar ─────────────────────────────────────────
          Container(
            color: const Color(0xFFF3F4F6),
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.5.h),
            child: _SegmentedTabBar(
              selectedIndex: _selectedTab,
              onTabChanged: (i) => setState(() => _selectedTab = i),
            ),
          ),

          // ── Content Area ──────────────────────────────────────────────
          // IndexedStack keeps all three screens alive so state is
          // preserved when the user switches tabs.
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: const [
                // Tab 0 — List
                LeadListScreen(selectedTab: 0),

                // Tab 1 — Dashboard
                DashboardScreen(),

                // Tab 2 — Report (placeholder; swap in your real screen)
                ReportScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SEGMENTED TAB BAR
// ─────────────────────────────────────────────

class _SegmentedTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const _SegmentedTabBar({
    required this.selectedIndex,
    required this.onTabChanged,
  });

  static const _tabs = ['LIST', 'DASHBOARD', 'REPORT'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5.5.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(3.5.w),
      ),
      padding: EdgeInsets.all(1.w),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final isSelected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.bottomNavBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(2.5.w),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.bottomNavBlue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  _tabs[i],
                  style: TextStyle(
                    fontSize: 15.4.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color:
                        isSelected ? Colors.white : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}