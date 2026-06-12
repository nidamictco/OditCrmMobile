import 'package:flutter/material.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:sizer/sizer.dart';

// ---------------------------------------------------------------------------
// App Colors – replace with your existing ScreenColors class
// ---------------------------------------------------------------------------
class ScreenColors {
  // static const Color gradientBlueStart = Color(0xFF1E88E5);
  static const Color gradientBlueEnd = Color(0xFF1565C0);
  static const Color addGreen = Color(0xFF4CAF50);
  static const Color fieldFill = Color(0xFFF5F5F5);
  static const Color hintGrey = Color(0xFF9E9E9E);
  static const Color iconGrey = Color(0xFF757575);
  static const Color borderGrey = Color(0xFFE0E0E0);
  static const Color cardShadow = Color(0x14000000);
  static const Color sectionIconBlue = Color(0xFF1E88E5);
  static const Color textPrimary = Color(0xFF212121);
  static const Color requiredRed = Color(0xFFE53935);
}

// ---------------------------------------------------------------------------
// CREATE LEAD SCREEN
// ---------------------------------------------------------------------------
class CreateLeadScreen extends StatefulWidget {
  const CreateLeadScreen({super.key});

  @override
  State<CreateLeadScreen> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends State<CreateLeadScreen> {
  // Customer Details controllers
  final _clientNameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  // Lead Information
  final _remarksCtrl = TextEditingController();

  // Product Info
  final _costCtrl = TextEditingController();

  // Dropdown values
  String? _selectedState;
  String? _selectedStaff = 'OXDO TECHNOLOGIES PVT';
  String? _selectedCategory;
  String? _selectedSource = 'Direct Entry';
  String? _selectedPriority = 'Normal';
  String? _selectedStage = 'New';

  static const List<String> _states = [
    'Kerala',
    'Tamil Nadu',
    'Karnataka',
    'Maharashtra',
    'Delhi',
  ];
  static const List<String> _staffList = ['OXDO TECHNOLOGIES PVT'];
  static const List<String> _priorities = ['Low', 'Normal', 'High'];
  static const List<String> _stages = ['New', 'In Progress', 'Closed'];

  @override
  void dispose() {
    _clientNameCtrl.dispose();
    _contactCtrl.dispose();
    _whatsappCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _pinCtrl.dispose();
    _remarksCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            children: [
              _CustomerDetailsCard(
                clientNameCtrl: _clientNameCtrl,
                contactCtrl: _contactCtrl,
                whatsappCtrl: _whatsappCtrl,
                emailCtrl: _emailCtrl,
                addressCtrl: _addressCtrl,
                pinCtrl: _pinCtrl,
                selectedState: _selectedState,
                states: _states,
                onStateChanged: (v) => setState(() => _selectedState = v),
                onContactPickerTap: () {},
              ),
              SizedBox(height: 2.h),
              _LeadInformationCard(
                selectedStaff: _selectedStaff,
                staffList: _staffList,
                onStaffChanged: (v) => setState(() => _selectedStaff = v),
                selectedCategory: _selectedCategory,
                onCategoryChanged: (v) => setState(() => _selectedCategory = v),
                onAddCategory: () {},
                selectedSource: _selectedSource,
                onSourceChanged: (v) => setState(() => _selectedSource = v),
                onAddSource: () {},
                selectedPriority: _selectedPriority,
                priorities: _priorities,
                onPriorityChanged: (v) => setState(() => _selectedPriority = v),
                selectedStage: _selectedStage,
                stages: _stages,
                onStageChanged: (v) => setState(() => _selectedStage = v),
                remarksCtrl: _remarksCtrl,
              ),

              SizedBox(height: 2.h),
              PrimaryButton(label: 'Create Lead', onTap: () {}),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(7.h),
      child: AppBar(
        backgroundColor: AppColors.bottomNavBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Create Lead',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        titleSpacing: 0,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION CARD  (reusable)
// ---------------------------------------------------------------------------
class CustomSectionCard extends StatelessWidget {
  final Widget header;
  final List<Widget> children;

  const CustomSectionCard({
    super.key,
    required this.header,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: ScreenColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          SizedBox(height: 1.5.h),
          ...children,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION TITLE  (reusable)
// ---------------------------------------------------------------------------
class SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const SectionTitle({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.bottomNavBlue, size: 17.sp),
        SizedBox(width: 2.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: ScreenColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// CUSTOM TEXT FIELD  (reusable)
// ---------------------------------------------------------------------------
// class CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hint;
//   final IconData? prefixIcon;
//   final bool filled;
//   final bool isRequired;
//   final int maxLines;
//   final TextInputType keyboardType;
//   final bool outlined;

//   const CustomTextField({
//     super.key,
//     required this.controller,
//     required this.hint,
//     this.prefixIcon,
//     this.filled = true,
//     this.isRequired = false,
//     this.maxLines = 1,
//     this.keyboardType = TextInputType.text,
//     this.outlined = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final border = OutlineInputBorder(
//       borderRadius: BorderRadius.circular(10),
//       borderSide: BorderSide(
//         color: outlined ? ScreenColors.borderGrey : Colors.transparent,
//         width: outlined ? 1 : 0,
//       ),
//     );

//     return TextField(
//       controller: controller,
//       maxLines: maxLines,
//       keyboardType: keyboardType,
//       style: TextStyle(fontSize: 14.sp, color: ScreenColors.textPrimary),
//       decoration: InputDecoration(
//         hintText: isRequired ? null : hint,
//         label: isRequired
//             ? RichText(
//                 text: TextSpan(
//                   text: hint.replaceAll(' *', ''),
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     color: ScreenColors.hintGrey,
//                   ),
//                   children: const [
//                     TextSpan(
//                       text: ' *',
//                       style: TextStyle(color: ScreenColors.requiredRed),
//                     ),
//                   ],
//                 ),
//               )
//             : null,
//         hintStyle: TextStyle(fontSize: 14.sp, color: ScreenColors.hintGrey),
//         prefixIcon: prefixIcon != null
//             ? Icon(prefixIcon, color: ScreenColors.iconGrey, size: 13.sp)
//             : null,
//         filled: filled,
//         fillColor: filled && !outlined
//             ? ScreenColors.fieldFill
//             : Colors.transparent,
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: 3.w,
//           vertical: maxLines > 1 ? 1.5.h : 0,
//         ),
//         border: border,
//         enabledBorder: border,
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(
//             color: ScreenColors.bottomNvgtnBlue,
//             width: 1.5,
//           ),
//         ),
//         isDense: true,
//       ),
//     );
//   }
// }

// ---------------------------------------------------------------------------
// CUSTOM DROPDOWN FIELD  (reusable)
// ---------------------------------------------------------------------------
class CustomDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String hint;
  final String? floatingLabel;
  final void Function(T?) onChanged;
  final bool filled;
  final Widget? suffixWidget;

  const CustomDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
    this.floatingLabel,
    this.filled = true,
    this.suffixWidget,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: filled ? Colors.transparent : ScreenColors.borderGrey,
      ),
    );

    return InputDecorator(
      decoration: InputDecoration(
        labelText: value != null ? floatingLabel : null,
        labelStyle: TextStyle(fontSize: 14.sp, color: ScreenColors.hintGrey),
        filled: filled,
        fillColor: filled ? ScreenColors.fieldFill : Colors.transparent,
        contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.bottomNavBlue,
            width: 0.1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.bottomNavBlue,
            width: 0.1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.bottomNavBlue,
            width: 1.5,
          ),
        ),

        isDense: true,
        suffixIcon: suffixWidget != null
            ? Padding(
                padding: EdgeInsets.only(right: 2.w),
                child: suffixWidget,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(
                Icons.arrow_drop_down_circle_outlined,
                color: ScreenColors.iconGrey,
                size: 16.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                hint,
                style: TextStyle(fontSize: 14.sp, color: ScreenColors.hintGrey),
              ),
            ],
          ),
          icon: const SizedBox.shrink(),
          style: TextStyle(fontSize: 14.sp, color: ScreenColors.textPrimary),
          items: items
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e,
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_drop_down_circle_outlined,
                        color: ScreenColors.iconGrey,
                        size: 16.sp,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        e.toString(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: ScreenColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GRADIENT SQUARE BUTTON  (reusable)
// ---------------------------------------------------------------------------
class GradientSquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const GradientSquareButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 7,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.bottomNavBlue,
          boxShadow: [
            BoxShadow(
              color: ScreenColors.gradientBlueEnd.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 14.sp),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GREEN CIRCULAR ADD BUTTON  (reusable)
// ---------------------------------------------------------------------------
class GreenAddButton extends StatelessWidget {
  final VoidCallback onTap;

  const GreenAddButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 8.w,
        height: 8.w,
        decoration: const BoxDecoration(
          // color: Colors.teal,
          color: AppColors.bottomNavBlue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x3349C361),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(Icons.add, color: Colors.white, size: 16.sp),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PRIMARY BUTTON  (reusable)
// ---------------------------------------------------------------------------
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const PrimaryButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bottomNavBlue,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CUSTOMER DETAILS CARD
// ---------------------------------------------------------------------------
class _CustomerDetailsCard extends StatelessWidget {
  final TextEditingController clientNameCtrl;
  final TextEditingController contactCtrl;
  final TextEditingController whatsappCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController pinCtrl;
  final String? selectedState;
  final List<String> states;
  final void Function(String?) onStateChanged;
  final VoidCallback onContactPickerTap;

  const _CustomerDetailsCard({
    required this.clientNameCtrl,
    required this.contactCtrl,
    required this.whatsappCtrl,
    required this.emailCtrl,
    required this.addressCtrl,
    required this.pinCtrl,
    required this.selectedState,
    required this.states,
    required this.onStateChanged,
    required this.onContactPickerTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSectionCard(
      header: const SectionTitle(
        icon: Icons.person_outline,
        title: 'Customer Details',
      ),
      children: [
        // Client Name + Contact Picker
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: 6.h,
                child: CustomTextField(
                  controller: clientNameCtrl,
                  hint: 'Client Name',
                  isRequired: true,
                  filled: false,
                  outlined: true,
                  suffixIcon: Icons.person_outline,
                ),
              ),
            ),
            SizedBox(width: 2.w),
            GradientSquareButton(
              icon: Icons.contacts_outlined,
              onTap: onContactPickerTap,
              size: 11,
            ),
          ],
        ),
        SizedBox(height: 1.2.h),

        // Contact Number (outlined)
        SizedBox(
          height: 6.h,
          child: CustomTextField(
            controller: contactCtrl,
            hint: 'Contact Number',
            isRequired: true,
            filled: false,
            outlined: true,
            suffixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
        ),
        SizedBox(height: 1.2.h),

        // WhatsApp Number (outlined)
        SizedBox(
          height: 6.h,
          child: CustomTextField(
            controller: whatsappCtrl,
            hint: 'Whatsapp Number',
            filled: false,
            outlined: true,
            keyboardType: TextInputType.phone,
            suffixIcon: Icons.phone_outlined,
          ),
        ),
        SizedBox(height: 1.2.h),

        // Email (filled)
        SizedBox(
          height: 6.h,
          child: CustomTextField(
            controller: emailCtrl,
            hint: 'Email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            suffixIcon: Icons.email_outlined,
          ),
        ),
        SizedBox(height: 1.2.h),

        // Address (filled, multiline)
        CustomTextField(
          controller: addressCtrl,
          hint: 'Address',
          prefixIcon: Icons.location_on_outlined,
          maxLines: 3,
          suffixIcon: Icons.location_on_outlined,
        ),
        SizedBox(height: 1.2.h),

        // PIN Code (filled)
        SizedBox(
          height: 6.h,
          child: CustomTextField(
            controller: pinCtrl,
            hint: 'PIN Code',
            prefixIcon: Icons.pin_drop_outlined,
            keyboardType: TextInputType.number,
            suffixIcon: Icons.location_on_outlined,
          ),
        ),
        SizedBox(height: 1.2.h),

        // State dropdown (filled)
        SizedBox(
          height: 6.h,
          child: CustomDropdownField<String>(
            value: selectedState,
            items: const [
              'Kerala',
              'Tamil Nadu',
              'Karnataka',
              'Maharashtra',
              'Delhi',
            ],
            hint: 'State',
            onChanged: onStateChanged,
            floatingLabel: 'State',
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// LEAD INFORMATION CARD
// ---------------------------------------------------------------------------
class _LeadInformationCard extends StatelessWidget {
  final String? selectedStaff;
  final List<String> staffList;
  final void Function(String?) onStaffChanged;
  final String? selectedCategory;
  final void Function(String?) onCategoryChanged;
  final VoidCallback onAddCategory;
  final String? selectedSource;
  final void Function(String?) onSourceChanged;
  final VoidCallback onAddSource;
  final String? selectedPriority;
  final List<String> priorities;
  final void Function(String?) onPriorityChanged;
  final String? selectedStage;
  final List<String> stages;
  final void Function(String?) onStageChanged;
  final TextEditingController remarksCtrl;

  const _LeadInformationCard({
    required this.selectedStaff,
    required this.staffList,
    required this.onStaffChanged,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onAddCategory,
    required this.selectedSource,
    required this.onSourceChanged,
    required this.onAddSource,
    required this.selectedPriority,
    required this.priorities,
    required this.onPriorityChanged,
    required this.selectedStage,
    required this.stages,
    required this.onStageChanged,
    required this.remarksCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSectionCard(
      header: const SectionTitle(
        icon: Icons.info_outline,
        title: 'Lead Information',
      ),
      children: [
        // Assign Staff
        SizedBox(
          height: 6.h,
          child: CustomDropdownField<String>(
            value: selectedStaff,
            items: staffList,
            hint: 'Assign Staff',
            floatingLabel: 'Assign Staff',
            onChanged: onStaffChanged,
          ),
        ),
        SizedBox(height: 1.2.h),

        // Lead Category + Add
        _DropdownWithAdd(
          value: selectedCategory,
          items: const [],
          hint: 'Lead Category',
          floatingLabel: 'Lead Category',
          onChanged: onCategoryChanged,
          onAdd: onAddCategory,
        ),
        SizedBox(height: 1.2.h),

        // Lead Source + Add
        _DropdownWithAdd(
          value: selectedSource,
          items: const ['Direct Entry', 'Referral', 'Online'],
          hint: 'Lead Source',
          floatingLabel: 'Lead Source',
          onChanged: onSourceChanged,
          onAdd: onAddSource,
        ),
        SizedBox(height: 1.2.h),

        // Priority
        SizedBox(
          height: 6.h,
          child: CustomDropdownField<String>(
            value: selectedPriority,
            items: priorities,
            hint: 'Priority',
            floatingLabel: 'Priority',
            onChanged: onPriorityChanged,
          ),
        ),
        SizedBox(height: 1.2.h),

        // Stages
        SizedBox(
          height: 6.h,
          child: CustomDropdownField<String>(
            value: selectedStage,
            items: stages,
            hint: 'Stages',
            floatingLabel: 'Stages',
            onChanged: onStageChanged,
          ),
        ),
        SizedBox(height: 1.2.h),

        // Remarks
        CustomTextField(
          controller: remarksCtrl,
          hint: 'Remarks',
          prefixIcon: Icons.list_alt_outlined,
          maxLines: 3,
          filled: true,
          suffixIcon: Icons.edit_document,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// DROPDOWN WITH ADD BUTTON  (private helper)
// ---------------------------------------------------------------------------
class _DropdownWithAdd extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String hint;
  final String? floatingLabel;
  final void Function(String?) onChanged;
  final VoidCallback onAdd;

  const _DropdownWithAdd({
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
    required this.onAdd,
    this.floatingLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6.h,
      child: Row(
        children: [
          Expanded(
            child: CustomDropdownField<String>(
              value: value,
              items: items,
              hint: hint,
              floatingLabel: floatingLabel,
              onChanged: onChanged,
            ),
          ),
          SizedBox(width: 2.w),
          GreenAddButton(onTap: onAdd),
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final bool filled;
  final bool isRequired;
  final int maxLines;
  final TextInputType keyboardType;
  final bool outlined;
  final Color? fillColor;
  final IconData? suffixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.filled = true,
    this.isRequired = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.outlined = false,
    this.fillColor,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final bool showOutlineBorder = outlined && !filled;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(fontSize: 14.sp, color: ScreenColors.textPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: ScreenColors.fieldFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.bottomNavBlue,
            width: 0.1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.bottomNavBlue,
            width: 0.1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.bottomNavBlue,
            width: 1.5,
          ),
        ),
        label: RichText(
          text: TextSpan(
            text: hint,
            style: TextStyle(fontSize: 15.sp, color: ScreenColors.hintGrey),

            children: [
              if (isRequired == true)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: ScreenColors.requiredRed),
                ),
            ],
          ),
        ),
        prefixIcon: Icon(suffixIcon, color: ScreenColors.iconGrey, size: 17.sp),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0),
      ),
    );
  }
}
