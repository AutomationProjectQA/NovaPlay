import 'package:equatable/equatable.dart';

/// User preferences persisted across launches (docs/UI_GUIDELINES.md §3.8).
/// Plain immutable value type; persistence lives in the settings repository.
class SettingsState extends Equatable {
  const SettingsState({
    this.musicVolume = 0.7,
    this.sfxVolume = 0.85,
    this.haptics = true,
    this.reducedMotion = false,
    this.languageCode = 'en',
  });

  /// Builds settings from a stored JSON-ish map, falling back to defaults.
  factory SettingsState.fromMap(Map<dynamic, dynamic> map) => SettingsState(
    musicVolume: (map['musicVolume'] as num?)?.toDouble() ?? 0.7,
    sfxVolume: (map['sfxVolume'] as num?)?.toDouble() ?? 0.85,
    haptics: map['haptics'] as bool? ?? true,
    reducedMotion: map['reducedMotion'] as bool? ?? false,
    languageCode: map['languageCode'] as String? ?? 'en',
  );

  final double musicVolume;
  final double sfxVolume;
  final bool haptics;
  final bool reducedMotion;
  final String languageCode;

  Map<String, dynamic> toMap() => {
    'musicVolume': musicVolume,
    'sfxVolume': sfxVolume,
    'haptics': haptics,
    'reducedMotion': reducedMotion,
    'languageCode': languageCode,
  };

  SettingsState copyWith({
    double? musicVolume,
    double? sfxVolume,
    bool? haptics,
    bool? reducedMotion,
    String? languageCode,
  }) {
    return SettingsState(
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      haptics: haptics ?? this.haptics,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  List<Object?> get props => [
    musicVolume,
    sfxVolume,
    haptics,
    reducedMotion,
    languageCode,
  ];
}
