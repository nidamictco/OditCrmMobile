// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:odit_crm_mobile/core/theme/app_colors.dart';
// import 'package:odit_crm_mobile/feature/staff_management/Screen/model/staff_model.dart';
// import 'package:odit_crm_mobile/feature/staff_management/cubit/staff_cubit.dart';
// import 'package:sizer/sizer.dart';

// class ChangePasswordScreen extends StatefulWidget {
//   final StaffModel staff; 
//   const ChangePasswordScreen({super.key, required this.staff});

//   @override
//   State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
// }

// class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }



//   void _changePassword() {
//     final newPassword = _newPasswordController.text.trim();
//     final confirmPassword = _confirmPasswordController.text.trim();

//     // ─── Validation ───────────────────────────
//     if (newPassword.isEmpty || confirmPassword.isEmpty) {
//       _showSnack('Please fill in both fields.', Colors.red);
//       return;
//     }

//     // if (newPassword.length < 6) {
//     //   _showSnack('Password must be at least 6 characters.', Colors.red);
//     //   return;
//     // }
//     if (newPassword.isEmpty) {
//   _showError("Please enter new password");
//   return;
// }
// if (confirmPassword.isEmpty) {
//   _showError("Please confirm password");
//   return;
// }
// if (newPassword.length < 6) {
//   _showError("Password must be at least 6 characters");
//   return;
// }
// if (newPassword != confirmPassword) {
//   _showError("Passwords do not match");
//   return;
// }
// if (widget.staff.id == null || widget.staff.id!.isEmpty) {
//   _showError("Staff ID not found");
//   return;
// }

//     if (newPassword != confirmPassword) {
//       _showSnack('Passwords do not match.', Colors.red);
//       return;
//     }

//     if (widget.staff.id == null) {
//       _showSnack('Staff ID not found.', Colors.red);
//       return;
//     }

//     setState(() => _isLoading = true);

//     // update only the password field in Firestore
//     context.read<StaffCubit>().updateStaffField(
//       widget.staff.id!,
//       {'password': newPassword},
//     );
//   }

//   void _showSnack(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: TextStyle(
//             fontSize: 14.sp,
//             color: Colors.white,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         backgroundColor: Colors.redAccent,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }

//   void _showSuccess(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: TextStyle(
//             fontSize: 14.sp,
//             color: Colors.white,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         backgroundColor: AppColors.bottomNavBlue,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }

//   Future<void> _submit() async {
//     final newPassword = _newPasswordController.text.trim();
//     final confirmPassword = _confirmPasswordController.text.trim();

//     if (newPassword.isEmpty) {
//   _showError("Please enter new password");
//   return;
// }
// if (confirmPassword.isEmpty) {
//   _showError("Please confirm password");
//   return;
// }
// if (newPassword.length < 6) {
//   _showError("Password must be at least 6 characters");
//   return;
// }
// if (newPassword != confirmPassword) {
//   _showError("Passwords do not match");
//   return;
// }
// if (widget.staff.id == null || widget.staff.id!.isEmpty) {
//   _showError("Staff ID not found");
//   return;
// }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Simulate API call
//        context.read<StaffCubit>().updateStaffField(
//     widget.staff.id!,
//     {'password': newPassword},
//   );
      
