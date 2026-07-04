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

  // CollectionReference<Map<String, dynamic>> get _collection =>
  //     _firestore.collection('STAFF');
  //
  // CollectionReference<Map<String, dynamic>> get _deletedCollection =>
  //     _firestore.collection('DELETED_STAFF');

  // ─── Upload file to Cloudinary ────────────────────────────────────────────

  // Future<String> uploadFile({
  //   required File file,
  //   required String folder,
  // }) async {
  //   try {
  //     final CloudinaryResponse res = await cloudinary.uploadFile(
  //       CloudinaryFile.fromFile(
  //         file.path,
  //         folder: folder,
  //       ),
  //     );
  //     return res.secureUrl;
  //   } catch (e) {
  //     throw Exception('Upload failed: $e');
  //   }
  // }

//   /// Upload from bytes — used on Flutter Web where dart:io File is unavailable.
// Future<String> uploadFileBytes({
//   required Uint8List bytes,
//   required String folder,
//   required String fileName,
// }) async {
//   try {
//     final CloudinaryResponse res = await cloudinary.uploadFile(
//       CloudinaryFile.fromBytesData(
//         bytes,
//         identifier: fileName,
//         folder: folder,
//       ),
//     );
//     return res.secureUrl;
//   } catch (e) {
//     throw Exception('Upload failed: $e');
//   }
// }

  // ─── Add ──────────────────────────────────────────────────────────────────

//   Future<String> addStaff(
//   StaffModel staff, {
//   File? imageFile,
//   Uint8List? imageBytes,   // ← add
//   String? imageFileName,  // ← add
//   File? documentFile,
//   Uint8List? documentBytes,   // ← add
//   String? documentFileName,   // ← add
// }) async {
//   // Check if phone number already exists globally in USERS collection
//   final existingUser = await _firestore
//       .collection("USERS")
//       .where("phone", isEqualTo: staff.phone.trim())
//       .limit(1)
//       .get();

//   if (existingUser.docs.isNotEmpty) {
//     throw Exception("Phone number already exists.");
//   }

//   String? imageUrl = staff.imageUrl;
//   String? documentUrl = staff.documentUrl;

//   if (kIsWeb) {
//     if (imageBytes != null && imageFileName != null) {
//       imageUrl = await uploadFileBytes(
//         bytes: imageBytes,
//         folder: 'staff_images',
//         fileName: imageFileName,
//       );
//     }
//     if (documentBytes != null && documentFileName != null) {
//       documentUrl = await uploadFileBytes(
//         bytes: documentBytes,
//         folder: 'staff_docs',
//         fileName: documentFileName,
//       );
//     }
//   } else {
//     if (imageFile != null) {
//       imageUrl = await uploadFile(file: imageFile, folder: 'staff_images');
//     }
//     if (documentFile != null) {
//       documentUrl = await uploadFile(file: documentFile, folder: 'staff_docs');
//     }
//   }

//   final data = staff.copyWith(
//     imageUrl: imageUrl,
//     documentUrl: documentUrl,
//     createdAt: DateTime.now(),
//   );

//   final doc = await _collection.add(data.toMap());
//   log('[StaffRepository] Staff added: ${doc.id}');
//   return doc.id;
// }
  // ─── Update ───────────────────────────────────────────────────────────────

//  Future<void> updateStaff(
//   StaffModel staff, {
//   File? imageFile,
//   Uint8List? imageBytes,
//   String? imageFileName,
//   File? documentFile,
//   Uint8List? documentBytes,
//   String? documentFileName,
// }) async {
//   assert(staff.id != null, 'ID must not be null for update');

//   String? imageUrl = staff.imageUrl;
//   String? documentUrl = staff.documentUrl;

//   if (kIsWeb) {
//     if (imageBytes != null && imageFileName != null) {
//       imageUrl = await uploadFileBytes(
//         bytes: imageBytes,
//         folder: 'staff_images',
//         fileName: imageFileName,
//       );
//       log('[StaffRepository] Image uploaded (web): $imageUrl');
//     }
//     if (documentBytes != null && documentFileName != null) {
//       documentUrl = await uploadFileBytes(
//         bytes: documentBytes,
//         folder: 'staff_docs',
//         fileName: documentFileName,
//       );
//       log('[StaffRepository] Document uploaded (web): $documentUrl');
//     }
//   } else {
//     if (imageFile != null) {
//       imageUrl = await uploadFile(file: imageFile, folder: 'staff_images');
//       log('[StaffRepository] Image uploaded: $imageUrl');
//     }
//     if (documentFile != null) {
//       documentUrl = await uploadFile(file: documentFile, folder: 'staff_docs');
//       log('[StaffRepository] Document uploaded: $documentUrl');
//     }
//   }

