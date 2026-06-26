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
            title: 'Lost in space',
            message: message ?? "We couldn't find that screen.",
            icon: Icons.travel_explore,
            actionLabel: 'Back to home',
            onAction: () => context.go(Routes.home),
          ),
        ),
      ),
    );
  }
}
