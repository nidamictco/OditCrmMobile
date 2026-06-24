import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/feature/staff_management/Screen/model/staff_model.dart';
import 'package:odit_crm_mobile/feature/reports/widgets/report_appbar.dart';
import 'package:odit_crm_mobile/feature/reports/widgets/staff_report_card.dart';
import 'package:odit_crm_mobile/feature/staff_management/cubit/staff_cubit.dart';
import 'package:odit_crm_mobile/feature/staff_management/cubit/staff_state.dart';
import 'package:sizer/sizer.dart';

class StaffReportScreen extends StatelessWidget {
  const StaffReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StaffCubit()..fetchAll(),
      child: const StaffReportContent(),
    );
  }
}

class StaffReportContent extends StatefulWidget {
  const StaffReportContent({super.key});

  @override
  State<StaffReportContent> createState() => _StaffReportContentState();
}

class _StaffReportContentState extends State<StaffReportContent> {
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const ReportAppBar(title: 'Staff Report'),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Container(
              height: 6.5.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search staff name or designation...',
                  hintStyle: TextStyle(
                    color: const Color(0xFFBDBDBD),
                    fontSize: 14.sp,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFBDBDBD),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 1.8.h),
                ),
              ),
            ),
          ),

          // Grouped Staff List
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
                        style: TextStyle(fontSize: 13.sp, color: Colors.red),
                      ),
                    ),
                  );
                } else if (state is StaffListLoaded) {
                  final List<StaffModel> telecallingStaff = [];
                  final List<StaffModel> adminStaff = [];

                  for (var staff in state.staffList) {
                    final isCompanyAdmin = staff.designation?.toLowerCase() == 'company_admin' ||
                        staff.designation?.toLowerCase() == 'company admin' ||
                        staff.staffType?.toLowerCase() == 'admin';

                    if (isCompanyAdmin) {
                      adminStaff.add(staff);
                    } else {
                      telecallingStaff.add(staff);
                    }
                  }

                  // Filter logic
                  final filteredTelecalling = telecallingStaff.where((staff) {
                    final query = _searchQuery.trim().toLowerCase();
                    final matchName = staff.name.toLowerCase().contains(query);
                    final matchDesig = (staff.designation ?? staff.staffType ?? '').toLowerCase().contains(query);
                    final matchPhone = staff.phone.toLowerCase().contains(query);
                    return matchName || matchDesig || matchPhone;
                  }).toList();

                  final filteredAdmin = adminStaff.where((staff) {
                    final query = _searchQuery.trim().toLowerCase();
                    final matchName = staff.name.toLowerCase().contains(query);
                    final matchDesig = (staff.designation ?? staff.staffType ?? '').toLowerCase().contains(query);
                    final matchPhone = staff.phone.toLowerCase().contains(query);
                    return matchName || matchDesig || matchPhone;
                  }).toList();

                  if (filteredTelecalling.isEmpty && filteredAdmin.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 10.h),
                        child: Text(
                          'No staff reports found',
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: 4.w,
                      right: 4.w,
                      bottom: MediaQuery.of(context).padding.bottom + 2.h,
                    ),
                    children: [
                      // Telecalling Section
                      if (filteredTelecalling.isNotEmpty) ...[
                        _buildSectionHeader('Telecalling'),
                        SizedBox(height: 1.5.h),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredTelecalling.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 1.5.h),
                          itemBuilder: (context, index) {
                            return StaffReportCard(
                              staff: filteredTelecalling[index],
                              onTap: () {},
                            );
                          },
                        ),
                        SizedBox(height: 3.h),
                      ],

                      // Company Admin Section
                      if (filteredAdmin.isNotEmpty) ...[
                        _buildSectionHeader('Company Admin'),
                        SizedBox(height: 1.5.h),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredAdmin.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 1.5.h),
                          itemBuilder: (context, index) {
                            return StaffReportCard(
                              staff: filteredAdmin[index],
                              onTap: () {},
                            );
                          },
                        ),
                      ],
                    ],
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

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        // Left Blue vertical bar
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF2F80ED),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1D2433),
          ),
        ),
        SizedBox(width: 3.w),
        // Section divider line
        const Expanded(
          child: Divider(color: Color(0xFFE5E7EB), thickness: 1.5),
        ),
      ],
    );
  }
}

