import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/core/constants/app_constants.dart';
import 'package:novaplay/core/di/injector.dart';
import 'package:novaplay/core/experiments/experiment.dart';
import 'package:novaplay/core/services/remote_config_service.dart';
import 'package:novaplay/features/rewards/presentation/rewards_providers.dart';

/// The effective variant for [Experiment] for this install, honoring any
/// server-side override (`exp_<key>`). Resolution is deterministic — same
/// install always gets the same bucket (docs/LIVEOPS.md).
///
/// Consumers should log exposure (`logExperimentExposure`) at the point the
/// variant actually changes behaviour, not here, so exposure tracks real impact.
final experimentVariantProvider = Provider.family<String, Experiment>((
  ref,
  experiment,
) {
  final override = getIt<RemoteConfigService>().getString(
    RcKeys.experimentOverride(experiment.key),
  );
  final unit = ref.read(rewardsRepositoryProvider).installId();
  return resolveVariant(experiment, unit, override);
});
