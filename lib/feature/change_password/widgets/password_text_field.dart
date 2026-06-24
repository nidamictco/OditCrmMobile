import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:sizer/sizer.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const PasswordTextField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 7.5.h,
      child: TextField(
        controller: widget.controller,
        obscureText: _obscureText,
        style: TextStyle(
          fontSize: 15.sp,
          color: const Color(0xFF333333),
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: const Color(0xFFBDBDBD),
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: Icon(
              Icons.lock,
              color: AppColors.bottomNavBlue,
              size: 5.5.w,
            ),
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 10.w,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.bottomNavBlue,
              size: 5.5.w,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.bottomNavBlue,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
