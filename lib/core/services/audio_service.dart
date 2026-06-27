import 'package:flame_audio/flame_audio.dart';
import 'package:novaplay/core/constants/audio_assets.dart';

/// App-owned audio interface for background music and SFX (docs/CONCEPT.md
/// audio, UI_GUIDELINES §3.8 settings). All playback respects the user's
/// volume settings.
abstract interface class AudioService {
  /// Preloads SFX and prepares music. Safe to call once at startup.
  Future<void> init();

  Future<void> playMusic(String track);
  Future<void> stopMusic();

  void playSfx(String sound);

  void setMusicVolume(double value);
  void setSfxVolume(double value);
}

/// flame_audio-backed implementation. Resilient: if assets are missing or audio
/// is unavailable on the platform, every call no-ops instead of crashing.
class FlameAudioService implements AudioService {
  bool _available = false;
  String? _currentTrack;
  double _musicVolume = 0.7;
  double _sfxVolume = 0.85;

  @override
  Future<void> init() async {
    try {
      await FlameAudio.audioCache.loadAll(AudioAssets.sfx);
      await FlameAudio.bgm.initialize();
      _available = true;
    } on Exception {
      _available = false;
    }
  }

  @override
  Future<void> playMusic(String track) async {
    _currentTrack = track;
    if (!_available || _musicVolume <= 0) return;
    try {
      await FlameAudio.bgm.play(track, volume: _musicVolume);
    } on Exception {
      // Audio is best-effort; ignore playback failures.
    }
  }

  @override
  Future<void> stopMusic() async {
    if (!_available) return;
    try {
      await FlameAudio.bgm.stop();
    } on Exception {
      // Ignore.
    }
  }

  @override
  void playSfx(String sound) {
    if (!_available || _sfxVolume <= 0) return;
    try {
      // Fire-and-forget SFX; we don't await the player.
      // ignore: discarded_futures
      FlameAudio.play(sound, volume: _sfxVolume);
    } on Exception {
      // Ignore.
    }
  }

  @override
  void setMusicVolume(double value) {
    _musicVolume = value.clamp(0.0, 1.0);
    if (!_available) return;
    if (_musicVolume <= 0) {
      // Fire-and-forget stop; muting music.
      // ignore: discarded_futures
      FlameAudio.bgm.stop();
      return;
    }
    // Fire-and-forget volume update / (re)start of the current track.
    // ignore: discarded_futures
    FlameAudio.bgm.audioPlayer.setVolume(_musicVolume);
    final track = _currentTrack;
    if (track != null && !FlameAudio.bgm.isPlaying) {
      // Fire-and-forget restart after un-muting.
      // ignore: discarded_futures
      FlameAudio.bgm.play(track, volume: _musicVolume);
    }
  }

  @override
  void setSfxVolume(double value) => _sfxVolume = value.clamp(0.0, 1.0);
}

/// No-op audio (tests / when audio is disabled).
class NoopAudioService implements AudioService {
  @override
  Future<void> init() async {}

  @override
  Future<void> playMusic(String track) async {}

  @override
  Future<void> stopMusic() async {}

  @override
  void playSfx(String sound) {}

  @override
  void setMusicVolume(double value) {}

  @override
  void setSfxVolume(double value) {}
}
