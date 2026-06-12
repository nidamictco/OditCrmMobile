import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:sizer/sizer.dart';

// ---------------------------------------------------------------------------
// Save as: lib/widgets/filter_bottom_sheet.dart
// ---------------------------------------------------------------------------

// ── Constants ───────────────────────────────────────────────────────────────
// const _kBlue = Color(0xFF2F80ED);
const _kBlue = AppColors.bottomNavBlue;
const _kLightGrey = Color(0xFFF0F0F4);
const _kRightBg = Color(0xFFF8F8FC);
const _kTextDark = Color(0xFF222222);
const _kTextGrey = Color(0xFF888888);

// ── Filter Category Model ────────────────────────────────────────────────────
class FilterCategory {
  final String label;
  final IconData icon;
  const FilterCategory({required this.label, required this.icon});
}

const List<FilterCategory> kFilterCategories = [
  FilterCategory(label: 'Leads Date', icon: Icons.calendar_today_outlined),
  FilterCategory(label: 'Assigned Staff', icon: Icons.group_outlined),
  FilterCategory(label: 'Category', icon: Icons.category_outlined),
  FilterCategory(label: 'Priority', icon: Icons.sort_outlined),
  FilterCategory(label: 'Products', icon: Icons.shopping_bag_outlined),
];

// ── Default checkbox items per category ──────────────────────────────────────
const Map<String, List<String>> kCheckboxItems = {
  'Assigned Staff': ['John', 'Alex', 'Staff 1', 'Staff 2', 'Staff 3'],
  'Category': [
    'Need Further Followup',
    'Not Contacted',
    'Fake',
    'Visited',
    'May Visit',
    'Converted',
  ],
  'Priority': ['High', 'Medium', 'Normal', 'Low'],
  'Products': ['Product A', 'Product B', 'Product C', 'Product D', 'Product E'],
};

// ── Show helper ──────────────────────────────────────────────────────────────
void showFilterBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (_) => const FilterBottomSheet(),
  );
}

