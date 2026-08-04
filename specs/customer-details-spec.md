# Customer Details Screen — Implementation Specification

Project: Field Credit Collection & Home Appliance Sales Management System
Platform: Android Mobile Application (Material 3)
Screen: Customer Details (leaf of the route explorer, launchpad for Collection and Sale)

---

## 1. Purpose

Customer Details is the single source of truth about one customer, viewed at the customer's doorstep. It answers, in order of importance:

1. Who is this person? (photo, name, phone)
2. How much do they owe right now? (one running outstanding number — never per product)
3. What have they done recently? (unified timeline of collections and sales)
4. What can I do next? (Collect Payment · New Sale · Edit Customer)

The screen is a launchpad. The collector opens it, glances, and acts. Everything below the fold is reference material. Everything above the fold is the identity and the money.

---

## 2. Primary User

- Collector — opens it every visit, needs the outstanding and the two primary actions within one glance.
- Substitute Collector — has never met this customer; leans on photo, address, GPS, and nominee info to confirm identity.
- Owner — reviews history, edits customer data, inspects proofs.

Assume outdoor use, one-handed operation, weak network. Elderly-friendly type sizes throughout.

---

## 3. Entry Points

- Customer List (Area) → tap a row.
- Global Customer Search → tap a result.
- Dashboard → Recent Activity row → tap.
- Notification: "Payment received from Owner" → tap.
- Deep link (shared by owner) → opens with full back stack rebuilt (Weekday → Place → Area → Customer List → Customer Details).
- Back from Collection or Sale screen after completing the activity (returns here with the new activity visible in the timeline).

---

## 4. Exit Points

- Back arrow / system back → Customer List (or previous screen in the stack).
- Bottom action "Collect Payment" → Collection screen.
- Bottom action "New Sale" → Sale screen.
- Bottom action "Edit Customer" → Edit Customer form (Owner; Collector sees a limited "Update phone / photo / GPS" form).
- Tap phone number → dialer intent (external app).
- Tap GPS card → external maps intent for directions.
- Tap a proof image thumbnail → full-screen image viewer.
- Tap a timeline row → activity detail sheet (in-app, does not leave the screen).

---

## 5. Information Displayed

### 5.1 App Bar
- Back arrow.
- Title: customer name (single line, ellipsised).
- Overflow menu: Share customer, Report issue, Mark "Do not visit", Delete (Owner only).
- Sync indicator.

### 5.2 Identity Header (hero)
- Circular photo (large). Falls back to initials avatar with deterministic color.
- Customer name (display-small).
- Primary phone number (tappable, formatted).
- Small chip row under the name: Route context ("Thursday · Village A · North Street"), Customer code / ID (label-small), "Do not visit" chip if applicable.

### 5.3 Outstanding Card (primary financial block)
- Label: "Outstanding".
- Amount (headline-large, 700 weight, ₹ prefix, Indian numbering).
- Sub-line: "Updated {time ago}" or "Includes unsynced activity" when local changes are pending.
- Micro-breakdown link: "How is this calculated?" → opens a bottom sheet showing:
    - Total financed (sum of credit added from sales).
    - Less total collected (sum of PAYMENT + PARTIAL_PAYMENT).
    - Equals outstanding.
    - Explicit note: CARRY_FORWARD activities do not reduce outstanding.
- Never per-product EMI, never a schedule. One number, one running balance.

### 5.4 Personal Information
- Section header: "Personal".
- Rows: Alternate phone, Guardian / spouse name, Date of birth (optional), Occupation (optional), Notes (free text).
- Any missing field is hidden entirely (no empty rows).

### 5.5 Address
- Full postal address (multi-line, selectable).
- Landmark line.
- Copy icon at the right → copies the address to clipboard.

### 5.6 GPS Location
- Small static map preview (or a placeholder tile if maps unavailable / offline).
- "Open in Maps" primary button → external maps app for directions.
- Distance from current device location: "1.2 km · 4 min drive" (when GPS granted).
- "Update pinned location" text link (records the current device GPS as the new pin — Collector allowed).

### 5.7 Nominees
- Section header: "Nominees" (people responsible if the customer is unavailable).
- Each nominee row: name, relationship, phone (tappable).
- Empty state within section: "No nominees added." Owner sees inline "Add nominee".

