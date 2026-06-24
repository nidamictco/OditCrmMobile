import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/feature/lead_details/cubit/activity_cubit.dart';
import 'package:odit_crm_mobile/feature/lead_details/data/activity_repo.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/activity_model.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/add_lead_model.dart';
import 'package:sizer/sizer.dart';

class LeadActivitiesTab extends StatefulWidget {
  final AddLeadModel lead;

  const LeadActivitiesTab({super.key, required this.lead});

  @override
  State<LeadActivitiesTab> createState() => _LeadActivitiesTabState();
}

class _LeadActivitiesTabState extends State<LeadActivitiesTab> {
  late final ActivityCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ActivityCubit(ActivityRepository());
    if (widget.lead.id != null && widget.lead.id!.isNotEmpty) {
      _cubit.fetchActivities(widget.lead.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<ActivityCubit, ActivityState>(
        builder: (context, state) {
          if (state is ActivityLoading) {
            return SizedBox(
              height: 40.h,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is ActivityError) {
            return SizedBox(
              height: 40.h,
              child: Center(
                child: Text('Error: ${state.errorMessage}'),
              ),
            );
          } else if (state is ActivityLoaded) {
            final activities = List<ActivityModel>.from(state.activities);

            // The first container for lead creation is still shown at the bottom of the list.
            // Check if a Lead Created activity is already in the list; if not, add it.
            final hasCreatedActivity = activities.any((a) => a.type == ActivityType.leadCreated);
            if (!hasCreatedActivity) {
              activities.add(
                ActivityModel(
                  id: "creation_${widget.lead.id}",
                  changedBy: widget.lead.createdBy.isNotEmpty ? widget.lead.createdBy : 'System',
                  changedById: widget.lead.createdById,
                  changedAt: widget.lead.createdAt ?? DateTime.now(),
                  type: ActivityType.leadCreated,
                  description: "Lead Created",
                ),
              );
            }

            if (activities.isEmpty) {
              return SizedBox(
                height: 40.h,
                child: const Center(
                  child: Text('No Activities Found'),
                ),
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: 1.w,
                vertical: 1.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(activities.length, (index) {
                  return ActivityTimelineItem(
                    activity: activities[index],
                    isLast: index == activities.length - 1,
                  );
                }),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class ActivityTimelineItem extends StatelessWidget {
  final ActivityModel activity;
  final bool isLast;

  const ActivityTimelineItem({
    super.key,
    required this.activity,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine card background and icon based on activity type
    final isTransfer = activity.type == ActivityType.staffAssigned;
    final contentBgColor = isTransfer
        ? const Color(0xFFEAF3FF)
        : const Color(0xFFF7F8FA);
    final activityIcon = isTransfer ? Icons.groups : Icons.comment;
    final dateStr = DateFormat('dd-MM-yyyy hh:mm a').format(activity.changedAt);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Side: Avatar & Timeline Line
          Column(
            children: [
              // Avatar
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.bottomNavBlue, width: 2),
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: 45,
                    color: AppColors.bottomNavBlue.withAlpha(204),
                  ),
                ),
              ),
              // Timeline vertical line
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: const Color(0xFFD8E7FF)),
                ),
            ],
          ),
          SizedBox(width: 4.w),
          // Right Side Card
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 3.h),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      offset: Offset(0, 3),
                      color: Colors.black12,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Staff Name
                        Text(
                          activity.changedBy,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        // Date Badge
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.5.w,
                            vertical: 0.6.h,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                color: const Color(0xFF9CA3AF),
                                size: 5.w,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                dateStr,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.5.h),
                    // Activity Content Box
                    Container(
                      decoration: BoxDecoration(
                        color: contentBgColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: EdgeInsets.all(4.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            activityIcon,
                            color: AppColors.bottomNavBlue,
                            size: 5.5.w,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              activity.description,
                              style: TextStyle(
                                fontSize: 14.5.sp,
                                color: const Color(0xFF4B5563),
                                height: 1.3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
