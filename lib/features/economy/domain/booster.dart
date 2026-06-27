/// The five boosters (docs/CONCEPT.md §7, MONETIZATION.md §4).
enum BoosterType { guidedLine, slowMo, extraSpark, bombSpark, rewind }

/// Display metadata for a booster.
extension BoosterInfo on BoosterType {
  String get label => switch (this) {
    BoosterType.guidedLine => 'Guided Line',
    BoosterType.slowMo => 'Slow-Mo',
    BoosterType.extraSpark => 'Extra Spark',
    BoosterType.bombSpark => 'Bomb Spark',
    BoosterType.rewind => 'Rewind',
  };

  /// Stable key for persistence.
  String get key => name;
}
