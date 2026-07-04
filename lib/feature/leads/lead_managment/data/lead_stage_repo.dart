
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odit_crm_mobile/core/constant/firebase_constant.dart';
import 'package:odit_crm_mobile/core/shared_prefference/session_service.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/leads_model.dart';
import 'package:odit_crm_mobile/feature/staff_management/model/staff_model.dart';
abstract class ILeadStageRepository {
  Stream<List<LeadsModel>> watchCategories();
  Future<void> addCategory({required String name, });
  Future<void> updateCategory({required String id, required String name});
  Future<void> deleteCategory({required String id});
}

class LeadStageRepository implements ILeadStageRepository {
  final FirebaseFirestore _firestore;

  // Firestore collection reference
  CollectionReference<Map<String, dynamic>> get _collection =>
      FirestorePath.companyCollection('LEADS STAGE');

  LeadStageRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 🔹 Stream all categories ordered by creation date (with default stages first in specific order)
  @override
  Stream<List<LeadsModel>> watchCategories() {
    _checkAndSeedDefaultStages();
    return _collection
        .snapshots()
        .map(
          (snapshot) {
            final stages = snapshot.docs
                .map((doc) => LeadsModel.fromFirestore(doc.data(), doc.id))
                .toList();

            const List<String> defaultStagesOrder = [
              'NEW',
              'FOLLOWUP',
              'CLOSED',
              'REJECTED',
              'TRANSFERRED'
            ];

            stages.sort((a, b) {
              final aUpper = a.name.toUpperCase();
              final bUpper = b.name.toUpperCase();
              final aIsDefault = a.isDefault || defaultStagesOrder.contains(aUpper);
              final bIsDefault = b.isDefault || defaultStagesOrder.contains(bUpper);

              if (aIsDefault && bIsDefault) {
                final aIdx = defaultStagesOrder.indexOf(aUpper);
                final bIdx = defaultStagesOrder.indexOf(bUpper);
                final normalizedAIdx = aIdx == -1 ? 99 : aIdx;
                final normalizedBIdx = bIdx == -1 ? 99 : bIdx;
                return normalizedAIdx.compareTo(normalizedBIdx);
              } else if (aIsDefault) {
                return -1;
              } else if (bIsDefault) {
                return 1;
              } else {
                return a.createdAt.compareTo(b.createdAt);
              }
            });
            return stages;
          },
        );
  }

  Future<void> _checkAndSeedDefaultStages() async {
    try {
      final snapshot = await _collection.limit(1).get();
      if (snapshot.docs.isEmpty) {
        final batch = _firestore.batch();
        final defaultStages = ['New', 'Followup', 'Closed', 'Rejected', 'Transferred'];
        for (var stageName in defaultStages) {
          final docRef = _collection.doc();
          batch.set(docRef, {
            'name': stageName,
            'createdBy': 'System',
            'idOfCreator': 'system',
            'createdAt': FieldValue.serverTimestamp(),
            'isDefault': true,
          });
        }
        await batch.commit();
      }
    } catch (_) {}
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
      'isDefault': false,
    });
  } 

  /// 🔹 Update an existing category's name
  @override
  Future<void> updateCategory({
    required String id,
    required String name,
  }) async {
    final doc = await _collection.doc(id).get();
    if (doc.exists) {
      final isDefault = doc.data()?['isDefault'] as bool? ?? false;
      if (isDefault) {
        throw Exception('This is a default lead stage and cannot be edited or deleted.');
      }
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Category name cannot be empty.');
    }

    await _collection.doc(id).update({'name': trimmedName});
  }

  /// 🔹 Delete a category
  @override
  Future<void> deleteCategory({required String id}) async {
    final doc = await _collection.doc(id).get();
    if (doc.exists) {
      final isDefault = doc.data()?['isDefault'] as bool? ?? false;
      if (isDefault) {
        throw Exception('This is a default lead stage and cannot be edited or deleted.');
      }
    }
    await _collection.doc(id).delete();
  }
}