# Round 3 — Fixes & Enhancements

Authoritative fix-list for the next build cycle. Each item below is a **contract**: implement exactly, in both the web prototype (`src/`) and the Flutter app (per `design-skill.md`). When this file disagrees with earlier specs, **this file wins** and the older spec must be updated in the same PR.

**Before starting:** read `AGENTS.md` §2, §4, §5 and `MISTAKES.md`. Append a `MISTAKES.md` entry for every regression you catch during this round.

---

## Fix 1 — Transactions screen

Reference: `specs/transactions-spec.md` (update it after implementing).

Changes:

1. **Remove the "Today · N entries" subtitle.** Header shows only `Transactions` + a right-aligned sync/cloud icon (as today).
2. **Remove the breadcrumb bar** on this screen. Transactions is a top-level bottom-nav tab — no chain needed.
3. **Add a filter icon** (lucide `SlidersHorizontal`) at the right end of the sticky search bar (inside the same pill, trailing).
   - Tap opens a bottom sheet titled **Filters**.
   - Sheet contains a single **Date range** group with segmented chips: `Today` (default), `This week`, `This month`, `Custom…` (opens native date-range picker).
   - Sheet has `Reset` (ghost) and `Apply` (primary). Apply closes the sheet and updates the list.
4. **Kind filter chip row stays** (`All`, `Payments`, `Partial`, `Carry-forward`, `Sales`) — horizontally scrollable, directly under the search bar.
5. **Search + kind chip + date range must AND together** and must all be reflected in the URL (`?kind=payments&range=week`). Refresh preserves state.
6. **Empty state copy** updates to: "No transactions match these filters." with a `Clear filters` button that resets kind→All and range→Today.

Delete the "Sale type", "Route scope", and "Active filters bar" concepts from `transactions-spec.md` — they were over-scoped and are dropped for v1.

---

## Fix 2 — Inventory

Reference: `specs/inventory-spec.md` (update it after implementing).

### 2a. Breadcrumb visibility
- **Hide** the breadcrumb on `/inventory` (top-level tab, same rule as Transactions).
- **Show** the breadcrumb starting at `/inventory/$categoryId` and deeper:
  - `/inventory/$categoryId` → `Dashboard › Inventory › <Category>`
  - Product-expanded overlay → append `› <Product>` while the overlay is open.
- Every crumb tappable, resolves from URL params (same rule as `navigation-shell-spec.md` §4).

### 2b. Product card overflow (P1 visual bug)
Symptom (see `user-uploads://inventory_products.jfif`): product cards clip the price and stock badge — "BOTTOM OVERFLOWED BY 21 PIXELS".

Root cause: fixed card height with content that doesn't fit at the current font scale.

Fix:
- Card uses **intrinsic height**, not a fixed height. Layout: image (aspect 1:1, `min` of `width` and `160dp`) → name (2 lines max, ellipsis) → brand (1 line, muted) → price (semibold) → stock badge.
- Add `padding: 12dp` and `gap: 6dp` inside the card body.
- Grid uses `mainAxisSpacing: 12`, `crossAxisSpacing: 12`, and `childAspectRatio` **removed** — use `SliverGrid` with `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 200, mainAxisExtent: null)` and let content size itself. Web: CSS grid `grid-auto-rows: auto`, no fixed row height.
- Verify at text-scale 1.3× — nothing clips.

### 2c. "Add product" FAB visibility
- **Show the `+` FAB on the Categories page (`/inventory`)** as well, not just inside a category.
- Bottom-right, 16dp from right, 16dp above the bottom nav (so it never overlaps the nav pill).

### 2d. Add Product form (opened from FAB anywhere)
Bottom sheet (mobile, 90% height) / centered dialog (tablet). Fields, in order:

1. **Category** — dropdown of existing categories. Below the dropdown, a subtle link `+ Add new category`:
   - Tapping opens a small inline nested sheet: `Category name` (required, ≤ 40 chars) + `Icon` (pick from a 12-icon lucide grid: `Refrigerator`, `Shirt`, `Speaker`, `Lightbulb`, `Wind`, `Tv`, `WashingMachine`, `Microwave`, `Fan`, `Plug`, `Coffee`, `Package`). Save → new category is written to mock repo AND becomes the selected value in the parent form.
2. **Name** (required, ≤ 80).
3. **Brand** (required, ≤ 40).
4. **SKU** (required, monospace input, auto-suggested `<brand>-<name>` slug uppercased, editable).
5. **Price** (₹, positive, ≤ 10,00,000, live `en_IN` grouping).
6. **Stock** (integer ≥ 0, +/- steppers).
7. **Image** (optional — camera + gallery picker; v1 accepts filename stub).
8. **Description** (optional, multiline, ≤ 500).

Actions: `Add product` (primary), `Cancel` (ghost, dirty→snackbar UNDO).