### 5.8 Proof Images
- Horizontal thumbnail strip (72 × 72 dp).
- Each thumbnail labeled: ID Proof · Address Proof · Photo with Customer · Other.
- Tap → full-screen viewer with pinch zoom.
- Owner sees "Add proof" tile at the end.

### 5.9 Activity Timeline
- Section header: "Activity" + filter chips: All · Collections · Sales.
- Reverse chronological. Grouped by day with a sticky day divider ("Today · 09 Jul", "Yesterday · 08 Jul", "Mon · 06 Jul").
- Each activity row shows:
    - Icon by type (rupee for collection, bag for sale).
    - Type chip: Payment / Partial Payment / Carry Forward / Sale / Advance.
    - Amount (right-aligned, colored by type — see 9.7).
    - Sub-line: short note or product summary ("Will arrange by evening" / "Washing Machine + Mixer").
    - Time ("09:15 AM"). Collector name (label-small) if not the current user.
- Multiple activities same day are listed under the same day header in the order they occurred (earliest first within the day, or newest-first with a toggle — default newest-first).
- Infinite scroll: loads older months on demand.

### 5.10 Bottom Action Bar (persistent, pinned)
- Three primary actions, always visible above the bottom safe area:
    1. Collect Payment (filled primary, largest).
    2. New Sale (filled tonal).
    3. Edit Customer (outlined).
- Never hidden by scroll. Never truncated on small screens (wraps labels under icons if necessary).

### 5.11 Persistent indicators
- Sync / offline chip in the app bar area.
- "Unsynced activity" badge on the Outstanding card if any local activity is queued.

---

## 6. Actions

Ordered by frequency.

1. Tap Collect Payment (bottom).
2. Tap New Sale (bottom).
3. Tap phone number → call.
4. Filter timeline (All / Collections / Sales).
5. Tap timeline row → activity detail sheet.
6. Tap Open in Maps.
7. Tap Update pinned location (Collector, at doorstep).
8. Tap proof thumbnail → viewer.
9. Tap Edit Customer (Owner / limited for Collector).
10. Overflow → Share, Report issue, Mark "Do not visit", Delete (Owner).
11. Long press outstanding amount → copy to clipboard.
12. Pull to refresh.

### 6.1 Role differences
- Collector: Collect, Sell, Call, Update GPS, limited Edit (phone / photo). Cannot delete, cannot edit financial rows.
- Substitute Collector: same as Collector plus visible "Covering for {Name}" banner.
- Owner: everything, including delete, mark "Do not visit", edit any field, add / remove nominees, add / remove proofs.

---

## 7. Widget Hierarchy

```
CustomerDetailsScreen
├── Scaffold
│   ├── AppBar
│   │   ├── BackButton
│   │   ├── Title (customer name)
│   │   └── Actions (SyncIndicator, Overflow)
│   ├── Body: CustomScrollView
│   │   ├── IdentityHeader
│   │   │   ├── AvatarLarge
│   │   │   ├── NameText
│   │   │   ├── PhoneRow (tappable)
│   │   │   └── ContextChipsRow
│   │   ├── OutstandingCard
│   │   │   ├── Label
│   │   │   ├── AmountLarge
│   │   │   ├── SubLine
│   │   │   └── HowCalculatedLink
│   │   ├── SectionCard "Personal"
│   │   ├── SectionCard "Address"
│   │   │   └── CopyAddressAction
│   │   ├── SectionCard "GPS"
│   │   │   ├── MapPreview
│   │   │   ├── OpenInMapsButton
│   │   │   └── UpdatePinLink
│   │   ├── SectionCard "Nominees" (list of NomineeRow)
│   │   ├── SectionCard "Proofs" (horizontal ProofThumbStrip)
│   │   └── TimelineSection
│   │       ├── TimelineHeader (title + filter chips)
│   │       └── For each day:
│   │           ├── DayDivider
│   │           └── ActivityRow ×N
│   └── BottomActionBar (persistent)
│       ├── CollectPaymentButton (primary)
│       ├── NewSaleButton (tonal)
│       └── EditCustomerButton (outlined)
```

---

## 8. Layout Structure

