# design-skill.md

**Skill name:** `field-collect-flutter-ui`
**Purpose:** Orchestrate an AI coding agent to build the complete UI/UX of the Field Credit Collection & Home Appliance Sales Management app in **Flutter**, wired to **mock/sample data** with **placeholder functions** where Supabase/PostgreSQL will later plug in.
**Audience:** A capable coding agent (Claude/Cursor/Copilot-class) that can execute multi-file scaffolds, follow structural rules, and self-verify.
**Non-goals:** Real Supabase integration, real auth, migrations, RLS, or sync engine. Those are stubbed behind interfaces so a follow-up skill can replace them 1:1.

---

## 0. Mission Statement (read this first, every turn)

You are building a **field-first, offline-first, one-thumb** Flutter app for substitute collectors who walk door-to-door in Tamil Nadu with cheap Android phones in bright sunlight. Every screen must answer **one question in under 3 seconds** and let the user complete **one action in under 15 seconds**. Optimize for:

1. **Clarity over cleverness** — big numbers, big taps, high contrast.
2. **Speed of data entry** — quick chips, smart defaults, minimum keystrokes.
3. **Offline correctness** — every write goes local-first; a `SyncStatus` widget shows state.
4. **Business truthfulness** — one running outstanding balance per customer; never per-product EMIs.

If a design decision conflicts with any of the above, **the above wins**.

---

## 1. Golden Rules (never violate)

| # | Rule |
|---|------|
| G1 | **One running balance per customer.** Never model per-product EMIs. |
| G2 | `CARRY_FORWARD` **never** changes outstanding. Only `PAYMENT` and `PARTIAL_PAYMENT` reduce it. |
| G3 | `Sale Type` is **derived**, not chosen: `credit_added == 0 → READY`, else `CREDIT`. |
| G4 | Every user-facing amount uses `₹` prefix + `en_IN` grouping (12,00,000 not 1,200,000). |
| G5 | Every screen works fully offline; network is a **status indicator**, never a blocker. |
| G6 | No hardcoded colors in widgets — use `AppColors` / `Theme.of(context)`. |
| G7 | No screen may exceed **400 LOC**. Extract widgets to `widgets/` subfolder. |
| G8 | Every list must have **loading**, **empty**, and **error** states. No exceptions. |
| G9 | Supabase code lives behind repository interfaces; UI never imports `supabase_flutter` directly. |
| G10 | Sample data lives in `lib/data/mock/`; seeding SQL lives in `supabase/seed/` as placeholders. |

---

## 2. Tech Stack (fixed)

- **Flutter** ≥ 3.24, Dart ≥ 3.5
- **State:** `flutter_riverpod` ^2.5
- **Routing:** `go_router` ^14
- **Local DB (stubbed now):** `drift` ^2.20 — interface only, in-memory impl for prototype
- **Remote (stubbed now):** `supabase_flutter` ^2.5 — behind repository interface, mock impl returns sample data
- **Forms:** `flutter_hooks` + `reactive_forms` ^17 (optional; plain controllers acceptable)
- **Fonts:** `google_fonts` — **Plus Jakarta Sans** (display) + **Space Grotesk** (numeric)
- **Icons:** `lucide_icons` (via `lucide_icons_flutter`) — no Material default icons for primary actions
- **Localization scaffold:** `flutter_localizations` + `intl` (English + Tamil placeholder ARB)
- **Utilities:** `intl` for `NumberFormat.currency(locale: 'en_IN', symbol: '₹')`
- **No** getx, no bloc, no provider (v3), no auto_route.

---

## 3. Project Structure (create exactly this)

