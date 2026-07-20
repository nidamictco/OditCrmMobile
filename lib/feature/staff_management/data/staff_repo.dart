import 'dart:io';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:odit_crm_mobile/core/constant/firebase_constant.dart';
import 'package:odit_crm_mobile/feature/staff_management/model/staff_model.dart';


class StaffRepository {
  final FirebaseFirestore _firestore;

  StaffRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // final cloudinary = CloudinaryPublic('dqwde64fn', 'profile_image');

  // ─── Collection references ────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestorePath.companyCollection('STAFF');

  CollectionReference<Map<String, dynamic>> get _deletedCollection =>
      FirestorePath.companyCollection('DELETED_STAFF');

  // ─── Update single field ──────────────────────────────────────────────────

  Future<void> updateStaffField(
      String id, Map<String, dynamic> fields) async {
    await _collection.doc(id).update(fields);
    log('[StaffRepository] Staff field updated: $id → $fields');
  }

  // ─── Soft delete (move to DELETED_STAFF) ─────────────────────────────────

  Future<void> moveToDeleted(StaffModel staff) async {
    assert(staff.id != null, 'ID must not be null');

    final deletedStaff = staff.copyWith(deletedAt: DateTime.now());

    await _deletedCollection.add(deletedStaff.toMap());
    await _collection.doc(staff.id).delete();

    log('[StaffRepository] Staff moved to DELETED_STAFF: ${staff.id}');
  }

  // ─── Hard delete ──────────────────────────────────────────────────────────

  Future<void> deleteStaff(String id) async {
    await _collection.doc(id).delete();
    log('[StaffRepository] Staff deleted: $id');
  }

  // ─── Fetch all ────────────────────────────────────────────────────────────

  Future<List<StaffModel>> fetchAll() async {
    final snap =
        await _collection.orderBy('createdAt', descending: true).get();
    return snap.docs.map(StaffModel.fromFirestore).toList();
  }

  // ─── Real-time stream ─────────────────────────────────────────────────────

  Stream<List<StaffModel>> streamAll() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(StaffModel.fromFirestore).toList());
  }

  // ─── Fetch single ─────────────────────────────────────────────────────────

  Future<StaffModel?> getStaff(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return StaffModel.fromFirestore(doc);
  }


Future<String?> getSessionId(String staffId) async {
  final doc = await FirestorePath.companyCollection('STAFF').doc(staffId).get();
  return doc.data()?['sessionId'] as String?;
}



  // ─── Fetch deleted staff ──────────────────────────────────────────────────

  Future<List<StaffModel>> fetchDeletedStaff() async {
    final snap = await _deletedCollection
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(StaffModel.fromFirestore).toList();
  }

  // ─── Permanently delete ───────────────────────────────────────────────────

  Future<void> deleteStaffPermanently(String id) async {
    await _deletedCollection.doc(id).delete();
    log('[StaffRepository] Staff deleted permanently: $id');
  }
// --------------------------------------------------
Future<void> updateSessionId(String staffId, String sessionId) async {
  await FirestorePath.companyCollection('STAFF').doc(staffId).set(
    {'sessionId': sessionId},
    SetOptions(merge: true),
  );
}

Future<void> clearSessionId(String staffId) async {
  await FirestorePath.companyCollection('STAFF').doc(staffId).update({
    'sessionId': FieldValue.delete(),
  });
}

Stream<DocumentSnapshot<Map<String, dynamic>>> watchStaffDoc(String staffId) {
  return FirestorePath.companyCollection('STAFF').doc(staffId).snapshots();
}
 
}