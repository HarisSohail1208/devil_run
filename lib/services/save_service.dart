import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../levels/level_catalog.dart';
import '../models/game_progress.dart';

class SaveService extends ChangeNotifier {
  static const _unlockedKey = 'unlocked_level';
  static const _completedKey = 'completed_levels';
  static const _soundKey = 'sound_enabled';
  static const _musicKey = 'music_enabled';
  static const _vibrationKey = 'vibration_enabled';

  GameProgress _progress = const GameProgress(
    unlockedLevel: 0,
    completedLevels: 0,
    soundEnabled: true,
    musicEnabled: true,
    vibrationEnabled: true,
  );

  GameProgress get progress => _progress;
  double get completionPercent =>
      LevelCatalog.completionPercent(_progress.completedLevels);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _progress = GameProgress(
      unlockedLevel: LevelCatalog.normalizeUnlockedCount(
        prefs.getInt(_unlockedKey) ?? LevelCatalog.initialUnlockedCount,
      ),
      completedLevels: LevelCatalog.normalizeCompletedCount(
        prefs.getInt(_completedKey) ??
            ((prefs.getInt(_unlockedKey) ?? LevelCatalog.initialUnlockedCount) -
                1),
      ),
      soundEnabled: prefs.getBool(_soundKey) ?? true,
      musicEnabled: prefs.getBool(_musicKey) ?? true,
      vibrationEnabled: prefs.getBool(_vibrationKey) ?? true,
    );
    await _save(notify: false);
  }

  Future<void> unlockThroughIndex(int levelIndex) async {
    final unlockedCount = LevelCatalog.unlockCountAfterCompleting(levelIndex);
    final completedCount = LevelCatalog.completedCountAfterCompleting(
      levelIndex,
    );
    if (unlockedCount <= _progress.unlockedLevel &&
        completedCount <= _progress.completedLevels) {
      return;
    }
    _progress = _progress.copyWith(
      unlockedLevel: unlockedCount > _progress.unlockedLevel
          ? unlockedCount
          : _progress.unlockedLevel,
      completedLevels: completedCount > _progress.completedLevels
          ? completedCount
          : _progress.completedLevels,
    );
    await _save();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _progress = _progress.copyWith(soundEnabled: enabled);
    await _save();
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _progress = _progress.copyWith(musicEnabled: enabled);
    await _save();
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    _progress = _progress.copyWith(vibrationEnabled: enabled);
    await _save();
  }

  Future<void> resetProgress() async {
    _progress = _progress.copyWith(
      unlockedLevel: LevelCatalog.initialUnlockedCount,
      completedLevels: 0,
    );
    await _save();
  }

  Future<void> _save({bool notify = true}) async {
    _progress = _progress.copyWith(
      unlockedLevel: LevelCatalog.normalizeUnlockedCount(
        _progress.unlockedLevel,
      ),
      completedLevels: LevelCatalog.normalizeCompletedCount(
        _progress.completedLevels,
      ),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_unlockedKey, _progress.unlockedLevel);
    await prefs.setInt(_completedKey, _progress.completedLevels);
    await prefs.setBool(_soundKey, _progress.soundEnabled);
    await prefs.setBool(_musicKey, _progress.musicEnabled);
    await prefs.setBool(_vibrationKey, _progress.vibrationEnabled);
    if (notify) notifyListeners();
  }
}
