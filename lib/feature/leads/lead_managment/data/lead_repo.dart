import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odit_crm_mobile/core/constant/firebase_constant.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/activity_model.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/add_lead_model.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/dashboard_count_model.dart';

// abstract class IAddLeadRepository {
//   Future<String> addLead(AddLeadModel lead);
//   Future<List<AddLeadModel>> fetchLeads({
//     required String staffId,
//     required String role,
//   });
//   Future<List<AddLeadModel>> fetchDashboardLeads({
//     required String staffId,
//     required String role,
//     required String fromCard,
//     required DateTime selectedDate,
//     DateTime? toDate,
//   });
//   Future<void> updateLead(String id, AddLeadModel lead);
//   Future<void> deleteLead(String id);
//   Future<void> moveToDeleted(AddLeadModel lead);
//   Future<List<AddLeadModel>> fetchDeletedLeads();
//   Future<String> restoreLead(AddLeadModel lead);
//   Future<void> permanentlyDeleteLead(String id);
//   Future<void> assignStaff(String leadId, String staffId, String staffName);
//   Future<AddLeadModel> getLeadById(String leadId);
//   Future<void> deleteFollowUp({
//     required String leadId,
//     required String followUpId,
//     required String changedByName,
//     required String changedById,
//     required String leadName,
//     required String leadPhone,
//   });
//   Future<void> addFollowUp(
//     String leadId,
//     FollowUpModel followUp, {
//     String? previousStage, // pass current lead's stage before update
//     String? previousCategory,
//     String? previousPriority,
//     String changedByName = '',
//     String changedById = '',
//     String leadName = '',
//     String leadPhone = '',
//   });
//   Future<DashboardCountModel> fetchLeadCounts({
//     required String staffId,
//     required DateTime selectedDate,
//     required String role,
//     bool forceStaffFilter = false,
//   });
//   Future<void> transferLead(
//     String leadId,
//     TransferDetails transfer, {
//     required String changedByName,
//     required String changedById,
//   });
//   Future<void> _logActivity(String leadId, ActivityModel activity);
//   Future<void> logLeadCreated({
//     required String leadId,
//     required String createdByName,
//     required String createdById,
//     required String assignedTo,
//     required String leadStage,
//     required String priority,
//     required String leadCategory,
//   });
//   Future<void> logLeadUpdated({
//     required String leadId,
//     required String changedByName,
//     required String changedById,
//     required AddLeadModel previous,
//     required AddLeadModel updated,
//   });
//   Future<List<LeadStaffHandler>> getLeadHandledStaffs(AddLeadModel lead);

//   Future<Map<String, int>> fetchLeadCountsByCategory({
//     required String staffId,
//     required String role,
//     required DateTime selectedDate,
//     DateTime? toDate,
//   });
//   Future<List<LeadCategoryTableRow>> fetchLeadCategoryTableRows({
//     required String staffId,
//     required String role,
//     required DateTime selectedDate,
//     DateTime? toDate,
//   });
//   Future<Map<String, int>> fetchCallStatusCounts({
//     required String staffId,
//     required String role,
//     DateTime? selectedDate,
//     DateTime? toDate,
//   });
//   Future<bool> isContactNumberExists(String contactNumber);
// }

// class AddLeadRepository implements IAddLeadRepository {
//   final FirebaseFirestore _firestore;

//   AddLeadRepository({FirebaseFirestore? firestore})
//     : _firestore = firestore ?? FirebaseFirestore.instance;

//   CollectionReference<Map<String, dynamic>> get _collection =>
//       FirestorePath.companyCollection('LEADS');
//   CollectionReference<Map<String, dynamic>> get _deletedCollection =>
//       FirestorePath.companyCollection('DELETED_LEADS');

//   String _generateDateId(String prefix) {
//     final now = DateTime.now();
//     final datePart = DateFormat('yyyyMMdd').format(now);
//     final timePart = DateFormat('HHmmss').format(now);
//     final ms =
//         now.millisecondsSinceEpoch % 1000; // last 3 digits for uniqueness
//     final id = now.millisecondsSinceEpoch.toString();
//     return '$prefix-$datePart-$id';
//   }

//   @override
//   Future<String> addLead(AddLeadModel lead) async {
//     if (lead.clientName.trim().isEmpty) {
//       throw ArgumentError('Client name cannot be empty.');
//     }
//     if (lead.contactNumber.trim().isEmpty) {
//       throw ArgumentError('Contact number cannot be empty.');
//     }

//     final String id = _generateDateId('LEAD');
//     await _collection.doc(id).set(lead.toFirestore());
//     log('[AddLeadRepository] Lead added with ID: $id');

//     return id;
//   }

//   @override
//   Future<List<AddLeadModel>> fetchLeads({
//     required String staffId,
//     required String role,
//   }) async {
//     try {
//       Query<Map<String, dynamic>> query = _collection;

//       if (role.toLowerCase() != 'admin') {
//         query = query.where('assignedStaffId', isEqualTo: staffId);
//       }

//       final snap = await query.orderBy('createdAt', descending: true).get();

//       // return snap.docs
//       //     .map((d) => AddLeadModel.fromFirestore(d.data(), d.id))
//       //     .toList();
//       /// FETCH LEADS + FOLLOWUPS
//       final List<AddLeadModel> allLeads = await Future.wait(
//         snap.docs.map((leadDoc) async {
//           /// MAIN LEAD
//           final lead = AddLeadModel.fromFirestore(leadDoc.data(), leadDoc.id);

//           /// FETCH FOLLOWUP SUBCOLLECTION
//           final followUpSnap = await _collection
//               .doc(leadDoc.id)
//               .collection('FOLLOW_UPS')
//               .orderBy('createdAt', descending: true)
//               .get();

//           /// CONVERT FOLLOWUPS
//           final followUps = followUpSnap.docs.map((fupDoc) {
//             return FollowUpModel.fromFirestore(fupDoc.data(), fupDoc.id);
//           }).toList();

//           /// RETURN LEAD WITH FOLLOWUPS
//           return lead.copyWith(followUp: followUps);
//         }),
//       );
//       return allLeads;
//     } on FirebaseException catch (e) {
//       debugPrint('[fetchLeads] Firebase error: ${e.code} — ${e.message}');
//       rethrow;
//     } catch (e, st) {
//       debugPrint('[fetchLeads] Unexpected error: $e\n$st');
//       rethrow;
//     }
//   }

//   Future<List<AddLeadModel>> fetchDashboardLeadsOld({
//     required String staffId,
//     required String role,
//     required String fromCard,
//     required DateTime selectedDate,
//   }) async {
//     Query<Map<String, dynamic>> query = _collection;

//     /// ---------------- ROLE FILTER ----------------
//     /// Admin -> all leads
//     /// Staff -> only assigned leads

//     if (role.toLowerCase() != 'admin') {
//       query = query.where('assignedStaffId', isEqualTo: staffId);
//     }

//     log("ddddddddddddddddddd");

//     try {
//       final snap = await query.orderBy('createdAt', descending: true).get();

//       final allLeads = snap.docs
//           .map((d) => AddLeadModel.fromFirestore(d.data(), d.id))
//           .toList();

//       /// ---------------- DATE FILTER HELPER ----------------

//       bool isSameDay(DateTime? date) {
//         if (date == null) return false;

//         return date.year == selectedDate.year &&
//             date.month == selectedDate.month &&
//             date.day == selectedDate.day;
//       }

//       /// ---------------- CARD FILTER ----------------

//       switch (fromCard.toUpperCase()) {
//         /// NEW LEADS
//         case 'NEW':
//           return allLeads.where((lead) {
//             return isSameDay(lead.createdAt);
//           }).toList();

//         /// FOLLOWUP LEADS
//         case 'FOLLOWUP':
//           return allLeads.where((lead) {
//             return isSameDay(lead.followUpDate);
//           }).toList();

//         /// CLOSED LEADS
//         case 'CLOSED':
//           return allLeads.where((lead) {
//             return lead.leadStage.toUpperCase() == 'CLOSED';
//           }).toList();

//         /// TOTAL CALLED
//         case 'TOTAL':
//           return allLeads.where((lead) {
//             return isSameDay(lead.calledDate);
//           }).toList();

//         /// MISSED / REJECTED
//         case 'MISSED':
//           return allLeads.where((lead) {
//             return lead.leadStage.toUpperCase() == 'REJECTED';
//           }).toList();

//         /// TRANSFERRED LEADS
//         case 'TRANSFERRED':
//           return allLeads.where((lead) {
//             if (lead.transferLeads == null || lead.transferLeads!.isEmpty) {
//               return false;
//             }

//             return lead.transferLeads!.any((item) {
//               final transferredTime = item.transferTime;
//               // item['transferredTime'];

//               if (transferredTime == null) {
//                 return false;
//               }

//               DateTime transferDate;

//               // if (transferredTime is Timestamp) {
//               //
//               //   transferDate = transferredTime.toDate();
//               //
//               // } else
//               transferDate = transferredTime;

//               return isSameDay(transferDate);
//             });
//           }).toList();

//         default:
//           return allLeads;
//       }
//     } catch (e) {
//       log("error in fetchDashboardLeads ::: $e");
//     }
//     return [];
//   }

//   @override
//   Future<List<AddLeadModel>> fetchDashboardLeads({
//     required String staffId,
//     required String role,
//     required String fromCard,
//     required DateTime selectedDate,
//     DateTime? toDate,
//   }) async {
//     Query<Map<String, dynamic>> query = _collection;

//     /// ROLE FILTER
//     if (role.toLowerCase() != 'admin') {
//       query = query.where('assignedStaffId', isEqualTo: staffId);
//     }

//     try {
//       final snap = await query.orderBy('createdAt', descending: true).get();

//       /// FETCH LEADS + FOLLOWUPS
//       final List<AddLeadModel> allLeads = await Future.wait(
//         snap.docs.map((leadDoc) async {
//           /// MAIN LEAD
//           final lead = AddLeadModel.fromFirestore(leadDoc.data(), leadDoc.id);

//           /// FETCH FOLLOWUP SUBCOLLECTION
//           final followUpSnap = await _collection
//               .doc(leadDoc.id)
//               .collection('FOLLOW_UPS')
//               .orderBy('createdAt', descending: true)
//               .get();

//           /// CONVERT FOLLOWUPS
//           final followUps = followUpSnap.docs.map((fupDoc) {
//             return FollowUpModel.fromFirestore(fupDoc.data(), fupDoc.id);
//           }).toList();

//           /// RETURN LEAD WITH FOLLOWUPS
//           return lead.copyWith(followUp: followUps);
//         }),
//       );

//       /// DATE FILTER HELPER
//       // bool isSameDay(DateTime? date) {
//       //   if (date == null) return false;

//       //   return date.year == selectedDate.year &&
//       //       date.month == selectedDate.month &&
//       //       date.day == selectedDate.day;
//       // }

//       final effectiveTo = toDate ?? selectedDate;

//       final fromDay = DateTime(
//         selectedDate.year,
//         selectedDate.month,
//         selectedDate.day,
//       );
//       final toDay = DateTime(
//         effectiveTo.year,
//         effectiveTo.month,
//         effectiveTo.day,
//         23,
//         59,
//         59,
//       );

//       bool isInRange(DateTime? date) {
//         if (date == null) return false;
//         return !date.isBefore(fromDay) && !date.isAfter(toDay);
//       }

//       bool isbeforeFromDay(DateTime? date) {
//         if (date == null) return false;
//         return date.isBefore(fromDay);
//       }

//       bool isAfterToDay(DateTime? date) {
//         if (date == null) return false;
//         return date.isAfter(toDay);
//       }

//       /// CARD FILTER
//       switch (fromCard.toUpperCase()) {
//         /// NEW LEADS
//         case 'NEW':
//           return allLeads.where((lead) {
//             return isInRange(lead.createdAt) &&
//                 lead.leadStage.toUpperCase() == 'NEW' &&
//                 // lead.followUp!.isEmpty;
//                 (lead.followUp == null || lead.followUp!.isEmpty);
//           }).toList();

//         /// FOLLOWUP LEADS
//         case 'FOLLOWUP':
//           return allLeads.where((lead) {
//             return isInRange(lead.followUpDate) &&
//                 lead.leadStage.toUpperCase() == 'FOLLOWUP'; // &&
//             // lead.leadStage.toUpperCase() != 'CLOSED'&&
//             // lead.leadStage.toUpperCase() != 'REJECTED'&& ;
//           }).toList();

//         /// CLOSED LEADS
//         case 'CLOSED':
//           return allLeads.where((lead) {
//             return lead.leadStage.toUpperCase() == 'CLOSED' &&
//                 isInRange(lead.calledDate);
//           }).toList();

//         /// TOTAL CALLED
//         case 'TOTAL':
//           return allLeads.where((lead) {
//             return isInRange(lead.calledDate);
//           }).toList();

//         /// MISSED / REJECTED
//         case 'MISSED':
//           return allLeads.where((lead) {
//             return (lead.leadStage.toUpperCase() == 'FOLLOWUP' ||
//                     lead.leadStage.toUpperCase() == 'NEW') &&
//                 isbeforeFromDay(lead.followUpDate);
//           }).toList();

//         /// TRANSFERRED
//         case 'TRANSFERRED':
//           return allLeads.where((lead) {
//             if (lead.transferLeads == null || lead.transferLeads!.isEmpty) {
//               return false;
//             }

//             return lead.transferLeads!.any((item) {
//               final transferredTime = item.transferTime;

//               if (transferredTime == null) {
//                 return false;
//               }

//               return isInRange(transferredTime);
//             });
//           }).toList();

//         default:
//           return allLeads;
//       }
//     } catch (e) {
//       log("error in fetchDashboardLeads ::: $e");

//       return [];
//     }
//   }

//   @override
//   Future<void> updateLead(String id, AddLeadModel lead) async {
//     if (id.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');

//     //    final data = lead.toFirestore();
//     // data.remove('createdAt'); // ✅ prevent createdAt from being overwritten
//     // data['updatedAt'] = FieldValue.serverTimestamp();

