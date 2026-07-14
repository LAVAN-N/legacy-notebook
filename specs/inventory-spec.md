# Inventory Module — Spec

Reached from bottom-nav tab **Inventory** (`/inventory`).

## Information architecture

```
/inventory                        → Categories grid
/inventory/$categoryId            → Products grid within category
/inventory/$categoryId/$productId → (deep-link only; on tap we expand in place — see §Card expansion)
```

Breadcrumb chain (per `navigation-shell-spec.md`):

- **Hide** the breadcrumb on `/inventory` (top-level tab).
- **Show** the breadcrumb starting at `/inventory/$categoryId` and deeper:
  - `/inventory/$categoryId` → `Dashboard › Inventory › <Category>`
  - Product-expanded overlay → append `› <Product>` while the overlay is open.

## Data (sample only for v1)

Extend `src/lib/prototype-data.ts` (and mirror in Flutter `lib/data/mock/`):

```ts
type Category = {
  id: string;
  name: string;             // "Kitchen Appliances"
  icon: string;             // lucide name
  productCount: number;     // derived
};

type Product = {
  id: string;
  categoryId: string;
  name: string;             // "Preethi Mixer Grinder 750W"
  sku: string;              // "PRT-MG-750"
  brand: string;
  price: number;            // ₹ base price
  stock: number;
  imageUrl?: string;        // placeholder ok
  description?: string;
  createdAt: string;        // ISO
};
```

Seed at least 5 categories × 4-8 products each.

## Screen 1 — Categories (`/inventory`)

- **Header:** title "Inventory", subtitle "<n> categories · <m> products".
- **Search bar** (sticky under header): searches across categories AND products by name/brand/sku. Match on product jumps to that product's expanded card in its category page.
- **Filter chip row:** `All`, `In stock`, `Low stock (<5)`, `Out of stock`. Chips filter product counts shown on category cards.
- **Grid:** 2 columns on mobile, 3 on tablet. Category card:
  - Icon in a tinted square (`primary/10` bg, `primary` fg).
  - Category name (semibold).
  - `<n> products` (muted).
  - Tap → `/inventory/$categoryId`.
- **"+ Add new item" button:** floating action button, bottom-right above the bottom nav. Opens the Add Product sheet (see §Add Product form).

## Screen 2 — Products in category (`/inventory/$categoryId`)

- **Header:** category name; back to `/inventory`.
- **Search bar:** searches products within this category (name/brand/sku).
- **Filter chip row:** `All`, `In stock`, `Low stock`, `Out of stock`, sort chip (`Newest`, `Price ↑`, `Price ↓`, `Name A-Z`).
- **Grid:** 2 columns. Product card uses **intrinsic height** (no fixed aspect ratio):
  - Image (aspect 1:1, `min` of `width` and `160dp`)
  - Name (2 lines max, ellipsis)
  - Brand (1 line, muted)
  - Price (semibold, currency style `₹` prefix, `en_IN` grouping)
  - Stock badge: green `In stock`, amber `Low`, red `Out`
  - Padding `12dp` and gap `6dp` inside the card body.
  - Grid uses `mainAxisSpacing: 12`, `crossAxisSpacing: 12`, and `childAspectRatio` removed. Content must not clip at 1.3x text scale.
- **"+ Add new item" button:** floating action button, bottom-right above the bottom nav. Opens the Add Product sheet (see §Add Product form).

### Card expansion (the "elevate + blur" interaction)

Tapping a product card must:

1. Blur + dim the rest of the screen (`backdrop-blur-md`, dark overlay 40%).
2. Animate the tapped card to the **vertical center** of the viewport (spring, 320 ms).
3. Expand it to `min(92vw, 480dp)` wide × auto height.
4. Reveal the **editable detail form** inside the same card:
   - Image (tap to replace — stub in v1).
   - Name (text input).
   - Brand (text input).
   - SKU (text input, monospace).
   - Price (numeric, `₹` prefix live-formatted).
   - Stock (numeric, +/- steppers).
   - Description (multiline).
   - Category (dropdown — allows moving to another category).
5. Bottom of the card: `Cancel` (ghost) and `Save` (primary).
6. Tapping outside the card, pressing Esc, or hardware back closes the expansion (with a diff-check: if dirty, snackbar "Discard changes? UNDO", non-blocking).
7. Save → local-first write to the mock/Drift product repo → snackbar "Saved · UNDO" → card animates back into the grid.

## Add Product form

Opened from the `+` FAB anywhere. Bottom sheet on mobile (90% height) / centered dialog on tablet.
Fields, in order:
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

## Acceptance

- FAB visible on both Categories and Products screens.
- Category dropdown lists existing + supports inline new category creation without leaving the form.
- Product card never overflows at any font scale.
- Search on Categories screen finds both categories and products.
- Card-expand animation is smooth (no jank on mid-range Android).
- Edits and adds persist to the mock repo and survive navigation away/back (until app restart in v1).
- All prices render `₹` + `en_IN` grouping.
- Loading / empty (no products in category) / error states all present.
- Breadcrumbs hidden on Categories, shown correctly on Products.
