import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../levels/level_catalog.dart';
import '../services/audio_service.dart';
import '../services/save_service.dart';
import '../widgets/game_button.dart';
import 'game_screen.dart';
import 'level_select_screen.dart';
import 'settings_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({
    required this.saveService,
    required this.audioService,
    super.key,
  });

  final SaveService saveService;
  final AudioService audioService;

  @override
  Widget build(BuildContext context) {
    final playIndex = LevelCatalog.playIndexForUnlockedCount(
      saveService.progress.unlockedLevel,
    );
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff120902), Color(0xff9a4f00), Color(0xff241003)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'DEVIL RUN',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'A trap platformer where every safe step is suspicious.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withValues(alpha: 0.76),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 230,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GameButton(
                        label: 'Play',
                        icon: Icons.play_arrow_rounded,
                        onPressed: playIndex == null
                            ? null
                            : () {
                                audioService.play(GameSound.click);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => GameScreen(
                                      levelIndex: playIndex,
                                      saveService: saveService,
                                      audioService: audioService,
                                    ),
                                  ),
                                );
                              },
                      ),
                      const SizedBox(height: 12),
                      GameButton(
                        label: 'Levels',
                        icon: Icons.grid_view_rounded,
                        onPressed: () {
                          audioService.play(GameSound.click);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LevelSelectScreen(
                                saveService: saveService,
                                audioService: audioService,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      GameButton(
                        label: 'Settings',
                        icon: Icons.settings_rounded,
                        onPressed: () {
                          audioService.play(GameSound.click);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SettingsScreen(
                                saveService: saveService,
                                audioService: audioService,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      GameButton(
                        label: 'Exit',
                        icon: Icons.exit_to_app_rounded,
                        onPressed: () {
                          audioService.play(GameSound.click);
                          SystemNavigator.pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