//       if (mounted) {
//         _newPasswordController.clear();
//         _confirmPasswordController.clear();
//         _showSuccess("Password changed successfully");
//       }
//     } catch (e) {
//       if (mounted) {
//         _showError(e.toString());
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF5F5F5),
//         appBar: const _CustomChangePasswordAppBar(),
//         body: SafeArea(
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             padding: EdgeInsets.symmetric(horizontal: 4.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(height: 4.h),
//                 PasswordTextField(
//                   controller: _newPasswordController,
//                   hintText: 'New Password',
//                 ),
//                 SizedBox(height: 2.5.h),
//                 PasswordTextField(
//                   controller: _confirmPasswordController,
//                   hintText: 'Confirm Password',
//                 ),
//                 SizedBox(height: 4.h),
//                 Center(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: AppColors.bottomNavBlue.withValues(alpha: .25),
//                           blurRadius: 15,
//                           offset: const Offset(0, 6),
//                         ),
//                       ],
//                     ),
//                     child: ElevatedButton(
//                       onPressed: _isLoading
//                           ? null
//                           : () {
//                               FocusScope.of(context).unfocus();
//                               _submit();
//                             },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.bottomNavBlue,
//                         foregroundColor: Colors.white,
//                         disabledBackgroundColor: AppColors.bottomNavBlue.withValues(alpha: 0.6),
//                         elevation: 0,
//                         fixedSize: Size(45.w, 6.5.h),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                       ),
//                       child: _isLoading
//                           ? SizedBox(
//                               height: 3.h,
//                               width: 3.h,
//                               child: const CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                           : Text(
//                               'Submit',
//                               style: TextStyle(
//                                 fontSize: 17.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.white,
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _CustomChangePasswordAppBar extends StatelessWidget implements PreferredSizeWidget {
//   const _CustomChangePasswordAppBar();

//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.light.copyWith(
//         statusBarColor: Colors.transparent,
//       ),
//       child: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xFF3AA0E6),
//               AppColors.bottomNavBlue,
//             ],
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//           ),
//         ),
//         child: SafeArea(
//           bottom: false,
//           child: SizedBox(
//             height: 9.h,
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 4.w),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Container(
//                       padding: EdgeInsets.all(2.w),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: Colors.white.withValues(alpha: 0.3),
//                           width: 1.5,
//                         ),
//                       ),
//                       child: Icon(
//                         Icons.arrow_back_ios_new_rounded,
//                         color: Colors.white,
//                         size: 15.sp,
//                       ),
//                     ),
//                   ),
//                   const Spacer(),
//                   Text(
//                     'Change Password',
//                     style: TextStyle(
//                       fontSize: 22.sp,
//                       fontWeight: FontWeight.w400,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     icon: Icon(
//                       Icons.more_vert,
//                       color: Colors.white,
//                       size: 20.sp,
//                     ),
//                     onPressed: () {},
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Size get preferredSize => Size.fromHeight(9.h);
// }

// class PasswordTextField extends StatefulWidget {
//   final TextEditingController controller;
//   final String hintText;
//   final String? Function(String?)? validator;

//   const PasswordTextField({
//     super.key,
//     required this.controller,
//     required this.hintText,
//     this.validator,
//   });

//   @override
//   State<PasswordTextField> createState() => _PasswordTextFieldState();
// }

// class _PasswordTextFieldState extends State<PasswordTextField> {
//   bool _obscure = true;

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: widget.controller,
//       obscureText: _obscure,
//       validator: widget.validator,
//       style: TextStyle(
//         fontSize: 15.sp,
//         color: const Color(0xFF212121),
//       ),
//       decoration: InputDecoration(
//         hintText: widget.hintText,
//         hintStyle: TextStyle(
//           fontSize: 14.sp,
//           color: const Color(0xFF888888),
//         ),
//         filled: true,
//         fillColor: Colors.white,
//         prefixIcon: Icon(
//           Icons.lock_outline_rounded,
//           color: const Color(0xFF888888),
//           size: 18.sp,
//         ),
//         suffixIcon: GestureDetector(
//           onTap: () => setState(() => _obscure = !_obscure),
//           child: Icon(
//             _obscure
//                 ? Icons.visibility_off_outlined
//                 : Icons.visibility_outlined,
//             color: const Color(0xFF888888),
//             size: 18.sp,
//           ),
//         ),
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: 4.w,
//           vertical: 1.8.h,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(
//             color: Color(0xFFE0E0E0),
//             width: 1,
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(
//             color: Color(0xFFE0E0E0),
//             width: 1,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(
//             color: AppColors.bottomNavBlue,
//             width: 1.5,
//           ),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(
//             color: Colors.redAccent,
//             width: 1,
//           ),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(
//             color: Colors.redAccent,
//             width: 1.5,
//           ),
//         ),
//         errorStyle: TextStyle(
//           fontSize: 11.sp,
//           color: Colors.redAccent,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/feature/staff_management/Screen/model/staff_model.dart';
import 'package:odit_crm_mobile/feature/staff_management/cubit/staff_cubit.dart';
import 'package:sizer/sizer.dart';

class ChangePasswordScreen extends StatefulWidget {
  final StaffModel staff;
  const ChangePasswordScreen({super.key, required this.staff});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // ✅ Scoped key — SnackBars resolve to THIS screen's Scaffold only
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Snack helpers ──────────────────────────────────────────────────────────
  // Both use _scaffoldMessengerKey so they always hit the local Scaffold.

  void _showError(String message) {
    _scaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  void _showSuccess(String message) {
    _scaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppColors.bottomNavBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validation
    if (newPassword.isEmpty) {
      _showError('Please enter new password');
      return;
    }
    if (confirmPassword.isEmpty) {
      _showError('Please confirm password');
      return;
    }
    if (newPassword.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }
    if (newPassword != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }
    if (widget.staff.id == null || widget.staff.id!.isEmpty) {
      _showError('Staff ID not found');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<StaffCubit>().updateStaffField(
            widget.staff.id!,
            {'password': newPassword},
          );

      if (mounted) {
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _showSuccess('Password changed successfully');
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // ✅ ScaffoldMessenger wraps the Scaffold and is keyed to this screen
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: const _CustomChangePasswordAppBar(),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 4.h),
                  PasswordTextField(
                    controller: _newPasswordController,
                    hintText: 'New Password',
                  ),
                  SizedBox(height: 2.5.h),
                  PasswordTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                  ),
                  SizedBox(height: 4.h),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.bottomNavBlue
                                .withValues(alpha: .25),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                FocusScope.of(context).unfocus();
                                _submit();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bottomNavBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.bottomNavBlue.withValues(alpha: 0.6),
                          elevation: 0,
                          fixedSize: Size(45.w, 6.5.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 3.h,
                                width: 3.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────

class _CustomChangePasswordAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _CustomChangePasswordAppBar();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3AA0E6), AppColors.bottomNavBlue],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 9.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 15.sp,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(9.h);
}

// ─── Password Text Field ──────────────────────────────────────────────────────

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;

  const PasswordTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator,
      style: TextStyle(fontSize: 15.sp, color: const Color(0xFF212121)),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF888888)),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: const Color(0xFF888888),
          size: 18.sp,
        ),
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscure = !_obscure),
          child: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: const Color(0xFF888888),
            size: 18.sp,
          ),
        ),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.bottomNavBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle:
            TextStyle(fontSize: 11.sp, color: Colors.redAccent),
      ),
    );
  }
}