```
lib/
├── main.dart
├── app.dart                          # MaterialApp.router, theme, locale
├── core/
│   ├── theme/
│   │   ├── app_colors.dart           # semantic tokens (see §4)
│   │   ├── app_typography.dart
│   │   ├── app_spacing.dart          # 4/8/12/16/20/24/32
│   │   ├── app_radius.dart           # 8/12/16/24/full
│   │   └── app_theme.dart            # ThemeData light + dark
│   ├── router/
│   │   ├── app_router.dart           # GoRouter config
│   │   └── routes.dart               # route name constants
│   ├── utils/
│   │   ├── formatters.dart           # rupees(), dateShort(), relativeTime()
│   │   ├── haptics.dart
│   │   └── result.dart               # sealed Result<T, E>
│   └── widgets/                       # reusable primitives
│       ├── amount_text.dart
│       ├── avatar.dart
│       ├── stat_card.dart
│       ├── tag_chip.dart
│       ├── sync_status_indicator.dart
│       ├── app_scaffold.dart          # top bar + safe area + bottom action bar slot
│       ├── section_header.dart
│       ├── empty_state.dart
│       ├── error_state.dart
│       ├── loading_skeleton.dart
│       └── confirm_snackbar.dart
├── data/
│   ├── models/                        # freezed models mirroring DB tables
│   │   ├── weekday.dart
│   │   ├── place.dart
│   │   ├── area.dart
│   │   ├── customer.dart
│   │   ├── product.dart
│   │   ├── sale.dart
│   │   ├── sale_item.dart
│   │   ├── collection.dart
│   │   ├── activity.dart              # sealed union of Collection|Sale
│   │   └── outstanding.dart
│   ├── mock/
│   │   ├── mock_weekdays.dart
│   │   ├── mock_places.dart
│   │   ├── mock_areas.dart
│   │   ├── mock_customers.dart
│   │   ├── mock_products.dart
│   │   ├── mock_sales.dart
│   │   ├── mock_collections.dart
│   │   └── mock_repository.dart       # implements all repository interfaces in-memory
│   └── repositories/                  # ABSTRACT interfaces only
│       ├── customer_repository.dart
│       ├── route_repository.dart
│       ├── collection_repository.dart
│       ├── sale_repository.dart
│       └── product_repository.dart
├── features/
│   ├── dashboard/
│   │   ├── dashboard_screen.dart
│   │   ├── controllers/dashboard_controller.dart
│   │   └── widgets/{hero_outstanding_card,weekday_scroller,todays_places_list,quick_actions_row}.dart
│   ├── route/
│   │   ├── weekday_screen.dart
│   │   ├── place_screen.dart
│   │   ├── area_screen.dart
│   │   └── widgets/{place_tile,area_tile,customer_tile,route_progress_bar}.dart
│   ├── customer/
│   │   ├── customer_detail_screen.dart
│   │   ├── controllers/customer_detail_controller.dart
│   │   └── widgets/{customer_context_card,activity_timeline,timeline_entry_tile,today_activity_strip}.dart
│   ├── collection/
│   │   ├── collect_screen.dart
│   │   └── widgets/{outcome_segmented_selector,amount_input_field,quick_amount_chips,new_outstanding_preview,quick_note_chips,save_collection_button}.dart
│   ├── sale/
│   │   ├── sale_screen.dart
│   │   ├── product_picker_sheet.dart
│   │   └── widgets/{line_items_section,advance_section,derived_summary_block,line_item_tile}.dart
│   └── sync/
│       └── widgets/pending_sync_badge.dart
└── l10n/
    ├── app_en.arb
    └── app_ta.arb                     # Tamil placeholders

supabase/
├── seed/
│   ├── 001_schema_placeholder.sql     # `-- TODO: real schema` + table stubs
│   ├── 002_sample_data.sql            # INSERTs mirroring mock data
│   └── README.md                      # how future seeding will plug in
└── functions/
    └── .keep                          # placeholder for future edge functions
```

**Enforcement:** After scaffolding, the agent must `flutter analyze` clean and `dart format .`.

---

## 4. Design System

### 4.1 Color Tokens (`app_colors.dart`)

Warm paper background + deep teal primary + currency green + marigold warn + vermilion danger. **No generic Material blue.**

```dart
// Light
background      = Color(0xFFF8F5EE);   // warm off-white paper
foreground      = Color(0xFF1B1F2A);
surface         = Color(0xFFFFFFFF);
primary         = Color(0xFF0F5D6B);   // deep teal
primaryFg       = Color(0xFFF2FBFC);
accent          = Color(0xFFF2C88C);   // warm sand accent
success         = Color(0xFF1F8A5B);   // currency green
warning         = Color(0xFFD98A2B);   // marigold
warningFg       = Color(0xFF3A2408);
danger          = Color(0xFFC0392B);   // vermilion overdue
muted           = Color(0xFFEFEBE1);
mutedFg         = Color(0xFF6C6F78);
border          = Color(0xFFE3DED2);

// Dark mirrors these with L flipped; same hues.
```

