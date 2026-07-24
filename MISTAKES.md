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









