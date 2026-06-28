import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:novaplay/app/env/app_environment.dart';
import 'package:novaplay/app/router/route_names.dart';
import 'package:novaplay/app/theme/app_colors.dart';
import 'package:novaplay/app/theme/app_spacing.dart';
import 'package:novaplay/app/theme/nova_context.dart';
import 'package:novaplay/core/di/injector.dart';
import 'package:novaplay/core/services/analytics_events.dart';
import 'package:novaplay/core/services/analytics_service.dart';
import 'package:novaplay/core/widgets/widgets.dart';
import 'package:novaplay/features/settings/presentation/settings_providers.dart';

/// App version label shown in the About section. Keep in sync with pubspec
/// `version:` (wired to package_info in a later sprint).
const String _appVersion = '1.0.0 (build 1)';

/// Audio / feel / general / about settings, backed by [settingsProvider]
/// (docs/UI_GUIDELINES.md §3.8). Every change persists immediately.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return NovaScaffold(
      appBar: AppBar(title: Text('settings_title'.tr())),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          _Section(
            title: 'settings_audio'.tr(),
            children: [
              _SliderTile(
                label: 'settings_music'.tr(),
                value: settings.musicVolume,
                onChanged: notifier.setMusicVolume,
              ),
              _SliderTile(
                label: 'settings_sound'.tr(),
                value: settings.sfxVolume,
                onChanged: notifier.setSfxVolume,
              ),
            ],
          ),
          _Section(
            title: 'settings_feel'.tr(),
            children: [
              _SwitchTile(
                label: 'settings_haptics'.tr(),
                value: settings.haptics,
                onChanged: (v) {
                  notifier.setHaptics(enabled: v);
                  getIt<AnalyticsService>().logSettingsChanged(
                    setting: 'haptics',
                    value: v,
                  );
                },
              ),
              _SwitchTile(
                label: 'settings_reduced_motion'.tr(),
                value: settings.reducedMotion,
                onChanged: (v) {
                  notifier.setReducedMotion(enabled: v);
                  getIt<AnalyticsService>().logSettingsChanged(
                    setting: 'reduced_motion',
                    value: v,
                  );
                },
              ),
            ],
          ),
          _Section(
            title: 'settings_general'.tr(),
            children: [
              _NavTile(
                label: 'settings_language'.tr(),
                trailing: 'English',
                onTap: () => _pickLanguage(context),
              ),
              _NavTile(
                label: 'settings_account'.tr(),
                trailing: 'settings_signed_out'.tr(),
                onTap: () => _todo(context),
              ),
            ],
          ),
          _Section(
            title: 'settings_about'.tr(),
            children: [
              _NavTile(
                label: 'settings_restore'.tr(),
                onTap: () => _todo(context),
              ),
              _NavTile(
                label: 'settings_privacy'.tr(),
                onTap: () => _todo(context),
              ),
              _NavTile(
                label: 'settings_reset_tutorial'.tr(),
                onTap: () {
                  notifier.setTutorialSeen(seen: false);
                  showNovaSnackBar(
                    context,
                    message: 'settings_tutorial_reset'.tr(),
                    status: NovaSnackStatus.success,
                  );
                },
              ),
              if (!AppEnvironment.instance.isProd)
                _NavTile(
                  label: 'settings_dev_gallery'.tr(),
                  onTap: () => context.push(Routes.gallery),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Text(
                  'Version $_appVersion',
                  style: context.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _pickLanguage(BuildContext context) {
    unawaited(
      showNovaSheet<void>(
        context,
        sheet: NovaSheet(
          title: 'settings_language'.tr(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                trailing: const Icon(Icons.check, color: AppColors.nova500),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _todo(BuildContext context) {
    showNovaSnackBar(context, message: 'Coming soon');
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: Text(
            title.toUpperCase(),
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.onMedium,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          SizedBox(width: 88, child: Text(label)),
          Expanded(
            child: NovaSlider(value: value, onChanged: onChanged),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${(value * 100).round()}%',
              textAlign: TextAlign.end,
              style: context.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          NovaSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.label, required this.onTap, this.trailing});

  final String label;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(trailing!, style: context.textTheme.bodyMedium),
          const Icon(Icons.chevron_right, color: AppColors.onMedium),
        ],
      ),
      onTap: onTap,
    );
  }
}
