import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../services/monetization_service.dart';
import '../services/save_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.saveService,
    required this.audioService,
    super.key,
  });

  final SaveService saveService;
  final AudioService audioService;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: saveService,
      builder: (context, _) {
        final progress = saveService.progress;
        return Scaffold(
          backgroundColor: const Color(0xff0f172a),
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: Colors.transparent,
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SwitchListTile(
                    title: const Text('Sound Effects'),
                    value: progress.soundEnabled,
                    onChanged: (value) async {
                      await saveService.setSoundEnabled(value);
                      audioService.play(GameSound.click);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Background Music'),
                    value: progress.musicEnabled,
                    onChanged: (value) async {
                      await saveService.setMusicEnabled(value);
                      if (value) {
                        await audioService.startMusic();
                      } else {
                        await audioService.stopMusic();
                      }
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Vibration'),
                    value: progress.vibrationEnabled,
                    onChanged: (value) async {
                      await saveService.setVibrationEnabled(value);
                      audioService.play(GameSound.click);
                    },
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () async {
                      await saveService.resetProgress();
                      audioService.play(GameSound.click);
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Reset Progress'),
                  ),
                  if (MonetizationService.instance.privacyOptionsRequired) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed:
                          MonetizationService.instance.showPrivacyOptions,
                      icon: const Icon(Icons.privacy_tip_outlined),
                      label: const Text('Privacy Options'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
