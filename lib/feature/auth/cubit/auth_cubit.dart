import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:odit_crm_mobile/core/constant/firebase_constant.dart';
import 'package:odit_crm_mobile/core/shared_prefference/session_service.dart';
import 'package:odit_crm_mobile/core/utils/notification_service.dart';
import 'package:odit_crm_mobile/feature/auth/data/auth_data.dart';
import 'package:odit_crm_mobile/feature/designation/cubit/permission_cubit.dart';
import 'package:odit_crm_mobile/feature/staff_management/model/staff_model.dart';
import 'package:odit_crm_mobile/feature/staff_management/data/staff_repo.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required FirebaseAuthService authService,
    required SessionService sessionService,
    StaffRepository? staffRepository,
  })  : _authService = authService,
        _sessionService = sessionService,
        _staffRepository = staffRepository ?? StaffRepository(),
        super(AuthInitial());

  final FirebaseAuthService _authService;
  final SessionService _sessionService;
  final StaffRepository _staffRepository;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sessionSub;

  // ─── Session guard ────────────────────────────────────────────────────────

  // void _startSessionWatcher(String staffId) {
  //   _sessionSub?.cancel();
  //   _sessionSub = _staffRepository.watchStaffDoc(staffId).listen((snap) async {
  //     final remoteSessionId = snap.data()?['sessionId'] as String?;
  //     final localSessionId = await _sessionService.getSessionId();

  //     if (remoteSessionId != null &&
  //         localSessionId != null &&
  //         remoteSessionId != localSessionId) {
  //       log('[AuthCubit] Session superseded by another device — forcing logout');
  //       await _forceLogout();
  //     }
  //   }, onError: (e) => log('[AuthCubit] session watcher error: $e'));
  // }
  void _startSessionWatcher(String staffId) {
  _sessionSub?.cancel();
  _sessionSub = _staffRepository.watchStaffDoc(staffId).listen(
    (snap) async {
      log('[AuthCubit] session watcher tick for $staffId — doc exists: ${snap.exists}');
      final remoteSessionId = snap.data()?['sessionId'] as String?;
      final localSessionId = await _sessionService.getSessionId();

      log('[AuthCubit] remote=$remoteSessionId local=$localSessionId');

      if (remoteSessionId != null &&
          localSessionId != null &&
          remoteSessionId != localSessionId) {
        log('[AuthCubit] Session superseded by another device — forcing logout');
        await _forceLogout();
      }
    },
    onError: (e) {
      log('[AuthCubit] session watcher error: $e — reattaching in 3s');
      // CRITICAL: without this, the stream is dead forever after any error.
      Future.delayed(const Duration(seconds: 3), () {
        if (!isClosed && _sessionSub != null) {
          _startSessionWatcher(staffId);
        }
      });
    },
  );
}

  // Future<void> _forceLogout() async {
  //   await _sessionSub?.cancel();
  //   _sessionSub = null;

  //   final user = await _sessionService.getSavedUser();
  //   if (user?.id != null && user!.id!.isNotEmpty) {
  //     await NotificationService.clearTokenOnLogout(user.id!);
  //   }

  //   await _sessionService.clearSessionId();
  //   await _sessionService.clearSession(); // prefs.clear() — wipes sessionId key too
  //   FirestorePath.clear();

  //   emit(AuthForceLoggedOut());
  // }
  Future<void> _forceLogout() async {
  await _sessionSub?.cancel();
  _sessionSub = null;

  // Emit FIRST so navigation starts immediately, before anything
  // that reads FirestorePath.companyId is invalidated.
  emit(AuthForceLoggedOut());

  // Cleanup now happens after the UI has already been told to leave.
  final user = await _sessionService.getSavedUser();
  if (user?.id != null && user!.id!.isNotEmpty) {
    await NotificationService.clearTokenOnLogout(user.id!);
  }

  await _sessionService.clearSessionId();
  await _sessionService.clearSession();
  FirestorePath.clear();
}

  // ─── Check saved session on app start ────────────────────────────────────

  Future<void> checkSession({PermissionCubit? permissionCubit}) async {
    emit(AuthLoading());
    try {
      final loggedIn = await _sessionService.isLoggedIn();
      if (loggedIn) {
        final user = await _sessionService.getSavedUser();
        if (user != null && user.id != null && user.id!.isNotEmpty) {
          log('[AuthCubit] Session restored for ${user.email}');

          if (user.companyId != null && user.companyId!.isNotEmpty) {
            FirestorePath.initializeCompany(user.companyId!);

            if (user.companyType != 'mother_company') {
              final compDoc = await FirebaseFirestore.instance
                  .collection('COMPANY')
                  .doc(user.companyId)
                  .get();
              if (compDoc.exists) {
                final compStatus =
                    (compDoc.data()?['status'] as String? ?? 'PENDING').toUpperCase();
                if (compStatus == 'SUSPENDED' || compStatus == 'PENDING') {
                  await _sessionService.clearSession();
                  emit(AuthError(message: 'Account is suspended. Need to upgrade plan.'));
                  return;
                }
              }
            }
          }

          // ── Session-guard check BEFORE restoring Authenticated: has
          // another device taken over while this app was closed? ──
          final staffDoc = await _staffRepository.watchStaffDoc(user.id!).first;
          final remoteSessionId = staffDoc.data()?['sessionId'] as String?;
          final localSessionId = await _sessionService.getSessionId();

          if (remoteSessionId != null &&
              localSessionId != null &&
              remoteSessionId != localSessionId) {
            await _sessionService.clearSessionId();
            await _sessionService.clearSession();
            FirestorePath.clear();
            emit(AuthForceLoggedOut());
            return;
          }

          await NotificationService.registerTokenAfterLogin(user.id!);
          _startSessionWatcher(user.id!);

          await permissionCubit?.loadPermissions(user.designationId);
          emit(Authenticated(user: user));
          return;
        }
      }
      emit(AuthLoggedOut());
    } catch (e) {
      log('[AuthCubit] checkSession error: $e');
      emit(AuthLoggedOut());
    }
  }

  // ─── Login ────────────────────────────────────────────────────────────────

