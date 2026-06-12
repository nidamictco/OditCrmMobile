import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:sizer/sizer.dart';

// ---------------------------------------------------------------------------
// Save as: lib/feature/search/search_screen.dart
// ---------------------------------------------------------------------------

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.bottomNavBlue, // AppColors.bottomNvgtnBlue
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // centerTitle: true,
        title: Text(
          'Search',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search Bar ──────────────────────────────────────────────
            const SearchBarWidget(),
            SizedBox(height: 2.h),

            // ── Leads Header Card ────────────────────────────────────────
            const LeadHeaderCard(title: 'Leads', subtitle: '10 records found'),
            SizedBox(height: 2.h),

            // ── Lead Cards ───────────────────────────────────────────────
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => SizedBox(height: 2.h),
              itemBuilder: (_, __) => SearchLeadCard(
                name: 'Noushifa',
                phone: '+917902207315',
                tag: 'May Visit',
                assignedTo: 'Visited (HR)',
                status: 'Follow Up',
                nextFollowUp: '09-06-2026',
                lastCall: '08-06-2026',
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SEARCH BAR WIDGET
// ---------------------------------------------------------------------------
class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 3.w),
          Icon(Icons.search, color: AppColors.bottomNavBlue, size: 5.5.w),
          SizedBox(width: 2.w),
          Expanded(
            child: TextField(
              style: TextStyle(
                fontSize: 14.5.sp,
                color: const Color(0xFF333333),
              ),
              decoration: InputDecoration(
                hintText: 'Search leads or customer...',
                hintStyle: TextStyle(
                  fontSize: 14.5.sp,
                  color: const Color(0xFFAAAAAA),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          // Blue search button
          Padding(
            padding: EdgeInsets.only(right: 2.5.w),
            child: Container(
              width: 10.w,
              height: 10.w,
              padding: EdgeInsets.all(0.5),
              decoration: BoxDecoration(
                color: AppColors.bottomNavBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.search, color: Colors.white, size: 5.w),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LEAD HEADER CARD
// ---------------------------------------------------------------------------
class LeadHeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const LeadHeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Mint icon box
          Container(
            width: 11.w,
            height: 11.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.bar_chart_rounded,
              color: const Color(0xFF2ECC71),
              size: 6.w,
            ),
          ),
          SizedBox(width: 3.w),
          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF222222),
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.keyboard_arrow_up_rounded,
            color: const Color(0xFF666666),
            size: 6.w,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LEAD CARD
// ---------------------------------------------------------------------------
class SearchLeadCard extends StatelessWidget {
  final String name;
  final String phone;
  final String tag;
  final String assignedTo;
  final String status;
  final String nextFollowUp;
  final String lastCall;

  const SearchLeadCard({
    super.key,
    required this.name,
    required this.phone,
    required this.tag,
    required this.assignedTo,
    required this.status,
    required this.nextFollowUp,
    required this.lastCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Top: Avatar + Name + Tag ───────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.5.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar with red dot
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 6.5.w,
                      backgroundColor: const Color(0xFFDDDDDD),
                      child: Icon(Icons.person, size: 7.w, color: Colors.white),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 2.8.w,
                        height: 2.8.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE53935),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 3.w),
                // Name + Phone
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      SizedBox(height: 0.4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 4.w,
                            color: const Color(0xFF888888),
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            phone,
                            style: TextStyle(
                              fontSize: 15.5.sp,
                              color: const Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Tag pill
                StatusChip(
                  label: tag,
                  textColor: const Color(0xFF2F80ED),
                  backgroundColor: const Color(0xFFDEEDFF),
                  borderColor: Colors.transparent,
                  showDot: false,
                ),
              ],
            ),
          ),

          // ── Divider ───────────────────────────────────────────────────
          Divider(height: 1, thickness: 1, color: const Color(0xFFF0F0F0)),

          // ── Middle: Chips ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            child: Row(
              children: [
                // Assigned chip
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 0.8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 5.w,
                        color: const Color(0xFF666666),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        assignedTo,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Status chip
                StatusChip(
                  label: status,
                  textColor: const Color(0xFFE6A817),
                  backgroundColor: const Color(0xFFFFF8E6),
                  borderColor: const Color(0xFFE6A817),
                  showDot: true,
                ),
              ],
            ),
          ),

          // ── Info Box ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: InfoBox(nextFollowUp: nextFollowUp, lastCall: lastCall),
          ),
          SizedBox(height: 1.5.h),

          // ── Contact Now Button ────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3DAA5C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 7.w,
                      height: 7.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.phone, color: Colors.white, size: 5.w),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Contact Now',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// INFO BOX
// ---------------------------------------------------------------------------
class InfoBox extends StatelessWidget {
  final String nextFollowUp;
  final String lastCall;

  const InfoBox({
    super.key,
    required this.nextFollowUp,
    required this.lastCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left: Next Follow-Up
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEXT FOLLOW-UP',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFAAAAAA),
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      nextFollowUp,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2F80ED),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Vertical divider
            VerticalDivider(
              thickness: 1,
              color: const Color(0xFFDDDDDD),
              width: 1,
            ),
            // Right: Last Call
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LAST CALL',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFAAAAAA),
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      lastCall,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF444444),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// STATUS CHIP
// ---------------------------------------------------------------------------
class StatusChip extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;
  final bool showDot;

  const StatusChip({
    super.key,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 2.w,
              height: 2.w,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 1.w),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
