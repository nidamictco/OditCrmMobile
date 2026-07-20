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

class AuthAlreadyLoggedIn extends AuthState {
  final StaffModel user;
  AuthAlreadyLoggedIn({required this.user});
}

class AuthLoggedOut extends AuthState {}

class AuthForceLoggedOut extends AuthState {
  final String message;
  AuthForceLoggedOut({
    this.message = 'Your account has been logged in from another device.',
  });
}