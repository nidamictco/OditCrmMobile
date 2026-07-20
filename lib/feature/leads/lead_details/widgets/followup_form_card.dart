import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/core/utils/custom_dropdown_field.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/screens/add_lead.dart';
import 'package:sizer/sizer.dart';

class FollowupFormCard extends StatelessWidget {
  final String calledDate;

  final String? selectedCallStatus;
  final ValueChanged<String?> onCallStatusChanged;

  final String selectedLeadStage;
  final ValueChanged<String?> onLeadStageChanged;
  final List<String> leadStagesList;

  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final List<String> categoryList;

  final String? selectedSubCategory;
  final ValueChanged<String?> onSubCategoryChanged;
  final List<String> subCategoryList;

  final String? selectedTag;

  final ValueChanged<String?> onTagChanged;
  final bool tagManditory;
  final List<String> leadTagOptions; 

  // More Details fields
  final TextEditingController remarksController;
  final TextEditingController whtsppController;
  final TextEditingController addressController;
  final TextEditingController emailController;
  final String? nextFollowupDate;
  final VoidCallback onPickNextFollowupDate;
  final String? selectedStaff;
  final List<String> staffList;
  final ValueChanged<String?> onStaffChanged;

  final String? selectedPriority;
  final List<String> priorityList;
  final ValueChanged<String?> onPriorityChanged;

  const FollowupFormCard({
    super.key,
    required this.calledDate,
    this.selectedCallStatus,
    required this.onCallStatusChanged,
    required this.selectedLeadStage,
    required this.onLeadStageChanged,
    required this.leadStagesList,
    required this.leadTagOptions,
    required this.tagManditory,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.categoryList,
    required this.selectedSubCategory,
    required this.onSubCategoryChanged,
    required this.subCategoryList,
    required this.remarksController,
    required this.whtsppController,
    required this.addressController,
    required this.emailController,
    this.nextFollowupDate,
    required this.onPickNextFollowupDate,
    this.selectedStaff,
    required this.staffList,
    required this.onStaffChanged,
    this.selectedPriority,
    required this.priorityList,
    required this.onPriorityChanged,
    this.selectedTag,
    required this.onTagChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4FA),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Called Date
          Text(
            'Called Date',
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF333333),
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            height: 6.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.access_time_outlined,
                  color: const Color(0xFF333333),
                  size: 5.5.w,
                ),
                SizedBox(width: 4.w),
                Text(
                  calledDate,
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 1.h),

          // Section 2: Call Status
          CustomDropdownField(
            label: 'Call Status',
            value: selectedCallStatus,
            hintText: 'Select Call Status',
            isRequired: true,
            items: const [
              'Connected',
              'Busy',
              'Rejected',
              'Switched Off',
              'Not Attended',
              'Out Of Coverage',
            ],
            onChanged: onCallStatusChanged,
          ),
          SizedBox(height: 1.h),

          // Section 3: Lead Stages
          CustomDropdownField(
            label: 'Lead Stages',
            value: selectedLeadStage == 'FOLLOWUP'
                ? 'FOLLOW UP'
                : selectedLeadStage,
            hintText: 'Select Lead Stage',
            isRequired: true,
            items: leadStagesList
                .map((e) => e == 'FOLLOWUP' ? 'FOLLOW UP' : e)
                .toList(),
            onChanged: onLeadStageChanged,
          ),
          SizedBox(height: 1.h),

          if (selectedLeadStage == 'FOLLOWUP')
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Next Follow Up Date',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    Text(
                      '*',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                GestureDetector(
                  onTap: onPickNextFollowupDate,
                  child: Container(
                    height: 6.5.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: const Color(0xFF888888),
                          size: 5.w,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          nextFollowupDate ?? '-',
                          style: TextStyle(
                            color: nextFollowupDate != null
                                ? const Color(0xFF333333)
                                : const Color(0xFF888888),
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
              ],
            ),

          if (leadTagOptions.isNotEmpty)
            Column(
              children: [
                CustomDropdownField(
                  label: 'Tag',
                  value: selectedTag,
                  hintText: 'Select Tag',
                  isRequired: tagManditory,
                  items: leadTagOptions,
                  onChanged: onTagChanged,
                ),
                SizedBox(height: 1.h),
              ],
            ),

          // Category Dropdown
          CustomDropdownField(
            label: 'Category',
            value: selectedCategory,
            hintText: 'Select Category',
            items: categoryList,
            onChanged: onCategoryChanged,
          ),
          if (subCategoryList.isNotEmpty)
          Column(
            children: [
              SizedBox(height: 1.h),
              CustomDropdownField(
                label: 'Sub Category',
                value: selectedSubCategory,
                hintText: 'Select Sub Category',
                items: subCategoryList,
                onChanged: onSubCategoryChanged,
              ),
            ],
          ),
          SizedBox(height: 2.5.h),

          // Expandable More Details Section
          ExpandableMoreDetailsSection(
            remarksController: remarksController,
            whatsappCntrlr: whtsppController,
            addressCntrlr: addressController,
            emailCntrlr: emailController,
            selectedStaff: selectedStaff,
            staffList: staffList,
            onStaffChanged: onStaffChanged,
            selectedPriority: selectedPriority,
            priorityList: priorityList,
            onPriorityChanged: onPriorityChanged,
          ),
        ],
      ),
    );
  }
}

