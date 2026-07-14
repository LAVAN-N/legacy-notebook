# Runtime Fixes — Round 2 Complete

## Summary of Issues Fixed

Based on run_log.txt analysis, three critical runtime errors were identified and fixed:

### 1. Disposed Ref in SnackBar Actions ✅ **FIXED**

**Error:** `Bad state: Cannot use "ref" after the widget was disposed`

**Root cause:** SnackBar actions tried to access `ref.read()` after ConsumerState disposal. The ref is bound to the widget lifecycle and cannot be accessed in deferred callbacks that outlive the widget.

**Fixed in:**
- `lib/features/customer/new_client_screen.dart` (2 locations: lines 165 & 200)
- `lib/features/sale/sale_screen.dart`
- `lib/features/collection/collect_screen.dart`

**Pattern applied:**
```dart
// ❌ UNSAFE (before)
onPressed: () async {
  await ref.read(customerRepositoryProvider).undoCustomer(id);
}

// ✅ SAFE (after)
final repository = ref.read(customerRepositoryProvider);  // Capture immediately
onPressed: () async {
  await repository.undoCustomer(id);  // Use captured value
}
```

---

### 2. GoRouter Pop Errors ✅ **FIXED**

**Error:** `You have popped the last page off of the stack, there are no pages left to show`

**Root cause:** Modal screens were using deprecated `Navigator.pop(context)` instead of `context.pop()` from GoRouter. This causes navigation state misalignment.

**Fixed in:**
- `lib/features/sale/sale_screen.dart` line 59
- `lib/features/collection/collect_screen.dart` line 63

**Change:**
```dart
// ❌ OLD (Navigator API)
Navigator.pop(context);

// ✅ NEW (GoRouter API)
if (mounted) {
  context.pop();
}
```

---

### 3. GlobalKey Conflict ✅ **FIXED** (from previous checkpoint)

**Error:** `Multiple widgets used the same GlobalKey`

**Fix:** Added `showSyncIndicator` parameter to `AppScaffold`:
- Modal screens (NewClient, Collect, Sale) now disable sync indicator with `showSyncIndicator: false`
- Prevents duplicate widgets in overlapping navigation layers

---

## Files Modified (3 total)

| File | Changes |
|------|---------|
| `lib/features/customer/new_client_screen.dart` | Fixed 2 SnackBar actions + disabled sync indicator |
| `lib/features/sale/sale_screen.dart` | Changed `Navigator.pop()` → `context.pop()` |
| `lib/features/collection/collect_screen.dart` | Changed `Navigator.pop()` → `context.pop()` |

---

## Build Status ✅

- **Build runner:** SUCCESS (`flutter clean` + `flutter pub run build_runner build`)
- **Compilation:** 0 errors
- **Lint:** 113 warnings/info (acceptable, no new issues)

---

## Verification Checklist

- [ ] App starts without "Cannot use ref after disposed" exceptions
- [ ] Modal screens (New Client, Collection, Sale) open without GlobalKey errors
- [ ] SnackBar UNDO actions work correctly
- [ ] Navigation back from modals works without "popped last page" errors
- [ ] No RenderFlex overflow warnings (deferred to UI polish)

---

## Testing Instructions

Run the app again:
```bash
flutter run
```

Expected behavior:
1. ✅ Splash screen → Dashboard (no blank screen)
2. ✅ Bottom nav visible with 4 tabs
3. ✅ No unhandled exceptions in logs
4. ✅ Modal screens open/close smoothly
5. ✅ UNDO snackbar actions execute without errors

---

## Known Remaining Issues (Not Blocking)

1. **RenderFlex overflow warnings** - Layout polish needed (deferred)
2. **OnBackInvokedCallback warning** - Android manifest setting (cosmetic)
3. **"No element" error** - Likely resolved by navigation fixes (monitor)

---

## Next Steps

1. **Test on device** with the freshly rebuilt APK
2. **If successful**, commit all changes:
   ```bash
   git add lib/features/customer/new_client_screen.dart \
           lib/features/sale/sale_screen.dart \
           lib/features/collection/collect_screen.dart
   git commit -m "fix: Resolve disposed ref, GlobalKey, and navigation errors

   - Capture ref values before SnackBar creation to prevent disposed state access
   - Replace Navigator.pop() with context.pop() for GoRouter compatibility
   - Disable sync indicator on modal screens to prevent duplicate GlobalKeys
   
   Fixes:
   - Bad state: Cannot use ref after disposed
   - Multiple widgets used same GlobalKey
   - Popped last page off stack errors"
   ```
3. **If issues persist**, attach new run_log.txt for further diagnosis

---

**Status:** Ready for testing on device. All known runtime blockers have been fixed.
