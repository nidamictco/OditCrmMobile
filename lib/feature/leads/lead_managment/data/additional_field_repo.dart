import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odit_crm_mobile/core/constant/firebase_constant.dart';
import 'package:odit_crm_mobile/feature/leads/lead_managment/models/additional_model.dart';


abstract class AdditionalFieldsRepository {
  Future<List<AdditionalFieldModel>> fetchFields();
  Future<void> saveFields(List<String> fieldNames);
  Future<void> deleteField(String id);
}

class AdditionalFieldsRepositoryImpl implements AdditionalFieldsRepository {
  final FirebaseFirestore _firestore;

  // Collection name — adjust to match your Firestore structure
  static const String _collection = 'ADDITIONAL_FIELD';

  AdditionalFieldsRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<AdditionalFieldModel>> fetchFields() async {
    final snapshot = await FirestorePath.companyCollection(
      _collection,
    ).orderBy('createdAt', descending: false).get();

    return snapshot.docs
        .map((doc) => AdditionalFieldModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> saveFields(List<String> fieldNames) async {
    // Filter out empty strings
    final validFields = fieldNames.where((f) => f.trim().isNotEmpty).toList();

    if (validFields.isEmpty) return;

    final batch = _firestore.batch();

    for (final name in validFields) {
      final docRef = FirestorePath.companyCollection(_collection).doc();
      batch.set(docRef, AdditionalFieldModel(fieldName: name.trim()).toMap());
    }

    await batch.commit();
  }

  @override
  Future<void> deleteField(String id) async {
    await FirestorePath.companyCollection(_collection).doc(id).delete();
  }
}
