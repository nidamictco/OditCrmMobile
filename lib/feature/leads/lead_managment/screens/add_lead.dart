import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/core/utils/custom_dropdown_field.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_cubit.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_state.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/cubit/category_cubit.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/cubit/category_state.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/cubit/source_cubit.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/cubit/source_state.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/add_lead_model.dart';
import 'package:sizer/sizer.dart';

// ---------------------------------------------------------------------------
// App Colors
// ---------------------------------------------------------------------------
class ScreenColors {
  static const Color gradientBlueEnd = Color(0xFF1565C0);
  static const Color addGreen = Color(0xFF4CAF50);
  static const Color fieldFill = Color(0xFFF5F5F5);
  static const Color hintGrey = Color(0xFF888888);
  static const Color iconGrey = Color(0xFF757575);
  static const Color borderGrey = Color(0xFFE0E0E0);
  static const Color cardShadow = Color(0x14000000);
  static const Color sectionIconBlue = Color(0xFF1E88E5);
  static const Color textPrimary = Color(0xFF212121);
  static const Color requiredRed = Color(0xFFE53935);
}

// ---------------------------------------------------------------------------
// VALIDATORS  (pure functions — no UI dependency)
// ---------------------------------------------------------------------------
String? validateClientName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Client Name is required';
  }
  return null;
}

String? validatePhone(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Contact Number is required';
  }
  if (value.trim().length != 10) {
    return 'Contact Number must be 10 digits';
  }
  return null;
}

String? validateWhatsapp(String? value) {
  if (value == null || value.trim().isEmpty) return null; // optional
  if (value.trim().length != 10) {
    return 'WhatsApp Number must be 10 digits';
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return null; // optional
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );
  if (!emailRegex.hasMatch(value.trim())) {
    return 'Enter a valid email address';
  }
  return null;
}

String? validatePincode(String? value) {
  if (value == null || value.trim().isEmpty) return null; // optional
  if (value.trim().length != 6) {
    return 'PIN Code must be 6 digits';
  }
  return null;
}

// ---------------------------------------------------------------------------
// CREATE LEAD SCREEN
// ---------------------------------------------------------------------------
class CreateLeadScreen extends StatelessWidget {
  final String? from;
  final AddLeadModel? lead;
  const CreateLeadScreen({super.key, this.from = 'NEW', this.lead});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AddLeadCubit()..initialize()),
        BlocProvider(
          create: (context) => LeadCategoryCubit()..watchCategories(),
        ),
        BlocProvider(create: (context) => LeadSourceCubit()..watchSources()),
      ],
      child: CreateLeadScreenBody(from: from, lead: lead),
    );
  }
}

class CreateLeadScreenBody extends StatefulWidget {
  final String? from;
  final AddLeadModel? lead;
  const CreateLeadScreenBody({super.key, this.from = 'NEW', this.lead});

  @override
  State<CreateLeadScreenBody> createState() => _CreateLeadScreenBodyState();
}

class _CreateLeadScreenBodyState extends State<CreateLeadScreenBody> {
  // ── Form key ───────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // Customer Details controllers
  final _clientNameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _postOfficeCtrl = TextEditingController();
  final nextFollowUpCtrl = TextEditingController();

  // Lead Information
  final _remarksCtrl = TextEditingController();

  // Product Info
  final _costCtrl = TextEditingController();

  // Dropdown values
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedStaff;
  String? _selectedCategory;
  String? _selectedSource;
  String? _selectedPriority = 'Normal';
  String? _selectedStage;
  String? _selectedLeadTag;
  String? _selectedCallStatus;

  @override
  void initState() {
    super.initState();
    if (widget.from == 'EDIT' && widget.lead != null) {
      _prefillIfEditing(widget.lead!);
    } else {
      _selectedPriority = 'Normal';
      _selectedStage = 'NEW';
    }
  }

  DateTime nextFollowUpDate = DateTime.now().add(const Duration(hours: 1));
  DateTime calledDateValue = DateTime.now();

  DateTime _nextFollowupDateValue = DateTime.now().add(const Duration(days: 1));
  String? _nextFollowupDate;

  Future<void> _pickNextFollowupDate() async {
    final now = DateTime.now();
    // Default to tomorrow so the calendar opens on a valid date
    final initialDate = now.add(const Duration(days: 1));

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now, // ✅ past dates greyed out
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
    );

    if (time == null || !mounted) return;

    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // ✅ Reject if the combined date+time is not strictly in the future
    if (!picked.isAfter(now)) {
      _showError('Please select a future date and time');
      return;
    }

