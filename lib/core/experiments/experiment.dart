/// Lightweight client-side A/B experiment framework (docs/LIVEOPS.md). Variant
/// assignment is **pure and deterministic** per install, so a player always sees
/// the same bucket and the logic is fully unit-testable. Remote Config can pin or
/// disable an experiment server-side without an app update.
library;

/// One arm of an experiment with a relative [weight] (e.g. 1:1, or 2:1).
class Variant {
  const Variant(this.id, [this.weight = 1]);

  final String id;
  final int weight;
}

/// A named experiment: its arms and the [control] arm used when it's disabled.
class Experiment {
  const Experiment({
    required this.key,
    required this.variants,
    required this.control,
  });

  final String key;
  final List<Variant> variants;
  final String control;
}

/// Stable 32-bit FNV-1a hash — same input always yields the same bucket, with no
/// dependency on `hashCode` (which is not stable across runs/platforms).
int _fnv1a(String s) {
  var hash = 0x811c9dc5;
  for (final unit in s.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}

/// Deterministically assigns a variant id for [unitId] (e.g. an install id)
/// within [experiment], weighted by each variant's weight. Pure: same
/// (experiment.key, unitId) → same variant, every time.
String assignVariant(Experiment experiment, String unitId) {
  final total = experiment.variants.fold<int>(0, (sum, v) => sum + v.weight);
  if (total <= 0) return experiment.control;
  var bucket = _fnv1a('${experiment.key}:$unitId') % total;
  for (final variant in experiment.variants) {
    if (bucket < variant.weight) return variant.id;
    bucket -= variant.weight;
  }
  return experiment.variants.last.id;
}

/// Resolves the effective variant honoring a server [override]:
/// - empty / `auto` → deterministic [assignVariant]
/// - `control` → the control arm
/// - a known variant id → that arm (force)
/// - anything else → falls back to deterministic assignment.
String resolveVariant(Experiment experiment, String unitId, String override) {
  if (override.isEmpty || override == 'auto') {
    return assignVariant(experiment, unitId);
  }
  if (override == 'control') return experiment.control;
  if (experiment.variants.any((v) => v.id == override)) return override;
  return assignVariant(experiment, unitId);
}

/// The live experiment catalog. Add experiments here; consume via
/// `experimentVariantProvider` and log exposure when the variant takes effect.
const Experiment interstitialCadenceExperiment = Experiment(
  key: 'interstitial_cadence',
  control: 'every_3',
  variants: [Variant('every_3'), Variant('every_4'), Variant('every_5')],
);

const Experiment firstClearCoinsExperiment = Experiment(
  key: 'first_clear_coins',
  control: 'coins_20',
  variants: [Variant('coins_20'), Variant('coins_30')],
);

const List<Experiment> kExperiments = [
  interstitialCadenceExperiment,
  firstClearCoinsExperiment,
];
