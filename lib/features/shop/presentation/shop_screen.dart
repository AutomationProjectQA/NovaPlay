import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:novaplay/core/widgets/widgets.dart';

/// Boosters / coins / stardust / cosmetics / remove-ads store. The IAP catalog
/// lands in Sprint 13; Sprint 7 ships the navigable placeholder.
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NovaStateView(
      kind: NovaStateKind.empty,
      icon: Icons.storefront,
      title: 'shop_title'.tr(),
      message: 'coming_soon'.tr(),
    );
  }
}
