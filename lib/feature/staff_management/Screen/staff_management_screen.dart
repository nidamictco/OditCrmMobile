import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/core/utils/app_bar.dart';
import 'package:odit_crm_mobile/feature/reports/widgets/report_appbar.dart';
import 'package:odit_crm_mobile/feature/staff_management/Screen/model/staff_model.dart';
import 'package:odit_crm_mobile/feature/staff_management/cubit/staff_cubit.dart';
import 'package:odit_crm_mobile/feature/staff_management/cubit/staff_state.dart';
import 'package:sizer/sizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STAFF MANAGEMENT SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class StaffManagementScreen extends StatelessWidget {
  const StaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StaffCubit()..fetchAll(),
      child: const StaffManagementContent(),
    );
  }
}

class StaffManagementContent extends StatefulWidget {
  const StaffManagementContent({super.key});

  @override
  State<StaffManagementContent> createState() => _StaffManagementContentState();
}

class _StaffManagementContentState extends State<StaffManagementContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const ReportAppBar(title: 'Staff Management'),
      body: Column(
        children: [
          // Search Bar Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Container(
              height: 7.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: const Color(0xFF1D2433),
                  fontSize: 15.sp,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search staff name, designation or phone...',
                  hintStyle: TextStyle(
                    color: const Color(0xFFBDBDBD),
                    fontSize: 15.sp,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFBDBDBD),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),
          ),

          // Staff List Section
          Expanded(
            child: BlocBuilder<StaffCubit, StaffState>(
              builder: (context, state) {
                if (state is StaffLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is StaffError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15.sp, color: Colors.red),
                      ),
                    ),
                  );
                } else if (state is StaffListLoaded) {
                  final filteredStaff = state.staffList.where((staff) {
                    final query = _searchQuery.trim().toLowerCase();
                    final nameMatch = staff.name.toLowerCase().contains(query);
                    final desigMatch = (staff.designation ?? staff.staffType ?? '').toLowerCase().contains(query);
                    final phoneMatch = staff.phone.toLowerCase().contains(query);
                    return nameMatch || desigMatch || phoneMatch;
                  }).toList();

                  if (filteredStaff.isEmpty) {
                    return Center(
                      child: Text(
                        'No staff found',
                        style: TextStyle(fontSize: 15.sp, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: 4.w,
                      right: 4.w,
                      bottom: MediaQuery.of(context).padding.bottom + 2.h,
                    ),
                    itemCount: filteredStaff.length,
                    separatorBuilder: (context, index) => SizedBox(height: 2.h),
                    itemBuilder: (context, index) {
                      return StaffPerformanceCard(staff: filteredStaff[index]);
                    },
                  );
                }
                return const Center(child: Text('No staff data'));
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class StaffPerformanceCard extends StatelessWidget {
  final StaffModel staff;

  const StaffPerformanceCard({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 35,
                backgroundColor: const Color(0xFFE0E0E0),
                backgroundImage: staff.imageUrl != null && staff.imageUrl!.isNotEmpty
                    ? NetworkImage(staff.imageUrl!)
                    : null,
                child: (staff.imageUrl == null || staff.imageUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
              SizedBox(width: 4.w),
              // Name and Designation Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.name ?? '',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D2433),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    DesignationBadge(label: staff.designation ?? staff.staffType ?? 'Staff'),
                  ],
                ),
              ),
              // Popup Menu Icon
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {},
                icon: const Icon(Icons.more_horiz, color: Color(0xFFBDBDBD)),
              ),
            ],
          ),
          SizedBox(height: 1.h),

          // Phone Section
          Row(
            children: [
              const Icon(
                Icons.phone_android_outlined,
                color: Color(0xFFBDBDBD),
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                staff.phone ?? 'N/A',
                style: TextStyle(
                  fontSize: 14.5.sp,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),

          // Statistics Cards Row
          Row(
            children: [
              Expanded(
                child: StaffStatBox(
                  title: 'Leads',
                  value: '0',
                  backgroundColor: const Color(0xFFF6F4FF),
                  borderColor: const Color(0xFFE6E0FF),
                  valueColor: const Color(0xFF6C63FF),
                ),
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: StaffStatBox(
                  title: 'Closed',
                  value: '0',
                  backgroundColor: const Color(0xFFF0FBF8),
                  borderColor: const Color(0xFFDDF4EE),
                  valueColor: const Color(0xFF21B98C),
                ),
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: StaffStatBox(
                  title: 'Calls (Ph/Cl)',
                  value: '- / 0',
                  backgroundColor: const Color(0xFFFFFBF3),
                  borderColor: const Color(0xFFF7E6BC),
                  valueColor: const Color(0xFFE0A82E),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}

class DesignationBadge extends StatelessWidget {
  final String label;

  const DesignationBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5FF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2F80ED),
        ),
      ),
    );
  }
}

class StaffStatBox extends StatelessWidget {
  final String title;
  final String value;
  final Color backgroundColor;
  final Color borderColor;
  final Color valueColor;

  const StaffStatBox({
    super.key,
    required this.title,
    required this.value,
    required this.backgroundColor,
    required this.borderColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class PerformanceProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0

  const PerformanceProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 10,
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: const Color(0xFFF0F0F0),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF66BB6A)),
        ),
      ),
    );
  }
}
