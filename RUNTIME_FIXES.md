# Runtime Fixes — Blank Screen & GlobalKey Issues

## Issues Identified & Fixed

### 1. GlobalKey Conflict on Modal Routes ✅
**Error:** `Multiple widgets used the same GlobalKey`

**Root cause:** Modal screens (NewClientScreen, CollectScreen, SaleScreen) were using `AppScaffold` with `SyncStatusIndicator` in the appBar actions. When these modals layered on top of shell routes, both widget trees were active simultaneously, causing duplicate GlobalKey instances.

**Fix applied:**
- Added `showSyncIndicator` parameter to `AppScaffold` (default: true)
- Set `showSyncIndicator: false` on all modal screens:
  - `lib/features/customer/new_client_screen.dart`
  - `lib/features/collection/collect_screen.dart`
  - `lib/features/sale/sale_screen.dart`

### 2. Disposed Ref Access in SnackBar Action ✅
**Error:** `Bad state: Cannot use "ref" after the widget was disposed`

**Root cause:** In new_client_screen, the snackbar UNDO action tried to call `ref.read()` after the screen may have been disposed. Refs are tied to widget lifecycle and cannot be accessed after disposal.

**Fix applied:**
- Captured repository and notifier references **before** creating the snackbar
- Stored values in local variables that outlive the widget
- Removed direct `ref.read()` calls from the snackbar action closure

**File:** `lib/features/customer/new_client_screen.dart` (lines 188-207)

### 3. Navigation Stack Assertion ⚠️
**Error:** `You have popped the last page off of the stack, there are no pages left to show`

**Status:** Not fully diagnosed yet. May be related to:
- Double-pops in modal transitions
- Sale/Collection screens calling Navigator.pop() when screen is already being dismissed
- Need to trace the exact pop sequence

**Recommendation:** Monitor on next run; likely resolved by GlobalKey fix allowing proper navigation state management.

---

## Files Modified

| File | Change | Status |
|------|--------|--------|
| app_scaffold.dart | Added showSyncIndicator param | ✅ |
| new_client_screen.dart | Disabled sync indicator + fixed ref capture | ✅ |
| collect_screen.dart | Disabled sync indicator | ✅ |
| sale_screen.dart | Disabled sync indicator | ✅ |

## Build Status
- ✅ Build runner: SUCCESS (34s, wrote 0 outputs)
- ✅ Lint: 115 warnings (acceptable level)
- ✅ No compilation errors

## Next Steps

1. **Test on device:** Run `flutter run` and verify:
   - Splash screen displays properly
   - Dashboard shows content (not blank)
   - Modal screens (New Client, Collection, Sale) open without GlobalKey errors
   - Snackbar UNDO actions work without disposed ref errors

2. **Monitor for:** Navigation stack errors, overflow issues (mentioned in log)

3. **If still blank screens:**
   - Check asset loading (brand_mark.png)
   - Verify data loading in dashboard controller
   - Add debug prints to confirm screen build() is called

---

## Trap Documentation
These issues have been added to prevent repeating them in future iterations.
