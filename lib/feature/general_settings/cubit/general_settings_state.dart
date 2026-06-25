import 'package:odit_crm_mobile/feature/general_settings/model/general_settings_model.dart';

abstract class GeneralSettingsState {
  const GeneralSettingsState();
}

class GeneralSettingsInitial extends GeneralSettingsState {
  const GeneralSettingsInitial();
}

class GeneralSettingsLoading extends GeneralSettingsState {
  const GeneralSettingsLoading();
}

class GeneralSettingsLoaded extends GeneralSettingsState {
  final GeneralSettingsModel settings;
  final DateTime _ts;

  GeneralSettingsLoaded(this.settings) : _ts = DateTime.now();
  // No Equatable — DateTime.now() ensures every emit is unique
}

class GeneralSettingsUpdating extends GeneralSettingsState {
  final GeneralSettingsModel settings;
  final DateTime _ts;

  GeneralSettingsUpdating(this.settings) : _ts = DateTime.now();
}

class GeneralSettingsError extends GeneralSettingsState {
  final String message;
  const GeneralSettingsError(this.message);
}