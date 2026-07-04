import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/core/utils/app_bar.dart';
import 'package:odit_crm_mobile/feature/reports/widgets/report_appbar.dart';
import 'package:odit_crm_mobile/feature/staff_management/model/staff_model.dart';
import 'package:odit_crm_mobile/feature/staff_management/cubit/staff_cubit.dart';
import 'package:odit_crm_mobile/feature/staff_management/cubit/staff_state.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_cubit.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_state.dart';
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
            child: BlocBuilder<AddLeadCubit, AddLeadState>(
              builder: (context, leadState) {
                final Map<String, List<int>> staffLeadCounts = {};
                for (final lead in leadState.leads) {
                  final staffId = lead.assignedStaffId;
                  if (staffId.isEmpty) continue;

                  staffLeadCounts.putIfAbsent(staffId, () => [0, 0]);
                  staffLeadCounts[staffId]![0]++;

                  if (lead.leadStage.toUpperCase() == 'CLOSED') {
                    staffLeadCounts[staffId]![1]++;
                  }
                }

                return BlocBuilder<StaffCubit, StaffState>(
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
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    } else if (state is StaffListLoaded) {
                      final filteredStaff = state.staffList.where((staff) {
                        final query = _searchQuery.trim().toLowerCase();
                        final nameMatch = staff.name.toLowerCase().contains(
                          query,
                        );
                        final desigMatch =
                            (staff.designation ?? staff.staffType ?? '')
                                .toLowerCase()
                                .contains(query);
                        final phoneMatch = staff.phone.toLowerCase().contains(
                          query,
                        );
                        return nameMatch || desigMatch || phoneMatch;
                      }).toList();

                      if (filteredStaff.isEmpty) {
                        return Center(
                          child: Text(
                            'No staff found',
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.grey,
                            ),
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
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 2.h),
                        itemBuilder: (context, index) {
                          final s = filteredStaff[index];
                          final counts = staffLeadCounts[s.id] ?? [0, 0];
                          return StaffPerformanceCard(
                            key: ValueKey(s.id),
                            staff: s,
                            totalLeads: counts[0],
                            closedLeads: counts[1],
                          );
                        },
                      );
                    }
                    return const Center(child: Text('No staff data'));
                  },
                );
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

class StaffPerformanceCard extends StatefulWidget {
  final StaffModel staff;
  final int totalLeads;
  final int closedLeads;

  const StaffPerformanceCard({
    super.key,
    required this.staff,
    this.totalLeads = 0,
    this.closedLeads = 0,
  });

  @override
  State<StaffPerformanceCard> createState() => _StaffPerformanceCardState();
}

class _StaffPerformanceCardState extends State<StaffPerformanceCard> {
    final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isProcessing = false;

  StaffModel get staff => widget.staff;

  bool get _isActive => staff.status == 'Active';

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    final overlay = Overlay.of(context);

    // Snapshot status at the moment the menu opens, so the label/color
    // shown in the popup always matches the latest staff.status.
    final bool isActive = _isActive;
    final String actionLabel = isActive ? 'Disable' : 'Enable';
    final Color actionColor = isActive ? Colors.red : Colors.green;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeMenu,
              child: Container(color: Colors.transparent),
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(-120, 30),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: _isProcessing
                        ? null
                        : () {
                            _closeMenu();
                            // Use the State's own `context` (the card's context,
                            // which is under BlocProvider<StaffCubit>), NOT the
                            // overlay builder's local `overlayContext`.
                            _showToggleConfirmation(context, isActive);
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        actionLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _isProcessing
                              ? Colors.grey.shade400
                              : actionColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _showToggleConfirmation(
    BuildContext context,
    bool isActive,
  ) async {
    // Capture the cubit BEFORE any await — context may become invalid after.
    final cubit = context.read<StaffCubit>();

    final String title = isActive ? 'Disable Staff' : 'Enable Staff';
    final String message = isActive
        ? 'Are you sure you want to disable this staff member?'
        : 'Are you sure you want to enable this staff member?';
    final String confirmLabel = isActive ? 'Disable' : 'Enable';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    if (confirmed == true && staff.id != null) {
      await _updateStaffStatus(cubit, isActive);
    }
  }

  Future<void> _updateStaffStatus(StaffCubit cubit, bool wasActive) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final String newStatus = wasActive ? 'Inactive' : 'Active';

    debugPrint('[ToggleStaffStatus] Selected staff ID: ${staff.id}');
    debugPrint('[ToggleStaffStatus] Current status: ${staff.status}');
    debugPrint('[ToggleStaffStatus] New status: $newStatus');

    try {
      await cubit.updateStatus(staff.id!, newStatus);
      final resultState = cubit.state;
      debugPrint('[ToggleStaffStatus] Cubit state after update: $resultState');

      if (resultState is StaffError) {
        debugPrint('[ToggleStaffStatus] Update FAILED: ${resultState.message}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to ${wasActive ? 'disable' : 'enable'} staff: ${resultState.message}',
              ),
            ),
          );
        }
      } else {
        debugPrint('[ToggleStaffStatus] Update SUCCEEDED for staffId: ${staff.id}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                wasActive
                    ? 'Staff has been disabled successfully.'
                    : 'Staff has been enabled successfully.',
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    _closeMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 16.w,
                height: 16.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  shape: BoxShape.circle,
                  image: staff.imageUrl != null && staff.imageUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(staff.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (staff.imageUrl == null || staff.imageUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              staff.name,
                              style: TextStyle(
                                fontSize: 16.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1D2433),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            SizedBox(width: 2.w),
                            DesignationBadge(
                              label:
                                  staff.designation ??
                                  staff.staffType ??
                                  'Staff',
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_android_outlined,
                          color: Color(0xFFBDBDBD),
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          staff.phone,
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: CompositedTransformTarget(
                  link: _layerLink,
                  child: GestureDetector(
                    onTap: _toggleMenu,
                    child: const Icon(
                      Icons.more_horiz,
                      color: Color(0xFFBDBDBD),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    StaffStatBox(
                      title: 'Leads',
                      value: widget.totalLeads.toString(),
                      backgroundColor: const Color(0xFFF6F4FF),
                      borderColor: const Color(0xFFE6E0FF),
                      valueColor: const Color(0xFF6C63FF),
                    ),
                    SizedBox(width: 2.w),
                    StaffStatBox(
                      title: 'Closed',
                      value: widget.closedLeads.toString(),
                      backgroundColor: const Color(0xFFF0FBF8),
                      borderColor: const Color(0xFFDDF4EE),
                      valueColor: const Color(0xFF21B98C),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 2.w,
                    height: 2.w,
                    decoration: BoxDecoration(
                      color: widget.staff.status == 'Active'
                          ? Colors.green.shade400
                          : Colors.red.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 0.3.w),
                  Text(
                    widget.staff.status,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: widget.staff.status == 'Active'
                          ? Colors.green.shade400
                          : Colors.red.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.5.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
          SizedBox(width: 1.5.w),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            maxLines: 2,
            softWrap: true,

            overflow: TextOverflow.ellipsis,
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




