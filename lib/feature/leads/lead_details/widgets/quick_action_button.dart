import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class QuickActionButton extends StatelessWidget {
  final IconData? icon;
  final String? iconAsset;
  final Color backgroundColor;
  final Color? iconColor;
  final String label;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    this.icon,
    this.iconAsset,
    required this.backgroundColor,
    this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: iconAsset != null
                ? Padding(
                    padding: EdgeInsets.all(1.5.w),
                    child: Image.asset(
                      iconAsset!,
                      width: 1.w,
                      height: 1.w,
                      color:
                          iconColor, // remove this line if your PNG is already colored (e.g. official WhatsApp green logo)
                    ),
                  )
                : Icon(icon, color: iconColor, size: 6.w),
          ),
          SizedBox(height: 0.8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}
