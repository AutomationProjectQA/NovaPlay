// Generates silent WAV placeholders for NovaPlay's audio (Sprint 12).
//
// These keep the audio pipeline functional end-to-end (it loads and "plays"
// silence) until real sound design lands. Replace the files in assets/audio/
// with real clips — paths are fixed in lib/core/constants/audio_assets.dart.
//
// Run:  dart run tool/generate_placeholder_audio.dart
import 'dart:io';
import 'dart:typed_data';

const int sampleRate = 22050;

void main() {
  // (path, durationSeconds)
  const files = <(String, double)>[
    ('assets/audio/music/ambient_loop.wav', 1.5),
    ('assets/audio/sfx/launch.wav', 0.15),
    ('assets/audio/sfx/bounce.wav', 0.1),
    ('assets/audio/sfx/star.wav', 0.15),
    ('assets/audio/sfx/win.wav', 0.4),
    ('assets/audio/sfx/lose.wav', 0.3),
  ];

  for (final (path, seconds) in files) {
    final file = File(path);
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(_silentWav(seconds));
  }
  stdout.writeln('Generated ${files.length} silent WAV placeholders.');
}

/// Builds a minimal mono 16-bit PCM WAV of [seconds] of silence.
Uint8List _silentWav(double seconds) {
  final sampleCount = (sampleRate * seconds).round();
  final dataLength = sampleCount * 2; // 16-bit mono
  final bytes = BytesBuilder();

  void writeString(String s) => bytes.add(s.codeUnits);
  void writeUint32(int v) {
    final b = ByteData(4)..setUint32(0, v, Endian.little);
    bytes.add(b.buffer.asUint8List());
  }

  void writeUint16(int v) {
    final b = ByteData(2)..setUint16(0, v, Endian.little);
    bytes.add(b.buffer.asUint8List());
  }

  writeString('RIFF');
  writeUint32(36 + dataLength);
  writeString('WAVE');
  writeString('fmt ');
  writeUint32(16); // PCM chunk size
  writeUint16(1); // audioFormat = PCM
  writeUint16(1); // channels = mono
  writeUint32(sampleRate);
  writeUint32(sampleRate * 2); // byteRate
  writeUint16(2); // blockAlign
  writeUint16(16); // bitsPerSample
  writeString('data');
  writeUint32(dataLength);
  bytes.add(Uint8List(dataLength)); // silence (zeros)

  return bytes.toBytes();
}
