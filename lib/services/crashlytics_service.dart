
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  static final CrashlyticsService _instance = CrashlyticsService._internal();
  factory CrashlyticsService() => _instance;
  CrashlyticsService._internal();

  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  Future<void> init() async {
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    FlutterError.onError = _crashlytics.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  Future<void> setUser(User? user) async {
    if (user != null) {
      await _crashlytics.setUserIdentifier(user.uid);
      await _crashlytics.setCustomKey('user_email', user.email ?? 'unknown');
      await _crashlytics.setCustomKey('display_name', user.displayName ?? 'unknown');
    } else {
      await _crashlytics.setUserIdentifier('');
    }
  }

  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    await _crashlytics.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  Future<void> throwTestCrash() async {
    await _crashlytics.log('Test crash triggered by user from settings screen');
    await _crashlytics.setCustomKey('crash_type', 'manual_test');

    _crashlytics.crash();
  }

  Future<void> throwTestNonFatalError() async {
    await _crashlytics.log('Non-fatal test error triggered');
    await _crashlytics.recordError(
      Exception('Test non-fatal error from Notes App'),
      StackTrace.current,
      reason: 'Manual test from settings screen',
      fatal: false,
    );
  }
}
