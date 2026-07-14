# New Client (via "New Credit Sale" quick action) — Spec

## Trigger

- Dashboard → **Quick actions** → **"New Credit Sale"** button.
- Also reachable from `/inventory/$categoryId/$productId` "Sell on credit" action (future — flag but do not build yet).

## Purpose

Before recording a credit sale, the collector often needs to onboard a **brand-new customer** and place them on the route. This screen handles both in one flow:

1. Assign the customer to a **Weekday → Place → Area** slot in the route.
2. Capture the customer's own details.
3. Land the user on the new customer's `Sale` screen with the customer pre-selected.

If the customer already exists, this flow is the wrong entry point — the user should search for them from the Sale screen instead. (Add a "Existing customer? Search" link at the top of the form.)

## Route

`/customer/new` — full-screen form; **bottom nav hidden**, back returns to Dashboard.

Breadcrumb: `Dashboard › New Credit Sale`.

## Form sections

### Section 1 — Route placement

Three cascading pickers. Later pickers disabled until the previous one is chosen.

1. **Weekday** (required). Segmented control, 7 chips (`Sun`–`Sat`). Defaults to today.
2. **Place** (required). Dropdown filtered to places whose `weekday == selectedDay`. If empty, show inline link `+ Add new place` (opens a small nested sheet: place name → save).
3. **Area** (required). Dropdown filtered to areas of the selected place. Same `+ Add new area` fallback.

### Section 2 — Customer details

- **Full name** (required, ≤ 80 chars).
- **Phone** (required, 10 digits, India). Live-format `98765 43210`.
- **Alternate phone** (optional).
- **Address** (multiline, required, ≤ 240 chars).
- **Landmark** (optional).
- **Nominee name** (optional).
- **Nominee relation** (optional dropdown: Spouse / Parent / Child / Sibling / Other).
- **ID proof type** (optional dropdown: Aadhaar / Voter / DL / PAN / Other).
- **ID proof number** (optional, masked in list views).
- **Photo** (optional — v1 shows a stubbed camera button that just accepts a filename).
- **Opening balance** (optional, default `₹0`). If > 0, note reads "This will appear as a starting outstanding on the customer's ledger via a `CARRY_FORWARD_OPENING` activity — it does NOT reduce with future payments the way normal carry-forwards don't. Instead treat as an initial `SALE` with `credit_added = opening` and `advance = 0`, so the outstanding formula in AGENTS.md §2 stays correct."

  **Implementation rule:** Never bypass the outstanding formula. Opening balance is written as a synthetic sale row with `kind = "SALE"`, `saleType = "CREDIT"`, `items = []`, `total = opening`, `advance = 0`, `creditAdded = opening`, `note = "Opening balance"`.

### Section 3 — Consent / preferences (collapsed by default)

- Preferred visit time (chips: Morning / Afternoon / Evening / Anytime).
- SMS reminders (toggle, default on).

## Validation

- Route placement fully filled.
- Name, phone, address non-empty; phone matches `^[6-9]\d{9}$`.
- Opening balance ≥ 0 and ≤ ₹10,00,000.
- On any invalid field, focus scrolls to the first error and shows an inline message under the field.

## Actions

- **Primary — "Create & start sale":** writes new customer (+ optional opening-balance synthetic sale) to the mock repo, then `router.replace('/customer/$customerId/sale', { customerId: newId })`. Snackbar on the destination: "Customer added · UNDO" (UNDO deletes the new customer and pops back to the form with data preserved).
- **Secondary — "Create only":** same write, then navigates to `/customer/$customerId` (detail, not sale). Useful when the collector wants to just onboard without an immediate sale.
- **Cancel (X in header):** if dirty, snackbar-confirm "Discard new customer? UNDO", non-blocking.

## Sample data hook

`MockCustomerRepository.addCustomer(...)` returns a promise resolving to the new customer with a generated `id`. Wire the "add new place" and "add new area" sub-sheets to their own repo methods; all three are no-op stubs today but shaped so the future Supabase repo can implement them identically.

## Acceptance

- Opens from Dashboard quick action.
- Route pickers cascade correctly (choose Monday → only Monday's places show).
- All required-field validation fires before submit.
- On success, user lands on the new customer's Sale screen with customer name in the header.
- Opening balance (if any) shows in the customer's timeline as a synthetic `SALE` row and is included in outstanding.
- Bottom nav hidden throughout the flow.
- Hardware back = "Discard new customer?" snackbar, not silent dismiss.
