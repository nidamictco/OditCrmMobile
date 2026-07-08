import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

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

  StatusCardData copyWith({
    String? label,
    int? count,
    IconData? icon,
    Color? iconColor,
    Color? bgColor,
    Color? borderColor,
  }) {
    return StatusCardData(
      label: label ?? this.label,
      count: count ?? this.count,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      bgColor: bgColor ?? this.bgColor,
      borderColor: borderColor ?? this.borderColor,
    );
  }
}

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
    label: 'Follow Up',
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
          color: isSelected
              ? data.bgColor.withValues(alpha: 0.85)
              : data.bgColor,
          borderRadius: BorderRadius.circular(5.w),
          border: Border.all(
            color: isSelected ? data.iconColor : data.borderColor,
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? data.iconColor.withValues(alpha: 0.22)
                  : data.iconColor.withValues(alpha: 0.08),
              blurRadius: isSelected ? 18 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              // width: 9.5.w,
              padding: EdgeInsets.all(0.5.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? data.iconColor.withValues(alpha: 0.20)
                    : data.iconColor.withValues(alpha: 0.12),
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
