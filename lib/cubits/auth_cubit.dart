

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/firebase_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseService _firebaseService = FirebaseService();

  AuthCubit() : super(AuthInitial()) {
    // Listen to Firebase auth state changes automatically
    _firebaseService.authStateChanges.listen((user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  // Google Sign-In

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());

    try {
      final credential = await _firebaseService.signInWithGoogle();
      emit(AuthAuthenticated(credential.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_formatFirebaseError(e)));
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('cancelled')) {
        emit(AuthError('Sign-in was cancelled.'));
      } else {
        emit(AuthError('An error occurred. Please try again.'));
      }
    }
  }

  // Sign Out

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await _firebaseService.signOut();
      emit(AuthUnauthenticated());
    } catch (_) {
      emit(AuthError('Failed to sign out. Please try again.'));
    }
  }

  // Format Firebase errors
  // 

  String _formatFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email.';
      case 'invalid-credential':
        return 'The credential is invalid or has expired.';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
