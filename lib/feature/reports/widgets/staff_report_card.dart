import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/feature/staff_management/model/staff_model.dart';
import 'package:sizer/sizer.dart';

class StaffReportCard extends StatelessWidget {
  final StaffModel staff;
  final VoidCallback onTap;

  const StaffReportCard({super.key, required this.staff, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Vertical Blue Indicator
                Container(width: 6, color: const Color(0xFF2F80ED)),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.8.h,
                    ),
                    child: Row(
                      children: [
                        // Letter Avatar
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: const Color(0xFFE3F2FD),
                          child: Text(
                            staff.name.isNotEmpty ? staff.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2F80ED),
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                staff.name,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1D2433),
                                ),
                              ),
                              SizedBox(height: 0.3.h),
                              Text(
                                staff.phone,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 16.sp,
                                    color: Colors.grey.shade400,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    'Joined: ${staff.joiningDate ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // // Navigation Arrow
                        // Icon(
                        //   Icons.chevron_right,
                        //   color: const Color(0xFFBDBDBD),
                        //   size: 19.5.sp,
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