//     await _collection.doc(id).update(lead.toUpdateMap());
//   }

//   @override
//   Future<void> deleteLead(String id) async {
//     if (id.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');
//     await _collection.doc(id).delete();
//   }

//   @override
//   Future<void> moveToDeleted(AddLeadModel lead) async {
//     assert(lead.id != null, 'ID must not be null');

//     final deletedLead = lead.copyWith(deletedAt: DateTime.now());

//     await _deletedCollection.add(deletedLead.toFirestore());
//     await _collection.doc(lead.id).delete();

//     log('[StaffRepository] Staff moved to DELETED_STAFF: ${lead.id}');
//   }

//   @override
//   Future<String> restoreLead(AddLeadModel lead) async {
//     if (lead.clientName.trim().isEmpty) {
//       throw ArgumentError('Client name cannot be empty.');
//     }
//     if (lead.contactNumber.trim().isEmpty) {
//       throw ArgumentError('Contact number cannot be empty.');
//     }
//     final doc = await _collection.add(lead.toFirestore());
//     await _deletedCollection.doc(lead.id).delete();
//     return doc.id;
//   }

//   @override
//   Future<List<AddLeadModel>> fetchDeletedLeads() async {
//     final snap = await _deletedCollection
//         .orderBy('deletedAt', descending: true)
//         .get();
//     return snap.docs
//         .map((d) => AddLeadModel.fromFirestore(d.data(), d.id))
//         .toList();
//   }

//   @override
//   Future<void> permanentlyDeleteLead(String id) async {
//     await _deletedCollection.doc(id).delete();
//     log('[AddLeadRepository] Lead permanently deleted: $id');
//   }

//   @override
//   Future<void> assignStaff(
//     String leadId,
//     String staffId,
//     String staffName,
//   ) async {
//     if (leadId.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');
//     await _collection.doc(leadId).update({
//       'assignedStaffId': staffId,
//       'assignedStaff': staffName,
//     });
//     log('[AddLeadRepository] Staff assigned to lead: $leadId → $staffId');
//   }

 

//   // @override
//   // Future<void> addFollowUp(
//   //   String leadId,
//   //   FollowUpModel followUp, {
//   //   String? previousStage, // pass current lead's stage before update
//   //   String? previousCategory,
//   //   String? previousPriority,
//   //   String changedByName = '',
//   //   String changedById = '',
//   //   String leadName = '',
//   //   String leadPhone = '',
//   // }) async {
//   //   if (leadId.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');

//   //   final batch = FirebaseFirestore.instance.batch();
//   //   final activityRef = _collection.doc(leadId).collection('ACTIVITIES');

//   //   // 1. Write the follow-up document
//   //   final String followUpId = followUp.id ?? _generateDateId('FUP');
//   //   final fupRef = _collection
//   //       .doc(leadId)
//   //       .collection('FOLLOW_UPS')
//   //       .doc(followUpId);
//   //   batch.set(fupRef, followUp.toFirestore(), SetOptions(merge: true));

//   //   // 2. Update lead document
//   //   final leadRef = _collection.doc(leadId);
//   //   // batch.update(leadRef, {
//   //   //   'leadStage': followUp.leadStage,
//   //   //   'priority': followUp.priority,
//   //   //   'leadCategory': followUp.leadCategory,
//   //   //   'nextFollowUpDate': followUp.nextFollowUpDate,
//   //   //   'lastCalledDate': followUp.calledDate,
//   //   //   'callResult': followUp.calledStatus,
//   //   //   'leadTag': followUp.leadTag,
//   //   //   'updatedAt': FieldValue.serverTimestamp(),
//   //   //   // 'remarks' : followUp.remarks,
//   //   // });
//   //   final Map<String, dynamic> leadUpdates = {
//   //     'leadStage': followUp.leadStage,
//   //     'priority': followUp.priority,
//   //     'leadCategory': followUp.leadCategory,
//   //     'nextFollowUpDate': followUp.nextFollowUpDate,
//   //     'lastCalledDate': followUp.calledDate,
//   //     'callResult': followUp.calledStatus,
//   //     'leadTag': followUp.leadTag,
//   //     'updatedAt': FieldValue.serverTimestamp(),
//   //     'hasFollowUp': true,
//   //   };
//   //   if ((followUp.adress ?? '').isNotEmpty) {
//   //     leadUpdates['address'] = followUp.adress;
//   //   }
//   //   if ((followUp.email ?? '').isNotEmpty) {
//   //     leadUpdates['email'] = followUp.email;
//   //   }
//   //   if ((followUp.remarks ?? '').isNotEmpty) {
//   //     leadUpdates['remarks'] = followUp.remarks;
//   //   }
//   //   batch.update(leadRef, leadUpdates);

//   //   final now = DateTime.now();

//   //   // Helper to add an activity doc in the batch
//   //   void logActivity(ActivityModel activity) {
//   //     batch.set(activityRef.doc(), activity.toFirestore());
//   //   }

//   //   // 3. Always log the follow-up added activity
//   //   logActivity(
//   //     ActivityModel(
//   //       id: '',
//   //       type: ActivityType.followupAdded,
//   //       changedBy: changedByName,
//   //       changedById: changedById,
//   //       changedAt: now,
//   //       previousValue: followUp.calledStatus,
//   //       leadId: leadId, // ← add
//   //       leadName: leadName, // ← add
//   //       leadPhone: leadPhone, // ← add
//   //       newValue: DateFormat(
//   //         'dd-MM-yyyy HH:mm',
//   //       ).format(followUp.nextFollowUpDate),
//   //       description:
//   //           'Follow-up added. Call status: ${followUp.calledStatus}. '
//   //           'Next follow-up scheduled to '
//   //           '${DateFormat('dd-MM-yyyy HH:mm').format(followUp.nextFollowUpDate)}.',
//   //     ),
//   //   );

//   //   // 4. Log status change only if it actually changed
//   //   if (previousStage != null &&
//   //       previousStage.isNotEmpty &&
//   //       previousStage != followUp.leadStage) {
//   //     logActivity(
//   //       ActivityModel(
//   //         id: '',
//   //         type: ActivityType.statusChanged,
//   //         changedBy: changedByName,
//   //         changedById: changedById,
//   //         changedAt: now,
//   //         previousValue: previousStage,
//   //         newValue: followUp.leadStage,
//   //         description:
//   //             'Status changed from $previousStage to ${followUp.leadStage}.',
//   //       ),
//   //     );
//   //   }

//   //   // 5. Log category change only if it changed
//   //   if (previousCategory != null &&
//   //       previousCategory.isNotEmpty &&
//   //       previousCategory != followUp.leadCategory &&
//   //       followUp.leadCategory.isNotEmpty) {
//   //     logActivity(
//   //       ActivityModel(
//   //         id: '',
//   //         type: ActivityType.categoryChanged,
//   //         changedBy: changedByName,
//   //         changedById: changedById,
//   //         changedAt: now,
//   //         previousValue: previousCategory,
//   //         newValue: followUp.leadCategory,
//   //         description:
//   //             'Lead category updated from $previousCategory to ${followUp.leadCategory}.',
//   //       ),
//   //     );
//   //   }

//   //   // 6. Log priority change only if it changed
//   //   if (previousPriority != null &&
//   //       previousPriority.isNotEmpty &&
//   //       previousPriority != followUp.priority &&
//   //       followUp.priority.isNotEmpty) {
//   //     logActivity(
//   //       ActivityModel(
//   //         id: '',
//   //         type: ActivityType.priorityChanged,
//   //         changedBy: changedByName,
//   //         changedById: changedById,
//   //         changedAt: now,
//   //         previousValue: previousPriority,
//   //         newValue: followUp.priority,
//   //         description:
//   //             'Priority updated from $previousPriority to ${followUp.priority}.',
//   //       ),
//   //     );
//   //   }

//   //   await batch.commit();
//   //   log('[AddLeadRepository] FollowUp + activities written for lead: $leadId');
//   // }

//   // ✅ FIXED: AddLeadRepository.addFollowUp() with full debug logging
// // Replace the existing addFollowUp() method in AddLeadRepository with this:

// @override
// Future<void> addFollowUp(
//   String leadId,
//   FollowUpModel followUp, {
//   String? previousStage,
//   String? previousCategory,
//   String? previousPriority,
//   String changedByName = '',
//   String changedById = '',
//   String leadName = '',
//   String leadPhone = '',
// }) async {
//   debugPrint('=== REPOSITORY addFollowUp START ===');
//   debugPrint('leadId: $leadId');
//   debugPrint('followUpId: ${followUp.id}');
//   debugPrint('followUpData: ${followUp.toFirestore()}');

//   if (leadId.trim().isEmpty) {
//     debugPrint('❌ VALIDATION ERROR: leadId is empty');
//     throw ArgumentError('Lead ID cannot be empty.');
//   }

//   try {
//     final batch = FirebaseFirestore.instance.batch();
//     final activityRef = _collection.doc(leadId).collection('ACTIVITIES');

//     // STEP 1: Write the follow-up document
//     debugPrint('📌 STEP 1: Writing follow-up to FOLLOW_UPS subcollection...');
//     final String followUpId = followUp.id ?? _generateDateId('FUP');
//     final fupRef = _collection
//         .doc(leadId)
//         .collection('FOLLOW_UPS')
//         .doc(followUpId);

//     debugPrint('   - Path: LEADS/$leadId/FOLLOW_UPS/$followUpId');
//     debugPrint('   - Data keys: ${followUp.toFirestore().keys.join(', ')}');

//     batch.set(fupRef, followUp.toFirestore(), SetOptions(merge: true));
//     debugPrint('✅ Follow-up batch.set() added');

//     // STEP 2: Update lead document
//     debugPrint('📌 STEP 2: Updating parent lead document...');
//     final leadRef = _collection.doc(leadId);

//     final Map<String, dynamic> leadUpdates = {
//       'leadStage': followUp.leadStage,
//       'priority': followUp.priority,
//       'leadCategory': followUp.leadCategory,
//       'nextFollowUpDate': followUp.nextFollowUpDate,
//       'lastCalledDate': followUp.calledDate,
//       'callResult': followUp.calledStatus,
//       'leadTag': followUp.leadTag,
//       'updatedAt': FieldValue.serverTimestamp(),
//       'hasFollowUp': true,
//     };

//     if ((followUp.adress ?? '').isNotEmpty) {
//       leadUpdates['address'] = followUp.adress;
//     }
//     if ((followUp.email ?? '').isNotEmpty) {
//       leadUpdates['email'] = followUp.email;
//     }
//     if ((followUp.remarks ?? '').isNotEmpty) {
//       leadUpdates['remarks'] = followUp.remarks;
//     }

//     debugPrint('   - Updating fields: ${leadUpdates.keys.join(', ')}');
//     batch.update(leadRef, leadUpdates);
//     debugPrint('✅ Lead batch.update() added');

//     // STEP 3: Log activities
//     debugPrint('📌 STEP 3: Logging activities...');
//     final now = DateTime.now();

//     void logActivity(ActivityModel activity) {
//       batch.set(activityRef.doc(), activity.toFirestore());
//       debugPrint('   - Activity logged: ${activity.type}');
//     }

//     // Always log the follow-up added activity
//     logActivity(
//       ActivityModel(
//         id: '',
//         type: ActivityType.followupAdded,
//         changedBy: changedByName,
//         changedById: changedById,
//         changedAt: now,
//         previousValue: followUp.calledStatus,
//         leadId: leadId,
//         leadName: leadName,
//         leadPhone: leadPhone,
//         newValue: DateFormat('dd-MM-yyyy HH:mm')
//             .format(followUp.nextFollowUpDate),
//         description:
//             'Follow-up added. Call status: ${followUp.calledStatus}. '
//             'Next follow-up scheduled to '
//             '${DateFormat('dd-MM-yyyy HH:mm').format(followUp.nextFollowUpDate)}.',
//       ),
//     );

//     // Log status change if it changed
//     if (previousStage != null &&
//         previousStage.isNotEmpty &&
//         previousStage != followUp.leadStage) {
//       logActivity(
//         ActivityModel(
//           id: '',
//           type: ActivityType.statusChanged,
//           changedBy: changedByName,
//           changedById: changedById,
//           changedAt: now,
//           previousValue: previousStage,
//           newValue: followUp.leadStage,
//           description:
//               'Status changed from $previousStage to ${followUp.leadStage}.',
//         ),
//       );
//     }

//     // Log category change if it changed
//     if (previousCategory != null &&
//         previousCategory.isNotEmpty &&
//         previousCategory != followUp.leadCategory &&
//         followUp.leadCategory.isNotEmpty) {
//       logActivity(
//         ActivityModel(
//           id: '',
//           type: ActivityType.categoryChanged,
//           changedBy: changedByName,
//           changedById: changedById,
//           changedAt: now,
//           previousValue: previousCategory,
//           newValue: followUp.leadCategory,
//           description:
//               'Lead category updated from $previousCategory to ${followUp.leadCategory}.',
//         ),
//       );
//     }

//     // Log priority change if it changed
//     if (previousPriority != null &&
//         previousPriority.isNotEmpty &&
//         previousPriority != followUp.priority &&
//         followUp.priority.isNotEmpty) {
//       logActivity(
//         ActivityModel(
//           id: '',
//           type: ActivityType.priorityChanged,
//           changedBy: changedByName,
//           changedById: changedById,
//           changedAt: now,
//           previousValue: previousPriority,
//           newValue: followUp.priority,
//           description:
//               'Priority updated from $previousPriority to ${followUp.priority}.',
//         ),
//       );
//     }

//     // STEP 4: Commit batch
//     debugPrint('📌 STEP 4: Committing batch write...');
//     await batch.commit();
//     debugPrint('✅ Batch committed successfully!');

//     log('[AddLeadRepository] FollowUp + activities written for lead: $leadId');
//   } catch (e, st) {
//     debugPrint('❌ CRITICAL ERROR in addFollowUp: $e');
//     debugPrint('Stack: $st');
//     rethrow;
//   }
// }

