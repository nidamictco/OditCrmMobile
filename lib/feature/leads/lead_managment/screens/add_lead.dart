// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:odit_crm_mobile/core/theme/app_colors.dart';
// import 'package:odit_crm_mobile/feature/auth/cubit/auth_cubit.dart';
// import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_cubit.dart';
// import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_state.dart';
// import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/cubit/category_cubit.dart';
// import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/cubit/category_state.dart';
// import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/cubit/source_cubit.dart';
// import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/cubit/source_state.dart';
// import 'package:odit_crm_mobile/feature/leads/lead_managment/data/lead_category_repo.dart';
// import 'package:odit_crm_mobile/feature/leads/lead_managment/data/lead_source_repo.dart';
// import 'package:odit_crm_mobile/feature/leads/lead_managment/models/add_lead_model.dart';
// import 'package:sizer/sizer.dart';

// // ---------------------------------------------------------------------------
// // App Colors – replace with your existing ScreenColors class
// // ---------------------------------------------------------------------------
// class ScreenColors {
//   // static const Color gradientBlueStart = Color(0xFF1E88E5);
//   static const Color gradientBlueEnd = Color(0xFF1565C0);
//   static const Color addGreen = Color(0xFF4CAF50);
//   static const Color fieldFill = Color(0xFFF5F5F5);
//   // static const Color hintGrey = Color(0xFF9E9E9E);
//   static const Color hintGrey = Color(0xFF888888);
//   static const Color iconGrey = Color(0xFF757575);
//   static const Color borderGrey = Color(0xFFE0E0E0);
//   static const Color cardShadow = Color(0x14000000);
//   static const Color sectionIconBlue = Color(0xFF1E88E5);
//   static const Color textPrimary = Color(0xFF212121);
//   static const Color requiredRed = Color(0xFFE53935);
// }

// // ---------------------------------------------------------------------------
// // CREATE LEAD SCREEN
// // ---------------------------------------------------------------------------
// class CreateLeadScreen extends StatelessWidget {
//   final String? from;
//   final AddLeadModel? lead;
//   const CreateLeadScreen({super.key, this.from = 'NEW', this.lead});

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (context) => AddLeadCubit()..initialize()),
//         BlocProvider(
//           create: (context) => LeadCategoryCubit()..watchCategories(),
//         ),
//         BlocProvider(create: (context) => LeadSourceCubit()..watchSources()),
//       ],
//       child: CreateLeadScreenBody(from: from, lead: lead),
//     );
//   }
// }

// class CreateLeadScreenBody extends StatefulWidget {
//   final String? from;
//   final AddLeadModel? lead;
//   const CreateLeadScreenBody({super.key, this.from = 'NEW', this.lead});

//   @override
//   State<CreateLeadScreenBody> createState() => _CreateLeadScreenBodyState();
// }

// class _CreateLeadScreenBodyState extends State<CreateLeadScreenBody> {
//   // Customer Details controllers
//   final _clientNameCtrl = TextEditingController();
//   final _contactCtrl = TextEditingController();
//   final _whatsappCtrl = TextEditingController();
//   final _emailCtrl = TextEditingController();
//   final _addressCtrl = TextEditingController();
//   final _pinCtrl = TextEditingController();
//   final nextFollowUpCtrl = TextEditingController();

//   // Lead Information
//   final _remarksCtrl = TextEditingController();

//   // Product Info
//   final _costCtrl = TextEditingController();

//   // Dropdown values
//   String? _selectedState;
//   String? _selectedStaff;
//   String? _selectedCategory;
//   String? _selectedSource;
//   String? _selectedPriority = 'Normal';
//   String? _selectedStage;
//   String? _selectedLeadTag;

//   @override
//   void initState() {
//     super.initState();
//     // ✅ If EDIT mode, populate fields with existing data
//     if (widget.from == 'EDIT' && widget.lead != null) {
//       _prefillIfEditing(widget.lead!);
//     } else {
//       _selectedPriority = 'Normal';
//       _selectedStage = 'NEW';
//     }
//   }

//   DateTime nextFollowUpDate = DateTime.now().add(const Duration(hours: 1));
//   DateTime calledDateValue = DateTime.now();

//   void _prefillIfEditing(AddLeadModel lead) {
//     _clientNameCtrl.text = lead.clientName;
//     _contactCtrl.text = lead.contactNumber;
//     _whatsappCtrl.text = lead.whatsappNumber;
//     _emailCtrl.text = lead.email;
//     _addressCtrl.text = lead.address;
//     _pinCtrl.text = lead.pinCode;
//     // _postOfficeCtrl.text = lead.postOffice;
//     _remarksCtrl.text = lead.remarks;
//     _selectedStage = lead.leadStage;
//     _selectedSource = lead.leadSource;
//     _selectedCategory = lead.leadCategory;
//     _selectedPriority = lead.priority;
//     _selectedStaff = lead.assignedStaff.isNotEmpty ? lead.assignedStaff : null;
//     _selectedState = lead.state.isNotEmpty ? lead.state : null;
//     nextFollowUpDate =
//         lead.followUpDate ?? DateTime.now().add(const Duration(days: 1));
//     nextFollowUpCtrl.text = DateFormat('dd-MM-yyyy').format(nextFollowUpDate);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final cubit = context.read<AddLeadCubit>();
//       if (lead.state.isNotEmpty) cubit.selectState(lead.state);
//       if (lead.district.isNotEmpty) cubit.selectDistrict(lead.district);
//       if (lead.leadCategory.isNotEmpty) cubit.selectCategory(lead.leadCategory);
//       if (lead.leadSource.isNotEmpty) cubit.selectSource(lead.leadSource);
//       if (lead.priority.isNotEmpty) cubit.selectPriority(lead.priority);
//       if (lead.assignedStaff.isNotEmpty) {
//         cubit.selectAssignedStaff(
//           name: lead.assignedStaff,
//           id: lead.assignedStaffId,
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _clientNameCtrl.dispose();
//     _contactCtrl.dispose();
//     _whatsappCtrl.dispose();
//     _emailCtrl.dispose();
//     _addressCtrl.dispose();
//     _pinCtrl.dispose();
//     _remarksCtrl.dispose();
//     _costCtrl.dispose();
//     super.dispose();
//   }

