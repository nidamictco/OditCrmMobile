import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odit_crm_mobile/core/constant/firebase_collection.dart';
import 'package:odit_crm_mobile/core/constant/firebase_constant.dart';
import 'package:odit_crm_mobile/feature/staff_management/Screen/model/staff_model.dart';


// class FirebaseAuthService {
//   FirebaseAuthService({FirebaseFirestore? firestore})
//     : _firestore = firestore ?? FirebaseFirestore.instance;

//   final FirebaseFirestore _firestore;

//   // CollectionReference<Map<String, dynamic>> get _staff =>
//   //     _firestore.collection('STAFF');

//   CollectionReference<Map<String, dynamic>> get staff =>
//       FirestorePath.companyCollection(DBCollections.staff);

//   static CollectionReference<Map<String, dynamic>> get users =>
//       FirebaseFirestore.instance.collection(DBCollections.users);

//   Future<StaffModel> login({
//     required String phoneNo,
//     required String password,
//     // required String companyId,
//   }) async {
//     try {
//       final rawPhone = phoneNo.trim();
//       final List<String> possiblePhones = [rawPhone, rawPhone.replaceAll(' ', '')];
//       log("phoneNo: ${phoneNo}, possiblePhones: ${possiblePhones}");
//       // if (rawPhone.length == 10 && !rawPhone.startsWith('+')) {
//       //   possiblePhones.add('+91$rawPhone');
//       //   possiblePhones.add('+91 $rawPhone');
//       //   possiblePhones.add('91$rawPhone');
//       // } else if (rawPhone.startsWith('+91')) {
//       //   final digits = rawPhone.substring(3).trim();
//       //   possiblePhones.add(digits);
//       //   possiblePhones.add('91$digits');
//       // } else if (rawPhone.startsWith('91') && rawPhone.length == 12) {
//       //   final digits = rawPhone.substring(2);
//       //   possiblePhones.add(digits);
//       //   possiblePhones.add('+$rawPhone');
//       // }

//       // ====================================================
//       // 1. CHECK USERS COLLECTION
//       // ====================================================

//       final userQuery = await users
//           .where('phone', whereIn: possiblePhones)
//           .limit(1)
//           .get();

//       StaffModel? userModel;

//       if (userQuery.docs.isNotEmpty) {
//         final doc = userQuery.docs.first;
//         final data = doc.data();

//         if ((data['password'] ?? '') != password) {
//           throw AuthException('Incorrect password.');
//         }

//         userModel = StaffModel.fromFirestore(doc);
//         if (userModel.companyId != null && userModel.companyId!.isNotEmpty) {
//           FirestorePath.initializeCompany(userModel.companyId!);
//           log(
//             'Company initialized from USERS document: ${userModel.companyId}',
//           );
//         }
//       } else {
//         // ====================================================
//         // 2. CHECK SPECIFIC COMPANY STAFF SUBCOLLECTION
//         // ====================================================

//         final staffQuery = await _firestore
//             .collection('COMPANY')
//             .doc(companyId)
//             .collection(DBCollections.staff)
//             .where('phone', whereIn: possiblePhones)
//             .limit(1)
//             .get();

//         if (staffQuery.docs.isEmpty) {
//           throw AuthException('No account found.');
//         }

//         final doc = staffQuery.docs.first;
//         final data = doc.data();

//         if ((data['password'] ?? '') != password) {
//           throw AuthException('Incorrect password.');
//         }

//         FirestorePath.initializeCompany(companyId);

//         log('Company initialized: $companyId');

//         userModel = StaffModel.fromFirestore(doc);
//       }

//       // ====================================================
//       // 4. CHECK COMPANY STATUS
//       // ====================================================
//       final resolvedCompanyId = userModel.companyId;
//       if (userModel.companyType != 'mother_company' && resolvedCompanyId != null && resolvedCompanyId.isNotEmpty) {
//         final compDoc = await _firestore.collection('COMPANY').doc(resolvedCompanyId).get();
//         if (compDoc.exists) {
//           final compStatus = (compDoc.data()?['status'] as String? ?? 'PENDING').toUpperCase();
//           if (compStatus == 'SUSPENDED' || compStatus == 'PENDING') {
//             throw const AuthException('Account is suspended. Need to upgrade plan.');
//           }
//           userModel = userModel.copyWith(companyStatus: compStatus);
//         }
//       }

//       return userModel;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Future<StaffModel> login({
//   //   required String phoneNo,
//   //   required String password,
//   // }) async {
//   //   try {
//   //     log('[FirebaseAuthService] Querying STAFF where PHONE == $phoneNo');
//   //
//   //     final query = await _staff
//   //         .where('phone', isEqualTo: phoneNo.trim())
//   //         .limit(1)
//   //         .get();
//   //
//   //     log('[FirebaseAuthService] Docs found: ${query.docs.length}');
//   //
//   //     if (query.docs.isEmpty) {
//   //       throw AuthException('No account found for "$phoneNo".');
//   //     }
//   //
//   //     final doc = query.docs.first;
//   //     final data = doc.data();
//   //
//   //     log('[FirebaseAuthService] Raw doc data: $data');
//   //
//   //     final storedPassword = data['password'] as String? ?? '';
//   //
//   //     if (storedPassword != password) {
//   //       throw AuthException('Incorrect password.');
//   //     }
//   //
//   //     try {
//   //       final user = StaffModel.fromFirestore(doc);
//   //       log('[FirebaseAuthService] UserModel built: $user');
//   //       return user;
//   //     } catch (e) {
//   //       log('[FirebaseAuthService] fromMap parse error: $e  |  raw data: $data');
//   //       throw AuthException('Failed to parse user data: $e');
//   //     }
//   //   } on AuthException {
//   //     rethrow;
//   //   } on FirebaseException catch (e) {
//   //     log('[FirebaseAuthService] FirebaseException: ${e.message}');
//   //     throw AuthException('Firebase error: ${e.message}');
//   //   } catch (e, st) {
//   //     log('[FirebaseAuthService] Unexpected: $e', stackTrace: st);
//   //     throw AuthException('Unexpected error: $e');
//   //   }
//   // }
// }