//   @override
//   Future<void> transferLead(
//     String leadId,
//     TransferDetails transfer, {
//     required String changedByName,
//     required String changedById,
//   }) async {
//     if (leadId.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');

//     final batch = FirebaseFirestore.instance.batch();
//     final String transferId = _generateDateId('TRF');

//     // 1. Add to TRANSFER_LEADS subcollection
//     final transferRef = _collection
//         .doc(leadId)
//         .collection('TRANSFER_LEADS')
//         .doc(transferId);
//     batch.set(transferRef, transfer.toFirestore());

//     // 2. Update the lead document
//     final leadRef = _collection.doc(leadId);
//     batch.update(leadRef, {
//       'assignedStaff': transfer.toStaff,
//       'assignedStaffId': transfer.toStaffId,
//       'leadStage': 'TRANSFERRED',
//       'transferLeads': FieldValue.arrayUnion([transfer.toFirestore()]),
//     });

//     // 3. Log the transfer activity
//     final activityRef = _collection.doc(leadId).collection('ACTIVITIES').doc();
//     batch.set(
//       activityRef,
//       ActivityModel(
//         id: '',
//         type: ActivityType.staffAssigned,
//         changedBy: changedByName,
//         changedById: changedById,
//         changedAt: DateTime.now(),
//         previousValue: transfer.fromStaff,
//         newValue: transfer.toStaff,
//         description:
//             'Lead transferred from ${transfer.fromStaff} to ${transfer.toStaff}.',
//       ).toFirestore(),
//     );

//     await batch.commit();
//     log('[AddLeadRepository] Lead transferred: $leadId → ${transfer.toStaff}');
//   }

//   // Future<void> transferLead(String leadId, TransferDetails transfer) async {
//   //   if (leadId.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');
//   //
//   //   final String transferId = _generateDateId('TRF');
//   //
//   //   // ── Add to subcollection ──────────────────────────────────────────────
//   //   await _collection
//   //       .doc(leadId)
//   //       .collection('TRANSFER_LEADS')
//   //       .doc(transferId)
//   //       .set(transfer.toFirestore());
//   //
//   //   // ── Update the lead document ──────────────────────────────────────────
//   //   await _collection.doc(leadId).update({
//   //     'assignedStaff':   transfer.toStaff,
//   //     'assignedStaffId': transfer.toStaffId,
//   //     'transferLeads': FieldValue.arrayUnion([transfer.toFirestore()]),
//   //   });
//   //
//   //   log('[AddLeadRepository] Lead transferred: $leadId → ${transfer.toStaff}');
//   // }

//   bool _isSameDay(DateTime d1, DateTime d2) {
//     return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
//   }

//   bool _isBeforeDay(DateTime d1, DateTime d2) {
//     final day1 = DateTime(d1.year, d1.month, d1.day);
//     final day2 = DateTime(d2.year, d2.month, d2.day);
//     return day1.isBefore(day2);
//   }

//   //   @override
//   //   Future<DashboardCountModel> fetchLeadCounts({
//   //     required String staffId,
//   //     required DateTime selectedDate,
//   //     required String role,
//   //     bool forceStaffFilter = false, // ← new flag
//   //   }) async {
//   //     final startOfDay = DateTime(
//   //       selectedDate.year,
//   //       selectedDate.month,
//   //       selectedDate.day,
//   //     );
//   //     final endOfDay = DateTime(
//   //       selectedDate.year,
//   //       selectedDate.month,
//   //       selectedDate.day,
//   //       23,
//   //       59,
//   //       59,
//   //     );

//   //     // If forceStaffFilter=true (staff profile screen), ALWAYS filter by staffId
//   //     // regardless of role. Otherwise use the original admin/staff logic.
//   //     Query<Map<String, dynamic>> query = _collection;
//   //     if (forceStaffFilter && staffId.isNotEmpty) {
//   //       query = query.where('assignedStaffId', isEqualTo: staffId);
//   //       log(
//   //         '[fetchLeadCounts] Staff profile mode: filtering by staffId=$staffId',
//   //       );
//   //     } else if (role.toLowerCase() != 'admin') {
//   //       query = query.where('assignedStaffId', isEqualTo: staffId);
//   //       log('[fetchLeadCounts] Staff mode: filtering by staffId=$staffId');
//   //     } else {
//   //       log('[fetchLeadCounts] Admin dashboard mode: fetching all leads');
//   //     }

//   //     final snap = await query.get();
//   //     log('[fetchLeadCounts] Total docs fetched: ${snap.docs.length}');

//   //     int newLeadCount = 0;
//   //     int followUpCount = 0;
//   //     int closedLeadCount = 0;
//   //     int totalCalledCount = 0;
//   //     int missedLeadCount = 0;
//   //     int transferredCount = 0;

//   //     for (final doc in snap.docs) {
//   //       final data = doc.data();
//   //       final leadStage = (data['leadStage'] ?? '').toString().toUpperCase();
//   //       final followUps =
//   //           (await doc.reference.collection('FOLLOW_UPS').get()).docs;

//   //       // NEW
//   //       final createdAt = data['createdAt'];
//   //       if (createdAt != null) {
//   //         final createdDate = (createdAt as Timestamp).toDate();
//   //         // if (_isSameDay(createdDate, selectedDate) &&
//   //         //     leadStage == 'NEW' &&
//   //         //     followUps.isEmpty) {
//   //         //   newLeadCount++;
//   //         // }
//   // //         if (leadStage == 'NEW' && createdDate != null && _isSameDay(createdDate, selectedDate)) {
//   // //   // only fetch follow-ups when the lead is actually a candidate
//   // //   final followUps = (await doc.reference.collection('FOLLOW_UPS').get()).docs;
//   // //   if (followUps.isEmpty) newLeadCount++;
//   // // }
//   // final hasFollowUp = data['hasFollowUp'] as bool? ?? false;
//   // if (leadStage == 'NEW' && _isSameDay(createdDate, selectedDate)) {
//   //   if (!hasFollowUp) newLeadCount++;
//   // }
//   //       }

//   //       // FOLLOWUP
//   //       final nextFollowUpDate = data['nextFollowUpDate'];
//   //       if (nextFollowUpDate != null) {
//   //         final followDate = (nextFollowUpDate as Timestamp).toDate();
//   //         if (_isSameDay(followDate, selectedDate) &&
//   //             leadStage != 'CLOSED' &&
//   //             leadStage != 'REJECTED' &&
//   //             leadStage != 'NEW') {
//   //           followUpCount++;
//   //         }
//   //       }

//   //       // final calledDate = data['lastCalledDate'] ;
//   //       // CLOSED
//   //       final lastCalledDate = data['lastCalledDate'];
//   //       if (lastCalledDate != null) {
//   //         final calledDate = (lastCalledDate as Timestamp).toDate();
//   //         if (leadStage == 'CLOSED' && _isSameDay(calledDate, selectedDate)) {
//   //           closedLeadCount++;
//   //         }
//   //       } else {
//   //         if (createdAt != null) {
//   //           final createdDate = (createdAt as Timestamp).toDate();
//   //           if (leadStage == 'CLOSED' && _isSameDay(createdDate, selectedDate)) {
//   //             closedLeadCount++;
//   //           }
//   //         }
//   //       }
//   //       //&& _isSameDay(calledDate, selectedDate)) closedLeadCount++;

//   //       // MISSED / REJECTED
//   //       if (nextFollowUpDate != null) {
//   //         final followDate = (nextFollowUpDate as Timestamp).toDate();
//   //         if ((leadStage == 'FOLLOWUP' || leadStage == 'NEW') &&
//   //             _isBeforeDay(followDate, selectedDate)) {
//   //           missedLeadCount++;
//   //         }
//   //       }

//   //       // TOTAL CALLED
//   //       // final lastCalledDate = data['lastCalledDate'];
//   //       if (lastCalledDate != null) {
//   //         final calledDate = (lastCalledDate as Timestamp).toDate();
//   //         if (_isSameDay(calledDate, selectedDate)) totalCalledCount++;
//   //       }

//   //       // TRANSFERRED
//   //       final transferredList = data['transferLeads'];
//   //       if (transferredList != null && transferredList is List) {
//   //         bool alreadyCounted = false;
//   //         for (final item in transferredList) {
//   //           if (item is Map<String, dynamic>) {
//   //             final transferredTime = item['transferTime'];
//   //             if (transferredTime != null) {
//   //               final transferDate = (transferredTime as Timestamp).toDate();
//   //               if (_isSameDay(transferDate, selectedDate) && !alreadyCounted) {
//   //                 transferredCount++;
//   //                 alreadyCounted = true;
//   //               }
//   //             }
//   //           }
//   //         }
//   //       }
//   //     }

//   //     log(
//   //       '[fetchLeadCounts] Results — new:$newLeadCount followUp:$followUpCount '
//   //       'closed:$closedLeadCount total:$totalCalledCount missed:$missedLeadCount '
//   //       'transferred:$transferredCount',
//   //     );

//   //     return DashboardCountModel(
//   //       newLeadCount: newLeadCount,
//   //       followUpCount: followUpCount,
//   //       closedLeadCount: closedLeadCount,
//   //       totalCalledCount: totalCalledCount,
//   //       missedLeadCount: missedLeadCount,
//   //       transferredCount: transferredCount,
//   //     );
//   //   }
//   @override
//   Future<DashboardCountModel> fetchLeadCounts({
//     required String staffId,
//     required DateTime selectedDate,
//     required String role,
//     bool forceStaffFilter = false,
//   }) async {
//     final sw = Stopwatch()..start();

//     final startOfDay = DateTime(
//       selectedDate.year,
//       selectedDate.month,
//       selectedDate.day,
//     );
//     final endOfDay = DateTime(
//       selectedDate.year,
//       selectedDate.month,
//       selectedDate.day,
//       23,
//       59,
//       59,
//     );

//     // ── Single query, no composite index needed ──────────────────────────────
//     Query<Map<String, dynamic>> base = _collection;
//     if (forceStaffFilter && staffId.isNotEmpty) {
//       base = base.where('assignedStaffId', isEqualTo: staffId);
//     } else if (role.toLowerCase() != 'admin') {
//       base = base.where('assignedStaffId', isEqualTo: staffId);
//     }

//     // ONE round-trip to Firestore — no subcollection reads at all
//     final snap = await base.get();
//     log('[fetchLeadCounts] docs: ${snap.docs.length}');

//     int newLeadCount = 0;
//     int followUpCount = 0;
//     int closedLeadCount = 0;
//     int totalCalledCount = 0;
//     int missedLeadCount = 0;
//     int transferredCount = 0;

//     for (final doc in snap.docs) {
//       final data = doc.data();
//       final leadStage = (data['leadStage'] ?? '').toString().toUpperCase();

//       // ── NEW ────────────────────────────────────────────────────────────
//       if (leadStage == 'NEW') {
//         final createdAt = data['createdAt'];
//         if (createdAt != null) {
//           final createdDate = (createdAt as Timestamp).toDate();
//           if (_isInRange(createdDate, startOfDay, endOfDay)) {
//             final hasFollowUp = data['hasFollowUp'] as bool? ?? false;
//             if (!hasFollowUp) newLeadCount++;
//           }
//         }
//       }

//       // ── FOLLOWUP ───────────────────────────────────────────────────────
//       if (leadStage == 'FOLLOWUP') {
//         final nextFollowUpDate = data['nextFollowUpDate'];
//         if (nextFollowUpDate != null) {
//           final followDate = (nextFollowUpDate as Timestamp).toDate();
//           if (_isInRange(followDate, startOfDay, endOfDay)) followUpCount++;
//         }
//       }

//       // ── CLOSED ─────────────────────────────────────────────────────────
//       if (leadStage == 'CLOSED') {
//         final lastCalledDate = data['lastCalledDate'];
//         final createdAt = data['createdAt'];
//         if (lastCalledDate != null) {
//           final calledDate = (lastCalledDate as Timestamp).toDate();
//           if (_isInRange(calledDate, startOfDay, endOfDay)) closedLeadCount++;
//         } else if (createdAt != null) {
//           final createdDate = (createdAt as Timestamp).toDate();
//           if (_isInRange(createdDate, startOfDay, endOfDay)) closedLeadCount++;
//         }
//       }

//       // ── TOTAL CALLED ───────────────────────────────────────────────────
//       final lastCalledDate = data['lastCalledDate'];
//       if (lastCalledDate != null) {
//         final calledDate = (lastCalledDate as Timestamp).toDate();
//         if (_isInRange(calledDate, startOfDay, endOfDay)) totalCalledCount++;
//       }

//       // ── MISSED ─────────────────────────────────────────────────────────
//       if (leadStage == 'FOLLOWUP' || leadStage == 'NEW') {
//         final nextFollowUpDate = data['nextFollowUpDate'];
//         if (nextFollowUpDate != null) {
//           final followDate = (nextFollowUpDate as Timestamp).toDate();
//           if (_isBeforeDay(followDate, startOfDay)) missedLeadCount++;
//         }
//       }

//       // ── TRANSFERRED ────────────────────────────────────────────────────
//       if (leadStage == 'TRANSFERRED') {
//         final transferredList = data['transferLeads'];
//         if (transferredList is List) {
//           bool counted = false;
//           for (final item in transferredList) {
//             if (counted) break;
//             if (item is Map<String, dynamic>) {
//               final t = item['transferTime'];
//               if (t != null) {
//                 final td = (t as Timestamp).toDate();
//                 if (_isInRange(td, startOfDay, endOfDay)) {
//                   transferredCount++;
//                   counted = true;
//                 }
//               }
//             }
//           }
//         }
//       }
//     }

//     sw.stop();
//     log(
//       '[fetchLeadCounts] new:$newLeadCount followUp:$followUpCount '
//       'closed:$closedLeadCount total:$totalCalledCount '
//       'missed:$missedLeadCount transferred:$transferredCount '
//       '— ${sw.elapsedMilliseconds}ms',
//     );

