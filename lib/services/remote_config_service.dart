

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static const String _primaryColorKey = 'app_primary_color';

  static const String _defaultColor = 'E94560';

  Future<void> init() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        minimumFetchInterval: const Duration(minutes: 1),
      ),
    );

    await _remoteConfig.setDefaults({
      _primaryColorKey: _defaultColor,
    });

    await fetchAndActivate();
  }

  Future<void> fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Remote Config fetch failed: $e');
    }
  }

  Color get primaryColor {
    final hexString = _remoteConfig.getString(_primaryColorKey);
    return _hexToColor(hexString);
  }

  Stream<RemoteConfigUpdate> get onConfigUpdated =>
      _remoteConfig.onConfigUpdated;

  Color _hexToColor(String hex) {
    try {
      final cleanHex = hex.replaceAll('#', '').trim();

      if (cleanHex.length != 6) return const Color(0xFFE94560);

      return Color(int.parse('FF$cleanHex', radix: 16));
    } catch (_) {
      return const Color(0xFFE94560);
    }
  }
}
