import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novaplay/core/widgets/widgets.dart';

/// Daily reward + daily challenge hub. Full reward ladder and challenge level
/// land in Sprint 15; Sprint 7 ships the navigable placeholder.
class DailyScreen extends StatelessWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NovaStateView(
      kind: NovaStateKind.empty,
      icon: Icons.calendar_today,
      title: 'daily_title'.tr(),
      message: 'coming_soon'.tr(),
    );
  }
}