// StaffModel? _pendingLoginUser;

//   Future<void> login({
//     required String phoneNo,
//     required String password,
//     required PermissionCubit permissionCubit,
//   }) async {
//     if (phoneNo.trim().isEmpty || password.isEmpty) {
//       emit(AuthError(message: 'Phone number and password are required.'));
//       return;
//     }
//     emit(AuthLoading());
//     try {
//       final user = await _authService.login(phoneNo: phoneNo.trim(), password: password);
//       log('[AuthCubit] Login success: ${user.phone} | designation: ${user.designation}');

//       await _sessionService.saveSession(user);

//       // ── Single-session enforcement ──
//       final newSessionId = const Uuid().v4();
//       await _staffRepository.updateSessionId(user.id!, newSessionId);
//       await _sessionService.saveSessionId(newSessionId);

//       await NotificationService.registerTokenAfterLogin(user.id!);
//       _startSessionWatcher(user.id!);

//       await permissionCubit.loadPermissions(user.designationId);

//       emit(Authenticated(user: user));
//     } on AuthException catch (e) {
//       emit(AuthError(message: e.message));
//     } on FirebaseException catch (e) {
//       emit(AuthError(message: 'Login failed: ${e.message}'));
//     } catch (e) {
//       emit(AuthError(message: 'Login failed. Please try again.'));
//     }
//   }

StaffModel? _pendingLoginUser; // holds credentials-verified user while we wait for confirmation

