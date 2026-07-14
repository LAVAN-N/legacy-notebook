# Transactions Module — Spec

Reached from:
- Bottom nav tab **Transactions** (`/transactions`).
- Dashboard's "Recent transactions" section — a **"View all →"** link/button in the section header.

Same underlying data as the Dashboard's recent section, just full-history with search + filters.

## Data model

A "Transaction" is a **union** row over the customer timeline — mirrors the Customer Detail timeline in `collection-spec.md` / `sale-spec.md` but flattened across all customers:

```ts
type Transaction =
  | { kind: "PAYMENT";          id; at; customerId; customerName; amount; note?; areaId; placeId; weekday }
  | { kind: "PARTIAL_PAYMENT";  id; at; customerId; customerName; amount; note?; ... }
  | { kind: "CARRY_FORWARD";    id; at; customerId; customerName; note;    ... }
  | { kind: "SALE";             id; at; customerId; customerName; saleType: "READY" | "CREDIT"; total; advance; creditAdded; items: string[]; ... }
```

Sort default: `at DESC`.

Currency formatting: `₹` + `en_IN` grouping. Never `$`.

## Screen layout

- **Header:** title "Transactions" only, with a right-aligned sync/cloud icon. No subtitles.
- **Sticky search bar:** searches customer name, note text, product name inside sale items.
  - Contains a trailing filter icon (e.g. `Icons.tune`).
  - Tapping the filter icon opens a **Filters** bottom sheet.
    - Sheet contains a single **Date range** group with segmented chips: `Today` (default), `This week`, `This month`, `Custom…` (opens native date-range picker).
    - Sheet has `Reset` (ghost) and `Apply` (primary) buttons.
- **Filter row (horizontal scroll of chips):**
  - Kind: `All`, `Payments`, `Partial`, `Carry-forward`, `Sales`.
  - Sits directly below the search bar.
- **List (virtualized):** one row per transaction:
  - Left: type icon in a tinted circle (green = payment, amber = partial, gray = carry-forward, teal = sale).
  - Middle: customer name (semibold, 1 line), then a secondary line:
    - Payments: `Payment · <place>, <area>` + optional note.
    - Sale: `<Ready|Credit> sale · <n> items · +<credit_added>` when credit > 0.
    - Carry-forward: the note verbatim.
  - Right: amount in currency style. Sales show total; payments show amount; carry-forward shows `—`.
  - Under the row (small, muted): relative time (`2h ago`, `Yesterday`, `12 Jul`).
- **Row tap** → deep-links to `/customer/$customerId` and scrolls its timeline to this exact activity (anchor by `id`).

## Empty / loading / error

- Empty (no transactions match): centered illustration + "No transactions match these filters." + `Clear filters` button that resets kind→All and range→Today.
- Loading: 8 skeleton rows.
- Error: retry button.

## Dashboard "View all" wiring

- In the Dashboard's Recent Transactions card, add a right-aligned `View all` action that pushes to `/transactions`.
- Preserve filter state in the URL (`?kind=payments&range=week`) so deep-links and back-nav are stable.
- Search + kind chip + date range must AND together.

## Acceptance

- Full list is virtualized (smooth on 1000+ rows).
- Search + filters combine (AND logic between filter groups).
- URL reflects filter state; refresh preserves it.
- Tapping a row lands on the correct customer with the correct activity highlighted.
- Bottom nav visible; no breadcrumbs on this screen (it is a top-level tab).
- Currency, offline, and one-balance rules from AGENTS.md §2 respected.
