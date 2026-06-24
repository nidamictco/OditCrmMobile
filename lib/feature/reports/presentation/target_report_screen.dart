import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/feature/reports/widgets/report_appbar.dart';
import 'package:sizer/sizer.dart';

class TargetReportScreen extends StatefulWidget {
  const TargetReportScreen({super.key});

  @override
  State<TargetReportScreen> createState() => _TargetReportScreenState();
}

class _TargetReportScreenState extends State<TargetReportScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: ReportAppBar(
        title: 'All Target Reports',
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.add_rounded, color: Colors.white, size: 22.sp),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          children: [
            // Search Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by Group Name',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 15.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade400,
                    size: 17.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 1.8.h),
                ),
              ),
            ),
            SizedBox(height: 2.h),

            // Date Filters Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 1.5.h,
                      horizontal: 3.w,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'From: 01-06-2026',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 1.5.h,
                      horizontal: 3.w,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'To: 17-06-2026',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Empty State
            const Expanded(
              child: Center(
                child: Text(
                  'No target reports found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
