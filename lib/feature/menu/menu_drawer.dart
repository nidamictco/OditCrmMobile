import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/core/utils/bottom_navigation.dart';
import 'package:odit_crm_mobile/feature/menu/profile_bottom_sheet.dart';
import 'package:odit_crm_mobile/feature/menu/logout_dialog.dart';
import 'package:odit_crm_mobile/feature/change_password/presentation/change_password_screen.dart';
import 'package:sizer/sizer.dart';

class OxdoDrawer extends StatelessWidget {
  const OxdoDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10.w),
        bottomLeft: Radius.circular(10.w),
      ),
      child: Drawer(
        backgroundColor: const Color(0xFFF7F7F7),
        width: 60.w,
        child: Column(
          children: [
            const _DrawerHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                children: [
                  _DrawerMenuItem(
                    icon: Icons.home_outlined,
                    title: 'Home',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomBottomNavScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.people_outline,
                    title: 'Staff Management',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CustomBottomNavScreen(index: CustomBottomNavScreen.staffIndex),
                        ),
                      );
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    onTap: () => ProfileBottomSheet.show(context),
                  ),
                  _DrawerMenuItem(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy T&C',
                  ),
                  _DrawerMenuItem(
                    icon: Icons.notifications_none,
                    title: 'Notification Settings',
                  ),
                  _DrawerMenuItem(
                    icon: Icons.location_on,
                    title: 'Company Locations',
                    iconColor: Color.fromARGB(255, 177, 41, 39),
                  ),
                  _DrawerMenuItem(
                    icon: Icons.dashboard_customize_outlined,
                    title: 'Set Dashboard',
                    iconColor: AppColors.skyBlue,
                  ),
                  _DrawerMenuItem(
                    icon: Icons.power_settings_new,
                    title: 'Logout',
                    onTap: () {
                      Navigator.pop(context);
                      LogoutDialog.show(context);
                    },
                  ),
                ],
              ),
            ),
            const _DrawerBottomBar(),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28.h,
      width: 100.w,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.bottomNavBlue, AppColors.bottomNavBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 13.h,
            width: 13.h,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'L2',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2F80ED),
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 1,
              ),
            ),
            child: Text(
              'OXDO LEADS',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback? onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    this.iconColor = const Color(0xFF444444),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: const Color(0xFF2F80ED).withOpacity(0.08),
      highlightColor: const Color(0xFF2F80ED).withOpacity(0.04),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
        child: Row(
          children: [
            Icon(icon, size: 6.5.w, color: iconColor),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF333333),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionLabel extends StatelessWidget {
  const _VersionLabel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 4.w + 5.5.w + 4.w,
        bottom: 1.h,
        top: 0.5.h,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Version : 3.0.6',
          style: TextStyle(
            fontSize: 9.sp,
            color: const Color(0xFF2F80ED),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _DrawerBottomBar extends StatelessWidget {
  const _DrawerBottomBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8.h,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _BottomIcon(icon: Icons.chat_outlined, onTap: () {}),
          _BottomIcon(icon: Icons.phone_outlined, onTap: () {}),
          _BottomIcon(icon: Icons.language_outlined, onTap: () {}),
        ],
      ),
    );
  }
}

class _BottomIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _BottomIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: EdgeInsets.all(2.w),
        child: Icon(icon, size: 6.w, color: const Color(0xFF555555)),
      ),
    );
  }
}
