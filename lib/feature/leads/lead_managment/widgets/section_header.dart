import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/core/theme/assets_resources.dart';
import 'package:sizer/sizer.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isReportActive;
  final bool areAllExpanded;
  final bool isFilterActive;
  final IconData sortIcon;
  final Color sortBgColor;
  final Color sortIconColor;
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
    this.isFilterActive = false,
    this.sortIcon = Icons.arrow_downward_rounded,
    this.sortBgColor = const Color(0xFFF3F4F6),
    this.sortIconColor = const Color(0xFF6B7280),
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
            color: Colors.black.withValues(alpha: 0.05),
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
                iconAsset: AssetResources.reportIcon,
                onTap: onChart,
                bgColor: isReportActive
                    ? AppColors.bottomNavBlue
                    : const Color(0xFFF3F4F6),
                iconColor: isReportActive
                    ? Colors.white
                    : const Color(0xFF6B7280),
              ),
              SizedBox(width: 1.5.w),
              ActionButton(
                icon: Icons.filter_alt_outlined,
                onTap: onFilter,
                bgColor: isFilterActive
                    ? AppColors.bottomNavBlue
                    : const Color(0xFFF3F4F6),
                iconColor: isFilterActive
                    ? Colors.white
                    : const Color(0xFF6B7280),
              ),
              SizedBox(width: 1.5.w),
              ActionButton(
                icon: Icons.search_rounded,
                onTap: onSearch,
                bgColor: Color(0xFFF3F4F6),
                iconColor: Color(0xFF6B7280),
              ),
              SizedBox(width: 1.5.w),
              ActionButton(
                icon: sortIcon,
                onTap: onDownload,
                bgColor: sortBgColor,
                iconColor: sortIconColor,
              ),
              SizedBox(width: 1.5.w),
              ActionButton(
                // icon: areAllExpanded
                //     ?  Icons.table_rows_outlined
                //     :Icons.table_rows ,
                iconAsset: AssetResources.expand,

                onTap: onmenu,
                bgColor: areAllExpanded
                    ? AppColors.bottomNavBlue
                    : const Color(0xFFF3F4F6),
                iconColor: areAllExpanded
                    ? Colors.white
                    : const Color(0xFF6B7280),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData? icon;
  final VoidCallback onTap;
  final Color bgColor;
  final Color iconColor;
  final String? iconAsset;

  const ActionButton({
    super.key,
    this.icon,
    required this.onTap,
    required this.bgColor,
    required this.iconColor,
    this.iconAsset,
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
        child: iconAsset != null
            ? Padding(
                padding: EdgeInsets.all(2.w),
                child: Image.asset(
                  iconAsset!,
                  height: 4.3.w,
                  width: 4.3.w,
                  color: iconColor,
                ),
              )
            : Icon(icon, size: 4.3.w, color: iconColor),
      ),
    );
  }
}
