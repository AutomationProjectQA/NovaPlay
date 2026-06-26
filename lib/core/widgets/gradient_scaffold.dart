import 'package:flutter/material.dart';
import 'package:novaplay/app/theme/nova_theme_extension.dart';

/// A scaffold whose body sits on the standard "lofi space" gradient backdrop.
class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    required this.body,
    this.appBar,
    super.key,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    final nova = Theme.of(context).extension<NovaTheme>()!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: nova.spaceGradient),
        child: SafeArea(child: body),
      ),
    );
  }
}