class ExpandableMoreDetailsSection extends StatefulWidget {
  final TextEditingController remarksController;
  final TextEditingController emailCntrlr;
  final TextEditingController whatsappCntrlr;
  final TextEditingController addressCntrlr;
  final String? selectedStaff;
  final List<String> staffList;
  final ValueChanged<String?> onStaffChanged;
  final String? selectedPriority;
  final List<String> priorityList;
  final ValueChanged<String?> onPriorityChanged;

  const ExpandableMoreDetailsSection({
    super.key,
    required this.remarksController,
    required this.emailCntrlr,
    required this.whatsappCntrlr,
    required this.addressCntrlr,
    this.selectedStaff,
    required this.staffList,
    required this.onStaffChanged,
    this.selectedPriority,
    required this.priorityList,
    required this.onPriorityChanged,
  });

  @override
  State<ExpandableMoreDetailsSection> createState() =>
      _ExpandableMoreDetailsSectionState();
}

class _ExpandableMoreDetailsSectionState
    extends State<ExpandableMoreDetailsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Expand/Collapse Header Row
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                ' ${_isExpanded ? 'Less' : 'More'} Details',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.bottomNavBlue,
                ),
              ),
              SizedBox(width: 1.w),
              Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: AppColors.bottomNavBlue,
                size: 6.w,
              ),
            ],
          ),
        ),
        SizedBox(height: 1.5.h),

        // Animated Body
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Priority
              CustomDropdownField(
                label: 'Priority',
                value: widget.selectedPriority,
                hintText: 'Select Priority',
                items: widget.priorityList,
                onChanged: widget.onPriorityChanged,
              ),
              SizedBox(height: 1.5.h),
              Text(
                'Whatsapp Number',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF333333),
                ),
              ),
              SizedBox(height: 0.5.h),
              SizedBox(
                height: 6.h,
                child: CustomTextField(
                  controller: widget.whatsappCntrlr,
                  hint: 'Whatsapp Number',
                  filled: false,
                  outlined: true,
                  phone: true,
                  isLabel: false,
                  keyboardType: TextInputType.number,
                  suffixIcon: Icons.phone_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return null; // optional
                    if (value.trim().length != 10) {
                      return 'WhatsApp Number must be 10 digits';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 1.2.h),
              Text(
                'Email',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF333333),
                ),
              ),
              SizedBox(height: 0.5.h),
              SizedBox(
                height: 6.h,
                child: CustomTextField(
                  controller: widget.emailCntrlr,
                  hint: 'Email',
                  isLabel: false,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  suffixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return null; // optional
                    final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
                    );
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Address',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF333333),
                ),
              ),
              SizedBox(height: 0.5.h),
              TextField(
                controller: widget.addressCntrlr,
                maxLines: 3,
                style: TextStyle(
                  color: const Color(0xFF212121),
                  fontSize: 14.5.sp,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter Address',
                  hintStyle: TextStyle(
                    color: const Color(0xFF888888),
                    fontSize: 14.sp,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.home_outlined),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.5.h,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.bottomNavBlue,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Remarks',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF333333),
                ),
              ),
              SizedBox(height: 0.5.h),
              TextField(
                controller: widget.remarksController,
                maxLines: 3,
                style: TextStyle(
                  color: const Color(0xFF212121),
                  fontSize: 14.5.sp,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter Remarks',
                  hintStyle: TextStyle(
                    color: const Color(0xFF888888),
                    fontSize: 14.sp,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.5.h,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.bottomNavBlue,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}
