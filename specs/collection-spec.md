# Collection Screen — Implementation Specification

Field Credit Collection & Home Appliance Sales Management System
Platform: Android Mobile Application · Design System: Material 3

---

## 1. Purpose

Allow a collector (or substitute collector) standing at a customer's doorstep to record the outcome of a collection visit in under 15 seconds:

- Record a **PAYMENT** (full or any amount)
- Record a **PARTIAL_PAYMENT** with a revisit note
- Record a **CARRY_FORWARD** (no payment) with a reason note

The screen must reduce the customer's running outstanding balance correctly, work fully offline, and require minimal typing.

---

## 2. Primary User

- **Collector** — daily field use, outdoors, one-handed, often in bright sunlight
- **Substitute Collector** — unfamiliar with customers; needs full context (photo, name, outstanding) visible without navigating away
- Users may be elderly and not highly technical

---

## 3. Entry Points

| From | Trigger |
|---|---|
| Customer Details screen | "Collect Payment" bottom action |
| Customer list (Area → Customer) | "Collect" quick action on a customer row |
| Route flow: Dashboard → Weekday → Place → Area → Customer | Tapping customer then Collect Payment |

The screen always opens with a specific customer already selected. There is no customer search inside this screen.

---

## 4. Exit Points

| Exit | Destination |
|---|---|
| Successful save | Success confirmation → back to Customer Details (timeline refreshed) |
| Back button / top app bar back | Customer Details (discard-confirmation if form has input) |
| "Save & New Sale" (optional secondary flow) | Sale screen for same customer |

---

## 5. Information Displayed

### Customer Context Header (always visible, non-scrolling)
- Customer photo (circular avatar, 48dp; initials fallback)
- Customer name (prominent)
- Phone number with tap-to-call icon
- **Total Outstanding** — the single running balance, largest number on screen
    - Source: `customer_outstanding_view`
    - Formula reminder (business rule): Outstanding = SUM(sales.financed_amount) − SUM(collections where type IN PAYMENT, PARTIAL_PAYMENT). CARRY_FORWARD never affects balance.

### Today's Activity Strip (conditional)
- If the customer already has collection activities today, show them compactly:
    - "Today 09:00 AM · Partial Payment ₹200 · Will arrange by evening"
- Reinforces that multiple activities per customer per day are allowed and expected.

### Form Area
- Outcome selector (Payment / Partial Payment / Carry Forward)
- Amount entered (Payment & Partial Payment only)
- **Live "New Outstanding" preview**: Outstanding − Amount, updates as the user types
- Note field with quick-note chips
- Date/time: defaults to now; displayed read-only (owner-only edit is out of scope for this screen)

---

## 6. Actions

| Action | Result |
|---|---|
| Select outcome type | Switches form mode (see §12 Interaction) |
| Enter amount | Numeric keypad only; live new-outstanding preview |
| Tap quick-amount chip | Fills amount field |
| Tap quick-note chip | Fills/append note |
| Tap "Save Collection" | Validates → persists locally (offline-first) → queues sync → success feedback → navigates back |
| Tap phone icon | Opens device dialer |
| Back | Discard confirmation if dirty |

---

## 7. Widget Hierarchy

```text
CollectionScreen
├── TopAppBar
│   ├── BackButton
│   └── Title: "Collect Payment"
├── CustomerContextCard (pinned)
│   ├── Avatar (photo / initials)
│   ├── NameText
│   ├── PhoneRow (number + call IconButton)
│   └── OutstandingBlock
│       ├── Label: "Outstanding"
│       └── AmountText (₹, extra-large)
├── TodayActivityStrip (conditional)
│   └── ActivityChip × n (time · type · amount · note)
├── ScrollableFormArea
│   ├── OutcomeSegmentedSelector
│   │   ├── Option: Payment
│   │   ├── Option: Partial Payment
│   │   └── Option: Carry Forward
│   ├── AmountSection (hidden for Carry Forward)
│   │   ├── AmountInputField (₹ prefix, numeric)
│   │   ├── QuickAmountChipsRow (₹100 · ₹200 · ₹500 · ₹1000 · Full)
│   │   └── NewOutstandingPreviewRow
│   ├── NoteSection
│   │   ├── QuickNoteChipsRow
│   │   │   ├── "Come next week"
│   │   │   ├── "Will arrange by evening"
│   │   │   ├── "Customer not available"
│   │   │   ├── "Visit after 7 PM"
│   │   │   └── "At work"
│   │   └── NoteTextField (multiline, optional/required per mode)
│   └── DateTimeRow (read-only, "Now · 08 Jul, 6:12 PM")
└── BottomActionBar (pinned)
    ├── SaveCollectionButton (primary, full-width, 56dp)
    └── SyncStatusIndicator (offline badge when unsynced)
```

---

## 8. Layout Structure

- **Top app bar**: standard Material 3 small top app bar.
- **Customer context card**: pinned below app bar; never scrolls away — the substitute collector must always see who they're collecting from and the outstanding amount.
- **Form area**: single-column scrollable; all controls within thumb reach; keyboard-aware (scrolls so amount field + new-outstanding preview stay visible above keyboard).
- **Bottom action bar**: pinned; primary button full-width; safe-area padded.
- One screen, no tabs, no horizontal navigation.

---

## 9. Component Specifications

### OutcomeSegmentedSelector
- Three large segmented buttons, minimum 48dp height, equal widths.
- Icons + labels: ✓ Payment · ◐ Partial · → Carry Fwd.
- Default selection: **Payment** (most common outcome).
- Selection changes form instantly; no confirmation.

### AmountInputField
- ₹ prefix, digits-only soft keyboard (`number` input), no decimals unless business uses paise (default: whole rupees).
- Font size ≥ 28sp; auto-focus when Payment/Partial selected.
- Max: no hard cap (overpayment allowed — see Edge Cases), but warn visually when amount > outstanding.

