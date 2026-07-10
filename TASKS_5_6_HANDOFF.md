# Phase 1 Handoff - Tasks 5-6: Dashboard Screen Implementation

## Overview

Tasks 1-4 (Foundation) are **COMPLETE** with **zero compilation errors**. The application is now ready for visible UI implementation starting with the Dashboard screen.

## Current State

- ✅ All design system widgets created and tested
- ✅ Mock data infrastructure fully functional (15+ Riverpod providers)
- ✅ Navigation plumbing in place (GoRouter + navigationPathProvider)
- ✅ 6 placeholder screens scaffolded
- ✅ Material 3 theming configured
- ✅ All imports using package paths (no relative imports)

**Compilation**: `flutter analyze` returns 0 issues

---

## Tasks 5-6: Dashboard Screen Implementation

### What Needs to Be Built

The Dashboard is the entry point after login. It displays:

1. **App Bar** (64dp height)
   - Brand mark / logo (small, left)
   - Greeting: "Good morning, {First Name}" (time-aware)
   - Today's date: "Thursday, 09 Jul"
   - Notification bell with badge ("3+")
   - Profile avatar (initials or photo)

2. **Today's Route Card** (Hero card - primary emphasis)
   - Label: "Today's Route"
   - Weekday name: "Thursday" (display-small, 36sp)
   - Route summary: "3 Places · 5 Areas · 42 Customers"
   - Expected collection: "₹ 24,500 expected today" (headline-large, bold)
   - Progress bar: "₹ 8,200 collected · 34%"
   - Pending visits: "28 pending visits"
   - CTA button: "Start Collecting" (full width, filled primary)

3. **Weekly Route Strip** (Horizontal scroll)
   - 7 weekday chips (Sun-Sat)
   - Today's chip: filled primary background
   - Each chip: "Thu · 42" (weekday short + count)
   - Tappable: navigate to that weekday's Weekday screen

4. **Quick Actions Row** (2-4 tiles, 88×88dp minimum)
   - Collect Payment → today's Weekday screen
   - New Sale → Customer Search screen
   - Find Customer → Customer Search screen
   - Inventory (Owner only, show for now) → placeholder

5. **Business Summary Grid** (2 columns, 2 rows)
   - Today's Collection: ₹ amount
   - Today's Sales: ₹ amount
   - Total Outstanding: ₹ amount (tap → filtered customer list)
   - Customers Visited: count / total

6. **Recent Activity** (Last 5 activities)
   - Section header: "Recent Activity" + "See all" link
   - Each row: avatar + customer name + activity type chip + amount + time ago
   - Tap row → Customer Details for that customer

### Data Integration

All data providers are ready in `lib/shared/providers/mock_providers.dart`:

```dart
// Use these providers in the Dashboard screen:
mockUserProvider                    // Current user
mockWeekdaysProvider                // All 7 weekdays
mockPlacesByWeekdayProvider('weekday_4')  // Today's places
todaysSummaryProvider               // Today's expected/collected
recentActivitiesProvider            // Last 5 activities
```

### State Management

Dashboard should support:

1. **Loading State**
   - Skeleton shimmer for hero card, chips, summary grid, activity rows
   - Min shimmer duration: 1.5s

2. **Empty State** (no route today)
   - Replace hero card with: "No route today" + illustration
   - Weekly strip still shown
   - Quick actions shown

3. **Error State** (load failed)
   - Centered error illustration + message + retry button
   - Never show blank screen

4. **Populated State** (normal display)
   - All sections visible with real data
   - Pull-to-refresh indicator

### Interactions

- **Start Collecting button**: Navigate to Weekday screen for today
- **Weekday chip tap**: Navigate to Weekday screen for that day
- **Quick action taps**: Navigate to appropriate screens
- **Summary card tap**: Navigate to filtered customer list (if applicable)
- **Activity row tap**: Navigate to Customer Details
- **Pull-to-refresh**: Show 400ms min spinner, then dismiss

### Implementation Hints

1. **Use ConsumerWidget or ConsumerStatefulWidget** to access Riverpod providers
2. **Wrap in FutureBuilder or AsyncValue.when()** for loading/error/data states
3. **Keep the scrollable area unified** - use SingleChildScrollView with all sections
4. **Use RefreshIndicator** for pull-to-refresh (callback does nothing for mock, just shows spinner)
5. **Navigate using GoRouter**: `context.go(AppRoutes.dashboard)` etc.
6. **Compute "today"**: Use `todayWeekdayIdProvider` = 'weekday_4' (Thursday)

### Widget Inventory (Available for Use)