Expose via `extension AppColorsX on ColorScheme` OR a `Theme.of(context).extension<AppColors>()`. **Never** use raw `Colors.*` in feature code.

### 4.2 Typography

- Display: `GoogleFonts.plusJakartaSans` — weights 400/500/600/700
- Numeric: `GoogleFonts.spaceGrotesk` with `fontFeatures: [FontFeature.tabularFigures()]`
- Sizes: `display=32/28`, `headline=22/20`, `title=17`, `body=15`, `caption=12`, `overline=11`
- Currency always uses numeric font, letter-spacing `-0.02em`.

### 4.3 Spacing / Radius / Elevation

- Spacing scale: 4, 8, 12, 16, 20, 24, 32
- Radius: `sm=8`, `md=12`, `lg=16`, `xl=24`, `full=999`
- Elevation: only two tiers — `card=1`, `sheet=6`. No fake neumorphism.

### 4.4 Component Conventions

- **Primary CTA:** 56 dp height, `radius.lg`, filled `primary`, weight 700, uppercase optional. Bottom-anchored inside `AppScaffold.bottom`.
- **Amount input:** `keyboardType: TextInputType.number`, digits only, ₹ prefix icon, right-aligned, 28sp numeric font.
- **Chips row:** horizontally scrollable, 44 dp min tap target, gap 8.
- **List tiles:** min 72 dp height (thumb-friendly), leading avatar 44 dp, trailing chevron only when navigable.
- **Bottom sheet:** for pickers; drag handle, safe-area padded.

### 4.5 Motion

- Page transitions: platform default (Cupertino on iOS, fade+slide on Android).
- Micro-interactions: 150 ms ease-out on chip select, 200 ms on segmented switch.
- Success haptic (`HapticFeedback.lightImpact`) on every Save.

---

## 5. Data Model & Sample Data

### 5.1 Models (freezed)

Every model mirrors a DB table 1:1. Include `fromJson/toJson`. Use `DateTime` for timestamps, `int` (paise) internally? — **No**, use `int` rupees for prototype simplicity; add `// TODO: switch to paise` comment.

Sealed `Activity`:

```dart
sealed class Activity {
  final String id;
  final DateTime at;
}
class PaymentActivity extends Activity { final int amount; final String? note; }
class PartialPaymentActivity extends Activity { final int amount; final String note; }
class CarryForwardActivity extends Activity { final String note; }
class SaleActivity extends Activity { final List<SaleItem> items; final int total; final int advance; final int creditAdded; }
```

### 5.2 Mock Repository

`MockRepository` implements every repo interface, holds `List<T>` in memory, mutates on write, exposes `Stream<T>` via `StateNotifier` so Riverpod rebuilds. Seeded from the const lists in `lib/data/mock/`.

Sample data must include:
- 7 weekdays, 4 places, 5 areas, 8 customers (mix of ₹0, small, large, overdue outstanding).
- 6 products (one out-of-stock).
- ≥ 12 activities across 3 customers so timelines look real.
- One customer (`c-1` "Lakshmi Priya") has same-day multiple collections to exercise `TodayActivityStrip`.

Use the exact sample data from `src/lib/prototype-data.ts` in this repo as source of truth; port names, phones, amounts verbatim.

### 5.3 Supabase Seeding Placeholders

`supabase/seed/001_schema_placeholder.sql`:
```sql
-- TODO(seed): replace with authoritative schema from spec docs.
-- Tables: weekdays, places, areas, users, products, customers,
--         customer_nominees, customer_proofs, sales, sale_items,
--         collections, inventory_transactions.
-- Views:  customer_outstanding_view, customer_activity_view,
--         product_stock_view, route_summary_view,
--         customer_route_view, customer_dashboard_view.
```

`supabase/seed/002_sample_data.sql`: INSERTs generated from mock data (agent must emit them; each row 1:1 with the Dart mock).

`SupabaseCustomerRepository` etc. must exist as **empty class stubs** with `UnimplementedError('wire in follow-up skill')` in every method, so the file compiles and the DI switch is a one-liner.

---

## 6. Screens (build in this order)

