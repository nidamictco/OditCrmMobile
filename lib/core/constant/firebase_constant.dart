// import 'package:cloud_firestore/cloud_firestore.dart';

// class FirestorePath {
//   static final FirebaseFirestore _db = FirebaseFirestore.instance;

//   static String? _companyId;

//   static String? get companyId => _companyId;

//   /// Initialize after company admin login
//   static void initializeCompany(String companyId) {
//     _companyId = companyId;
//   }

//   /// Clear on logout
//   static void clear() {
//     _companyId = null;
//   }

//   // --------------------------------------------------------
//   // MAIN COLLECTIONS
//   // --------------------------------------------------------

//   static CollectionReference<Map<String, dynamic>> get companies =>
//       _db.collection('COMPANY');

//   static CollectionReference<Map<String, dynamic>> get users =>
//       _db.collection('USERS');

//   // --------------------------------------------------------
//   // COMPANY DOCUMENT
//   // --------------------------------------------------------

//   static DocumentReference<Map<String, dynamic>> get companyDoc {
//     if (_companyId == null) {
//       throw Exception('Company ID not initialized');
//     }

//     return companies.doc(_companyId);
//   }

//   // --------------------------------------------------------
//   // COMPANY SUB COLLECTIONS
//   // --------------------------------------------------------

//   static CollectionReference<Map<String, dynamic>> companyCollection(
//       String collectionName,
//       ) {
//     return companyDoc.collection(collectionName);
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyNotInitializedException implements Exception {
  const CompanyNotInitializedException();
  @override
  String toString() => 'CompanyNotInitializedException: Company ID not initialized';
}

class FirestorePath {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String? _companyId;

  static String? get companyId => _companyId;

  /// Initialize after company admin login
  static void initializeCompany(String companyId) {
    _companyId = companyId;
  }

  /// Clear on logout
  static void clear() {
    _companyId = null;
  }

  // --------------------------------------------------------
  // MAIN COLLECTIONS
  // --------------------------------------------------------

  static CollectionReference<Map<String, dynamic>> get companies =>
      _db.collection('COMPANY');

  static CollectionReference<Map<String, dynamic>> get users =>
      _db.collection('USERS');

  // --------------------------------------------------------
  // COMPANY DOCUMENT
  // --------------------------------------------------------

  static DocumentReference<Map<String, dynamic>> get companyDoc {
    if (_companyId == null) {
      throw const CompanyNotInitializedException();
    }
    return companies.doc(_companyId);
  }

  // --------------------------------------------------------
  // COMPANY SUB COLLECTIONS
  // --------------------------------------------------------

  static CollectionReference<Map<String, dynamic>> companyCollection(
    String collectionName,
  ) {
    return companyDoc.collection(collectionName);
  }
}