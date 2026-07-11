# Dashboard Screen — Implementation Specification

Project: Field Credit Collection & Home Appliance Sales Management System
Platform: Android Mobile Application (Material 3)
Screen: Dashboard (Home Screen after login)

---

## 1. Purpose

The Dashboard is the entry point of the application after login. It orients the collector for the day's field work and gives the owner a real-time snapshot of business health.

It must answer four questions within two seconds of opening:

1. What day is it, and which route am I working today?
2. How much money is expected to be collected today?
3. How many customers must I visit today, and how many are still pending?
4. What is the total outstanding across the business?

The Dashboard is the single launchpad into the day's work — one tap moves the user into the Weekday → Place → Area → Customer navigation chain.

---

## 2. Primary User

- Collector (primary) — opens the app first thing in the morning, wants to start collecting fast.
- Substitute Collector (primary) — unfamiliar with the route; needs strong visual guidance and zero ambiguity.
- Owner (secondary) — checks totals, today's collection, and overall outstanding.

Assume the user may be elderly, may be outdoors in bright sunlight, may be using one hand, and may have limited literacy in English. Numbers and icons must carry the meaning; text is supporting.

---

## 3. Entry Points

- App launch (after successful login / session restore) — lands here by default.
- Bottom navigation "Home" tab from any other primary screen.
- Back navigation from Weekday, Place, Area, Customer Details, Collection, or Sale screens.
- Deep link / notification tap (e.g., "You have 12 pending collections today") opens the Dashboard.
- Pull-to-refresh from within the Dashboard itself (stays on Dashboard, refreshes data).

---

## 4. Exit Points

- Tap Today's Route card → Weekday screen (pre-selected to today).
- Tap any weekday chip in the Weekly Route strip → Weekday screen for that day.
- Tap "Collect Now" quick action → Weekday screen for today.
- Tap "New Sale" quick action → Customer search / picker (then Sale screen).
- Tap a recent activity row → Customer Details for that customer.
- Tap Outstanding summary card → Customers list filtered by "Has outstanding".
- Tap profile avatar (top right) → Profile / Settings screen.
- Tap notification bell (top right) → Notifications screen.
- System back gesture → exits the app (with a "Press back again to exit" toast).

---

## 5. Information Displayed

### 5.1 App Bar (top)
- App logo / brand mark (small, left).
- Greeting line: "Good morning, {First Name}" (adapts to time of day: morning / afternoon / evening).
- Today's date, human-readable: "Thursday, 09 Jul".
- Notification bell with unread count badge (right).
- Profile avatar (right).

### 5.2 Today's Route Card (hero card, primary emphasis)
- Label: "Today's Route".
- Weekday name in large type: "Thursday".
- Route summary: "3 Places · 5 Areas · 42 Customers".
- Expected collection today (₹): large, bold. Example: "₹ 24,500 expected today".
- Progress bar: collected today / expected today. Example: "₹ 8,200 collected · 34%".
- Pending customers count with icon: "28 pending visits".
- Primary CTA button: "Start Collecting" (full width, filled, Material 3 elevated).

### 5.3 Weekly Route Strip (horizontal scroll)
- Seven weekday chips: Sun, Mon, Tue, Wed, Thu, Fri, Sat.
- Today's chip is visually distinct (filled, primary color).
- Each chip shows: weekday short name + customer count. Example: "Thu · 42".
- Chips are tappable → open Weekday screen for that day.

### 5.4 Quick Actions Row (2–4 large tiles)
- Collect Payment — icon: wallet / rupee. Opens today's collection route.
- New Sale — icon: shopping bag. Opens customer picker → Sale.
- Find Customer — icon: search / person. Opens global customer search.
- Inventory (Owner only) — icon: box. Opens Inventory screen.

### 5.5 Business Summary Cards (grid, 2 columns)
- Today's Collection: ₹ amount collected today across all collectors.
- Today's Sales: ₹ amount + count of sales.
- Total Outstanding: ₹ amount across all customers (tap → filtered customer list).
- Customers Visited Today: count / total scheduled.

Owner sees all four. Collector sees only their own today's collection and their own today's sales; the outstanding card shows only the outstanding of customers on their assigned routes.

### 5.6 Recent Activity (last 5 items)
- Section header: "Recent Activity" with "See all" text link.
- Each row:
    - Customer name (bold, primary).
    - Activity type chip: Payment / Partial / Carry Forward / Sale / Advance.
    - Amount (right-aligned, colored: green for money in, blue for sale, grey for carry forward).
    - Time ago: "10 min ago", "2 h ago".
    - Small avatar or initials on the left.
- Tap a row → Customer Details of that customer, timeline scrolled to that activity.

