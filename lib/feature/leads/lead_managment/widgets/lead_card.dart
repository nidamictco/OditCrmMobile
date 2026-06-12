
import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/lead_management.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/widgets/lead_list.dart';
import 'package:sizer/sizer.dart';

// ---------------------------------------------------------------------------
// Save as: lib/core/utils/lead_card.dart  (replaces your existing file)
// ---------------------------------------------------------------------------

// ── Action panel width (revealed area) ──────────────────────────────────────
double get _kActionPanelWidth => 55.w;

// ── Swipe snap threshold (fraction of panel width) ──────────────────────────
const double _kSnapThreshold = 0.35;

// ── Action panel items ───────────────────────────────────────────────────────
class _SwipeAction {
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _SwipeAction({
    required this.color,
    required this.icon,
    required this.onTap,
  });
}

// ===========================================================================
// SWIPEABLE LEAD CARD  (public API — drop-in replacement)
// ===========================================================================
class LeadCard extends StatefulWidget {
  final LeadData data;
  final VoidCallback onToggleExpand;
  final VoidCallback onCall;
  final VoidCallback onMessage;

  /// Notify parent when this card opens so siblings can close.
  final VoidCallback? onSwipeOpen;

  /// Parent calls this notifier to force-close this card.
  final ValueNotifier<bool>? closeNotifier;

  const LeadCard({
    super.key,
    required this.data,
    required this.onToggleExpand,
    required this.onCall,
    required this.onMessage,
    this.onSwipeOpen,
    this.closeNotifier,
  });

  @override
  State<LeadCard> createState() => _LeadCardState();
}

