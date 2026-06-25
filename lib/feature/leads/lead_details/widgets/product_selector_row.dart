import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:sizer/sizer.dart';

class ProductSelectorRow extends StatelessWidget {
  final String? selectedProduct;
  final List<String> products;
  final ValueChanged<String?> onChanged;
  final VoidCallback onAddPressed;
  final bool showAddButton;

  const ProductSelectorRow({
    super.key,
    this.selectedProduct,
    required this.products,
    required this.onChanged,
    required this.onAddPressed,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 7.5.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  color: const Color(0xFF555555),
                  size: 5.5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedProduct,
                      hint: Text(
                        'Select Products',
                        style: TextStyle(
                          color: const Color(0xFF888888),
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: const Color(0xFF888888),
                        size: 7.w,
                      ),
                      isExpanded: true,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        color: const Color(0xFF333333),
                        fontWeight: FontWeight.w400,
                      ),
                      items: products.map((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: onChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showAddButton) ...[
          SizedBox(width: 3.w),
          GestureDetector(
            onTap: onAddPressed,
            child: Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: AppColors.bottomNavBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
