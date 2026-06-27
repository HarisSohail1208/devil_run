import '../models/level_definition.dart';

class LevelCatalog {
  const LevelCatalog._();

  static final List<LevelDefinition> levels = _rawLevels
      .map(LevelDefinition.fromJsonText)
      .toList(growable: false);

  static int get levelCount => levels.length;
  static bool get hasLevels => levels.isNotEmpty;
  static int get initialUnlockedCount => hasLevels ? 1 : 0;

  static int normalizeUnlockedCount(int value) {
    if (!hasLevels) return 0;
    return value.clamp(1, levelCount).toInt();
  }

  static int normalizeCompletedCount(int value) {
    if (!hasLevels) return 0;
    return value.clamp(0, levelCount).toInt();
  }

  static int? clampIndex(int index) {
    if (!hasLevels) return null;
    return index.clamp(0, levelCount - 1).toInt();
  }

  static LevelDefinition? at(int index) {
    if (index < 0 || index >= levelCount) return null;
    return levels[index];
  }

  static LevelDefinition byIndex(int index) {
    final clampedIndex = clampIndex(index);
    if (clampedIndex == null) {
      throw StateError('LevelCatalog contains no levels.');
    }
    return levels[clampedIndex];
  }

  static bool isUnlocked(int index, int unlockedCount) {
    return index >= 0 &&
        index < levelCount &&
        index < normalizeUnlockedCount(unlockedCount);
  }

  static int? playIndexForUnlockedCount(int unlockedCount) {
    if (!hasLevels) return null;
    return clampIndex(normalizeUnlockedCount(unlockedCount) - 1);
  }

  static int? nextIndexAfter(int index) {
    final nextIndex = index + 1;
    if (nextIndex >= levelCount) return null;
    return nextIndex;
  }

  static int? previousIndexBefore(int index) {
    final previousIndex = index - 1;
    if (previousIndex < 0) return null;
    return previousIndex;
  }

  static bool isLastIndex(int index) {
    return hasLevels && index >= levelCount - 1;
  }

  static int unlockCountAfterCompleting(int index) {
    return normalizeUnlockedCount(index + 2);
  }

  static int completedCountAfterCompleting(int index) {
    return normalizeCompletedCount(index + 1);
  }

  static double completionPercent(int completedCount) {
    if (!hasLevels) return 0;
    return normalizeCompletedCount(completedCount) / levelCount;
  }
}

