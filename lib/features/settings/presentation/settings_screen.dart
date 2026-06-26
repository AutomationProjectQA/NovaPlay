import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novaplay/core/widgets/gradient_scaffold.dart';

/// Audio/haptics/locale/account settings. Wired to real services in Sprint 12+.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: Text('settings_title'.tr())),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('settings_music'.tr()),
            value: true,
            onChanged: (_) {},
          ),
          SwitchListTile(
            title: Text('settings_sound'.tr()),
            value: true,
            onChanged: (_) {},
          ),
          SwitchListTile(
            title: Text('settings_haptics'.tr()),
            value: true,
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }
}
