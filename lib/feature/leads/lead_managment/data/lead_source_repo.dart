
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odit_crm_mobile/core/constant/firebase_constant.dart';
import 'package:odit_crm_mobile/core/shared_prefference/session_service.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/leads_model.dart';
import 'package:odit_crm_mobile/feature/staff_management/Screen/model/staff_model.dart';

abstract class ILeadSourceRepository {
  Stream<List<LeadsModel>> watchSource();
  Future<void> addSource({required String name, });
  Future<void> updateSource({required String id, required String name});
  Future<void> deleteSource({required String id});
}

class LeadSourceRepository implements ILeadSourceRepository {
  final FirebaseFirestore _firestore;

  // Firestore collection reference
  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestorePath.companyCollection('LEAD SOURCE');

  LeadSourceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 🔹 Stream all categories ordered by creation date
  // In lead_category_repository.dart
@override
Stream<List<LeadsModel>> watchSource() {
  return _collection
      .orderBy('createdAt', descending: false) 
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => LeadsModel.fromFirestore(doc.data(), doc.id))
            .toList(), // already creates a new list, but be explicit:
      );
}

  /// 🔹 Add a new category
  @override
  Future<void> addSource({
    required String name,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Lead Source name cannot be empty.');
    }
    final StaffModel? user = await SessionService().getSavedUser();
    await _collection.add({
      'name': trimmedName,
      'createdBy': user?.name, 
      'idOfCreator': user?.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  } 

  /// 🔹 Update an existing category's name
  @override
  Future<void> updateSource({
    required String id,
    required String name,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Category name cannot be empty.');
    }

    await _collection.doc(id).update({'name': trimmedName});
  }

  /// 🔹 Delete a category
  @override
  Future<void> deleteSource({required String id}) async {
    await _collection.doc(id).delete();
  }
}