### 5.7 Sync / Offline Indicator (persistent, subtle)
- Small banner or icon in the app bar area.
- States: Online (hidden or subtle green dot), Offline (amber banner "Offline — X activities pending sync"), Syncing (animated).
- Tapping it opens a Sync Status sheet (out of scope for this screen, referenced only).

---

## 6. Actions

Ordered by frequency of use.

1. Start Collecting → primary CTA on Today's Route card.
2. Tap a weekday chip → jump to any day's route.
3. Tap Collect Payment quick action.
4. Tap New Sale quick action.
5. Tap Find Customer.
6. Tap Outstanding summary card → filtered customer list.
7. Tap a recent activity row → Customer Details.
8. Pull to refresh.
9. Tap notification bell.
10. Tap profile avatar.
11. Tap Inventory (Owner only).

---

## 7. Widget Hierarchy

```
DashboardScreen
├── Scaffold
│   ├── AppBar
│   │   ├── Leading: BrandMark
│   │   ├── Title Column
│   │   │   ├── GreetingText
│   │   │   └── DateText
│   │   └── Actions
│   │       ├── SyncStatusIndicator
│   │       ├── NotificationBellWithBadge
│   │       └── ProfileAvatarButton
│   ├── Body: RefreshIndicator
│   │   └── ScrollView (vertical)
│   │       ├── TodaysRouteCard (hero)
│   │       │   ├── WeekdayLabel
│   │       │   ├── RouteSummaryLine (places · areas · customers)
│   │       │   ├── ExpectedAmountLarge
│   │       │   ├── CollectionProgressBar
│   │       │   ├── PendingVisitsRow
│   │       │   └── StartCollectingButton
│   │       ├── WeeklyRouteStrip (horizontal scroll)
│   │       │   └── WeekdayChip × 7
│   │       ├── QuickActionsRow
│   │       │   └── QuickActionTile × 2–4
│   │       ├── BusinessSummaryGrid (2 columns)
│   │       │   └── SummaryCard × 4
│   │       ├── RecentActivitySection
│   │       │   ├── SectionHeader ("Recent Activity" + See all)
│   │       │   └── ActivityRow × up to 5
│   │       └── BottomSpacer (safe area padding)
│   └── BottomNavigationBar (app-wide)
│       └── Home · Customers · Collections · More
```

---

## 8. Layout Structure

- Scroll: single vertical scroll for the whole body. No nested scrollables except the horizontal Weekly Route Strip.
- Screen padding: 16 dp horizontal, 12 dp vertical between sections.
- Card gap: 12 dp between stacked cards.
- Hero card: full width minus 16 dp margins, elevation 2, rounded 20 dp.
- Weekly Route Strip: horizontal list, 8 dp gap between chips, 16 dp start/end padding, 44 dp chip height.
- Quick Actions: horizontal row of equal-width tiles, min 88 × 88 dp, 12 dp gap.
- Summary Grid: 2 columns, 12 dp gap, cards rounded 16 dp, elevation 1.
- Recent Activity rows: 72 dp min height per row (Material 3 two-line list item), full-width dividers optional.
- BottomNavigationBar: 80 dp (Material 3), always visible.
- Safe areas respected top and bottom.

Single-hand reach: the primary CTA ("Start Collecting") sits in the top hero card AND is mirrored in the Quick Actions row, so at least one instance is reachable with a thumb regardless of scroll position.

---

## 9. Component Specifications

### 9.1 AppBar
- Height: 64 dp expanded (two-line title).
- Background: surface color, no elevation on scroll top; elevation 2 after 8 dp scroll.
- Greeting: title-medium, 500 weight.
- Date: label-medium, on-surface-variant color.
- Notification badge: filled red (error color), min 16 dp, white numeric, "9+" cap.

### 9.2 Today's Route Card
- Container: filled tonal card, primary-container background, on-primary-container text.
- Weekday label: display-small (36 sp), 600 weight.
- Expected amount: headline-large (32 sp), 700 weight, ₹ prefix.
- Progress bar: 8 dp height, rounded, primary color fill on primary-container track.
- Start Collecting button: Material 3 filled button, min 56 dp height, full width, icon + label.

### 9.3 Weekday Chip
- Size: min 64 × 44 dp.
- Selected (today): filled, primary background, on-primary text, elevation 1.
- Unselected: outlined, on-surface text.
- Two-line content: weekday short + numeric count.

### 9.4 Quick Action Tile
- Size: min 88 × 88 dp square, or equal-width row cell.
- Icon: 32 dp, primary color.
- Label: label-large, on-surface, single line, ellipsis if needed.
- Ripple + haptic light-impact on press.

