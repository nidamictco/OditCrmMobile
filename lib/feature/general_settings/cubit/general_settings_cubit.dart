import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/core/shared_prefference/session_service.dart';
import 'package:odit_crm_mobile/feature/general_settings/cubit/general_settings_state.dart';
import 'package:odit_crm_mobile/feature/general_settings/data/general_setting_repo.dart';
import 'package:odit_crm_mobile/feature/general_settings/model/general_settings_model.dart';

class GeneralSettingsCubit extends Cubit<GeneralSettingsState> {
  GeneralSettingsRepository? _repo;
   GeneralSettingsModel? _lastKnownSettings;

   void Function(GeneralSettingsModel)? onSettingsChanged;

  GeneralSettingsCubit() : super(const GeneralSettingsInitial());

  // ── Called from screen — resolves staffId at runtime ──────────────────────
  Future<void> loadForCurrentUser() async {
    emit(const GeneralSettingsLoading());
    try {
      final user = await SessionService().getSavedUser();
      final staffId = user?.id ?? '';

      log('[GeneralSettingsCubit] staffId = "$staffId"');

      if (staffId.isEmpty) {
        emit(GeneralSettingsError('User not found. Please log in again.'));
        return;
      }

      _repo = GeneralSettingsRepository(staffId: staffId);
      final settings = await _repo!.fetchSettings();
      log('[GeneralSettingsCubit] Loaded: ${settings.toMap()}');
      emit(GeneralSettingsLoaded(settings));
    } catch (e) {
      log('[GeneralSettingsCubit] Load error: $e');
      emit(GeneralSettingsError('Failed to load settings: $e'));
    }
  }

  // Future<void> toggleField(String field, bool value) async {
  //   log('[toggleField] $field = $value');
  //   if (_repo == null) return;

  //   // Use _lastKnownSettings as fallback — never rely on state alone
  //   final current = _currentSettings() ?? _lastKnownSettings;
  //   if (current == null) {
  //     log('[toggleField] No settings available');
  //     return;
  //   }

  //   final updated = _applyToggle(current, field, value);
  //   _lastKnownSettings = updated;            // ← KEEP IN SYNC
  //   emit(GeneralSettingsLoaded(updated));

  //   try {
  //     await _repo!.updateField(field, value);
  //     log('[toggleField] Saved $field = $value ✅');
  //   } catch (e) {
  //     log('[toggleField] Save failed, rolling back: $e');
  //     _lastKnownSettings = current;          // ← ROLLBACK
  //     emit(GeneralSettingsLoaded(current));
  //     emit(GeneralSettingsError('Failed to save: $e'));
  //   }
  // }
   Future<void> toggleField(String field, bool value) async {
    log('[toggleField] $field = $value');
    if (_repo == null) return;

    final current = _currentSettings() ?? _lastKnownSettings;
    if (current == null) {
      log('[toggleField] No settings available');
      return;
    }

    final updated = _applyToggle(current, field, value);
    _lastKnownSettings = updated;
    emit(GeneralSettingsLoaded(updated));

    try {
      await _repo!.updateField(field, value);
      log('[toggleField] Saved $field = $value ✅');
      onSettingsChanged?.call(updated); 
    } catch (e) {
      log('[toggleField] Save failed, rolling back: $e');
      _lastKnownSettings = current;
      emit(GeneralSettingsLoaded(current));
      emit(GeneralSettingsError('Failed to save: $e'));
    }
  }


 GeneralSettingsModel? _currentSettings() {
  final s = state;
  if (s is GeneralSettingsLoaded) return s.settings;
  if (s is GeneralSettingsUpdating) return s.settings;
  if (s is GeneralSettingsError) {
    // state got stuck as error — you need to recover last known settings
    log('[_currentSettings] state is Error — no settings available');
  }
  log('[_currentSettings] Unexpected state: ${s.runtimeType}');
  return null;
}

 GeneralSettingsModel _applyToggle(GeneralSettingsModel m, String field, bool value) {
  switch (field) {
    case 'newLead':      return m.copyWith(newLead: value);
    case 'facebookLead': return m.copyWith(facebookLead: value);
    case 'transferLead': return m.copyWith(transferLead: value);
    case 'whatsapp':     return m.copyWith(whatsapp: value);
    case 'cloudCall':    return m.copyWith(cloudCall: value);
    case 'phoneCall':    return m.copyWith(phoneCall: value);
    case 'autoAssign':   return m.copyWith(autoAssign: value);
    default:             return m;
  }
}
}