import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ReportOptionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const ReportOptionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFDDF4DD),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF1D2433), size: 20.sp),
            SizedBox(height: 1.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D2433),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
