class GameProgress {
  const GameProgress({
    required this.unlockedLevel,
    required this.completedLevels,
    required this.soundEnabled,
    required this.musicEnabled,
    required this.vibrationEnabled,
  });

  final int unlockedLevel;
  final int completedLevels;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;

  GameProgress copyWith({
    int? unlockedLevel,
    int? completedLevels,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
  }) {
    return GameProgress(
      unlockedLevel: unlockedLevel ?? this.unlockedLevel,
      completedLevels: completedLevels ?? this.completedLevels,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}