// class AuthException implements Exception {
//   final String message;
//   const AuthException(this.message);

//   @override
//   String toString() => message;
// }


import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';


class FirebaseAuthService {
  FirebaseAuthService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // CollectionReference<Map<String, dynamic>> get _staff =>
  //     _firestore.collection('STAFF');

  CollectionReference<Map<String, dynamic>> get staff =>
      FirestorePath.companyCollection(DBCollections.staff);

  static CollectionReference<Map<String, dynamic>> get users =>
      FirebaseFirestore.instance.collection(DBCollections.users);

  Future<StaffModel> login({
    required String phoneNo,
    required String password,
  }) async {
    try {
      // ====================================================
      // 1. CHECK USERS COLLECTION
      // ====================================================

      final userQuery = await users
          .where('phone', isEqualTo: phoneNo.trim())
          .limit(1)
          .get();

      StaffModel? userModel;

      if (userQuery.docs.isNotEmpty) {
        final doc = userQuery.docs.first;
        final data = doc.data();

        if ((data['password'] ?? '') != password) {
          throw AuthException('Incorrect password.');
        }

        userModel = StaffModel.fromFirestore(doc);
        if (userModel.companyId != null && userModel.companyId!.isNotEmpty) {
          FirestorePath.initializeCompany(userModel.companyId!);
          log(
            'Company initialized from USERS document: ${userModel.companyId}',
          );
        }
      } else {
        // ====================================================
        // 2. CHECK ALL STAFF SUBCOLLECTIONS
        // ====================================================

        final staffQuery = await _firestore
            .collectionGroup(DBCollections.staff)
            .where('phone', isEqualTo: phoneNo.trim())
            .limit(1)
            .get();

        if (staffQuery.docs.isEmpty) {
          throw AuthException('No account found.');
        }

        final doc = staffQuery.docs.first;
        final data = doc.data();

        if ((data['password'] ?? '') != password) {
          throw AuthException('Incorrect password.');
        }

        // ====================================================
        // 3. EXTRACT COMPANY ID
        // ====================================================

        final segments = doc.reference.path.split('/');
        if (segments.length < 2 || segments[0] != 'COMPANY') {
          throw AuthException('Invalid company document structure.');
        }
        final companyId = segments[1];

        FirestorePath.initializeCompany(companyId);

        log('Company initialized: $companyId');

        userModel = StaffModel.fromFirestore(doc);
      }

      // ====================================================
      // 4. CHECK COMPANY STATUS
      // ====================================================
      final companyId = userModel.companyId;
      if (userModel.companyType != 'mother_company' &&
          companyId != null &&
          companyId.isNotEmpty) {
        final compDoc = await _firestore
            .collection('COMPANY')
            .doc(companyId)
            .get();
        if (compDoc.exists) {
          final compStatus = (compDoc.data()?['status'] as String? ?? 'PENDING')
              .toUpperCase();
          if (compStatus == 'SUSPENDED') {
            throw const AuthException(
              'Account is suspended. Need to upgrade plan.',
            );
          } else if (compStatus == 'PENDING') {
            throw const AuthException(
              'Account is pending. Need to purchase plan. Contact admin',
            );
          }
          userModel = userModel.copyWith(companyStatus: compStatus);
        }
      }

      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  // Future<StaffModel> login({
  //   required String phoneNo,
  //   required String password,
  // }) async {
  //   try {
  //     log('[FirebaseAuthService] Querying STAFF where PHONE == $phoneNo');
  //
  //     final query = await _staff
  //         .where('phone', isEqualTo: phoneNo.trim())
  //         .limit(1)
  //         .get();
  //
  //     log('[FirebaseAuthService] Docs found: ${query.docs.length}');
  //
  //     if (query.docs.isEmpty) {
  //       throw AuthException('No account found for "$phoneNo".');
  //     }
  //
  //     final doc = query.docs.first;
  //     final data = doc.data();
  //
  //     log('[FirebaseAuthService] Raw doc data: $data');
  //
  //     final storedPassword = data['password'] as String? ?? '';
  //
  //     if (storedPassword != password) {
  //       throw AuthException('Incorrect password.');
  //     }
  //
  //     try {
  //       final user = StaffModel.fromFirestore(doc);
  //       log('[FirebaseAuthService] UserModel built: $user');
  //       return user;
  //     } catch (e) {
  //       log('[FirebaseAuthService] fromMap parse error: $e  |  raw data: $data');
  //       throw AuthException('Failed to parse user data: $e');
  //     }
  //   } on AuthException {
  //     rethrow;
  //   } on FirebaseException catch (e) {
  //     log('[FirebaseAuthService] FirebaseException: ${e.message}');
  //     throw AuthException('Firebase error: ${e.message}');
  //   } catch (e, st) {
  //     log('[FirebaseAuthService] Unexpected: $e', stackTrace: st);
  //     throw AuthException('Unexpected error: $e');
  //   }
  // }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
