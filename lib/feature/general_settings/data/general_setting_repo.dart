
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:odit_crm_mobile/core/constant/firebase_constant.dart';
import 'package:odit_crm_mobile/feature/general_settings/model/general_settings_model.dart';

class GeneralSettingsRepository {
  GeneralSettingsRepository({
    required this.staffId,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final String staffId;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> get _docRef => FirestorePath.companyCollection('STAFF')
      .doc(staffId)
      .collection('settings')
      .doc('general');

  Future<GeneralSettingsModel> fetchSettings() async {
    try {
      final snap = await _docRef.get();
      if (snap.exists && snap.data() != null) {
        return GeneralSettingsModel.fromMap(snap.data()!);
      }
      return const GeneralSettingsModel();
    } catch (e) {
      log('[GeneralSettingsRepo] fetchSettings error: $e');
      return const GeneralSettingsModel();
    }
  }

  Future<void> saveSettings(GeneralSettingsModel model) async {
    try {
      await _docRef.set(model.toMap());
    } catch (e) {
      log('[GeneralSettingsRepo] saveSettings error: $e');
      rethrow;
    }
  }

  Future<void> updateField(String field, bool value) async {
    try {
      await _docRef.update({field: value});
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        await _docRef.set({field: value});
      } else {
        log('[GeneralSettingsRepo] updateField error: $e');
        rethrow;
      }
    } catch (e) {
      log('[GeneralSettingsRepo] updateField error: $e');
      rethrow;
    }
  }
}