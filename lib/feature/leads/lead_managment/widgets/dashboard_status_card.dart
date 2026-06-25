import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/feature/reports/presentation/lead_report_screen.dart';
import 'package:sizer/sizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
enum StatCardVariant {
  twoLabel,
  actionIcons,
  twoLabelWithFilter,
}

// ─────────────────────────────────────────────────────────────────────────────
// DashboardStatCard
// ─────────────────────────────────────────────────────────────────────────────

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String count;
  final Color backgroundColor;
  final IconData watermarkIcon;
  final String? leftLabel;
  final String? leftValue;
  final String? rightLabel;
  final String? rightValue;

  final List<IconData>? actionIcons;
  final VoidCallback? onActionTap;
  final List<VoidCallback>? onActionTaps;
  final bool showFilterButton;
  final VoidCallback? onFilterTap;

  final StatCardVariant variant;
  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.count,
    required this.backgroundColor,
    required this.watermarkIcon,
    this.leftLabel,
    this.leftValue,
    this.rightLabel,
    this.rightValue,
    this.actionIcons,
    this.onActionTap,
    this.onActionTaps,
    this.showFilterButton = false,
    this.onFilterTap,
    this.variant = StatCardVariant.twoLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LeadReportScreen()),
      ),
      child: AspectRatio(
        aspectRatio: 0.99,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5.w),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.45),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // ── Watermark icon ──────────────────────────────────────────
              Positioned(
                bottom: -1.5.h,
                right: -2.w,
                child: Icon(
                  watermarkIcon,
                  size: 20.w,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),

              // ── Card content ────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.all(4.5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.92),
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (showFilterButton)
                          GestureDetector(
                            onTap: onFilterTap,
                            child: Container(
                              width: 7.w,
                              height: 7.w,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.20),
                                borderRadius: BorderRadius.circular(2.w),
                              ),
                              child: Icon(
                                Icons.filter_list_rounded,
                                size: 4.w,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 0.8.h),

                    // Count
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),

                    const Spacer(),

                    // Bottom section
                    _buildBottom(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottom() {
    switch (variant) {
      case StatCardVariant.twoLabel:
        return _TwoLabelRow(
          leftLabel: leftLabel ?? '',
          leftValue: leftValue ?? '0',
          rightLabel: rightLabel ?? '',
          rightValue: rightValue ?? '0',
        );

      case StatCardVariant.twoLabelWithFilter:
        return _TwoLabelRow(
          leftLabel: leftLabel ?? '',
          leftValue: leftValue ?? '0',
          rightLabel: rightLabel ?? '',
          rightValue: rightValue ?? '0',
        );

      case StatCardVariant.actionIcons:
        return _ActionIconRow(
          icons: actionIcons ?? [],
          onActionTaps: onActionTaps,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Two-label bottom row  (New / Closed / Lost cards)
// ─────────────────────────────────────────────────────────────────────────────

class _TwoLabelRow extends StatelessWidget {
  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  const _TwoLabelRow({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LabelValue(label: leftLabel, value: leftValue),
        Container(
          width: 0.4,
          height: 4.h,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          color: Colors.white.withOpacity(0.30),
        ),
        _LabelValue(label: rightLabel, value: rightValue),
      ],
    );
  }
}

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;

  const _LabelValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white.withOpacity(0.78),
            fontWeight: FontWeight.w400,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        SizedBox(height: 0.3.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 17.sp,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
           overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action icons row  (Active card)
// ─────────────────────────────────────────────────────────────────────────────

class _ActionIconRow extends StatelessWidget {
  final List<IconData> icons;
  final List<VoidCallback>? onActionTaps;

  const _ActionIconRow({
    required this.icons,
    this.onActionTaps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(icons.length, (index) {
        final icon = icons[index];
        final onTap = (onActionTaps != null && onActionTaps!.length > index)
            ? onActionTaps![index]
            : null;
        return Padding(
          padding: EdgeInsets.only(right: 2.5.w),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              width: 9.w,
              height: 9.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 4.5.w),
            ),
          ),
        );
      }),
    );
  }
}
