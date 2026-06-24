import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

// ---------------------------------------------------------------------------
// Save as: lib/feature/leads/report/analytics_card.dart
// ---------------------------------------------------------------------------

// ── Palette constants ────────────────────────────────────────────────────────
const _kDarkBlue = Color(0xFF1A3A6B);
const _kBlue = Color(0xFF2F80ED);
const _kRed = Color(0xFFE53935);
const _kGreen = Color(0xFF43A047);
const _kYellow = Color(0xFFFFC107);
const _kPurple = Color(0xFF8E24AA);
const _kBadgeBg = Color(0xFFEDE7F6);
const _kBadgeBorder = Color(0xFFB39DDB);
const _kSummaryBg = Color(0xFFF3F7FA);
const _kGreyText = Color(0xFF9E9E9E);
const _kProgressBg = Color(0xFFEEEEEE);

// ── Data models ──────────────────────────────────────────────────────────────
class AnalyticsItem {
  final String label;
  final int count;
  final double percentage;
  final Color progressColor;

  const AnalyticsItem({
    required this.label,
    required this.count,
    required this.percentage,
    required this.progressColor,
  });
}

// ===========================================================================
// ANALYTICS CARD  (top-level entry point)
// ===========================================================================
class AnalyticsCard extends StatelessWidget {
  final List<AnalyticsItem> agentItems;
  final List<AnalyticsItem> categoryItems;
  final String summaryLabel;
  final String summaryValue;

  const AnalyticsCard({
    super.key,
    required this.agentItems,
    required this.categoryItems,
    this.summaryLabel = 'Total New Generated',
    this.summaryValue = '40 Leads',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Agent Wise ───────────────────────────────────────────────
          AnalyticsSectionHeader(
            title: 'AGENT WISE',
            badgeCount: agentItems.length,
          ),
          SizedBox(height: 2.h),
          ...agentItems.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: AnalyticsProgressItem(item: item),
            ),
          ),

          // ── Divider ──────────────────────────────────────────────────
          Divider(color: const Color(0xFFEEEEEE), thickness: 1.2),
          SizedBox(height: 2.h),

          // ── Category Wise ─────────────────────────────────────────────
          AnalyticsSectionHeader(
            title: 'CATEGORY WISE',
            badgeCount: categoryItems.length,
          ),
          SizedBox(height: 2.h),
          ...categoryItems.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: AnalyticsProgressItem(item: item),
            ),
          ),

          // ── Summary tile ─────────────────────────────────────────────
          AnalyticsSummaryTile(label: summaryLabel, value: summaryValue),
        ],
      ),
    );
  }
}

// ===========================================================================
// SECTION HEADER  →  "AGENT WISE  [3]"
// ===========================================================================
class AnalyticsSectionHeader extends StatelessWidget {
  final String title;
  final int badgeCount;

  const AnalyticsSectionHeader({
    super.key,
    required this.title,
    required this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            color: _kDarkBlue,
            letterSpacing: 2,
          ),
        ),
        SizedBox(width: 3.w),
        AnalyticsCountBadge(count: badgeCount),
      ],
    );
  }
}

// ===========================================================================
// COUNT BADGE  →  rounded "[3]"
// ===========================================================================
class AnalyticsCountBadge extends StatelessWidget {
  final int count;

  const AnalyticsCountBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: _kBadgeBg,
        borderRadius: BorderRadius.circular(2.w),
        border: Border.all(color: _kBadgeBorder, width: 1.2),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: _kPurple,
        ),
      ),
    );
  }
}

// ===========================================================================
// PROGRESS ITEM  →  one row (name + count + bar + %)
// ===========================================================================
class AnalyticsProgressItem extends StatelessWidget {
  final AnalyticsItem item;

  const AnalyticsProgressItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name + count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF333333),
              ),
            ),
            Text(
              item.count.toString(),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111111),
              ),
            ),
          ],
        ),
        SizedBox(height: 0.8.h),
        // Progress bar + percentage
        AnalyticsProgressBar(
          percentage: item.percentage,
          progressColor: item.progressColor,
        ),
      ],
    );
  }
}

// ===========================================================================
// PROGRESS BAR
// ===========================================================================
class AnalyticsProgressBar extends StatelessWidget {
  final double percentage; // 0.0 – 1.0
  final Color progressColor;

  const AnalyticsProgressBar({
    super.key,
    required this.percentage,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final pctText = '${(percentage * 100).round()}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bar
        LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final fillWidth = (totalWidth * percentage).clamp(0.0, totalWidth);

            return Stack(
              children: [
                // Track
                Container(
                  height: 0.7.h,
                  width: totalWidth,
                  decoration: BoxDecoration(
                    color: _kProgressBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Fill
                Container(
                  height: 0.7.h,
                  width: fillWidth,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: 0.4.h),
        // Percentage aligned right
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            pctText,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: progressColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// SUMMARY TILE  →  "Total New Generated    40 Leads"
// ===========================================================================
class AnalyticsSummaryTile extends StatelessWidget {
  final String label;
  final String value;

  const AnalyticsSummaryTile({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: _kSummaryBg,
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: _kGreyText,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: _kBlue,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// DEMO USAGE — drop this anywhere in your screen
// ===========================================================================
//
// AnalyticsCard(
//   agentItems: const [
//     AnalyticsItem(label: 'Fairooza', count: 37, percentage: 0.92, progressColor: Color(0xFF2F80ED)),
//     AnalyticsItem(label: 'Farsana',  count: 2,  percentage: 0.05, progressColor: Color(0xFF2F80ED)),
//     AnalyticsItem(label: 'Shahid',   count: 1,  percentage: 0.02, progressColor: Color(0xFFFFC107)),
//   ],
//   categoryItems: const [
//     AnalyticsItem(label: 'Not Contacted',        count: 29, percentage: 0.72, progressColor: Color(0xFFE53935)),
//     AnalyticsItem(label: 'Need Further Followup',count: 8,  percentage: 0.20, progressColor: Color(0xFF43A047)),
//     AnalyticsItem(label: 'Uncategorized',        count: 2,  percentage: 0.05, progressColor: Color(0xFFE53935)),
//     AnalyticsItem(label: 'Fake',                 count: 1,  percentage: 0.02, progressColor: Color(0xFF8E24AA)),
//   ],
//   summaryLabel: 'Total New Generated',
//   summaryValue: '40 Leads',
// )
