# Route Explorer — Implementation Specification

Project: Field Credit Collection & Home Appliance Sales Management System
Platform: Android Mobile Application (Material 3)
Flow: Weekday → Place → Area → Customer

---

## 1. Purpose

The Route Explorer is how a collector drills from a day of the week down to the individual customer they are standing in front of. It mirrors the physical reality of field collection: on any given day, the collector covers a set of Places (villages / colonies), each Place has one or more Areas (streets / lanes), and each Area contains a fixed list of Customers.

The explorer must:

1. Show the collector exactly where they are in the four-level hierarchy at all times.
2. Surface the two numbers that matter at every level: how many customers, how much money is expected.
3. Show completion progress so the collector knows what is left to do.
4. Let a substitute collector, who has never walked this route, complete the day without asking anyone.

The four screens (Weekday, Place, Area, Customer List) share one interaction model, one visual language, and one navigation pattern. They are one feature, not four.

---

## 2. Primary User

- Collector — knows the route, wants speed and minimum taps.
- Substitute Collector — does not know the route, needs strong wayfinding, GPS hints, and clear order.
- Owner — audits progress and inspects any level read-only.

All three see the same screens. Role differences are limited to which actions are enabled (see Actions).

---

## 3. Entry Points

### 3.1 Weekday screen
- Dashboard → Start Collecting (opens today's weekday).
- Dashboard → tap any Weekday chip in the Weekly Route Strip.
- Bottom Nav → Collections tab (opens today's weekday).
- Deep link / notification: "You have 12 pending visits today".

### 3.2 Place screen
- Weekday screen → tap a Place row.
- Deep link from a saved shortcut ("Continue Village A").
- Back from Area screen.

### 3.3 Area screen
- Place screen → tap an Area row.
- Back from Customer List screen.

### 3.4 Customer List screen
- Area screen → tap the Area (auto-drills when the Area has exactly one implicit list of customers).
- Global Customer Search → tap "View in route context".
- Back from Customer Details screen.

---

## 4. Exit Points

Common to all four screens:
- System back / top-left back arrow → previous level in the chain.
- Bottom Navigation tab → leaves the flow.
- Tap breadcrumb segment → jump to that level.

Level-specific:
- Weekday → tap Place → Place screen.
- Place → tap Area → Area screen.
- Area → tap Area card → Customer List (or, if only one area exists, this step is skipped and the user lands on Customer List directly).
- Customer List → tap Customer row → Customer Details screen.
- Customer List → tap "Collect" quick action on a row → Collection screen for that customer.
- Customer List → tap "Sell" quick action on a row → Sale screen for that customer.
- Any level → tap "Open in Maps" (Place / Area only) → external Google Maps intent.

---

## 5. Information Displayed

### 5.1 Weekday screen
- App bar: title "Thursday · 09 Jul", back arrow, sync indicator, overflow menu.
- Sub-header (sticky): total customers today, total expected ₹, total collected ₹, progress bar.
- Weekday selector strip (horizontal): Sun–Sat chips, today filled. Tapping any chip switches the screen contents.
- List of Places for the selected weekday. Each Place row shows:
    - Place name (bold, primary line).
    - Sub-line: "{N} Areas · {N} Customers".
    - Right column: expected ₹ today, and collected ₹ today.
    - Progress bar under the row (thin).
    - Status chip: Pending / In Progress / Done.
    - Distance from current GPS (if location permission granted): "1.2 km".
- Empty spacer / FAB area at the bottom.

### 5.2 Place screen
- App bar: Place name as title, back arrow, sync indicator, overflow (with "Open in Maps", "Call point of contact" if configured).
- Sub-header (sticky): "{N} Areas · {N} Customers", expected ₹, collected ₹, progress bar, weekday context ("Thursday route").
- List of Areas within this Place. Each Area row shows:
    - Area name.
    - Sub-line: "{N} Customers".
    - Right column: expected ₹, collected ₹.
    - Status chip: Pending / In Progress / Done.
    - Small progress bar.

### 5.3 Area screen
- App bar: Area name as title, back arrow, sync indicator, overflow.
- Breadcrumb strip (single line, ellipsised in the middle if long): "Thursday › Village A › North Street".
- Sub-header: "{N} Customers", expected ₹, collected ₹, progress bar.
- The Area screen may skip itself when a Place has exactly one Area — in that case it is bypassed on drill-down and shown only if the user explicitly navigates back. Otherwise it shows a Customer List directly.

### 5.4 Customer List screen (leaf of the explorer)
- App bar: Area name, back arrow, search action (filters within the area), sort action, overflow.
- Breadcrumb strip: "Thursday › Village A › North Street".
- Sub-header: "{N} Customers · ₹ {expected} expected · ₹ {collected} collected", progress bar.
- Filter chips row: All · Pending · Partial · Done · No Outstanding.
- Customer rows (see 9.6). Each row shows:
    - Avatar / initials.
    - Customer name (bold).
    - Sub-line: phone (masked last-4) or house number.
    - Outstanding ₹ (right-aligned, colored).
    - Status chip: Pending / Partial / Done / Carry Forward / No Outstanding.
    - Last activity time ago ("Visited 2 h ago").
    - Right-swipe action: Collect. Left-swipe action: Call.
- FAB: "Add customer to this area" (Owner only; hidden for Collector unless permitted).

### 5.5 Shared across all four screens
- Persistent offline / sync indicator in app bar.
- Pending sync counter if any activity is queued.
- "Today" pill visible in the sub-header if the currently viewed weekday equals the device's current weekday.

---

## 6. Actions

Ordered by frequency.

### 6.1 Weekday screen
1. Tap a Place row → drill down.
2. Switch weekday via the top strip.
3. Pull to refresh.
4. Tap sub-header progress bar → summary sheet ("What's left today").
5. Overflow → "View on map" (plots all today's Places as pins), "Export today's list" (Owner only).

### 6.2 Place screen
1. Tap an Area row → drill down.
2. Tap "Open in Maps" → external navigation to the Place's saved GPS.
3. Overflow → "Call point of contact", "Report issue", "Mark Place done" (Collector, only when all areas done).

### 6.3 Area screen (when shown)
1. Tap Area / Continue → Customer List.
2. Tap "Open in Maps" for the Area centroid.
3. Overflow → "Reorder customers" (Owner only), "Report issue".

### 6.4 Customer List screen
1. Tap Customer row → Customer Details.
2. Right-swipe Collect → Collection screen for that customer.
3. Left-swipe Call → dialer intent.
4. Long press Customer row → contextual menu: View, Call, Directions, Mark visited (no payment).
5. Filter chips → filter the list.
6. Search (app bar) → free-text filter within the area.
7. Sort → Default (route order), Highest outstanding, Nearest first (requires GPS), Not yet visited.
8. FAB Add Customer → new customer form pre-scoped to this Area (Owner only).

### 6.5 Role differences
- Collector: cannot add / edit / reorder route structure. Can perform Collect, Sell, Call, Mark Visited.
- Substitute Collector: same as Collector, plus a persistent banner (see Edge Cases).
- Owner: everything, plus edit / reorder / add / export.

---

## 7. Widget Hierarchy

All four screens share the same skeleton. Only the list content differs.

```
RouteExplorerScreen (Weekday | Place | Area | CustomerList)
├── Scaffold
│   ├── AppBar
│   │   ├── BackButton
│   │   ├── TitleColumn (title + optional subtitle)
│   │   └── Actions (Search?, Sort?, SyncIndicator, Overflow)
│   ├── StickyHeader
│   │   ├── BreadcrumbStrip           (Place / Area / CustomerList only)
│   │   ├── WeekdaySelectorStrip      (Weekday only)
│   │   ├── SummaryRow (counts + ₹ expected + ₹ collected)
│   │   ├── ProgressBar
│   │   └── FilterChipsRow            (CustomerList only)
│   ├── Body: RefreshIndicator
│   │   └── ScrollView
│   │       └── List
│   │           ├── PlaceRow          (Weekday)   ×N
│   │           ├── AreaRow           (Place)     ×N
│   │           ├── (skip)            (Area routes usually straight to list)
│   │           └── CustomerRow       (CustomerList) ×N
│   ├── FAB (Owner add actions, level-appropriate)
│   └── BottomNavigationBar (app-wide)
```

---

## 8. Layout Structure

- Screen padding: 16 dp horizontal.
- Sticky header: elevation 2 once the list scrolls under it.
- List row min height: 72 dp (two-line row) for Place / Area, 80 dp for Customer (adds status chip line).
- Row internal padding: 16 dp horizontal, 12 dp vertical.
- Row separators: 1 dp on-surface-variant / 20% divider, or use inset dividers left-aligned after the avatar column.
- Right-column amounts: right-aligned, tabular numerals so digits align across rows.
- Progress bar under sub-header: 6 dp height, rounded, primary track.
- Filter chips row: 44 dp height, horizontally scrollable.
- FAB: 56 dp standard, bottom-right, 16 dp margins.
- Bottom Nav always visible.
- Safe areas respected top and bottom; last list row has 88 dp bottom padding so the FAB never covers it.

Single-hand thumb reach:
- Primary drill target is the whole row (large area).
- Row-level quick actions (Collect / Call) are surfaced via horizontal swipe, not tiny trailing icons.

---

## 9. Component Specifications

### 9.1 Sticky SummaryRow
- Layout: left column shows "{N} Customers"; right column shows "₹ {collected} / ₹ {expected}"; below, a full-width progress bar.
- Amount typography: title-medium, 600 weight, tabular numerals.
- Sub-labels: label-small, on-surface-variant.
- On tap: opens a bottom sheet "Today's summary" with a breakdown by status.

### 9.2 WeekdaySelectorStrip
- 7 chips: Sun–Sat.
- Selected: filled primary, on-primary label.
- Unselected: outlined, on-surface.
- Two-line chip: weekday short + numeric customer count.
- Min size 64 × 44 dp; 8 dp gap.

### 9.3 BreadcrumbStrip
- Single line, horizontally scrollable if needed.
- Format: "Thursday › Village A › North Street".
- Each segment is tappable, jumps to that level.
- Current segment: on-surface, 600 weight, non-tappable visually distinct.
- Prior segments: primary color, underlined on press.

### 9.4 PlaceRow
- Leading: pin icon (24 dp, on-surface-variant).
- Title: Place name, title-small, 600.
- Subtitle: "{N} Areas · {N} Customers · 1.2 km".
- Trailing column:
    - Expected ₹ (title-small, 600).
    - Collected ₹ (label-small, on-surface-variant).
    - Status chip (Pending / In Progress / Done) with icon + color.
- Bottom: 4 dp progress bar spanning row.

### 9.5 AreaRow
- Leading: street icon (24 dp).
- Title: Area name.
- Subtitle: "{N} Customers".
- Trailing: same amount stack as Place row.
- Bottom: progress bar.

### 9.6 CustomerRow
- Leading: 40 dp circular avatar (photo or initials on deterministic color).
- Title: customer name, title-small, 600.
- Subtitle line 1: phone masked (e.g. "•••• 4321") or house number.
- Subtitle line 2: last activity "Visited 2 h ago" OR "Not visited today".
- Trailing:
    - Outstanding ₹ amount (title-medium, 600, colored by status).
    - Status chip: Pending / Partial / Done / Carry Forward / No Outstanding.
- Swipe reveals:
    - Right swipe (start → end): green Collect action.
    - Left swipe (end → start): blue Call action.
    - Swipe never deletes anything.
- Long press → contextual menu.

### 9.7 StatusChip
- Fixed set: Pending, In Progress, Done, Partial, Carry Forward, No Outstanding.
- Each has an icon + label; never color-only.
- Colors:
    - Pending: neutral (on-surface-variant).
    - In Progress: amber tone.
    - Done: success green.
    - Partial: primary blue.
    - Carry Forward: outlined neutral.
    - No Outstanding: subtle grey.

### 9.8 FilterChipsRow (CustomerList only)
- Single-select behavior, default "All".
- Chips: All · Pending · Partial · Done · No Outstanding.
- Selected: filled primary. Persists per (weekday, area) for the session.

### 9.9 SortMenu
- Options: Route Order (default), Highest Outstanding, Nearest First (disabled without GPS), Not Visited Today.
- Selected option marked with a check.

### 9.10 Amount Formatting
- Indian numbering (₹ 1,24,500).
- Never scale text below the type-scale minimum. Wrap or truncate the customer name first, never the amount.
- Zero outstanding shows "—", not "₹ 0", to reduce cognitive noise in scanning lists.

---

## 10. Loading State

- First open of any level, no cache: skeleton list of 6 rows matching final row height. Sticky header shows skeleton bars for count and amount. Shimmer 1.5 s cycle.
- Refresh with cache: keep list visible, show a 2 dp linear progress bar under the sticky header.
- Weekday switch: instant switch if data cached for that day; otherwise skeleton for list only, header count animates to new value.
- Drill-down transition: pushes the next screen; the next screen shows its own skeleton if not cached.
- Pull-to-refresh threshold 80 dp, min visible duration 400 ms.
- Filter/sort change: never full skeleton; list re-renders with a subtle fade (150 ms).

---

## 11. Empty State

### 11.1 Weekday: no route today
- Illustration + headline "No route for Thursday".
- Sub: "Choose another day above, or return to Dashboard."
- Secondary action: "Go to today" (jumps to actual current weekday if different).

### 11.2 Place: no areas
- Headline: "No areas defined for this Place."
- Owner sees CTA: "Add first area".
- Collector sees a note: "Ask your owner to add areas for this place."

### 11.3 Area / Customer List: no customers
- Headline: "No customers in this area yet."
- Owner sees CTA: "Add customer".
- Collector sees: "Nothing to visit here today."

### 11.4 Filter empty
- When a filter yields zero rows: keep the header, replace the list body with:
    - Icon + "No customers match this filter."
    - Button: "Clear filter".

### 11.5 Zero expected but customers exist
- Sub-header shows "₹ 0 expected · courtesy visits only" and progress bar is hidden.
- CTA on the summary tap becomes "Mark visits" instead of tracking rupees.

---

## 12. Error State

### 12.1 Full-screen error (no cache and load failed)
- Centered illustration + message "Couldn't load this list".
- Retry button (filled primary).
- Contact support link.

### 12.2 Partial refresh error (cache exists)
- Inline dismissable banner at top of the list: "Couldn't refresh — showing last synced data. Tap to retry."
- Do NOT clear the visible list.

### 12.3 Offline
- Amber banner under the app bar: "Offline — data last synced at 08:12 AM."
- Row-level actions (Collect / Call / drill down) remain enabled; new activities queue locally.
- "Add customer" FAB is disabled offline with a tooltip: "Add customer needs internet."

### 12.4 Permission errors
- GPS denied: hide distance labels; hide "Nearest First" sort; show a small "Enable location" pill in sticky header that opens the OS permission screen.
- Call permission denied: swipe-to-call opens a fallback confirm dialog rather than direct dial.

### 12.5 Data integrity edge
- If a Place points to zero Areas but has customers directly (misconfigured): show a single "Ungrouped" Area row so the collector can still reach the customers.

---

## 13. Accessibility

- Minimum touch target 48 dp; row targets are much larger.
- All icon-only controls (sync indicator, sort, overflow) have content descriptions.
- Announce rows naturally: "Ramesh Kumar, outstanding twelve thousand rupees, pending, visited two hours ago. Double tap to open."
- Announce breadcrumbs as: "You are in Thursday, Village A, North Street."
- Support text scaling to 200% without truncation of critical numbers; amount text wraps to a second line before shrinking.
- Every status chip carries an icon in addition to color.
- Focus order: back → title → sticky header controls → list top-to-bottom → FAB → bottom nav.
- Haptics: light impact on tap; selection tick on chip / filter change; success haptic on swipe-collect completion.
- Weekday chips announce the numeric count ("Thursday, 42 customers").
- All amounts read as words in the locale (e.g., "twelve thousand five hundred rupees") for screen readers.

---

## 14. Navigation Rules

- Strict hierarchy: Weekday → Place → Area → Customer List → Customer Details.
- Back always returns to the previous level in the chain, never skips.
- Breadcrumb tap CAN skip levels backwards (jump to Weekday from Customer List).
- Skipping the Area level: when a Place has exactly one Area, drilling into that Place goes directly to Customer List. Back from Customer List still goes to the Place screen, not the (implicit) Area screen.
- Switching weekday via the strip on the Weekday screen is not a navigation push — it swaps the list contents in place; back exits the flow.
- Switching weekday from any deeper level is not allowed. The user must go back to the Weekday screen. This prevents accidental context loss.
- Deep links: opening a Customer deep link from outside the flow pushes the full stack (Weekday → Place → Area → Customer List → Customer Details) so back navigation is coherent.
- Bottom nav switches are stateful — returning to the Collections tab restores the last position in the explorer.
- Search results that jump to a customer show the breadcrumb of their assigned route so the collector is never lost.

---

## 15. Edge Cases

1. Customer belongs to multiple routes (rare data quirk) → show them under all applicable routes; deduplicate by id in totals so amounts are not double counted.
2. Customer moved to a different Area today → show the new Area only; a note appears in Customer Details.
3. Place with 500+ customers → paginate/virtualize the list; sticky header shows "Loading more…" chip when appending.
4. Area with a single customer → still show the area screen only if it was reached by explicit back navigation; forward drill goes straight to Customer Details.
5. Substitute collector on someone else's route → persistent banner on every level: "Covering for {Name} today". Banner is dismissable per session.
6. Owner viewing a route they do not collect → all destructive quick actions (Collect, Sell) are enabled but tagged "on behalf of {Collector}".
7. GPS distance appears wrong (indoor accuracy) → distance older than 60 s is shown with a "~" prefix ("~1.2 km").
8. Route reordered by owner while collector is mid-route → show a snackbar "Route updated" with "Refresh" action; do not reorder under the user's finger.
9. Currency overflow (₹ 1,25,00,000 total in sub-header) → wrap to two lines, keep tabular alignment.
10. Two collectors work the same route → filter chip "Mine only" appears; default is Mine only for collectors, All for owners.
11. Same customer collected twice today (partial + payment) → Customer row shows the latest status chip; long press shows full timeline hint.
12. Time zone change or clock skew → recompute "today" on resume; if the weekday in view is stale, show a banner "The day has changed. Go to today."
13. Empty area created and later filled → new customers appear at the top of the list with a subtle "New" badge for the first day.
14. Bulk action requested (mark all done) → not supported. Every visit is an explicit act; there is no bulk button anywhere in this flow.
15. Customer marked "Do not visit" (e.g. dispute) → row is greyed with a lock icon; swipe actions disabled; tap still opens Details (read-only banner).
16. Extremely long place / area names → truncate with ellipsis at row level; full name visible in the header when drilled in.
17. Search that yields customers outside the current area → results section splits into "In this area" and "Elsewhere on your route" so context is preserved.

---

## 16. Interaction Specifications

### 16.1 Tap
- Row tap: full-row ripple, 200 ms; light haptic; navigation transition begins immediately.
- Debounce: 500 ms on row taps to prevent double navigation.

### 16.2 Long press
- 400 ms → context menu on customer rows (View, Call, Directions, Mark Visited).
- Long press on Place / Area rows → tooltip with expected ₹ and last visit summary.

### 16.3 Swipe
- Right swipe (start → end) on CustomerRow: reveals green Collect action; releasing past 30% of width triggers navigation to Collection.
- Left swipe (end → start): reveals blue Call action; releasing past 30% triggers dialer.
- Swipe threshold shows an anchored state at 30%; users can commit by tap or by releasing past 60%.
- Never destructive. No delete-by-swipe.

### 16.4 Pull to refresh
- Threshold 80 dp; standard Material indicator.
- Refresh scope: current level's data + parent counts (so sub-header numbers update).
- Minimum indicator visible time: 400 ms.

### 16.5 Filter / Sort
- Filter chip change: local re-filter, 150 ms fade transition on list rows.
- Sort change: bottom sheet, single-select, applies on selection.
- Both persist per (weekday, area) for the session; reset on app restart.

### 16.6 Weekday switch (only on Weekday screen)
- Tap chip: 150 ms fade of list content; sub-header numbers count up/down with a 300 ms animation.
- Currently selected chip has a subtle scale-up (1.05×).

### 16.7 Drill-down transitions
- Shared-axis X forward, 300 ms, standard Material easing.
- Back uses reverse.
- Breadcrumb jumps use a fade (200 ms) rather than shared-axis, to signal a "warp" rather than a step.

### 16.8 Progress animations
- Sub-header progress bar animates from previous value to new value over 400 ms after any collection completes.
- Row-level progress bar (Place / Area rows) uses the same duration and easing, staggered by 30 ms per row for a subtle cascade.

### 16.9 Snackbars and toasts
- "Route updated" (data changed remotely) → snackbar with Refresh action, 4 s.
- "Synced N activities" → 2 s snackbar after coming back online.
- Errors on refresh → inline banner, not snackbar (they must persist until retried).

### 16.10 Timings
- Level-to-level navigation must feel instant (<300 ms) when data is cached.
- With no cache, show skeleton within 100 ms of navigation start.
- Swipe actions commit within 150 ms of release; navigation to Collection begins immediately after the commit animation.

### 16.11 Sound
- No sound. Optional light haptic "tick" on swipe-commit and successful drill-down.

---

End of Route Explorer specification.