Acceptance:
- FAB visible on both Categories and Products screens.
- Category dropdown lists existing + supports inline new category creation without leaving the form.
- Product card never overflows at any font scale.

---

## Fix 3 — New Credit Sale / New Client form

Reference: `specs/new-client-spec.md` (update it after implementing).

Changes:

1. **Add optional field `Location`** in the *Customer details* section, right after `Landmark`.
   - Label: `Location (optional)`.
   - Tappable tile that opens an inline **mini map picker** (~200dp tall) with a centered pin, draggable, and a `Use this location` primary button.
   - Web: Google Maps JavaScript API (or `react-leaflet` fallback if no key) inside a modal sheet.
   - Flutter: `google_maps_flutter` with a stub key + fallback static-map placeholder if the key is unset.
   - Store `{lat: number, lng: number, label?: string}`. Show the resolved address (reverse geocode; fallback to raw lat/lng) as the tile's subtitle once picked.
   - `Clear location` link appears once a value is set.

2. **Add optional field `ID proof document`** in the *Customer details* section, after `ID proof number`.
   - Tappable tile: `Attach ID proof (optional)`.
   - Tapping opens an action sheet with two options: **Take photo** (camera roll) and **Choose file** (file picker; accept `image/*, application/pdf`).
   - After capture/pick: show a thumbnail (or PDF icon + filename), file size, and a `Replace` / `Remove` menu.
   - Store `{filename, mimeType, sizeBytes, localUri}`. v1 keeps file locally; Supabase Storage upload is a stub.

3. **Remove `Opening balance` field entirely.**
   - Delete the field, its validation, and the synthetic-SALE write logic from the form.
   - Update `new-client-spec.md` to remove §Section 2 opening-balance bullet, the implementation rule paragraph, and the acceptance line about opening balance.
   - **Do not remove** the outstanding-formula rule from `AGENTS.md` §2 — that still applies to normal sales.

4. **Remove the entire `Section 3 — Consent / preferences` block.**
   - No preferred visit time chips. No SMS reminders toggle.
   - Update `new-client-spec.md` accordingly.

5. Primary CTA stays `Create & start sale`; secondary stays `Create only`. Both now write only the customer record (+ optional location + optional ID proof metadata).

---

## Fix 4 — Create & Start Sale (Sale screen)

Reference: `sale-spec.md` (update it after implementing).

### 4a. Breadcrumb is misleading
Current chain: `Dashboard › Monday › Place p-3 › Area a-4 › Client c-178394` — shows raw IDs.

Fix:
- Breadcrumb must use **human-readable labels** resolved from the mock/Drift repos:
  `Dashboard › <Weekday name> › <Place name> › <Area name> › <Customer name>`.
- Fallback while data loads: skeleton chip (not the raw ID).
- Same rule applied on Customer Detail, Collect, and any deeper screen.

### 4b. Customer card is misleading (tap → popup form)
Current: tapping the customer summary card at the top of the Sale screen navigates away / opens something confusing.

Fix:
- Tapping the customer card opens an **editable customer sheet** (bottom sheet, 85% height) with the same fields as the New Client form (name, phone, alt phone, address, landmark, location, nominee, ID proof + document).
- Sheet actions: `Save` (primary, writes to repo, snackbar UNDO) and `Cancel` (ghost).
- Sheet does **not** navigate — the user returns to the Sale screen with updated customer info in the header card.
- The card should show a subtle `Edit` affordance (pencil icon, top-right) to make the interaction discoverable.

### 4c. "Add item" — fix and enhance
Current: `+ ADD ITEM` opens a raw product catalog sheet with no search and rendering issues (see `user-uploads://add_item_credit_sale.jfif`).

Fix:
- Sheet title: `Select product`.
- **Add a sticky search bar** at the top of the sheet: searches product `name`, `brand`, `sku`.
- List row layout (fixes right-side overflow):
  - Left column (`Expanded`): `name` (semibold, 1 line ellipsis), then a secondary line `SKU · Brand · Stock N`.
  - Right column (fixed width `120dp`, right-aligned): price (`₹` + `en_IN`), and if `stock == 0`, an `OUT OF STOCK` red pill under the price.
  - Never wrap the price. Never overflow horizontally.
- Out-of-stock rows: greyed out and non-tappable.
- Tapping a row: closes the sheet and pushes a `Line item` inline editor onto the Sale screen with:
  - `Quantity` (integer ≥ 1, +/- steppers, default 1).
  - `Unit price` (pre-filled from catalog, editable ≤ catalog price × 1.5 with an inline warning if edited).
  - `Line total` (derived, read-only).
- `Save item` adds it to the Line Items list; `Cancel` discards.

Acceptance:
- Product selection sheet has working search and no overflow.
- Editing a line item is possible from the Line Items list (tap a row → same editor).
- Financial calculations panel recomputes live as items change.

---

## Fix 5 — Profile tab = Client Search / Full Client Detail

