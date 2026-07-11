import 'package:audioplayers/audioplayers.dart';

import 'save_service.dart';

enum GameSound { click, jump, death, win }

abstract interface class GameAudio {
  Future<void> play(GameSound sound);
}

class AudioService implements GameAudio {
  AudioService(this._saveService);

  final SaveService _saveService;
  final AudioPlayer _musicPlayer = AudioPlayer(playerId: 'music');
  static const _effectPoolSize = 4;
  final List<AudioPlayer> _effectPlayers = List.generate(
    _effectPoolSize,
    (index) => AudioPlayer(playerId: 'effect-$index'),
  );
  int _nextEffectPlayer = 0;

  Future<void> initialize() async {
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(0.28);
    for (final player in _effectPlayers) {
      await player.setReleaseMode(ReleaseMode.stop);
    }
    if (_saveService.progress.musicEnabled) {
      await startMusic();
    }
  }

  Future<void> startMusic() async {
    if (!_saveService.progress.musicEnabled) return;
    await _musicPlayer.play(AssetSource('audio/music_loop.wav'));
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  @override
  Future<void> play(GameSound sound) async {
    if (!_saveService.progress.soundEnabled) return;
    final file = switch (sound) {
      GameSound.click => 'click.wav',
      GameSound.jump => 'jump.wav',
      GameSound.death => 'death.wav',
      GameSound.win => 'win.wav',
    };
    final player = _effectPlayers[_nextEffectPlayer];
    _nextEffectPlayer = (_nextEffectPlayer + 1) % _effectPlayers.length;
    await player.play(AssetSource('audio/$file'), volume: 0.75);
  }

  Future<void> dispose() async {
    await _musicPlayer.dispose();
    for (final player in _effectPlayers) {
      await player.dispose();
    }
  }
}