// ===========================================================================
// MAIN BOTTOM SHEET
// ===========================================================================
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  int _selectedIndex = 0;

  // Date state
  String _fromDate = '09-06-2026';
  String _toDate = '09-06-2026';

  // Checkbox state: category label → set of selected items
  final Map<String, Set<String>> _selectedItems = {
    'Assigned Staff': {},
    'Category': {},
    'Priority': {},
    'Products': {},
  };

  // Search query per category
  final Map<String, String> _searchQuery = {
    'Assigned Staff': '',
    'Category': '',
    'Priority': '',
    'Products': '',
  };

  void _clearAll() {
    setState(() {
      _fromDate = '09-06-2026';
      _toDate = '09-06-2026';
      for (final key in _selectedItems.keys) {
        _selectedItems[key]!.clear();
      }
      for (final key in _searchQuery.keys) {
        _searchQuery[key] = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65.h,
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _FilterHeader(onClose: () => Navigator.of(context).pop()),

          // ── Body ────────────────────────────────────────────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left menu
                SizedBox(
                  width: 34.w,
                  child: _LeftMenu(
                    selectedIndex: _selectedIndex,
                    onSelect: (i) => setState(() => _selectedIndex = i),
                  ),
                ),
                // Right content
                Expanded(
                  child: Container(
                    color: _kRightBg,
                    padding: EdgeInsets.all(4.w),
                    child: _buildRightContent(),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Buttons ───────────────────────────────────────────────
          BottomActionButtons(
            onClear: _clearAll,
            onApply: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildRightContent() {
    final category = kFilterCategories[_selectedIndex];
    switch (category.label) {
      case 'Leads Date':
        return DateSelectionView(
          fromDate: _fromDate,
          toDate: _toDate,
          onFromDateTap: () async {
            final picked = await _pickDate(context, _fromDate);
            if (picked != null) setState(() => _fromDate = picked);
          },
          onToDateTap: () async {
            final picked = await _pickDate(context, _toDate);
            if (picked != null) setState(() => _toDate = picked);
          },
          onClear: () => setState(() {
            _fromDate = '09-06-2026';
            _toDate = '09-06-2026';
          }),
          onToday: () {
            final now = DateTime.now();
            final fmt = _formatDate(now);
            setState(() {
              _fromDate = fmt;
              _toDate = fmt;
            });
          },
          onThisMonth: () {
            final now = DateTime.now();
            final first = DateTime(now.year, now.month, 1);
            setState(() {
              _fromDate = _formatDate(first);
              _toDate = _formatDate(now);
            });
          },
        );
      default:
        final label = category.label;
        final items = kCheckboxItems[label] ?? [];
        final selected = _selectedItems[label] ?? {};
        final query = _searchQuery[label] ?? '';
        final filtered = items
            .where((e) => e.toLowerCase().contains(query.toLowerCase()))
            .toList();

        return Column(
          children: [
            SearchFilterField(
              onChanged: (v) => setState(() => _searchQuery[label] = v),
            ),
            SizedBox(height: 1.5.h),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final item = filtered[i];
                  return CheckboxListTileWidget(
                    label: item,
                    isChecked: selected.contains(item),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          selected.add(item);
                        } else {
                          selected.remove(item);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        );
    }
  }

  Future<String?> _pickDate(BuildContext context, String current) async {
    final parts = current.split('-');
    final initial = parts.length == 3
        ? DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          )
        : DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    return picked != null ? _formatDate(picked) : null;
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.year}';
}

// ===========================================================================
// FILTER HEADER
// ===========================================================================
class _FilterHeader extends StatelessWidget {
  final VoidCallback onClose;
  const _FilterHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filters',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: _kTextDark,
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, size: 28, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// LEFT MENU
// ===========================================================================
class _LeftMenu extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _LeftMenu({required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: _kLightGrey,
        child: Column(
          children: List.generate(
            kFilterCategories.length,
            (i) => FilterMenuItem(
              category: kFilterCategories[i],
              isSelected: selectedIndex == i,
              onTap: () => onSelect(i),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// FILTER MENU ITEM
// ===========================================================================
class FilterMenuItem extends StatelessWidget {
  final FilterCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterMenuItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : _kLightGrey,
          border: Border(
            left: BorderSide(
              color: isSelected ? _kBlue : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 2.2.h, horizontal: 2.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 18.sp,
              color: isSelected ? _kBlue : _kTextGrey,
            ),
            SizedBox(height: 0.6.h),
            Text(
              category.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? _kBlue : _kTextGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// DATE SELECTION VIEW
// ===========================================================================
class DateSelectionView extends StatelessWidget {
  final String fromDate;
  final String toDate;
  final VoidCallback onFromDateTap;
  final VoidCallback onToDateTap;
  final VoidCallback onClear;
  final VoidCallback onToday;
  final VoidCallback onThisMonth;

  const DateSelectionView({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.onFromDateTap,
    required this.onToDateTap,
    required this.onClear,
    required this.onToday,
    required this.onThisMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Date Range',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: _kTextDark,
              ),
            ),
            GestureDetector(
              onTap: onClear,
              child: Text(
                'Clear',
                style: TextStyle(
                  fontSize: 14.5.sp,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),

        // From Date
        FilterDateCard(
          label: 'From Date',
          date: fromDate,
          onTap: onFromDateTap,
        ),
        SizedBox(height: 1.5.h),

        // To Date
        FilterDateCard(label: 'To Date', date: toDate, onTap: onToDateTap),
        SizedBox(height: 2.h),

        // Quick-select buttons
        Row(
          children: [
            Expanded(
              child: FilterOutlinedButton(label: 'Today', onTap: onToday),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: FilterOutlinedButton(
                label: 'This Month',
                onTap: onThisMonth,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ===========================================================================
// FILTER DATE CARD
// ===========================================================================
class FilterDateCard extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;

  const FilterDateCard({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.4.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 13.5.sp, color: _kTextGrey),
                  ),
                  SizedBox(height: 0.4.h),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                      color: _kTextDark,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.calendar_today_outlined, color: _kBlue, size: 18.sp),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// FILTER OUTLINED BUTTON
// ===========================================================================
class FilterOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const FilterOutlinedButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 5.5.h,
        decoration: BoxDecoration(
          color: _kBlue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBlue, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: _kBlue,
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// SEARCH FILTER FIELD
// ===========================================================================
class SearchFilterField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchFilterField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(fontSize: 13.5.sp, color: _kTextDark),
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(fontSize: 13.35.sp, color: _kTextGrey),
          prefixIcon: Icon(Icons.search, color: _kTextGrey, size: 18.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 1.5.h),
        ),
      ),
    );
  }
}

// ===========================================================================
// CHECKBOX LIST TILE WIDGET
// ===========================================================================
class CheckboxListTileWidget extends StatelessWidget {
  final String label;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  const CheckboxListTileWidget({
    super.key,
    required this.label,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isChecked),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 5.w,
              height: 5.w,
              child: Checkbox(
                value: isChecked,
                onChanged: onChanged,
                activeColor: _kBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(color: Color(0xFFAAAAAA), width: 1.5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  color: _kTextDark,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// BOTTOM ACTION BUTTONS
// ===========================================================================
class BottomActionButtons extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onApply;

  const BottomActionButtons({
    super.key,
    required this.onClear,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          // Clear All
          Expanded(
            child: SizedBox(
              height: 6.5.h,
              child: OutlinedButton(
                onPressed: onClear,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCCCCCC)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _kTextDark,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          // Apply Filters
          Expanded(
            child: SizedBox(
              height: 6.5.h,
              child: ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