//     return DashboardCountModel(
//       newLeadCount: newLeadCount,
//       followUpCount: followUpCount,
//       closedLeadCount: closedLeadCount,
//       totalCalledCount: totalCalledCount,
//       missedLeadCount: missedLeadCount,
//       transferredCount: transferredCount,
//     );
//   }

//   // ── Add this helper if not already present ──────────────────────────────────
//   bool _isInRange(DateTime date, DateTime start, DateTime end) {
//     return !date.isBefore(start) && !date.isAfter(end);
//   }

//   @override
//   Future<void> _logActivity(String leadId, ActivityModel activity) async {
//     await _collection
//         .doc(leadId)
//         .collection('ACTIVITIES')
//         .doc()
//         .set(activity.toFirestore());
//   }

//   Future<void> logLeadCreated({
//     required String leadId,
//     required String createdByName,
//     required String createdById,
//     required String assignedTo,
//     required String leadStage,
//     required String priority,
//     required String leadCategory,
//   }) async {
//     await _logActivity(
//       leadId,
//       ActivityModel(
//         id: '',
//         type: ActivityType.leadCreated,
//         changedBy: createdByName,
//         changedById: createdById,
//         changedAt: DateTime.now(),
//         previousValue: null,
//         newValue: leadStage,
//         description:
//             'Lead created. Assigned to $assignedTo.'
//             '${leadStage.isNotEmpty ? ' Stage: $leadStage.' : ''}'
//             '${priority.isNotEmpty ? ' Priority: $priority.' : ''}'
//             '${leadCategory.isNotEmpty ? ' Category: $leadCategory.' : ''}',
//       ),
//     );
//   }

//   Future<void> logLeadUpdated({
//     required String leadId,
//     required String changedByName,
//     required String changedById,
//     required AddLeadModel previous,
//     required AddLeadModel updated,
//   }) async {
//     final now = DateTime.now();
//     final batch = FirebaseFirestore.instance.batch();
//     final activityRef = _collection.doc(leadId).collection('ACTIVITIES');

//     void log(
//       ActivityType type,
//       String field,
//       String prev,
//       String next,
//       String desc,
//     ) {
//       if (prev == next || next.isEmpty) return;
//       batch.set(
//         activityRef.doc(),
//         ActivityModel(
//           id: '',
//           type: type,
//           changedBy: changedByName,
//           changedById: changedById,
//           changedAt: now,
//           previousValue: prev,
//           newValue: next,
//           description: desc,
//         ).toFirestore(),
//       );
//     }

//     log(
//       ActivityType.statusChanged,
//       'stage',
//       previous.leadStage,
//       updated.leadStage,
//       'Status changed from ${previous.leadStage} to ${updated.leadStage}.',
//     );
//     log(
//       ActivityType.categoryChanged,
//       'category',
//       previous.leadCategory,
//       updated.leadCategory,
//       'Category updated from ${previous.leadCategory} to ${updated.leadCategory}.',
//     );
//     log(
//       ActivityType.priorityChanged,
//       'priority',
//       previous.priority,
//       updated.priority,
//       'Priority updated from ${previous.priority} to ${updated.priority}.',
//     );
//     log(
//       ActivityType.staffAssigned,
//       'staff',
//       previous.assignedStaff,
//       updated.assignedStaff,
//       'Assigned staff changed from ${previous.assignedStaff} to ${updated.assignedStaff}.',
//     );
//     // log(ActivityType.costUpdated,     'cost',     previous.cost ?? '',   updated.cost ?? '',   'Cost updated from ${previous.cost} to ${updated.cost}.');
//     log(
//       ActivityType.remarkUpdated,
//       'remarks',
//       previous.remarks ?? '',
//       updated.remarks ?? '',
//       'Remark updated.',
//     );

//     // Only commit if there's at least one change
//     final ops = batch; // batch will be a no-op if nothing was added
//     await ops.commit();
//   }

//   Future<List<LeadStaffHandler>> getLeadHandledStaffs(AddLeadModel lead) async {
//     // Collect raw staff entries: {staffId -> staffName}
//     // Order matters — insertion order = chronological
//     final Map<String, String> staffMap = {};

//     // 1. Lead creator is always first
//     if (lead.createdById.isNotEmpty) {
//       staffMap[lead.createdById] = lead.createdBy ?? '';
//     }

//     // 2. Assigned staff (may be same as creator — dedup handled by map key)
//     if (lead.assignedStaffId.isNotEmpty) {
//       staffMap[lead.assignedStaffId] = lead.assignedStaff;
//     }

//     // 3. All transfer participants (fromStaff and toStaff)
//     final transferSnap = await _collection
//         .doc(lead.id)
//         .collection('TRANSFER_LEADS')
//         .orderBy('transferTime')
//         .get();

//     for (final doc in transferSnap.docs) {
//       final data = doc.data();
//       final fromId = data['fromStaffId'] as String? ?? '';
//       final fromName = data['fromStaff'] as String? ?? '';
//       final toId = data['toStaffId'] as String? ?? '';
//       final toName = data['toStaff'] as String? ?? '';
//       if (fromId.isNotEmpty) staffMap.putIfAbsent(fromId, () => fromName);
//       if (toId.isNotEmpty) staffMap.putIfAbsent(toId, () => toName);
//     }

//     // 4. Count follow-ups per staff (activity count)
//     final fupSnap = await _collection
//         .doc(lead.id)
//         .collection('FOLLOW_UPS')
//         .get();

//     final Map<String, int> fupCount = {};
//     for (final doc in fupSnap.docs) {
//       final creatorId = doc.data()['createdById'] as String? ?? '';
//       if (creatorId.isNotEmpty) {
//         fupCount[creatorId] = (fupCount[creatorId] ?? 0) + 1;
//       }
//     }

//     // 5. Fetch phone numbers from STAFF collection in parallel
//     final staffIds = staffMap.keys.toList();
//     final phoneMap = <String, String>{};

//     await Future.wait(
//       staffIds.map((id) async {
//         try {
//           final doc = await FirestorePath.companyCollection(
//             'STAFF',
//           ).doc(id).get();
//           phoneMap[id] = doc.data()?['phone'] as String? ?? '';
//         } catch (_) {
//           phoneMap[id] = '';
//         }
//       }),
//     );

//     // 6. Build result list — same order as staffMap insertion
//     return staffIds.map((id) {
//       return LeadStaffHandler(
//         staffId: id,
//         staffName: staffMap[id] ?? '',
//         phone: phoneMap[id] ?? '',
//         // +1 for the lead creation itself by the creator
//         activityCount: (fupCount[id] ?? 0) + (id == lead.createdById ? 1 : 0),
//         isCurrentAssignee: id == lead.assignedStaffId,
//       );
//     }).toList();
//   }

//   Future<Map<String, int>> fetchLeadCountsByCategory({
//     required String staffId,
//     required String role,
//     required DateTime selectedDate,
//     DateTime? toDate,
//   }) async {
//     Query<Map<String, dynamic>> query = _collection;

//     if (staffId.isNotEmpty) {
//       query = query.where(
//         'assignedStaffId',
//         isEqualTo: staffId,
//       ); // ← always filter
//     }

//     // ── Date filter ──────────────────────────────────────────────────────
//     final from = DateTime(
//       selectedDate.year,
//       selectedDate.month,
//       selectedDate.day,
//     );
//     final to = toDate != null
//         ? DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59)
//         : DateTime(from.year, from.month, from.day, 23, 59, 59);

//     query = query
//         .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
//         .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(to));
//     // ─────────────────────────────────────────────────────────────────────

//     final snap = await query.get();

//     final Map<String, int> counts = {
//       'New': 0,
//       'Follow Up': 0,
//       'Rejected': 0,
//       'Closed': 0,
//       'Transferred': 0,
//     };

//     for (final doc in snap.docs) {
//       final data = doc.data();
//       final stage = (data['leadStage'] ?? '').toString().toUpperCase();

//       switch (stage) {
//         case 'NEW':
//           counts['New'] = (counts['New'] ?? 0) + 1;
//           break;
//         case 'FOLLOW UP':
//         case 'FOLLOWUP':
//           counts['Follow Up'] = (counts['Follow Up'] ?? 0) + 1;
//           break;
//         case 'REJECTED':
//           counts['Rejected'] = (counts['Rejected'] ?? 0) + 1;
//           break;
//         case 'CLOSED':
//           counts['Closed'] = (counts['Closed'] ?? 0) + 1;
//           break;
//         case 'TRANSFERRED':
//           counts['Transferred'] = (counts['Transferred'] ?? 0) + 1;
//           break;
//         default:
//           counts['Pending'] = (counts['Pending'] ?? 0) + 1;
//           break;
//       }
//     }

//     return counts;
//   }

//   // In your AddLeadRepository
//   Future<List<LeadCategoryTableRow>> fetchLeadCategoryTableRows({
//     required String staffId,
//     required String role,
//     required DateTime selectedDate,
//     DateTime? toDate,
//   }) async {
//     // ← Remove the date filter, fetch all leads for this staff
//     Query<Map<String, dynamic>> query = _collection;

//     // Always filter by staffId for staff profile view
//     if (staffId.isNotEmpty) {
//       query = query.where('assignedStaffId', isEqualTo: staffId);
//     }

//     // ── Date filter ──────────────────────────────────────────────────────
//     final from = DateTime(
//       selectedDate.year,
//       selectedDate.month,
//       selectedDate.day,
//     );
//     final to = toDate != null
//         ? DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59)
//         : DateTime(from.year, from.month, from.day, 23, 59, 59);

//     query = query
//         .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
//         .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(to));
//     // ─────────────────────────────────────────────────────────────────────

//     final snapshot = await query.get();

//     // Group by leadCategory → then count by leadStage
//     final Map<String, Map<String, int>> grouped = {};

//     for (final doc in snapshot.docs) {
//       final data = doc.data();
//       final category = (data['leadCategory'] as String? ?? 'Uncategorized')
//           .trim()
//           .toUpperCase();
//       final stage = (data['leadStage'] as String? ?? '').trim().toUpperCase();

//       // Use display-friendly category name
//       final displayCategory = category.isEmpty ? 'Uncategorized' : category;

//       grouped.putIfAbsent(
//         displayCategory,
//         () => {'NEW': 0, 'FOLLOW UP': 0, 'REJECTED': 0, 'CLOSED': 0},
//       );

//       if (stage == 'NEW') {
//         grouped[displayCategory]!['NEW'] =
//             (grouped[displayCategory]!['NEW'] ?? 0) + 1;
//       } else if (stage == 'FOLLOW UP' || stage == 'FOLLOWUP') {
//         grouped[displayCategory]!['FOLLOW UP'] =
//             (grouped[displayCategory]!['FOLLOW UP'] ?? 0) + 1;
//       } else if (stage == 'REJECTED') {
//         grouped[displayCategory]!['REJECTED'] =
//             (grouped[displayCategory]!['REJECTED'] ?? 0) + 1;
//       } else if (stage == 'CLOSED') {
//         grouped[displayCategory]!['CLOSED'] =
//             (grouped[displayCategory]!['CLOSED'] ?? 0) + 1;
//       }
//     }

//     // Sort by total count descending so most active categories appear first
//     final rows = grouped.entries
//         .map(
//           (e) => LeadCategoryTableRow(
//             category: e.key,
//             newCount: e.value['NEW'] ?? 0,
//             followUpCount: e.value['FOLLOW UP'] ?? 0,
//             rejectedCount: e.value['REJECTED'] ?? 0,
//             closedCount: e.value['CLOSED'] ?? 0,
//           ),
//         )
//         .toList();

//     rows.sort((a, b) {
//       final totalA =
//           a.newCount + a.followUpCount + a.rejectedCount + a.closedCount;
//       final totalB =
//           b.newCount + b.followUpCount + b.rejectedCount + b.closedCount;
//       return totalB.compareTo(totalA);
//     });

//     return rows;
//   }

//   static const Map<String, bool> callResultConnectionMap = {
//     'connected': true,
//     'answered': true,
//     'busy': false,
//     'not attended': false,
//     'notattended': false,
//     'out of coverage area': false,
//     'outofcoveragearea': false,
//     'rejected': false,
//     'switched off': false,
//     'switchedoff': false,
//     'no answer': false,
//     'noanswer': false,
//   };

//   static bool isCallConnected(String status) {
//     final normalized = status.toLowerCase().trim();
//     if (normalized.isEmpty) return false;
//     if (callResultConnectionMap.containsKey(normalized)) {
//       return callResultConnectionMap[normalized]!;
//     }
//     // Fallback: If it contains 'connect' or 'answer', assume connected; otherwise, not connected.
//     if (normalized.contains('connect') || normalized.contains('answer')) {
//       return true;
//     }
//     return false;
//   }

//   Future<Map<String, int>> fetchCallStatusCounts({
//     required String staffId,
//     required String role,
//     DateTime? selectedDate,
//     DateTime? toDate,
//   }) async {
//     Timestamp? fromTs;
//     Timestamp? toTs;
//     if (selectedDate != null) {
//       final from = DateTime(
//         selectedDate.year,
//         selectedDate.month,
//         selectedDate.day,
//       );
//       final to = toDate != null
//           ? DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59)
//           : DateTime(from.year, from.month, from.day, 23, 59, 59);
//       fromTs = Timestamp.fromDate(from);
//       toTs = Timestamp.fromDate(to);
//     }

//     // Query FOLLOW_UPS subcollection across all leads for this staff
//     Query<Map<String, dynamic>> query = _firestore
//         .collectionGroup('FOLLOW_UPS')
//         .where('createdById', isEqualTo: staffId);

//     if (fromTs != null && toTs != null) {
//       query = query
//           .where('createdAt', isGreaterThanOrEqualTo: fromTs)
//           .where('createdAt', isLessThanOrEqualTo: toTs);
//     }

//     final snap = await query.get();

//     int totalCalled = 0;
//     int connected = 0;
//     int notConnected = 0;
//     final Map<String, int> detailedCounts = {};

//     for (final doc in snap.docs) {
//       final data = doc.data();
//       final calledStatus = (data['calledStatus'] as String? ?? '').trim();