const List<String> _rawLevels = [
  '''
{
  "id": 1,
  "name": "Trust the Floor",
  "size": {"w": 1280, "h": 720},
  "spawn": {"x": 74, "y": 500},
  "doorId": "door",
  "entities": [
    {"id": "start_floor", "kind": "platform", "rect": {"x": 0, "y": 560, "w": 170, "h": 160}},
    {"id": "low_floor", "kind": "platform", "rect": {"x": 170, "y": 592, "w": 240, "h": 128}},
    {"id": "middle_floor", "kind": "platform", "rect": {"x": 410, "y": 640, "w": 300, "h": 80}},
    {"id": "right_floor", "kind": "platform", "rect": {"x": 860, "y": 640, "w": 190, "h": 80}},
    {"id": "door_floor", "kind": "platform", "rect": {"x": 1120, "y": 592, "w": 160, "h": 128}},
    {"id": "mid_step", "kind": "platform", "rect": {"x": 735, "y": 505, "w": 72, "h": 24}},
    {"id": "vanish_step", "kind": "disappearingPlatform", "rect": {"x": 1048, "y": 616, "w": 72, "h": 24}, "delay": 0.18},
    {"id": "spike_a", "kind": "spike", "rect": {"x": 258, "y": 556, "w": 76, "h": 36}},
    {"id": "hidden_a", "kind": "hiddenSpike", "rect": {"x": 536, "y": 604, "w": 88, "h": 36}},
    {"id": "drop_spikes", "kind": "movingSpike", "rect": {"x": 858, "y": 238, "w": 92, "h": 38}, "moveBy": {"x": 0, "y": 288}, "speed": 0},
    {"id": "door", "kind": "door", "rect": {"x": 1188, "y": 496, "w": 56, "h": 96}},
    {"id": "reveal_hidden", "kind": "trigger", "rect": {"x": 470, "y": 470, "w": 122, "h": 190}, "triggerAction": "surpriseSpike", "targetId": "hidden_a"},
    {"id": "drop_ceiling", "kind": "trigger", "rect": {"x": 790, "y": 450, "w": 100, "h": 210}, "triggerAction": "shiftTarget", "targetId": "drop_spikes", "moveBy": {"x": 0, "y": 288}},
    {"id": "vanish_path", "kind": "trigger", "rect": {"x": 1006, "y": 448, "w": 94, "h": 210}, "triggerAction": "vanishTarget", "targetId": "vanish_step"}
  ]
}
''',
  '''
{
  "id": 2,
  "name": "Door Games",
  "size": {"w": 1280, "h": 720},
  "spawn": {"x": 70, "y": 500},
  "doorId": "door",
  "entities": [
    {"id": "start_floor", "kind": "platform", "rect": {"x": 0, "y": 560, "w": 240, "h": 160}},
    {"id": "pit_left", "kind": "platform", "rect": {"x": 360, "y": 640, "w": 190, "h": 80}},
    {"id": "pit_right", "kind": "platform", "rect": {"x": 670, "y": 640, "w": 230, "h": 80}},
    {"id": "door_floor", "kind": "platform", "rect": {"x": 1010, "y": 592, "w": 270, "h": 128}},
    {"id": "bait_bridge", "kind": "fakePlatform", "rect": {"x": 244, "y": 560, "w": 112, "h": 24}},
    {"id": "falling_step", "kind": "fallingPlatform", "rect": {"x": 555, "y": 562, "w": 92, "h": 24}, "delay": 0.16},
    {"id": "safe_step", "kind": "platform", "rect": {"x": 914, "y": 512, "w": 94, "h": 24}},
    {"id": "moving_spike", "kind": "movingSpike", "rect": {"x": 704, "y": 604, "w": 78, "h": 36}, "moveBy": {"x": 130, "y": 0}, "speed": 1.75},
    {"id": "saw", "kind": "saw", "rect": {"x": 438, "y": 580, "w": 58, "h": 58}, "moveBy": {"x": 0, "y": -140}, "speed": 1.3},
    {"id": "hidden_b", "kind": "hiddenSpike", "rect": {"x": 1054, "y": 556, "w": 82, "h": 36}},
    {"id": "fake_door", "kind": "fakeDoor", "rect": {"x": 1030, "y": 496, "w": 56, "h": 96}},
    {"id": "door", "kind": "door", "rect": {"x": 1190, "y": 496, "w": 56, "h": 96}},
    {"id": "fake_win", "kind": "trigger", "rect": {"x": 1018, "y": 482, "w": 78, "h": 130}, "triggerAction": "fakeVictory", "targetId": "fake_door"},
    {"id": "door_escape", "kind": "trigger", "rect": {"x": 1096, "y": 440, "w": 82, "h": 190}, "triggerAction": "shiftTarget", "targetId": "door", "moveBy": {"x": -105, "y": 0}},
    {"id": "reveal_last", "kind": "trigger", "rect": {"x": 962, "y": 450, "w": 86, "h": 190}, "triggerAction": "surpriseSpike", "targetId": "hidden_b"},
    {"id": "reverse_room", "kind": "trigger", "rect": {"x": 652, "y": 420, "w": 96, "h": 240}, "triggerAction": "reverseControls"}
  ]
}
''','''
{
  "id": 3,
  "name": "Mind the Gaps",
  "size": {"w": 1280, "h": 720},
  "spawn": {"x": 70, "y": 500},
  "doorId": "door",
  "entities": [
    {"id":"start_floor","kind":"platform","rect":{"x":0,"y":560,"w":220,"h":160}},

    {"id":"step1","kind":"platform","rect":{"x":280,"y":500,"w":90,"h":24}},
    {"id":"fake1","kind":"fakePlatform","rect":{"x":420,"y":470,"w":90,"h":24}},
    {"id":"step2","kind":"platform","rect":{"x":570,"y":430,"w":90,"h":24}},

    {"id":"falling_step","kind":"fallingPlatform","rect":{"x":740,"y":390,"w":90,"h":24},"delay":0.18},

    {"id":"safe_platform","kind":"platform","rect":{"x":920,"y":500,"w":120,"h":24}},

    {"id":"door_floor","kind":"platform","rect":{"x":1090,"y":592,"w":190,"h":128}},

    {"id":"spike1","kind":"spike","rect":{"x":220,"y":524,"w":70,"h":36}},

    {"id":"hidden_spike","kind":"hiddenSpike","rect":{"x":585,"y":394,"w":80,"h":36}},

    {
      "id":"moving_spike",
      "kind":"movingSpike",
      "rect":{"x":790,"y":464,"w":80,"h":36},
      "moveBy":{"x":140,"y":0},
      "speed":1.5
    },

    {
      "id":"saw",
      "kind":"saw",
      "rect":{"x":1130,"y":340,"w":60,"h":60},
      "moveBy":{"x":0,"y":180},
      "speed":1.2
    },

    {"id":"door","kind":"door","rect":{"x":1188,"y":496,"w":56,"h":96}},

    {
      "id":"trigger_hidden",
      "kind":"trigger",
      "rect":{"x":540,"y":350,"w":110,"h":120},
      "triggerAction":"surpriseSpike",
      "targetId":"hidden_spike"
    },

    {
      "id":"trigger_move",
      "kind":"trigger",
      "rect":{"x":720,"y":340,"w":110,"h":150},
      "triggerAction":"shiftTarget",
      "targetId":"moving_spike",
      "moveBy":{"x":140,"y":0}
    },

    {
      "id":"trigger_fall",
      "kind":"trigger",
      "rect":{"x":700,"y":340,"w":90,"h":120},
      "triggerAction":"vanishTarget",
      "targetId":"falling_step"
    }
  ]
}
''','''
{
  "id": 4,
  "name": "Don't Trust Anything",
  "size": {"w":1280,"h":720},
  "spawn":{"x":70,"y":500},
  "doorId":"door",
  "entities":[

    {"id":"start_floor","kind":"platform","rect":{"x":0,"y":560,"w":310,"h":160}},

    {"id":"middle_floor","kind":"platform","rect":{"x":470,"y":560,"w":260,"h":160}},

    {"id":"door_floor","kind":"platform","rect":{"x":980,"y":560,"w":300,"h":160}},

    {"id":"door","kind":"door","rect":{"x":1170,"y":464,"w":60,"h":96}},



    {
      "id":"ground_trap",
      "kind":"disappearingPlatform",
      "rect":{"x":260,"y":536,"w":210,"h":24},
      "delay":0.20
    },



    {
      "id":"hidden_spike",
      "kind":"hiddenSpike",
      "rect":{"x":515,"y":524,"w":90,"h":36}
    },



    {
      "id":"moving_spike",
      "kind":"movingSpike",
      "rect":{"x":770,"y":520,"w":90,"h":36},
      "moveBy":{"x":160,"y":0},
      "speed":1.6
    },



    {
      "id":"saw",
      "kind":"saw",
      "rect":{"x":1040,"y":330,"w":60,"h":60},
      "moveBy":{"x":0,"y":180},
      "speed":1.4
    },



    {
      "id":"trap_floor",
      "kind":"trigger",
      "rect":{"x":220,"y":430,"w":120,"h":180},
      "triggerAction":"vanishTarget",
      "targetId":"ground_trap"
    },



    {
      "id":"spike_trigger",
      "kind":"trigger",
      "rect":{"x":470,"y":420,"w":120,"h":180},
      "triggerAction":"surpriseSpike",
      "targetId":"hidden_spike"
    },



    {
      "id":"move_trigger",
      "kind":"trigger",
      "rect":{"x":720,"y":420,"w":120,"h":180},
      "triggerAction":"shiftTarget",
      "targetId":"moving_spike",
      "moveBy":{"x":160,"y":0}
    }

  ]
}
''',
];
