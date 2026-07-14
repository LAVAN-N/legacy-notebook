# Feature Specs — Round 2

Per-feature contracts for the next build cycle. Each file is authoritative for its screen/feature. When a spec disagrees with `<workspace-knowledge>` in the system prompt, workspace-knowledge wins.

**Read order for any agent picking this up:**

1. `AGENTS.md` (§2 business rules, §4 stack traps)
2. `design-skill.md` (folder layout, theming, widgets, delivery order)
3. The relevant spec below
4. `collection-spec.md` / `sale-spec.md` for parity of tone/format

## Specs in this round

| # | File | Scope |
|---|------|-------|
| 1 | `splash-spec.md` | Splash screen at app entry (no loader) |
| 2 | `theme-toggle-spec.md` | Light/Dark theme toggle on Dashboard |
| 3 | `navigation-shell-spec.md` | Blended header, floating bottom nav, back-to-exit on Dashboard, breadcrumb back-nav bug fix |
| 4 | `inventory-spec.md` | Inventory: Categories → Products with expanding-card details |
| 5 | `transactions-spec.md` | Transactions list screen with search + filters, deep-link from Dashboard "View all" |
| 6 | `new-client-spec.md` | "New Credit Sale" quick action → New-Client form (day/place/area + details) |
| 7 | `fixes-round-3.md` | **Round 3 fixes** — Transactions filters, Inventory overflow + Add Product, New Client (location + ID doc, remove opening balance), Sale editable customer + product search, Clients tab (full editable profile). **Overrides earlier specs where they conflict.** |

## Global rules for this round

- **Bottom nav (v1 of it, replacing the `design-skill.md` "no bottom nav" rule):** 4 tabs — **Dashboard, Inventory, Transactions, Profile**. Floating pill shape, rounded, sitting slightly above the safe-area bottom, blur/frosted surface. Never overlaps content — screens use `bottom-padding = navHeight + 16`.
- **Header/nav blend:** Dashboard header background matches the page background (no visible divider). Elevation only appears once the user scrolls > 8px.
- **Back button (system/hardware):** On the Dashboard route, back **exits the app**. On every other route it navigates **up the actual crumb chain** (see `navigation-shell-spec.md`), never to "today".
- **Breadcrumbs:** Every screen below Dashboard renders a chain: `Dashboard › <Weekday> › <Place> › <Area> › <Customer>`. Each crumb is tappable and pops **to that exact ancestor**, not to today.
- **All new forms:** local-first write (mock repo now, Drift + Supabase later). Snackbar + UNDO on save. No modal confirmation dialogs.
- **Currency, offline, one-balance rules from AGENTS.md §2 still apply.**