//       if (calledStatus.isNotEmpty) {
//         // Capitalize first letter of each word to look clean on UI
//         final normalized = calledStatus
//             .split(RegExp(r'\s+'))
//             .map((word) {
//               if (word.isEmpty) return '';
//               return word[0].toUpperCase() + word.substring(1).toLowerCase();
//             })
//             .join(' ');

//         if (normalized.isNotEmpty) {
//           detailedCounts[normalized] = (detailedCounts[normalized] ?? 0) + 1;
//         }

//         totalCalled++;

//         if (isCallConnected(calledStatus)) {
//           connected++;
//         } else {
//           notConnected++;
//         }
//       }
//     }

//     return {
//       'totalCalled': totalCalled,
//       'connected': connected,
//       'notConnected': notConnected,
//       ...detailedCounts,
//     };
//   }

//   Future<AddLeadModel> getLeadById(String leadId) async {
//     try {
//       final leadDoc = await _collection.doc(leadId).get();

//       if (!leadDoc.exists) {
//         throw Exception('Lead not found');
//       }

//       final followUpSnap = await _collection
//           .doc(leadId)
//           .collection('FOLLOW_UPS')
//           .orderBy('createdAt', descending: true)
//           .get();

//       final followUps = followUpSnap.docs
//           .map((e) => FollowUpModel.fromFirestore(e.data(), e.id))
//           .toList();

//       final lead = AddLeadModel.fromFirestore(leadDoc.data()!, leadDoc.id);

//       return lead.copyWith(followUp: followUps);
//     } catch (e) {
//       throw Exception('Failed to fetch lead: $e');
//     }
//   }

//   // Future<void> deleteFollowUp({
//   //   required String leadId,
//   //   required String followUpId,
//   // }) async {
//   //   try {
//   //     await FirebaseFirestore.instance
//   //         .collection('LEADS')
//   //         .doc(leadId)
//   //         .collection('FOLLOW_UPS')
//   //         .doc(followUpId)
//   //         .delete();
//   //   } catch (e) {
//   //     throw Exception('Failed to delete follow-up: $e');
//   //   }
//   // }

//   Future<void> deleteFollowUp({
//     required String leadId,
//     required String followUpId,
//     required String changedByName,
//     required String changedById,
//     required String leadName,
//     required String leadPhone,
//   }) async {
//     final leadRef = _collection.doc(leadId);

//     final activityRef = leadRef.collection('ACTIVITIES');

//     // Read followup BEFORE deleting
//     final deletedDoc = await leadRef
//         .collection('FOLLOW_UPS')
//         .doc(followUpId)
//         .get();

//     if (!deletedDoc.exists) {
//       throw Exception('Follow-up not found');
//     }

//     final deletedFollowup = FollowUpModel.fromFirestore(
//       deletedDoc.data()!,
//       deletedDoc.id,
//     );

//     // Delete followup
//     await deletedDoc.reference.delete();

//     // Find the next latest followup
//     final remaining = await leadRef
//         .collection('FOLLOW_UPS')
//         .orderBy('calledDate', descending: true)
//         .limit(1)
//         .get();

//     if (remaining.docs.isNotEmpty) {
//       final latest = FollowUpModel.fromFirestore(
//         remaining.docs.first.data(),
//         remaining.docs.first.id,
//       );

//       await leadRef.update({
//         'leadStage': latest.leadStage,
//         'priority': latest.priority,
//         'leadCategory': latest.leadCategory,
//         'followUpDate': latest.nextFollowUpDate,
//         'calledDate': latest.calledDate,
//         'callResult': latest.calledStatus,
//         'remarks': latest.remarks,
//       });
//     }

//     // Log activity
//     await activityRef.add(
//       ActivityModel(
//         id: '',
//         type: ActivityType.followupDeleted,
//         changedBy: changedByName,
//         changedById: changedById,
//         changedAt: DateTime.now(),
//         leadId: leadId,
//         leadName: leadName,
//         leadPhone: leadPhone,
//         previousValue: deletedFollowup.calledStatus,
//         newValue: '',
//         description:
//             'Deleted follow-up. Status: ${deletedFollowup.leadStage}, '
//             'Call Result: ${deletedFollowup.calledStatus}, '
//             'Scheduled Date: ${DateFormat('dd-MM-yyyy HH:mm').format(deletedFollowup.nextFollowUpDate)}',
//       ).toFirestore(),
//     );
//   }

//   @override
//   Future<bool> isContactNumberExists(String contactNumber) async {
//     final snap = await _collection
//         .where('contactNumber', isEqualTo: contactNumber.trim())
//         .limit(1)
//         .get();
//     return snap.docs.isNotEmpty;
//   }
// }

// Future<void> migrateHasFollowUp() async {
//   final db = FirebaseFirestore.instance;
//   final leadsSnap = await db.collection('LEADS').get();

//   int updated = 0;
//   int skipped = 0;

//   for (final leadDoc in leadsSnap.docs) {
//     final data = leadDoc.data();

//     // Skip if already set
//     if (data.containsKey('hasFollowUp')) {
//       skipped++;
//       continue;
//     }

//     // Check if this lead has any follow-ups
//     final followUpsSnap = await db
//         .collection('LEADS')
//         .doc(leadDoc.id)
//         .collection('FOLLOW_UPS')
//         .limit(1)
//         .get();

//     final hasFollowUp = followUpsSnap.docs.isNotEmpty;

//     await db.collection('LEADS').doc(leadDoc.id).update({
//       'hasFollowUp': hasFollowUp,
//     });

//     updated++;
//     print('Updated ${leadDoc.id} → hasFollowUp: $hasFollowUp');
//   }

//   print('Migration complete. Updated: $updated, Skipped: $skipped');
// }



abstract class IAddLeadRepository {
  Future<String> addLead(AddLeadModel lead);
  Future<List<AddLeadModel>> fetchLeads({
    required String staffId,
    required String role,
  });
  Future<List<AddLeadModel>> fetchDashboardLeads({
    required String staffId,
    required String role,
    required String fromCard,
    required DateTime selectedDate,
    DateTime? toDate,
  });
  Future<void> updateLead(String id, AddLeadModel lead);
  Future<void> deleteLead(String id);
  Future<void> moveToDeleted(AddLeadModel lead);
  Future<List<AddLeadModel>> fetchDeletedLeads();
  Future<String> restoreLead(AddLeadModel lead);
  Future<void> permanentlyDeleteLead(String id);
  Future<void> assignStaff(String leadId, String staffId, String staffName);
  Future<AddLeadModel> getLeadById(String leadId);
  Future<void> deleteFollowUp({
    required String leadId,
    required String followUpId,
    required String changedByName,
    required String changedById,
    required String leadName,
    required String leadPhone,
  });
  Future<void> addFollowUp(
    String leadId,
    FollowUpModel followUp, {
    String? previousStage, // pass current lead's stage before update
    String? previousCategory,
    String? previousPriority,
    String changedByName = '',
    String changedById = '',
    String leadName = '',
    String leadPhone = '',
  });
  Future<DashboardCountModel> fetchLeadCounts({
    required String staffId,
    required DateTime selectedDate,
    required String role,
    bool forceStaffFilter = false,
  });
  Future<void> transferLead(
    String leadId,
    TransferDetails transfer, {
    required String changedByName,
    required String changedById,
  });
  Future<void> _logActivity(String leadId, ActivityModel activity);
  Future<void> logLeadCreated({
    required String leadId,
    required String createdByName,
    required String createdById,
    required String assignedTo,
    required String leadStage,
    required String priority,
    required String leadCategory,
  });
  Future<void> logLeadUpdated({
    required String leadId,
    required String changedByName,
    required String changedById,
    required AddLeadModel previous,
    required AddLeadModel updated,
  });
  Future<List<LeadStaffHandler>> getLeadHandledStaffs(AddLeadModel lead);

  Future<Map<String, int>> fetchLeadCountsByCategory({
    required String staffId,
    required String role,
    required DateTime selectedDate,
    DateTime? toDate,
  });
  Future<List<LeadCategoryTableRow>> fetchLeadCategoryTableRows({
    required String staffId,
    required String role,
    required DateTime selectedDate,
    DateTime? toDate,
  });
  Future<Map<String, int>> fetchCallStatusCounts({
    required String staffId,
    required String role,
    DateTime? selectedDate,
    DateTime? toDate,
  });
  Future<bool> isContactNumberExists(String contactNumber);
}

class AddLeadRepository implements IAddLeadRepository {
  final FirebaseFirestore _firestore;

  AddLeadRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestorePath.companyCollection('LEADS');
  CollectionReference<Map<String, dynamic>> get _deletedCollection =>
      FirestorePath.companyCollection('DELETED_LEADS');

  String _generateDateId(String prefix) {
    final now = DateTime.now();
    final datePart = DateFormat('yyyyMMdd').format(now);
    final timePart = DateFormat('HHmmss').format(now);
    final ms =
        now.millisecondsSinceEpoch % 1000; // last 3 digits for uniqueness
    final id = now.millisecondsSinceEpoch.toString();
    return '$prefix-$datePart-$id';
  }

  @override
  Future<String> addLead(AddLeadModel lead) async {
    if (lead.clientName.trim().isEmpty) {
      throw ArgumentError('Client name cannot be empty.');
    }
    if (lead.contactNumber.trim().isEmpty) {
      throw ArgumentError('Contact number cannot be empty.');
    }

    final String id = _generateDateId('LEAD');
    await _collection.doc(id).set(lead.toFirestore());
    log('[AddLeadRepository] Lead added with ID: $id');

    return id;
  }

  @override
  Future<List<AddLeadModel>> fetchLeads({
    required String staffId,
    required String role,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _collection;

      if (role.toLowerCase() != 'admin') {
        query = query.where('assignedStaffId', isEqualTo: staffId);
      }

      final snap = await query.orderBy('createdAt', descending: true).get();

      // return snap.docs
      //     .map((d) => AddLeadModel.fromFirestore(d.data(), d.id))
      //     .toList();
      /// FETCH LEADS + FOLLOWUPS
      final List<AddLeadModel> allLeads = await Future.wait(
        snap.docs.map((leadDoc) async {
          /// MAIN LEAD
          final lead = AddLeadModel.fromFirestore(leadDoc.data(), leadDoc.id);

          /// FETCH FOLLOWUP SUBCOLLECTION
          final followUpSnap = await _collection
              .doc(leadDoc.id)
              .collection('FOLLOW_UPS')
              .orderBy('createdAt', descending: true)
              .get();

          /// CONVERT FOLLOWUPS
          final followUps = followUpSnap.docs.map((fupDoc) {
            return FollowUpModel.fromFirestore(fupDoc.data(), fupDoc.id);
          }).toList();

          /// RETURN LEAD WITH FOLLOWUPS
          return lead.copyWith(followUp: followUps);
        }),
      );
      return allLeads;
    } on FirebaseException catch (e) {
      debugPrint('[fetchLeads] Firebase error: ${e.code} — ${e.message}');
      rethrow;
    } catch (e, st) {
      debugPrint('[fetchLeads] Unexpected error: $e\n$st');
      rethrow;
    }
  }

  Future<List<AddLeadModel>> fetchDashboardLeadsOld({
    required String staffId,
    required String role,
    required String fromCard,
    required DateTime selectedDate,
  }) async {
    Query<Map<String, dynamic>> query = _collection;

    /// ---------------- ROLE FILTER ----------------
    /// Admin -> all leads
    /// Staff -> only assigned leads

    if (role.toLowerCase() != 'admin') {
      query = query.where('assignedStaffId', isEqualTo: staffId);
    }

    log("ddddddddddddddddddd");

    try {
      final snap = await query.orderBy('createdAt', descending: true).get();

      final allLeads = snap.docs
          .map((d) => AddLeadModel.fromFirestore(d.data(), d.id))
          .toList();

      /// ---------------- DATE FILTER HELPER ----------------

      bool isSameDay(DateTime? date) {
        if (date == null) return false;

        return date.year == selectedDate.year &&
            date.month == selectedDate.month &&
            date.day == selectedDate.day;
      }

      /// ---------------- CARD FILTER ----------------

      switch (fromCard.toUpperCase()) {
        /// NEW LEADS
        case 'NEW':
          return allLeads.where((lead) {
            return isSameDay(lead.createdAt);
          }).toList();

        /// FOLLOWUP LEADS
        case 'FOLLOWUP':
          return allLeads.where((lead) {
            return isSameDay(lead.followUpDate);
          }).toList();

        /// CLOSED LEADS
        case 'CLOSED':
          return allLeads.where((lead) {
            return lead.leadStage.toUpperCase() == 'CLOSED';
          }).toList();

        /// TOTAL CALLED
        case 'TOTAL':
          return allLeads.where((lead) {
            return isSameDay(lead.calledDate);
          }).toList();

        /// MISSED / REJECTED
        case 'MISSED':
          return allLeads.where((lead) {
            return lead.leadStage.toUpperCase() == 'REJECTED';
          }).toList();

        /// TRANSFERRED LEADS
        case 'TRANSFERRED':
          return allLeads.where((lead) {
            if (lead.transferLeads == null || lead.transferLeads!.isEmpty) {
              return false;
            }

            return lead.transferLeads!.any((item) {
              final transferredTime = item.transferTime;
              // item['transferredTime'];

              if (transferredTime == null) {
                return false;
              }

              DateTime transferDate;

              // if (transferredTime is Timestamp) {
              //
              //   transferDate = transferredTime.toDate();
              //
              // } else
              transferDate = transferredTime;

              return isSameDay(transferDate);
            });
          }).toList();

        default:
          return allLeads;
      }
    } catch (e) {
      log("error in fetchDashboardLeads ::: $e");
    }
    return [];
  }

