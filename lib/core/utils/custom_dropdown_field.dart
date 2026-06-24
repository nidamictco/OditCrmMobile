import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CustomDropdownField extends StatefulWidget {
  final String label;
  final String? value;
  final String hintText;
  final List<String> items;
  final IconData? prefixIcon;
  final bool isRequired;
  final ValueChanged<String?> onChanged;

  const CustomDropdownField({
    super.key,
    required this.label,
    this.value,
    required this.hintText,
    required this.items,
    this.prefixIcon,
    this.isRequired = false,
    required this.onChanged,
  });

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(covariant CustomDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _overlayEntry?.markNeedsBuild();
      });
    }
  }

  @override
  void dispose() {
    _closeDropdown(immediate: true);
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
    _animationController.forward();
  }

  void _closeDropdown({bool immediate = false}) {
    if (!_isOpen) return;

    if (immediate) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOpen = false;
    } else {
      _animationController.reverse().then((_) {
        if (mounted) {
          _overlayEntry?.remove();
          _overlayEntry = null;
          setState(() {
            _isOpen = false;
          });
        }
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size.zero;

    return OverlayEntry(
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
        final spaceBelow = screenHeight - offset.dy - size.height;
        final dropdownHeight = 30.h;
        final showAbove = spaceBelow < dropdownHeight && offset.dy > spaceBelow;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _closeDropdown(),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: showAbove ? Alignment.topLeft : Alignment.bottomLeft,
              followerAnchor: showAbove ? Alignment.bottomLeft : Alignment.topLeft,
              offset: showAbove ? const Offset(0, -4) : const Offset(0, 4),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: size.width,
                  constraints: BoxConstraints(
                    maxHeight: dropdownHeight,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FadeTransition(
                    opacity: _expandAnimation,
                    child: SizeTransition(
                      sizeFactor: _expandAnimation,
                      axisAlignment: showAbove ? 1.0 : -1.0,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 0.5.h),
                        shrinkWrap: true,
                        itemCount: widget.items.length,
                        itemBuilder: (BuildContext context, int index) {
                          final item = widget.items[index];
                          final isSelected = item == widget.value;
                          return InkWell(
                            onTap: () {
                              widget.onChanged(item);
                              _closeDropdown();
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.5.h,
                              ),
                              color: isSelected
                                  ? const Color(0xFFE3F2FD) // Soft blue highlight for selected item
                                  : Colors.transparent,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 14.5.sp,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: isSelected
                                            ? const Color(0xFF1E88E5)
                                            : const Color(0xFF333333),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check,
                                      color: const Color(0xFF1E88E5),
                                      size: 5.w,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF333333),
              ),
            ),
            if (widget.isRequired) ...[
              SizedBox(width: 1.w),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 0.5.h),
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              height: 6.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isOpen ? const Color(0xFF1E88E5) : const Color(0xFFE0E0E0),
                  width: 1.5,
                ),
                boxShadow: _isOpen
                    ? [
                        BoxShadow(
                          color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Row(
                children: [
                  if (widget.prefixIcon != null) ...[
                    Icon(widget.prefixIcon, color: const Color(0xFF888888), size: 5.5.w),
                    SizedBox(width: 3.w),
                  ],
                  Expanded(
                    child: Text(
                      widget.value ?? widget.hintText,
                      style: TextStyle(
                        color: widget.value == null
                            ? const Color(0xFF888888)
                            : const Color(0xFF333333),
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: const Color(0xFF888888),
                    size: 7.w,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
