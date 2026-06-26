import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:novaplay/app/router/route_names.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/core/widgets/gradient_scaffold.dart';

/// Fallback screen shown for unknown routes or unrecoverable navigation errors.
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: AppSpacing.md),
              Text(
                message ?? 'Something went wrong.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => context.go(Routes.home),
                child: const Text('Back to home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
