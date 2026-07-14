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

