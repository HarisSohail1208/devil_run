import 'package:audioplayers/audioplayers.dart';

import 'save_service.dart';

enum GameSound { click, jump, death, win }

class AudioService {
  AudioService(this._saveService);

  final SaveService _saveService;
  final AudioPlayer _musicPlayer = AudioPlayer(playerId: 'music');
  final AudioPlayer _effectPlayer = AudioPlayer(playerId: 'effects');

  Future<void> initialize() async {
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(0.28);
    await _effectPlayer.setReleaseMode(ReleaseMode.stop);
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

  Future<void> play(GameSound sound) async {
    if (!_saveService.progress.soundEnabled) return;
    final file = switch (sound) {
      GameSound.click => 'click.wav',
      GameSound.jump => 'jump.wav',
      GameSound.death => 'death.wav',
      GameSound.win => 'win.wav',
    };
    await _effectPlayer.stop();
    await _effectPlayer.play(AssetSource('audio/$file'), volume: 0.75);
  }

  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _effectPlayer.dispose();
  }
}
