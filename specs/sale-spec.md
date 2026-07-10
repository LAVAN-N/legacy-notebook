# Sale Screen — Implementation Specification

Field Credit Collection & Home Appliance Sales Management System
Platform: Android Mobile Application · Design System: Material 3

---

## 1. Purpose

Allow a collector (or substitute collector) standing at a customer's doorstep to record a home-appliance sale — either a **READY SALE** (fully paid on the spot) or a **CREDIT SALE** (part advance, remainder added to the customer's running outstanding) — in under 45 seconds, offline, with the customer's balance updated correctly the instant the sale is saved.

The screen must:

- Add one or more products to the sale
- Capture price, advance received, and derive credit added
- Update the customer's single running outstanding balance
- Produce exactly one sale record + one activity in the unified timeline
- Deduct stock from inventory (via a linked `inventory_transactions` write)
- Work fully offline

---

## 2. Primary User

- **Collector** — completes the sale at the customer's doorstep after showing/demonstrating the product
- **Substitute Collector** — unfamiliar with the customer; needs full context (photo, name, current outstanding) visible so they don't misjudge how much credit to extend
- **Owner** — occasionally records store-walk-in sales from the same screen
- Users may be elderly and not highly technical

---

## 3. Entry Points

| From | Trigger |
|---|---|
| Customer Details screen | "Add Sale" bottom action |
| Collection Screen success snackbar | Optional "Save & New Sale" secondary action |
| Customer list (Area → Customer) | "New Sale" quick action on customer row |
| Route flow: Dashboard → Weekday → Place → Area → Customer | Tapping customer then Add Sale |

The screen always opens with a specific customer already selected. There is no customer search inside this screen.

---

## 4. Exit Points

| Exit | Destination |
|---|---|
| Successful save | Success confirmation → back to Customer Details (timeline + outstanding refreshed) |
| Back button / top app bar back | Customer Details (discard-confirmation if any product added or amount entered) |
| "Save & Collect" (optional secondary flow) | Collection Screen for same customer with updated outstanding |

---

## 5. Information Displayed

### Customer Context Header (always visible, non-scrolling)
- Customer photo (circular avatar, 48dp; initials fallback)
- Customer name (prominent)
- Phone number with tap-to-call icon
- **Current Outstanding** — the single running balance before this sale
    - Source: `customer_outstanding_view`
    - Purpose: helps the collector judge credit risk before adding more credit

### Sale Composition Area
- Line items (each product added)
- Sale Total = SUM(line item prices)
- Advance Received (single field for the whole sale, not per product)
- **Credit Added** = Sale Total − Advance (auto-calculated, read-only)
- **New Outstanding** = Current Outstanding + Credit Added (live preview)
- Sale type badge auto-derived: READY when Credit Added = ₹0, CREDIT otherwise

### Product Picker (invoked from Sale Composition Area)
- Searchable list from `products` table with live stock (`product_stock_view`)
- Each row: product name, price, stock available
- Out-of-stock items shown but disabled with "Out of stock" label

### Form Meta
- Date/time: defaults to now; displayed read-only
- Notes field (optional, e.g., delivery instructions, serial number)

---

## 6. Actions

| Action | Result |
|---|---|
| Tap "Add Product" | Opens Product Picker bottom sheet |
| Select product | Adds line item at product's default price |
| Edit line item price | Inline editable; recomputes Sale Total live |
| Remove line item | Swipe-to-delete with undo snackbar |
| Enter Advance | Numeric keypad only; live Credit Added + New Outstanding preview |
| Tap "Full Payment" chip | Fills Advance = Sale Total → makes it a READY sale |
| Tap "Zero Advance" chip | Sets Advance = ₹0 → full credit sale |
| Tap "Save Sale" | Validates → persists locally (offline-first) → queues sync → success feedback → navigates back |
| Tap phone icon | Opens device dialer |
| Back | Discard confirmation if dirty |

---

## 7. Widget Hierarchy

