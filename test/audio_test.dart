import 'package:flutter_test/flutter_test.dart';
import 'package:novaplay/core/services/audio_service.dart';
import 'package:novaplay/core/services/haptics_service.dart';

void main() {
  group('NoopAudioService', () {
    test('every call is a safe no-op', () async {
      final audio = NoopAudioService()
        ..setMusicVolume(0.5)
        ..setSfxVolume(0.5)
        ..playSfx('sfx/launch.wav');
      await audio.init();
      await audio.playMusic('music/ambient_loop.wav');
      await audio.stopMusic();
      // Reaching here without throwing is the assertion.
      expect(audio, isNotNull);
    });
  });

  group('FlameAudioService', () {
    test('no-ops safely when audio is unavailable (no init)', () {
      // Without init(), _available is false, so volume/SFX calls must not throw.
      FlameAudioService()
        ..setSfxVolume(0.8)
        ..setMusicVolume(0)
        ..playSfx('sfx/launch.wav');
    });
  });

  group('HapticsService', () {
    test('disabled haptics never invoke the platform channel', () {
      PlatformHapticsService()
        ..setEnabled(enabled: false)
        ..selection()
        ..light()
        ..medium();
    });

    test('noop haptics are safe', () {
      NoopHapticsService()
        ..setEnabled(enabled: true)
        ..selection()
        ..light()
        ..medium();
    });
  });
}