  @override
  Future<List<AddLeadModel>> fetchDashboardLeads({
    required String staffId,
    required String role,
    required String fromCard,
    required DateTime selectedDate,
    DateTime? toDate,
  }) async {
    Query<Map<String, dynamic>> query = _collection;

    /// ROLE FILTER
    if (role.toLowerCase() != 'admin') {
      query = query.where('assignedStaffId', isEqualTo: staffId);
    }

    try {
      final snap = await query.orderBy('createdAt', descending: true).get();

      /// FETCH LEADS + FOLLOWUPS
      final List<AddLeadModel> allLeads = await Future.wait(
        snap.docs.map((leadDoc) async {
          /// MAIN LEAD
          final lead = AddLeadModel.fromFirestore(leadDoc.data(), leadDoc.id);

          /// FETCH FOLLOWUP SUBCOLLECTION
          final followUpSnap = await _collection
              .doc(leadDoc.id)
              .collection('FOLLOW_UPS')
              .orderBy('createdAt', descending: true)
              .get();

          /// CONVERT FOLLOWUPS
          final followUps = followUpSnap.docs.map((fupDoc) {
            return FollowUpModel.fromFirestore(fupDoc.data(), fupDoc.id);
          }).toList();

          /// RETURN LEAD WITH FOLLOWUPS
          return lead.copyWith(followUp: followUps);
        }),
      );

      /// DATE FILTER HELPER
      // bool isSameDay(DateTime? date) {
      //   if (date == null) return false;

      //   return date.year == selectedDate.year &&
      //       date.month == selectedDate.month &&
      //       date.day == selectedDate.day;
      // }

      final effectiveTo = toDate ?? selectedDate;

      final fromDay = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      final toDay = DateTime(
        effectiveTo.year,
        effectiveTo.month,
        effectiveTo.day,
        23,
        59,
        59,
      );

      bool isInRange(DateTime? date) {
        if (date == null) return false;
        return !date.isBefore(fromDay) && !date.isAfter(toDay);
      }

      bool isbeforeFromDay(DateTime? date) {
        if (date == null) return false;
        return date.isBefore(fromDay);
      }

      bool isAfterToDay(DateTime? date) {
        if (date == null) return false;
        return date.isAfter(toDay);
      }

      /// CARD FILTER
      switch (fromCard.toUpperCase()) {
        /// NEW LEADS
        case 'NEW':
          return allLeads.where((lead) {
            return isInRange(lead.createdAt) &&
                lead.leadStage.toUpperCase() == 'NEW' &&
                // lead.followUp!.isEmpty;
                (lead.followUp == null || lead.followUp!.isEmpty);
          }).toList();

        /// FOLLOWUP LEADS
        case 'FOLLOWUP':
          return allLeads.where((lead) {
            return isInRange(lead.followUpDate) &&
                lead.leadStage.toUpperCase() == 'FOLLOWUP'; // &&
            // lead.leadStage.toUpperCase() != 'CLOSED'&&
            // lead.leadStage.toUpperCase() != 'REJECTED'&& ;
          }).toList();

        /// CLOSED LEADS
        case 'CLOSED':
          return allLeads.where((lead) {
            return lead.leadStage.toUpperCase() == 'CLOSED' &&
                isInRange(lead.calledDate);
          }).toList();

        /// TOTAL CALLED
        case 'TOTAL':
          return allLeads.where((lead) {
            return isInRange(lead.calledDate);
          }).toList();

        /// MISSED / REJECTED
        case 'MISSED':
          return allLeads.where((lead) {
            return (lead.leadStage.toUpperCase() == 'FOLLOWUP' ||
                    lead.leadStage.toUpperCase() == 'NEW') &&
                isbeforeFromDay(lead.followUpDate);
          }).toList();

        /// TRANSFERRED
        case 'TRANSFERRED':
          return allLeads.where((lead) {
            if (lead.transferLeads == null || lead.transferLeads!.isEmpty) {
              return false;
            }

            return lead.transferLeads!.any((item) {
              final transferredTime = item.transferTime;

              if (transferredTime == null) {
                return false;
              }

              return isInRange(transferredTime);
            });
          }).toList();

        default:
          return allLeads;
      }
    } catch (e) {
      log("error in fetchDashboardLeads ::: $e");

      return [];
    }
  }

