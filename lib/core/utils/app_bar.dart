import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/core/shared_prefference/session_service.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/feature/home/search_screen.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_cubit.dart';
import 'package:odit_crm_mobile/feature/notification/screen/notification_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:odit_crm_mobile/feature/staff_management/model/staff_model.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? avatarImagePath;

  final VoidCallback? onAvatarTap;
  final VoidCallback? onMoreTap;

  final int notificationCount;

  const CommonAppBar({
    super.key,
    this.avatarImagePath,
    this.onAvatarTap,
    this.onMoreTap,
    this.notificationCount = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StaffModel?>(
      future: SessionService().getSavedUser(),
      builder: (context, snapshot) {
        final String displayName;
        final String displayRole;

        if (snapshot.connectionState == ConnectionState.waiting) {
          displayName = 'Loading...';
          displayRole = 'Loading...';
        } else {
          final user = snapshot.data;
          displayName = user?.name ?? 'Guest';
          displayRole = user?.staffType ?? 'Unknown';
        }

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: Container(
            decoration: const BoxDecoration(color: AppColors.bottomNavBlue),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 80,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      // ── Avatar ──────────────────────────────
                      GestureDetector(
                        onTap: onAvatarTap,
                        child: _Avatar(imagePath: avatarImagePath),
                      ),
                      const SizedBox(width: 12),

                      // ── Company name + role ──────────────────
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                                height: 1.2,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              displayRole,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Action icons ────────────────────────
                      _AppBarIconButton(
                        icon: Icons.notifications_none_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationScreen(),
                            ),
                          );
                        },
                        badgeCount: notificationCount,
                      ),
                      SizedBox(width: 4),
                      _AppBarIconButton(
                        icon: Icons.search,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<AddLeadCubit>(),
                                child: const SearchScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// AVATAR
// ─────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? imagePath;

  const _Avatar({this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.15),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
      ),
      child: ClipOval(
        child: imagePath != null
            ? Image.asset(
                imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _PlaceholderAvatar(),
              )
            : const _PlaceholderAvatar(),
      ),
    );
  }
}

class _PlaceholderAvatar extends StatelessWidget {
  const _PlaceholderAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.15),
      child: Icon(
        Icons.person_rounded,
        size: 26,
        color: Colors.white.withOpacity(0.85),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ICON BUTTON WITH OPTIONAL BADGE
// ─────────────────────────────────────────────

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final int badgeCount;

  const _AppBarIconButton({
    required this.icon,
    this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            if (badgeCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