- Scroll: single vertical scroll for the whole page. Timeline is inside the same scroll (no nested scrollables).
- Screen padding: 16 dp horizontal, 12 dp between sections.
- Section cards: rounded 16 dp, elevation 0 (filled tonal container), 16 dp inner padding.
- Identity header: 24 dp top padding, avatar 96 dp diameter, 12 dp gap to name.
- Outstanding card: filled tonal with primary-container background, elevation 1, amount typographically dominant.
- Timeline row: 72 dp min height; day divider is 32 dp with sticky behavior.
- Bottom action bar: 88 dp tall including safe area; buttons min 56 dp height, equal-width row with the primary Collect button given 1.5× flex so it visually dominates.
- Bottom content padding: 96 dp so the last timeline row is never hidden behind the action bar.
- App bar collapses on scroll: hero avatar shrinks into a small avatar next to the title after 120 dp of scroll (single continuous transition, not a snap).

---

## 9. Component Specifications

### 9.1 IdentityHeader
- Avatar: 96 dp circle. Photo cropped center. Fallback initials on deterministic color.
- Name: display-small (28 sp), 600 weight, single line with ellipsis; wrap to two lines only when device font scale > 130%.
- Phone row: label prefix "Phone" (label-small, on-surface-variant), then formatted number (title-medium), then a phone icon on the right. Whole row is tappable.
- Context chips: label-small, on-surface-variant, wrap to a second line if needed.

### 9.2 OutstandingCard
- Background: primary-container.
- Label "Outstanding": label-medium, on-primary-container.
- Amount: 32–40 sp, 700 weight, tabular numerals, ₹ prefix.
- SubLine: label-small.
- HowCalculatedLink: text button with underline; opens bottom sheet.
- Long press on amount: copies value to clipboard with a snackbar "Amount copied".

### 9.3 SectionCard (Personal / Address / GPS / Nominees / Proofs)
- Title: title-small, 600, on-surface, 12 dp bottom padding.
- Rows inside use a two-column key/value pattern: key label-small on the left (min 96 dp width), value body-medium on the right, wrapping allowed.
- Trailing action icons (copy, edit) sized 40 dp touch target minimum.

### 9.4 MapPreview
- 160 dp tall.
- Shows a static map tile if online; else a placeholder with an icon and "Map unavailable offline. Open in Maps still works with saved coordinates."
- Rounded 12 dp corners.

### 9.5 NomineeRow
- Leading small avatar (initials).
- Name + relationship on line 1.
- Phone (tappable) on line 2.
- Trailing call icon.

### 9.6 ProofThumb
- 72 × 72 dp thumbnail, rounded 8 dp.
- Label below thumb (label-small).
- Tap opens the full-screen viewer with pinch-zoom, swipe between proofs, share (Owner).

### 9.7 ActivityRow
- Leading icon (rupee for collections, bag for sales), inside a 32 dp tonal circle, tinted by activity type.
- Line 1: type chip + note preview.
- Line 2: time · collector name (if not you).
- Trailing: amount, colored by type:
    - Payment / Partial Payment: success green.
    - Sale / Advance: primary blue.
    - Carry Forward: on-surface-variant grey (no amount, shows a dash and a reason chip).
- Tap → activity detail bottom sheet.

### 9.8 DayDivider
- Sticky within the timeline section.
- Content: "Today · 09 Jul", "Yesterday · 08 Jul", "Mon · 06 Jul".
- Right side shows day totals: "Collected ₹500 · Sold ₹12,000" (only shown if non-zero).

### 9.9 BottomActionBar
- Elevation 3, tonal surface, safe-area padded.
- Never scrolled off screen.
- Primary button: Collect Payment. Icon (wallet) + label. Min 56 dp height. Ripple + light haptic.
- Tonal button: New Sale. Icon (bag) + label.
- Outlined button: Edit Customer. Icon (pencil) + label.
- On very small widths, labels stack under icons rather than truncating.

### 9.10 Typography / Numbers
- Tabular numerals everywhere amounts appear.
- Indian numbering for all ₹ amounts.
- Zero outstanding shows "₹ 0" here (unlike the list view) because the user is looking at the specific customer and the exact number matters.

---

## 10. Loading State

