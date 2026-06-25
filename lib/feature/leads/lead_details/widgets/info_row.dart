import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const InfoRow({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Label
          SizedBox(
            width: 32.w,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          // Colon separator
          Text(
            ': ',
            style: TextStyle(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1D2433),
            ),
          ),
          // Value
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1D2433),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
