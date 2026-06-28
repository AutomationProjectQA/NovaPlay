import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:novaplay/app/router/route_names.dart';
import 'package:novaplay/core/widgets/nova_state_view.dart';
import 'package:novaplay/core/widgets/space_background.dart';

/// Fallback screen shown for unknown routes or unrecoverable navigation errors.
/// Calm, never an alarmist red wall (docs/DESIGN_SYSTEM.md §4.12).
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SpaceBackground(
        child: SafeArea(
          child: NovaStateView(
            kind: NovaStateKind.error,
            title: 'error_title'.tr(),
            message: message ?? 'error_message'.tr(),
            icon: Icons.travel_explore,
            actionLabel: 'error_back'.tr(),
            onAction: () => context.go(Routes.home),
          ),
        ),
      ),
    );
  }
}
