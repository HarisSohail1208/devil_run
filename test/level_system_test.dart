import 'package:devil_run/levels/level_catalog.dart';
import 'package:devil_run/services/save_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('catalog exposes safe dynamic level helpers', () {
    expect(LevelCatalog.levelCount, LevelCatalog.levels.length);
    expect(LevelCatalog.hasLevels, LevelCatalog.levelCount > 0);
    if (LevelCatalog.hasLevels) {
      expect(LevelCatalog.clampIndex(-100), 0);
      expect(LevelCatalog.clampIndex(100000), LevelCatalog.levelCount - 1);
    } else {
      expect(LevelCatalog.clampIndex(0), isNull);
    }
    expect(LevelCatalog.nextIndexAfter(LevelCatalog.levelCount - 1), isNull);
    expect(LevelCatalog.previousIndexBefore(0), isNull);
  });

  test('save progress clamps to the current catalog', () async {
    SharedPreferences.setMockInitialValues({
      'unlocked_level': 100000,
      'completed_levels': 100000,
    });

    final saveService = SaveService();
    await saveService.load();

    expect(
      saveService.progress.unlockedLevel,
      LevelCatalog.hasLevels ? LevelCatalog.levelCount : 0,
    );
    expect(saveService.progress.completedLevels, LevelCatalog.levelCount);
    expect(saveService.completionPercent, LevelCatalog.hasLevels ? 1 : 0);
  });

  test('unlocking uses catalog positions instead of level ids', () async {
    SharedPreferences.setMockInitialValues({});

    final saveService = SaveService();
    await saveService.load();
    await saveService.unlockThroughIndex(0);

    expect(
      saveService.progress.unlockedLevel,
      LevelCatalog.unlockCountAfterCompleting(0),
    );
    expect(
      saveService.progress.completedLevels,
      LevelCatalog.completedCountAfterCompleting(0),
    );
  });
}
