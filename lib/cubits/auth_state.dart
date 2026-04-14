

import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

// Success — user is authenticated
class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

// Logged out
class AuthUnauthenticated extends AuthState {}

// Error — something went wrong
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