class _LeadCardState extends State<LeadCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnim;

  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slideAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    widget.closeNotifier?.addListener(_onCloseRequested);
  }

  @override
  void didUpdateWidget(LeadCard old) {
    super.didUpdateWidget(old);
    if (old.closeNotifier != widget.closeNotifier) {
      old.closeNotifier?.removeListener(_onCloseRequested);
      widget.closeNotifier?.addListener(_onCloseRequested);
    }
  }

  void _onCloseRequested() {
    if (widget.closeNotifier?.value == true && _isOpen) {
      _close();
    }
  }

  void _open() {
    setState(() => _isOpen = true);
    _controller.animateTo(1.0);
    widget.onSwipeOpen?.call();
  }

  void _close() {
    _controller.animateTo(0.0).then((_) {
      if (mounted) setState(() => _isOpen = false);
    });
  }

  void _toggle() => _isOpen ? _close() : _open();

  void _onHorizontalDragUpdate(DragUpdateDetails d) {
    // Only respond to leftward drag
    if (d.primaryDelta == null) return;
    final delta = -d.primaryDelta! / _kActionPanelWidth;
    _controller.value = (_controller.value + delta).clamp(0.0, 1.0);
  }

  void _onHorizontalDragEnd(DragEndDetails d) {
    final velocity = d.primaryVelocity ?? 0;
    if (velocity < -300) {
      _open();
    } else if (velocity > 300) {
      _close();
    } else if (_controller.value >= _kSnapThreshold) {
      _open();
    } else {
      _close();
    }
  }

  @override
  void dispose() {
    widget.closeNotifier?.removeListener(_onCloseRequested);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      _SwipeAction(
        color: const Color(0xFF2196F3),
        icon: Icons.person_add_alt_1_rounded,
        onTap: () {},
      ),
      _SwipeAction(
        color: const Color(0xFF4CAF50),
        icon: Icons.call_rounded,
        onTap: widget.onCall,
      ),
      _SwipeAction(
        color: const Color(0xFF25D366),
        icon: Icons.chat_rounded,
        onTap: widget.onMessage,
      ),
      _SwipeAction(
        color: const Color(0xFF607D8B),
        icon: Icons.refresh_rounded,
        onTap: () {},
      ),
    ];

    return GestureDetector(
      // Close on tap-outside when open
      onTap: _isOpen ? _close : null,
      behavior: HitTestBehavior.translucent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.w),
        child: SizedBox(
          // Let card define its own height intrinsically
          child: AnimatedBuilder(
            animation: _slideAnim,
            builder: (context, _) {
              final slideOffset = _slideAnim.value * _kActionPanelWidth;

              return Stack(
                children: [
                  // ── Action panel (behind the card) ──────────────────────
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: _kActionPanelWidth,
                        child: _ActionPanel(actions: actions),
                      ),
                    ),
                  ),

                  // ── The actual card (slides left) ───────────────────────
                  Transform.translate(
                    offset: Offset(-slideOffset, 0),
                    child: GestureDetector(
                      onHorizontalDragUpdate: _onHorizontalDragUpdate,
                      onHorizontalDragEnd: _onHorizontalDragEnd,
                      // Prevent tap-close from firing on card body
                      onTap: () {},
                      child: _LeadCardBody(
                        data: widget.data,
                        onToggleExpand: widget.onToggleExpand,
                        onCall: widget.onCall,
                        onMessage: widget.onMessage,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// ACTION PANEL
// ===========================================================================
class _ActionPanel extends StatelessWidget {
  final List<_SwipeAction> actions;

  const _ActionPanel({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: actions
          .map(
            (a) => Expanded(
              child: GestureDetector(
                onTap: a.onTap,
                child: Container(
                  color: a.color,
                  child: Center(
                    child: Icon(
                      a.icon,
                      color: Colors.white,
                      size: 6.w,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ===========================================================================
// LEAD CARD BODY  (your original LeadCard UI — untouched)
// ===========================================================================
class _LeadCardBody extends StatelessWidget {
  final LeadData data;
  final VoidCallback onToggleExpand;
  final VoidCallback onCall;
  final VoidCallback onMessage;

  const _LeadCardBody({
    required this.data,
    required this.onToggleExpand,
    required this.onCall,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.w),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left colour strip ──────────────────────────────────────
              Container(
                width: 1.w,
                decoration: BoxDecoration(
                  color: data.statusDotColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4.w),
                    bottomLeft: Radius.circular(4.w),
                  ),
                ),
              ),

              // ── Content ────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row
                      Row(
                        children: [
                          Container(
                            width: 2.2.w,
                            height: 1.1.h,
                            decoration: BoxDecoration(
                              color: data.statusDotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 1.8.w),
                          Expanded(
                            child: Text(
                              data.name,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 1.5.w),
                          _CategoryChip(label: data.category),
                          if (data.notificationCount > 0) ...[
                            SizedBox(width: 1.5.w),
                            _CountBadge(count: data.notificationCount),
                          ],
                          SizedBox(width: 1.5.w),
                          GestureDetector(
                            onTap: onToggleExpand,
                            child: Icon(
                              data.isExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 7.w,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),

                      // Expanded content
                      if (data.isExpanded) ...[
                        SizedBox(height: 1.2.h),
                        _InfoRow(icon: Icons.phone_outlined, text: data.phone),
                        SizedBox(height: 0.8.h),
                        _InfoRow(
                          icon: Icons.person_outline_rounded,
                          text: data.assignedTo,
                        ),
                      ],
                      SizedBox(height: 1.2.h),

                      // Bottom row
                      Row(
                        children: [
                          _StatusChip(
                            label: data.status,
                            color: data.statusDotColor,
                          ),
                          const Spacer(),
                          _CircleActionButton(
                            icon: Icons.call_rounded,
                            bgColor: const Color(0xFFDCFCE7),
                            iconColor: const Color(0xFF16A34A),
                            onTap: onCall,
                          ),
                          SizedBox(width: 2.w),
                          _CircleActionButton(
                            icon: Icons.chat_bubble_outline_rounded,
                            bgColor: const Color(0xFFDCFCE7),
                            iconColor: const Color(0xFF16A34A),
                            onTap: onMessage,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// SUB-WIDGETS  (identical to your original)
// ===========================================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 5.w, color: const Color(0xFF9CA3AF)),
        SizedBox(width: 1.5.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 15.5.sp,
            color: const Color(0xFF374151),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(1.5.w),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFDC2626),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5.w,
      height: 2.8.h,
      decoration: const BoxDecoration(
        color: Color(0xFFF59E0B),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        count.toString(),
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.5.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _CircleActionButton({
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 9.w,
        height: 4.5.h,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, size: 4.3.w, color: iconColor),
      ),
    );
  }
}