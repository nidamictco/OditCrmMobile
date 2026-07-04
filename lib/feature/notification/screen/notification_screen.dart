import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:odit_crm_mobile/core/shared_prefference/session_service.dart';
import 'package:sizer/sizer.dart';

import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/feature/notification/cubit/notification_cubit.dart';
import 'package:odit_crm_mobile/feature/notification/cubit/notification_state.dart';
import 'package:odit_crm_mobile/feature/notification/model/notification_model.dart';
import 'package:odit_crm_mobile/feature/reports/widgets/report_appbar.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String? _staffId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final user = await SessionService().getSavedUser();
    if (!mounted) return;
    final id = user?.id ?? '';
    setState(() => _staffId = id);
    context.read<NotificationCubit>().load(id);
  }

  Future<void> _onRefresh() async {
    final id = _staffId;
    if (id != null && id.isNotEmpty) {
      context.read<NotificationCubit>().load(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const ReportAppBar(title: "Notification"),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          // Mark all as read as soon as the list lands on screen
          if (state is NotificationLoaded) {
            final id = _staffId;
            if (id != null && id.isNotEmpty) {
              context.read<NotificationCubit>().markAllRead(id);
            }
          }
        },
        builder: (context, state) {
          // ── Loading ─────────────────────────────────────────────────
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Error ───────────────────────────────────────────────────
          if (state is NotificationError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade400, fontSize: 14.sp),
                ),
              ),
            );
          }

          // ── Resolve list from all "has data" states ─────────────────
          final List<NotificationModel> notifications;
          if (state is NotificationLoaded) {
            notifications = state.notifications;
          } else if (state is NotificationDeleting) {
            notifications = state.notifications;
          } else if (state is NotificationDeleteError) {
            notifications = state.notifications;
          } else {
            notifications = [];
          }

          // ── Empty ───────────────────────────────────────────────────
          if (notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                // Wrap in ListView so pull-to-refresh works on empty state
                children: const [SizedBox(height: 200), _EmptyState()],
              ),
            );
          }

          // ── Loaded list ─────────────────────────────────────────────
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) =>
                  const Divider(thickness: 1, color: Color(0xFFE5E5E5)),
              itemBuilder: (context, index) {
                return NotificationTile(notification: notifications[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

// ─── Tile ─────────────────────────────────────────────────────────────────────

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final dateLabel = notification.createdAt != null
        ? DateFormat('dd-MM-yyyy').format(notification.createdAt!)
        : DateFormat('dd-MM-yyyy').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar ────────────────────────────────────────────────
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/app_logo.png',
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.bottomNavBlue,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ── Content ───────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 16.sp,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    color: const Color(0xFF555555),
                    fontSize: 14.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── Date ──────────────────────────────────────────────────
          Text(
            dateLabel,
            style: TextStyle(color: const Color(0xFFAAAAAA), fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 56,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            "No notifications yet",
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