  @override
  Future<void> updateLead(String id, AddLeadModel lead) async {
    if (id.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');

    //    final data = lead.toFirestore();
    // data.remove('createdAt'); // ✅ prevent createdAt from being overwritten
    // data['updatedAt'] = FieldValue.serverTimestamp();

    await _collection.doc(id).update(lead.toUpdateMap());
  }

  @override
  Future<void> deleteLead(String id) async {
    if (id.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');
    await _collection.doc(id).delete();
  }

  @override
  Future<void> moveToDeleted(AddLeadModel lead) async {
    assert(lead.id != null, 'ID must not be null');

    final deletedLead = lead.copyWith(deletedAt: DateTime.now());

    await _deletedCollection.add(deletedLead.toFirestore());
    await _collection.doc(lead.id).delete();

    log('[StaffRepository] Staff moved to DELETED_STAFF: ${lead.id}');
  }

  @override
  Future<String> restoreLead(AddLeadModel lead) async {
    if (lead.clientName.trim().isEmpty) {
      throw ArgumentError('Client name cannot be empty.');
    }
    if (lead.contactNumber.trim().isEmpty) {
      throw ArgumentError('Contact number cannot be empty.');
    }
    final doc = await _collection.add(lead.toFirestore());
    await _deletedCollection.doc(lead.id).delete();
    return doc.id;
  }

  @override
  Future<List<AddLeadModel>> fetchDeletedLeads() async {
    final snap = await _deletedCollection
        .orderBy('deletedAt', descending: true)
        .get();
    return snap.docs
        .map((d) => AddLeadModel.fromFirestore(d.data(), d.id))
        .toList();
  }

  @override
  Future<void> permanentlyDeleteLead(String id) async {
    await _deletedCollection.doc(id).delete();
    log('[AddLeadRepository] Lead permanently deleted: $id');
  }

  @override
  Future<void> assignStaff(
    String leadId,
    String staffId,
    String staffName,
  ) async {
    if (leadId.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');
    await _collection.doc(leadId).update({
      'assignedStaffId': staffId,
      'assignedStaff': staffName,
    });
    log('[AddLeadRepository] Staff assigned to lead: $leadId → $staffId');
  }

  @override
  Future<void> addFollowUpOld(String leadId, FollowUpModel followUp) async {
    if (leadId.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');

    final String followUpId = _generateDateId('FUP');
    await _collection
        .doc(leadId)
        .collection('FOLLOW_UPS')
        .doc(followUpId)
        .set(followUp.toFirestore());

    await _collection.doc(leadId).update({
      'leadStage': followUp.leadStage,
      'priority': followUp.priority,
      'leadCategory': followUp.leadCategory,
      'nextFollowUpDate': followUp.nextFollowUpDate,
      'lastCalledDate': followUp.calledDate,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    log('[AddLeadRepository] FollowUp added for lead: $leadId');
  }

  @override
  Future<void> addFollowUp(
    String leadId,
    FollowUpModel followUp, {
    String? previousStage, // pass current lead's stage before update
    String? previousCategory,
    String? previousPriority,
    String changedByName = '',
    String changedById = '',
    String leadName = '',
    String leadPhone = '',
  }) async {
    if (leadId.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');

    final batch = FirebaseFirestore.instance.batch();
    final activityRef = _collection.doc(leadId).collection('ACTIVITIES');

    // 1. Write the follow-up document
    final String followUpId = followUp.id ?? _generateDateId('FUP');
    final fupRef = _collection
        .doc(leadId)
        .collection('FOLLOW_UPS')
        .doc(followUpId);
    batch.set(fupRef, followUp.toFirestore(), SetOptions(merge: true));

    // 2. Update lead document
    final leadRef = _collection.doc(leadId);
    // batch.update(leadRef, {
    //   'leadStage': followUp.leadStage,
    //   'priority': followUp.priority,
    //   'leadCategory': followUp.leadCategory,
    //   'nextFollowUpDate': followUp.nextFollowUpDate,
    //   'lastCalledDate': followUp.calledDate,
    //   'callResult': followUp.calledStatus,
    //   'leadTag': followUp.leadTag,
    //   'updatedAt': FieldValue.serverTimestamp(),
    //   // 'remarks' : followUp.remarks,
    // });
    final Map<String, dynamic> leadUpdates = {
      'leadStage': followUp.leadStage,
      'priority': followUp.priority,
      'leadCategory': followUp.leadCategory,
      'nextFollowUpDate': followUp.nextFollowUpDate,
      'lastCalledDate': followUp.calledDate,
      'callResult': followUp.calledStatus,
      'leadTag': followUp.leadTag,
      'updatedAt': FieldValue.serverTimestamp(),
      'hasFollowUp': true,
    };
    if ((followUp.adress ?? '').isNotEmpty) {
      leadUpdates['address'] = followUp.adress;
    }
    if ((followUp.email ?? '').isNotEmpty) {
      leadUpdates['email'] = followUp.email;
    }
    if ((followUp.remarks ?? '').isNotEmpty) {
      leadUpdates['remarks'] = followUp.remarks;
    }
    batch.update(leadRef, leadUpdates);

    final now = DateTime.now();

    // Helper to add an activity doc in the batch
    void logActivity(ActivityModel activity) {
      batch.set(activityRef.doc(), activity.toFirestore());
    }

    // 3. Always log the follow-up added activity
    logActivity(
      ActivityModel(
        id: '',
        type: ActivityType.followupAdded,
        changedBy: changedByName,
        changedById: changedById,
        changedAt: now,
        previousValue: followUp.calledStatus,
        leadId: leadId, // ← add
        leadName: leadName, // ← add
        leadPhone: leadPhone, // ← add
        newValue: DateFormat(
          'dd-MM-yyyy HH:mm',
        ).format(followUp.nextFollowUpDate),
        description:
            'Follow-up added. Call status: ${followUp.calledStatus}. '
            'Next follow-up scheduled to '
            '${DateFormat('dd-MM-yyyy HH:mm').format(followUp.nextFollowUpDate)}.',
      ),
    );

    // 4. Log status change only if it actually changed
    if (previousStage != null &&
        previousStage.isNotEmpty &&
        previousStage != followUp.leadStage) {
      logActivity(
        ActivityModel(
          id: '',
          type: ActivityType.statusChanged,
          changedBy: changedByName,
          changedById: changedById,
          changedAt: now,
          previousValue: previousStage,
          newValue: followUp.leadStage,
          description:
              'Status changed from $previousStage to ${followUp.leadStage}.',
        ),
      );
    }

    // 5. Log category change only if it changed
    if (previousCategory != null &&
        previousCategory.isNotEmpty &&
        previousCategory != followUp.leadCategory &&
        followUp.leadCategory.isNotEmpty) {
      logActivity(
        ActivityModel(
          id: '',
          type: ActivityType.categoryChanged,
          changedBy: changedByName,
          changedById: changedById,
          changedAt: now,
          previousValue: previousCategory,
          newValue: followUp.leadCategory,
          description:
              'Lead category updated from $previousCategory to ${followUp.leadCategory}.',
        ),
      );
    }

    // 6. Log priority change only if it changed
    if (previousPriority != null &&
        previousPriority.isNotEmpty &&
        previousPriority != followUp.priority &&
        followUp.priority.isNotEmpty) {
      logActivity(
        ActivityModel(
          id: '',
          type: ActivityType.priorityChanged,
          changedBy: changedByName,
          changedById: changedById,
          changedAt: now,
          previousValue: previousPriority,
          newValue: followUp.priority,
          description:
              'Priority updated from $previousPriority to ${followUp.priority}.',
        ),
      );
    }

    await batch.commit();
    log('[AddLeadRepository] FollowUp + activities written for lead: $leadId');
  }

  @override
  Future<void> transferLead(
    String leadId,
    TransferDetails transfer, {
    required String changedByName,
    required String changedById,
  }) async {
    if (leadId.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');

    final batch = FirebaseFirestore.instance.batch();
    final String transferId = _generateDateId('TRF');

    // 1. Add to TRANSFER_LEADS subcollection
    final transferRef = _collection
        .doc(leadId)
        .collection('TRANSFER_LEADS')
        .doc(transferId);
    batch.set(transferRef, transfer.toFirestore());

    // 2. Update the lead document
    final leadRef = _collection.doc(leadId);
    batch.update(leadRef, {
      'assignedStaff': transfer.toStaff,
      'assignedStaffId': transfer.toStaffId,
      'leadStage': 'TRANSFERRED',
      'transferLeads': FieldValue.arrayUnion([transfer.toFirestore()]),
    });

    // 3. Log the transfer activity
    final activityRef = _collection.doc(leadId).collection('ACTIVITIES').doc();
    batch.set(
      activityRef,
      ActivityModel(
        id: '',
        type: ActivityType.staffAssigned,
        changedBy: changedByName,
        changedById: changedById,
        changedAt: DateTime.now(),
        previousValue: transfer.fromStaff,
        newValue: transfer.toStaff,
        description:
            'Lead transferred from ${transfer.fromStaff} to ${transfer.toStaff}.',
      ).toFirestore(),
    );

    await batch.commit();
    log('[AddLeadRepository] Lead transferred: $leadId → ${transfer.toStaff}');
  }

  // Future<void> transferLead(String leadId, TransferDetails transfer) async {
  //   if (leadId.trim().isEmpty) throw ArgumentError('Lead ID cannot be empty.');
  //
  //   final String transferId = _generateDateId('TRF');
  //
  //   // ── Add to subcollection ──────────────────────────────────────────────
  //   await _collection
  //       .doc(leadId)
  //       .collection('TRANSFER_LEADS')
  //       .doc(transferId)
  //       .set(transfer.toFirestore());
  //
  //   // ── Update the lead document ──────────────────────────────────────────
  //   await _collection.doc(leadId).update({
  //     'assignedStaff':   transfer.toStaff,
  //     'assignedStaffId': transfer.toStaffId,
  //     'transferLeads': FieldValue.arrayUnion([transfer.toFirestore()]),
  //   });
  //
  //   log('[AddLeadRepository] Lead transferred: $leadId → ${transfer.toStaff}');
  // }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  bool _isBeforeDay(DateTime d1, DateTime d2) {
    final day1 = DateTime(d1.year, d1.month, d1.day);
    final day2 = DateTime(d2.year, d2.month, d2.day);
    return day1.isBefore(day2);
  }

  //   @override
  //   Future<DashboardCountModel> fetchLeadCounts({
  //     required String staffId,
  //     required DateTime selectedDate,
  //     required String role,
  //     bool forceStaffFilter = false, // ← new flag
  //   }) async {
  //     final startOfDay = DateTime(
  //       selectedDate.year,
  //       selectedDate.month,
  //       selectedDate.day,
  //     );
  //     final endOfDay = DateTime(
  //       selectedDate.year,
  //       selectedDate.month,
  //       selectedDate.day,
  //       23,
  //       59,
  //       59,
  //     );

  //     // If forceStaffFilter=true (staff profile screen), ALWAYS filter by staffId
  //     // regardless of role. Otherwise use the original admin/staff logic.
  //     Query<Map<String, dynamic>> query = _collection;
  //     if (forceStaffFilter && staffId.isNotEmpty) {
  //       query = query.where('assignedStaffId', isEqualTo: staffId);
  //       log(
  //         '[fetchLeadCounts] Staff profile mode: filtering by staffId=$staffId',
  //       );
  //     } else if (role.toLowerCase() != 'admin') {
  //       query = query.where('assignedStaffId', isEqualTo: staffId);
  //       log('[fetchLeadCounts] Staff mode: filtering by staffId=$staffId');
  //     } else {
  //       log('[fetchLeadCounts] Admin dashboard mode: fetching all leads');
  //     }

  //     final snap = await query.get();
  //     log('[fetchLeadCounts] Total docs fetched: ${snap.docs.length}');

  //     int newLeadCount = 0;
  //     int followUpCount = 0;
  //     int closedLeadCount = 0;
  //     int totalCalledCount = 0;
  //     int missedLeadCount = 0;
  //     int transferredCount = 0;

  //     for (final doc in snap.docs) {
  //       final data = doc.data();
  //       final leadStage = (data['leadStage'] ?? '').toString().toUpperCase();
  //       final followUps =
  //           (await doc.reference.collection('FOLLOW_UPS').get()).docs;

  //       // NEW
  //       final createdAt = data['createdAt'];
  //       if (createdAt != null) {
  //         final createdDate = (createdAt as Timestamp).toDate();
  //         // if (_isSameDay(createdDate, selectedDate) &&
  //         //     leadStage == 'NEW' &&
  //         //     followUps.isEmpty) {
  //         //   newLeadCount++;
  //         // }
  // //         if (leadStage == 'NEW' && createdDate != null && _isSameDay(createdDate, selectedDate)) {
  // //   // only fetch follow-ups when the lead is actually a candidate
  // //   final followUps = (await doc.reference.collection('FOLLOW_UPS').get()).docs;
  // //   if (followUps.isEmpty) newLeadCount++;
  // // }
  // final hasFollowUp = data['hasFollowUp'] as bool? ?? false;
  // if (leadStage == 'NEW' && _isSameDay(createdDate, selectedDate)) {
  //   if (!hasFollowUp) newLeadCount++;
  // }
  //       }

  //       // FOLLOWUP
  //       final nextFollowUpDate = data['nextFollowUpDate'];
  //       if (nextFollowUpDate != null) {
  //         final followDate = (nextFollowUpDate as Timestamp).toDate();
  //         if (_isSameDay(followDate, selectedDate) &&
  //             leadStage != 'CLOSED' &&
  //             leadStage != 'REJECTED' &&
  //             leadStage != 'NEW') {
  //           followUpCount++;
  //         }
  //       }

  //       // final calledDate = data['lastCalledDate'] ;
  //       // CLOSED
  //       final lastCalledDate = data['lastCalledDate'];
  //       if (lastCalledDate != null) {
  //         final calledDate = (lastCalledDate as Timestamp).toDate();
  //         if (leadStage == 'CLOSED' && _isSameDay(calledDate, selectedDate)) {
  //           closedLeadCount++;
  //         }
  //       } else {
  //         if (createdAt != null) {
  //           final createdDate = (createdAt as Timestamp).toDate();
  //           if (leadStage == 'CLOSED' && _isSameDay(createdDate, selectedDate)) {
  //             closedLeadCount++;
  //           }
  //         }
  //       }
  //       //&& _isSameDay(calledDate, selectedDate)) closedLeadCount++;

  //       // MISSED / REJECTED
  //       if (nextFollowUpDate != null) {
  //         final followDate = (nextFollowUpDate as Timestamp).toDate();
  //         if ((leadStage == 'FOLLOWUP' || leadStage == 'NEW') &&
  //             _isBeforeDay(followDate, selectedDate)) {
  //           missedLeadCount++;
  //         }
  //       }

  //       // TOTAL CALLED
  //       // final lastCalledDate = data['lastCalledDate'];
  //       if (lastCalledDate != null) {
  //         final calledDate = (lastCalledDate as Timestamp).toDate();
  //         if (_isSameDay(calledDate, selectedDate)) totalCalledCount++;
  //       }

  //       // TRANSFERRED
  //       final transferredList = data['transferLeads'];
  //       if (transferredList != null && transferredList is List) {
  //         bool alreadyCounted = false;
  //         for (final item in transferredList) {
  //           if (item is Map<String, dynamic>) {
  //             final transferredTime = item['transferTime'];
  //             if (transferredTime != null) {
  //               final transferDate = (transferredTime as Timestamp).toDate();
  //               if (_isSameDay(transferDate, selectedDate) && !alreadyCounted) {
  //                 transferredCount++;
  //                 alreadyCounted = true;
  //               }
  //             }
  //           }
  //         }
  //       }
  //     }

  //     log(
  //       '[fetchLeadCounts] Results — new:$newLeadCount followUp:$followUpCount '
  //       'closed:$closedLeadCount total:$totalCalledCount missed:$missedLeadCount '
  //       'transferred:$transferredCount',
  //     );

  //     return DashboardCountModel(
  //       newLeadCount: newLeadCount,
  //       followUpCount: followUpCount,
  //       closedLeadCount: closedLeadCount,
  //       totalCalledCount: totalCalledCount,
  //       missedLeadCount: missedLeadCount,
  //       transferredCount: transferredCount,
  //     );
  //   }
  @override
  Future<DashboardCountModel> fetchLeadCounts({
    required String staffId,
    required DateTime selectedDate,
    required String role,
    bool forceStaffFilter = false,
  }) async {
    final sw = Stopwatch()..start();

    final startOfDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final endOfDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      23,
      59,
      59,
    );

    // ── Single query, no composite index needed ──────────────────────────────
    Query<Map<String, dynamic>> base = _collection;
    if (forceStaffFilter && staffId.isNotEmpty) {
      base = base.where('assignedStaffId', isEqualTo: staffId);
    } else if (role.toLowerCase() != 'admin') {
      base = base.where('assignedStaffId', isEqualTo: staffId);
    }

    // ONE round-trip to Firestore — no subcollection reads at all
    final snap = await base.get();
    log('[fetchLeadCounts] docs: ${snap.docs.length}');

    int newLeadCount = 0;
    int followUpCount = 0;
    int closedLeadCount = 0;
    int totalCalledCount = 0;
    int missedLeadCount = 0;
    int transferredCount = 0;

    for (final doc in snap.docs) {
      final data = doc.data();
      final leadStage = (data['leadStage'] ?? '').toString().toUpperCase();

      // ── NEW ────────────────────────────────────────────────────────────
      if (leadStage == 'NEW') {
        final createdAt = data['createdAt'];
        if (createdAt != null) {
          final createdDate = (createdAt as Timestamp).toDate();
          if (_isInRange(createdDate, startOfDay, endOfDay)) {
            final hasFollowUp = data['hasFollowUp'] as bool? ?? false;
            if (!hasFollowUp) newLeadCount++;
          }
        }
      }

      // ── FOLLOWUP ───────────────────────────────────────────────────────
      if (leadStage == 'FOLLOWUP') {
        final nextFollowUpDate = data['nextFollowUpDate'];
        if (nextFollowUpDate != null) {
          final followDate = (nextFollowUpDate as Timestamp).toDate();
          if (_isInRange(followDate, startOfDay, endOfDay)) followUpCount++;
        }
      }

      // ── CLOSED ─────────────────────────────────────────────────────────
      if (leadStage == 'CLOSED') {
        final lastCalledDate = data['lastCalledDate'];
        final createdAt = data['createdAt'];
        if (lastCalledDate != null) {
          final calledDate = (lastCalledDate as Timestamp).toDate();
          if (_isInRange(calledDate, startOfDay, endOfDay)) closedLeadCount++;
        } else if (createdAt != null) {
          final createdDate = (createdAt as Timestamp).toDate();
          if (_isInRange(createdDate, startOfDay, endOfDay)) closedLeadCount++;
        }
      }

      // ── TOTAL CALLED ───────────────────────────────────────────────────
      final lastCalledDate = data['lastCalledDate'];
      if (lastCalledDate != null) {
        final calledDate = (lastCalledDate as Timestamp).toDate();
        if (_isInRange(calledDate, startOfDay, endOfDay)) totalCalledCount++;
      }

      // ── MISSED ─────────────────────────────────────────────────────────
      if (leadStage == 'FOLLOWUP' || leadStage == 'NEW') {
        final nextFollowUpDate = data['nextFollowUpDate'];
        if (nextFollowUpDate != null) {
          final followDate = (nextFollowUpDate as Timestamp).toDate();
          if (_isBeforeDay(followDate, startOfDay)) missedLeadCount++;
        }
      }

      // ── TRANSFERRED ────────────────────────────────────────────────────
      if (leadStage == 'TRANSFERRED') {
        final transferredList = data['transferLeads'];
        if (transferredList is List) {
          bool counted = false;
          for (final item in transferredList) {
            if (counted) break;
            if (item is Map<String, dynamic>) {
              final t = item['transferTime'];
              if (t != null) {
                final td = (t as Timestamp).toDate();
                if (_isInRange(td, startOfDay, endOfDay)) {
                  transferredCount++;
                  counted = true;
                }
              }
            }
          }
        }
      }
    }

    sw.stop();
    log(
      '[fetchLeadCounts] new:$newLeadCount followUp:$followUpCount '
      'closed:$closedLeadCount total:$totalCalledCount '
      'missed:$missedLeadCount transferred:$transferredCount '
      '— ${sw.elapsedMilliseconds}ms',
    );

    return DashboardCountModel(
      newLeadCount: newLeadCount,
      followUpCount: followUpCount,
      closedLeadCount: closedLeadCount,
      totalCalledCount: totalCalledCount,
      missedLeadCount: missedLeadCount,
      transferredCount: transferredCount,
    );
  }

  // ── Add this helper if not already present ──────────────────────────────────
  bool _isInRange(DateTime date, DateTime start, DateTime end) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  @override
  Future<void> _logActivity(String leadId, ActivityModel activity) async {
    await _collection
        .doc(leadId)
        .collection('ACTIVITIES')
        .doc()
        .set(activity.toFirestore());
  }

  Future<void> logLeadCreated({
    required String leadId,
    required String createdByName,
    required String createdById,
    required String assignedTo,
    required String leadStage,
    required String priority,
    required String leadCategory,
  }) async {
    await _logActivity(
      leadId,
      ActivityModel(
        id: '',
        type: ActivityType.leadCreated,
        changedBy: createdByName,
        changedById: createdById,
        changedAt: DateTime.now(),
        previousValue: null,
        newValue: leadStage,
        description:
            'Lead created. Assigned to $assignedTo.'
            '${leadStage.isNotEmpty ? ' Stage: $leadStage.' : ''}'
            '${priority.isNotEmpty ? ' Priority: $priority.' : ''}'
            '${leadCategory.isNotEmpty ? ' Category: $leadCategory.' : ''}',
      ),
    );
  }

  Future<void> logLeadUpdated({
    required String leadId,
    required String changedByName,
    required String changedById,
    required AddLeadModel previous,
    required AddLeadModel updated,
  }) async {
    final now = DateTime.now();
    final batch = FirebaseFirestore.instance.batch();
    final activityRef = _collection.doc(leadId).collection('ACTIVITIES');

    void log(
      ActivityType type,
      String field,
      String prev,
      String next,
      String desc,
    ) {
      if (prev == next || next.isEmpty) return;
      batch.set(
        activityRef.doc(),
        ActivityModel(
          id: '',
          type: type,
          changedBy: changedByName,
          changedById: changedById,
          changedAt: now,
          previousValue: prev,
          newValue: next,
          description: desc,
        ).toFirestore(),
      );
    }

    log(
      ActivityType.statusChanged,
      'stage',
      previous.leadStage,
      updated.leadStage,
      'Status changed from ${previous.leadStage} to ${updated.leadStage}.',
    );
    log(
      ActivityType.categoryChanged,
      'category',
      previous.leadCategory,
      updated.leadCategory,
      'Category updated from ${previous.leadCategory} to ${updated.leadCategory}.',
    );
    log(
      ActivityType.priorityChanged,
      'priority',
      previous.priority,
      updated.priority,
      'Priority updated from ${previous.priority} to ${updated.priority}.',
    );
    log(
      ActivityType.staffAssigned,
      'staff',
      previous.assignedStaff,
      updated.assignedStaff,
      'Assigned staff changed from ${previous.assignedStaff} to ${updated.assignedStaff}.',
    );
    // log(ActivityType.costUpdated,     'cost',     previous.cost ?? '',   updated.cost ?? '',   'Cost updated from ${previous.cost} to ${updated.cost}.');
    log(
      ActivityType.remarkUpdated,
      'remarks',
      previous.remarks ?? '',
      updated.remarks ?? '',
      'Remark updated.',
    );

    // Only commit if there's at least one change
    final ops = batch; // batch will be a no-op if nothing was added
    await ops.commit();
  }

  Future<List<LeadStaffHandler>> getLeadHandledStaffs(AddLeadModel lead) async {
    // Collect raw staff entries: {staffId -> staffName}
    // Order matters — insertion order = chronological
    final Map<String, String> staffMap = {};

    // 1. Lead creator is always first
    if (lead.createdById.isNotEmpty) {
      staffMap[lead.createdById] = lead.createdBy ?? '';
    }

    // 2. Assigned staff (may be same as creator — dedup handled by map key)
    if (lead.assignedStaffId.isNotEmpty) {
      staffMap[lead.assignedStaffId] = lead.assignedStaff;
    }

    // 3. All transfer participants (fromStaff and toStaff)
    final transferSnap = await _collection
        .doc(lead.id)
        .collection('TRANSFER_LEADS')
        .orderBy('transferTime')
        .get();

    for (final doc in transferSnap.docs) {
      final data = doc.data();
      final fromId = data['fromStaffId'] as String? ?? '';
      final fromName = data['fromStaff'] as String? ?? '';
      final toId = data['toStaffId'] as String? ?? '';
      final toName = data['toStaff'] as String? ?? '';
      if (fromId.isNotEmpty) staffMap.putIfAbsent(fromId, () => fromName);
      if (toId.isNotEmpty) staffMap.putIfAbsent(toId, () => toName);
    }

    // 4. Count follow-ups per staff (activity count)
    final fupSnap = await _collection
        .doc(lead.id)
        .collection('FOLLOW_UPS')
        .get();

    final Map<String, int> fupCount = {};
    for (final doc in fupSnap.docs) {
      final creatorId = doc.data()['createdById'] as String? ?? '';
      if (creatorId.isNotEmpty) {
        fupCount[creatorId] = (fupCount[creatorId] ?? 0) + 1;
      }
    }

    // 5. Fetch phone numbers from STAFF collection in parallel
    final staffIds = staffMap.keys.toList();
    final phoneMap = <String, String>{};

    await Future.wait(
      staffIds.map((id) async {
        try {
          final doc = await FirestorePath.companyCollection(
            'STAFF',
          ).doc(id).get();
          phoneMap[id] = doc.data()?['phone'] as String? ?? '';
        } catch (_) {
          phoneMap[id] = '';
        }
      }),
    );

    // 6. Build result list — same order as staffMap insertion
    return staffIds.map((id) {
      return LeadStaffHandler(
        staffId: id,
        staffName: staffMap[id] ?? '',
        phone: phoneMap[id] ?? '',
        // +1 for the lead creation itself by the creator
        activityCount: (fupCount[id] ?? 0) + (id == lead.createdById ? 1 : 0),
        isCurrentAssignee: id == lead.assignedStaffId,
      );
    }).toList();
  }

  Future<Map<String, int>> fetchLeadCountsByCategory({
    required String staffId,
    required String role,
    required DateTime selectedDate,
    DateTime? toDate,
  }) async {
    Query<Map<String, dynamic>> query = _collection;

    if (staffId.isNotEmpty) {
      query = query.where(
        'assignedStaffId',
        isEqualTo: staffId,
      ); // ← always filter
    }

    // ── Date filter ──────────────────────────────────────────────────────
    final from = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final to = toDate != null
        ? DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59)
        : DateTime(from.year, from.month, from.day, 23, 59, 59);

    query = query
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(to));
    // ─────────────────────────────────────────────────────────────────────

    final snap = await query.get();

    final Map<String, int> counts = {
      'New': 0,
      'Follow Up': 0,
      'Rejected': 0,
      'Closed': 0,
      'Transferred': 0,
    };

    for (final doc in snap.docs) {
      final data = doc.data();
      final stage = (data['leadStage'] ?? '').toString().toUpperCase();

      switch (stage) {
        case 'NEW':
          counts['New'] = (counts['New'] ?? 0) + 1;
          break;
        case 'FOLLOW UP':
        case 'FOLLOWUP':
          counts['Follow Up'] = (counts['Follow Up'] ?? 0) + 1;
          break;
        case 'REJECTED':
          counts['Rejected'] = (counts['Rejected'] ?? 0) + 1;
          break;
        case 'CLOSED':
          counts['Closed'] = (counts['Closed'] ?? 0) + 1;
          break;
        case 'TRANSFERRED':
          counts['Transferred'] = (counts['Transferred'] ?? 0) + 1;
          break;
        default:
          counts['Pending'] = (counts['Pending'] ?? 0) + 1;
          break;
      }
    }

    return counts;
  }

  // In your AddLeadRepository
  Future<List<LeadCategoryTableRow>> fetchLeadCategoryTableRows({
    required String staffId,
    required String role,
    required DateTime selectedDate,
    DateTime? toDate,
  }) async {
    // ← Remove the date filter, fetch all leads for this staff
    Query<Map<String, dynamic>> query = _collection;

    // Always filter by staffId for staff profile view
    if (staffId.isNotEmpty) {
      query = query.where('assignedStaffId', isEqualTo: staffId);
    }

    // ── Date filter ──────────────────────────────────────────────────────
    final from = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final to = toDate != null
        ? DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59)
        : DateTime(from.year, from.month, from.day, 23, 59, 59);

    query = query
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(to));
    // ─────────────────────────────────────────────────────────────────────

    final snapshot = await query.get();

    // Group by leadCategory → then count by leadStage
    final Map<String, Map<String, int>> grouped = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final category = (data['leadCategory'] as String? ?? 'Uncategorized')
          .trim()
          .toUpperCase();
      final stage = (data['leadStage'] as String? ?? '').trim().toUpperCase();

      // Use display-friendly category name
      final displayCategory = category.isEmpty ? 'Uncategorized' : category;

      grouped.putIfAbsent(
        displayCategory,
        () => {'NEW': 0, 'FOLLOW UP': 0, 'REJECTED': 0, 'CLOSED': 0},
      );

      if (stage == 'NEW') {
        grouped[displayCategory]!['NEW'] =
            (grouped[displayCategory]!['NEW'] ?? 0) + 1;
      } else if (stage == 'FOLLOW UP' || stage == 'FOLLOWUP') {
        grouped[displayCategory]!['FOLLOW UP'] =
            (grouped[displayCategory]!['FOLLOW UP'] ?? 0) + 1;
      } else if (stage == 'REJECTED') {
        grouped[displayCategory]!['REJECTED'] =
            (grouped[displayCategory]!['REJECTED'] ?? 0) + 1;
      } else if (stage == 'CLOSED') {
        grouped[displayCategory]!['CLOSED'] =
            (grouped[displayCategory]!['CLOSED'] ?? 0) + 1;
      }
    }

    // Sort by total count descending so most active categories appear first
    final rows = grouped.entries
        .map(
          (e) => LeadCategoryTableRow(
            category: e.key,
            newCount: e.value['NEW'] ?? 0,
            followUpCount: e.value['FOLLOW UP'] ?? 0,
            rejectedCount: e.value['REJECTED'] ?? 0,
            closedCount: e.value['CLOSED'] ?? 0,
          ),
        )
        .toList();

    rows.sort((a, b) {
      final totalA =
          a.newCount + a.followUpCount + a.rejectedCount + a.closedCount;
      final totalB =
          b.newCount + b.followUpCount + b.rejectedCount + b.closedCount;
      return totalB.compareTo(totalA);
    });

    return rows;
  }

  static const Map<String, bool> callResultConnectionMap = {
    'connected': true,
    'answered': true,
    'busy': false,
    'not attended': false,
    'notattended': false,
    'out of coverage area': false,
    'outofcoveragearea': false,
    'rejected': false,
    'switched off': false,
    'switchedoff': false,
    'no answer': false,
    'noanswer': false,
  };

  static bool isCallConnected(String status) {
    final normalized = status.toLowerCase().trim();
    if (normalized.isEmpty) return false;
    if (callResultConnectionMap.containsKey(normalized)) {
      return callResultConnectionMap[normalized]!;
    }
    // Fallback: If it contains 'connect' or 'answer', assume connected; otherwise, not connected.
    if (normalized.contains('connect') || normalized.contains('answer')) {
      return true;
    }
    return false;
  }

  Future<Map<String, int>> fetchCallStatusCounts({
    required String staffId,
    required String role,
    DateTime? selectedDate,
    DateTime? toDate,
  }) async {
    Timestamp? fromTs;
    Timestamp? toTs;
    if (selectedDate != null) {
      final from = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      final to = toDate != null
          ? DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59)
          : DateTime(from.year, from.month, from.day, 23, 59, 59);
      fromTs = Timestamp.fromDate(from);
      toTs = Timestamp.fromDate(to);
    }

    // Query FOLLOW_UPS subcollection across all leads for this staff
    Query<Map<String, dynamic>> query = _firestore
        .collectionGroup('FOLLOW_UPS')
        .where('createdById', isEqualTo: staffId);

    if (fromTs != null && toTs != null) {
      query = query
          .where('createdAt', isGreaterThanOrEqualTo: fromTs)
          .where('createdAt', isLessThanOrEqualTo: toTs);
    }

    final snap = await query.get();

    int totalCalled = 0;
    int connected = 0;
    int notConnected = 0;
    final Map<String, int> detailedCounts = {};

    for (final doc in snap.docs) {
      final data = doc.data();
      final calledStatus = (data['calledStatus'] as String? ?? '').trim();

      if (calledStatus.isNotEmpty) {
        // Capitalize first letter of each word to look clean on UI
        final normalized = calledStatus
            .split(RegExp(r'\s+'))
            .map((word) {
              if (word.isEmpty) return '';
              return word[0].toUpperCase() + word.substring(1).toLowerCase();
            })
            .join(' ');

        if (normalized.isNotEmpty) {
          detailedCounts[normalized] = (detailedCounts[normalized] ?? 0) + 1;
        }

        totalCalled++;

        if (isCallConnected(calledStatus)) {
          connected++;
        } else {
          notConnected++;
        }
      }
    }

    return {
      'totalCalled': totalCalled,
      'connected': connected,
      'notConnected': notConnected,
      ...detailedCounts,
    };
  }