//   await _collection.doc(staff.id).update(
//         staff
//             .copyWith(imageUrl: imageUrl, documentUrl: documentUrl)
//             .toMap()
//             ..remove('createdAt'),
//       );
//   log('[StaffRepository] Staff updated: ${staff.id}');
// // }
// Future<void> updateStaff(
//   StaffModel staff, {
//   File? imageFile,
//   Uint8List? imageBytes,
//   String? imageFileName,
//   File? documentFile,
//   Uint8List? documentBytes,
//   String? documentFileName,
// }) async {
//   assert(staff.id != null, 'ID must not be null for update');

//   String? imageUrl = staff.imageUrl;   // already null if user removed it
//   String? documentUrl = staff.documentUrl;

//   if (kIsWeb) {
//     if (imageBytes != null && imageFileName != null) {
//       imageUrl = await uploadFileBytes(bytes: imageBytes, folder: 'staff_images', fileName: imageFileName);
//     }
//     if (documentBytes != null && documentFileName != null) {
//       documentUrl = await uploadFileBytes(bytes: documentBytes, folder: 'staff_docs', fileName: documentFileName);
//     }
//   } else {
//     if (imageFile != null) {
//       imageUrl = await uploadFile(file: imageFile, folder: 'staff_images');
//     }
//     if (documentFile != null) {
//       documentUrl = await uploadFile(file: documentFile, folder: 'staff_docs');
//     }
//   }

//   // Preserve designation if it is Company_Admin
//   final doc = await _collection.doc(staff.id).get();
//   String? originalDesignation;
//   String? originalDesignationId;
//   String? originalStaffType;
//   String? originalPhone;
//   if (doc.exists) {
//     originalDesignation = doc.data()?['designation'] as String?;
//     originalDesignationId = doc.data()?['designationId'] as String?;
//     originalStaffType = doc.data()?['staffType'] as String?;
//     originalPhone = doc.data()?['phone'] as String?;
//   }

//   // If phone number has changed, perform global uniqueness check
//   if (originalPhone != staff.phone) {
//     final existingUser = await _firestore
//         .collection("USERS")
//         .where("phone", isEqualTo: staff.phone.trim())
//         .get();

//     for (var userDoc in existingUser.docs) {
//       if (userDoc.id != staff.id) {
//         throw Exception("Phone number already exists.");
//       }
//     }
//   }

//   final isCompanyAdmin = originalDesignation == "Company_Admin";
//   final finalStaff = isCompanyAdmin
//       ? staff.copyWith(
//           designation: originalDesignation,
//           designationId: originalDesignationId,
//           staffType: originalStaffType,
//         )
//       : staff;

//   // Use set with merge:false on only the changed fields, 
//   // so null imageUrl is explicitly written to Firestore
//   final updatedData = finalStaff
//       .copyWith(imageUrl: imageUrl, documentUrl: documentUrl)
//       .toMap()
//     ..remove('createdAt');

//   // ← explicitly null out imageUrl in Firestore if removed
//   if (imageUrl == null) {
//     updatedData['imageUrl'] = null;
//   }

//   await _collection.doc(staff.id).update(updatedData);
//   log('[StaffRepository] Staff updated: ${staff.id}');
// }

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

  // ─── Restore from deleted ─────────────────────────────────────────────────

  // Future<String> restoreStaff(
  //   StaffModel staff, {
  //   File? imageFile,
  //   File? documentFile,
  // }) async {
  //   String? imageUrl = staff.imageUrl;
  //   String? documentUrl = staff.documentUrl;

  //   if (imageFile != null) {
  //     imageUrl = await uploadFile(file: imageFile, folder: 'staff_images');
  //     log('[StaffRepository] Image uploaded: $imageUrl');
  //   }

  //   if (documentFile != null) {
  //     documentUrl =
  //         await uploadFile(file: documentFile, folder: 'staff_docs');
  //     log('[StaffRepository] Document uploaded: $documentUrl');
  //   }

  //   final finalStaff = staff.copyWith(
  //     imageUrl: imageUrl,
  //     documentUrl: documentUrl,
  //     createdAt: DateTime.now(),
  //   );

  //   final docRef = await _collection.add(finalStaff.toMap());
  //   await _deletedCollection.doc(staff.id).delete();

  //   log('[StaffRepository] Staff restored: ${docRef.id}');
  //   return docRef.id;
  // }

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

 
}