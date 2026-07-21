import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../router/navigation_shell.dart';
import 'sync_status_indicator.dart';
import 'breadcrumbs_bar.dart';

class AppScaffold extends StatefulWidget {
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
    this.blendHeader = false,
    this.showSyncIndicator = true,
  });

  final Widget body;
  final Widget? title;
  final List<Widget>? appBarActions;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheetSlot;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? appBarLeading;
  final bool blendHeader;
  final bool showSyncIndicator;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final scrolled = _scrollController.offset > 8;
    if (scrolled != _isScrolled) {
      setState(() => _isScrolled = scrolled);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final backTarget = context.getBackTarget();

    final List<Widget> actions = [];
    if (widget.appBarActions != null) {
      actions.addAll(widget.appBarActions!);
    }
    if (widget.showSyncIndicator) {
      actions.add(const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: SyncStatusIndicator(),
      ));
    }

    final appBarBackground = widget.blendHeader && !_isScrolled
        ? colors.background
        : (widget.blendHeader && _isScrolled ? colors.surface.withValues(alpha: 0.85) : colors.surface);
    final appBarElevation = widget.blendHeader && !_isScrolled ? 0.0 : 1.0;
    final showBorder = widget.blendHeader && _isScrolled;

    Widget scaffoldContent = Scaffold(
      backgroundColor: colors.background,
      drawer: widget.drawer,
      appBar: widget.title != null
          ? AppBar(
              leading: widget.appBarLeading ??
                  (backTarget != null
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.go(backTarget),
                        )
                      : null),
              title: widget.title,
              actions: actions,
              backgroundColor: appBarBackground,
              elevation: appBarElevation,
              scrolledUnderElevation: widget.blendHeader ? 0 : 2,
              flexibleSpace: widget.blendHeader && _isScrolled
                  ? ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(color: Colors.transparent),
                      ),
                    )
                  : null,
              bottom: showBorder
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(1),
                      child: Container(
                        height: 1,
                        color: colors.border.withValues(alpha: 0.3),
                      ),
                    )
                  : null,
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BreadcrumbsBar(),
            Expanded(child: widget.body),
          ],
        ),
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
      bottomSheet: widget.bottomSheetSlot,
      floatingActionButton: widget.floatingActionButton,
    );

    if (backTarget != null && widget.appBarLeading == null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          context.go(backTarget);
        },
        child: scaffoldContent,
      );
    }

    return scaffoldContent;
  }
}