### 9.5 Summary Card
- Height: min 96 dp.
- Top row: small icon (20 dp) + label (label-medium).
- Main value: headline-small (24 sp), 600 weight.
- Sub value: label-small, on-surface-variant.
- Tap target: entire card.

### 9.6 Activity Row
- Leading: 40 dp circular avatar with initials.
- Two-line title: customer name (title-small, 500) + activity type chip (label-small).
- Trailing: amount (title-medium, 600, colored by type) + time ago (label-small, on-surface-variant).
- Full row is tappable; 72 dp min height.

### 9.7 Amount Color Semantics
- Payment / Partial Payment: success green.
- Sale / Advance: primary blue.
- Carry Forward: on-surface-variant grey.
- Never use red for money (reserved for errors and destructive actions).

### 9.8 Typography Scale
- Follow Material 3 type scale. Minimum body text 14 sp. Minimum amount display 20 sp on any card. No text below 12 sp anywhere on the Dashboard.

### 9.9 Color & Contrast
- All text must meet WCAG AA (4.5:1) against its background.
- Outdoor readability: primary text on primary-container must be tested at maximum brightness; avoid low-contrast tonal pairings.

---

## 10. Loading State

- On first open with no cached data: skeleton placeholders for each block (hero card, chips strip, summary grid, activity rows). Shimmer animation, 1.5 s cycle.
- On refresh with cached data: existing content stays visible; a linear progress bar (2 dp) appears under the app bar. No skeletons on refresh — never blank out data the user is already looking at.
- Pull-to-refresh: standard Material circular indicator, primary color.
- Skeleton blocks preserve final layout heights to prevent content shift.

---

## 11. Empty State

### 11.1 No route assigned for today (rest day / no schedule)
- Hero card replaced with a friendly empty state:
    - Illustration (calm, non-alarming).
    - Headline: "No route today".
    - Sub: "Enjoy the day, or view another weekday below."
    - Weekly Route Strip still shown so the user can jump to another day.

### 11.2 No recent activity
- Recent Activity section shows a single row:
    - Icon (clock).
    - Text: "No activity yet today."

### 11.3 New user with no data anywhere
- Hero card: "Welcome, {Name}. Your first route will appear here once assigned."
- Summary cards show "—" instead of ₹0 to avoid implying a real zero.
- Owner sees a secondary CTA: "Add your first customer".

---

## 12. Error State

### 12.1 Full-screen error (initial load failed AND no cache)
- Centered illustration + message: "Couldn't load your dashboard".
- Sub: plain-language reason ("Check your internet and try again").
- Retry button (filled, primary).
- Contact support text link (secondary).

### 12.2 Partial error (some sections failed to refresh)
- Keep last known data visible.
- Show a dismissable inline banner at the top of the affected section: "Couldn't update — showing last synced data. Tap to retry."
- Never remove data the user was already seeing.

### 12.3 Offline
- Amber banner directly under the app bar: "You are offline. Data shown was last updated at 08:12 AM."
- Pending sync counter: "3 collections waiting to sync."
- Actions like Start Collecting, New Sale remain enabled — they queue locally.
- Only refresh, notifications, and profile-photo upload are disabled with a tooltip.

### 12.4 Permission / auth error
- Toast: "Session expired. Please sign in again." → navigate to Login.

---

## 13. Accessibility

- Minimum touch target: 48 × 48 dp everywhere; primary CTA is 56 dp.
- Content descriptions on every icon-only control (bell, avatar, sync indicator, quick action tiles).
- Semantic headings: greeting is H1, section headers ("Recent Activity") are H2.
- Announce amounts naturally to screen readers: "Twenty four thousand five hundred rupees expected today", not "₹ 24,500".
- Support text scaling up to 200% without truncation; long text wraps, never clips.
- All color-coded information also carries an icon or text label (e.g., Carry Forward chip shows an arrow icon, not color alone).
- Focus order: App Bar → Hero card → Start Collecting button → Weekday strip (left to right) → Quick Actions (left to right) → Summary Grid (row major) → Recent Activity rows top to bottom → Bottom Nav.
- Haptic feedback: light impact on primary tap, selection tick on weekday chip change.
- Do not rely on hover — this is a touch device.
- Elderly-friendly: default font size at least 16 sp for body, generous line height (1.4×), avoid all caps except in short chips.

---

## 14. Navigation Rules

