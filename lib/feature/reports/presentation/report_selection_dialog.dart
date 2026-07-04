import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/feature/reports/presentation/lead_report_screen.dart';
import 'package:odit_crm_mobile/feature/reports/presentation/transfer_report_screen.dart';
import 'package:odit_crm_mobile/feature/reports/presentation/staff_report_screen.dart';
import 'package:odit_crm_mobile/feature/reports/presentation/target_report_screen.dart';
import 'package:odit_crm_mobile/feature/reports/widgets/report_option_card.dart';
import 'package:sizer/sizer.dart';

class ReportSelectionDialog extends StatelessWidget {
  const ReportSelectionDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: FadeTransition(
            opacity: anim1,
            child: ScaleTransition(
              scale: anim1.drive(
                Tween<double>(begin: 0.8, end: 1.0).chain(
                  CurveTween(curve: Curves.easeOutQuad),
                ),
              ),
              child: const Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                insetPadding: EdgeInsets.zero,
                child: ReportSelectionDialog(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Icon
          Container(
            height: 90,
            width: 90,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF9EE),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.check_rounded,
                color: Color(0xFF34D058),
                size: 50,
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Title
          Text(
            'Reports',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19.5.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1D2433),
            ),
          ),
          SizedBox(height: 0.5.h),

          // Subtitle
          Text(
            'Choose Report',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 3.5.h),

          // Report Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 4.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 1.4,
            children: [
              ReportOptionCard(
                label: 'Lead Report',
                icon: Icons.grid_view_rounded,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LeadReportScreen(
                        reportType: LeadReportType.all,
                      ),
                    ),
                  );
                },
              ),
              ReportOptionCard(
                label: 'Transfer Report',
                icon: Icons.receipt_long_rounded,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LeadReportScreen(reportType: LeadReportType.transferred,),
                    ),
                  );
                },
              ),
              ReportOptionCard(
                label: 'Staff Report',
                icon: Icons.badge_outlined,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StaffReportScreen(),
                    ),
                  );
                },
              ),
              ReportOptionCard(
                label: 'Target Report',
                icon: Icons.track_changes_rounded,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TargetReportScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
