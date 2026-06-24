part of 'auth_cubit.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final StaffModel user;
  Authenticated({required this.user});
}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}

class AuthLoggedOut extends AuthState {}


// part of 'auth_cubit.dart';

// abstract class AuthState {}

// class AuthInitial    extends AuthState {}
// class AuthLoading    extends AuthState {}
// class AuthLoggedOut  extends AuthState {}

// class Authenticated extends AuthState {
//   final StaffModel user;
//   Authenticated({required this.user});
// }

// class AuthError extends AuthState {
//   final String message;
//   AuthError({required this.message});
// }

// // ── NEW: OTP was sent → show OTP input field in UI ──
// class OtpSent extends AuthState {}