# MISTAKES.md — append-only ledger

Every agent that fixes a bug caused by a wrong assumption appends here.
Read before starting. Never edit past entries.

---

### 2026-07-13 · lucide_icons dependency version incompatibility

- **Context:** Adding lucide_icons to pubspec.yaml for bottom nav and theme toggle UI.
- **Mistake:** Attempted to add `lucide_icons: ^0.368.0` which doesn't resolve in this Flutter environment.
- **Root cause:** Wrong semantic version constraint; no compatible version exists at 0.368.0.
- **Fix applied:** Removed lucide_icons from pubspec.yaml dependencies. Using Flutter's built-in icon sets (Icons) instead of lucide_icons for now. Will substitute lucide icon names with Material icons equivalents in inventory + bottom nav screens.
- **Rule for next agent:** NEVER add lucide_icons without first verifying compatible versions. Use `flutter pub add lucide_icons` to auto-resolve, or stick to Material Icons.
- **Guardrail:** Build output verification step must run before claiming done. `flutter analyze` will catch broken imports.

---



### 2026-07-13 · Disposed ref access in SnackBar callbacks

- **Context:** Implementing UNDO functionality in SnackBar for new_client_screen, collect_screen, and sale_screen.
- **Mistake:** Placed `ref.read()` calls directly in SnackBar action `onPressed` callbacks, which are deferred until user interaction. The ConsumerState widget may be disposed by then, causing "Cannot use ref after widget was disposed" exception.
- **Root cause:** Riverpod's `ref` is lifecycle-bound to ConsumerState. Deferred callbacks (timers, SnackBar actions, etc.) must capture values synchronously before the callback is registered. Accessing ref in an async callback that may execute after disposal is fundamentally unsafe.
- **Fix applied:** Captured repository and notifier instances immediately (before showing SnackBar), then used captured variables in the callback closure. Applied to new_client_screen (2 locations), collect_screen, and sale_screen.
- **Rule for next agent:** NEVER use `ref.read()` or `ref.watch()` inside deferred callbacks (SnackBar, Timer, Future.delayed). Always capture values before passing to callbacks: `final val = ref.read(...); onPressed: () { val.doSomething(); }`.
- **Guardrail:** Lint rule would require importing and checking for ref usage in closure bodies. For now: code review + runtime testing on device. All SnackBarAction callbacks must be inspected for direct ref access.

---

### 2026-07-13 · Navigator.pop() vs context.pop() in GoRouter modals

- **Context:** Dismissing modal screens (Sale, Collection) from save callbacks.
- **Mistake:** Used deprecated `Navigator.pop(context)` instead of `context.pop()` from GoRouter. This causes GoRouter's state to desync from Flutter's Navigator state, leading to "You have popped the last page off the stack" assertion failures.
- **Root cause:** GoRouter implements custom navigation via GoRouterDelegate. Using the raw Navigator API bypasses GoRouter's state management. GoRouter routes must use `context.pop()` (from GoRouter extension) or `context.go()` for navigation.
- **Fix applied:** Replaced `Navigator.pop(context)` with `if (mounted) context.pop()` in sale_screen.dart line 59 and collect_screen.dart line 63.
- **Rule for next agent:** NEVER call `Navigator.pop()`, `Navigator.push()`, or raw Navigator methods in any GoRouter route. Always use `context.pop()`, `context.push()`, `context.go()`, or `context.replace()` from GoRouter extensions.
- **Guardrail:** Grep for `Navigator.pop|Navigator.push` in `features/**/*.dart`. All should be context-based GoRouter calls. Add a pre-commit hook or lint rule to enforce this.

---

### 2026-07-13 · Multiple SnackBar unsafe patterns in single file

- **Context:** new_client_screen had three SnackBar actions: discard confirmation, createOnly, createAndSale.
- **Mistake:** Fixed one (line 200) but missed another (line 165) with the same disposed ref bug. Similar patterns across multiple screens. Not all instances were caught in single pass.
- **Root cause:** Incomplete refactoring + no systematic grep for the pattern across codebase before declaring fix complete.
- **Fix applied:** Second pass identified and fixed line 165. Then grepped all files for SnackBarAction patterns. Only found 4 total instances (3 in new_client_screen, 1 in confirm_snackbar.dart). All now safe.
- **Rule for next agent:** After fixing a bug pattern in one file, ALWAYS grep the entire codebase for the same pattern in other files before marking done. `grep -r "SnackBarAction" lib/` should be run.
- **Guardrail:** End-of-task verification should include: (1) fix in primary file, (2) grep for pattern across entire features/ and core/, (3) fix all instances, (4) document count fixed, (5) run build + lint.

---

### 2026-07-13 · Bottom Navigation Bar in v1
- **Context:** Implementing the navigation shell.
- **Mistake:** Assuming bottom navigation was excluded from v1 per `design-skill.md`.
- **Root cause:** Specs were updated in `navigation-shell-spec.md` to explicitly require a bottom nav, overriding `design-skill.md`.
- **Fix applied:** Re-introduced bottom navigation via `FloatingBottomNav` and `NavigationShell`.
- **Rule for next agent:** ALWAYS read product specs (in `specs/`) over generic design docs (`design-skill.md`) if there is a conflict. Bottom nav IS in v1.
- **Guardrail:** Spec read order check before implementation.

---

### 2026-07-13 · GoRouter pop exception when calling context.pop() on empty stack

- **Context:** Implementing back navigation inside full-screen screens (`NewClientScreen`, `SaleScreen`, `CollectScreen`).
- **Mistake:** Used `context.pop()` in screens that might be navigated to via `context.go()` (which replaces the route history stack). This throws a `GoError: There is nothing to pop` exception.
- **Root cause:** Assumed these screens are always pushed via `context.push()`. However, the Dashboard's quick actions row uses `context.go(Routes.newClient)`, and `NewClientScreen` itself navigates to the sale screen via `context.go(Routes.sale(...))`. In these cases, there is no route history to pop back to.
- **Fix applied:** Implemented safe back navigation: check `context.canPop()` before calling `.pop()`, and fall back to the screen's logical parent (`context.getBackTarget()` or `Routes.dashboard`) via `context.go()` if `.canPop()` is false. Also fixed `_computeBackTarget` in `navigation_shell.dart` to map `/customer/new` to `Routes.dashboard` instead of returning garbage.
- **Rule for next agent:** NEVER call `context.pop()` directly in screens that might be deep-linked or navigated to via `context.go()`. ALWAYS check `context.canPop()` first or fall back to `context.getBackTarget()`.
- **Guardrail:** Grep search for `context.pop` and verify that each instance checks `context.canPop()` or has a safe fallback path.

---

### 2026-07-13 · Hardcoded back-buttons overriding AppScaffold dynamic targets

- **Context:** Implementing the route sequence screens (Weekday -> Place -> Area -> Customer).
- **Mistake:** Added an `appBarLeading` IconButton with a hardcoded `context.go()` action (e.g. `Routes.weekday('Thursday')` or `Routes.place('Monday', ...)` defaults) inside each screen.
- **Root cause:** Forgot that `AppScaffold` automatically handles building the back button using `_computeBackTarget(GoRouterState.of(context))`. Passing `appBarLeading` overwrote the dynamic parameter-aware back navigation with a static or defaulted parameter, breaking back navigation if the user wasn't strictly following the default path (e.g. going back from Place screen would always drop you on Thursday).
- **Fix applied:** Removed `appBarLeading` from `WeekdayScreen`, `PlaceScreen`, `AreaScreen`, and `CustomerDetailScreen`. `AppScaffold` now dynamically calculates the back-route perfectly. Also fixed the `EmptyState` back-buttons to use `context.getBackTarget()`.
- **Rule for next agent:** NEVER supply `appBarLeading` with an `Icons.arrow_back` in any screen wrapped with `AppScaffold` unless you are explicitly intercepting form discarding. Let the scaffold handle back navigation.
- **Guardrail:** Grep for `appBarLeading` in `app/lib/features`. It should only exist in form screens that require dirty-state interception.

---

### 2026-07-13 · PopScope fails to intercept device back button when GoRouter stack is empty

- **Context:** Intercepting the hardware back button on Android to implement custom breadcrumb back navigation using `context.go(backTarget)`.
- **Mistake:** Used `PopScope(canPop: false)` to intercept the back button.
- **Root cause:** Since we navigate laterally/downward using `context.go()`, the `GoRouter` navigation stack only ever contains 1 route. When the Android back button is pressed, the `GoRouter` root `Navigator` sees only 1 route and immediately returns `false` to the OS (telling Android to close the app) *without* invoking the `PopScope` inside the route. `PopScope` prevents popping from the Navigator, but it doesn't prevent the root Navigator from reporting "empty" to the system dispatcher.
- **Fix applied:** Replaced `PopScope` with `BackButtonListener` in `AppScaffold` and `NewClientScreen`. `BackButtonListener` registers directly with the system/router `BackButtonDispatcher`, explicitly returning `true` to cancel the app close and instead executing `context.go(backTarget)`.
- **Rule for next agent:** NEVER rely on `PopScope` to prevent app closure in a flat `GoRouter` setup (where `context.go` replaces the stack). ALWAYS use `BackButtonListener` if you need to intercept hardware back to execute a custom `context.go()`.
- **Guardrail:** Grep search for `PopScope` in `lib/`. It should not be used for root-level navigation interception.

---

### 2026-07-22 · BuildContext across async gaps (`use_build_context_synchronously`)

- **Context:** Dismissing the transaction filters bottom sheet after picking a custom date range in `_selectCustomDateRange(context).then(...)`.
- **Mistake:** Calling `context.pop()` inside an asynchronous callback closure without checking if the widget/context is still mounted.
- **Root cause:** Forgot that async gaps invalidate raw `BuildContext` references.
- **Fix applied:** Added `&& context.mounted` check before calling `context.pop()`.
- **Rule for next agent:** ALWAYS check `context.mounted` before accessing or executing operations on `BuildContext` inside any asynchronous callback (e.g., `Future.then`, `await`).
- **Guardrail:** `flutter analyze` will fail with a `use_build_context_synchronously` lint warning if this is violated.

---

### 2026-07-22 · Bottom layout overflow when keyboard is open

- **Context:** Displaying empty states in `clients_screen.dart` and `transactions_screen.dart`.
- **Mistake:** Placing a fixed-height layout column with large vertical padding (`AppSpacing.xxl`) inside an `Expanded` widget. When the soft keyboard opens, it reduces available screen height and causes a `BOTTOM OVERFLOWED` layout error.
- **Root cause:** Assuming the empty state widget would always have enough screen height.
- **Fix applied:** Wrapped the empty state's inner container in a `SingleChildScrollView` and reduced vertical padding.
- **Rule for next agent:** ALWAYS wrap empty state layouts in a `SingleChildScrollView` or a scrollable widget if they contain vertical text, icons, and buttons that could overflow when the keyboard is open.
- **Guardrail:** Verify layout responsiveness under different keyboard states during review.

---

### 2026-07-22 · GridView.builder parameters & Theme colors extension

- **Context:** Implementing `CustomCalendarView` and dialog pop-up inside customer details card view.
- **Mistake:** (1) Attempted to pass `crossAxisCount` directly to `GridView.builder` (which is only valid in `GridView.count`), causing compilation failure. (2) Used `Theme.of(context).colors` instead of the extension getter `context.colors` on `BuildContext`.
- **Root cause:** Mixing up parameters of different `GridView` constructors and assuming the custom theme extension was on `ThemeData` instead of `BuildContext`.
- **Fix applied:** Changed `GridView.builder` to include a `gridDelegate` with `SliverGridDelegateWithFixedCrossAxisCount` and changed `Theme.of(context).colors` to `context.colors`.
- **Rule for next agent:** ALWAYS pass `gridDelegate` to `GridView.builder` for grids, and use the `context.colors` extension for app palette.
- **Guardrail:** Run `flutter analyze` immediately after writing layout structures to verify parameter availability and extension getters.

---

### 2026-07-22 · Integrating Complete Project Knowledge Base into AGENTS.md

- **Context:** Ensuring project context is fully loaded at the start of every session without manual read operations.
- **Mistake:** Requiring agents to perform multiple file reads (`knowledge/*.md`) at the beginning of each session.
- **Root cause:** Domain knowledge, workflows, and database schema were dispersed across multiple markdown files.
- **Fix applied:** Integrated the compiled, token-efficient, and complete knowledge base (business model, route hierarchy, enums, database schema tables, views, and core workflows) directly at the end of `AGENTS.md`. Since `AGENTS.md` is automatically loaded by the system as a `RULE`, this guarantees that every new agent session has full context on start.
- **Rule for next agent:** ALWAYS keep the integrated knowledge base in `AGENTS.md` updated when database schemas or business workflows evolve.
- **Guardrail:** Validate that new project rules or schema changes are added to both `/knowledge` files and the integrated knowledge base in `AGENTS.md`.

---

### 2026-07-22 · Splash timer triggered on constructor & static GoRouter redirects

- **Context:** Ensuring the splash screen is displayed on cold startups and theme change animations are smooth.
- **Mistake:** (1) Starting the minimum splash display timer in the controller's constructor. On slow cold boots or development builds, the startup latency exceeds the 900ms minimum duration, dismissing the splash screen before the first frame even paints. (2) GoRouter did not reactively redirect on splash status updates because `refreshListenable` was not set. (3) Leaving the theme change animations at default (which is linear and fast).
- **Root cause:** Starting timers prior to visual rendering and neglecting GoRouter's reactive refresh hook.
- **Fix applied:** Moved the splash display timer logic to `startSplashTimer()` which is explicitly called inside `SplashScreen`'s post-frame callback. Added `refreshListenable` with `GoRouterRefreshStream` on the `GoRouter` provider to listen to `splashControllerProvider`. Configured `themeAnimationDuration` and `themeAnimationCurve` on `MaterialApp.router`.
- **Rule for next agent:** ALWAYS start screen-minimum duration timers on widget mount or post-frame callbacks rather than controller construction, and wire Riverpod triggers to GoRouter via `refreshListenable`.
- **Guardrail:** Ensure splash controllers do not auto-run timers in the constructor; verify `refreshListenable` mapping.

---

### 2026-07-22 · Premature GoRouter notifications & Missing Assets on startup

- **Context:** Resolving cold boot blank screens on Android and optimizing theme transition frame rates.
- **Mistake:** (1) Calling `notifyListeners()` during GoRouter's initial delegate building phase (inside `GoRouterRefreshStream` constructor), which interrupts setup and causes a blank screen. (2) Invoking `Image.asset` on a missing `assets/brand_mark.png` without verifying its presence in `pubspec.yaml`, triggering cold-start bundle exceptions. (3) Enabling color-interpolating theme transitions that cause frame drops during builds on mobile hardware.
- **Root cause:** Dispatching UI refresh events before matching state is ready, calling non-registered asset keys, and animating resource-intensive full-tree style builds.
- **Fix applied:** Replaced `GoRouterRefreshStream` with a direct `ValueNotifier` and a Riverpod `ref.listen` block inside the router provider. Replaced the `Image.asset` widget in `SplashScreen` with the standalone fallback brand mark `Container` directly. Set `themeAnimationDuration: Duration.zero` on `MaterialApp.router`. Fully implemented the premium classic editorial splash screen layout from `splash_design.md` utilizing a custom-rendered `LedgerIcon` vector, Bodoni Moda + Inter typography, safe-area geometry, and accessibility-compliant transition controls. Centered the main screen content horizontally by wrapping the parent Column in a `Center` widget, removed the top established dates block, and configured the minimum display timer to 3 seconds. Fixed horizontal offset text centering by applying left padding offsets equal to the positive letter spacings. Created a transparent status bar layout (Blinkit style) by setting `SystemUiMode.edgeToEdge`, configuring `statusBarColor: Colors.transparent` with light system icons, and setting `top: false` on `SafeArea` to stretch the deep teal canvas completely behind the top overlays. Enabled `SystemUiMode.edgeToEdge` globally at app boot in `main.dart` and defined dynamic transparent `systemOverlayStyle` in `AppBarTheme` inside `app_theme.dart` for light and dark modes, ensuring edge-to-edge styling operates dynamically across all app screens with correct icon contrasts. Configured the bottom navigation bar to support dynamic edge-to-edge scroll hiding exclusively on the Dashboard screen: set `extendBody: isDashboard` dynamically on both the outer Scaffold in [navigation_shell.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/core/router/navigation_shell.dart) and the inner Scaffold in [app_scaffold.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/core/widgets/app_scaffold.dart) to allow content to flow behind the floating bottom bar transparently on the Dashboard screen while keeping bounds solid on other screens. Wrapped `widget.child` in `MediaQuery.removePadding(removeBottom: true)` when `isDashboard` is true inside [navigation_shell.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/core/router/navigation_shell.dart) to prevent Flutter's outer Scaffold from injecting inflated nav bar height into `MediaQuery.padding.bottom`, removing the extra empty scroll space below the Dashboard. Set `systemNavigationBarColor: Colors.transparent` and `systemNavigationBarContrastEnforced: false` globally in [navigation_shell.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/core/router/navigation_shell.dart) and [app_scaffold.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/core/widgets/app_scaffold.dart) to enable dynamic system overlay blending and complete transparency for the system navigation bar across all screens. Added `NotificationListener<ScrollNotification>` inside [app_scaffold.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/core/widgets/app_scaffold.dart) to listen to scroll offset updates, enabling `blendHeader` on scroll correctly for any page (like [collect_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/collection/collect_screen.dart), [sale_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/sale/sale_screen.dart), and [new_client_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/new_client_screen.dart)). Placed the client detail action buttons inside `bottomNavigationBar` of `AppScaffold` with `extendBody: true` and `color: Colors.transparent` in [customer_detail_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/customer_detail_screen.dart) and wrapped the body in `MediaQuery.removePadding(removeBottom: true)` to prevent duplicate bottom safe area calculation, and styled the `NEW SALE` button with a surface/paper background (`colors.surface`) and primary text color. Set `bottomNavigationBarTheme.backgroundColor` to `Colors.transparent` and `elevation` to `0` in [app_theme.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/core/theme/app_theme.dart). Reduced the bottom spacer in [dashboard_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/dashboard/dashboard_screen.dart) from `96` to `AppSpacing.lg`.
- **Rule for next agent:** ALWAYS wrap Scaffold body in `MediaQuery.removePadding(removeBottom: true)` when using `extendBody: true` with a custom floating navigation bar to avoid inflated `MediaQuery.padding.bottom` space.

