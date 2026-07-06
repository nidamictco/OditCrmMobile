import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/core/theme/assets_resources.dart';
import 'package:odit_crm_mobile/core/utils/bottom_navigation.dart';
import 'package:odit_crm_mobile/feature/auth/cubit/auth_cubit.dart';
import 'package:odit_crm_mobile/feature/designation/cubit/permission_cubit.dart';
import 'package:sizer/sizer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedCompany = 'S1';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //   @override
  //   Widget build(BuildContext context) {
  //     return BlocConsumer<AuthCubit, AuthState>(
  //       listener: (context, state) {
  //         if (state is Authenticated) {
  //           Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => const CustomBottomNavScreen(),
  //             ),
  //           );
  //         } else if (state is AuthError) {
  //           log(state.message);
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text(state.message), backgroundColor: Colors.red),
  //           );
  //         }
  //       },
  //       builder: (context, state) {
  //         return Scaffold(
  //           backgroundColor: Colors.white,
  //           body: SafeArea(
  //             top: false,
  //             bottom: true,
  //             child: SingleChildScrollView(
  //               physics: const BouncingScrollPhysics(),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.stretch,
  //                 children: [
  //                   // ── Top Background and Logo Section ──
  //                   Stack(
  //                     clipBehavior: Clip.none,
  //                     alignment: Alignment.center,
  //                     children: [
  //                       const TopBackgroundWidget(),

  //                       // Logo (placed overlapping the bottom of top background)
  //                       Positioned(bottom: -8.h, child: const LogoWidget()),
  //                     ],
  //                   ),

  //                   SizedBox(height: 10.h),

  //                   // ── Credentials / Input Section ──
  //                   Padding(
  //                     padding: EdgeInsets.symmetric(horizontal: 6.w),
  //                     child: Column(
  //                       children: [
  //                         // Welcome Texts
  //                         Text(
  //                           'Welcome Back',
  //                           style: GoogleFonts.poppins(
  //                             fontSize: 20.sp,
  //                             fontWeight: FontWeight.bold,
  //                             color: const Color(0xFF1D2433),
  //                           ),
  //                           textAlign: TextAlign.center,
  //                         ),
  //                         SizedBox(height: 0.8.h),
  //                         Text(
  //                           'Sign in to access your account',
  //                           style: GoogleFonts.poppins(
  //                             fontSize: 14.sp,
  //                             color: Colors.grey.shade500,
  //                           ),
  //                           textAlign: TextAlign.center,
  //                         ),
  //                         SizedBox(height: 4.h),

  //                         // Username Input
  //                         LoginTextFieldWidget(
  //                           controller: _usernameController,
  //                           hintText: 'Enter your phone number',
  //                           prefixIcon: Icons.phone_outlined,
  //                           keyboardType: TextInputType.phone,
  //                           phone: true,
  //                         ),
  //                         SizedBox(height: 2.h),

  //                         // Password Input
  //                         LoginTextFieldWidget(
  //                           controller: _passwordController,
  //                           hintText: 'Enter your password',
  //                           prefixIcon: Icons.lock_outline,
  //                           obscureText: _obscurePassword,
  //                           suffixIcon: IconButton(
  //                             icon: Icon(
  //                               _obscurePassword
  //                                   ?Icons.visibility_off_outlined
  //                                   :Icons.visibility_outlined,
  //                               color: Colors.grey.shade400,
  //                               size: 20,
  //                             ),
  //                             onPressed: () {
  //                               setState(() {
  //                                 _obscurePassword = !_obscurePassword;
  //                               });
  //                             },
  //                           ),
  //                         ),
  //                         SizedBox(height: 4.h),

  //                         // Sign In Button
  //                         // LoginButtonWidget(
  //                         //   isLoading: state is AuthLoading,
  //                         //   onTap: () {
  //                         //     context.read<AuthCubit>().login(
  //                         //       phoneNo: _usernameController.text,
  //                         //       password: _passwordController.text,
  //                         //       // companyId: ,
  //                         //       permissionCubit: context.read<PermissionCubit>(),
  //                         //     );
  //                         //     log(_usernameController.text);
  //                         //     log(_passwordController.text);
  //                         //     log(_selectedCompany.toString());
  //                         //   },
  //                         // ),
  //                         LoginButtonWidget(
  //   isLoading: state is AuthLoading,
  //   onTap: () {
  //     final phone = _usernameController.text.trim();
  //     final password = _passwordController.text.trim();
  //     if(phone.isEmpty){
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Please enter your phone number'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       return;
  //     }
  //     if(password.isEmpty){
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Please enter your password'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       return;
  //     }

  //     if (phone.length != 10) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Please enter a valid 10-digit phone number'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       return;
  //     }

  //     context.read<AuthCubit>().login(
  //       phoneNo: phone,
  //       password: password,
  //       permissionCubit: context.read<PermissionCubit>(),
  //     );
  //   },
  // ),
  //                         SizedBox(height: 2.5.h),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //   }
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        debugPrint('🔥 LISTENER FIRED: $state');
        if (state is Authenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CustomBottomNavScreen(),
            ),
          );
        } else if (state is AuthError) {
          log(state.message);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              top: false,
              bottom: true,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Top Background and Logo Section ──
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        const TopBackgroundWidget(),
                        Positioned(bottom: -8.h, child: const LogoWidget()),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Column(
                        children: [
                          Text(
                            'Welcome Back',
                            style: GoogleFonts.poppins(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1D2433),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 0.8.h),
                          Text(
                            'Sign in to access your account',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4.h),

                          LoginTextFieldWidget(
                            controller: _usernameController,
                            hintText: 'Enter your phone number',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            phone: true,
                          ),
                          SizedBox(height: 2.h),

                          LoginTextFieldWidget(
                            controller: _passwordController,
                            hintText: 'Enter your password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 4.h),

                          LoginButtonWidget(
                            isLoading: state is AuthLoading,
                            onTap: () {
                              final phone = _usernameController.text.trim();
                              final password = _passwordController.text.trim();
                              if (phone.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter your phone number',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              if (password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter your password'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              if (phone.length != 10) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter a valid 10-digit phone number',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              context.read<AuthCubit>().login(
                                phoneNo: phone,
                                password: password,
                                permissionCubit: context
                                    .read<PermissionCubit>(),
                              );
                            },
                          ),
                          SizedBox(height: 2.5.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ===========================================================================
// TOP BACKGROUND WIDGET
// ===========================================================================
class TopBackgroundWidget extends StatelessWidget {
  const TopBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.h,
      decoration: BoxDecoration(
        color: AppColors.bottomNavBlue.withOpacity(0.04),
      ),
      child: ClipRect(
        child: Stack(
          children: [
            // Light background wave curves (custom drawn/positioned circles)
            Positioned(
              left: -15.w,
              top: -5.h,
              width: 55.w,
              height: 55.w,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bottomNavBlue.withOpacity(0.04),
                ),
              ),
            ),
            Positioned(
              right: -25.w,
              top: -10.h,
              width: 75.w,
              height: 75.w,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bottomNavBlue.withOpacity(0.03),
                ),
              ),
            ),
            Positioned(
              left: -5.w,
              bottom: -2.h,
              width: 35.w,
              height: 35.w,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bottomNavBlue.withOpacity(0.02),
                ),
              ),
            ),
            // Custom Wave Painter at the bottom border of 35.h
            Positioned.fill(child: CustomPaint(painter: _WavePainter())),
          ],
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.bottomNavBlue.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.9,
        size.width * 0.5,
        size.height * 0.8,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.7,
        size.width,
        size.height * 0.85,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);

    final paint2 = Paint()
      ..color = AppColors.bottomNavBlue.withOpacity(0.02)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.7,
        size.width * 0.6,
        size.height * 0.85,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.95,
        size.width,
        size.height * 0.75,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ===========================================================================
// COMPANY DROPDOWN WIDGET
// ===========================================================================
class CompanyDropdownWidget extends StatelessWidget {
  final String selectedValue;
  final ValueChanged<String?> onChanged;

  const CompanyDropdownWidget({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.bottomNavBlue.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          icon: Icon(
            Icons.arrow_drop_down,
            color: AppColors.bottomNavBlue,
            size: 18.sp,
          ),
          onChanged: onChanged,
          items: const [
            DropdownMenuItem(
              value: 'S1',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.dns_outlined,
                    color: AppColors.bottomNavBlue,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'S1',
                    style: TextStyle(
                      color: AppColors.bottomNavBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'S2',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.dns_outlined,
                    color: AppColors.bottomNavBlue,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'S2',
                    style: TextStyle(
                      color: AppColors.bottomNavBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// LOGO WIDGET
// ===========================================================================
class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(
            //   Icons.trending_up_rounded,
            //   color: AppColors.bottomNavBlue,
            //   size: 22.sp,
            // ),
            // Text(
            //   'Odit',
            //   style: GoogleFonts.poppins(
            //     color: AppColors.bottomNavBlue,
            //     fontSize: 30.sp,
            //     fontWeight: FontWeight.bold,
            //     letterSpacing: 0.5,
            //   ),
            // ),
            Image.asset(AssetResources.logo, height: 15.h, width: 20.w),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// LOGIN TEXT FIELD WIDGET
// ===========================================================================
class LoginTextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool phone;

  const LoginTextFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.phone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          fontSize: 14.5.sp,
          color: const Color(0xFF333333),
        ),
        inputFormatters: phone == true
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ]
            : null,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14.5.sp,
            color: Colors.grey.shade400,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Icon(
              prefixIcon,
              color: AppColors.bottomNavBlue,
              size: 20.sp,
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 10.w),
          suffixIcon: suffixIcon,
          contentPadding: EdgeInsets.symmetric(
            vertical: 2.2.h,
            horizontal: 4.w,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFEEEEEE), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: AppColors.bottomNavBlue,
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

// ===========================================================================
// LOGIN BUTTON WIDGET
// ===========================================================================
class LoginButtonWidget extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const LoginButtonWidget({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 7.h,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.bottomNavBlue.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bottomNavBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'Sign In',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
