import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:odit_crm_mobile/feature/notification/cubit/notification_state.dart';
import 'package:odit_crm_mobile/feature/notification/data/notification_repo.dart';
import 'package:odit_crm_mobile/feature/notification/model/notification_model.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepo _repo;

  StreamSubscription? _subscription;
  List<NotificationModel> _currentList = [];

  NotificationCubit(this._repo) : super(NotificationInitial());

  /// Loads notification HISTORY from Firestore. No longer triggers any
  /// local push — FCM (via NotificationService) owns all push display now.
  void load(String staffId) {
    log('[NotificationCubit] load called with staffId: $staffId');
    if (isClosed) return;
    emit(NotificationLoading());
    _subscription?.cancel();

    _subscription = _repo.streamByStaff(staffId).listen(
      (notifications) {
        if (isClosed) return;
        _currentList = notifications;
        emit(NotificationLoaded(notifications));
      },
      onError: (e) {
        log('[NotificationCubit] load error: $e');
        if (isClosed) return;
        emit(NotificationError(e.toString()));
      },
    );
  }

  Future<void> deleteOne(String notificationId) async {
    emit(NotificationDeleting(_currentList));
    try {
      await _repo.deleteOne(notificationId);
    } catch (e) {
      emit(NotificationDeleteError(_currentList, e.toString()));
    }
  }

  Future<void> deleteAll(String staffId) async {
    emit(NotificationDeleting(_currentList));
    try {
      await _repo.deleteAll(staffId);
    } catch (e) {
      emit(NotificationDeleteError(_currentList, e.toString()));
    }
  }

  Future<void> markAllRead(String staffId) async {
    try {
      await _repo.markAllRead(staffId);
    } catch (e) {
      log('[NotificationCubit] markAllRead error: $e');
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}