import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/core/utils/notification_service.dart';
import 'package:odit_crm_mobile/feature/general_settings/data/general_setting_repo.dart';
import 'package:odit_crm_mobile/feature/general_settings/model/general_settings_model.dart';
import 'package:odit_crm_mobile/feature/notification/cubit/notification_state.dart';
import 'package:odit_crm_mobile/feature/notification/data/notification_repo.dart';
import 'package:odit_crm_mobile/feature/notification/model/notification_model.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepo _repo;
  final GeneralSettingsRepository _settingsRepo;

  StreamSubscription? _subscription;
  final Set<String> _seenIds = {};

  // keeps last known list so delete states can still show the UI
  List<NotificationModel> _currentList = [];

   GeneralSettingsModel _settings = const GeneralSettingsModel();

  NotificationCubit(this._repo, this._settingsRepo) : super(NotificationInitial());

  // void load(String staffId) {
  //   emit(NotificationLoading());
  //   _subscription?.cancel();

  //     // Load settings once up-front; refresh in the background silently.
  //   _settingsRepo.fetchSettings().then((s) {
  //     _settings = s;
  //     log('[NotificationCubit] settings loaded: ${s.toMap()}');
  //   }).catchError((e) {
  //     log('[NotificationCubit] settings fetch failed: $e');
  //     // keep default (all false) — safe fallback
  //   });

  //   _subscription = _repo.streamByStaff(staffId).listen(
  //     (notifications) async {
  //       _currentList = notifications;
  //       await _triggerLocalForNew(notifications);
  //       emit(NotificationLoaded(notifications));
  //     },
  //     onError: (e) {
  //     log('[NotificationCubit] load error: $e'); 
  //     if (isClosed) return;
  //     emit(NotificationError(e.toString()));
  //   },
  //   );
  // }
  void load(String staffId) {
  if (isClosed) return;  // ← ADD THIS GUARD
  emit(NotificationLoading());
  _subscription?.cancel();

  _settingsRepo.fetchSettings().then((s) {
    if (isClosed) return;  // ← AND HERE
    _settings = s;
    log('[NotificationCubit] settings loaded: ${s.toMap()}');
  }).catchError((e) {
    log('[NotificationCubit] settings fetch failed: $e');
  });

  _subscription = _repo.streamByStaff(staffId).listen(
    (notifications) async {
      if (isClosed) return;  // ← AND HERE
      _currentList = notifications;
      await _triggerLocalForNew(notifications);
      if (isClosed) return;  // ← AND AFTER THE AWAIT
      emit(NotificationLoaded(notifications));
    },
    onError: (e) {
      log('[NotificationCubit] load error: $e');
      if (isClosed) return;
      emit(NotificationError(e.toString()));
    },
  );
}

  // delete a single notification
  Future<void> deleteOne(String notificationId) async {
    emit(NotificationDeleting(_currentList));
    try {
      _seenIds.remove(notificationId); // clean up seen tracker
      await _repo.deleteOne(notificationId);
      // stream will automatically emit updated list after deletion
    } catch (e) {
      emit(NotificationDeleteError(_currentList, e.toString()));
    }
  }

  // delete all notifications for current staff
  Future<void> deleteAll(String staffId) async {
    emit(NotificationDeleting(_currentList));
    try {
      _seenIds.clear(); // clear all seen trackers
      await _repo.deleteAll(staffId);
      // stream will automatically emit empty list after deletion
    } catch (e) {
      emit(NotificationDeleteError(_currentList, e.toString()));
    }
  }

  // Future<void> _triggerLocalForNew(List<NotificationModel> notifications) async {
  //   final isFirstLoad = _seenIds.isEmpty;

  //   for (final n in notifications) {
  //     if (!_seenIds.contains(n.id)) {
  //       _seenIds.add(n.id);
  //       if (!isFirstLoad) {
  //         await NotificationService.show(
  //           title: n.title,
  //           body: n.message,
  //         );
  //       }
  //     }
  //   }
  // }

  // in notification_cubit.dart
Future<void> markAllRead(String staffId) async {
  try {
    await _repo.markAllRead(staffId);
    // stream re-emits automatically with isRead: true → unreadCount drops to 0
  } catch (e) {
    log('[NotificationCubit] markAllRead error: $e');
  }
}

 // ── Gated local push ────────────────────────────────────────────────────────
 
//   Future<void> _triggerLocalForNew(List<NotificationModel> notifications) async {
//   final isFirstLoad = _seenIds.isEmpty;

//   // Collect new notifications first
//   final newOnes = <NotificationModel>[];
//   for (final n in notifications) {
//     if (!_seenIds.contains(n.id)) {
//       _seenIds.add(n.id);
//       newOnes.add(n);
//     }
//   }

//   if (isFirstLoad || newOnes.isEmpty) return;

//   // Re-fetch settings fresh before showing any banner
//   try {
//     final fresh = await _settingsRepo.fetchSettings();
//     _settings = fresh;
//     log('[NotificationCubit] settings refreshed on new notification: ${fresh.toMap()}');
//   } catch (e) {
//     log('[NotificationCubit] settings re-fetch failed, using cached: $e');
//     // fall through — use whatever _settings was last set to
//   }

//   for (final n in newOnes) {
//     if (_isAllowed(n)) {
//       await NotificationService.show(
//         title: n.title,
//         body: n.message,
//       );
//     }
//   }
// }

Future<void> _triggerLocalForNew(List<NotificationModel> notifications) async {
  final isFirstLoad = _seenIds.isEmpty;

  final newOnes = <NotificationModel>[];
  for (final n in notifications) {
    if (!_seenIds.contains(n.id)) {
      _seenIds.add(n.id);
      newOnes.add(n);
    }
  }

  if (isFirstLoad || newOnes.isEmpty) return;

  try {
    // Force through Dart's scheduler instead of direct JS Promise await
    final fresh = await Future.value(_settingsRepo.fetchSettings());
    if (isClosed) return;
    _settings = fresh;
    log('[NotificationCubit] settings refreshed: ${fresh.toMap()}');
  } catch (e) {
    log('[NotificationCubit] settings re-fetch failed, using cached: $e');
  }

  for (final n in newOnes) {
    if (isClosed) return;
    log('[NotificationCubit] _isAllowed("${n.title}") = ${_isAllowed(n)}');
    if (_isAllowed(n)) {
      await NotificationService.show(
        title: n.title,
        body: n.message,
      );
    }
  }
}
  void refreshSettings(GeneralSettingsModel updated) {
  _settings = updated;
  log('[NotificationCubit] settings refreshed: ${updated.toMap()}');
}

  /// Maps a notification to the settings toggle that gates it.
  // bool _isAllowed(NotificationModel n) {
  //   final t = n.title.toLowerCase();

  //   if (t.contains('new lead')) return _settings.newLead;
  //   if (t.contains('transfer') || t.contains('transferred')) {
  //     return _settings.transferLead;
  //   }
  //   if (t.contains('facebook')) return _settings.facebookLead;

  //   // Unknown/unrecognised type — allow by default.
  //   return true;
  // }
  bool _isAllowed(NotificationModel n) {
  final t = n.title.toLowerCase();

  if (t.contains('new lead')) return _settings.newLead;
   // ── Import leads — gate under the same newLead toggle ───────────────────
  if (t.contains('leads imported') || t.contains('import complete')) {
    return _settings.newLead;
  }
  if (t.contains('transfer') || t.contains('transferred')) {
    return _settings.transferLead;
  }
  if (t.contains('facebook')) return _settings.facebookLead;

  return true;
}

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}