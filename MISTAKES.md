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









