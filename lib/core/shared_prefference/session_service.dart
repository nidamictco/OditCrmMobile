import 'dart:convert';
import 'dart:developer';

import 'package:odit_crm_mobile/feature/staff_management/model/staff_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyIsLoggedIn = 'session_is_logged_in';
  static const _keyUser = 'session_user';
  static const _keyUserId = 'session_user_id';
  static const _keySessionId = 'session_active_session_id';

  Future<void> saveSession(StaffModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    // await prefs.setString(_keyUser, jsonEncode(user.toMap()));
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
    // Save id separately since toMap() doesn't include it
    await prefs.setString(_keyUserId, user.id ?? '');
    log('[SessionService] Session saved for ${user.email}');
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    log('[SessionService] Session cleared and all shared preferences cleared');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  
  Future<StaffModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUser);
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final savedId = prefs.getString(_keyUserId) ?? '';

      // Inject the saved ID back since toJson() may not include it
      map['id'] = savedId.isNotEmpty ? savedId : map['id'];

      return StaffModel.fromJson(map); // ← use same parser everywhere
    } catch (e) {
      log('[SessionService] Corrupt session data, clearing: $e');
      await clearSession();
      return null;
    }
  }

 Future<void> saveSessionId(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySessionId, sessionId);
  }

  Future<String?> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySessionId);
  }

  Future<void> clearSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySessionId);
  }

  /// Firestore [Timestamp] serialises to `{"_seconds": x, "_nanoseconds": y}`
  /// after going through jsonEncode. Handle both that and a raw ISO string.
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is Map) {
      final seconds = value['_seconds'] as int?;
      if (seconds != null) {
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
    }
    return null;
  }
}
