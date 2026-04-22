

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/app_color_cubit.dart';
import '../services/crashlytics_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: BlocBuilder<AppColorCubit, AppColorState>(
        builder: (context, colorState) {
          final color = colorState.primaryColor;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [

              // ── Section: Remote Config ──────────────────────
              _SectionHeader(title: 'Firebase Remote Config'),
              const SizedBox(height: 12),

              // Color preview card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current App Color',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fetched from Firebase Remote Config key: app_primary_color',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5), fontSize: 12),
                    ),
                    const SizedBox(height: 16),

                    // Color swatch
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: color.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace'),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'R:${color.red}  G:${color.green}  B:${color.blue}',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Refresh button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            context.read<AppColorCubit>().refresh(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.refresh_rounded,
                            color: Colors.white, size: 18),
                        label: const Text('Refresh Remote Config',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // How to change color hint
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.08), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: color, size: 18),
                        const SizedBox(width: 8),
                        const Text('How to change the color',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _Step(
                        number: '1',
                        text:
                            'Go to Firebase Console → Remote Config'),
                    _Step(
                        number: '2',
                        text: 'Add parameter: app_primary_color'),
                    _Step(
                        number: '3',
                        text:
                            'Set value to a hex color e.g. 3B82F6 (blue)'),
                    _Step(number: '4', text: 'Click Publish changes'),
                    _Step(
                        number: '5',
                        text:
                            'Tap "Refresh Remote Config" above — color updates instantly!'),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Section: Crashlytics ────────────────────────
              _SectionHeader(title: 'Firebase Crashlytics'),
              const SizedBox(height: 12),

              // Non-fatal error button
              _CrashlyticsCard(
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.amber,
                title: 'Send Non-Fatal Error',
                subtitle:
                    'Records a handled error in Crashlytics dashboard.\nApp keeps running normally.',
                buttonLabel: 'Send Non-Fatal Error',
                buttonColor: Colors.amber.shade700,
                onPressed: () async {
                  await CrashlyticsService().throwTestNonFatalError();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            '✅ Non-fatal error sent to Crashlytics!'),
                        backgroundColor: Colors.green.shade700,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 12),

              // Fatal crash button
              _CrashlyticsCard(
                icon: Icons.bug_report_rounded,
                iconColor: Colors.red,
                title: 'Force Test Crash',
                subtitle:
                    'Crashes the app immediately.\nCheck Firebase Crashlytics dashboard after relaunch.',
                buttonLabel: 'Force Crash Now',
                buttonColor: Colors.red.shade700,
                onPressed: () async {
                  // Show confirmation dialog before crashing
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF16213E),
                      title: const Text('Force Crash?',
                          style: TextStyle(color: Colors.white)),
                      content: const Text(
                        'This will immediately crash the app.\n\nAfter reopening, the crash will appear in your Firebase Crashlytics dashboard within a few minutes.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Crash Now',
                                style:
                                    TextStyle(color: Colors.red))),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await CrashlyticsService().throwTestCrash();
                  }
                },
              ),

              const SizedBox(height: 28),

              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.08), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: Colors.blue, size: 18),
                        const SizedBox(width: 8),
                        const Text('Where to see crashes',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _Step(
                        number: '1',
                        text: 'Firebase Console → Crashlytics'),
                    _Step(
                        number: '2',
                        text:
                            'Click on your Android app'),
                    _Step(
                        number: '3',
                        text:
                            'Crashes appear within 1-2 minutes after relaunch'),
                    _Step(
                        number: '4',
                        text:
                            'Non-fatal errors appear under "Non-fatals" tab'),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withOpacity(0.5),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String text;
  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(number,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 11)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _CrashlyticsCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback onPressed;

  const _CrashlyticsCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.buttonColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                  height: 1.5)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(buttonLabel,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
