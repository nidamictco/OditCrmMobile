import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/feature/staff_management/Screen/model/staff_model.dart';
import 'package:sizer/sizer.dart';

class ProfileBottomSheet extends StatelessWidget {
  final StaffModel user;
  const ProfileBottomSheet({super.key, required this.user});

  // static void show(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => const ProfileBottomSheet(),
  //   );
  // } 

  static Future<void> show(BuildContext context, StaffModel user) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileBottomSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: EdgeInsets.only(
        left: 5.w,
        right: 5.w,
        top: 2.h,
        bottom: MediaQuery.of(context).padding.bottom + 2.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Indicator
          Container(
            width: 12.w,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 3.h),

          // Profile Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF2a83c5),
                  // Color(0xFF1b5d91),
                  AppColors.bottomNavBlue,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1b5d91).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty == true
                    ? user.name![0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Company Name
          Text(
            // 'Oxdo technologies pvt ltd',
            user.name?.isNotEmpty == true ? user.name.toUpperCase() : 'U',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 0.5.h),

          // Designation
          Text(
            user.designation == 'Company_Admin'
                ? "Company Admin"
                : user.staffType!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 2.5.h),

          // Divider
          Divider(color: Colors.grey.shade200, thickness: 1, height: 1),
          SizedBox(height: 1.h),

          // Email Info Card
          _buildInfoCard(
            context: context,
            icon: Icons.mail_outline,
            iconColor: const Color(0xFFF39C12),
            iconBgColor: const Color(0xFFFEF5E7),
            label: 'Email',
            value: user.email!,
          ),
          SizedBox(height: 1.h),

          // Phone Info Card
          _buildInfoCard(
            context: context,
            icon: Icons.phone_android_outlined,
            iconColor: const Color(0xFF2ECC71),
            iconBgColor: const Color(0xFFEAFAF1),
            label: 'Phone',
            value: user.phone,
          ),
          SizedBox(height: 4.h),

          // Close Button
          SizedBox(
            width: double.infinity,
            height: 6.5.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bottomNavBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F3F5), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          SizedBox(width: 4.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
