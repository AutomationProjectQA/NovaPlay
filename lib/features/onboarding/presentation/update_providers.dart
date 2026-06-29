import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novaplay/core/constants/app_constants.dart';
import 'package:novaplay/core/di/injector.dart';
import 'package:novaplay/core/services/remote_config_service.dart';
import 'package:novaplay/core/services/update_gate.dart';

/// The current build's update status, evaluated against the Remote Config
/// thresholds (docs/LIVEOPS.md). Read at boot to gate play on a hard kill
/// switch.
final updateStatusProvider = Provider<UpdateStatus>((ref) {
  final rc = getIt<RemoteConfigService>();
  return evaluateUpdate(
    currentBuild: AppBuild.number,
    minSupportedBuild: rc.getInt(RcKeys.minSupportedBuild),
    latestBuild: rc.getInt(RcKeys.latestBuild),
  );
});
