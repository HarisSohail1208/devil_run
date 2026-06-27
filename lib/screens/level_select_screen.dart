import 'package:flutter/material.dart';

import '../levels/level_catalog.dart';
import '../services/audio_service.dart';
import '../services/save_service.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({
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
        return Scaffold(
          backgroundColor: const Color(0xff0f172a),
          appBar: AppBar(
            title: const Text('Select Level'),
            backgroundColor: Colors.transparent,
          ),
          body: LevelCatalog.hasLevels
              ? GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 2.4,
                  ),
                  itemCount: LevelCatalog.levelCount,
                  itemBuilder: (context, index) {
                    final level = LevelCatalog.levels[index];
                    final unlocked = LevelCatalog.isUnlocked(
                      index,
                      saveService.progress.unlockedLevel,
                    );
                    return FilledButton(
                      onPressed: unlocked
                          ? () {
                              audioService.play(GameSound.click);
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => GameScreen(
                                    levelIndex: index,
                                    saveService: saveService,
                                    audioService: audioService,
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: unlocked
                            ? const Color(0xff164e63)
                            : const Color(0xff1f2937),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            unlocked ? Icons.flag_rounded : Icons.lock_rounded,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${index + 1}. ${level.name}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : const Center(child: Text('No levels available')),
        );
      },
    );
  }
}
