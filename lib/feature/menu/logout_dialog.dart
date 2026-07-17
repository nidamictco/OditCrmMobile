import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/feature/auth/cubit/auth_cubit.dart';
import 'package:odit_crm_mobile/feature/auth/login_screen.dart';
import 'package:odit_crm_mobile/feature/designation/cubit/permission_cubit.dart';
import 'package:sizer/sizer.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 300),
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
                Tween<double>(
                  begin: 0.8,
                  end: 1.0,
                ).chain(CurveTween(curve: Curves.easeOutBack)),
              ),
              child: const Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                insetPadding: EdgeInsets.zero,
                child: LogoutDialog(),
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
      width: 85.w,
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
            height: 75,
            width: 75,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF3FF),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.logout_rounded,
                color: AppColors.bottomNavBlue,
                size: 35,
              ),
            ),
          ),
          SizedBox(height: 0.5.h),

          // Title
          Text(
            'Confirm Logout',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 1.h),

          // Subtitle
          Text(
            'Are you sure you want to logout?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 2.h),

          // Action Buttons
          Row(
            children: [
              // Cancel Button
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.bottomNavBlue,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.bottomNavBlue,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              // Logout Button
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                       final authCubit = context.read<AuthCubit>();
        final permissionCubit = context.read<PermissionCubit>();

        await authCubit.logout(permissionCubit: permissionCubit);

        if (context.mounted) {
          Navigator.of(context).pop(); // close the dialog itself
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bottomNavBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