### QuickAmountChipsRow
- Chips: ₹100, ₹200, ₹500, ₹1000, and **Full** (fills exact outstanding).
- Tapping replaces current amount. 40dp min height, horizontally scrollable if needed.

### NewOutstandingPreviewRow
- "New Outstanding: ₹X" recalculated on every keystroke.
- Green tint when it reaches ₹0; amber warning when negative (overpayment).

### QuickNoteChipsRow
- Predefined notes (see hierarchy). Tap = fills note field (replace; long-press = append).
- Chips reduce typing to near zero for the common cases.

### NoteTextField
- Optional for Payment.
- **Required for Carry Forward** (reason must be recorded).
- Recommended (prompted but not blocking) for Partial Payment.
- 2-line multiline, sentence capitalization.

### SaveCollectionButton
- Label changes with mode: "Save Payment ₹500" / "Save Partial ₹200" / "Save Carry Forward".
- Disabled until form is valid.
- On tap: single instantaneous local write; button shows brief spinner ≤ 500ms; **never blocks on network**.

### SyncStatusIndicator
- Small badge: "Saved on device — will sync" when offline; "Synced" when confirmed.
- Never phrased as an error; offline is normal operation.

---

## 10. States

### Loading State
- Customer context card shows skeleton (avatar circle, two text bars, amount bar).
- Form renders immediately with outcome selector enabled; Save disabled until outstanding loads (from local DB — should be near-instant even offline).

### Empty State
- Not applicable in the usual sense (screen always has a customer).
- If outstanding = ₹0: header shows "No Outstanding" in green; Payment/Partial still allowed (advance/booking money is possible), with an informational line "Customer has no outstanding balance."

### Error State
- **Save failure (local write)**: inline error banner "Could not save. Try again." — retry keeps all input.
- **Sync failure**: silent; item stays in sync queue with badge. Never shown as a blocking error on this screen.
- **Validation errors**: inline under the field (e.g., "Enter an amount" / "Add a reason for carry forward"). Never a dialog.

---

## 11. Accessibility

- All touch targets ≥ 48×48dp; primary button 56dp.
- Outstanding amount and new-outstanding preview: high-contrast, ≥ 28sp, readable in sunlight (avoid low-contrast greys).
- Content descriptions on avatar ("Customer photo, Lakshmi"), call button ("Call 98765…"), and each outcome segment.
- Support system font scaling up to 200% without layout breakage (form scrolls; bottom bar stays pinned).
- Color is never the sole signal — outcome types use icon + label; warnings use icon + text.
- Announce save success via accessibility event ("Payment of ₹500 saved").

---

## 12. Interaction Specifications

### Mode behavior
| Mode | Amount | Note | Save label |
|---|---|---|---|
| Payment | Required, > 0 | Optional | "Save Payment ₹X" |
| Partial Payment | Required, > 0 | Prompted | "Save Partial ₹X" |
| Carry Forward | Hidden, forced ₹0 | **Required** | "Save Carry Forward" |

- Switching modes preserves entered amount/note (so accidental toggles lose nothing); Carry Forward hides the amount but retains its value if the user switches back.

### Save flow
1. Validate per mode table.
2. Write collection record to local store (Drift/SQLite) with type, amount, note, timestamp, customer id, collector id.
3. Enqueue sync to backend.
4. Haptic tick + success snackbar: "₹500 collected · New outstanding ₹11,500".
5. Navigate back to Customer Details; timeline shows the new activity at top.

### Speed targets
- Common case (Payment + quick-amount chip + save): **3 taps**.
- Carry Forward (chip note + save): **3 taps**.

---

## 13. Navigation Rules

- Reached only with a customer in context; deep links without a valid customer redirect to Dashboard.
- Back with dirty form → discard confirmation dialog ("Discard this collection?" · Keep editing / Discard).
- After save → always return to Customer Details (not the customer list), so the collector sees the updated outstanding and timeline.
- Double-tap protection on Save (button disables immediately on first tap) to prevent duplicate records.

---

## 14. Edge Cases

| Case | Behavior |
|---|---|
| Multiple collections same day | Fully allowed; Today's Activity Strip shows prior entries so the collector has context (e.g., morning partial, evening payment). |
| Amount > outstanding (overpayment) | Allowed (advance against future purchase) but shows amber warning "Amount exceeds outstanding by ₹X — continue?" inline; Save requires the same tap, no dialog. |
| Outstanding = ₹0 | Screen still usable; informational note shown; Carry Forward on zero balance allowed (visit record). |
| Amount = ₹0 with Payment/Partial selected | Blocked with inline validation; suggest switching to Carry Forward. |
| Offline entirely | Full functionality; outstanding computed from local data; badge shows unsynced state. |
| Stale outstanding (another device synced) | Show last-synced timestamp subtly under outstanding; balance reconciles after sync — never block collection. |
| Rapid consecutive saves for same customer | Allowed (matches business reality); each is a separate activity. |
| App killed mid-entry | Draft not persisted (entry takes seconds); acceptable loss. |
| Customer photo missing | Initials avatar; never a broken-image placeholder. |
| Very long note | Note field caps at ~200 characters with counter appearing at 160. |

---

## 15. Business Rules Enforced by This Screen

1. **One running balance** — the screen never shows or asks for a per-product/EMI allocation. A payment always reduces the single customer outstanding.
2. **CARRY_FORWARD never changes the balance** — it is a visit record with a mandatory reason.
3. **PAYMENT and PARTIAL_PAYMENT both reduce outstanding by the entered amount** — the distinction is workflow intent (revisit expected), not accounting.
4. Every save produces exactly one collection activity in the customer's unified history timeline.