- No cache: identity header shows skeleton avatar + name bar; Outstanding card shows a skeleton amount bar; each section shows 2–3 skeleton rows.
- With cache: content stays visible; a 2 dp linear progress bar appears under the app bar during refresh.
- Timeline: first page rendered from cache instantly; older pages fetched on demand with a footer spinner.
- Map preview loads asynchronously; placeholder with a subtle shimmer, never blocks the rest of the page.
- Any per-section load failure keeps the rest of the page usable.

---

## 11. Empty State

- No timeline activity: timeline section shows "No activity yet for this customer." with a subtle icon.
- No nominees: "No nominees added." Owner sees an inline "Add nominee" text button.
- No proofs: "No proof images uploaded." Owner sees an "Add proof" tile.
- No phone: phone row is hidden; a small "Add phone" text button appears in Personal (Owner and Collector limited edit).
- No GPS pinned: map preview replaced with "Location not set. Stand at the customer's home and tap Set location."
- Zero outstanding: Outstanding card still renders with "₹ 0" and sub-line "No dues".

---

## 12. Error State

### 12.1 Full-screen error (initial load failed, no cache)
- Centered illustration + "Couldn't load customer".
- Retry button (filled primary).
- Back button always available.

### 12.2 Partial section error
- Inline banner within the affected section: "Couldn't refresh {section}. Tap to retry."
- Other sections remain usable.

### 12.3 Offline
- Amber banner under the app bar: "Offline — last synced {time}."
- Collect Payment and New Sale remain enabled; activities queue locally and appear immediately in the timeline with an "Unsynced" pill.
- Outstanding card recalculates optimistically from local queue and shows sub-line "Includes unsynced activity".
- Map preview replaced with static placeholder; Open in Maps still works with cached coordinates.

### 12.4 Sync conflict
- If the server outstanding differs from local computation after sync, show a one-time snackbar: "Balance updated after sync." No blocking dialog.

### 12.5 Auth / permission
- Session expired → toast "Please sign in again" → Login.
- Camera / storage permission denied when adding proof: inline prompt inside the proof viewer.

---

## 13. Accessibility

- Touch targets min 48 dp; bottom action buttons 56 dp.
- Announce identity: "Owner Kumar, outstanding twelve thousand rupees, updated ten minutes ago."
- Amounts read as words (locale-aware) for screen readers.
- Every icon-only control has a content description.
- Semantic headings: customer name is H1; section titles are H2; day dividers are H3.
- Support text scaling to 200%; identity name and outstanding amount wrap rather than truncate.
- All type / status information carries an icon in addition to color (Carry Forward has a distinct arrow icon, not grey alone).
- Focus order: back → title → hero avatar → name → phone → outstanding card → each section top-to-bottom → timeline filters → each activity row → bottom bar (Collect → Sell → Edit).
- Haptics: light impact on primary tap; medium impact on Collect / Sell button press to signal a state change is starting.
- Read timeline items in a natural sentence: "Payment three hundred rupees at nine fifteen AM. Collected by you."

---

## 14. Navigation Rules

- Customer Details is a leaf of the explorer chain but a launchpad for Collection and Sale. It is never a layout / parent.
- Back always returns to the previous screen; if entered via deep link, the full explorer stack is rebuilt so back walks up naturally.
- Collect Payment / New Sale push their screens onto the stack; on completion they pop back here, the timeline updates immediately, and a subtle "New activity added" pulse highlights the new row.
- Edit Customer pushes a form; on save, the identity header and personal section update in place.
- Overflow → Delete (Owner) requires a confirmation dialog with the customer's name typed or a "hold to confirm" long-press control; on confirm, returns to Customer List.
- Tap-to-call is an external intent — the app is backgrounded, not the flow lost.
- Open in Maps is an external intent — same.
- Full-screen image viewer is a modal within the app; back closes only the viewer.

---

## 15. Edge Cases

