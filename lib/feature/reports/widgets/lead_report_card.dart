import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odit_crm_mobile/core/theme/assets_resources.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/add_lead_model.dart';
import 'package:odit_crm_mobile/feature/lead_details/presentation/lead_details_screen.dart';
import 'package:sizer/sizer.dart';

class LeadReportCard extends StatelessWidget {
  final AddLeadModel lead;
  final bool isTransferReport;
  final VoidCallback? onFollowUp;
  final VoidCallback? onCall;
  final VoidCallback? onWhatsApp;

  const LeadReportCard({
    super.key,
    required this.lead,
    this.isTransferReport = false,
    this.onFollowUp,
    this.onCall,
    this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status badge colors
    Color statusBgColor = const Color(0xFFFFEAEB);
    Color statusTextColor = const Color(0xFFEB5757);
    Color statusIndicatorColor = const Color(0xFF27AE60);

    if (lead.leadCategory.toLowerCase().contains('need further')) {
      statusBgColor = const Color(0xFFFFEAEB);
      statusTextColor = const Color(0xFFEB5757);
      statusIndicatorColor = const Color(0xFF27AE60);
    } else if (lead.leadCategory.toLowerCase().contains('may visit')) {
      statusBgColor = const Color(0xFFFFEAEB);
      statusTextColor = const Color(0xFFEB5757);
      statusIndicatorColor = const Color(0xFFEB5757);
    } else if (lead.leadCategory.toLowerCase().contains('visited')) {
      statusBgColor = const Color(0xFFFFEAEB);
      statusTextColor = const Color(0xFFEB5757);
      statusIndicatorColor = const Color(0xFF2F80ED);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () {
          LeadDetailsScreen.show(
            context,
            lead: AddLeadModel(
              id: lead.id ?? '',
              clientName: lead.clientName,
              leadStage: lead.leadStage,
              leadCategory: lead.leadCategory,
              contactNumber: lead.contactNumber,
              assignedStaff: lead.assignedStaff,
              leadSource: lead.leadSource,
              createdAt: lead.createdAt,
              priority: lead.priority,
              whatsappNumber: lead.whatsappNumber,
              email: lead.email,
              address: lead.address,
              state: lead.state,
              district: lead.district,
              pinCode: lead.pinCode,
              postOffice: lead.postOffice,
              createdBy: lead.createdBy,
              remarks: lead.remarks, contactDialCode: '', assignedStaffId: '', createdById: '',
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Padding(
                padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
                child: Row(
                  children: [
                    // Status Indicator Circle
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: statusIndicatorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    // Name
                    Expanded(
                      child: Text(
                        lead.clientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1D2433),
                        ),
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.5.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lead.leadCategory.isEmpty
                            ? 'Uncategorized'
                            : capitalizeFirst(lead.leadCategory.toLowerCase()),
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          color: statusTextColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    // Expand Icon
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.grey.shade400,
                      size: 18.sp,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F3F5)),

              // Details Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dates Row
                    Row(
                      children: [
                        // Called Date
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.6.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F4FD),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.phone_callback,
                                  size: 16.sp,
                                  color: const Color(0xFF2F80ED),
                                ),
                                SizedBox(width: 1.w),
                                Expanded(
                                  child: Text(
                                    'Called: ${lead.calledDate}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2F80ED),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        // Next Followup Date
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.6.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16.sp,
                                  color: const Color(0xFFE0A82E),
                                ),
                                SizedBox(width: 1.w),
                                Expanded(
                                  child: Text(
                                    'Next: ${lead.followUpDate}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFE0A82E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),

                    // Phone and Profile Avatar Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.phone_android_outlined,
                              color: const Color(0xFF2F80ED),
                              size: 17.sp,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              lead.contactNumber,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1D2433),
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey.shade200,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),

                    // Assigned Staff
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: Colors.grey.shade400,
                          size: 17.5.sp,
                        ),
                        SizedBox(width: 1.5.w),
                        Text(
                          'Assigned to : ${lead.assignedStaff}',
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),

                    // Action Buttons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left element
                        if (isTransferReport)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 0.8.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFECEB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Transferred',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFEB5757),
                              ),
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: onFollowUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFF9E6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.h,
                              ),
                            ),
                            child: Text(
                              'Follow Up',
                              style: TextStyle(
                                color: const Color(0xFFF2C94C),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        // Right buttons
                        Row(
                          children: [
                            // Call Button
                            ElevatedButton.icon(
                              onPressed: onCall,
                              icon: Icon(
                                Icons.phone,
                                size: 16.5.sp,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Call',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF27AE60),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 1.w,
                                  vertical: 0.2.h,
                                ),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            // WhatsApp Button
                            GestureDetector(
                              onTap: onWhatsApp,
                              child: Container(
                                padding: EdgeInsets.all(1.2.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2ECC71),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Image.asset(
                                  AssetResources.whatsapp,
                                  width: 3.h,
                                  height: 3.h,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String capitalizeFirst(String text) {
    if (text.isEmpty) return text;

    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