**Buttons**:
- `PrimaryButton` - "Start Collecting", "Collect Payment", etc.
- `SecondaryButton` - Secondary actions
- `TertiaryButton` - Tertiary actions or overflow menu

**Components**:
- `StatusChip.fromStatus(status)` - Status indicators
- `AmountDisplay(amount: 24500)` - Rupee formatting
- `SkeletonLoader` - Shimmer placeholders

**States**:
- `LoadingState` - Default skeleton list
- `EmptyState` - No data message
- `ErrorState` - Error with retry

### File Location

Create: `lib/features/dashboard/presentation/screens/dashboard_screen.dart`

Replace the placeholder with full implementation.

---

## Testing Checklist

After implementation, verify:

- [ ] Dashboard compiles without errors
- [ ] All 6 states render correctly (loading, empty, error, populated, offline, offline + sync error)
- [ ] All navigation taps work and navigate to correct screens
- [ ] Pull-to-refresh shows spinner for 400ms then dismisses
- [ ] Greeting changes based on time (Good morning/afternoon/evening)
- [ ] Weekly chips are tappable and update the view
- [ ] Amount displays use proper Indian formatting (₹1,24,500)
- [ ] Typography scale follows Material 3 (no text below 12sp)
- [ ] Touch targets min 48dp, buttons 56dp
- [ ] All images/avatars fallback to initials
- [ ] Scroll works smoothly, no layout jank
- [ ] No null pointer exceptions or errors in console

---

## Data Model Examples

```dart
// From mockUserProvider:
UserModel(
  id: 'user_001',
  name: 'Ramesh Kumar',
  firstName: 'Ramesh',
  phone: '+91 98765 43210',
  avatar: 'RK',
)

// From todaysSummaryProvider (Thursday):
{
  'expected': 24500,
  'collected': 8200,
}

// From mockPlacesByWeekdayProvider('weekday_4'):
PlaceModel(
  id: 'place_1',
  name: 'Village A',
  customerCount: 18,
  expectedAmount: 12500,
  collectedAmount: 0,
  distance: 1.2,
)

// From recentActivitiesProvider:
ActivityModel(
  id: 'activity_1',
  customerId: 'customer_1',
  type: 'payment',
  amount: 5000,
  timestamp: DateTime(...),
  timeAgo: '10m ago',
)
```

---

## Material 3 Theme Details

All widgets automatically use the Material 3 theme from `lib/app/theme.dart`:

- Primary color: Material 3 default blue
- Success (green): For collections
- Amber: For pending/incomplete
- Grey: For carry forward
- Error (red): For errors only (never use for money)

No custom color codes needed—use `Theme.of(context).colorScheme.*`

---

## Package Import Pattern

All files use package imports (not relative):

```dart
// ✅ CORRECT:
import 'package:legacy_notebook/shared/models/customer_model.dart';
import 'package:legacy_notebook/shared/providers/mock_providers.dart';

// ❌ AVOID:
import '../../../shared/models/customer_model.dart';
```

---

## Performance Notes

- **Mock data loading**: FutureProvider caches the result per session
- **Shimmer animation**: 1.5s cycle, smooth
- **Scroll performance**: SingleChildScrollView is sufficient for initial load; optimize later with LazyColumn if needed
- **Navigation**: GoRouter handles deep links and state preservation

---

## Next Phase (After Task 6)

Once Dashboard is complete:
- Task 7-10: Route Explorer (Weekday → Place → Area → Customer List)
- Task 11: Customer Search
- Task 12-14: Customer Details
- Task 15-17: Testing, accessibility, responsive layout

---

## Questions & Blockers

If you encounter:

1. **"FutureProvider not loading data"** → Check `assets/mock_data/` folder exists and files are in `pubspec.yaml`
2. **"Navigation not working"** → Verify `GoRouter` provider in `app.dart` and route paths match `app_routes.dart`
3. **"Widgets not using Material 3 colors"** → Use `Theme.of(context).colorScheme.*`, not hardcoded colors
4. **"Text overflowing"** → Check type scale, wrap long text, use ellipsis, or reduce font size only as last resort
5. **"Touch targets too small"** → Ensure all interactive elements are 48dp+ (buttons 56dp+)

---

## Summary

- **4 Tasks Complete**: Design system, mock data, navigation, placeholder screens ✅
- **Compilation**: 0 errors ✅
- **Ready for**: Dashboard UI implementation (Task 5-6)
- **Data Available**: All providers ready to integrate
- **Design System**: All components available for reuse

**Time to implement Dashboard**: Estimated 2-3 hours depending on detail level and testing.
