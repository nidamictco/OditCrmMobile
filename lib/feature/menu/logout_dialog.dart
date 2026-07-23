import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/feature/auth/cubit/auth_cubit.dart';
import 'package:odit_crm_mobile/feature/auth/login_screen.dart';
import 'package:odit_crm_mobile/feature/designation/cubit/permission_cubit.dart';
import 'package:sizer/sizer.dart';

// class LogoutDialog extends StatelessWidget {
//   const LogoutDialog({super.key});

//   static Future<void> show(BuildContext context) {
//     return showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: 'Dismiss',
//       barrierColor: Colors.black.withValues(alpha: 0.4),
//       transitionDuration: const Duration(milliseconds: 300),
//       pageBuilder: (context, anim1, anim2) {
//         return const SizedBox.shrink();
//       },
//       transitionBuilder: (context, anim1, anim2, child) {
//         return BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//           child: FadeTransition(
//             opacity: anim1,
//             child: ScaleTransition(
//               scale: anim1.drive(
//                 Tween<double>(
//                   begin: 0.8,
//                   end: 1.0,
//                 ).chain(CurveTween(curve: Curves.easeOutBack)),
//               ),
//               child: const Dialog(
//                 backgroundColor: Colors.transparent,
//                 elevation: 0,
//                 insetPadding: EdgeInsets.zero,
//                 child: LogoutDialog(),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 85.w,
//       padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.15),
//             blurRadius: 25,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Top Icon
//           Container(
//             height: 75,
//             width: 75,
//             decoration: const BoxDecoration(
//               color: Color(0xFFEAF3FF),
//               shape: BoxShape.circle,
//             ),
//             child: const Center(
//               child: Icon(
//                 Icons.logout_rounded,
//                 color: AppColors.bottomNavBlue,
//                 size: 35,
//               ),
//             ),
//           ),
//           SizedBox(height: 0.5.h),

//           // Title
//           Text(
//             'Confirm Logout',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 20.sp,
//               fontWeight: FontWeight.w700,
//               color: Colors.black87,
//             ),
//           ),
//           SizedBox(height: 1.h),

//           // Subtitle
//           Text(
//             'Are you sure you want to logout?',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w400,
//               color: Colors.grey,
//             ),
//           ),
//           SizedBox(height: 2.h),

