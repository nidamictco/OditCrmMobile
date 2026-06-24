import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:sizer/sizer.dart';

class LeadTabBar extends StatelessWidget {
  final String selectedTab;
  final List<String> tabs;
  final ValueChanged<String> onTabChanged;

  const LeadTabBar({
    super.key,
    required this.selectedTab,
    required this.tabs,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.5.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: tabs.map((tab) {
          final isSelected = tab == selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.bottomNavBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  tab,
                  style: TextStyle( 
                    fontSize: 14.5.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF555555),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