1. Customer with 500+ activities → timeline loads the most recent 30, older on scroll with a footer spinner; day dividers still group correctly across pages.
2. Multiple activities same day → all shown under one day divider; day-total shown in the divider.
3. Duplicate collection accidentally entered → shows as its own row; there is no auto-merge. Owner can void from the activity detail sheet.
4. Outstanding becomes negative (over-collection) → shown as "₹ 0" with a sub-line "Advance credit ₹250 held". Never a negative red number.
5. Customer marked "Do not visit" → identity chip "Do not visit" appears; bottom action bar buttons are disabled with a tooltip "This customer is flagged. Contact the owner."; timeline remains fully visible.
6. Customer photo very large / rotated → downscale on the client to 512 px longest side; auto-orient via EXIF.
7. Nominee phone number matches the customer's phone → deduplicate visually; show a subtle "same as customer" hint.
8. Sale that includes both a paid product and a credit product → shown as one Sale row with a sub-line summarising both. Tap opens the sale detail sheet with per-item breakdown.
9. Product returned / refunded → appears as a Refund row in the timeline with a distinct icon; outstanding adjusts.
10. GPS pin far from the actual location (customer moved) → "Update pinned location" tap requires confirmation "Replace pinned location? This affects the route order."
11. Long name overflowing app bar → app bar shows first name + last initial; full name always visible in the hero.
12. Two collectors updating same customer simultaneously → optimistic UI shows latest local change; on sync, snackbar "Updated with latest changes" if server data differs.
13. Customer has no phone at all → phone row hidden; Call swipe on lists is disabled; add-phone prompt visible in Personal.
14. Very old customer with no activity in 6+ months → show a subtle chip "Inactive · 8 months" next to name.
15. Timeline crosses a year boundary → day divider format shifts to include the year ("Sat · 27 Dec 2025").
16. User deletes an activity while offline → local queue records the deletion; timeline hides it immediately; on sync, if the server rejects, restore the row with a snackbar "Couldn't delete. Try again."
17. Very large outstanding (7+ digits) → wraps to two lines in the card rather than shrinking type.
18. Substitute collector opens the screen → banner "You are covering for {Name} today"; timeline entries created by the substitute are tagged with their name.
19. Owner viewing a customer they don't collect → bottom actions still enabled but tagged "on behalf of {Collector}" beneath the button.
20. Address contains sensitive info the user wants to redact → not supported; owner can edit the address string directly.

---

## 16. Interaction Specifications

### 16.1 Tap
- Primary bottom buttons: 200 ms ripple + light haptic on down + medium haptic on release (signals action commitment).
- Section rows and timeline rows: standard ripple, light haptic on down.
- Debounce 500 ms on the primary bottom buttons to prevent double navigation.

### 16.2 Long press
- On outstanding amount: 400 ms → copy to clipboard, show snackbar.
- On a timeline row: 400 ms → context menu (View details, Share, Void — Owner only).
- On a proof thumb: 400 ms → context menu (View, Replace — Owner, Delete — Owner).

### 16.3 Swipe
- No horizontal swipe on timeline rows on this screen (swipes belong to the list view).
- Full-screen image viewer supports pinch to zoom and horizontal swipe between proofs.

### 16.4 Pull to refresh
- Threshold 80 dp; refreshes identity, outstanding, and timeline (first page) in a single coordinated fetch.
- Minimum spinner visible time: 400 ms.

### 16.5 Scroll behavior
- App bar collapses hero avatar into a small avatar next to the title after 120 dp scroll; continuous, not snapping.
- Day dividers stick to the top of the timeline as it scrolls.
- Bottom action bar never scrolls away.

### 16.6 Filter chip change (timeline)
- 150 ms fade of timeline content; day dividers recompute totals.
- Filter selection persists per customer for the session.

### 16.7 Bottom sheet transitions
- "How is this calculated?" sheet: standard modal bottom sheet, 300 ms slide.
- Activity detail sheet: modal bottom sheet with a drag handle; swipe down to dismiss.

### 16.8 Post-action feedback (returning from Collection / Sale)
- New timeline row inserts with a 200 ms fade + subtle background pulse (primary-container → transparent over 800 ms).
- Outstanding amount animates from previous value to new value over 400 ms.
- Snackbar at bottom (above the action bar): "Payment recorded" / "Sale recorded".

### 16.9 Timings
- First frame under 300 ms when opened from a cached list; interactive within 500 ms.
- Any action without visible change within 300 ms shows a progress indicator.
- Map tile can load up to 3 s before showing a fallback placeholder.

### 16.10 Sound
- No sound. Optional light haptic tick on successful copy-to-clipboard and on filter change.

---

End of Customer Details Screen specification.