- Dashboard is the root of the navigation stack. System back on Dashboard shows a "Press back again to exit" toast; a second back within 2 s exits the app.
- Bottom Navigation "Home" is highlighted while on Dashboard. Re-tapping "Home" scrolls the Dashboard to top and refreshes the hero card.
- All outward navigations push onto the stack; returning brings the user back to Dashboard with scroll position preserved.
- Deep link into Dashboard replaces the stack — Dashboard is never a child.
- Notifications and Profile open as pushed screens with a back arrow, not as tabs.

---

## 15. Edge Cases

1. Today has zero scheduled customers → show "No route today" empty state; hide expected amount and progress; keep weekly strip.
2. Expected amount is zero but customers are scheduled (all have zero outstanding) → show "₹ 0 expected · 12 courtesy visits" and adjust CTA label to "Start Visits".
3. Collected > Expected today (over-collection from past dues) → progress bar caps at 100%; show a small badge "+₹2,300 extra collected"; never show >100% progress.
4. Substitute Collector logged in on someone else's route → show a banner "You are covering for {Name} today" above the hero card.
5. Owner viewing Dashboard → business summary cards show global totals; recent activity aggregates all collectors; add a small collector filter chip above Recent Activity.
6. Very long customer name in Recent Activity → truncate to one line with ellipsis; full name visible in Customer Details.
7. Very large amount (7+ digits) → format with Indian numbering ("₹ 1,24,500"); never scale text down below the minimum. Instead, wrap to two lines on the hero card if needed.
8. Date crosses midnight while app is open → auto-refresh Dashboard at 00:00 local time so "Today" updates without a manual reload.
9. Timezone / device clock changed → recompute date and route on resume; if mismatch with server date, show a subtle warning icon in the app bar.
10. User has multiple weekdays assigned to same day (rare) → show combined route in hero; weekday chip shows total.
11. Sync fails mid-refresh → keep old data, show partial error banner, do not clear timers or user input elsewhere.
12. Notifications permission denied → hide unread badge; tapping bell still opens notifications screen with an inline enable-permission prompt.
13. Profile photo not set → show initials avatar with a color derived deterministically from user id.
14. Extremely poor network (2G) → skip images on activity rows, keep initials avatars; show sync indicator as "Slow connection".
15. Duplicate quick tap on Start Collecting → debounce 500 ms; disable button visually until navigation completes.
16. App resumed after long background (>30 min) → auto trigger a silent refresh; show progress bar under app bar, no skeleton.
17. Customer count updated mid-day (new customer added by owner) → hero card updates on next refresh; show a subtle "Updated" pulse on the affected number.

---

## 16. Interaction Specifications

### 16.1 Tap
- All primary interactive surfaces (cards, tiles, rows, chips) respond to tap with:
    - Ripple animation (Material 3 default), 200 ms.
    - Light haptic on down, no haptic on release.
- Buttons: filled primary uses "elevated + fade" pressed state.

### 16.2 Long Press
- Long press on a Recent Activity row (400 ms) → contextual menu: "View customer", "Call customer", "Copy amount".
- Long press on a Weekday chip → tooltip with full weekday name and expected amount for that day.

### 16.3 Swipe
- Horizontal swipe on Weekly Route Strip: standard fling scroll.
- Horizontal swipe on a Recent Activity row: reveals a quick "Call" action (right swipe) and "View" (left swipe). Actions never destructive — swipe never deletes anything on the Dashboard.

### 16.4 Pull to Refresh
- Threshold 80 dp.
- Refreshes hero card totals, weekly strip counts, summary grid, and recent activity together (single coordinated fetch).
- Duration cap: show indicator at least 400 ms even if response is faster, to make the refresh feel intentional.

### 16.5 Scroll
- App bar collapses subtly on scroll: greeting line hides, only date and actions remain, elevation increases.
- Bottom nav stays pinned.
- Weekly Route Strip does not stick — it scrolls with the page (owner and collector both prefer maximum vertical space for content).

### 16.6 Transitions
- Navigating out to Weekday / Sale / Customer Details uses a shared-axis X (forward) transition, 300 ms, standard Material easing.
- Returning uses the reverse transition.
- Refresh spinner uses standard Material progress motion.

### 16.7 Feedback & Toasts
- Successful background sync → subtle snackbar at bottom: "Synced 3 collections" (2 s auto-dismiss). Only shown if the user was previously offline.
- Failed background sync → persistent banner as described in Error State 12.2.
- Never block the Dashboard with a modal for informational messages.

### 16.8 Timings
- First frame under 1 s from tap on app icon (with cached data).
- Interactive within 2 s.
- Skeleton to content swap: 200 ms cross-fade.
- Any action that does not produce visible change within 300 ms must show a progress indicator.

### 16.9 Sound
- No sound by default.
- Optional (user setting) light "tick" on successful pull-to-refresh completion.

---

End of Dashboard Screen specification.