Each screen entry lists: **Purpose · Route · Key widgets · States · Interactions · Sample copy**.

### S1 · Dashboard
- **Route:** `/`
- **Purpose:** In 2 seconds, tell the collector: how much money is out, what today's route is, and give a one-tap start.
- **Widgets:** `HeroOutstandingCard` (gradient teal, huge ₹ number, overdue tag, unsynced count) · `WeekdayScroller` (7 pill chips, today highlighted) · `TodaysPlacesList` · `QuickActionsRow` (Collect / New Sale).
- **States:** loading skeleton for hero; empty ("Enjoy the day off") when no places today.
- **Interactions:** tap weekday → `/weekday/:day`; tap place → `/place/:id`; quick action → customer picker.

### S2 · Weekday
- **Route:** `/weekday/:day`
- **Purpose:** Pick a place inside the selected weekday.
- **Widgets:** header with weekday name, list of `PlaceTile` (name, area count, ~customer count, outstanding sum, progress bar of collected today).

### S3 · Place
- **Route:** `/place/:placeId`
- **Purpose:** Pick an area inside the place.
- **Widgets:** `AreaTile` list, top summary strip (total outstanding, collected today, pending customers).

### S4 · Area
- **Route:** `/area/:areaId`
- **Purpose:** Pick a customer.
- **Widgets:** search field, `CustomerTile` list sorted by (overdue desc, outstanding desc). Each tile: avatar, name, phone, outstanding amount, last activity, overdue tag. Empty state when zero customers.

### S5 · Customer Detail
- **Route:** `/customer/:customerId`
- **Purpose:** Full context + unified timeline + two primary actions.
- **Widgets:** `CustomerContextCard` (avatar, name, phone tap-to-call, huge outstanding, overdue tag) · `TodayActivityStrip` (only if ≥1 today) · `ActivityTimeline` grouped by day, entries typed per §5.1 · sticky bottom bar with **Collect** + **New Sale** buttons.
- **Interactions:** tap phone → `launchUrl('tel:...')`; timeline entry expands to show note; long-press → future "edit last".

### S6 · Collect (spec source: `collection-spec.md`)
- **Route:** `/customer/:id/collect`
- **Widgets:** pinned `CustomerContextCard` · `OutcomeSegmentedSelector` (PAYMENT / PARTIAL / CARRY FWD) · `AmountInputField` (hidden when CARRY) · `QuickAmountChipsRow` (100/200/500/1000/FULL) · `NewOutstandingPreviewRow` (live) · `QuickNoteChipsRow` + `NoteTextField` (required for PARTIAL & CARRY) · `SaveCollectionButton` + `SyncStatusIndicator`.
- **Validation:** mode-specific; disable Save until valid.
- **On save:** write to mock repo → haptic → snackbar "Saved · Outstanding ₹X" with UNDO (5s) → pop back to Customer Detail.

### S7 · Sale (spec source: `sale-spec.md`)
- **Route:** `/customer/:id/sale`
- **Widgets:** pinned `CustomerContextCard` · `LineItemsSection` (add via `ProductPickerBottomSheet`) · `AdvanceSection` (numeric input, max = sale total) · `DerivedSummaryBlock` (Sale Total, Credit Added, New Outstanding, Sale Type badge) · `NoteTextField` · `DateTimeRow` (default now, editable) · sticky Save.
- **Product Picker:** searchable bottom sheet from `mock_products`; out-of-stock disabled with tag; same product can be added N times.
- **Validation:** ≥1 line item; advance ≤ total.
- **On save:** create SaleActivity + decrement mock stock → haptic → snackbar → back.

### S8 · Sync Status (surfaces, not a full screen)
- Everywhere top-right: `SyncStatusIndicator` (Synced / Offline / N pending). Backed by a `syncStateProvider` that in mock mode returns a rotating fake status every 10s so the UI can be seen.

---

## 7. Routing

`go_router` tree:
```
/                                    → Dashboard
/weekday/:day                        → Weekday
/place/:placeId                      → Place
/area/:areaId                        → Area
/customer/:customerId                → CustomerDetail
/customer/:customerId/collect        → Collect
/customer/:customerId/sale           → Sale
```
- Use `ShellRoute` only if a bottom nav is added later; for v1 no bottom nav — the flow is linear back-stack.
- Type-safe route helpers in `routes.dart`: `Routes.customer(id)`, `Routes.collect(id)`, etc.