```text
SaleScreen
├── TopAppBar
│   ├── BackButton
│   └── Title: "New Sale"
├── CustomerContextCard (pinned)
│   ├── Avatar (photo / initials)
│   ├── NameText
│   ├── PhoneRow (number + call IconButton)
│   └── CurrentOutstandingBlock
│       ├── Label: "Current Outstanding"
│       └── AmountText (₹)
├── ScrollableFormArea
│   ├── LineItemsSection
│   │   ├── LineItemRow × n
│   │   │   ├── ProductName
│   │   │   ├── PriceField (inline editable, ₹ prefix)
│   │   │   └── RemoveIconButton
│   │   └── AddProductButton ("＋ Add Product")
│   ├── SaleTotalRow (label + amount, read-only)
│   ├── AdvanceSection
│   │   ├── AdvanceInputField (₹ prefix, numeric)
│   │   └── QuickAdvanceChipsRow ("Zero" · "₹500" · "₹1000" · "₹2000" · "Full")
│   ├── DerivedSummaryBlock
│   │   ├── CreditAddedRow (label + amount, read-only)
│   │   ├── NewOutstandingRow (label + amount, emphasized)
│   │   └── SaleTypeBadge ("READY SALE" / "CREDIT SALE")
│   ├── NoteSection
│   │   └── NoteTextField (multiline, optional)
│   └── DateTimeRow (read-only, "Now · 08 Jul, 6:12 PM")
└── BottomActionBar (pinned)
    ├── SaveSaleButton (primary, full-width, 56dp)
    └── SyncStatusIndicator (offline badge when unsynced)

ProductPickerBottomSheet (modal)
├── SearchField
└── ProductList
    └── ProductRow × n (name · price · stock · disabled if out of stock)
```

---

## 8. Layout Structure

- **Top app bar**: standard Material 3 small top app bar.
- **Customer context card**: pinned below app bar; never scrolls away — the substitute collector must always see who they're selling to and their current outstanding.
- **Form area**: single-column scrollable; line items at top, advance/summary below; keyboard-aware (scrolls so Advance field + New Outstanding preview stay visible above keyboard).
- **Bottom action bar**: pinned; primary button full-width; safe-area padded.
- **Product picker**: modal bottom sheet (≥ 60% screen height, drag-dismissible), not a separate route — preserves sale-in-progress state.
- One screen, no tabs, no horizontal navigation.

---

## 9. Component Specifications

### LineItemRow
- Product name (2 lines max, ellipsized).
- Price field: inline editable, ₹ prefix, digits-only, defaults to product's catalog price; editing is per-sale and does not change the catalog.
- Remove: leading swipe reveals delete; also a trailing icon button for discoverability.
- Minimum 56dp row height.

### AddProductButton
- Full-width outlined button; opens ProductPickerBottomSheet.
- Always visible at the bottom of the line-items list.

### ProductPickerBottomSheet
- Opens at ~70% height; search field auto-focused.
- Rows show: product name, current price, stock count.
- Out-of-stock rows dimmed and non-tappable with "Out of stock" chip.
- Tapping a row appends it as a line item and closes the sheet.
- Same product can be added multiple times (business allows selling multiple units).

### AdvanceInputField
- ₹ prefix, digits-only soft keyboard, whole rupees.
- Font size ≥ 24sp.
- Auto-focused after the first product is added.
- Live-drives CreditAddedRow, NewOutstandingRow, and SaleTypeBadge on every keystroke.

### QuickAdvanceChipsRow
- Chips: **Zero** (₹0 — full credit), ₹500, ₹1000, ₹2000, **Full** (fills exact Sale Total → READY sale).
- Tapping replaces current advance. 40dp min height, horizontally scrollable.

### DerivedSummaryBlock
- **Credit Added**: amber tint when > 0, green when 0. Read-only.
- **New Outstanding**: largest number in this block (≥ 28sp), always emphasized — this is the number the customer will owe after the sale.
- **Sale Type Badge**: pill; green "READY SALE" when Credit Added = ₹0, amber "CREDIT SALE" otherwise. Switches live.

### NoteTextField
- Optional. 2-line multiline, sentence capitalization. Cap ~200 characters with counter appearing at 160.

### SaveSaleButton
- Label reflects derived sale: "Save Ready Sale ₹3,000" / "Save Credit Sale · Adds ₹10,000".
- Disabled until form is valid (≥ 1 line item, advance ≥ ₹0 and ≤ Sale Total unless overpayment allowed — see Edge Cases).
- On tap: single instantaneous local write; button shows brief spinner ≤ 500ms; **never blocks on network**.

### SyncStatusIndicator
- Small badge: "Saved on device — will sync" when offline; "Synced" when confirmed.
- Never phrased as an error; offline is normal operation.

---

## 10. States

### Loading State
- Customer context card shows skeleton (avatar, name bar, outstanding bar).
- Form renders immediately; AddProductButton enabled; Save disabled until customer outstanding loads (from local DB — near-instant even offline).

### Empty State
- Line items list empty by default; shows placeholder text "Add the first product to start this sale" with an arrow toward AddProductButton.
- Advance and summary blocks are hidden until at least one line item exists (reduces visual noise).

### Error State
- **Save failure (local write)**: inline error banner "Could not save. Try again." — retry keeps all input.
- **Sync failure**: silent; item stays in sync queue with badge. Never a blocking error.
- **Validation errors**: inline near the offending control (e.g., "Add at least one product", "Advance can't exceed Sale Total"). Never a dialog.
- **Product picker: no results**: friendly empty state "No products match '…'" with a cleared search suggestion.