This replaces the "Coming soon" stub for `/profile` set in `specs/navigation-shell-spec.md`.

### 5a. Profile tab (`/profile`)
- Rename the tab label from `Profile` to **`Clients`** (keep the same icon `User`, or switch to `Users`).
- Update `navigation-shell-spec.md` tab table.
- Screen layout:
  - Header: `Clients` (blended with page bg like Dashboard).
  - Sticky **search bar** with placeholder `Search by name, phone, or address`.
  - Optional filter chip row: `All`, `<Weekday>` (7 chips, horizontal scroll), `Has outstanding`.
  - Below: virtualized list of matching customers with:
    - Avatar/initials.
    - Name (semibold).
    - `<Weekday> · <Place> · <Area>` (muted).
    - Outstanding amount (right-aligned, `₹` + `en_IN`, red if > 0, muted `₹0` otherwise).
  - Row tap → `/customer/$customerId` (the full detail screen described in §5b).

### 5b. Customer Detail screen — full editable profile
Reachable from **two entry points** and must render identically in both:
- `/customer/$customerId` from the Clients tab (breadcrumb: `Dashboard › Clients › <Customer>`).
- `/customer/$customerId` from the route drill-down (breadcrumb: `Dashboard › <Weekday> › <Place> › <Area> › <Customer>`).

Sections, top to bottom:

1. **Identity card** (existing — name, phone, current outstanding).
2. **Route placement** — Weekday / Place / Area, each with an `Edit` affordance that opens the same cascading picker used in New Client.
3. **Contact & address** — phone, alternate phone, address, landmark. Inline-editable (tap a row → edit sheet).
4. **Location** — mini map preview (~180dp tall) rendered from stored `{lat, lng}`. Tap → opens the same map picker as New Client for editing. Empty state: `+ Add location`.
5. **Nominees (multiple)** — a list of nominee entries. Each: `Name`, `Relation`, `Phone (optional)`. `+ Add nominee` button below. Each row swipe/menu → `Edit` / `Delete`.
   - Update the customer model to store `nominees: Nominee[]` (array), not a single nominee.
   - Data migration for mock repo: existing single `nominee` fields collapse into `nominees[0]`.
6. **ID proofs (multiple)** — list of `{type, number, documentFile?}`. Each row shows type, masked number, and a thumbnail if a document exists. Tap thumbnail → full-screen preview (pinch-zoom for images, PDF viewer for PDFs). `+ Add ID proof` button.
7. **Timeline** (existing — unified activity stream). No changes.

Every field is editable inline via a bottom sheet; every save writes to the mock repo with snackbar UNDO. No modal confirmations.

### 5c. Model changes (mock + Flutter)
```ts
type Nominee = { id: string; name: string; relation?: string; phone?: string };
type IdProof = {
  id: string;
  type: 'Aadhaar' | 'Voter' | 'DL' | 'PAN' | 'Other';
  number: string;                // stored raw, rendered masked
  document?: { filename: string; mimeType: string; sizeBytes: number; localUri: string };
};
type Location = { lat: number; lng: number; label?: string };

type Customer = {
  // ...existing fields
  location?: Location;
  nominees: Nominee[];           // was: nominee?: ...
  idProofs: IdProof[];           // was: idProofType/idProofNumber
};
```

Update `MockCustomerRepository` seed data so at least 3 customers have location, 2 have multiple nominees, 1 has multiple ID proofs — so the UI is visibly populated.

---

## Cross-cutting rules for this round

- **Do not touch business logic** (§2 of AGENTS.md) — this round is UI/UX only, plus small model additions (location, nominees[], idProofs[]).
- **Google Maps key**: read from `import.meta.env.VITE_GOOGLE_MAPS_API_KEY` (web) or `--dart-define=GOOGLE_MAPS_API_KEY=...` (Flutter). If unset, render a static placeholder tile with a `Configure Google Maps` note — never crash.
- **File uploads**: v1 stores files locally only; add `// TODO: upload to Supabase Storage` comments at the write site.
- **Every regression** you notice from earlier rounds → append to `MISTAKES.md` (do not silently fix and forget).

## Delivery order

1. **PR-A** — Fix 1 (Transactions) + Fix 2 (Inventory overflow + FAB + Add Product form). Ship together, tightly scoped visual/interaction work.
2. **PR-B** — Fix 4 (Sale screen breadcrumb, editable customer card, Add item search + line editor).
3. **PR-C** — Fix 3 (New Client form: location + ID proof, remove opening balance and preferences) + Model changes for `location`, `nominees[]`, `idProofs[]`.
4. **PR-D** — Fix 5 (Clients tab + full editable Customer Detail). Depends on PR-C's model changes.

Update `specs/transactions-spec.md`, `specs/inventory-spec.md`, `specs/new-client-spec.md`, `specs/navigation-shell-spec.md`, `sale-spec.md`, and `collection-spec.md` as you go — never let the older specs contradict this file.