//   void _showAddCategoryDialog(BuildContext parentContext) {
//     final controller = TextEditingController();
//     showDialog(
//       context: parentContext,
//       builder: (dialogContext) {
//         return BlocProvider.value(
//           value: parentContext.read<LeadCategoryCubit>(),
//           child: BlocConsumer<LeadCategoryCubit, LeadCategoryState>(
//             listener: (context, state) {},
//             builder: (context, state) {
//               return AlertDialog(
//                 title: const Text('Add Category'),
//                 content: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       controller: controller,
//                       decoration: const InputDecoration(
//                         hintText: 'Enter category name',
//                       ),
//                     ),
//                     if (state.isSubmitting)
//                       const Padding(
//                         padding: EdgeInsets.only(top: 8.0),
//                         child: LinearProgressIndicator(),
//                       ),
//                   ],
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(dialogContext),
//                     child: const Text('Cancel'),
//                   ),
//                   ElevatedButton(
//                     onPressed: state.isSubmitting
//                         ? null
//                         : () async {
//                             final name = controller.text.trim();
//                             if (name.isNotEmpty) {
//                               try {
//                                 await context
//                                     .read<LeadCategoryCubit>()
//                                     .addCategory(name: name);
//                                 if (dialogContext.mounted) {
//                                   Navigator.pop(dialogContext);
//                                 }
//                               } catch (e) {
//                                 if (dialogContext.mounted) {
//                                   ScaffoldMessenger.of(
//                                     dialogContext,
//                                   ).showSnackBar(
//                                     SnackBar(content: Text(e.toString())),
//                                   );
//                                 }
//                               }
//                             }
//                           },
//                     child: const Text('Add'),
//                   ),
//                 ],
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   void _showAddSourceDialog(BuildContext parentContext) {
//     final controller = TextEditingController();
//     showDialog(
//       context: parentContext,
//       builder: (dialogContext) {
//         return BlocProvider.value(
//           value: parentContext.read<LeadSourceCubit>(),
//           child: BlocConsumer<LeadSourceCubit, LeadSourceState>(
//             listener: (context, state) {},
//             builder: (context, state) {
//               return AlertDialog(
//                 title: const Text('Add Lead Source'),
//                 content: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       controller: controller,
//                       decoration: const InputDecoration(
//                         hintText: 'Enter source name',
//                       ),
//                     ),
//                     if (state.isSubmitting)
//                       const Padding(
//                         padding: EdgeInsets.only(top: 8.0),
//                         child: LinearProgressIndicator(),
//                       ),
//                   ],
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(dialogContext),
//                     child: const Text('Cancel'),
//                   ),
//                   ElevatedButton(
//                     onPressed: state.isSubmitting
//                         ? null
//                         : () async {
//                             final name = controller.text.trim();
//                             if (name.isNotEmpty) {
//                               try {
//                                 await context.read<LeadSourceCubit>().addSource(
//                                   name: name,
//                                 );
//                                 if (dialogContext.mounted) {
//                                   Navigator.pop(dialogContext);
//                                 }
//                               } catch (e) {
//                                 if (dialogContext.mounted) {
//                                   ScaffoldMessenger.of(
//                                     dialogContext,
//                                   ).showSnackBar(
//                                     SnackBar(content: Text(e.toString())),
//                                   );
//                                 }
//                               }
//                             }
//                           },
//                     child: const Text('Add'),
//                   ),
//                 ],
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<AddLeadCubit, AddLeadState>(
//       listener: (context, state) {
//         if (state.status == AddLeadStatus.success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 state.successMessage ??
//                     (widget.from == 'EDIT'
//                         ? 'Lead updated successfully'
//                         : 'Lead created successfully'),
//               ),
//               backgroundColor: Colors.green,
//             ),
//           );
//           Navigator.maybePop(context, true);
//         } else if (state.status == AddLeadStatus.failure) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(state.errorMessage ?? 'Failed to create lead'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       },
//       builder: (context, state) {
//         if (state.status == AddLeadStatus.loading && !state.isSubmitting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         // Synchronization logic:
//         final categoryState = context.watch<LeadCategoryCubit>().state;
//         final sourceState = context.watch<LeadSourceCubit>().state;
//         final categories = categoryState.categories.map((c) => c.name).toList();
//         final sources = sourceState.sources.map((s) => s.name).toList();
//         final stages = state.stages.map((st) => st.name).toList();
//         final staffList = state.staffList.map((s) => s.name).toList();
//         if (staffList.isEmpty && state.assignedStaffName.isNotEmpty) {
//           staffList.add(state.assignedStaffName);
//         }

//         // Ensure current selected values exist in dropdown options to prevent runtime error
//         if (widget.from != 'EDIT') {
//           if (categories.isNotEmpty &&
//               _selectedCategory != null &&
//               !categories.contains(_selectedCategory)) {
//             _selectedCategory = null;
//           }
//           if (sources.isNotEmpty &&
//               _selectedSource != null &&
//               !sources.contains(_selectedSource)) {
//             _selectedSource = null;
//           }
//           if (stages.isNotEmpty &&
//               _selectedStage != null &&
//               !stages.contains(_selectedStage)) {
//             _selectedStage = null;
//           }
//           if (staffList.isNotEmpty &&
//               _selectedStaff != null &&
//               !staffList.contains(_selectedStaff)) {
//             _selectedStaff = null;
//           }
//         }

//         // Set defaults from state if currently null
//         _selectedStaff ??= state.assignedStaffName.isNotEmpty
//             ? state.assignedStaffName
//             : null;
//         _selectedCategory ??= state.selectedCategory;
//         _selectedSource ??= state.selectedSource;
//         _selectedStage ??= state.selectedLeadStage;
//         _selectedPriority ??= state.selectedPriority;
//         _selectedState ??= state.selectedState;

//         final bool isSaving = state.isSubmitting;

//         return Scaffold(
//           backgroundColor: const Color(0xFFF0F4F8),
//           appBar: _buildAppBar(),
//           body: SafeArea(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
//               child: Column(
//                 children: [
//                   _CustomerDetailsCard(
//                     clientNameCtrl: _clientNameCtrl,
//                     contactCtrl: _contactCtrl,
//                     whatsappCtrl: _whatsappCtrl,
//                     emailCtrl: _emailCtrl,
//                     addressCtrl: _addressCtrl,
//                     pinCtrl: _pinCtrl,
//                     selectedState: _selectedState,
//                     states: const [
//                       'Kerala',
//                       'Tamil Nadu',
//                       'Karnataka',
//                       'Maharashtra',
//                       'Delhi',
//                     ],
//                     onStateChanged: (v) {
//                       setState(() => _selectedState = v);
//                       context.read<AddLeadCubit>().selectState(v);
//                     },
//                     onContactPickerTap: () {},
//                   ),
//                   SizedBox(height: 2.h),
//                   _LeadInformationCard(
//                     selectedStaff: _selectedStaff,
//                     staffList: staffList,
//                     categories: categories,
//                     sources: sources,
//                     onStaffChanged: (v) {
//                       setState(() => _selectedStaff = v);
//                       if (v != null) {
//                         try {
//                           final matchingStaff = state.staffList.firstWhere(
//                             (s) => s.name == v,
//                           );
//                           context.read<AddLeadCubit>().selectAssignedStaff(
//                             name: matchingStaff.name,
//                             id: matchingStaff.id ?? '',
//                           );
//                         } catch (_) {
//                           context.read<AddLeadCubit>().selectAssignedStaff(
//                             name: v,
//                             id: '',
//                           );
//                         }
//                       }
//                     },
//                     selectedCategory: _selectedCategory,
//                     onCategoryChanged: (v) {
//                       setState(() => _selectedCategory = v);
//                       context.read<AddLeadCubit>().selectCategory(v);
//                     },
//                     onAddCategory: () => _showAddCategoryDialog(context),
//                     selectedSource: _selectedSource,
//                     onSourceChanged: (v) {
//                       setState(() => _selectedSource = v);
//                       context.read<AddLeadCubit>().selectSource(v);
//                     },
//                     onAddSource: () => _showAddSourceDialog(context),
//                     selectedPriority: _selectedPriority,
//                     priorities: const [
//                       'Normal',
//                       'High',
//                       'Norma',
//                       'Low',
//                       'Negative',
//                     ],
//                     onPriorityChanged: (v) {
//                       setState(() => _selectedPriority = v);
//                       context.read<AddLeadCubit>().selectPriority(v);
//                     },
//                     selectedStage: _selectedStage,
//                     stages: stages,
//                     onStageChanged: (v) {
//                       setState(() => _selectedStage = v);
//                       context.read<AddLeadCubit>().selectLeadStage(v);
//                     },
//                     remarksCtrl: _remarksCtrl,
//                   ),
//                   SizedBox(height: 2.h),
//                   if (isSaving)
//                     const Center(child: CircularProgressIndicator())
//                   else
//                     PrimaryButton(
//                       label: widget.from == 'EDIT'
//                           ? 'Update Lead'
//                           : 'Create Lead',
//                       onTap: () {
//                         if (_clientNameCtrl.text.trim().isEmpty) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('Client Name is required'),
//                             ),
//                           );
//                           return;
//                         }
//                         if (_contactCtrl.text.trim().isEmpty) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('Contact Number is required'),
//                             ),
//                           );
//                           return;
//                         }
//                         if (widget.from == 'EDIT' && widget.lead != null) {
//                           if (widget.lead?.id == null) {
//                             debugPrint('Lead ID is null');
//                             return;
//                           }

//                           if ((_selectedStaff ?? '').isEmpty) {
//                             debugPrint('Staff is empty');
//                             return;
//                           }

//                           debugPrint('_selectedState = $_selectedState');
//                           debugPrint('_selectedCategory = $_selectedCategory');
//                           debugPrint('_selectedSource = $_selectedSource');
//                           debugPrint('_selectedPriority = $_selectedPriority');
//                           debugPrint('_selectedStaff = $_selectedStaff');
//                           debugPrint('_selectedStage = $_selectedStage');
//                           debugPrint(
//                             'assignedStaffId = ${state.assignedStaffId}',
//                           );
//                           debugPrint('leadId = ${widget.lead?.id}');

//                           final updatedLead = AddLeadModel(
//                             id: widget
//                                 .lead
//                                 ?.id, // ✅ Use widget.leadData instead of _leadData
//                             clientName: _clientNameCtrl.text,
//                             contactNumber: _contactCtrl.text,
//                             contactDialCode: '+91',
//                             whatsappNumber: _whatsappCtrl.text,
//                             whatsappDialCode: '+91',
//                             email: _emailCtrl.text,
//                             address: _addressCtrl.text,
//                             pinCode: _pinCtrl.text,
//                             postOffice: '',
//                             state: _selectedState ?? widget.lead?.state ?? '',
//                             district: '',
//                             remarks: _remarksCtrl.text,
//                             leadCategory:
//                                 _selectedCategory ??
//                                 widget.lead?.leadCategory ??
//                                 '',
//                             leadSource:
//                                 _selectedSource ??
//                                 widget.lead?.leadSource ??
//                                 '',
//                             leadTag: _selectedLeadTag,
//                             priority:
//                                 _selectedPriority ??
//                                 widget.lead?.priority ??
//                                 '',
//                             assignedStaffId:
//                                 state.assignedStaffId ??
//                                 widget.lead?.assignedStaffId ??
//                                 '',
//                             assignedStaff:
//                                 _selectedStaff ??
//                                 widget.lead?.assignedStaff ??
//                                 '',
//                             leadStage:
//                                 _selectedStage ??
//                                 widget.lead?.leadStage ??
//                                 'NEW',
//                             // Preserve original fields
//                             createdBy: widget.lead!.createdBy,
//                             createdById: widget.lead!.createdById,
//                             createdAt: widget.lead!.createdAt,
//                             callResult: widget.lead!.callResult,
//                             followUpDate: widget.lead!.followUpDate,
//                             followUp: widget.lead!.followUp,
//                           );

//                           () async {
//                             final cubit = context.read<AddLeadCubit>();
//                             await cubit.updateLead(
//                               widget.lead?.id ?? '',
//                               updatedLead,
//                             );
//                             debugPrint('Lead Updated Successfully');
//                             debugPrint('Fetching Latest Leads...');
//                             await cubit.fetchLeads();
//                             debugPrint(
//                               'Lead Count: ${cubit.state.leads.length}',
//                             );
//                           }();
//                           return;
//                         }

//                         // ✅ CREATE MODE: Add new lead
//                         context.read<AddLeadCubit>().submitLead(
//                           clientName: _clientNameCtrl.text,
//                           contactNumber: _contactCtrl.text,
//                           contactDialCode: '+91',
//                           whatsappNumber: _whatsappCtrl.text,
//                           whatsappDialCode: '+91',
//                           email: _emailCtrl.text,
//                           address: _addressCtrl.text,
//                           pinCode: _pinCtrl.text,
//                           postOffice: '',
//                           remarks: _remarksCtrl.text,
//                           nextFollowUpDate: DateTime.now(),
//                         );
//                       },
//                     ),
//                   SizedBox(height: 2.h),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return PreferredSize(
//       preferredSize: Size.fromHeight(7.h),
//       child: AppBar(
//         backgroundColor: AppColors.bottomNavBlue,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.maybePop(context),
//         ),
//         // title: Text(
//         //   'Create Lead',
//         //   style: TextStyle(
//         //     color: Colors.white,
//         //     fontSize: 16.sp,
//         //     fontWeight: FontWeight.w500,
//         //   ),
//         // ),
//         title: Text(
//           widget.from == 'EDIT' ? 'Edit Lead' : 'Create Lead',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 16.sp,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         titleSpacing: 0,
//       ),
//     );
//   }
// }

// // ---------------------------------------------------------------------------
// // SECTION CARD  (reusable)
// // ---------------------------------------------------------------------------
// class CustomSectionCard extends StatelessWidget {
//   final Widget header;
//   final List<Widget> children;

//   const CustomSectionCard({
//     super.key,
//     required this.header,
//     required this.children,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: const [
//           BoxShadow(
//             color: ScreenColors.cardShadow,
//             blurRadius: 12,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           header,
//           SizedBox(height: 1.5.h),
//           ...children,
//         ],
//       ),
//     );
//   }
// }

// // ---------------------------------------------------------------------------
// // SECTION TITLE  (reusable)
// // ---------------------------------------------------------------------------
// class SectionTitle extends StatelessWidget {
//   final IconData icon;
//   final String title;

//   const SectionTitle({super.key, required this.icon, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(icon, color: AppColors.bottomNavBlue, size: 17.sp),
//         SizedBox(width: 2.w),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 16.sp,
//             fontWeight: FontWeight.bold,
//             color: ScreenColors.textPrimary,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ---------------------------------------------------------------------------
// // CUSTOM TEXT FIELD  (reusable)
// // ---------------------------------------------------------------------------
// // class CustomTextField extends StatelessWidget {
// //   final TextEditingController controller;
// //   final String hint;
// //   final IconData? prefixIcon;
// //   final bool filled;
// //   final bool isRequired;
// //   final int maxLines;
// //   final TextInputType keyboardType;
// //   final bool outlined;

// //   const CustomTextField({
// //     super.key,
// //     required this.controller,
// //     required this.hint,
// //     this.prefixIcon,
// //     this.filled = true,
// //     this.isRequired = false,
// //     this.maxLines = 1,
// //     this.keyboardType = TextInputType.text,
// //     this.outlined = false,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     final border = OutlineInputBorder(
// //       borderRadius: BorderRadius.circular(10),
// //       borderSide: BorderSide(
// //         color: outlined ? ScreenColors.borderGrey : Colors.transparent,
// //         width: outlined ? 1 : 0,
// //       ),
// //     );

// //     return TextField(
// //       controller: controller,
// //       maxLines: maxLines,
// //       keyboardType: keyboardType,
// //       style: TextStyle(fontSize: 14.sp, color: ScreenColors.textPrimary),
// //       decoration: InputDecoration(
// //         hintText: isRequired ? null : hint,
// //         label: isRequired
// //             ? RichText(
// //                 text: TextSpan(
// //                   text: hint.replaceAll(' *', ''),
// //                   style: TextStyle(
// //                     fontSize: 14.sp,
// //                     color: ScreenColors.hintGrey,
// //                   ),
// //                   children: const [
// //                     TextSpan(
// //                       text: ' *',
// //                       style: TextStyle(color: ScreenColors.requiredRed),
// //                     ),
// //                   ],
// //                 ),
// //               )
// //             : null,
// //         hintStyle: TextStyle(fontSize: 14.sp, color: ScreenColors.hintGrey),
// //         prefixIcon: prefixIcon != null
// //             ? Icon(prefixIcon, color: ScreenColors.iconGrey, size: 13.sp)
// //             : null,
// //         filled: filled,
// //         fillColor: filled && !outlined
// //             ? ScreenColors.fieldFill
// //             : Colors.transparent,
// //         contentPadding: EdgeInsets.symmetric(
// //           horizontal: 3.w,
// //           vertical: maxLines > 1 ? 1.5.h : 0,
// //         ),
// //         border: border,
// //         enabledBorder: border,
// //         focusedBorder: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(10),
// //           borderSide: const BorderSide(
// //             color: ScreenColors.bottomNvgtnBlue,
// //             width: 1.5,
// //           ),
// //         ),
// //         isDense: true,
// //       ),
// //     );
// //   }
// // }

// // ---------------------------------------------------------------------------
// // CUSTOM DROPDOWN FIELD  (reusable)
// // ---------------------------------------------------------------------------
// class _CustomDropdownField<T> extends StatelessWidget {
//   final T? value;
//   final List<T> items;
//   final String hint;
//   final String? floatingLabel;
//   final void Function(T?) onChanged;
//   final bool filled;
//   final Widget? suffixWidget;

//   const _CustomDropdownField({
//     super.key,
//     required this.value,
//     required this.items,
//     required this.hint,
//     required this.onChanged,
//     this.floatingLabel,
//     this.filled = true,
//     this.suffixWidget,
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
//             child: Row(
//               children: [
//                 // Icon(
//                 //   Icons.arrow_drop_down_circle_outlined,
//                 //   color: ScreenColors.iconGrey,
//                 //   size: 16.sp,
//                 // ),
//                 // SizedBox(width: 2.w),
//                 Text(
//                   e.toString(),
//                   style: TextStyle(
//                     fontSize: 15.sp,
//                     color: ScreenColors.textPrimary,
//                   ),
//                 ),
//               ],
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
//           suffixIconConstraints: const BoxConstraints(),
//         ),
//         child: Row(
//           children: [
//             // Icon(
//             //   Icons.arrow_drop_down_circle_outlined,
//             //   color: ScreenColors.iconGrey,
//             //   size: 16.sp,
//             // ),
//             // SizedBox(width: 2.w),
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

// // ---------------------------------------------------------------------------
// // GRADIENT SQUARE BUTTON  (reusable)
// // ---------------------------------------------------------------------------
// class GradientSquareButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//   final double size;

//   const GradientSquareButton({
//     super.key,
//     required this.icon,
//     required this.onTap,
//     this.size = 7,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: size.w,
//         height: size.w,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           color: AppColors.bottomNavBlue,
//           boxShadow: [
//             BoxShadow(
//               color: ScreenColors.gradientBlueEnd.withOpacity(0.35),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Icon(icon, color: Colors.white, size: 14.sp),
//       ),
//     );
//   }
// }

// // ---------------------------------------------------------------------------
// // GREEN CIRCULAR ADD BUTTON  (reusable)
// // ---------------------------------------------------------------------------
// class GreenAddButton extends StatelessWidget {
//   final VoidCallback onTap;

//   const GreenAddButton({super.key, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 8.w,
//         height: 8.w,
//         decoration: const BoxDecoration(
//           // color: Colors.teal,
//           color: AppColors.bottomNavBlue,
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: Color(0x3349C361),
//               blurRadius: 8,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Icon(Icons.add, color: Colors.white, size: 16.sp),
//       ),
//     );
//   }
// }

// // ---------------------------------------------------------------------------
// // PRIMARY BUTTON  (reusable)
// // ---------------------------------------------------------------------------
// class PrimaryButton extends StatelessWidget {
//   final String label;
//   final VoidCallback onTap;

//   const PrimaryButton({super.key, required this.label, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 6.h,
//       child: ElevatedButton(
//         onPressed: onTap,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.bottomNavBlue,
//           foregroundColor: Colors.white,
//           elevation: 3,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontSize: 15.sp,
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.3,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ---------------------------------------------------------------------------
// // CUSTOMER DETAILS CARD
// // ---------------------------------------------------------------------------
// class _CustomerDetailsCard extends StatelessWidget {
//   final TextEditingController clientNameCtrl;
//   final TextEditingController contactCtrl;
//   final TextEditingController whatsappCtrl;
//   final TextEditingController emailCtrl;
//   final TextEditingController addressCtrl;
//   final TextEditingController pinCtrl;
//   final String? selectedState;
//   final List<String> states;
//   final void Function(String?) onStateChanged;
//   final VoidCallback onContactPickerTap;

//   const _CustomerDetailsCard({
//     required this.clientNameCtrl,
//     required this.contactCtrl,
//     required this.whatsappCtrl,
//     required this.emailCtrl,
//     required this.addressCtrl,
//     required this.pinCtrl,
//     required this.selectedState,
//     required this.states,
//     required this.onStateChanged,
//     required this.onContactPickerTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return CustomSectionCard(
//       header: const SectionTitle(
//         icon: Icons.person_outline,
//         title: 'Customer Details',
//       ),
//       children: [
//         // Client Name + Contact Picker
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Expanded(
//               child: SizedBox(
//                 height: 6.h,
//                 child: CustomTextField(
//                   controller: clientNameCtrl,
//                   hint: 'Client Name',
//                   isRequired: true,
//                   filled: false,
//                   outlined: true,
//                   suffixIcon: Icons.person_outline,
//                   validator: (){

//                   },
//                 ),
//               ),
//             ),
//             // SizedBox(width: 2.w),
//             // GradientSquareButton(
//             //   icon: Icons.contacts_outlined,
//             //   onTap: onContactPickerTap,
//             //   size: 11,
//             // ),
//           ],
//         ),
//         SizedBox(height: 1.2.h),

//         // Contact Number (outlined)
//         SizedBox(
//           height: 6.h,
//           child: CustomTextField(
//             controller: contactCtrl,
//             hint: 'Contact Number',
//             isRequired: true,
//             filled: false,
//             outlined: true,
//             phone: true,
//             suffixIcon: Icons.phone_outlined,
//             keyboardType: TextInputType.phone,
//           ),
//         ),
//         SizedBox(height: 1.2.h),

//         // WhatsApp Number (outlined)
//         SizedBox(
//           height: 6.h,
//           child: CustomTextField(
//             controller: whatsappCtrl,
//             hint: 'Whatsapp Number',
//             filled: false,
//             outlined: true,
//             phone: true,
//             keyboardType: TextInputType.phone,
//             suffixIcon: Icons.phone_outlined,
//           ),
//         ),
//         SizedBox(height: 1.2.h),

//         // Email (filled)
//         SizedBox(
//           height: 6.h,
//           child: CustomTextField(
//             controller: emailCtrl,
//             hint: 'Email',
//             prefixIcon: Icons.email_outlined,
//             keyboardType: TextInputType.emailAddress,
//             suffixIcon: Icons.email_outlined,
//           ),
//         ),
//         SizedBox(height: 1.2.h),

//         // Address (filled, multiline)
//         CustomTextField(
//           controller: addressCtrl,
//           hint: 'Address',
//           prefixIcon: Icons.location_on_outlined,
//           maxLines: 5,
//           suffixIcon: Icons.location_on_outlined,
//           contentPadding: EdgeInsets.symmetric(
//             horizontal: 3.w,
//             vertical: 1.5.h,
//           ),
//         ),
//         SizedBox(height: 1.2.h),

//         // PIN Code (filled)
//         SizedBox(
//           height: 6.h,
//           child: CustomTextField(
//             controller: pinCtrl,
//             hint: 'PIN Code',
//             prefixIcon: Icons.pin_drop_outlined,
//             keyboardType: TextInputType.number,
//             suffixIcon: Icons.location_on_outlined,
//           ),
//         ),
//         SizedBox(height: 1.2.h),

//         // State dropdown (filled)
//         SizedBox(
//           height: 6.h,
//           child: _CustomDropdownField<String>(
//             value: selectedState,
//             items: const [
//               'Kerala',
//               'Tamil Nadu',
//               'Karnataka',
//               'Maharashtra',
//               'Delhi',
//             ],
//             hint: 'State',
//             onChanged: onStateChanged,
//             floatingLabel: 'State',
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ---------------------------------------------------------------------------
// // LEAD INFORMATION CARD
// // ---------------------------------------------------------------------------
// class _LeadInformationCard extends StatelessWidget {
//   final String? selectedStaff;
//   final List<String> staffList;
//   final void Function(String?) onStaffChanged;
//   final String? selectedCategory;
//   final List<String> categories;
//   final void Function(String?) onCategoryChanged;
//   final VoidCallback onAddCategory;
//   final String? selectedSource;
//   final List<String> sources;
//   final void Function(String?) onSourceChanged;
//   final VoidCallback onAddSource;
//   final String? selectedPriority;
//   final List<String> priorities;
//   final void Function(String?) onPriorityChanged;
//   final String? selectedStage;
//   final List<String> stages;
//   final void Function(String?) onStageChanged;
//   final TextEditingController remarksCtrl;

//   const _LeadInformationCard({
//     required this.selectedStaff,
//     required this.staffList,
//     required this.onStaffChanged,
//     required this.selectedCategory,
//     required this.categories,
//     required this.onCategoryChanged,
//     required this.onAddCategory,
//     required this.selectedSource,
//     required this.sources,
//     required this.onSourceChanged,
//     required this.onAddSource,
//     required this.selectedPriority,
//     required this.priorities,
//     required this.onPriorityChanged,
//     required this.selectedStage,
//     required this.stages,
//     required this.onStageChanged,
//     required this.remarksCtrl,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return CustomSectionCard(
//       header: const SectionTitle(
//         icon: Icons.info_outline,
//         title: 'Lead Information',
//       ),
//       children: [
//         // Assign Staff
//         SizedBox(
//           height: 6.h,
//           child: _CustomDropdownField<String>(
//             value: selectedStaff,
//             items: staffList,
//             hint: 'Assign Staff',
//             floatingLabel: 'Assign Staff',
//             onChanged: onStaffChanged,
//           ),
//         ),
//         SizedBox(height: 1.2.h),

//         // Lead Category + Add
//         _DropdownWithAdd(
//           value: selectedCategory,
//           items: categories,
//           hint: 'Lead Category',
//           floatingLabel: 'Lead Category',
//           onChanged: onCategoryChanged,
//           onAdd: onAddCategory,
//         ),
//         SizedBox(height: 1.2.h),

//         // Lead Source + Add
//         _DropdownWithAdd(
//           value: selectedSource,
//           items: sources,
//           hint: 'Lead Source',
//           floatingLabel: 'Lead Source',
//           onChanged: onSourceChanged,
//           onAdd: onAddSource,
//         ),
//         SizedBox(height: 1.2.h),

//         // Priority
//         SizedBox(
//           height: 6.h,
//           child: _CustomDropdownField<String>(
//             value: selectedPriority,
//             items: priorities,
//             hint: 'Priority',
//             floatingLabel: 'Priority',
//             onChanged: onPriorityChanged,
//           ),
//         ),
//         SizedBox(height: 1.2.h),

//         // Stages
//         SizedBox(
//           height: 6.h,
//           child: _CustomDropdownField<String>(
//             value: selectedStage,
//             items: stages,
//             hint: 'Stages',
//             floatingLabel: 'Stages',
//             onChanged: onStageChanged,
//           ),
//         ),
//         SizedBox(height: 1.2.h),

//         // Remarks
//         CustomTextField(
//           controller: remarksCtrl,
//           hint: 'Remarks',
//           prefixIcon: Icons.list_alt_outlined,
//           maxLines: 5,
//           filled: true,
//           suffixIcon: Icons.edit_document,
//           contentPadding: EdgeInsets.symmetric(
//             horizontal: 3.w,
//             vertical: 1.5.h,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ---------------------------------------------------------------------------
// // DROPDOWN WITH ADD BUTTON  (private helper)
// // ---------------------------------------------------------------------------
// class _DropdownWithAdd extends StatelessWidget {
//   final String? value;
//   final List<String> items;
//   final String hint;
//   final String? floatingLabel;
//   final void Function(String?) onChanged;
//   final VoidCallback onAdd;

//   const _DropdownWithAdd({
//     required this.value,
//     required this.items,
//     required this.hint,
//     required this.onChanged,
//     required this.onAdd,
//     this.floatingLabel,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 6.h,
//       child: Row(
//         children: [
//           Expanded(
//             child: _CustomDropdownField<String>(
//               value: value,
//               items: items,
//               hint: hint,
//               floatingLabel: floatingLabel,
//               onChanged: onChanged,
//             ),
//           ),
//           SizedBox(width: 2.w),
//           GreenAddButton(onTap: onAdd),
//         ],
//       ),
//     );
//   }
// }

// class CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hint;
//   final IconData? prefixIcon;
//   final bool filled;
//   final bool isRequired;
//   final int maxLines;
//   final TextInputType keyboardType;
//   final bool outlined;
//   final Color? fillColor;
//   final IconData? suffixIcon;
//   final double? fontSize;
//   final EdgeInsetsGeometry? contentPadding;
//   final bool? phone;
//   final bool? isLabel;
//   final String? validator;

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
//     this.fillColor,
//     this.suffixIcon,
//     this.fontSize,
//     this.contentPadding,
//     this.phone = false,
//     this.isLabel = true,
//     this.validator,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bool showOutlineBorder = outlined && !filled;

//     return TextFormField(
//       controller: controller,
//       validator: validator,
//       maxLines: maxLines,
//       style: TextStyle(
//         fontSize: fontSize ?? 15.sp,
//         color: ScreenColors.textPrimary,
//       ),
      
//       inputFormatters: phone == true
//           ? [
//               FilteringTextInputFormatter.digitsOnly,
//               LengthLimitingTextInputFormatter(10),
//             ]
//           : null,
//       decoration: InputDecoration(
        
//         filled: true,
//         // fillColor: ScreenColors.fieldFill,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(
//             color: AppColors.bottomNavBlue,
//             width: 0.1,
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(
//             color: AppColors.bottomNavBlue,
//             width: 0.1,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(
//             color: AppColors.bottomNavBlue,
//             width: 1.5,
//           ),
//         ),
//         label: isLabel == true
//             ? RichText(
//                 text: TextSpan(
//                   text: hint,
//                   style: TextStyle(
//                     fontSize: fontSize ?? 15.sp,
//                     color: ScreenColors.hintGrey,
//                   ),

//                   children: [
//                     if (isRequired == true)
//                       TextSpan(
//                         text: ' *',
//                         style: TextStyle(color: ScreenColors.requiredRed),
//                       ),
//                   ],
//                 ),
//               )
//             : null,
//         hintText: isLabel == false ? hint : null,
//         hintStyle: TextStyle(
//           fontSize: fontSize ?? 14.sp,
//           color: ScreenColors.hintGrey,
//         ),
//         prefixIcon: Icon(suffixIcon, color: ScreenColors.iconGrey, size: 17.sp),
//         isDense: true,
//         contentPadding:
//             contentPadding ??
//             EdgeInsets.symmetric(horizontal: 3.w, vertical: 0),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:odit_crm_mobile/core/theme/app_colors.dart';
import 'package:odit_crm_mobile/feature/auth/cubit/auth_cubit.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_cubit.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/lead_cubit/lead_state.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/cubit/category_cubit.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/cubit/category_state.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/cubit/source_cubit.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/cubit/cubit/source_state.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/data/lead_category_repo.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/data/lead_source_repo.dart';
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
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
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
  final nextFollowUpCtrl = TextEditingController();

  // Lead Information
  final _remarksCtrl = TextEditingController();

  // Product Info
  final _costCtrl = TextEditingController();

  // Dropdown values
  String? _selectedState;
  String? _selectedStaff;
  String? _selectedCategory;
  String? _selectedSource;
  String? _selectedPriority = 'Normal';
  String? _selectedStage;
  String? _selectedLeadTag;

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

  void _showAddCategoryDialog(BuildContext parentContext) {
    final controller = TextEditingController();
    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: parentContext.read<LeadCategoryCubit>(),
          child: BlocConsumer<LeadCategoryCubit, LeadCategoryState>(
            listener: (context, state) {},
            builder: (context, state) {
              return AlertDialog(
                title: const Text('Add Category'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Enter category name',
                      ),
                    ),
                    if (state.isSubmitting)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () async {
                            final name = controller.text.trim();
                            if (name.isNotEmpty) {
                              try {
                                await context
                                    .read<LeadCategoryCubit>()
                                    .addCategory(name: name);
                                if (dialogContext.mounted) {
                                  Navigator.pop(dialogContext);
                                }
                              } catch (e) {
                                if (dialogContext.mounted) {
                                  ScaffoldMessenger.of(dialogContext)
                                      .showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              }
                            }
                          },
                    child: const Text('Add'),
                  ),
                ],
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
      builder: (dialogContext) {
        return BlocProvider.value(
          value: parentContext.read<LeadSourceCubit>(),
          child: BlocConsumer<LeadSourceCubit, LeadSourceState>(
            listener: (context, state) {},
            builder: (context, state) {
              return AlertDialog(
                title: const Text('Add Lead Source'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Enter source name',
                      ),
                    ),
                    if (state.isSubmitting)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: LinearProgressIndicator(),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
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
                              } catch (e) {
                                if (dialogContext.mounted) {
                                  ScaffoldMessenger.of(dialogContext)
                                      .showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              }
                            }
                          },
                    child: const Text('Add'),
                  ),
                ],
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

      () async {
        final cubit = context.read<AddLeadCubit>();
        await cubit.updateLead(widget.lead?.id ?? '', updatedLead);
        debugPrint('Lead Updated Successfully');
        await cubit.fetchLeads();
        debugPrint('Lead Count: ${cubit.state.leads.length}');
      }();
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
          nextFollowUpDate: DateTime.now(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddLeadCubit, AddLeadState>(
      listener: (context, state) {
        if (state.status == AddLeadStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.successMessage ??
                    (widget.from == 'EDIT'
                        ? 'Lead updated successfully'
                        : 'Lead created successfully'),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.maybePop(context, true);
        } else if (state.status == AddLeadStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to create lead'),
              backgroundColor: Colors.red,
            ),
          );
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

        _selectedStaff ??=
            state.assignedStaffName.isNotEmpty ? state.assignedStaffName : null;
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
                padding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
                      states: const [
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
                    ),
                    SizedBox(height: 2.h),
                    _LeadInformationCard(
                      selectedStaff: _selectedStaff,
                      staffList: staffList,
                      categories: categories,
                      sources: sources,
                      onStaffChanged: (v) {
                        setState(() => _selectedStaff = v);
                        if (v != null) {
                          try {
                            final matchingStaff = state.staffList
                                .firstWhere((s) => s.name == v);
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
                      priorities: const [
                        'Normal',
                        'High',
                        'Norma',
                        'Low',
                        'Negative',
                      ],
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
class _CustomDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String hint;
  final String? floatingLabel;
  final void Function(T?) onChanged;
  final bool filled;
  final Widget? suffixWidget;

  const _CustomDropdownField({
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
              style:
                  TextStyle(fontSize: 15.sp, color: ScreenColors.textPrimary),
            ),
          );
        }).toList();
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: value != null ? floatingLabel : null,
          labelStyle:
              TextStyle(fontSize: 15.sp, color: ScreenColors.hintGrey),
          filled: filled,
          fillColor: filled ? Colors.white : Colors.transparent,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
                color: AppColors.bottomNavBlue, width: 0.1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
                color: AppColors.bottomNavBlue, width: 0.1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
                color: AppColors.bottomNavBlue, width: 1.5),
          ),
          isDense: true,
          suffixIcon: suffixWidget ??
              Icon(Icons.arrow_drop_down,
                  color: ScreenColors.iconGrey, size: 20.sp),
          suffixIconConstraints: const BoxConstraints(),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            validator: validateClientName, // ✅
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
          contentPadding:
              EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
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
            suffixIcon: Icons.location_on_outlined,
            pinCode: true,   // ✅ enables 6-digit formatter
            validator: validatePincode, // ✅
          ),
        ),
        SizedBox(height: 1.2.h),

        // State dropdown
        SizedBox(
          height: 6.h,
          child: _CustomDropdownField<String>(
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

  const _LeadInformationCard({
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
          ),
        ),
        SizedBox(height: 1.2.h),
        SizedBox(
          height: 6.h,
          child: _CustomDropdownField<String>(
            value: selectedStage,
            items: stages,
            hint: 'Stages',
            floatingLabel: 'Stages',
            onChanged: onStageChanged,
          ),
        ),
        SizedBox(height: 1.2.h),
        CustomTextField(
          controller: remarksCtrl,
          hint: 'Remarks',
          prefixIcon: Icons.list_alt_outlined,
          maxLines: 5,
          filled: true,
          suffixIcon: Icons.edit_document,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
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
  final bool? pinCode;   // ✅ new: enables 6-digit formatter for PIN
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
    this.pinCode = false,  // ✅
    this.isLabel = true,
    this.validator,        // ✅
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
              color: AppColors.bottomNavBlue, width: 0.1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: AppColors.bottomNavBlue, width: 0.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: AppColors.bottomNavBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: ScreenColors.requiredRed, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: ScreenColors.requiredRed, width: 1.5),
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
        prefixIcon:
            Icon(suffixIcon, color: ScreenColors.iconGrey, size: 17.sp),
        isDense: true,
        contentPadding: contentPadding ??
            EdgeInsets.symmetric(horizontal: 3.w, vertical: 0),
        // ✅ Error text styled to match existing design
        errorStyle: TextStyle(
          fontSize: 11.sp,
          color: ScreenColors.requiredRed,
        ),
      ),
    );
  }
}