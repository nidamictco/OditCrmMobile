import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/feature/leads/lead_details/widgets/status_badge.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/add_lead_model.dart';
import 'package:sizer/sizer.dart';

class FollowupHistoryCard extends StatelessWidget {
  final FollowUpModel followup;
  final int followupNumber;
  final DateTime? scheduledDate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool canEditDelete;
  final bool canNotDelete;

  const FollowupHistoryCard({
    super.key,
    required this.followup,
    required this.followupNumber,
    this.scheduledDate,
    required this.onEdit,
    required this.onDelete,
    this.canEditDelete = false,
    this.canNotDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNewStatus = followup.leadStage.trim().toLowerCase().contains(
      'new',
    );
    final Color badgeBgColor = isNewStatus
        ? AppColors.bottomNavBlue
        : const Color(0xFFFFA000);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF9ED1FF), width: 1),
      ),
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              // Profile Avatar
              Container(
                width: 10.w,
                height: 10.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.person,
                  color: const Color(0xFF888888),
                  size: 6.w,
                ),
              ),
              SizedBox(width: 3.w),
              // Staff Name
              Expanded(
                child: Text(
                  followup.assignedStaff,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D2433),
                  ),
                ),
              ),
              // Edit & Delete Icons
              if (canEditDelete) ...[
                GestureDetector(
                  onTap: onEdit,
                  child: Icon(
                    Icons.edit,
                    color: AppColors.bottomNavBlue,
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 3.w),
                if (followupNumber != 2)
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(Icons.delete, color: Colors.red, size: 5.w),
                  ),
                SizedBox(width: 3.w),
              ],
              // Status Badge
              StatusBadge(
                label: followup.leadStage,
                backgroundColor: badgeBgColor,
                textColor: Colors.white,
              ),
            ],
          ),
          SizedBox(height: 1.5.h),

          // Scheduled Date Row
          if (scheduledDate != null && followup.leadStage != 'REJECTED') ...[
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: AppColors.bottomNavBlue,
                  size: 4.5.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Scheduled Date: ${DateFormat('dd-MM-yyyy hh:mm a').format(followup.nextFollowUpDate)}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF555555),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
          ],

          // Called Date Row
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                color: AppColors.bottomNavBlue,
                size: 4.5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Called Date: ${DateFormat('dd-MM-yyyy hh:mm a').format(followup.calledDate)}',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF555555),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),

          // Call Status Row
          Padding(
            padding: EdgeInsets.only(left: 6.5.w),
            child: Text(
              'Call Status: ${followup.calledStatus}',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF555555),
              ),
            ),
          ),
          SizedBox(height: 1.5.h),

          // // F.No Badge
          // Padding(
          //   padding: EdgeInsets.only(left: 6.5.w),
          //   child: Container(
          //     padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
          //     decoration: BoxDecoration(
          //       color: const Color(0xFFDDF5D8),
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     child: Text(
          //       'F.No : $followupNumber',
          //       style: TextStyle(
          //         fontSize: 12.sp,
          //         fontWeight: FontWeight.w600,
          //         color: const Color(0xFF2E7D32),
          //       ),
          //     ),
          //   ),
          // ),
          // SizedBox(height: 1.5.h),

          // Remarks Row
          Padding(
            padding: EdgeInsets.only(left: 6.5.w),
            child: Text(
              followup.remarks.isNotEmpty?
              'Remarks:  ${followup.remarks}':'Remark : N/A',
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF555555),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