---

## 11. Accessibility

- All touch targets ≥ 48×48dp; primary button 56dp; product picker rows 56dp.
- Sale Total, Credit Added, and New Outstanding: high-contrast, ≥ 24sp, readable in sunlight.
- Content descriptions on avatar ("Customer photo, Lakshmi"), call button, add-product button, and each line item's remove control ("Remove Washing Machine from sale").
- Support system font scaling up to 200% without layout breakage (form scrolls; bottom bar stays pinned).
- Color never sole signal — sale type uses badge text + icon; warnings use icon + text.
- Announce save success via accessibility event ("Credit sale saved. ₹10,000 added to outstanding.").

---

## 12. Interaction Specifications

### Derivation rules (live, on every input change)
- `Sale Total = SUM(line_item.price)`
- `Credit Added = max(0, Sale Total − Advance)`
- `New Outstanding = Current Outstanding + Credit Added`
- `Sale Type = READY when Credit Added == 0, else CREDIT`

### Field behavior
| Field | Rule |
|---|---|
| Line items | ≥ 1 required to enable Save |
| Line item price | > 0 required; blank field = validation error on that row |
| Advance | ≥ ₹0; ≤ Sale Total by default (overpayment/advance-for-future blocked here — collectors use the Collection screen for pure advances against no product) |
| Note | Optional |

### Save flow
1. Validate per rules above.
2. Write sale record + sale_items to local store (Drift/SQLite) with customer id, collector id, timestamp, sale total, advance, financed_amount = Credit Added.
3. Write matching `inventory_transactions` rows (one per line item) to decrement stock.
4. Enqueue sync to backend.
5. Haptic tick + success snackbar: "Sale saved · Outstanding now ₹22,000".
6. Navigate back to Customer Details; timeline shows the new Purchase entry at top; outstanding header updated.

### Speed targets
- Common credit sale (1 product + advance chip + save): **5 taps**.
- Ready sale (1 product + Full advance chip + save): **4 taps**.

---

## 13. Navigation Rules

- Reached only with a customer in context; deep links without a valid customer redirect to Dashboard.
- Back with dirty form (≥ 1 line item OR advance entered) → discard confirmation dialog ("Discard this sale?" · Keep editing / Discard).
- After save → always return to Customer Details, so the collector sees the updated outstanding and the new Purchase entry in the timeline.
- Double-tap protection on Save (button disables immediately on first tap) to prevent duplicate records.
- Product picker dismissal does not discard the in-progress sale.

---

## 14. Edge Cases

| Case | Behavior |
|---|---|
| Same product added twice | Allowed (two units); each appears as its own line item so per-unit price can be edited independently. |
| Line item price edited to differ from catalog | Allowed; catalog unchanged. Sale reflects the negotiated price. |
| Advance > Sale Total | Blocked with inline validation "Advance can't exceed sale total. For pure advance, use Collect Payment." — guides the user to the correct workflow. |
| Advance = Sale Total | Sale Type flips to READY; Credit Added = ₹0; New Outstanding = Current Outstanding (unchanged). |
| Advance = ₹0 | Full credit sale; entire Sale Total added to outstanding. |
| Customer already heavily indebted | No block — decision is human. Current Outstanding is prominently shown so the collector can judge. |
| Product out of stock | Cannot be added from picker (disabled row). If stock reaches 0 mid-composition (another device synced), show inline warning on the line item and allow save (stock reconciled offline-first). |
| Offline entirely | Full functionality; stock counts from local mirror; badge shows unsynced state. |
| App killed mid-entry | Draft not persisted (sale entry takes under a minute); acceptable loss — matches Collection Screen behavior. |
| Customer photo missing | Initials avatar; never a broken-image placeholder. |
| Zero line items but user taps Save | Save disabled; inline hint on AddProductButton "Add at least one product". |
| Very long product name | 2-line ellipsis in line item; full name shown in picker. |

---

## 15. Business Rules Enforced by This Screen

1. **One running balance** — a sale never creates a per-product EMI schedule. It adds `Credit Added` (= Sale Total − Advance) to the customer's single outstanding.
2. **READY vs CREDIT is derived, not chosen** — the collector never picks a sale type; it follows from whether Advance equals Sale Total.
3. **Advance ≤ Sale Total** on this screen — pure advance against no product belongs on the Collection Screen as a PAYMENT on zero outstanding.
4. **Stock deducts atomically with the sale** — saving a sale writes both the sale record and matching inventory_transactions in the same local transaction.
5. Every save produces exactly one Purchase entry in the customer's unified history timeline, showing product(s), Advance, and Credit Added.
