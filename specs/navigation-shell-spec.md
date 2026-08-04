# Navigation Shell — Spec

Covers four related concerns that all touch `AppShell` / router:

1. Header blends with Dashboard background.
2. Floating rounded bottom navigation bar.
3. Hardware/system back on Dashboard exits the app.
4. **Bug fix:** back-navigation from a non-today weekday jumps to today. Must go to the actual parent in the chain.

---

## 1. Header ↔ Dashboard blend

- On the Dashboard route (and **only** there), the sticky header uses the **same background token** as the page (`background`, not `background/95 backdrop-blur`).
- No bottom `border-b` on the header while `scrollY <= 8`. Once `scrollY > 8`, fade in the border and a subtle backdrop-blur over 150 ms.
- On all other routes, header keeps the current elevated look (there's a real content break there).
- Implementation:
  - Web: extend `AppShell` with a `blend?: boolean` prop. Dashboard passes `blend`. Internally use a scroll listener + `data-scrolled` attribute.
  - Flutter: `SliverAppBar` with `elevation: 0`, `scrolledUnderElevation: 2`, `backgroundColor: Theme.of(context).colorScheme.background`.

---

## 2. Floating bottom navigation bar

**Overrides** the `design-skill.md` "no bottom nav in v1" rule. Add a `MISTAKES.md` entry noting the reversal.

### Shape
- Pill/rounded-rectangle, `border-radius: 28dp`.
- Height: `64dp` content + safe-area inset.
- Sits **12dp above** the bottom safe-area (floats, does not touch the edge).
- Horizontal margin: `16dp` left and right.
- Surface: `surface` token at 92% opacity + backdrop blur 20px. Border: 1px `border` token.
- Elevation: soft shadow `0 8 24 rgba(0,0,0,0.12)`.

### Tabs (exactly 4, in order)

| Icon (lucide) | Label | Route |
|---|---|---|
| `LayoutDashboard` | Dashboard | `/` |
| `Package` | Inventory | `/inventory` |
| `Receipt` | Transactions | `/transactions` |
| `User` | Profile | `/profile` (stub screen: "Coming soon") |

### Rules

- Active tab: filled icon + `primary` color + label bold.
- Inactive: outline icon + `muted-foreground`.
- Tap = replace navigation (does NOT push onto stack) — never grows the back stack via tab switching.
- Bottom nav is hidden on:
  - Splash screen.
  - Any `*.collect` / `*.sale` sub-route (focus mode).
  - Any full-screen form (New Client, Add Product).
- Every screen that shows the bar must reserve `padding-bottom = 96dp` at the bottom of its scroll container so content is never hidden.

---

## 3. Back-to-exit on Dashboard

- On the Dashboard route, pressing hardware/system back **exits the app** instead of popping.
- Guard rail: a "Press back again to exit" snackbar on the first back press; second back within 2 s exits.
- Flutter: `PopScope` (or `WillPopScope` on older SDKs) on the Dashboard screen.
- Web prototype: no-op (browser back is user-controlled) — document in the file that this rule is Flutter-only.

On every non-Dashboard route, hardware back **must** pop to the previous crumb (see §4).

---

## 4. Breadcrumb / back-nav bug fix (P1)

### Observed bug
From the Dashboard, user taps a weekday other than today (say **Monday**) → sees Monday's places → taps a place → then presses the back arrow. **Currently:** jumps to today's (Thursday's) weekday page. **Expected:** returns to **Monday's** weekday page.

### Root cause
The Weekday route is being computed from `new Date()` on remount instead of from the URL. `AppShell`'s back button is set to `{ to: "/weekday/$day" }` with `params` derived from "today" rather than from the actual referrer/URL segment.

### Rule for every screen

- **The back target is derived from the current URL**, never from `Date.now()` or "today".
- Every screen below Dashboard passes an explicit `back={{ to, params }}` that reconstructs the parent using the current route's own params:

| Current route | Back target |
|---|---|
| `/weekday/$day` | `/` (Dashboard) |
| `/place/$placeId` | `/weekday/$day` where `$day = place.weekday` |
| `/area/$areaId` | `/place/$placeId` where `$placeId = area.placeId` |
| `/customer/$customerId` | `/area/$areaId` where `$areaId = customer.areaId` |
| `/customer/$customerId/collect` | `/customer/$customerId` |
| `/customer/$customerId/sale` | `/customer/$customerId` |

### Breadcrumbs (visible chain)

Every screen below Dashboard renders a crumb bar under the title:

```
Dashboard › Monday › Village B › South Colony › Owner K.
```

- Each crumb is a `<Link>` with the correct `to` + `params` derived like the table above.
- Current crumb is not a link (styled `text-foreground/80`).
- Crumb bar horizontally scrolls if it overflows (already the case in `AppShell`).
- The chain is **derived from the current URL params + data lookups**, not from a navigation-history stack (which is unreliable on deep-links / refresh / share).

### Acceptance

- Deep-link into `/place/pl-b-market` in a fresh tab → back button goes to `/weekday/monday`, not today.
- Refresh at any level → breadcrumbs and back target stay correct.
- Hardware back on Dashboard triggers the double-tap-to-exit flow.
- Bottom nav does not grow the back stack.
