import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:sizer/sizer.dart';

class LeadHandledStaffCard extends StatelessWidget {
  final String name;
  final String phone;
  // final int callCount;

  const LeadHandledStaffCard({
    super.key,
    required this.name,
    required this.phone,
    // required this.callCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(3.5.w),
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          // Left: Circle Avatar
          CircleAvatar(
            radius: 5.5.w,
            backgroundColor: const Color(0xFFE5E7EB),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.bottomNavBlue,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          // Center: Staff details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2433),
                  ),
                ),
                SizedBox(height: 0.4.h),
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      color: const Color(0xFF6B7280),
                      size: 4.5.w,
                    ),
                    SizedBox(width: 1.5.w),
                    Text(
                      phone,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Right: Call count badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.call,
                  color: AppColors.bottomNavBlue,
                  size: 4.w,
                ),
                SizedBox(width: 1.5.w),
                // Text(
                //   callCount.toString(),
                //   style: TextStyle(
                //     fontSize: 13.sp,
                //     fontWeight: FontWeight.bold,
                //     color: AppColors.bottomNavBlue,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
