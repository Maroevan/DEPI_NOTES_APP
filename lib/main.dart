

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'services/remote_config_service.dart';
import 'services/crashlytics_service.dart';
import 'cubits/app_color_cubit.dart';
import 'views/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await CrashlyticsService().init();

  await RemoteConfigService().init();

  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppColorCubit(),
      child: BlocBuilder<AppColorCubit, AppColorState>(
        builder: (context, colorState) {
          final primaryColor = colorState.primaryColor;

          return MaterialApp(
            title: 'Notes App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: primaryColor,
              scaffoldBackgroundColor: const Color(0xFF1A1A2E),
              colorScheme: ColorScheme.dark(
                primary: primaryColor,
                surface: const Color(0xFF16213E),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF16213E),
                elevation: 0,
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: primaryColor,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
              ),
            ),
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}
