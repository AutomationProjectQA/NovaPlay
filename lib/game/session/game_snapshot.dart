import 'package:equatable/equatable.dart';

/// A lightweight in-flight level snapshot for pause/resume
/// (docs/ARCHITECTURE.md §8.10). Captures sparks left and which stars are lit;
/// the board itself is rebuilt deterministically from the level definition.
class GameSnapshot extends Equatable {
  const GameSnapshot({
    required this.levelId,
    required this.sparksRemaining,
    required this.litStarIndices,
  });

  factory GameSnapshot.fromMap(Map<dynamic, dynamic> map) => GameSnapshot(
    levelId: map['levelId'] as int,
    sparksRemaining: map['sparksRemaining'] as int,
    litStarIndices: (map['litStarIndices'] as List<dynamic>)
        .map((e) => e as int)
        .toList(),
  );

  final int levelId;
  final int sparksRemaining;
  final List<int> litStarIndices;

  Map<String, dynamic> toMap() => {
    'levelId': levelId,
    'sparksRemaining': sparksRemaining,
    'litStarIndices': litStarIndices,
  };

  @override
  List<Object?> get props => [levelId, sparksRemaining, litStarIndices];
}