Future<void> login({
  required String phoneNo,
  required String password,
  required PermissionCubit permissionCubit,
  bool forceLogin = false,
}) async {
  log('[AuthCubit] Entering login(forceLogin: $forceLogin) | phoneNo: "$phoneNo", password: "${password.isNotEmpty ? '********' : 'EMPTY'}"');
  log('[AuthCubit] Current _pendingLoginUser: ${_pendingLoginUser?.id}');

  if (phoneNo.trim().isEmpty || password.isEmpty) {
    log('[AuthCubit] Validation failed: phoneNo or password empty');
    emit(AuthError(message: 'Phone number and password are required.'));
    return;
  }
  log('[AuthCubit] Emitting AuthLoading');
  emit(AuthLoading());
  try {
    // Reuse the already-verified user if this is a confirmed force-login,
    // otherwise verify credentials fresh.
    log('[AuthCubit] User verification step starting');
    final user = (forceLogin && _pendingLoginUser != null)
        ? _pendingLoginUser!
        : await _authService.login(phoneNo: phoneNo.trim(), password: password);

    log('[AuthCubit] User verification step done. User: ${user.phone} (${user.id})');

    // ── NEW: check for an existing active session before proceeding ──
    if (!forceLogin) {
      log('[AuthCubit] Checking for existing session for user: ${user.id}');
      final existingSessionId = await _staffRepository.getSessionId(user.id!);
      log('[AuthCubit] Existing session ID: $existingSessionId');
      if (existingSessionId != null && existingSessionId.isNotEmpty) {
        log('[AuthCubit] Existing session detected! Setting _pendingLoginUser: ${user.id}');
        _pendingLoginUser = user; // remember so "Continue" doesn't re-auth
        log('[AuthCubit] Emitting AuthAlreadyLoggedIn');
        emit(AuthAlreadyLoggedIn(user: user));
        return;
      }
    }

    log('[AuthCubit] Clearing _pendingLoginUser');
    _pendingLoginUser = null;

    log('[AuthCubit] Saving local session');
    await _sessionService.saveSession(user);

    final newSessionId = const Uuid().v4();
    log('[AuthCubit] Creating new session ID: $newSessionId');
    
    log('[AuthCubit] Updating Firestore session ID');
    await _staffRepository.updateSessionId(user.id!, newSessionId);
    
    log('[AuthCubit] Saving local session ID');
    await _sessionService.saveSessionId(newSessionId);

    log('[AuthCubit] Registering FCM token');
    await NotificationService.registerTokenAfterLogin(user.id!);
    
    log('[AuthCubit] Starting session watcher');
    _startSessionWatcher(user.id!);

    log('[AuthCubit] Loading permissions');
    await permissionCubit.loadPermissions(user.designationId);

    log('[AuthCubit] Emitting Authenticated');
    emit(Authenticated(user: user));
  } on AuthException catch (e) {
    log('[AuthCubit] AuthException caught: ${e.message}');
    emit(AuthError(message: e.message));
  } on FirebaseException catch (e) {
    log('[AuthCubit] FirebaseException caught: ${e.message}');
    emit(AuthError(message: 'Login failed: ${e.message}'));
  } catch (e) {
    log('[AuthCubit] Exception caught: $e');
    emit(AuthError(message: 'Login failed. Please try again.'));
  }
}

// Called if the user taps "Cancel" on the already-logged-in dialog.
void cancelForceLogin() {
  log('[AuthCubit] cancelForceLogin() called. Clearing _pendingLoginUser');
  _pendingLoginUser = null;
  log('[AuthCubit] Emitting AuthLoggedOut');
  emit(AuthLoggedOut());
}

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout({PermissionCubit? permissionCubit}) async {
    emit(AuthLoading());

    // Cancel the watcher FIRST so clearing our own sessionId below
    // doesn't trigger our own force-logout branch.
    await _sessionSub?.cancel();
    _sessionSub = null;

    final user = await _sessionService.getSavedUser();
    if (user?.id != null && user!.id!.isNotEmpty) {
      await NotificationService.clearTokenOnLogout(user.id!);
      await _staffRepository.clearSessionId(user.id!);
    }

    await _sessionService.clearSessionId();
    await _sessionService.clearSession();
    FirestorePath.clear();
    permissionCubit?.clear();

    emit(AuthLoggedOut());
  }

  Future<void> refreshUser(String staffId) async {
    try {
      final updated = await _staffRepository.getStaff(staffId);
      if (updated != null) {
        await _sessionService.saveSession(updated);
        emit(Authenticated(user: updated));
        log('[AuthCubit] User refreshed: $staffId');
      }
    } catch (e) {
      log('[AuthCubit] refreshUser error: $e');
    }
  }

  @override
  Future<void> close() {
    _sessionSub?.cancel();
    return super.close();
  }
}