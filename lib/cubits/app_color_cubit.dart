

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/remote_config_service.dart';


class AppColorState {
  final Color primaryColor;
  const AppColorState(this.primaryColor);
}


class AppColorCubit extends Cubit<AppColorState> {
  final RemoteConfigService _remoteConfigService = RemoteConfigService();

  AppColorCubit()
      : super(AppColorState(RemoteConfigService().primaryColor)) {
    _remoteConfigService.onConfigUpdated.listen((_) async {
      await _remoteConfigService.fetchAndActivate();
      emit(AppColorState(_remoteConfigService.primaryColor));
    });
  }

  Future<void> refresh() async {
    await _remoteConfigService.fetchAndActivate();
    emit(AppColorState(_remoteConfigService.primaryColor));
  }
}
