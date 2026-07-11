import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'sync_status_indicator.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.appBarActions,
    this.bottomNavigationBar,
    this.bottomSheetSlot,
    this.floatingActionButton,
    this.drawer,
    this.appBarLeading,
  });

  final Widget body;
  final Widget? title;
  final List<Widget>? appBarActions;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheetSlot;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? appBarLeading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final List<Widget> actions = [];
    if (appBarActions != null) {
      actions.addAll(appBarActions!);
    }
    actions.add(const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      child: SyncStatusIndicator(),
    ));

    return Scaffold(
      backgroundColor: colors.background,
      drawer: drawer,
      appBar: title != null
          ? AppBar(
              leading: appBarLeading,
              title: title,
              actions: actions,
            )
          : null,
      body: SafeArea(child: body),
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheetSlot,
      floatingActionButton: floatingActionButton,
    );
  }
}