  Future<AddLeadModel> getLeadById(String leadId) async {
    try {
      final leadDoc = await _collection.doc(leadId).get();

      if (!leadDoc.exists) {
        throw Exception('Lead not found');
      }

      final followUpSnap = await _collection
          .doc(leadId)
          .collection('FOLLOW_UPS')
          .orderBy('createdAt', descending: true)
          .get();

      final followUps = followUpSnap.docs
          .map((e) => FollowUpModel.fromFirestore(e.data(), e.id))
          .toList();

      final lead = AddLeadModel.fromFirestore(leadDoc.data()!, leadDoc.id);

      return lead.copyWith(followUp: followUps);
    } catch (e) {
      throw Exception('Failed to fetch lead: $e');
    }
  }

  // Future<void> deleteFollowUp({
  //   required String leadId,
  //   required String followUpId,
  // }) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('LEADS')
  //         .doc(leadId)
  //         .collection('FOLLOW_UPS')
  //         .doc(followUpId)
  //         .delete();
  //   } catch (e) {
  //     throw Exception('Failed to delete follow-up: $e');
  //   }
  // }

  Future<void> deleteFollowUp({
    required String leadId,
    required String followUpId,
    required String changedByName,
    required String changedById,
    required String leadName,
    required String leadPhone,
  }) async {
    final leadRef = _collection.doc(leadId);

    final activityRef = leadRef.collection('ACTIVITIES');

    // Read followup BEFORE deleting
    final deletedDoc = await leadRef
        .collection('FOLLOW_UPS')
        .doc(followUpId)
        .get();

    if (!deletedDoc.exists) {
      throw Exception('Follow-up not found');
    }

    final deletedFollowup = FollowUpModel.fromFirestore(
      deletedDoc.data()!,
      deletedDoc.id,
    );

    // Delete followup
    await deletedDoc.reference.delete();

    // Find the next latest followup
    final remaining = await leadRef
        .collection('FOLLOW_UPS')
        .orderBy('calledDate', descending: true)
        .limit(1)
        .get();

    if (remaining.docs.isNotEmpty) {
      final latest = FollowUpModel.fromFirestore(
        remaining.docs.first.data(),
        remaining.docs.first.id,
      );

      await leadRef.update({
        'leadStage': latest.leadStage,
        'priority': latest.priority,
        'leadCategory': latest.leadCategory,
        'followUpDate': latest.nextFollowUpDate,
        'calledDate': latest.calledDate,
        'callResult': latest.calledStatus,
        'remarks': latest.remarks,
      });
    }

    // Log activity
    await activityRef.add(
      ActivityModel(
        id: '',
        type: ActivityType.followupDeleted,
        changedBy: changedByName,
        changedById: changedById,
        changedAt: DateTime.now(),
        leadId: leadId,
        leadName: leadName,
        leadPhone: leadPhone,
        previousValue: deletedFollowup.calledStatus,
        newValue: '',
        description:
            'Deleted follow-up. Status: ${deletedFollowup.leadStage}, '
            'Call Result: ${deletedFollowup.calledStatus}, '
            'Scheduled Date: ${DateFormat('dd-MM-yyyy HH:mm').format(deletedFollowup.nextFollowUpDate)}',
      ).toFirestore(),
    );
  }

  @override
  Future<bool> isContactNumberExists(String contactNumber) async {
    final snap = await _collection
        .where('contactNumber', isEqualTo: contactNumber.trim())
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }
}

Future<void> migrateHasFollowUp() async {
  final db = FirebaseFirestore.instance;
  final leadsSnap = await db.collection('LEADS').get();

  int updated = 0;
  int skipped = 0;

  for (final leadDoc in leadsSnap.docs) {
    final data = leadDoc.data();

    // Skip if already set
    if (data.containsKey('hasFollowUp')) {
      skipped++;
      continue;
    }

    // Check if this lead has any follow-ups
    final followUpsSnap = await db
        .collection('LEADS')
        .doc(leadDoc.id)
        .collection('FOLLOW_UPS')
        .limit(1)
        .get();

    final hasFollowUp = followUpsSnap.docs.isNotEmpty;

    await db.collection('LEADS').doc(leadDoc.id).update({
      'hasFollowUp': hasFollowUp,
    });

    updated++;
    print('Updated ${leadDoc.id} → hasFollowUp: $hasFollowUp');
  }

  print('Migration complete. Updated: $updated, Skipped: $skipped');
}