    setState(() {
      _nextFollowupDateValue = picked;
      _nextFollowupDate = DateFormat('dd-MM-yyyy hh:mm a').format(picked);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _prefillIfEditing(AddLeadModel lead) {
    _clientNameCtrl.text = lead.clientName;
    _contactCtrl.text = lead.contactNumber;
    _whatsappCtrl.text = lead.whatsappNumber;
    _emailCtrl.text = lead.email;
    _addressCtrl.text = lead.address;
    _pinCtrl.text = lead.pinCode;
    _remarksCtrl.text = lead.remarks;
    _selectedStage = lead.leadStage;
    _selectedSource = lead.leadSource;
    _selectedCategory = lead.leadCategory;
    _selectedPriority = lead.priority;
    _selectedStaff = lead.assignedStaff.isNotEmpty ? lead.assignedStaff : null;
    _selectedState = lead.state.isNotEmpty ? lead.state : null;
    nextFollowUpDate =
        lead.followUpDate ?? DateTime.now().add(const Duration(days: 1));
    nextFollowUpCtrl.text = DateFormat('dd-MM-yyyy').format(nextFollowUpDate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<AddLeadCubit>();
      if (lead.state.isNotEmpty) cubit.selectState(lead.state);
      if (lead.district.isNotEmpty) cubit.selectDistrict(lead.district);
      if (lead.leadCategory.isNotEmpty) cubit.selectCategory(lead.leadCategory);
      if (lead.leadSource.isNotEmpty) cubit.selectSource(lead.leadSource);
      if (lead.priority.isNotEmpty) cubit.selectPriority(lead.priority);
      if (lead.assignedStaff.isNotEmpty) {
        cubit.selectAssignedStaff(
          name: lead.assignedStaff,
          id: lead.assignedStaffId,
        );
      }
    });
  }

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

  // void _showAddCategoryDialog(BuildContext parentContext) {
  //   final controller = TextEditingController();
  //   showDialog(
  //     context: parentContext,
  //     builder: (dialogContext) {
  //       return BlocProvider.value(
  //         value: parentContext.read<LeadCategoryCubit>(),
  //         child: BlocConsumer<LeadCategoryCubit, LeadCategoryState>(
  //           listener: (context, state) {},
  //           builder: (context, state) {
  //             return AlertDialog(
  //               title: const Text('Add Category'),
  //               content: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   TextField(
  //                     controller: controller,
  //                     decoration: const InputDecoration(
  //                       hintText: 'Enter category name',
  //                     ),
  //                   ),
  //                   if (state.isSubmitting)
  //                     const Padding(
  //                       padding: EdgeInsets.only(top: 8.0),
  //                       child: LinearProgressIndicator(),
  //                     ),
  //                 ],
  //               ),
  //               actions: [
  //                 TextButton(
  //                   onPressed: () => Navigator.pop(dialogContext),
  //                   child: const Text('Cancel'),
  //                 ),
  //                 ElevatedButton(
  //                   onPressed: state.isSubmitting
  //                       ? null
  //                       : () async {
  //                           final name = controller.text.trim();
  //                           if (name.isNotEmpty) {
  //                             try {
  //                               await context
  //                                   .read<LeadCategoryCubit>()
  //                                   .addCategory(name: name);
  //                               if (dialogContext.mounted) {
  //                                 Navigator.pop(dialogContext);
  //                               }
  //                             } catch (e) {
  //                               if (dialogContext.mounted) {
  //                                 ScaffoldMessenger.of(
  //                                   dialogContext,
  //                                 ).showSnackBar(
  //                                   SnackBar(content: Text(e.toString())),
  //                                 );
  //                               }
  //                             }
  //                           }
  //                         },
  //                   child: const Text('Add'),
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  // void _showAddSourceDialog(BuildContext parentContext) {
  //   final controller = TextEditingController();
  //   showDialog(
  //     context: parentContext,
  //     builder: (dialogContext) {
  //       return BlocProvider.value(
  //         value: parentContext.read<LeadSourceCubit>(),
  //         child: BlocConsumer<LeadSourceCubit, LeadSourceState>(
  //           listener: (context, state) {},
  //           builder: (context, state) {
  //             return AlertDialog(
  //               title: const Text('Add Lead Source'),
  //               content: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   TextField(
  //                     controller: controller,
  //                     decoration: const InputDecoration(
  //                       hintText: 'Enter source name',
  //                     ),
  //                   ),
  //                   if (state.isSubmitting)
  //                     const Padding(
  //                       padding: EdgeInsets.only(top: 8.0),
  //                       child: LinearProgressIndicator(),
  //                     ),
  //                 ],
  //               ),
  //               actions: [
  //                 TextButton(
  //                   onPressed: () => Navigator.pop(dialogContext),
  //                   child: const Text('Cancel'),
  //                 ),
  //                 ElevatedButton(
  //                   onPressed: state.isSubmitting
  //                       ? null
  //                       : () async {
  //                           final name = controller.text.trim();
  //                           if (name.isNotEmpty) {
  //                             try {
  //                               await context.read<LeadSourceCubit>().addSource(
  //                                 name: name,
  //                               );
  //                               if (dialogContext.mounted) {
  //                                 Navigator.pop(dialogContext);
  //                               }
  //                             } catch (e) {
  //                               if (dialogContext.mounted) {
  //                                 ScaffoldMessenger.of(
  //                                   dialogContext,
  //                                 ).showSnackBar(
  //                                   SnackBar(content: Text(e.toString())),
  //                                 );
  //                               }
  //                             }
  //                           }
  //                         },
  //                   child: const Text('Add'),
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  void _showAddCategoryDialog(BuildContext parentContext) {
    final controller = TextEditingController();
    showDialog(
      context: parentContext,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) {
        return BlocProvider.value(
          value: parentContext.read<LeadCategoryCubit>(),
          child: BlocConsumer<LeadCategoryCubit, LeadCategoryState>(
            listener: (context, state) {},
            builder: (context, state) {
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Container(
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Icon + Title ─────────────────────────────
                      Row(
                        children: [
                          Container(
                            width: 11.w,
                            height: 11.w,
                            decoration: BoxDecoration(
                              color: AppColors.bottomNavBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.category_outlined,
                              color: AppColors.bottomNavBlue,
                              size: 6.w,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              'Add Lead Category',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1D2433),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(dialogContext),
                            child: Container(
                              padding: EdgeInsets.all(1.5.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F3F5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 4.5.w,
                                color: const Color(0xFF555555),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 2.5.h),

                      // ── Subtitle ─────────────────────────────────
                      Text(
                        'This will be added to your Lead Category list and can be reused for future leads.',
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          color: const Color(0xFF888888),
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),

                      SizedBox(height: 2.5.h),

                      // ── Text field ───────────────────────────────
                      TextField(
                        controller: controller,
                        autofocus: true,
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          color: const Color(0xFF212121),
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. Visited, May Visited, Not Interested',
                          hintStyle: TextStyle(
                            fontSize: 13.5.sp,
                            color: const Color(0xFFAAAAAA),
                          ),
                          prefixIcon: Icon(
                            Icons.edit_outlined,
                            size: 5.w,
                            color: const Color(0xFF888888),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.6.h,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
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

                      if (state.isSubmitting) ...[
                        SizedBox(height: 2.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            minHeight: 4,
                            backgroundColor: const Color(0xFFE0E0E0),
                            color: AppColors.bottomNavBlue,
                          ),
                        ),
                      ],

                      SizedBox(height: 3.h),

                      // ── Actions ──────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: state.isSubmitting
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 1.6.h),
                                side: const BorderSide(
                                  color: Color(0xFFE0E0E0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF555555),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: state.isSubmitting
                                  ? null
                                  : () async {
                                      final name = controller.text.trim();
                                      if (name.isNotEmpty) {
                                        try {
                                          await context
                                              .read<LeadCategoryCubit>()
                                              .addCategory(name: name);

                                          // NEW: close dialog first
                                          if (dialogContext.mounted) {
                                            Navigator.pop(dialogContext);
                                          }

                                          // NEW: auto-select the newly added
                                          // category. We already know the
                                          // exact value that was just written
                                          // to Firestore (`name`), so we
                                          // don't need to wait for the stream
                                          // to refresh before selecting it —
                                          // this also avoids any extra API
                                          // calls.
                                          if (mounted) {
                                            setState(() {
                                              _selectedCategory = name;
                                            });
                                            parentContext
                                                .read<AddLeadCubit>()
                                                .selectCategory(name);
                                          }
                                        } catch (e) {
                                          if (dialogContext.mounted) {
                                            ScaffoldMessenger.of(
                                              dialogContext,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(e.toString()),
                                                backgroundColor: Colors.red,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.bottomNavBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 1.6.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: state.isSubmitting
                                  ? SizedBox(
                                      width: 4.5.w,
                                      height: 4.5.w,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Add Category',
                                      style: TextStyle(
                                        fontSize: 14.5.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showAddSourceDialog(BuildContext parentContext) {
    final controller = TextEditingController();
    showDialog(
      context: parentContext,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) {
        return BlocProvider.value(
          value: parentContext.read<LeadSourceCubit>(),
          child: BlocConsumer<LeadSourceCubit, LeadSourceState>(
            listener: (context, state) {},
            builder: (context, state) {
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Container(
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Icon + Title ─────────────────────────────
                      Row(
                        children: [
                          Container(
                            width: 11.w,
                            height: 11.w,
                            decoration: BoxDecoration(
                              color: AppColors.bottomNavBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.source_outlined,
                              color: AppColors.bottomNavBlue,
                              size: 6.w,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              'Add Lead Source',
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1D2433),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(dialogContext),
                            child: Container(
                              padding: EdgeInsets.all(1.5.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F3F5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 4.5.w,
                                color: const Color(0xFF555555),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 2.5.h),

                      // ── Subtitle ─────────────────────────────────
                      Text(
                        'This will be added to your Lead Source list and can be reused for future leads.',
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          color: const Color(0xFF888888),
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),

                      SizedBox(height: 2.5.h),

                      // ── Text field ───────────────────────────────
                      TextField(
                        controller: controller,
                        autofocus: true,
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          color: const Color(0xFF212121),
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. Instagram Ads, Referral, Walk-in',
                          hintStyle: TextStyle(
                            fontSize: 13.5.sp,
                            color: const Color(0xFFAAAAAA),
                          ),
                          prefixIcon: Icon(
                            Icons.edit_outlined,
                            size: 5.w,
                            color: const Color(0xFF888888),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.6.h,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
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

                      if (state.isSubmitting) ...[
                        SizedBox(height: 2.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            minHeight: 4,
                            backgroundColor: const Color(0xFFE0E0E0),
                            color: AppColors.bottomNavBlue,
                          ),
                        ),
                      ],

                      SizedBox(height: 3.h),

                      // ── Actions ──────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: state.isSubmitting
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 1.6.h),
                                side: const BorderSide(
                                  color: Color(0xFFE0E0E0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF555555),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: state.isSubmitting
                                  ? null
                                  : () async {
                                      final name = controller.text.trim();
                                      if (name.isNotEmpty) {
                                        try {
                                          await context
                                              .read<LeadSourceCubit>()
                                              .addSource(name: name);

                                          if (dialogContext.mounted) {
                                            Navigator.pop(dialogContext);
                                          }

                                          if (mounted) {
                                            setState(() {
                                              _selectedSource = name;
                                            });
                                            parentContext
                                                .read<AddLeadCubit>()
                                                .selectSource(name);
                                          }
                                        } catch (e) {
                                          if (dialogContext.mounted) {
                                            ScaffoldMessenger.of(
                                              dialogContext,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(e.toString()),
                                                backgroundColor: Colors.red,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.bottomNavBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 1.6.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: state.isSubmitting
                                  ? SizedBox(
                                      width: 4.5.w,
                                      height: 4.5.w,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Add Source',
                                      style: TextStyle(
                                        fontSize: 14.5.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── Submit handler (single place for validation gate) ─────────────────────
  void _handleSubmit(BuildContext context, AddLeadState state) {
    // ✅ Validate all form fields first
    if (!_formKey.currentState!.validate()) return;

    if (widget.from != 'EDIT') {
      if (_selectedStage == 'FOLLOWUP' || _selectedStage == 'REJECTED') {
        if ((_selectedCallStatus ?? '').isEmpty) {
          _showError('Call Status is required');
          return;
        }
      }
      if (_selectedStage == 'FOLLOWUP') {
        if (_nextFollowupDate == null) {
          _showError('Next Followup Date is required');
          return;
        }
      }
      if (_selectedStage == 'REJECTED') {
        if ((_selectedLeadTag ?? '').isEmpty) {
          _showError('Tag is required');
          return;
        }
      }
    }

    if (widget.from == 'EDIT' && widget.lead != null) {
      if (widget.lead?.id == null) {
        debugPrint('Lead ID is null');
        return;
      }
      if ((_selectedStaff ?? '').isEmpty) {
        debugPrint('Staff is empty');
        return;
      }

      final updatedLead = AddLeadModel(
        id: widget.lead?.id,
        clientName: _clientNameCtrl.text,
        contactNumber: _contactCtrl.text,
        contactDialCode: '+91',
        whatsappNumber: _whatsappCtrl.text,
        whatsappDialCode: '+91',
        email: _emailCtrl.text,
        address: _addressCtrl.text,
        pinCode: _pinCtrl.text,
        postOffice: '',
        state: _selectedState ?? widget.lead?.state ?? '',
        district: '',
        remarks: _remarksCtrl.text,
        leadCategory: _selectedCategory ?? widget.lead?.leadCategory ?? '',
        leadSource: _selectedSource ?? widget.lead?.leadSource ?? '',
        leadTag: _selectedLeadTag,
        priority: _selectedPriority ?? widget.lead?.priority ?? '',
        assignedStaffId:
            state.assignedStaffId ?? widget.lead?.assignedStaffId ?? '',
        assignedStaff: _selectedStaff ?? widget.lead?.assignedStaff ?? '',
        leadStage: _selectedStage ?? widget.lead?.leadStage ?? 'NEW',
        createdBy: widget.lead!.createdBy,
        createdById: widget.lead!.createdById,
        createdAt: widget.lead!.createdAt,
        callResult: widget.lead!.callResult,
        followUpDate: widget.lead!.followUpDate,
        followUp: widget.lead!.followUp,
      );
      context.read<AddLeadCubit>().updateLead(
        widget.lead?.id ?? '',
        updatedLead,
      );
      // () async {
      //   final cubit = context.read<AddLeadCubit>();
      //   await cubit.updateLead(widget.lead?.id ?? '', updatedLead);
      //   debugPrint('Lead Updated Successfully');
      //   await cubit.fetchLeads();
      //   debugPrint('Lead Count: ${cubit.state.leads.length}');
      // }();
      return;
    }

    // CREATE MODE
    context.read<AddLeadCubit>().submitLead(
      clientName: _clientNameCtrl.text,
      contactNumber: _contactCtrl.text,
      contactDialCode: '+91',
      whatsappNumber: _whatsappCtrl.text,
      whatsappDialCode: '+91',
      email: _emailCtrl.text,
      address: _addressCtrl.text,
      pinCode: _pinCtrl.text,
      postOffice: '',
      remarks: _remarksCtrl.text,
      nextFollowUpDate: _nextFollowupDateValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddLeadCubit, AddLeadState>(
      listener: (context, state) {
        // if (state.status == AddLeadStatus.success) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text(
        //         state.successMessage ??
        //             (widget.from == 'EDIT'
        //                 ? 'Lead updated successfully'
        //                 : 'Lead created successfully'),
        //       ),
        //       backgroundColor: Colors.green,
        //     ),
        //   );
        //   Navigator.maybePop(context, true);
        // } else if (state.status == AddLeadStatus.failure) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text(state.errorMessage ?? 'Failed to create lead'),
        //       backgroundColor: Colors.red,
        //     ),
        //   );
        // }
        if (!state.isSubmitting && !state.isUpdating) {
          if (state.status == AddLeadStatus.success &&
              (state.successMessage?.isNotEmpty == true)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.maybePop(context, true);
          } else if (state.status == AddLeadStatus.failure &&
              (state.errorMessage?.isNotEmpty == true)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        if (state.status == AddLeadStatus.loading && !state.isSubmitting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final categoryState = context.watch<LeadCategoryCubit>().state;
        final sourceState = context.watch<LeadSourceCubit>().state;
        final categories = categoryState.categories.map((c) => c.name).toList();
        final sources = sourceState.sources.map((s) => s.name).toList();
        final stages = state.stages.map((st) => st.name).toList();
        final staffList = state.staffList.map((s) => s.name).toList();
        if (staffList.isEmpty && state.assignedStaffName.isNotEmpty) {
          staffList.add(state.assignedStaffName);
        }

        if (widget.from != 'EDIT') {
          if (categories.isNotEmpty &&
              _selectedCategory != null &&
              !categories.contains(_selectedCategory)) {
            _selectedCategory = null;
          }
          if (sources.isNotEmpty &&
              _selectedSource != null &&
              !sources.contains(_selectedSource)) {
            _selectedSource = null;
          }
          if (stages.isNotEmpty &&
              _selectedStage != null &&
              !stages.contains(_selectedStage)) {
            _selectedStage = null;
          }
          if (staffList.isNotEmpty &&
              _selectedStaff != null &&
              !staffList.contains(_selectedStaff)) {
            _selectedStaff = null;
          }
        }

        _selectedStaff ??= state.assignedStaffName.isNotEmpty
            ? state.assignedStaffName
            : null;
        _selectedCategory ??= state.selectedCategory;
        _selectedSource ??= state.selectedSource;
        _selectedStage ??= state.selectedLeadStage;
        _selectedPriority ??= state.selectedPriority;
        _selectedState ??= state.selectedState;

        final bool isSaving = state.isSubmitting;

        return Scaffold(
          backgroundColor: const Color(0xFFF0F4F8),
          appBar: _buildAppBar(),
          body: SafeArea(
            // ✅ Form wraps the entire scrollable body
            child: Form(
              key: _formKey,
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
                      postOfficeCtrl: _postOfficeCtrl,
                      selectedState: _selectedState,
                      selectedDistrict: _selectedDistrict,
                      districts: [
                        'wayanad',
                        'malappuram',
                        'kozhikode',
                        'palakad',
                        'thrissur',
                        'ernakulam',
                        'kannur',
                        'kasargod',
                        'kollam',
                        'pathanamthitta',
                        'alappuzha',
                        'kottayam',
                        'idukki',
                        'kannur',
                        'kasargod',
                        'kollam',
                        'pathanamthitta',
                        'alappuzha',
                        'kottayam',
                        'idukki',
                      ],
                      states: [
                        'Kerala',
                        'Tamil Nadu',
                        'Karnataka',
                        'Maharashtra',
                        'Delhi',
                      ],
                      onStateChanged: (v) {
                        setState(() => _selectedState = v);
                        context.read<AddLeadCubit>().selectState(v);
                      },
                      onContactPickerTap: () {},
                      onDistrictChanged: (v) {
                        setState(() => _selectedDistrict = v);
                        context.read<AddLeadCubit>().selectDistrict(v);
                      },
                    ),
                    SizedBox(height: 2.h),
                    _LeadInformationCard(
                      from: widget.from!,
                      selectedStaff: _selectedStaff,
                      staffList: staffList,
                      categories: categories,
                      sources: sources,
                      onStaffChanged: (v) {
                        setState(() => _selectedStaff = v);
                        if (v != null) {
                          try {
                            final matchingStaff = state.staffList.firstWhere(
                              (s) => s.name == v,
                            );
                            context.read<AddLeadCubit>().selectAssignedStaff(
                              name: matchingStaff.name,
                              id: matchingStaff.id ?? '',
                            );
                          } catch (_) {
                            context.read<AddLeadCubit>().selectAssignedStaff(
                              name: v,
                              id: '',
                            );
                          }
                        }
                      },
                      selectedCategory: _selectedCategory,
                      onCategoryChanged: (v) {
                        setState(() => _selectedCategory = v);
                        context.read<AddLeadCubit>().selectCategory(v);
                      },
                      onAddCategory: () => _showAddCategoryDialog(context),
                      selectedSource: _selectedSource,
                      onSourceChanged: (v) {
                        setState(() => _selectedSource = v);
                        context.read<AddLeadCubit>().selectSource(v);
                      },
                      onAddSource: () => _showAddSourceDialog(context),
                      selectedPriority: _selectedPriority,
                      priorities: const ['Normal', 'High', 'Low', 'Negative'],
                      onPriorityChanged: (v) {
                        setState(() => _selectedPriority = v);
                        context.read<AddLeadCubit>().selectPriority(v);
                      },
                      selectedStage: _selectedStage,
                      stages: stages,
                      onStageChanged: (v) {
                        setState(() => _selectedStage = v);
                        context.read<AddLeadCubit>().selectLeadStage(v);
                      },
                      remarksCtrl: _remarksCtrl,
                      onPickNextFollowupDate: _pickNextFollowupDate,
                      nextFollowupDate:
                          _nextFollowupDate ??
                          DateFormat(
                            'dd-MM-yyyy hh:mm a',
                          ).format(DateTime.now().add(const Duration(days: 1))),
                      onCallStatusChanged: (val) {
                        setState(() {
                          _selectedCallStatus = val;
                        });
                        context.read<AddLeadCubit>().selectCallResult(val);
                      },
                      onTagChanged: (val) {
                        setState(() {
                          _selectedLeadTag = val;
                        });
                        context.read<AddLeadCubit>().selectLeadTag(val);
                      },
                      selectedTag: _selectedLeadTag,
                      selectedCallStatus: _selectedCallStatus,
                    ),
                    SizedBox(height: 2.h),
                    if (isSaving)
                      const Center(child: CircularProgressIndicator())
                    else
                      PrimaryButton(
                        label: widget.from == 'EDIT'
                            ? 'Update Lead'
                            : 'Create Lead',
                        onTap: () => _handleSubmit(context, state),
                      ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
          widget.from == 'EDIT' ? 'Edit Lead' : 'Create Lead',
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
// SECTION CARD
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
// SECTION TITLE
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
// CUSTOM DROPDOWN FIELD
// ---------------------------------------------------------------------------
// class _CustomDropdownField<T> extends StatelessWidget {
//   final T? value;
//   final List<T> items;
//   final String hint;
//   final String? floatingLabel;
//   final void Function(T?) onChanged;
//   final bool filled;
//   final Widget? suffixWidget;
//   final bool isRequired;

//   const _CustomDropdownField({
//     super.key,
//     required this.value,
//     required this.items,
//     required this.hint,
//     required this.onChanged,
//     this.floatingLabel,
//     this.filled = true,
//     this.suffixWidget,
//     this.isRequired = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return PopupMenuButton<T>(
//       offset: Offset(0, 6.h),
//       color: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       onSelected: onChanged,
//       itemBuilder: (context) {
//         return items.map((e) {
//           return PopupMenuItem<T>(
//             value: e,
//             child: Text(
//               e.toString(),
//               style: TextStyle(
//                 fontSize: 15.sp,
//                 color: ScreenColors.textPrimary,
//               ),
//             ),
//           );
//         }).toList();
//       },
//       child: InputDecorator(
//         decoration: InputDecoration(
//           labelText: value != null ? floatingLabel : null,
//           labelStyle: TextStyle(fontSize: 15.sp, color: ScreenColors.hintGrey),
//           filled: filled,
//           fillColor: filled ? Colors.white : Colors.transparent,
//           contentPadding: EdgeInsets.symmetric(
//             horizontal: 3.w,
//             vertical: 1.2.h,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: const BorderSide(
//               color: AppColors.bottomNavBlue,
//               width: 0.1,
//             ),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: const BorderSide(
//               color: AppColors.bottomNavBlue,
//               width: 0.1,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: const BorderSide(
//               color: AppColors.bottomNavBlue,
//               width: 1.5,
//             ),
//           ),
//           isDense: true,
//           suffixIcon:
//               suffixWidget ??
//               Icon(
//                 Icons.arrow_drop_down,
//                 color: ScreenColors.iconGrey,
//                 size: 20.sp,
//               ),
//           // suffixIconConstraints: const BoxConstraints(),
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: Text(
//                 value != null ? value.toString() : hint,
//                 style: TextStyle(
//                   fontSize: 15.sp,
//                   color: value != null
//                       ? ScreenColors.textPrimary
//                       : ScreenColors.hintGrey,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class _CustomDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String hint;
  final String? floatingLabel;
  final void Function(T?) onChanged;
  final bool filled;
  final Widget? suffixWidget;
  final bool isRequired;

  const _CustomDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
    this.floatingLabel,
    this.filled = true,
    this.suffixWidget,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    // Show the clear (✕) icon only when a value is selected and the
    // field is not marked required. Required fields keep only the
    // dropdown arrow, exactly as before.
    final bool showClearIcon = value != null && !isRequired;

    return PopupMenuButton<T>(
      offset: Offset(0, 6.h),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: onChanged,
      itemBuilder: (context) {
        return items.map((e) {
          return PopupMenuItem<T>(
            value: e,
            child: Text(
              e.toString(),
              style: TextStyle(
                fontSize: 15.sp,
                color: ScreenColors.textPrimary,
              ),
            ),
          );
        }).toList();
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: value != null ? floatingLabel : null,
          labelStyle: TextStyle(fontSize: 15.sp, color: ScreenColors.hintGrey),
          filled: filled,
          fillColor: filled ? Colors.white : Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 3.w,
            vertical: 1.2.h,
          ),
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
          suffixIcon:
              suffixWidget ??
              (showClearIcon
                  ? GestureDetector(
                      // Stop the tap from bubbling up to the
                      // PopupMenuButton so clearing never opens the menu.
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(null),
                      child: Icon(
                        Icons.close,
                        color: ScreenColors.iconGrey,
                        size: 18.sp,
                      ),
                    )
                  : Icon(
                      Icons.arrow_drop_down,
                      color: ScreenColors.iconGrey,
                      size: 20.sp,
                    )),
          // suffixIconConstraints: const BoxConstraints(),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value != null ? value.toString() : hint,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: value != null
                      ? ScreenColors.textPrimary
                      : ScreenColors.hintGrey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GRADIENT SQUARE BUTTON
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
// GREEN CIRCULAR ADD BUTTON
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
// PRIMARY BUTTON
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
  final TextEditingController postOfficeCtrl;
  final String? selectedState;
  final String? selectedDistrict;
  final List<String> states;
  final List<String> districts;
  final void Function(String?) onStateChanged;
  final void Function(String?) onDistrictChanged;
  final VoidCallback onContactPickerTap;

  const _CustomerDetailsCard({
    required this.clientNameCtrl,
    required this.contactCtrl,
    required this.whatsappCtrl,
    required this.emailCtrl,
    required this.addressCtrl,
    required this.pinCtrl,
    required this.postOfficeCtrl,
    required this.selectedState,
    required this.selectedDistrict,
    required this.districts,
    required this.states,
    required this.onStateChanged,
    required this.onDistrictChanged,
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
        // Client Name
        SizedBox(
          height: 6.h,
          child: CustomTextField(
            controller: clientNameCtrl,
            hint: 'Client Name',
            isRequired: true,
            filled: false,
            outlined: true,
            suffixIcon: Icons.person_outline,
            validator: validateClientName,
          ),
        ),
        SizedBox(height: 1.2.h),

        // Contact Number
        SizedBox(
          height: 6.h,
          child: CustomTextField(
            controller: contactCtrl,
            hint: 'Contact Number',
            isRequired: true,
            filled: false,
            outlined: true,
            phone: true,
            suffixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: validatePhone, // ✅
          ),
        ),
        SizedBox(height: 1.2.h),

        // WhatsApp Number
        SizedBox(
          height: 6.h,
          child: CustomTextField(
            controller: whatsappCtrl,
            hint: 'Whatsapp Number',
            filled: false,
            outlined: true,
            phone: true,
            keyboardType: TextInputType.phone,
            suffixIcon: Icons.phone_outlined,
            validator: validateWhatsapp, // ✅
          ),
        ),
        SizedBox(height: 1.2.h),

        // Email
        SizedBox(
          height: 6.h,
          child: CustomTextField(
            controller: emailCtrl,
            hint: 'Email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            suffixIcon: Icons.email_outlined,
            validator: validateEmail, // ✅
          ),
        ),
        SizedBox(height: 1.2.h),

        // Address (no validation — free text)
        CustomTextField(
          controller: addressCtrl,
          hint: 'Address',
          prefixIcon: Icons.location_on_outlined,
          maxLines: 5,
          suffixIcon: Icons.location_on_outlined,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 3.w,
            vertical: 1.5.h,
          ),
        ),
        SizedBox(height: 1.2.h),

        // PIN Code
        SizedBox(
          height: 6.h,
          child: CustomTextField(
            controller: pinCtrl,
            hint: 'PIN Code',
            prefixIcon: Icons.pin_drop_outlined,
            keyboardType: TextInputType.number,
            suffixIcon: Icons.share_location_sharp,
            pinCode: true, // ✅ enables 6-digit formatter
            validator: validatePincode, // ✅
          ),
        ),
        SizedBox(height: 1.2.h),

        SizedBox(
          height: 6.h,
          child: CustomTextField(
            controller: postOfficeCtrl,
            hint: 'Post Office',
            prefixIcon: Icons.pin_drop_outlined,
            keyboardType: TextInputType.text,
            suffixIcon: Icons.home_work_rounded,
          ),
        ),
        SizedBox(height: 1.2.h),

        // State dropdown
        SizedBox(
          height: 6.h,
          child: _CustomDropdownField<String>(
            value: selectedState,
            items: [
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
        SizedBox(height: 1.2.h),
        // district
        SizedBox(
          height: 6.h,
          child: _CustomDropdownField<String>(
            value: selectedDistrict,
            items: [
              'Malappuram',
              'Ernakulam',
              'Alappuzha',
              'Kozhikode',
              'Thiruvananthapuram',
            ],
            hint: 'District',
            onChanged: onDistrictChanged,
            floatingLabel: 'District',
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
  final String from;
  final String? selectedStaff;
  final List<String> staffList;
  final void Function(String?) onStaffChanged;
  final String? selectedCategory;
  final List<String> categories;
  final void Function(String?) onCategoryChanged;
  final VoidCallback onAddCategory;
  final String? selectedSource;
  final List<String> sources;
  final void Function(String?) onSourceChanged;
  final VoidCallback onAddSource;
  final String? selectedPriority;
  final List<String> priorities;
  final void Function(String?) onPriorityChanged;
  final String? selectedStage;
  final List<String> stages;
  final void Function(String?) onStageChanged;
  final TextEditingController remarksCtrl;
  final String? nextFollowupDate;
  final VoidCallback onPickNextFollowupDate;
  final String? selectedTag;

  final ValueChanged<String?> onTagChanged;
  final String? selectedCallStatus;
  final ValueChanged<String?> onCallStatusChanged;

  const _LeadInformationCard({
    required this.from,
    required this.selectedStaff,
    required this.staffList,
    required this.onStaffChanged,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
    required this.onAddCategory,
    required this.selectedSource,
    required this.sources,
    required this.onSourceChanged,
    required this.onAddSource,
    required this.selectedPriority,
    required this.priorities,
    required this.onPriorityChanged,
    required this.selectedStage,
    required this.stages,
    required this.onStageChanged,
    required this.remarksCtrl,
    this.nextFollowupDate,
    required this.onPickNextFollowupDate,
    required this.onCallStatusChanged,
    this.selectedCallStatus,
    this.selectedTag,
    required this.onTagChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSectionCard(
      header: const SectionTitle(
        icon: Icons.info_outline,
        title: 'Lead Information',
      ),
      children: [
        SizedBox(
          height: 6.h,
          child: _CustomDropdownField<String>(
            value: selectedStaff,
            items: staffList,
            hint: 'Assign Staff',
            floatingLabel: 'Assign Staff',
            onChanged: onStaffChanged,
            isRequired: true,
          ),
        ),
        SizedBox(height: 1.2.h),
        _DropdownWithAdd(
          value: selectedCategory,
          items: categories,
          hint: 'Lead Category',
          floatingLabel: 'Lead Category',
          onChanged: onCategoryChanged,
          onAdd: onAddCategory,
        ),
        SizedBox(height: 1.2.h),
        _DropdownWithAdd(
          value: selectedSource,
          items: sources,
          hint: 'Lead Source',
          floatingLabel: 'Lead Source',
          onChanged: onSourceChanged,
          onAdd: onAddSource,
        ),
        SizedBox(height: 1.2.h),
        SizedBox(
          height: 6.h,
          child: _CustomDropdownField<String>(
            value: selectedPriority,
            items: priorities,
            hint: 'Priority',
            floatingLabel: 'Priority',
            onChanged: onPriorityChanged,
            isRequired: true,
          ),
        ),
        if (from != 'EDIT') ...[
          SizedBox(height: 1.2.h),
          SizedBox(
            height: 6.h,
            child: _CustomDropdownField<String>(
              value: selectedStage,
              items: stages,
              hint: 'Stages',
              floatingLabel: 'Stages',
              onChanged: onStageChanged,
              isRequired: true,
            ),
          ),
          if (selectedStage == 'FOLLOWUP' || selectedStage == 'REJECTED') ...[
            Column(
              children: [
                SizedBox(height: 1.2.h),
                if (selectedStage == 'FOLLOWUP') ...[
                  Row(
                    children: [
                      Text(
                        'Next Followup Date',
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
                ],
                if (selectedStage == 'REJECTED') ...[
                  CustomDropdownField(
                    label: 'Tag',
                    value: selectedTag,
                    hintText: 'Select Tag',
                    isRequired: true,
                    items: const [
                      'Costly',
                      'Not interested',
                      'Bad Quality',
                      'Pending',
                      'Rejected',
                      'Switched Off',
                    ],
                    // FIX: Now uses the real onTagChanged callback from the
                    // widget parameter instead of the former uninitialized local.
                    onChanged: onTagChanged,
                  ),
                ],
                SizedBox(height: 1.2.h),
                CustomDropdownField(
                  label: 'Call Status',
                  value: selectedCallStatus,
                  hintText: 'Select Call Status',
                  isRequired: true,
                  items: [
                    'Connected',
                    'Busy',
                    'Not Attended',
                    'Switched Off',
                    'Out Of Coverage',
                    'Wrong Number',
                    'Not Reachable',
                    'Other',
                  ],
                  onChanged: onCallStatusChanged,
                ),
              ],
            ),
          ],
        ],

        SizedBox(height: 1.2.h),
        // CustomTextField(
        //   controller: remarksCtrl,
        //   hint: 'Remarks',
        //   prefixIcon: Icons.list_alt_outlined,
        //   maxLines: 5,
        //   filled: true,
        //   // suffixIcon: Icons.edit_document,
        //   contentPadding: EdgeInsets.symmetric(
        //     horizontal: 3.w,
        //     vertical: 1.5.h,
        //   ),
        // ),
        TextField(
          controller: remarksCtrl,
          maxLines: 5,
          style: TextStyle(color: const Color(0xFF212121), fontSize: 14.5.sp),
          decoration: InputDecoration(
            hintText: 'Enter Remarks',
            hintStyle: TextStyle(
              color: const Color(0xFF888888),
              fontSize: 14.sp,
            ),

            // label: Text(
            //   'Remarks',
            //   style: TextStyle(
            //     color: const Color(0xFF888888),
            //     fontSize: 14.5.sp,
            //   ),
            // ),
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
    );
  }
}

// ---------------------------------------------------------------------------
// DROPDOWN WITH ADD BUTTON
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
            child: _CustomDropdownField<String>(
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

// ---------------------------------------------------------------------------
// CUSTOM TEXT FIELD  — updated: validator typed correctly + pinCode flag
// ---------------------------------------------------------------------------
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
  final double? fontSize;
  final EdgeInsetsGeometry? contentPadding;
  final bool? phone;
  final bool? pinCode; // ✅ new: enables 6-digit formatter for PIN
  final bool? isLabel;
  // ✅ Correct type: nullable function returning nullable String
  final String? Function(String?)? validator;

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
    this.fontSize,
    this.contentPadding,
    this.phone = false,
    this.pinCode = false, // ✅
    this.isLabel = true,
    this.validator, // ✅
  });

  @override
  Widget build(BuildContext context) {
    // ── Input formatters ────────────────────────────────────────────────────
    List<TextInputFormatter> formatters = [];

    if (phone == true) {
      // 10-digit numeric — unchanged from original
      formatters = [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ];
    } else if (pinCode == true) {
      // ✅ 6-digit numeric for PIN Code
      formatters = [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ];
    }

    return TextFormField(
      controller: controller,
      validator: validator, // ✅ wired in
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: fontSize ?? 15.sp,
        color: ScreenColors.textPrimary,
      ),
      inputFormatters: formatters.isNotEmpty ? formatters : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: ScreenColors.requiredRed,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: ScreenColors.requiredRed,
            width: 1.5,
          ),
        ),
        label: isLabel == true
            ? RichText(
                text: TextSpan(
                  text: hint,
                  style: TextStyle(
                    fontSize: fontSize ?? 15.sp,
                    color: ScreenColors.hintGrey,
                  ),
                  children: [
                    if (isRequired == true)
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: ScreenColors.requiredRed),
                      ),
                  ],
                ),
              )
            : null,
        hintText: isLabel == false ? hint : null,
        hintStyle: TextStyle(
          fontSize: fontSize ?? 14.sp,
          color: ScreenColors.hintGrey,
        ),
        prefixIcon: Icon(suffixIcon, color: ScreenColors.iconGrey, size: 17.sp),
        isDense: true,
        contentPadding:
            contentPadding ??
            EdgeInsets.symmetric(horizontal: 3.w, vertical: 0),
        // ✅ Error text styled to match existing design
        errorStyle: TextStyle(fontSize: 11.sp, color: ScreenColors.requiredRed),
      ),
    );
  }
}