---

### 2026-07-23 · Floating nav bar docking offsets & Inventory safe area spacing

- **Context:** Implementing global floating navigation bar, FAB docking, and safe bottom padding across inventory and client detail screens.
- **Mistake:** (1) Using `76.0 + rawSafeAreaBottom` as the bottom offset for floating action buttons and client detail action buttons placed the buttons right against the top edge of the floating nav bar with zero breathing space. (2) Inventory screens (`inventory_categories_screen.dart`, `inventory_products_screen.dart`, `add_product_sheet.dart`) lacked safe area bottom padding on GridViews, empty state screens, and modal forms.
- **Root cause:** Neglecting extra breathing margin above the 76px nav bar height, and omitting safe bottom insets on inventory views.
- **Fix applied:** Updated bottom offsets for action buttons and FABs across [customer_detail_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/customer_detail_screen.dart), [clients_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/clients_screen.dart), [inventory_categories_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/inventory_categories_screen.dart), and [inventory_products_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/inventory_products_screen.dart) to `88.0 + rawSafeAreaBottom` (providing 12px clean breathing margin above the navigation bar). Added `88.0 + rawSafeAreaBottom` bottom padding to inventory GridViews and empty state views, and added `rawSafeAreaBottom` to form container bottom paddings in [add_product_sheet.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/widgets/add_product_sheet.dart). Replaced `FloatingActionButton.extended` with a standard `FloatingActionButton` (removing text labels) for the "New Client" and "Add Product" buttons on [clients_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/clients_screen.dart), [inventory_categories_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/inventory_categories_screen.dart), and [inventory_products_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/inventory_products_screen.dart).
- **Rule for next agent:** ALWAYS use `88.0 + rawSafeAreaBottom` (76px nav bar height + 12px breathing gap) when positioning docked FABs and action bars above the floating bottom navigation bar.

---

### 2026-07-23 · Semi-transparent button overlay styling for readability

- **Context:** Styling primary action buttons with transparency to make background scroll content visible.
- **Mistake:** Button backdrops blocked underlying screen text when scrolled.
- **Root cause:** Solid background color on buttons blocks content visualization.
- **Fix applied:** Wrapped the FABs on [clients_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/clients_screen.dart), [inventory_categories_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/inventory_categories_screen.dart), and [inventory_products_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/inventory_products_screen.dart), as well as the `NEW SALE` button on [customer_detail_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/customer_detail_screen.dart), in an `Opacity` widget set to `0.85`.
- **Rule for next agent:** ALWAYS wrap floating overlays or action buttons in `Opacity(opacity: 0.85)` if the user requests transparency to keep underlying scroll content readable.

---

### 2026-07-23 · Circular regular FAB button layout styling

- **Context:** Making key primary action FABs perfectly round.
- **Mistake:** Default Material 3 FABs are large and have slightly flattened rounded rectangle shapes, which did not align with design preferences.
- **Root cause:** Omitting explicit shape overrides on FloatingActionButtons.
- **Fix applied:** Configured `shape: const CircleBorder()` on the standard FloatingActionButtons inside [clients_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/clients_screen.dart), [inventory_categories_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/inventory_categories_screen.dart), and [inventory_products_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/inventory_products_screen.dart).
- **Rule for next agent:** ALWAYS use `shape: const CircleBorder()` on default-sized FloatingActionButtons if the user requests them to be regular-sized (56dp) but perfectly circular.

---

### 2026-07-23 · Supabase Schema RLS & Public Git Security Enforcements