//           // Action Buttons
//           Row(
//             children: [
//               // Cancel Button
//               Expanded(
//                 child: SizedBox(
//                   height: 55,
//                   child: OutlinedButton(
//                     onPressed: () => Navigator.pop(context),
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(
//                         color: AppColors.bottomNavBlue,
//                         width: 1.5,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                     ),
//                     child: Text(
//                       'Cancel',
//                       style: TextStyle(
//                         color: AppColors.bottomNavBlue,
//                         fontSize: 15.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 4.w),
//               // Logout Button
//               Expanded(
//                 child: SizedBox(
//                   height: 55,
//                   child: ElevatedButton(
//                     onPressed: () async {
//                        final authCubit = context.read<AuthCubit>();
//         final permissionCubit = context.read<PermissionCubit>();

//         await authCubit.logout(permissionCubit: permissionCubit);

//         if (context.mounted) {
//           Navigator.of(context).pop(); // close the dialog itself
//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (_) => const LoginScreen()),
//             (route) => false,
//           );
//         }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.bottomNavBlue,
//                       elevation: 0,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                     ),
//                     child: Text(
//                       'Logout',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 15.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/feature/auth/cubit/auth_cubit.dart';
import 'package:odit_crm_mobile/feature/auth/login_screen.dart';
import 'package:odit_crm_mobile/feature/designation/cubit/permission_cubit.dart';
import 'package:odit_crm_mobile/main.dart'; // CHANGED: import for navigatorKey
import 'package:sizer/sizer.dart';

class LogoutDialog extends StatefulWidget {
  const LogoutDialog({super.key});

  // CHANGED: static guard so rapid multi-tapping the drawer's "Logout"
  // item can't stack multiple dialog instances before the first one
  // even finishes opening.
  static bool _isDialogOpen = false;

  static Future<void> show(BuildContext context) {
    if (_isDialogOpen) return Future<void>.value();
    _isDialogOpen = true;

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
                Tween<double>(begin: 0.8, end: 1.0)
                    .chain(CurveTween(curve: Curves.easeOutBack)),
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
      // CHANGED: reset the guard once the dialog route is fully gone,
      // regardless of how it closed (Cancel, Logout, or barrier tap).
    ).whenComplete(() => _isDialogOpen = false);
  }

  @override
  State<LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  bool _isLoggingOut = false;

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
          Container(
            height: 75,
            width: 75,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF3FF),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.logout_rounded, color: AppColors.bottomNavBlue, size: 35),
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Confirm Logout',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.black87),
          ),
          SizedBox(height: 1.h),
          Text(
            'Are you sure you want to logout?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: Colors.grey),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: OutlinedButton(
                    onPressed: _isLoggingOut ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.bottomNavBlue, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: _isLoggingOut ? Colors.grey : AppColors.bottomNavBlue,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    // CHANGED: the entire onPressed body — see comments inline.
                    onPressed: _isLoggingOut
                        ? null
                        : () async {
                            setState(() => _isLoggingOut = true);

                            final authCubit = context.read<AuthCubit>();
                            final permissionCubit = context.read<PermissionCubit>();

                            try {
                              // PRIMARY PATH: let AuthCubit do its normal
                              // work. If it completes cleanly, it emits
                              // AuthLoggedOut and main.dart's top-level
                              // BlocListener performs the real navigation
                              // reset for us — nothing changed there.
                               authCubit.logout(permissionCubit: permissionCubit);
                            } catch (e) {
                              // ROOT CAUSE HANDLING: AuthCubit.logout() has
                              // no internal try/catch. Session-clearing
                              // calls run and succeed BEFORE this point,
                              // but if anything after them throws (e.g.
                              // permissionCubit.clear(), or a Firestore
                              // call in NotificationService.clearTokenOnLogout
                              // under poor connectivity), the method aborts
                              // right there and NEVER reaches its final
                              // emit(AuthLoggedOut()). That's exactly the
                              // "cleared but stuck" symptom you saw.
                              //
                              // We swallow it here (already logged) instead
                              // of rethrowing, so the `finally` block below
                              // still runs unconditionally.
                              debugPrint('[LogoutDialog] authCubit.logout() threw: $e');
                            } finally {
                              // SAFETY NET — always runs, whether logout()
                              // succeeded, threw, or silently failed to
                              // emit. We navigate via the app's global
                              // `navigatorKey`, NOT this widget's own
                              // `context`/`Navigator.of(context)` — by this
                              // point `context` may already be unmounted
                              // if the BlocListener's own navigation beat
                              // us to it. navigatorKey sidesteps that
                              // entirely and works either way.
                              //
                              // We deliberately do NOT check "are we
                              // already on LoginScreen" first: if
                              // main.dart's listener already navigated
                              // successfully, calling this again is
                              // harmless — pushAndRemoveUntil always
                              // collapses the stack back down to
                              // [home, LoginScreen], so the end state is
                              // identical whether this fires once or
                              // twice. That's what makes this reliable
                              // under races or heavy load without needing
                              // to detect the current route.
                              navigatorKey.currentState?.pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => route.isFirst, // keep `home` (hosts
                                                           // the AuthCubit
                                                           // listener), discard
                                                           // everything else —
                                                           // including this
                                                           // dialog's own route.
                              );

                              // Only relevant in the rare case this widget
                              // is somehow still mounted afterward — reset
                              // the spinner so nothing looks stuck.
                              if (mounted) {
                                setState(() => _isLoggingOut = false);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bottomNavBlue,
                      disabledBackgroundColor: AppColors.bottomNavBlue.withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoggingOut
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            'Logout',
                            style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold),
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