---

## 8. State Management Pattern

- One `AsyncNotifierProvider` per screen; controllers live in `features/*/controllers/`.
- Repositories exposed as `Provider<CustomerRepository>` bound to `MockCustomerRepository` in `main.dart`; swap to Supabase impl later via a single override.
- No `ChangeNotifier`. No global singletons except `ProviderScope`.
- Derived values (`newOutstanding`, `creditAdded`, `saleType`) are **computed in the controller**, never in the widget.

---

## 9. Accessibility & Field Usability

- Minimum tap target: **48 dp** (56 dp for primary CTA).
- Text contrast: WCAG AA against `background` and `surface` — verify programmatically if possible.
- Support system font scale up to 130% without breaking layouts (use `Flexible`, avoid fixed heights on text).
- Every icon-only button has `tooltip` + `Semantics(label:)`.
- All amounts spoken as "₹ five hundred" via `Semantics(label: rupees(500))`.
- Keyboard: numeric fields open number pad, not full QWERTY.

---

## 10. Offline & Sync UX (mock)

- All writes appear immediately in UI; a `pendingCount` provider increments.
- After a 3-second delay in mock mode, decrement `pendingCount` to simulate sync success.
- Add `PendingSyncBadge` to Dashboard hero and every screen's top bar.
- Never block save on network. Never show a spinner longer than 200 ms for local writes.

---

## 11. Copy Guidelines

- Tone: warm, brief, action-first. English default; Tamil ARB stubs `// TODO translate`.
- Never say "Error occurred". Say "Couldn't save — tap to retry".
- Never say "Loading…". Show a skeleton.
- Empty states are humane: "No dues here 🌿" / "Enjoy the day off".

---

## 12. Delivery Order (agent must follow)

1. **Bootstrap**: `flutter create`, add deps, wire `main.dart` with `ProviderScope` + Riverpod overrides pointing at mock repos.
2. **Theme + core widgets** (§4 + `core/widgets/`).
3. **Models + mock data + mock repository** (§5).
4. **Router** (§7).
5. **Screens** in order S1 → S7. After each screen: `flutter analyze`, take a screenshot in the widget test harness (`golden_toolkit` optional), commit.
6. **Supabase placeholder files** (§5.3) — last, so the app already runs end-to-end.
7. **README.md** at repo root explaining: how to run, how to swap MockRepository for SupabaseRepository, where seed SQL lives.

---

## 13. Definition of Done

- [ ] `flutter run` on a fresh clone shows the Dashboard with real sample data.
- [ ] All 7 screens navigable; back stack behaves.
- [ ] Collect + Sale write to mock repo and the Customer Detail timeline updates live.
- [ ] `flutter analyze` = 0 issues; `dart format` clean.
- [ ] No `Colors.*` or hex literals in `features/`.
- [ ] No `supabase_flutter` import outside `data/repositories/supabase_*` stubs.
- [ ] `supabase/seed/*.sql` files exist with clear TODOs and sample INSERTs.
- [ ] README documents the mock→real swap in ≤ 10 lines.

---

## 14. Anti-Patterns (reject on sight)

- Bottom navigation bar (flow is linear this release).
- Modal dialogs for confirmation on save (use snackbar + UNDO).
- Per-product EMI tracking anywhere.
- `setState` in a screen that already has a Riverpod controller.
- `FutureBuilder` at screen root (use `AsyncValue.when`).
- Generic Material purple, generic Roboto, generic outlined text fields.
- Any screen > 400 LOC.
- Silent catch blocks.

---

## 15. Hand-off Note to Follow-up "Supabase Wiring" Skill

When the next skill runs:
1. Implement `SupabaseCustomerRepository` etc. against real tables listed in workspace knowledge.
2. Replace mock overrides in `main.dart` — **one line change per repo**.
3. Replace `supabase/seed/001_schema_placeholder.sql` with authoritative schema + RLS + GRANTs (per workspace rules).
4. Wire Drift for offline mirror; `MockRepository` becomes the fallback for tests only.
5. Do **not** touch any file under `features/` — the UI must remain untouched.

---

**End of skill. Execute §12 top-to-bottom. Verify §13 before reporting done.**