- **Context:** Conducting full security and IP audit for public git repository deployment.
- **Mistake:** Database schema placeholder lacked `ENABLE ROW LEVEL SECURITY` and `GRANT` directives across all public tables, leaving potential REST endpoints open without policy enforcement.
- **Root cause:** Defining SQL schema tables without explicit RLS activation statements.
- **Fix applied:** Updated [001_schema_placeholder.sql](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/supabase/seed/001_schema_placeholder.sql) to add `GRANT` statements and `ALTER TABLE ... ENABLE ROW LEVEL SECURITY;` across all tables (`weekdays`, `places`, `areas`, `customers`, `products`, `sales`, `sale_items`, `collections`). Generated a full security audit report artifact at [security_audit_report.md](file:///C:/Users/LavanyanThandapani/.gemini/antigravity-cli/brain/265bdc04-8859-4c9e-af13-6ecf17e765cc/security_audit_report.md).
- **Rule for next agent:** ALWAYS include `GRANT` statements and `ENABLE ROW LEVEL SECURITY` on every table created in Supabase SQL migration files.

---

### 2026-07-23 · Product sheet bottom padding & solid block removal

- **Context:** Resolving solid colored bottom block above device app toggle bar on Inventory Add and Edit product forms.
- **Mistake:** Including `+ MediaQueryData.fromView(View.of(context)).padding.bottom` inside the modal sheet container's bottom padding added solid background color fill on top of system gesture area.
- **Root cause:** Adding screen bottom safe area padding directly inside container decoration padding of full modal sheets.
- **Fix applied:** Updated container bottom padding in [add_product_sheet.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/widgets/add_product_sheet.dart) to `MediaQuery.of(context).viewInsets.bottom + 24` across `_AddProductSheetState` and `_EditProductSheetState`, matching `edit_customer_sheet.dart` and eliminating the solid bottom block above the system toggle handle.
- **Rule for next agent:** NEVER add `MediaQueryData.fromView(View.of(context)).padding.bottom` inside bottom sheet container padding when `backgroundColor` is filled.

---

### 2026-07-23 · Transparent Android system navigation bar on modal sheets

- **Context:** Enforcing transparent system navigation gesture background on showModalBottomSheet views.
- **Mistake:** Solid color container background in product forms extended to screen bottom, overlaying a background color behind the transparent Android navigation bar.
- **Root cause:** Omitting `SafeArea(top: false, bottom: true)` outside sheet content and omitting `AnnotatedRegion<SystemUiOverlayStyle>` inside the modal route builder.
- **Fix applied:** Wrapped the widget trees returned by `_AddProductSheetState.build` and `_EditProductSheetState.build` in [add_product_sheet.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/widgets/add_product_sheet.dart) inside `AnnotatedRegion<SystemUiOverlayStyle>` (with systemNavigationBarColor: Colors.transparent), allowing the sheet container background to extend edge-to-edge under the system gesture bar without leaving any solid block or background.
- **Rule for next agent:** ALWAYS wrap modal bottom sheet widget content inside the Stateful/Stateless widget's `build` method with `AnnotatedRegion<SystemUiOverlayStyle>` (with systemNavigationBarColor: Colors.transparent) to ensure Android applies the styling during route overlay, and do NOT wrap the route builder in `SafeArea(bottom: true)` so the sheet draws edge-to-edge.

---

### 2026-07-24 · High-fidelity custom animated loading visuals

- **Context:** Delivering customized loader styles that avoid basic system spinners.
- **Mistake:** Depending on standard CircularProgressIndicator, which looks standard and fails to present a premium brand style.
- **Root cause:** Defaulting to native Material loading widgets instead of building custom animations.
- **Fix applied:** Created [custom_visual_loader.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/core/widgets/custom_visual_loader.dart) featuring `PulseRippleLoader` (expanding concentric radar wave rings around a central rotating core), `WaveDotLoader` (staggered scaling dot wave), and `CustomLoadingOverlay` to support premium loading behaviors without heavy external libraries.
- **Rule for next agent:** ALWAYS use `PulseRippleLoader` or `WaveDotLoader` instead of standard spinners when loading is triggered on major operations or transactions.

---

### 2026-07-24 · Migration of generic loaders to premium shimmers & custom visual dots

- **Context:** Replacing CircularProgressIndicator with SkeletonList and WaveDotLoader across customer list, details, transactions, new client registration, and collect/sale screens.
- **Mistake:** Retaining default Material spinners in main directory lists and action buttons, breaking design parity.
- **Root cause:** Standard spinners were left as placeholder loaders in initial layout iterations.
- **Fix applied:** 
  1. Updated [clients_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/clients_screen.dart) and [transactions_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/transactions/transactions_screen.dart) to show `SkeletonList` and handle stream failures via `ErrorState` with retry callbacks.
  2. Updated [customer_detail_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/customer_detail_screen.dart) detail state loading to render `SkeletonList`.
  3. Replaced button spinners and GPS locator indicators in [new_client_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/new_client_screen.dart), [collect_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/collection/collect_screen.dart), and [sale_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/sale/sale_screen.dart) with custom pulsing `WaveDotLoader` animations.
- **Rule for next agent:** NEVER leave a default CircularProgressIndicator on main listing pages or major button loading states; utilize SkeletonList or WaveDotLoader.

---

### 2026-07-24 · Custom bottom navigation bar touch targets and hit-testing

- **Context:** Resolving sluggish navigation behavior where custom bottom nav items required multiple taps or very precise taps to trigger tab switching.
- **Mistake:** Bottom nav items in [floating_bottom_nav.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/core/widgets/floating_bottom_nav.dart) had no `Expanded` wrappers inside the parent row and `GestureDetector` lacked `HitTestBehavior.opaque`.
- **Root cause:** Without `Expanded` and `behavior: HitTestBehavior.opaque`, the touch target size was limited strictly to the visual pixels of the tiny icons/text, ignoring taps on empty/transparent space around the tabs.
- **Fix applied:** Wrapped each custom tab item in an `Expanded` container widget so it consumes exactly 1/4 of the nav bar width, and set `behavior: HitTestBehavior.opaque` on the `GestureDetector` to capture clicks on all parts of the segment.
- **Rule for next agent:** ALWAYS wrap custom row navigation items in `Expanded` and set `behavior: HitTestBehavior.opaque` on `GestureDetector` to keep tab switching responsive and avoid dead zones.

---

### 2026-07-24 · Local persistent SQLite storage migration

- **Context:** Replacing the in-memory mock repository with a local SQL database using `sqflite`.
- **Mistake:** Assuming model mappings for `Nominee` and `IdProof` contained simple fields like `customerId` and `imageUrl`, which led to compilation failures since `IdProof` stores document details inside an nested `IdProofDocument` object and `Nominee` does not carry a back-reference field.
- **Root cause:** Insufficient inspection of target model classes in `lib/data/models/` before writing SQL mapper queries.
- **Fix applied:**
  1. Created [database_helper.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/data/local/database_helper.dart) containing table schemas, indexes, views, and seed data.
  2. Implemented [local_sqlite_repositories.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/data/repositories/local_sqlite_repositories.dart) representing reactive query listeners using a custom `TableBroadcaster`.
  3. Aligned `Nominee` instantiation and mapped proof media to `IdProofDocument(localUri: ...)` structures.
  4. Updated [providers.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/data/providers.dart) to wire repositories to the new SQLite database providers.
- **Rule for next agent:** ALWAYS check Freezed model constructors in `lib/data/models/` prior to mapping database query result sets to domain entities.

---

### 2026-07-24 · Alignment of local SQL schema & seeds with actual mock datasets

- **Context:** Ensuring that local SQLite database schemas and seeded tables match mock data formats rather than the outdated database-schema.md document.
- **Mistake:** Using generic placeholder categories (e.g. `Television`) and custom string keys (e.g. `mon`, `tue`) during database setup, which broke mappings to `mockCategoriesList` and search indices because the UI expected exact IDs like `w-1` and `cat-kat`.
- **Root cause:** Relying on the outdated `database-schema.md` context file instead of analyzing `lib/data/mock/mock_data.dart` which is the source of truth for current app values.
- **Fix applied:**
  1. Updated the product table schema in [database_helper.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/data/local/database_helper.dart) to define a `category_id` column matching model field expectations.
  2. Modified the seed methods to directly loop through and insert records from `mockWeekdaysList`, `mockPlacesList`, `mockAreasList`, `mockProductsList`, `mockCustomersList`, `mockSalesList`, and `mockCollectionsList`.
  3. Ensured that inventory transactions and items correctly match product prices and SKUs in rupees/paise scales.
- **Rule for next agent:** ALWAYS prioritize mock data definitions in `lib/data/mock/` over schema design files when configuring local-first databases or sync endpoints.

---

### 2026-07-24 · Upgrading local SQLite schema in development to clear cached versions

- **Context:** Resolving the 'inventory totally not loading' bug where products list failed to display.
- **Mistake:** Attempting to query newly added `category_id` columns and views while using the cached database file created under version 1, which triggered SQLite runtime errors because `onCreate` is bypassed if version is unchanged.
- **Root cause:** Neglecting to increment the database version and configure a drop/recreate upgrade policy when updating table schemas during rapid development iterations.
- **Fix applied:**
  1. Incremented the database version to `2` in [database_helper.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/data/local/database_helper.dart).
  2. Implemented the `onUpgrade` database callback and a `_dropAll` method to clean and rebuild all SQLite tables, views, and seed datasets.
- **Rule for next agent:** ALWAYS increment the version number and write an upgrade/rebuild hook in [database_helper.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/data/local/database_helper.dart) when modifying SQL tables or column schemas.

---

### 2026-07-24 · Product category key mismatch in SQL repository mappings

- **Context:** Fixing the `Null is not a subtype of type String` cast exception when opening the Inventory screen.
- **Mistake:** Accessing `m['category']` in [local_sqlite_repositories.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/data/repositories/local_sqlite_repositories.dart) after refactoring the SQLite schema to use `category_id`.
- **Root cause:** Querying a non-existent map key `category` in sqflite query maps returns `null`, which throws a cast error when cast to non-nullable `String`.
- **Fix applied:** Updated `categoryId: m['category_id'] as String` in `getProducts()`, and corrected map insert/update statements to target `'category_id'`.
- **Rule for next agent:** ALWAYS ensure database map result queries target the exact column name definition (e.g. `category_id`) rather than the model's camelCase name (e.g. `categoryId`) or older properties.

---

### 2026-07-24 · Client Details Screen layout rearrangements & field mappings

- **Context:** Refining layout order and info parameters on the client details screen.
- **Mistake:** Rendering personal details card above financial summary card, showing unused guardian data instead of profile creation dates, and placing purchased products in a disconnected bottom list.
- **Root cause:** Suboptimal layout arrangement that prioritizes auxiliary static text over key financial performance indicators and purchase history.
- **Fix applied:**
  1. Updated [customer_detail_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/customer_detail_screen.dart) to place the `FinancialSummaryBlock` at the top of the details panel.
  2. Nested the horizontal purchased products list (using `PurchasedProductCard`) inside the `FinancialSummaryBlock` card directly.
  3. Extracted the customer created date dynamically from the oldest timeline activity (usually their initial sale or opening balance setup) and passed it to `CustomerContextCard`.
  4. Swapped out the `Guardian/Spouse` row in [customer_context_card.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/customer_context_card.dart) with `Client Created Date`.
- **Rule for next agent:** ALWAYS place high-priority summary widgets (like running balances and purchase history) at the top fold of customer detail panels to maximize operational efficiency for collection agents.

---

### 2026-07-24 · Transactions Screen safe scroll height padding

- **Context:** Implementing scroll spacing at the bottom of the transactions page list to avoid contents hiding behind the floating navigation bar.
- **Mistake:** Setting standard symmetric padding on the ListView without accommodating the height of the custom floating bottom navigation bar.
- **Root cause:** Neglecting the overlay height of custom floating navigation widgets when `extendBody: true` is configured.
- **Fix applied:** Declared `rawSafeAreaBottom` in [transactions_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/transactions/transactions_screen.dart) and set the ListView bottom padding to `88.0 + rawSafeAreaBottom`.
- **Rule for next agent:** ALWAYS apply a bottom padding of `88.0 + rawSafeAreaBottom` to primary scrollable list views on screens that sit above the floating bottom navigation bar.

---

### 2026-07-27 · Local File Existence Checks & Mock Viewer Fallback in ID Proof details

- **Context:** Fixing file preview failure and document viewing crashes for ID proofs.
- **Mistake:** Attempting to render `Image.file(File(docUri))` directly and launching raw local paths without verification, which threw file system exceptions for seeded/mock files that did not exist on the device.
- **Root cause:** Assuming local database path seeds mapped to files present on disk, and parsing plain local folder strings directly into `Uri.parse` without adding the `file://` scheme prefix.
- **Fix applied:**
  1. Wrapped local file image rendering in `File(docUri).existsSync()` checks inside [customer_context_card.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/customer_context_card.dart) and [new_client_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/new_client_screen.dart).
  2. Implemented a fallback placeholder card (`_buildFilePlaceholder`) to show a clean design for missing local preview files.
  3. Added logic to parse local file paths using `Uri.file()` and fallback to a simulated digital document card dialog (`_showMockDocumentDialog`) if the file is missing from disk.
- **Rule for next agent:** ALWAYS wrap `Image.file` calls and file open actions in `File(path).existsSync()` verification checks, and provide simulated mock visual cards in offline mode when actual files are unavailable.

---

### 2026-07-27 · file:// URI parsing for file existence checks

- **Context:** Resolving file preview failure when uploading a file (still showing mock placeholder).
- **Mistake:** Passing raw `file://` scheme URIs directly into Dart's `File()` constructor.
- **Root cause:** When a user uploads a new ID proof document, the file path is saved to the database as a `file://` URI string. Passing this string directly to `File(uriString)` fails because the constructor expects a raw path string (e.g., `C:\Users\...` or `/data/...`), causing `File(uriString).existsSync()` to evaluate to false and display the mock placeholder instead of the file image.
- **Fix applied:** Added helper logic `Uri.parse(docUri).toFilePath()` in [customer_context_card.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/customer_context_card.dart) and [new_client_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/new_client_screen.dart) to convert `file://` URIs back into raw file paths before performing file checks or initializing `Image.file()`.
- **Rule for next agent:** ALWAYS convert `file://` URI strings to raw platform paths using `Uri.parse(uriString).toFilePath()` before passing them to Dart's `File` constructor.

---

### 2026-07-27 · Local File launch mode configuration and async context safety

- **Context:** Resolving file launcher crash / `<asynchronous suspension>` exception when clicking the 'Open Document' button.
- **Mistake:** Launching `file://` scheme URIs without wrapping in a try-catch block and without specifying the correct external launcher mode.
- **Root cause:** Standard `launchUrl(uri)` tries to open URIs within WebView intents by default, which throws platform exception crashes when loading local `file://` paths. Additionally, executing BuildContext references across await boundaries triggers linter sync warnings.
- **Fix applied:**
  1. Wrapped `launchUrl` in a try-catch block to handle launch failures gracefully via SnackBars.
  2. Set `mode: LaunchMode.externalApplication` to delegate local file opening to the operating system's native viewers.
  3. Guarded `BuildContext` operations with `context.mounted` checks.
- **Rule for next agent:** ALWAYS set `mode: LaunchMode.externalApplication` when launching local file URIs using `url_launcher`, and verify `context.mounted` before rendering dialogues or SnackBars inside asynchronous callbacks.

---

### 2026-07-27 · Native shell launcher for desktop platforms and SnackBar layout bounds

- **Context:** Resolving platform file launch exceptions and floating SnackBar off-screen layout assertions.
- **Mistake:** Launching `file://` URIs on Windows via `url_launcher` (which often fails due to security associations/restrictions) and displaying error notifications as floating SnackBars.
- **Root cause:**
  1. On desktop platforms (like Windows/macOS/Linux), launching file paths directly is most reliably handled by native shell processes (`Process.run('explorer.exe', [path])`) rather than web intent handlers.
  2. Floating SnackBars inside a layout with high bottom navigation overlays can exceed vertical limits and trigger performLayout boundary failures.
- **Fix applied:**
  1. Swapped direct file launches on desktop platforms to native shell calls (`Process.run('explorer.exe')` on Windows, `open` on macOS, `xdg-open` on Linux) inside [customer_context_card.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/customer_context_card.dart) and [new_client_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/new_client_screen.dart).
  2. Set `behavior: SnackBarBehavior.fixed` for file opening error SnackBars to ensure they draw at the bottom bounds and prevent layout overflow assertions.
- **Rule for next agent:** ALWAYS launch local desktop files natively via `Process.run('explorer.exe' / 'open')` instead of using `url_launcher`, and set SnackBar behavior to `fixed` when presenting warnings/errors on screens overlaid with floating bottom navigation widgets.

---

### 2026-07-27 · FileUriExposedException and integration of open_filex on Android

- **Context:** Resolving `FileUriExposedException` on Android when clicking 'Open Document'.
- **Mistake:** Attempting to share raw `file://` URIs with external apps via `url_launcher` on Android.
- **Root cause:** Android 24+ blocks sharing raw `file://` URIs outside the app's package boundary to prevent directory transversal exploits. This triggers a `FileUriExposedException` unless files are shared through a secure `FileProvider` converting the scheme to `content://`.
- **Fix applied:** Integrated the `open_filex` package, which configures Android's `FileProvider` automatically, and updated [customer_context_card.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/customer_context_card.dart) and [new_client_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/new_client_screen.dart) to call `OpenFilex.open(filePath)` on mobile platforms.
- **Rule for next agent:** ALWAYS use the `open_filex` package (`OpenFilex.open`) when opening local files on mobile devices (Android/iOS) to ensure security provider wrapping and avoid exposure crashes.

---

### 2026-07-27 · Interface parameters refactoring and AppColors constraints

- **Context:** Refactoring product price fields into cost price, selling price, and markup percentage slider.
- **Mistake:** Forgetting to update repository stubs/mocks (`MockRepository` and `SupabaseProductRepository`) when changing `ProductRepository` interface method signatures. Also, using Material 3 style colors (`surfaceContainerLowest`) that are not defined in the custom `AppColors` extension class.
- **Root cause:**
  1. Interfaces specify contracts. Adding/renaming parameters in the base interface means all sub-classes and implementors must implement the exact signature.
  2. The custom `AppColors` extension defines custom color tokens but doesn't mimic the default Material 3 color scheme class (e.g. `surfaceContainerLowest`).
- **Fix applied:**
  1. Updated `addProduct` signatures in both `MockRepository` and `SupabaseProductRepository` to match `ProductRepository`.
  2. Swapped `colors.surfaceContainerLowest` for `colors.muted.withValues(alpha: 0.05)` and imported `app_spacing.dart` into [add_product_sheet.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/widgets/add_product_sheet.dart).
- **Rule for next agent:** ALWAYS update all mock and production implementors of an interface when refactoring its method signatures, and NEVER assume M3 colors exist on `AppColors` unless explicitly defined in the theme file.

---

### 2026-07-27 · Pricing constraints and dynamic slider markup validation

- **Context:** Enforcing that selling price does not exceed maximum retail price (MRP).
- **Mistake:** Assuming the profit markup percentage slider can static-bound up to 100% when MRP limits are configured.
- **Root cause:** If cost price is high and MRP is close to cost price, a 100% markup would generate a selling price far exceeding MRP, violating business rules and user constraints.
- **Fix applied:** Added the `mrp` field and dynamically calculated the maximum allowed markup (`(((mrp - cost) / cost) * 100).clamp(5.0, 100.0)`) inside [add_product_sheet.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/widgets/add_product_sheet.dart). Used this dynamic maximum to configure the Slider's `max` and `divisions` properties, and clamped the active `_markupPercent` to it.
- **Rule for next agent:** ALWAYS constrain sliders and calculated fields dynamically based on related bounds (e.g. MRP limits), and verify bounds clamp values to prevent Flutter slider assertion crashes.

---

### 2026-07-27 · RenderFlex overflow in product list pricing Row

- **Context:** Presenting selling price, cost price, and MRP details on product catalog cards.
- **Mistake:** Rendering multiple text details side-by-side in a horizontal `Row` alongside a fixed stock badge container.
- **Root cause:** When screen widths are small or price numbers are long, the horizontal row length exceeds available width constraints and causes a `RenderFlex overflow` error.
- **Fix applied:** Wrapped the pricing `Column` in an `Expanded` widget and changed the inner `Row` of MRP and Cost elements to a `Wrap` widget in [inventory_products_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/inventory_products_screen.dart).
- **Rule for next agent:** ALWAYS wrap flexible price text columns inside standard `Row` structures in `Expanded` and use `Wrap` widgets for side-by-side text elements to avoid layout overflow issues on smaller displays.

---

### 2026-07-27 · Alignment displacement in discrete slider labels

- **Context:** Placing text indicator labels underneath a discrete slider showing divisions.
- **Mistake:** Spacing labels using a standard `Row` with `MainAxisAlignment.spaceBetween` when the slider track max value varies dynamically.
- **Root cause:** Because the slider track is a linear scale starting at a fixed minimum (5%) and ending at a dynamic maximum (e.g. 60%), simple intermediate labels (e.g. 25%, 50%) spaced evenly in a Row will not physically align with the tick marks on the slider track.
- **Fix applied:** Rendered the labels in a `Stack` of `Align` widgets, calculating the exact horizontal alignment fraction as `2 * (value - min) / (max - min) - 1` in [add_product_sheet.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/widgets/add_product_sheet.dart).
- **Rule for next agent:** ALWAYS align tick mark label indicators underneath linear sliders dynamically based on their fractional positions along the track using a Stack of Aligns, ensuring labels physically match track tick stops.

---

### 2026-07-27 · Continuous slider with discrete indicator labels

- **Context:** Building a continuous slider that has indicator labels below it representing increments of multiples of 5 (e.g., 5%, 20%, 40%, 60%, 80%, 100%).
- **Mistake:** Using discrete track configurations (`divisions`) and rounding slider values inside callback hooks, which breaks continuous sliding movement.
- **Root cause:** Defining the `divisions` parameter on a `Slider` makes the slider track discrete. Omitting `divisions` makes it continuous.
- **Fix applied:** Removed the `divisions` parameter from `Slider` and removed value rounding/snapping logic inside `_onMarkupSliderChanged` in [add_product_sheet.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/widgets/add_product_sheet.dart). Kept the dynamic `buildSliderLabels` helper to render indicators below.
- **Rule for next agent:** NEVER set the `divisions` property on `Slider` when a continuous sliding UX is desired, even if discrete visual indicators are requested below the track.

---

### 2026-07-27 · Discrete slider snapping at 5 multiples with full indicators

- **Context:** Enforcing a discrete slider snapped to 5-multiple intervals (5%, 10%, 15%...) with tick marks and digit labels for each.
- **Mistake:** Omitting the `divisions` property or removing snapped rounding inside callback listeners. Also, using string interpolation for `toStringAsFixed` values triggering unnecessary string interpolation lints.
- **Root cause:** Snapping requires both the `divisions` property on the `Slider` widget and snapped value rounding in its callbacks. Direct method outputs (like `val.toStringAsFixed(0)`) should not be nested in string interpolation templates.
- **Fix applied:** Configured `divisions: divisions` on the `Slider` widgets and snapped slider values to the nearest multiple of 5. Placed compact digit labels under each tick mark, and resolved the string interpolation warnings in [add_product_sheet.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/widgets/add_product_sheet.dart).
- **Rule for next agent:** ALWAYS use snapping rounding in slider change listeners alongside the `divisions` track property for discrete layouts, and write clean method invocations without redundant string wrappers.

---

### 2026-07-27 · Solid track line layout instead of dotted track appearance

- **Context:** Styling a discrete slider to appear visually as a dotted line of ticks instead of a solid line with dots on top.
- **Mistake:** Using standard default `trackHeight` values (e.g. 4) which draws a solid prominent bar that visually overwhelms the discrete tick marks.
- **Root cause:** The track is drawn as a solid rectangle of `trackHeight` thickness, while tick marks are drawn as circles of `tickMarkRadius` size. Setting track height very thin and tick mark radius larger changes the aesthetics to a dotted track.
- **Fix applied:** Reduced `trackHeight` to `1.5` and set `tickMarkShape` to a `RoundSliderTickMarkShape` of radius `3.0` in [add_product_sheet.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/widgets/add_product_sheet.dart).
- **Rule for next agent:** ALWAYS set a thin track height (e.g. 1.5) and larger tick mark radius (e.g. 3.0) to achieve a dotted discrete slider design in Flutter.

---

### 2026-07-27 · Pricing multiplier labels display on product cards

- **Context:** Presenting product markup multipliers visually on catalog items.
- **Mistake:** Forgetting to dynamically compute product markup percentage (`(((sellingPrice - costPrice) / costPrice) * 100).round()`) and render it visually next to the primary selling price.
- **Root cause:** Dynamic catalog details need to map exact item margins using standard formatting models.
- **Fix applied:** Rendered the computed markup margin using a multiplier tag format (`x25` for 25% markup) inside a horizontal Row next to the selling price in [inventory_products_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/inventory_products_screen.dart).
- **Rule for next agent:** ALWAYS render margin percentages using standard multiplier notations (e.g. `x25` for 25% profit margin) next to the primary selling price in catalog displays.

---

### 2026-07-27 · Credit surcharge input integration on credit sales

- **Context:** Adding a credit transaction surcharge to credit sales records.
- **Mistake:** Calculating credit surcharge as a static rupee field without support for percentages, or forgetting to pass the calculated surcharge to saveSale database queries.
- **Root cause:** Credit charges must support unit toggles (₹ and %) and be added directly to the total sale amount before determining financed amounts and running balances.
- **Fix applied:** Implemented credit charge state parameters (`creditChargeValue`, `creditChargeType`) in [sale_controller.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/sale/controllers/sale_controller.dart). Added a custom styled ₹/% toggle and numeric input in [sale_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/sale/sale_screen.dart), and passed the computed surcharge to the SQLite query save transaction.
- **Rule for next agent:** ALWAYS allow credit surcharge inputs to toggle between absolute (₹) and percentage (%) units, and add it directly to total sale values to ensure financed running balances are updated correctly.

---

### 2026-07-27 · Purchased products unification into purchase summaries

- **Context:** Transitioning from displaying individual products to displaying unified transaction summaries in customer details.
- **Mistake:** Grouping purchased items individually causing cluttered/duplicated date rows, or omitting the corresponding invoice financial summary on those cards.
- **Root cause:** Customer history screens should group transactions logically by sale event (`SaleActivity`) rather than flat product arrays.
- **Fix applied:** Replaced `PurchasedProductCard` with `PurchaseSummaryCard` in [purchased_product_card.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/purchased_product_card.dart). Unified lines using `timeline.whereType<SaleActivity>()` in [customer_detail_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/customer_detail_screen.dart), displaying item details alongside the financial summary (total, advance, credit) of that transaction.
- **Rule for next agent:** ALWAYS render customer purchases grouped by transaction event/date rather than individual products, displaying the items list and transaction totals unified in a single card.

---

### 2026-07-27 · Multiple transaction day grouping and credit charge detail representation

- **Context:** Grouping multiple sale transactions on the same calendar day into a single card representation.
- **Mistake:** Rendering individual cards for each transaction occurring on the same day instead of unifying them, or omitting timestamps and calculated credit charges.
- **Root cause:** Day-based records require grouping sale events under a single parent date object, separating nested lists by divider lines, and showing timestamps (`hh:mm a`) alongside the computed credit charge difference (`total - itemsTotal`).
- **Fix applied:** Grouped `SaleActivity` records into `GroupedSales` in [customer_detail_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/customer_detail_screen.dart). Rendered nested lists separated by `<hr>` dividers and timestamps, and added a credit charge breakdown field in [purchased_product_card.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/purchased_product_card.dart).
- **Rule for next agent:** ALWAYS append multiple sales from the same date into a unified card, separating them with dividers and timestamps, and displaying computed credit charge differences (`grandTotal - itemsTotal`) on their summaries.

---

### 2026-07-27 · Modal presentation for detailed financial transaction audits

- **Context:** Presenting granular accounting metrics (credit charges, down payments, running balances) on timeline cards.
- **Mistake:** Rendering full accounting summaries directly inside narrow horizontal card listings, causing layout crowding or text overflow.
- **Root cause:** Card templates in narrow scroll rows should only present key indicators (items, sale types, primary totals) and delegate extensive audit tables to full-size bottom sheet dialogs.
- **Fix applied:** Configured the card list in [financial_summary_block.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/financial_summary_block.dart) as a horizontal scrollable view of height 165. Added a `GestureDetector` tap handler in [purchased_product_card.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/purchased_product_card.dart) that triggers a bottom sheet modal displaying the products list, timestamps, and elevated financial calculation card for that sale.
- **Rule for next agent:** ALWAYS keep horizontal timeline summaries simple and clean, and use interactive tap actions to display complete financial calculation grids on custom elevated bottom sheets.

---

### 2026-07-27 · Bottom sheet safety paddings and product list text overflows

- **Context:** Hardening bottom sheet modals against keyboard overlays, safe area height bounds, and horizontal flex overflows.
- **Mistake:** Omitting `SafeArea` on modal contents, manual pixel paddings that clash with device notches/virtual keyboard viewInsets, or letting raw `Text` widgets overflow inside horizontal flex Rows.
- **Root cause:** Modal bottom sheets must be wrapped in `SafeArea(top: false)` and padded with `MediaQuery.of(context).viewInsets.bottom` to adapt to screen notches and soft keyboards. Horizontal lists of variable-length product names in Rows must be wrapped in `Expanded` with ellipsis overflow to prevent layout overflows.
- **Fix applied:** Wrapped the bottom sheet return in `SafeArea(top: false)` and padded with `viewInsets.bottom` in [purchased_product_card.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/purchased_product_card.dart). Wrapped item names in `Expanded` with `maxLines: 2` and `overflow: TextOverflow.ellipsis` to resolve the 21px overflow.
- **Rule for next agent:** ALWAYS wrap bottom sheet widgets in `SafeArea` with `viewInsets.bottom` padding, and wrap all variable-length name strings in `Expanded` inside Row layouts to prevent horizontal overflows.

---

### 2026-07-27 · Floating bottom navigation bar safety height in bottom sheets

- **Context:** Ensuring modal sheet content does not get hidden behind custom floating navigation bars.
- **Mistake:** Assuming system `SafeArea` or `viewInsets` is sufficient bottom padding on screens that feature custom floating tab navigation layers.
- **Root cause:** App frameworks overlaying custom floating navigation bar layouts (e.g. height 88 + system notch padding) will cover the bottom portion of default modal sheets unless we explicitly add offsetting bottom pad spaces.
- **Fix applied:** Added a dynamic calculation in [purchased_product_card.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/purchased_product_card.dart) that checks if the keyboard is open: if not, it applies a padding of `88.0 + rawSafeAreaBottom + AppSpacing.lg` to keep all controls clearly visible above the floating nav bar layer.
- **Rule for next agent:** ALWAYS add height offsets (e.g. `88.0 + rawSafeAreaBottom`) to bottom sheets displayed on pages featuring custom floating tab navigation bars to prevent content from hiding underneath them.

---

### 2026-07-27 · Revert bottom sheet modal SafeArea wrapper

- **Context:** Restoring default modal presentation without extra SafeArea wrappers.
- **Mistake:** Over-wrapping modal container overlays with SafeArea widget classes when not explicitly requested by UX/design guidelines.
- **Root cause:** Dialogs and bottom sheet modals are often managed outside the Scaffold viewport, and standard system navigation padding (`MediaQuery.of(context).padding.bottom`) is preferred over nesting.
- **Fix applied:** Reverted the bottom sheet wrapper changes in [purchased_product_card.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/purchased_product_card.dart) to return Container directly with `padding.bottom` set to `MediaQuery.of(context).padding.bottom + AppSpacing.lg`.
- **Rule for next agent:** NEVER wrap default bottom sheets in additional `SafeArea` layers unless specifically requested, using standard system pad heights to handle device home indicators.

---

### 2026-07-27 · Navigation bar height offset inside bottom sheet padding

- **Context:** Preventing bottom sheet contents from rendering underneath the app's custom floating bottom navigation bar.
- **Mistake:** Omitting the `88.0` custom navigation bar height offset from the sheet container bottom padding parameter when not using standard layout screens.
- **Root cause:** Default modal bottom sheet windows start from the absolute bottom of the window, so any custom overlay tab navigation bars (height `88.0`) sitting on top of the screen will hide the bottom of the sheet unless padding explicitly accounts for it.
- **Fix applied:** Configured the bottom padding of the sheet container in [purchased_product_card.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/purchased_product_card.dart) to be `MediaQuery.of(context).padding.bottom + 88.0 + AppSpacing.lg`.
- **Rule for next agent:** ALWAYS add custom floating navigation bar height offsets (`88.0`) to the container's bottom padding when designing modal bottom sheets on screens that display the custom floating navigation shell.

---

### 2026-07-27 · Credit charge scaling bug and unified same-day sales cards

- **Context:** Grouping same-day sales of all payment types (ready cash/credit) and fixing scaling multiplier bugs on saved credit charges.
- **Mistake:** Multiplying `creditChargeAmount` by 100 before calling `saveSale` database stubs, or dividing same-day sales into separate cards when they have different sale types.
- **Root cause:** The database and repository layer processes sales and surcharge metrics in whole rupees, so multiplying by 100 scaled a ₹1,000 charge up to ₹1,00,000. Additionally, timeline cards should group all sales on the same date regardless of their READY/CREDIT type.
- **Fix applied:** Removed the `* 100` scaling multiplier on the `creditCharge` parameter in [sale_controller.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/sale/controllers/sale_controller.dart). Grouped sales by date only (using `dateOnly`) and derived the primary card badge by checking if any sale contains credit terms in [customer_detail_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/customer_detail_screen.dart).
- **Rule for next agent:** ALWAYS pass credit surcharge fields to save sale repository stubs in whole rupees (no `* 100` multiplication), and group all sale events on the same calendar date into a single card.

---

### 2026-07-27 · Visual transaction occurrence chips in horizontal catalog summaries

- **Context:** Transitioning initial card bodies from text product list files to graphical occurrence chips.
- **Mistake:** Rendering full product name lists directly inside small horizontal overview cards, causing clutter or duplication of detail.
- **Root cause:** Overview blocks should summarize structural states (e.g. sequence of Credit/Ready events) visually and let users drill down on tap to read detailed products list.
- **Fix applied:** Replaced the products list ListView with a dynamic `Wrap` of small cards/chips representing each sale occurrence, color-coded in green for `Ready` (cash) and red for `Credit` with timestamps in [purchased_product_card.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/purchased_product_card.dart).
- **Rule for next agent:** ALWAYS render horizontal timeline summary card bodies as visual occurrence chips (green for Ready, red for Credit) indicating chronological events rather than raw product text.

---

### 2026-07-27 · Graph timeline UI with axis lines and nodes in purchase summaries

- **Context:** Transitioning card summary views into stylized progress timeline axis widgets.
- **Mistake:** Using flat chip grids that do not communicate linear progress or step events chronologically.
- **Root cause:** Day transactions represent chronological step progress. Displaying them as nodes on a horizontal axis line provides a graph-like visual feed.
- **Fix applied:** Implemented a horizontal graph timeline UI inside [purchased_product_card.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/purchased_product_card.dart) utilizing a background axis line and centered nodes (circles with thick matching borders and glowing shadows) indicating daily Ready/Credit sale occurrences with times.
- **Rule for next agent:** ALWAYS display horizontal daily overview cards utilizing a timeline graph widget with axis lines and glowing circular nodes.

---

### 2026-07-27 · Grid stroke graph timeline layout with X and Y axes

- **Context:** Transitioning daily summary cards into mini graph-grid analytical visual widgets.
- **Mistake:** Omitting grid strokes, Y-axis references (Ready vs Credit), or trace lines connecting coordinates to timeline bounds.
- **Root cause:** Day-based timeline plots are best represented as coordinates mapping type (Y-axis) against transaction times (X-axis) overlaid on a structured grid layer.
- **Fix applied:** Implemented an analytical graph timeline layout in [purchased_product_card.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/purchased_product_card.dart) featuring Y-axis labels ('Ready' at top in green, 'Credit' at bottom in red), horizontal/vertical dashed grid stroke lines, solid X & Y axis lines, and trace-connected node circles representing chronological sale coordinates with bottom timestamps.
- **Rule for next agent:** ALWAYS render purchase overview bodies utilizing a grid chart layout displaying Ready (top Y-axis) and Credit (bottom Y-axis) points trace-linked to the X-axis timeline.

---

### 2026-07-27 · Responsive timeline nodes using Expanded to prevent RenderFlex overflow

- **Context:** Preventing horizontal RenderFlex layout overflows when a customer records multiple transactions in a single day.
- **Mistake:** Using fixed-width widgets (`SizedBox(width: 48)`) for plotted timeline nodes inside small horizontal parent cards (width `220`), which causes right-edge visual overflows.
- **Root cause:** Dynamic counts of elements in horizontal layout rows must divide the parent space proportionally to guarantee they never exceed strict layout boundaries.
- **Fix applied:** Replaced fixed-width graph coordinates inside [purchased_product_card.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/purchased_product_card.dart) with `Expanded` widgets, allowing nodes to share the available horizontal space dynamically and resolving the 27px overflow.
- **Rule for next agent:** ALWAYS wrap plotted timeline grid nodes in `Expanded` inside Row layouts to ensure they scale dynamically without causing horizontal RenderFlex overflows.

---

### 2026-07-27 · Unified single grid graph timeline representing purchase summaries

- **Context:** Replacing multiple sliding timeline cards with a single unified chronological chart widget.
- **Mistake:** Rendering distinct card scroll lists for transactions when the user prefers a single, macro-view grid graph (Y: Date, X: Time).
- **Root cause:** Macro analytical dashboards are cleaner and less prone to overflow bugs when they present all transaction dates and times on a single timeline axis board using coordinate alignments.
- **Fix applied:** Overwrote [financial_summary_block.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/financial_summary_block.dart) to draw a single Grid Chart (Y-axis: Dates as rows, X-axis: Times as columns) with responsive alignment coordinates (`hourFraction`), where tapping plotted node circles (green/red) opens the detailed elevated financial summary bottom sheet. Deleted the unused `purchased_product_card.dart` imports.
- **Rule for next agent:** ALWAYS render customer purchase summaries as a single unified grid timeline graph (Y: Date, X: Time) displaying interactive tapped nodes rather than separate scrollable cards.

---

### 2026-07-27 · GitHub contribution activity grid for purchase summaries

- **Context:** Transitioning daily transaction indicators into a GitHub-style weekly contribution activity matrix.
- **Mistake:** Building standard timeline axes when the user specifically requests a commit grid chart representation.
- **Root cause:** Git contribution charts represent activity density per calendar day arranged as weekdays (Y-axis) by weeks (X-axis).
- **Fix applied:** Re-implemented the purchase summary block in [financial_summary_block.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/financial_summary_block.dart) as a GitHub contribution grid displaying 8 weeks (columns) of 7 days (rows). Cells are color-coded (red for Credit sales, green for Ready cash sales, grey for no activity) and labeled with weekday ticks (`Mon`, `Wed`, `Fri`, `Sun`) and dynamic Month name headers. Tapping any active cell opens the detailed financial invoice list modal.
- **Rule for next agent:** ALWAYS render purchase histories as a GitHub contribution activity grid chart showing Ready (green) and Credit (red) calendar cells mapped over weeks.

---

### 2026-07-27 · Stateful calendar contribution grid with 5-year and 12-month selectors

- **Context:** Implementing navigation controls to allow viewing daily transaction activity across months and years.
- **Mistake:** Rendering rigid weekly grids that cannot scroll or represent historical transactions spanning several years.
- **Root cause:** To inspect transaction trends, collectors need to select specific years and months. Presenting this as a monthly calendar grid (7 columns for weekdays, 5-6 rows for weeks) allows all dates of any selected month to be visually represented responsively on mobile.
- **Fix applied:** Converted [financial_summary_block.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/financial_summary_block.dart) to a stateful widget. Added a horizontal Year selector (5 years choice pills) and Month selector (12 month chips) that update the visual calendar grid. Cells represent calendar days (labeled `1` to `31`), color-coded based on sale activity status (green: Ready, red: Credit, grey: empty/inactive). Tapping active days triggers detailed timeline bottom sheet modals.
- **Rule for next agent:** ALWAYS display calendar-style purchase activity matrices utilizing stateful Year (5 options) and Month (12 options) pills above a 7-column weekday calendar grid.

---

### 2026-07-27 · Combined concise month and year filters top-row layout

- **Context:** Saving visual space inside the calendar chart filters layout.
- **Mistake:** Dedicating separate full-width rows for Year and Month selectors, causing vertical scroll bloat.
- **Root cause:** Year selection can be rendered as a compact dropdown menu on the right side of the screen, freeing up horizontal space on the left to render the Month capsule scroll list.
- **Fix applied:** Redesigned the filter header in [financial_summary_block.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/financial_summary_block.dart) by wrapping Months scroll (left) and Year selection DropdownButton (right) into a single concise Row layout. Removed the unused `_buildWeekdayLabel` helper method.
- **Rule for next agent:** ALWAYS align horizontal Month tabs and Year dropdown filters into a single concise row directly above the calendar grid to save vertical display space.

---

### 2026-07-27 · Split-pane GitHub calendar grid with vertical month selector and event chips

- **Context:** Implementing a highly detailed GitHub-style activity grid with vertical scrolling month navigation and event logs.
- **Mistake:** Rendering day numbers inside cells or losing sequential event context in overview layouts.
- **Root cause:** Real GitHub contribution grids show blank status squares representing weekday rows by calendar weeks, requiring chronological lists of active event chips below the grid for text readability.
- **Fix applied:** Overwrote [financial_summary_block.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/financial_summary_block.dart) with a split-pane layout containing a vertical Month list selector on the left and a blank GitHub grid matrix (Mon-Sun rows, weeks columns) on the right. Below the grid is a chronological list of compact event chips showing date tags, status indicators, and total rupees. Corrected SizedBox alignment/margin compilation issues.
- **Rule for next agent:** ALWAYS render split-pane purchase summaries as a vertical Month scroll selector (left) beside a blank GitHub calendar grid (right) with chronological detailed event chips below.

---

### 2026-07-28 · Sorted Month list filter starting from current month going backward

- **Context:** Keeping the current month at the top of the scroll filter list in chronological order.
- **Mistake:** Listing calendar months in fixed January-to-December order, requiring the collector to scroll down to view current month transactions.
- **Root cause:** Navigation structures are most helpful when recent activity is immediately displayed first, and historical periods follow as you scroll deeper.
- **Fix applied:** Configured the Month vertical filter list inside [financial_summary_block.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/financial_summary_block.dart) to generate ordered months dynamically (current month at index 0, followed by previous months in reverse chronological order going back 12 steps).
- **Rule for next agent:** ALWAYS sort scrollable month filter lists starting from the current month going backward in time to keep recent context visible first.

---

### 2026-07-28 · Chronologically sorted Month filter list starting from current month (rotated)

- **Context:** Ordering months in standard chronological sequence (January to December) but starting the vertical selector list with the current month at index 0.
- **Mistake:** Sorting months in reverse chronological order when the user explicitly requests correct chronological sequence starting from the current month.
- **Root cause:** Standard chronological order is preferred for planning, but rotating the starting month keeps the current calendar month instantly visible at the top.
- **Fix applied:** Corrected the month generator logic in [financial_summary_block.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/financial_summary_block.dart) to start from the current month and iterate forward chronologically wrapping around December: `(currentMonth + index - 1) % 12 + 1`.
- **Rule for next agent:** ALWAYS sort scrollable month filters chronologically forward starting from the current month rotated.

---

### 2026-07-28 · Standard chronological Month list with ScrollController viewport offset

- **Context:** Displaying the Month vertical filter list in standard January-to-December calendar order while focusing the viewport on the current month initially.
- **Mistake:** Custom index-remapping or rotating the months list layout when the user prefers the normal January-to-December sequence with custom scroll focus.
- **Root cause:** The list items should maintain standard calendar sequence, but we scroll the viewport automatically to position the current month first upon loading.
- **Fix applied:** Restored standard `index + 1` (January to December) calendar order in [financial_summary_block.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/financial_summary_block.dart) and utilized a `ScrollController` initialized with an `initialScrollOffset` of `(currentMonth - 1) * 36.0` to position the current month at the top of the viewport when initialized.
- **Rule for next agent:** ALWAYS keep scrollable month filters in standard chronological January-to-December order, using a ScrollController with offset calculations to scroll the current month to the top of the viewport.

---

### 2026-07-28 · Add to Cart UI/UX with Builder-encapsulated non-nullable Cart item extraction

- **Context:** Implementing direct Add and quantity counter adjustment actions in the product catalog sheet for new sales.
- **Mistake:** Accessing nullable variables in closures or relying on implicit type-promotion in collection literals (`if` / `else if` blocks), which causes compiler warnings about nullable receivers.
- **Root cause:** Dart's flow analysis does not propagate local variable type promotion inside callback closures or collection lists.
- **Fix applied:** Converted `_ProductPickerSheet` in [sale_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/sale/sale_screen.dart) to a Riverpod `ConsumerStatefulWidget` so catalog additions and adjustment actions update the provider directly. Wrapped the quantity controller in a local `Builder` widget block inside the row list, declaring a local non-nullable variable `final cartItem = state.lineItems[existingIndex];` to completely avoid compiler warnings. Added a floating Zomato-style bottom Cart Summary bar.
- **Rule for next agent:** ALWAYS encapsulate lists or widgets utilizing conditionally present items inside a local `Builder` to extract non-nullable states cleanly and avoid compiler type promotion warnings.

---

### 2026-07-28 · Custom GestureDetector replacement for IconButton to prevent layout overflows

- **Context:** Resolving RenderFlex layout overflows inside the cart quantity adjuster row.
- **Mistake:** Using material `IconButton` widgets in narrow flex layouts (like a product list row item) without completely overriding default layout padding, causing minor horizontal overlaps and `RenderFlex` overflows.
- **Root cause:** Flutter's `IconButton` has implicit margins and touch-target padding constraints that can exceed parent flex widths.
- **Fix applied:** Replaced `IconButton` widgets in the quantity adjuster row of [sale_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/sale/sale_screen.dart) with custom `GestureDetector` widgets wrapping `Container` structures of exact `28x28` dimensions.
- **Rule for next agent:** NEVER use raw `IconButton` widgets in space-constrained horizontal rows where precise widths are needed; use custom `GestureDetector` widgets with fixed-size containers instead.

---

### 2026-07-28 · Global unfocus GestureDetector inside MaterialApp builder

- **Context:** Implementing global tap-to-dismiss keyboard behavior when clicking outside text inputs.
- **Mistake:** Wrapping individual screens or views with GestureDetector which fails to unfocus text inputs inside overlay routes, alerts, and bottom sheet modals.
- **Root cause:** Dialogs, bottom sheets, and route changes render inside the top-level Navigator overlay, bypassing individual screen GestureDetectors.
- **Fix applied:** Wrapped the `builder` parameter of `MaterialApp.router` in [app.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/app.dart) with a translucent `GestureDetector` executing `FocusManager.instance.primaryFocus?.unfocus()`.
- **Rule for next agent:** ALWAYS wrap the MaterialApp builder widget with a translucent GestureDetector executing FocusManager unfocus to handle tap-to-dismiss keyboards globally across all screens and bottom sheets.

---

### 2026-07-28 · Cached non-zero bottom safe-area offset to prevent bottom navigation overlaps during transitions

- **Context:** Resolving action button layout overlaps on screen back-transitions inside bottom-navigation shells.
- **Mistake:** Accessing raw view safe-area bottom padding inside transition frames where the overlay values temporarily drop to `0.0`, causing positioned elements to sink and overlap.
- **Root cause:** Flutter route transition animations can cause the underlying window view safe-area metrics to fluctuate or reset to zero temporarily.
- **Fix applied:** Implemented a persistent tracker variable `_maxSafeAreaBottom` in [customer_detail_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/customer_detail_screen.dart) that captures and locks the maximum non-zero safe area bottom padding ever reported by the view. Adjusted button position offset baseline from `88` to `96` to guarantee clearance over the floating bottom nav bar.
- **Rule for next agent:** ALWAYS cache the maximum non-zero safe area bottom padding reported by the view to prevent elements in extend-body layouts from dropping down and overlapping bottom bars during route transitions.

---

### 2026-07-28 · Disabled search bar autofocus to prevent keyboard occlusion in bottom sheets

- **Context:** Preventing the software keyboard from invoking automatically on launching the product picker.
- **Mistake:** Setting `autofocus: true` on search text fields inside modal bottom sheets, causing the keyboard to invoke automatically and cover essential scroll content on presentation.
- **Root cause:** Automatically focusing inputs inside modal overlays forces keyboard popups that disrupt visual discovery of content unless the user intentionally chooses to type.
- **Fix applied:** Changed `autofocus: true` to `autofocus: false` in the product picker search field of [sale_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/sale/sale_screen.dart).
- **Rule for next agent:** NEVER set autofocus to true on search or filter fields inside overlay sheets to prevent keyboard occlusion on initial display.

---

### 2026-07-28 · Dynamic clients dashboard stats and green lowercase settled filter chip

- **Context:** Ensuring search/filter screens present statistics based on current active query results, and styling settled indicators.
- **Mistake:** Rendering overall database counts and total outstandings instead of updating statistics reactively based on filtered results. Hardcoding standard chips without styling special status options.
- **Root cause:** Collectors filter the clients screen to see specific places or weekdays; dashboard indicators must represent the exact subset of clients currently visible to be useful. Settled accounts indicate complete collection (success) and should use green indicators.
- **Fix applied:** Reordered filter logic to run before stats calculations in [clients_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/clients_screen.dart). Replaced overall dataset length and outstandings with filtered list parameters. Re-routed the "Settled" status filter chip styling to draw the text "settled" (lowercase) with `colors.success` formatting when active.
- **Rule for next agent:** ALWAYS calculate screen summary headers, counts, and outstanding metrics using the active filtered list rather than the full database list, and color settled filter chips green using lowercase text.

---

### 2026-07-28 · Clients list sorting and search-replace block boundaries safety

- **Context:** Sorting the clients list by outstanding balance descending to show active accounts on top and settled accounts at the bottom, and resolving compile failures.
- **Mistake:** Removing required return statements from closure bodies during replace tool invocations due to overlapping match scopes.
- **Root cause:** The replacement range included the `return true;` statement at the tail end of the closure block which was missing from the replacement content, causing a compile-time type mismatch error.
- **Fix applied:** Sorted the `filtered` list in [clients_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/clients_screen.dart) using a compare callback on outstanding balances descending (`outB.compareTo(outA)`). Restored the missing `return true;` statement inside the `where` closure.
- **Rule for next agent:** ALWAYS double check replacement targets to ensure closure return statements or punctuation symbols are not accidentally swallowed, and sort the clients list descending by outstanding amount to keep active balances on top.

---

### 2026-07-28 · Riverpod 'ref' access in post-frame callbacks inside dispose

- **Context:** Resolving `StateError: Cannot use "ref" after the widget was disposed` on popping the New Client screen.
- **Mistake:** Accessing `ref.read` inside a `WidgetsBinding.instance.addPostFrameCallback` scheduled in the `dispose` method of a `ConsumerStatefulWidget`.
- **Root cause:** Post-frame callbacks execute after the current rendering frame completes. By that time, the widget has completed its unmount/disposal phase, making the element's `ref` invalid and raising a Riverpod disposal assertion.
- **Fix applied:** Captured the notifier reference synchronously (`final notifier = ref.read(...)`) *before* registering the callback in the `dispose` method of [new_client_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/new_client_screen.dart).
- **Rule for next agent:** NEVER access `ref` inside post-frame callbacks registered during a widget's unmount or disposal phase; always read and capture the notifier locally in `dispose` before scheduling the callback.

---

### 2026-07-28 · Scroll-to-hide FAB behavior with NotificationListener and AnimatedScale

- **Context:** Implementing dynamic scroll-to-hide behavior for Floating Action Buttons on lists/grids (Add Client, Add Product).
- **Mistake:** Using scroll controllers that require manual stateful initialization and disposal lifecycles, or using raw visibility changes without smooth scaling.
- **Root cause:** Floating action buttons are visually prominent and should shrink dynamically when scrolling down to maximize reading area, and scale back up when scrolling up.
- **Fix applied:** Wrapped scroll views in [clients_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/clients_screen.dart), [inventory_categories_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/inventory_categories_screen.dart), and [inventory_products_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/inventory_products_screen.dart) with a `NotificationListener<UserScrollNotification>` that toggles `_isFabVisible` depending on `ScrollDirection`. Wrapped the FABs in `IgnorePointer` and `AnimatedScale`. Added `package:flutter/rendering.dart` for `ScrollDirection` types.
- **Rule for next agent:** ALWAYS use NotificationListener<UserScrollNotification> wrapped in AnimatedScale and IgnorePointer to implement clean scroll-to-hide Floating Action Buttons without needing manual ScrollController management.

---

### 2026-07-28 · Custom Transaction Dates for Migration & Customer Created Date Derivation

- **Context:** Implementing historical record migrations via custom transaction dates in sales and collections, and deriving client created date from their oldest sale.
- **Mistake:** Assuming database creation dates (`created_at`) are the canonical reference point for older migrated customer records, or ignoring mock repositories when updating signatures.
- **Root cause:** Business records migrated from prior systems need exact transaction datetimes. Additionally, interface overrides (`CollectionRepository`, `SaleRepository`) must match exactly across all repositories including the mock repository.
- **Fix applied:** Added custom transaction date picker to `sale_screen.dart` and `collect_screen.dart`, forwarding custom dates to controllers and database insertions. Modified `MockRepository`, `LocalSaleRepository`, and `LocalCollectionRepository` signatures to accept optional `customDate`. Updated client created date calculations on the detail view to target the oldest `SaleActivity` in the history stream.
- **Rule for next agent:** ALWAYS ensure transaction date overrides are supported across all collection/sale database paths and mock classes, and derive client created date from the oldest sale activity in their timeline when available.

---

### 2026-07-28 · Make Date of Birth Optional in New Client Form

- **Context:** Making the Date of Birth optional on the New Client registration/edit form.
- **Mistake:** Forgetting to update validation logic in the controller alongside UI changes.
- **Root cause:** Validation constraints on fields must match both the UI formatting and the controller validators.
- **Fix applied:** Removed the `dob` emptiness validator block in [new_client_controller.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/new_client_controller.dart) and updated the text field label in [new_client_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/new_client_screen.dart) to remove the asterisk.
- **Rule for next agent:** ALWAYS align controller validations with UI optionality states when fields are changed between mandatory and optional.

---

### 2026-07-28 · Redesign Quick Action Row to Circle Icon Items

- **Context:** Redesigning the Quick Actions section on the dashboard to use lightweight circular icon buttons instead of large Card panels, and introducing an "Add Product" action.
- **Mistake:** Retaining large box elements or forgetting to clean up unused imports (such as `app_spacing.dart` when no longer using custom margins).
- **Root cause:** Card wrappers add visual weight; replacing them with transparent round items provides a native dashboard aesthetics.
- **Fix applied:** Overwrote [quick_actions_row.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/dashboard/widgets/quick_actions_row.dart) to define a grid of three custom circular icon items ("Collect Money", "New Client Sale", "Add Product"). Wired "Add Product" to trigger `showAddProductSheet(context)`. Cleaned up unused imports.
- **Rule for next agent:** ALWAYS implement quick actions as circular, containerless icon items with centeralized text labels, and remember to clean up unused imports to satisfy compiler checks.

---

### 2026-07-28 · Brand Field Dropdown with Add Brand Dialog

- **Context:** Redesigning the brand text entry field in Add and Edit product sheets to be a sorted dropdown list with an "Add brand..." dynamic dialog action.
- **Mistake:** Using the deprecated `value` parameter in `DropdownButtonFormField` instead of `initialValue` which causes analyzer deprecation warnings.
- **Root cause:** Modern versions of Flutter deprecate FormField-based `value` parameters in favor of `initialValue` for initial load and key-based `currentState.didChange` for controlled updates.
- **Fix applied:** Refactored brand fields in both `_AddProductSheetState` and `_EditProductSheetState` to use `DropdownButtonFormField` with `key` mapped to `_brandKey` and `initialValue` mapped to `_selectedBrand`. Programmatic updates after brand additions call `_brandKey.currentState?.didChange(newBrand)`.
- **Rule for next agent:** NEVER use the deprecated `value` parameter on modern FormFields like `DropdownButtonFormField`; ALWAYS use `initialValue` and control dynamic value changes programmatically using a `GlobalKey<FormFieldState>`.

---

### 2026-07-28 · Searchable Concise Brand Dialog Selection

- **Context:** Implementing a search bar for the brand list that is concise in size when adding or editing products.
- **Mistake:** Implementing search fields directly inside dropdowns which is non-standard in Flutter and can cause overflow bugs.
- **Root cause:** Standard Flutter DropdownButtons do not support embedded search text inputs cleanly. Replacing the dropdown with an InkWell wrapper that opens a constrained, searchable dialog list is highly clean and avoids rendering issues.
- **Fix applied:** Refactored brand inputs in `_AddProductSheetState` and `_EditProductSheetState` in [add_product_sheet.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/widgets/add_product_sheet.dart) to be standard TextFormFields wrapped inside tap InkWells. These tap fields open `_SearchableBrandDialog` (bounded at 350x320 px) showing a compact search input, matching brands list sorted A-Z, and dynamic brand adding logic.
- **Rule for next agent:** ALWAYS use a custom, constrained Dialog container with a search filter and ListView when implementing searchable selection list features to keep layouts clean and consistent.

---

### 2026-07-29 · Prevent Automatic Keyboard Invocation in Brand Dialog

- **Context:** Preventing keyboard invoke upon opening the brand search dialog.
- **Mistake:** Setting `autofocus: true` on the search TextField inside `_SearchableBrandDialogState` which automatically pops open the software keyboard immediately when the dialog opens.
- **Root cause:** Dialogs are expected to show the list of options first; automatically triggering focus on the search input disrupts the user flow by taking up half the screen with the keyboard.
- **Fix applied:** Changed `autofocus: true` to `autofocus: false` in [add_product_sheet.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/widgets/add_product_sheet.dart).
- **Rule for next agent:** NEVER set `autofocus: true` on search TextFields inside option selector dialogs/bottom sheets unless explicitly requested by the user, ensuring the keyboard doesn't cover option lists on load.

---

### 2026-07-29 · Inline Search Bar Filter replacing Sort Chip

- **Context:** Changing the products list sort chip filter into a search bar filter inside the horizontal filter chip list.
- **Mistake:** Retaining two search fields on the products screen or placing an unconstrained text input that causes line overflows inside the horizontal list view.
- **Root cause:** Double search bars are redundant and confuse the user layout; replacing the top category search bar and rendering a fixed-width (`width: 160`) inline search input instead of the `Sort: Newest` chip maintains structural consistency.
- **Fix applied:** Overwrote `_InventoryProductsScreenState` build and state parameters in [inventory_products_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/inventory_products_screen.dart) to dispose of `_sortType`, remove the top large search text box, and define a compact `TextField` inline next to the category filter chips. Added a clear suffix action icon to empty text quickly.
- **Rule for next agent:** ALWAYS remove redundant search inputs and use a defined-size constraints container (`SizedBox(width: ...)`) when placing text search fields inside horizontal scrolling layout rows.

---

### 2026-07-29 · reposition Search Inputs First in Horizontal Lists (Category + Product)

- **Context:** Placing search text inputs as the first item in categories and products horizontal scrolling filter bars.
- **Mistake:** Hardcoding class closures incorrectly during refactors, deleting state declaration signatures, or leaving search bars as the last item inside scrolling rows.
- **Root cause:** Search inputs should be immediately visible and scrollable along with filter chips; placing them first ensures optimal discoverability.
- **Fix applied:** Refactored [inventory_categories_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/inventory_categories_screen.dart) and [inventory_products_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/inventory_products_screen.dart) to remove top search text areas and define inline text fields as the first child of the horizontal scrollable lists.
- **Rule for next agent:** ALWAYS position inline search inputs as the first element in scrollable rows to follow mobile usability guidelines, and double check class wrapper structures after editing class fields.

---

### 2026-07-29 · Fixed Docked Search Bar with Scrollable Filter Chips

- **Context:** Placing search text inputs stationary (fixed) on the left while allowing filter chips to scroll on the right in Category and Product screens.
- **Mistake:** Rendering search inputs inside the scrolling ListView viewport directly, causing search inputs to scroll out of view when sliding the chips.
- **Root cause:** Search boxes should remain stationary at the start of filter groups for quick entry, while secondary filter tags slide horizontally.
- **Fix applied:** Refactored [inventory_categories_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/inventory_categories_screen.dart) and [inventory_products_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/inventory/inventory_products_screen.dart) to put a fixed-width `SizedBox(width: 140)` search TextField on the left and wrap filter chips on the right inside an `Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal))` layout.
- **Rule for next agent:** ALWAYS keep search inputs stationary on the left side and place scrollable filter chips inside an Expanded scroll container next to it.

### 2026-07-29 · Database Column serialization to CamelCase Models

- **Context:** Implementing remote repositories using `SupabaseClient` mapping table records to Freezed/JsonSerializable model structures.
- **Mistake:** Assuming database query maps (snake_case columns like `customer_code`, `category_id`) can be directly deserialized by `Model.fromJson(...)` when generated serialization code expects camelCase keys (`customerCode`, `categoryId`).
- **Root cause:** Dart's `@JsonSerializable()` default constructor setup without custom `@JsonKey` snake_case mapping configurations parses keys exactly matching camelCase properties.
- **Fix applied:** Manually mapped raw postgres snake_case columns to camelCase fields (e.g. `customerCode: map['customer_code']`) when passing query maps to `.fromJson()` constructors in [supabase_repositories.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/data/repositories/supabase_repositories.dart).
- **Rule for next agent:** ALWAYS transform database snake_case keys into camelCase keys before calling `.fromJson()` constructors on generated Freezed models unless explicit JSON key snake_case annotation mapping is verified in the model code.
- **Guardrail:** `flutter analyze` compiler error/warning output will detect type conflicts or missing fields, or runtime parsing exceptions.

### 2026-07-29 · Nested query builders inside PostgREST filter method

- **Context:** Querying collections with subquery logic on client locations in [supabase_repositories.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/data/repositories/supabase_repositories.dart).
- **Mistake:** Nesting a `PostgrestFilterBuilder` query client request inside `.filter('column', 'in', client.from(...).select())`, causing string parsing runtime exceptions (`PGRST100: failed to parse filter`).
- **Root cause:** The Dart PostgREST SDK converts nested objects to their string representation (`Instance of 'PostgrestFilterBuilder'`) instead of producing subquery string requests.
- **Fix applied:** Queried target entity IDs first, then filtered collections using `.inFilter('customer_id', idList)`.
- **Rule for next agent:** NEVER nest PostgREST builder requests inside filter parameters; retrieve list IDs beforehand and apply `.inFilter(...)` on the results.
- **Guardrail:** Validate query syntax runtime using test runs or checking for SQL parsing errors in the output logs.

### 2026-07-29 · Numeric and Null type casting from database responses

- **Context:** Deserializing database aggregates and nullable columns in [supabase_repositories.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/data/repositories/supabase_repositories.dart).
- **Mistake:** Direct casting of database results (e.g. `map['amount'] as int` or `res['total_financed'] as int`) where aggregation fields can evaluate to `null` or double/num type formats in Dart, triggering `Null is not a subtype of int` cast exceptions.
- **Root cause:** Sum and count aggregation results on database views are sometimes typed as numeric or double in Dart depending on postgrest versioning, and left join rows return null fields when missing child relations.
- **Fix applied:** Upgraded all numeric mapping casts to use `(value as num?)?.toInt() ?? 0` to safely handle `null`, `double`, `int`, or `num` formats.
- **Rule for next agent:** ALWAYS parse raw database query integers or sums using `(value as num?)?.toInt() ?? defaultValue` instead of direct `as int` casts.
- **Guardrail:** Validate model loading in screens using mock tables or empty databases to ensure fallback defaults function correctly on null rows.

### 2026-07-29 · Realtime logical replication on PostgreSQL database views

- **Context:** Listening to client outstanding changes via `watchCustomerOutstanding` in [supabase_repositories.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/data/repositories/supabase_repositories.dart).
- **Mistake:** Subscribing to logical replication updates on a view (`_client.from('customer_outstanding_view').stream(...)`), triggering a `RealtimeSubscribeException: Unable to subscribe to changes`.
- **Root cause:** PostgreSQL logical replication publications (which power Supabase Realtime) ONLY support physical tables, not database views.
- **Fix applied:** Refactored the stream to listen to changes on the underlying physical tables (`sales` and `collections`) using a custom `StreamController`, and trigger a reload of the calculated view values whenever an event occurs.
- **Rule for next agent:** NEVER subscribe to realtime streams on database views; instead, subscribe to the underlying physical tables and trigger a manual view reload in the stream callback.
- **Guardrail:** Verify all stream builders connect successfully without throwing RealtimeSubscribeException on startup.

### 2026-07-29 · Unsafe Riverpod ref.read calls inside widget dispose

- **Context:** Resetting customer creation form state when navigating back in [new_client_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/new_client_screen.dart).
- **Mistake:** Calling `ref.read` directly inside `dispose()` method, which throws `StateError: Cannot use "ref" after the widget was disposed` because the widget element tree is already deactivated/unmounted during finalization.
- **Root cause:** Flutter's unmounting cycle disposes elements, making Riverpod `ref` references inaccessible by the time `dispose()` is executed.
- **Fix applied:** Moved `ref.read(...).resetForm()` into the widget's `deactivate()` method, which runs while the element is still attached to the tree and readable.
- **Rule for next agent:** NEVER call `ref.read` or access Riverpod values inside `dispose()`; perform these actions in `deactivate()` or before popping the screen route.
- **Guardrail:** Confirm screen navigates and pops back cleanly without throwing StateError exceptions in the debug logs.

### 2026-07-29 · Modifying Riverpod providers during widget build / deactivate phase

- **Context:** Resetting customer creation form state during navigation unmounting in [new_client_screen.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/new_client_screen.dart).
- **Mistake:** Triggering provider state updates directly inside the `deactivate()` lifecycle method, which throws `Unhandled Exception: Tried to modify a provider while the widget tree was building`.
- **Root cause:** The `deactivate()` method is triggered during Flutter's element tree build/unmounting pass; modifying provider states during this phase breaks rendering consistency.
- **Fix applied:** Wrapped the `ref.read(...).resetForm()` update inside `WidgetsBinding.instance.addPostFrameCallback((_) {...})` to schedule the provider update after the layout frame finishes building.
- **Rule for next agent:** ALWAYS wrap provider modifications inside `WidgetsBinding.instance.addPostFrameCallback` when updating states from lifecycle hooks (like `initState`, `didUpdateWidget`, or `deactivate`).
- **Guardrail:** Check logs for "Tried to modify a provider while the widget tree was building" exceptions during screen transitions.

### 2026-07-29 · Location and ID Proof model deserialization key mismatches

- **Context:** Parsing customer location and identity documents inside `SupabaseCustomerRepository` in [supabase_repositories.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/data/repositories/supabase_repositories.dart).
- **Mistake:** Mapping location properties to JSON using `'latitude'` and `'longitude'` keys (which causes `Location.fromJson` to fail or load null because it expects `'lat'` and `'lng'`), and deserializing proof maps directly using `IdProof.fromJson` with `'imageUrl'` (which gets ignored as `IdProof` expects a nested `'document'` property).
- **Root cause:** Misalignment between database snake_case columns and the specific nested properties expected by custom model parsing configurations.
- **Fix applied:** Corrected location JSON keys to use `'lat'` and `'lng'`, and updated `getProofs` to instantiate the nested `IdProof` and `IdProofDocument` structures directly.
- **Rule for next agent:** ALWAYS check target model property constructors (like `Location` expecting `lat`/`lng` and `IdProof` expecting `document.localUri`) before mapping raw database rows.
- **Guardrail:** Confirm saved coordinates and identity document images render correctly on preview cards and detail screens.

### 2026-07-29 · Storage bucket RLS policies for anonymous uploads and database key mappings

- **Context:** Saving client avatars, identity proofs, and product photos to Supabase Storage in [supabase_repositories.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/data/repositories/supabase_repositories.dart).
- **Mistake:** Assuming public buckets automatically permit write operations, resulting in 403 Forbidden errors that silently fallback to saving local file paths. Also, incorrectly mapping customer profile images from the database using `map['proof_url']` (which doesn't exist) instead of `map['photo_url']` into the `proofUrl` model property.
- **Root cause:** Missing Row-Level Security (RLS) policies on the `storage.objects` table inside Supabase, and mapping keys which differed from database column definitions.
- **Fix applied:** Configured anonymous SELECT, INSERT, UPDATE, and DELETE RLS policies on the `storage.objects` table. Updated customer profile avatar mapping to use the correct `photo_url` database column name.
- **Rule for next agent:** ALWAYS ensure storage table permissions are enabled for the target roles, and double-check database columns (e.g. `photo_url` vs `proof_url`) before mapping.
- **Guardrail:** Confirm files are successfully uploaded and return public S3 URLs in the database after saving.

### 2026-07-29 · Hardcoding credentials in configuration files (leakage risk)

- **Context:** Managing credentials configuration in [supabase_config.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/core/config/supabase_config.dart).
- **Mistake:** Hardcoding the Supabase database connection URL and Anon API key inside a committed config file, risking credential leakage and unauthorized access when pushing to a public GitHub repository.
- **Root cause:** Storing development configuration strings directly in source files instead of utilizing dynamic environment parameters.
- **Fix applied:** Refactored `SupabaseConfig` to load values via `String.fromEnvironment` and created [README_ENV.md](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/README_ENV.md) instructing how to supply credentials during execution with `--dart-define`.
- **Rule for next agent:** NEVER commit live public database URL or API keys to the repository; always load them dynamically from the environment.
- **Guardrail:** Verify that `supabase_config.dart` contains no hardcoded credential strings before committing.

### 2026-07-29 · Hardcoded object path formatting constraints in S3 storage uploads

- **Context:** Storing product catalog images dynamically under structured folders in Supabase Storage inside [supabase_repositories.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/data/repositories/supabase_repositories.dart).
- **Mistake:** Uploading product images using the product ID as a flat folder path (e.g. `productId/photo.png`) instead of formatting the path structure hierarchically as `<category_name>/<product_name>.<extension>` inside the `product-photos` bucket.
- **Root cause:** Neglecting to map the `categoryId` to its corresponding name string when uploading, and failing to sanitize product and category name strings for spaces/URL encoding.
- **Fix applied:** Implemented a `_getCategoryName` lookup map in the repository and formatted the S3 path string using `<category_name>/<product_name>.<extension>` with spaces replaced by underscores for clean URL representation.
- **Rule for next agent:** ALWAYS structure S3 storage object keys hierarchically using logical domain names (e.g. category and product name folders) rather than raw internal database IDs where readable URLs are expected.
- **Guardrail:** Confirm that product S3 object URLs created in the database follow the `<category_name>/<product_name>.<extension>` format.

### 2026-07-29 · Database null constraints and clashing loop IDs during nominee insertions

- **Context:** Saving and updating customer nominee relationships in Supabase and local SQLite tables inside `supabase_repositories.dart` and `local_sqlite_repositories.dart`.
- **Mistake:** Assuming that nominee phone number and relation columns are nullable when they were defined as `NOT NULL` in the database, resulting in crashes for optional UI inputs. Additionally, using simple timestamp strings inside loops to generate unique IDs, which crashed with duplicate key violations because inserts run faster than a millisecond/microsecond tick.
- **Root cause:** Database table definition discrepancy with optional model parameters and generating identical timestamp-based IDs in execution loops.
- **Fix applied:** Dropped `NOT NULL` constraints in Supabase, introduced empty-string writes workarounds for SQLite, and updated the repository ID generation code to use the UI's existing unique nominee ID if present, fallback appending index/hashes.
- **Rule for next agent:** ALWAYS ensure that database columns align with optional model fields (nullable vs not null), and never generate loop IDs solely using microseconds epoch without unique offsets.
- **Guardrail:** Verify that customers with multiple nominees (having empty phone numbers or relation fields) save and retrieve cleanly without constraint crashes.

### 2026-07-29 · Type cast crashes during Customer.fromJson deserialization of nested Freezed collections

- **Context:** Deserializing nested lists of models (such as `idProofs` and `nominees`) when reading custom maps from the Supabase database inside [supabase_repositories.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/data/repositories/supabase_repositories.dart).
- **Mistake:** Passing lists of mapped objects like `proofs.map((p) => p.toJson()).toList()` inside the JSON map passed to `Customer.fromJson`. Because `json_serializable` does not automatically invoke `explicit_to_json` on child objects, the `document` property remained an instance of `_$IdProofDocumentImpl` inside the map, which crashed during casting to `Map<String, dynamic>`.
- **Root cause:** Implicit nested serialization layout limits of Dart's `json_serializable` generator when converting model instances back to map representations.
- **Fix applied:** Avoided converting objects to maps and back by refactoring the database fetch methods to instantiate the `Customer` class directly using its standard constructor.
- **Rule for next agent:** NEVER convert class model instances to JSON maps and decode them back to construct parent models; ALWAYS instantiate model classes directly using their standard constructors for better performance and type-safety.
- **Guardrail:** Confirm that the application dashboard and customer lists refresh and stream data without type cast exceptions.

### 2026-07-29 · Database migration and validation dependencies when making optional model parameters mandatory

- **Context:** Enforcing a required phone number for customer nominees across the database schema, Freezed models, mock data seeds, and UI sheets.
- **Mistake:** Assuming that we can directly alter a database column to `NOT NULL` without migrating existing rows containing null values, which failed with database transaction errors. Also, neglecting to update existing mock model constructor instances and UI text field validation.
- **Root cause:** Missing prerequisite migrations for existing database null values and missing validation state listeners for UI bottom sheets.
- **Fix applied:** Ran SQL query to populate a dummy phone number placeholder for existing null nominees, set the column constraint to `SET NOT NULL`, updated all mock constructor instances, and added text changed state listeners to require non-empty input before saving nominees.
- **Rule for next agent:** ALWAYS migrate existing database rows containing null/empty values before enforcing `NOT NULL` constraints, update mock seed models, and configure UI validators with proper change listeners.
- **Guardrail:** Confirm that adding a nominee without a phone number is disabled in the UI, and editing nominees behaves correctly.

### 2026-07-30 · Package visibility restrictions causing canLaunchUrl to fail on modern mobile OS versions

- **Context:** Launching document viewer URLs, maps, or calling phone numbers in [customer_context_card.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/customer_context_card.dart).
- **Mistake:** Using `canLaunchUrl(uri)` as a gatekeeper check before calling `launchUrl`. On Android 11+ and modern iOS versions, package visibility restrictions return `false` from `canLaunchUrl` unless schemes are explicitly queried in the native manifests, blocking the actual launching action.
- **Root cause:** Native security model updates for package visibility restrictions preventing query discovery from client applications.
- **Fix applied:** Bypassed `canLaunchUrl` checks completely by directly invoking `launchUrl` inside try-catch blocks.
- **Rule for next agent:** NEVER use `canLaunchUrl` to gate URL/URI launches unless manifest queries are actively configured; always invoke `launchUrl` directly wrapped in try-catch to let the OS handle application resolution.
- **Guardrail:** Verify that clicking ID proof document links, phone numbers, or map locations triggers external application launches without getting blocked.

### 2026-07-30 · Leaking public bucket object URLs during document opens

- **Context:** Opening remote ID proof documents from public Supabase buckets in [customer_context_card.dart](file:///C:/Users/LavanyanThandapani/Desktop/project-legacy/legacy-notebook/app/lib/features/customer/widgets/customer_context_card.dart).
- **Mistake:** Launching the remote URL directly in a web browser using `launchUrl`, which exposes the public S3 URL in history and third-party browsers.
- **Root cause:** Neglecting to download objects locally before opening, resulting in a potential security/confidentiality leak.
- **Fix applied:** Refactored the open handler to download remote files using `HttpClient` into a local temp directory, and then opened the local path using `OpenFilex` or local OS process commands.
- **Rule for next agent:** NEVER open remote public storage URLs of sensitive ID proofs in a browser; ALWAYS download them locally to a temporary secure path first, then open with native system application viewers.
- **Guardrail:** Verify that opening remote documents downloads the file silently and starts the local viewer application directly.

### 2026-07-30 · Unstructured and clashing filenames in client proof storage uploads

- **Context:** Storing and organizing customer identity documents inside Supabase Storage bucket paths in `supabase_repositories.dart`.
- **Mistake:** Naming customer proof files solely by their proof ID (e.g. `customerId/proof_id.png`) instead of using structural naming parameters that identify the customer and document type context. Also, failing to sanitize special characters or spaces in customer name/proof type fields.
- **Root cause:** Neglecting S3 folder organization constraints and ignoring name collision risks when uploading multiple documents of the same proof type for a single customer.
- **Fix applied:** Refactored remote S3 paths to place proofs under a client-specific folder named after the `client_id`, with filenames structured as `<client_name>_<proof_type>.<extension>` (replacing non-alphanumeric characters with underscores) to support type-based overwriting directly.
- **Rule for next agent:** ALWAYS name uploaded customer documents using a structured format containing the client's sanitized name and proof type under a customer-id directory context to enforce overwriting of existing document types.
- **Guardrail:** Confirm that files uploaded to the `customer-proofs` bucket follow the `client_id/client_name_proof_type.ext` path pattern.

### 2026-07-30 · Redundant sequence numbers and non-descriptive customer IDs

- **Context:** Modeling customer identification and ordering attributes in the database schema, models, and repositories.
- **Mistake:** Using random epoch timestamp IDs (`cust_1785...`) and non-descriptive customer codes (`LC-123456`), while maintaining a redundant `sequence_number` column for route sorting. Also, using primitive `INT` for collection monetary amounts instead of financial `NUMERIC(12,2)` / `double`.
- **Root cause:** Missing alignment with financial DBMS primary key standards and route location context.
- **Fix applied:** Replaced epoch customer IDs with sequential auto-incrementing integer IDs (`1, 2, 3...`), formatted `customer_code` as `<WEEK_ID>-<PLACE_ID>-<AREA_ID>-<PADDED_ID>` (e.g. `W4-P1-A1-001`), completely removed `sequence_number` (using `id ASC` for sequential visit order), updated collections schema to `NUMERIC(12,2)` / `double`, and re-indexed all seed data.
- **Rule for next agent:** NEVER generate arbitrary timestamp customer codes or maintain redundant sequence number columns; ALWAYS use auto-incrementing integer IDs, composite `W1-P2-A3-001` customer codes, and `id ASC` sorting.
- **Guardrail:** Confirm that new customers are assigned formatted codes like `W4-P1-A1-001` and sorted by sequential integer ID.

### 2026-07-30 · Silent action failures on "Create & Sale" and "Create Only" buttons

- **Context:** Submitting new client creation form in `new_client_screen.dart`.
- **Mistake:** Clicking "Create & Sale" or "Create Only" did not trigger navigation or show feedback when validation or database insertion returned `null`.
- **Root cause:** 
  1. `SupabaseCustomerRepository.addCustomer` used `.order('id', ascending: false)` on a `TEXT` primary key column, causing string-sorting mismatches that returned duplicate IDs and triggered database primary key collision exceptions.
  2. `new_client_screen.dart` returned silently on `customer == null` without displaying `state.errors` or a SnackBar explaining the failure.
- **Fix applied:** Refactored `addCustomer` in `SupabaseCustomerRepository` to select and parse all numeric customer IDs to accurately compute the next max integer ID. Updated `new_client_screen.dart` button handlers to display a destructive SnackBar with the exact validation/submission error whenever creation returns `null`.
- **Rule for next agent:** ALWAYS display error feedback SnackBars when form action callbacks return null, and ALWAYS parse integer IDs in memory when finding MAX(id) on TEXT columns in PostgreSQL.
- **Guardrail:** Verify that clicking "Create & Sale" or "Create Only" either succeeds with navigation or shows a descriptive red error SnackBar.

### 2026-07-30 · View column alias mismatch on `route_summary_view.customer_count`

- **Context:** Executing `DashboardController.refresh()` to fetch route summary counters from PostgreSQL view `route_summary_view`.
- **Mistake:** PostgreSQL view definition aliased `COUNT(DISTINCT c.id)` as `total_customers` instead of `customer_count`, causing `PostgrestException (42703)` when `SupabaseRouteRepository` queried `select('customer_count')`.
- **Root cause:** View column alias in SQL migration script did not match the expected `customer_count` property name in the Flutter repository interface.
- **Fix applied:** Re-created `route_summary_view` in Supabase and updated `001_schema_placeholder.sql` to explicitly alias `COUNT(DISTINCT c.id) AS customer_count`.
- **Rule for next agent:** ALWAYS verify SQL view column aliases match repository `.select('column_name')` fields exactly.
- **Guardrail:** Verify `DashboardController.refresh()` completes without PostgrestException 42703.

### 2026-07-30 · Customer ID format refactoring and JSON Document Model mapping

- **Context:** Storing and querying customer entities with nominees and ID proofs.
- **Mistake:** Relational sub-queries for `customer_nominees` and `customer_proofs` tables added extra SQL joins and write operations, complicating sync and local database migrations.
- **Root cause:** Relational modeling of dependent objects (nominees, proofs) created sync ordering complexities and overhead.
- **Fix applied:** Refactored database schemas to store nominees and ID proofs as nested JSONB arrays (`nominees` and `id_proofs`) directly in the `customers` table, dropping `customer_nominees` and `customer_proofs` tables. Refactored customer IDs from integers to zero-padded strings (`CU-001`, `CU-002`) and nominee/proof IDs to random UUIDs.
- **Rule for next agent:** ALWAYS store dependent customer nominees and ID proofs inside JSON columns on the `customers` record, and ALWAYS generate customer IDs in the `CU-001` format.
- **Guardrail:** Verify that nominees and ID proofs are retrieved and saved successfully from/to the embedded JSON fields of the customer record.

### 2026-07-30 · Replacing number key with proofUrl in customer ID proofs list

- **Context:** Storing and displaying ID proof document records inside customer details.
- **Mistake:** Used a redundant `number` text key to identify mock ID proofs, instead of referencing the document's remote S3 bucket file URL directly using `proof_url`.
- **Root cause:** Requirement update to store document URLs directly under a `proof_url` key in PostgreSQL JSON fields.
- **Fix applied:** Replaced `number` property in `IdProof` model with `proofUrl` mapping to `proof_url` in the database. Restored standard `fromJson` redirect factory to prevent build runner compilation crashes, and defined a custom static `fromJsonCustom` helper to dynamically hydrate UI `document` metadata objects in memory.
- **Rule for next agent:** ALWAYS store ID proof S3 paths/URLs under the key `proof_url` (mapped to property `proofUrl`) inside the customer `id_proofs` list.
- **Guardrail:** Verify that `IdProof` objects serialize `proof_url` as their primary S3 document path and compile/hydrate metadata cleanly.

### 2026-07-30 · Deleting redundant guardianName schema key and database column

- **Context:** Cleaning up unused properties from customer records.
- **Mistake:** Retained a redundant `guardian_name` database column and model field (`guardianName`) which was not utilized or rendered anywhere in the application.
- **Root cause:** Legacy schema configuration residue that was missed during database optimization sweeps.
- **Fix applied:** Completely removed `guardianName` from `Customer` model, mapping logic, mock data lists, and database creation queries. Dropped the `guardian_name` column from the remote PostgreSQL database and incremented local SQLite version to `6`.
- **Rule for next agent:** NEVER retain dead or unused schema fields (like `guardianName`) in models or tables when they are completely bypassed by business logic and presentation layers.
- **Guardrail:** Verify compilation runs cleanly and `guardianName` is not referenced anywhere in codebase maps or models.

### 2026-07-30 · PostgrestException PGRST204 due to deleted proof_url column and stale schema cache

- **Context:** Fetching or updating customer records from/to Supabase database.
- **Mistake:** Encountered PGRST204 because the root-level customer `proof_url` column (used to store profile/primary proof URLs) was mistakenly deleted from the `customers` database table, and PostgREST schema cache was stale.
- **Root cause:** The database column was dropped by accident during database alterations, and PostgREST cache wasn't notified.
- **Fix applied:** Added the `proof_url TEXT` column back to the `customers` table in Supabase and executed `NOTIFY pgrst, 'reload schema';` to refresh the PostgREST cache.
- **Rule for next agent:** ALWAYS notify PostgREST when altering database structures to prevent PGRST204 schema cache discrepancies.
- **Guardrail:** Verify that the `proof_url` column exists on the `customers` table and queries resolve without PGRST204.

### 2026-07-30 · Refactoring customer proof_url to profile_url and implementing interactive photo uploader

- **Context:** Implementing profile photo selection in new client registration and profile edit screen.
- **Mistake:** Retained a misleading field/column name `proof_url` representing the profile photo avatar, which clashed with ID proof documents, and lacked a dedicated interactive profile picture picker section.
- **Root cause:** Ambiguous naming convention and missing profile picture capture control in customer registration forms.
- **Fix applied:** Refactored all model, repository, database schema, and view references from `proof_url`/`proofUrl` to `profile_url`/`profileUrl`. Implemented an interactive `CircleAvatar` image upload field inside `_CustomerDetailsSection` that captures local gallery/camera paths using `ImagePicker` and synchronizes uploads to S3 bucket `customer-photos`.
- **Rule for next agent:** ALWAYS refer to the primary customer avatar image URL as `profile_url` / `profileUrl`, and use the interactive uploader on `new_client_screen.dart` to pick or remove profile pictures.
- **Guardrail:** Run `flutter analyze` and check that `profileUrl` maps cleanly to `profile_url` in both SQLite and Supabase serializers/repositories.

### 2026-07-30 · Non-lowercase S3 file paths / names

- **Context:** Storing uploaded profile images and ID proof documents on Supabase S3 bucket.
- **Mistake:** Constructed remote upload path strings using raw casing (which preserves uppercase customer IDs like `CU-001` or client names), violating the requirement for all-lowercase S3 file paths.
- **Root cause:** Forgot to convert filenames and parent folders to lowercase when assembling path strings.
- **Fix applied:** Appended `.toLowerCase()` to all generated S3 upload paths inside `supabase_repositories.dart` before calling `_uploadFile`.
- **Rule for next agent:** ALWAYS ensure all S3 upload path strings are converted to lowercase before performing uploads.
- **Guardrail:** Verify that `.toLowerCase()` is called on final constructed remote paths in `supabase_repositories.dart`.

### 2026-07-30 · Leaking unused S3 files when documents or photos are removed from UI

- **Context:** Updating customer records when an ID proof document or profile photo is deleted from the screen.
- **Mistake:** Left orphaned files in Supabase storage buckets (`customer-proofs`, `customer-photos`) when a user removed/deleted proofs or profile images in the UI form.
- **Root cause:** Only updated the table records to remove references, without calling storage delete operations.
- **Fix applied:** Implemented a comparison logic in `updateCustomer` inside `supabase_repositories.dart` which fetches the existing record and triggers `_deleteFile` to remove files from Supabase storage if they are no longer in the updated `idProofs` list or `profileUrl` field.
- **Rule for next agent:** ALWAYS delete removed local files from remote S3 storage buckets when a user clears or modifies proof documents/profile photos.
- **Guardrail:** Verify that the existing customer record is checked and any removed document URLs are cleaned up from Supabase storage during customer updates.

### 2026-08-03 · Centralized config table migration for places, areas, categories, and brands

- **Context:** Storing lookup configurations for places, areas, categories, and brands in a queryable JSON-based format.
- **Mistake:** Used separate relations (`places`, `areas`) and hardcoded mock files for product metadata, which made adding, updating, or deleting layout values complex and non-dynamic.
- **Root cause:** Standard relational lookup tables were used before consolidated configuration models were preferred.
- **Fix applied:** Created a single `config` table (`id TEXT PRIMARY KEY, data JSONB/TEXT`) in both local SQLite and remote PostgreSQL. Migrated separate relations to read and write dynamic lists (`places`, `areas`, `categories`, `brands`) from config, and converted the original tables to JSON-backed views in SQLite and Postgres so all other database queries remain untouched.
- **Rule for next agent:** ALWAYS retrieve places, areas, categories, and brands from the reactive config repository providers.
- **Guardrail:** Run `flutter analyze` and confirm `categoriesStreamProvider` and `brandsStreamProvider` compile cleanly without warning.

### 2026-08-03 · Enabling Supabase Realtime and RLS policies on newly created tables

- **Context:** Accessing lookup configs via Supabase streams and queries.
- **Mistake:** Forgot to add the newly created `config` table to the `supabase_realtime` publication, and did not add permissive RLS policies/grants, which caused configuration lookups to silently hang/return zero records.
- **Root cause:** Supabase tables do not enable Realtime or public access by default.
- **Fix applied:** Added the `config` table to the `supabase_realtime` publication, created a public permissive RLS policy, granted table access permissions, and reloaded the PostgREST cache.
- **Rule for next agent:** ALWAYS verify that newly created tables are added to the `supabase_realtime` publication and have appropriate RLS policies and role grants.
- **Guardrail:** Query `pg_publication_tables` and `pg_policies` when creating new Supabase tables.

### 2026-08-03 · JSON key mapping mismatch between Freezed models and config data

- **Context:** Fetching places and areas configurations in dashboard and route screens.
- **Mistake:** Triggered a `Null is not a subtype of String` type cast error during `Place.fromJson` and `Area.fromJson` calls.
- **Root cause:** The dynamic `config` data stored snake_case keys (`weekday_id` and `place_id`), while the Freezed generated models `Place.fromJson` and `Area.fromJson` expected camelCase keys (`weekdayId` and `placeId`).
- **Fix applied:** Added custom mappings in the local and remote config repositories to translate `weekday_id` to `weekdayId` and `place_id` to `placeId` during JSON deserialization, and vice versa on serializing.
- **Rule for next agent:** ALWAYS map snake_case attributes to camelCase properties before passing raw JSON from configuration table data to Freezed model `fromJson` factories.
- **Guardrail:** Verify that key case conversions are performed during both read and write configuration repository operations.

### 2026-08-03 · DropdownButtonFormField crash due to selected value missing in items list

- **Context:** Selecting places, areas, and categories inside form dropdowns.
- **Mistake:** Triggered a dropdown assertion failure (`items.where(...) == 1`) when a new lookup item (e.g. category `"1785739431861"`) was added but the reactive items list hadn't finished updating/loading.
- **Root cause:** `DropdownButtonFormField` will crash if the `initialValue` / `value` property is non-null but not present in the list of dropdown item values.
- **Fix applied:** Configured the dropdowns to set their `initialValue` property using a containment check (e.g. `initialValue: items.any(...) ? value : null`).
- **Rule for next agent:** ALWAYS wrap `DropdownButtonFormField` selected values in a containment check against the items list to prevent crash assertions during asynchronous list updates.
- **Guardrail:** Verify that dropdown values are validated against the dropdown items list before assigning them.

### 2026-08-03 · Swallowed exceptions in database write catch blocks

- **Context:** Saving places and areas configuration updates.
- **Mistake:** Catch-all blocks returned `null` silently, hiding underlying database write exceptions (such as RLS violations or parsing errors) and making debugging hard.
- **Root cause:** Swallowing exceptions without logging or rethrowing makes runtime errors invisible.
- **Fix applied:** Configured the `try-catch` blocks in `NewClientController` to log the caught exception and stack trace using `developer.log`.
- **Rule for next agent:** NEVER swallow exceptions silently in repository or controller catch blocks; always print or log them.
- **Guardrail:** Verify that all catch blocks in async database writers contain a logging or rethrow mechanism.

### 2026-08-03 · Non-incremental IDs for dynamic configurations

- **Context:** Generating IDs for dynamically added places and areas.
- **Mistake:** Used epoch timestamps (`plc_<timestamp>`, `area_<timestamp>`) instead of continuing the database's sequential/incremental ID patterns.
- **Root cause:** Missed the database convention of sequential numeric IDs (`p-<number>` and `a-<number>`).
- **Fix applied:** Implemented sequential ID calculators inside the local and remote config repositories to find the maximum existing sequence number and increment it.
- **Rule for next agent:** ALWAYS use incremental sequential ID formats (e.g. `p-<number>` and `a-<number>`) when adding dynamic places and areas.
- **Guardrail:** Verify that newly created places and areas parse the max ID from the current list and increment it.

---

### 2026-08-04 · Import paths in database helpers and UUID migrations

- **Context:** Implementing UUID data types for transactional tables (sales, collections, sale items, inventory transactions) and the products table, and refactoring ID generation.
- **Mistake:** Imported helper file `uuid.dart` using a single-dot parent relative path (`../core/utils/uuid.dart`) instead of double-dot parent relative path (`../../core/utils/uuid.dart`) in `database_helper.dart`.
- **Root cause:** Misestimated the folder depth of `lib/data/local/database_helper.dart` relative to `lib/core/utils/uuid.dart`.
- **Fix applied:** Corrected the import path to `../../core/utils/uuid.dart` and verified compilation with `flutter analyze`.
- **Rule for next agent:** ALWAYS verify import paths relative to project root folders when adding new utilities.
- **Guardrail:** Run `flutter analyze` immediately after resolving path additions to catch import resolution errors.

---

### 2026-08-06 · Uncanceled stream subscriptions in StateNotifiers

- **Context:** Resolving ANR crashes and freezing when navigating back during screen/state loading.
- **Mistake:** Subscribed to streams using `.listen` inside the controller notifier `build` method without registering cleanup callbacks on provider disposal.
- **Root cause:** Forgot that Dart stream subscriptions remain active and continue executing callbacks (which attempt to write state to the disposed notifier) unless explicitly cancelled.
- **Fix applied:** Registered cancel callbacks inside `ref.onDispose` for all active stream subscriptions, delayed stream listening until initial loads complete, and guarded callbacks with a `_isDisposed` flag.
- **Rule for next agent:** ALWAYS cancel stream subscriptions by registering `.cancel()` callbacks within `ref.onDispose`, defer listening until initial data is loaded, and guard state modifications with a disposed check flag in Riverpod notifier build methods.
- **Guardrail:** Look for any use of `.listen()` inside notifier or state class initialization, ensuring there is a corresponding `onDispose` or lifecycle cancel call.

---

### 2026-08-06 · Stale Supabase Realtime channels causing ANRs on navigation stress-test

- **Context:** Resolving ANR freezes when rapidly opening and closing screens that watch Supabase Realtime channels.
- **Mistake:** Unsubscribed the channel inside `StreamController.onCancel` but did not remove the channel from the Supabase client list.
- **Root cause:** Unsubscribing a channel changes its status, but the channel instance remains registered and cached inside the Supabase client. Creating new duplicate channel objects and calling `.subscribe()` multiple times on the same connection leads to thread locking and ANR freezes.
- **Fix applied:** Added `await _client.removeChannel(channel)` inside `onCancel` and appended `DateTime.now().microsecondsSinceEpoch` to channel names in `supabase_repositories.dart` to make each subscription instance unique.
- **Rule for next agent:** ALWAYS make Supabase Realtime channel names instance-unique using a timestamp/UUID and call both `channel.unsubscribe()` and `client.removeChannel(channel)` during teardown to avoid resource cache conflicts.
- **Guardrail:** Grep search for `.channel(` in repositories and ensure they use dynamic instance-unique names.

---

### 2026-08-06 · Embedded native GoogleMap platform view causing Android GL unbinding ANRs

- **Context:** Resolving main-thread ANR freezes when rapidly opening and popping the Client Details screen from Transactions.
- **Mistake:** Embedded a native `GoogleMap` platform view inside a scrollable card (`CustomerContextCard`) with gestures disabled.
- **Root cause:** Creating and destroying native Android `MapView` platform views rapidly during page transitions causes GLSurfaceView/OpenGL texture context unbinding deadlocks on the main thread (blocking Android's `CameraXLibraryPigeonInstanceManager` and native message handlers).
- **Fix applied:** Replaced the embedded native `GoogleMap` widget in `CustomerContextCard` with a pure Flutter location card containing a map pin and an interactive "Tap to Open in Maps" action that launches external maps via `launchUrl`.
- **Rule for next agent:** NEVER embed live native `GoogleMap` platform views inside scrollable list items or cards unless explicitly necessary; use pure Flutter static card previews with external map launcher actions instead.
- **Guardrail:** Grep for `GoogleMap(` inside card or list item widgets.

---

### 2026-08-07 · Cumulative Realtime stream/channel leak in AutoDispose notifier causing ANR on Nth navigation

- **Context:** Resolving ANR crash on the Nth visit (first 1st, then 3rd, then 5th) to Customer Detail screen from Transactions.
- **Mistake:** `CustomerDetailNotifier` created 3 stream subscriptions (watchCustomerById, watchCustomerOutstanding, watchCustomerTimeline) and registered `ref.onDispose(() { sub.cancel(); })` to clean them up.
- **Root cause:** `ref.onDispose` is a **synchronous** callback. `StreamSubscription.cancel()` returns a `Future<void>` that is never awaited inside a sync callback. The `controller.onCancel` in the Supabase repo does `await channel.unsubscribe()` + `await _client.removeChannel(channel)` — all of which run as untracked fire-and-forget microtasks. Each navigation leaves ~3 dangling async teardowns in-flight. By the 5th visit, ~15 competing WebSocket teardown tasks on the platform channel starve Android's main thread → ANR.
- **Fix applied:** Removed ALL stream subscriptions from `CustomerDetailNotifier`. Converted to a pure `Future.wait([getCustomerById, getCustomerOutstanding, getCustomerTimeline])` parallel fetch with no channels, no subscriptions, and no cleanup. Riverpod `AutoDispose` guarantees `build()` re-runs with fresh data on every re-navigation.
- **Rule for next agent:** NEVER use stream subscriptions inside `AutoDispose` notifiers with async cleanup unless you can guarantee the cleanup is awaited. If a screen shows data that is refreshed on every navigation, use a one-shot `Future.wait` parallel fetch instead of streams — zero channels, zero accumulation.
- **Guardrail:** Any `ref.onDispose` that calls `.cancel()` without `await` is a leak. Grep for `onDispose` blocks containing `.cancel()` and verify the stream's `onCancel` does no async work, or switch to Future-based fetching.

---

### 2026-08-07 · CameraX native background listener & non-autoDispose StreamProvider.family leaks

- **Context:** Resolving ANR crashes on 5th/6th attempt back gesture from Customer Detail to Transactions.
- **Mistake:** (1) `camera` package dependency was included, registering Android's native `CameraXLibraryPigeonInstanceManager` at app startup, which ran background Pigeon native message handler callbacks on Android's UI thread Handler even when no camera view was open. (2) `customerOutstandingProvider` in `providers.dart` was declared as `StreamProvider.family` without `autoDispose`, creating permanent Supabase Realtime WebSocket channels that never unmounted across customer visits.
- **Root cause:** Native `CameraX` plugin background callbacks ran continuously on Android's main Handler thread. When combined with non-autoDisposed Realtime channels and navigation transitions, the main thread Handler message queue hit 20s timeouts (`CameraXLibraryPigeonInstanceManager$$ExternalSyntheticLambda0`).
- **Fix applied:** (1) Removed `camera` package and `camera_android_camerax` plugin dependency entirely, replacing photo capture fallback with standard `image_picker` (`ImageSource.camera`). (2) Added `.autoDispose` to `customerOutstandingProvider` in `providers.dart`.
- **Rule for next agent:** NEVER include the `camera` package if `image_picker` is sufficient for photo capturing; `camera_android_camerax` registers background main thread Pigeon callbacks. ALWAYS add `.autoDispose` to `StreamProvider.family` declarations.
- **Guardrail:** Check `pubspec.yaml` for `camera` dependency and verify all `StreamProvider.family` definitions use `autoDispose`.

---

### 2026-08-07 · Android 13+ Predictive Back Choreographer$FrameHandler deadlock in PopScope

- **Context:** Resolving ANR crash (`target=android.view.Choreographer$FrameHandler`) on hardware back press when popping screens.
- **Mistake:** (1) `android:enableOnBackInvokedCallback="true"` was missing from `<application>` in `AndroidManifest.xml`, causing Android 13+ (MIUI) `ViewRootImpl` to warn and lock waiting for back invocation callbacks. (2) `PopScope` in `navigation_shell.dart` called `context.go(backTarget)` synchronously inside `onPopInvokedWithResult`, dismantling and swapping the route tree during active frame gesture evaluation.
- **Root cause:** Swapping the entire GoRouter location tree synchronously inside the back invocation callback while Android's `Choreographer` engine was rendering the back animation created a native thread deadlock waiting for frame completion.
- **Fix applied:** (1) Added `android:enableOnBackInvokedCallback="true"` to `AndroidManifest.xml`. (2) Deferred `context.go(backTarget)` inside `PopScope` using `WidgetsBinding.instance.addPostFrameCallback((_) { ... })`.
- **Rule for next agent:** ALWAYS wrap `context.go()` calls inside `PopScope.onPopInvokedWithResult` in `WidgetsBinding.instance.addPostFrameCallback` so route tree mutations happen on the next frame after back gesture evaluation completes. ALWAYS declare `android:enableOnBackInvokedCallback="false"` in `AndroidManifest.xml` to avoid system predictive back gesture dispatcher freezes.
- **Guardrail:** Grep `onPopInvokedWithResult` for synchronous `context.go()` calls and verify `enableOnBackInvokedCallback="false"` exists in `AndroidManifest.xml`.

---

### 2026-08-10 · Android 13+ Predictive Back Callback deadlock on MIUI/Xiaomi

- **Context:** Resolving ANR crash (`android.window.WindowOnBackInvokedDispatcher$OnBackInvokedCallbackWrapper`) on back gesture swiping.
- **Mistake:** Declared `android:enableOnBackInvokedCallback="true"` in the application manifest.
- **Root cause:** On MIUI (Xiaomi) devices with system gesture navigation active, enabling predictive back causes the system's custom gesture dispatcher to deadlock when interacting with Flutter's dynamic asynchronous `PopScope` handlers. The system thread hangs waiting for synchronous callback resolution.
- **Fix applied:** Set `android:enableOnBackInvokedCallback="false"` in `AndroidManifest.xml` to fallback to legacy back key dispatching (`onBackPressed`), which works flawlessly with asynchronous pops/PopScopes.
- **Rule for next agent:** NEVER enable `android:enableOnBackInvokedCallback="true"` on Android builds targeting custom operating systems like MIUI/Xiaomi unless you are not using any async PopScope interceptors. Keep it `false`.
- **Guardrail:** Verify `android:enableOnBackInvokedCallback="false"` in `AndroidManifest.xml`.


---

### 2026-08-10 · Dashboard N+1 per-customer query loops causing ANRs on load

- **Context:** Resolving ANR crashes when loading or refreshing `DashboardScreen`.
- **Mistake:** `DashboardController.refresh()` iterated through every single customer in the database and launched `getCustomerOutstanding`, `getCustomerTimeline`, and `getCollectionsForCustomerToday` individually in `Future.wait` (issuing 250+ parallel HTTP requests on startup).
- **Root cause:** Bombarding Supabase REST with 200+ concurrent network queries saturated Dart's event loop and main thread socket pool, triggering Android 20-second ANR timeouts.
- **Fix applied:** Refactored `DashboardController.refresh()` in `dashboard_controller.dart` to fetch bulk datasets in 4 concurrent batch requests (`getPlacesByWeekday`, `getAllCustomers`, `getAllSales`, `getAllCollections`), and compute all totals, pending visits, and recent activities in-memory.
- **Rule for next agent:** NEVER map over a list of entities to issue individual network queries in controllers or repositories; ALWAYS fetch bulk table datasets in 1 query and compute metrics/aggregations in-memory.
- **Guardrail:** Audit `.map((c) => repo.get...` loops inside `Future.wait`.

---

### 2026-08-10 · Synchronous context.go pop exception deadlock during skeleton loading

- **Context:** Resolving ANR/crashes when pressing the AppBar back button during the skeleton loading state of `CustomerDetailScreen`.
- **Mistake:** The skeleton loading view used a custom `Scaffold` with an AppBar back button that called `context.pop()`.
- **Root cause:** Because `CustomerDetailScreen` is a child route within a `ShellRoute`, `context.pop()` throws a GoRouter exception if the nested navigator stack has no previous page. Running `context.go()` synchronously inside the `catch` block on the same frame corrupted GoRouter's internal state machine, causing a platform channel deadlock.
- **Fix applied:** Replaced raw `Scaffold` loading/error states in `customer_detail_screen.dart` with `AppScaffold`, which automatically delegates to safe, frame-deferred `getBackTarget()` navigation transitions.
- **Rule for next agent:** ALWAYS use the unified `AppScaffold` widget for skeleton loading and error states instead of custom raw `Scaffold`s to ensure consistent navigation and back-behavior.
- **Guardrail:** Check `loading` and `error` parameters in `AsyncValue.when` handlers to ensure they return `AppScaffold`.

---

### 2026-08-10 · Stale provider data when returning from pushed child screens

- **Context:** Customer details screen outstanding, timeline, and profile were not auto-refreshing after completing a new sale, collection, or editing customer details.
- **Mistake:** Navigated to child modal routes using `context.push` without invalidating `customerDetailControllerProvider` and `dashboardControllerProvider` in controller save methods or on push completion.
- **Root cause:** Because `CustomerDetailScreen` remains mounted underneath the pushed route, `AutoDispose` does not trigger a teardown or re-run `build()`.
- **Fix applied:** (1) Added `_ref.invalidate(customerDetailControllerProvider(id))` and `_ref.invalidate(dashboardControllerProvider)` to `saveSale()`, `saveCollection()`, and `updateCustomer()`. (2) Awaited `context.push(...)` in `customer_detail_screen.dart` and `customer_context_card.dart`, calling `ref.invalidate(...)` on return.
- **Rule for next agent:** ALWAYS invalidate parent controller providers upon completing write operations and upon returning from `await context.push(...)`.
- **Guardrail:** Verify `ref.invalidate` calls after `context.push` in detail screens.

---

### 2026-08-10 · ListWheelScrollView build-time setState and VerticalDivider unbounded height in Row

- **Context:** Implementing 3-column scroll-wheel filters for Route Filter in `clients_screen.dart`.
- **Mistake:** (1) `ListWheelScrollView.onSelectedItemChanged` invoked `setState` synchronously during initial layout/build. (2) `VerticalDivider` inside a `Row` without `IntrinsicHeight` caused an unbounded height expansion resulting in `A RenderFlex overflowed by 99341 pixels on the bottom`.
- **Root cause:** `VerticalDivider` attempts to expand to max vertical constraints of the parent `Row`. If the parent `Row` is not wrapped in `IntrinsicHeight` or given fixed bounds, height becomes infinite. Additionally, `ListWheelScrollView` fires initial item position changes during build, throwing `setState() or markNeedsBuild() called during build`.
- **Fix applied:** (1) Wrapped `Row` in `IntrinsicHeight` and used fixed-width `Container(width: 1)` divider lines. (2) Tracked `_lastReportedIndex` and deferred `onSelectedIndexChanged` calls via `WidgetsBinding.instance.addPostFrameCallback`.
- **Rule for next agent:** ALWAYS wrap `Row`s containing `VerticalDivider` in `IntrinsicHeight` or use fixed `Container(width: 1)` lines, and ALWAYS defer `ListWheelScrollView.onSelectedItemChanged` state updates to `addPostFrameCallback`.
- **Guardrail:** Never call `setState` directly inside `ListWheelScrollView.onSelectedItemChanged` without post-frame callback protection.

---

### 2026-08-10 · RenderPhysicalShape hasSize assertion with InkWell during bottom sheet animations

- **Context:** Embedding custom calendar date range picker inside modal bottom sheet (`_showFiltersSheet`).
- **Mistake:** Used bare `InkWell`s on multiple calendar grid and list cells inside a modal bottom sheet without immediate `Material` parent widgets and used `Container(height: double.infinity)` inside `Row`.
- **Root cause:** `InkWell` requires a `Material` widget to host its ink splash. When placed inside a modal bottom sheet without a local `Material`, `InkWell` references the root modal `Material` (`RenderPhysicalShape`). During the entry slide animation, child layout queries `RenderPhysicalShape.size` before the modal animation frame finishes layout, throwing `RenderBox was not laid out: RenderPhysicalShape#... Failed assertion: hasSize`.
- **Fix applied:** Replaced `InkWell`s in calendar grid and month selector with `GestureDetector(behavior: HitTestBehavior.opaque)` and set explicit bounded constraints (`crossAxisAlignment: CrossAxisAlignment.stretch` with defined child heights).
- **Rule for next agent:** NEVER use bare `InkWell` inside modal sheets without local `Material` parents; use `GestureDetector(behavior: HitTestBehavior.opaque)` for custom cell components.
- **Guardrail:** Grep for `InkWell` without `Material` in modal bottom sheets.

---

### 2026-08-10 · BoxConstraints forces an infinite width on unexpanded Button in Row

- **Context:** Action buttons (Cancel & Apply Filters) in `_showFiltersSheet` within `transactions_screen.dart`.
- **Mistake:** Placed an unexpanded `OutlinedButton` next to an `Expanded(child: FilledButton)` inside a `Row` under a stretched `Column` in a bottom sheet.
- **Root cause:** In stretched flex containers inside scrollable sheets, `OutlinedButton` calculates width with unbounded horizontal/vertical constraints (`BoxConstraints(w=Infinity, 56.0<=h<=Infinity)`), causing `RenderConstrainedBox.performLayout` to throw `BoxConstraints forces an infinite width. Failed assertion: hasSize`.
- **Fix applied:** Wrapped both buttons in `Expanded` (e.g. `flex: 1` for `OutlinedButton`, `flex: 2` for `FilledButton`) inside the `Row` to ensure exact, bounded constraint distribution.
- **Rule for next agent:** ALWAYS wrap all button siblings in `Expanded` when placing buttons side-by-side in a `Row` inside stretched bottom sheets or dialogs.
- **Guardrail:** Ensure buttons in bottom action rows have bounded width or are wrapped in `Expanded`.

---

### 2026-08-11 · SocketException on Supabase config stream without offline fallback

- **Context:** Fetching places, areas, categories, brands, or proof types when offline or when host lookup fails (`SocketException: Failed host lookup: 'sssrdqyhhqorltejqqeo.supabase.co'`).
- **Mistake:** `SupabaseConfigRepository` streamed directly from `_client.from('config').stream(...)` with no `handleError` / `onError` callback and without local SQLite fallback.
- **Root cause:** When device is offline or network is disconnected, Supabase Realtime streams immediately emit a `SocketException` into the StreamProvider. Furthermore, `_readData` returned `'[]'` on error rather than reading from the persistent local SQLite cache.
- **Fix applied:** Integrated `LocalSqliteConfigRepository` and `LocalSqliteRouteRepository` directly into `SupabaseConfigRepository` and `SupabaseRouteRepository`. The repositories immediately emit local SQLite cached streams, background-sync from Supabase Realtime with `onError` guarded, and fallback seamlessly when offline per offline-first principles.
- **Rule for next agent:** ALWAYS back Supabase stream queries with local SQLite streams and `onError` handlers so offline devices never throw unhandled `SocketException`s or lose cached data.
- **Guardrail:** Verify that all Supabase repositories provide offline-first local SQLite fallback and stream error suppression.









