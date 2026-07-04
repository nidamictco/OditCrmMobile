// lib/features/lead_category/data/repositories/lead_category_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odit_crm_mobile/core/constant/firebase_constant.dart';
import 'package:odit_crm_mobile/core/shared_prefference/session_service.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/leads_model.dart';
import 'package:odit_crm_mobile/feature/staff_management/model/staff_model.dart';

abstract class ILeadCategoryRepository {
  Stream<List<LeadsModel>> watchCategories();
  Future<void> addCategory({required String name, });
  Future<void> updateCategory({required String id, required String name});
  Future<void> deleteCategory({required String id});
}

class LeadCategoryRepository implements ILeadCategoryRepository {
  final FirebaseFirestore _firestore;

  // Firestore collection reference
  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestorePath.companyCollection('LEADS CATEGORY');

  LeadCategoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 🔹 Stream all categories ordered by creation date
  // In lead_category_repository.dart
@override
Stream<List<LeadsModel>> watchCategories() {
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
  Future<void> addCategory({
    required String name,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Category name cannot be empty.');
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
  Future<void> updateCategory({
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
  Future<void> deleteCategory({required String id}) async {
    await _collection.doc(id).delete();
  }
}