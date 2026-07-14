# Theme Toggle — Spec

## Purpose

Let the field user flip between **Light** and **Dark** without diving into settings. Field conditions vary (bright sun vs. dim shop) — the toggle must be one tap from the Dashboard.

## Placement

- **Dashboard header, top-right corner**, replacing nothing — sits to the **left of** the existing Online/Offline pill.
- Circular icon button, 40×40dp, ghost background, foreground = current `foreground` token.
- Icons: `Sun` in dark mode (tap → go light), `Moon` in light mode (tap → go dark). Use `lucide_icons` / `lucide-react` — no emoji.
- Tooltip / long-press label: "Switch to light theme" / "Switch to dark theme".

## Behavior

- Three modes exist internally: `system` (default on first launch), `light`, `dark`. The toggle in v1 only cycles between `light` and `dark`; `system` is used only until the user taps once.
- Tap → immediate theme swap. No dialog, no confirmation.
- Choice is persisted:
  - Flutter: `shared_preferences` key `theme_mode` (`"light"` | `"dark"` | `"system"`).
  - Web prototype: `localStorage["field-collect.theme"]`.
- Persistence read must happen **before first paint** where possible (see `splash-spec.md` — splash uses the persisted theme).

## State management

- **Flutter:** `themeModeProvider` in `lib/core/theme/theme_controller.dart` — a `StateNotifierProvider<ThemeController, ThemeMode>`. `MaterialApp.router` reads it via `ref.watch`.
- **Web prototype:** `ThemeProvider` in `src/components/prototype/ThemeProvider.tsx` writing `data-theme="dark"` on `<html>`. `src/styles.css` already needs a `[data-theme="dark"]` block mirroring the existing token set with dark values.

## Dark palette (tokens, not hex in components)

Define alongside existing light tokens. Keep semantic names identical; only values change:

| Token | Light | Dark |
|---|---|---|
| `background` | warm paper | `#0F1417` (deep ink) |
| `surface` | white | `#171D22` |
| `foreground` | near-black | `#ECEEF0` |
| `muted-foreground` | warm gray | `#8A9299` |
| `border` | warm gray-200 | `#2A3138` |
| `primary` | deep teal (unchanged hue) | slightly lifted teal for contrast |
| `success` / `warning` / `danger` | unchanged hue, adjusted lightness for WCAG AA on dark |

**No component may hardcode a hex.** All new dark values live in `src/styles.css` (web) and `lib/core/theme/app_colors.dart` (Flutter). Enforced by AGENTS.md §4.

## Acceptance

- Toggle visible on Dashboard, single tap changes theme instantly.
- Choice survives app restart.
- No flash of wrong theme on cold start (splash already respects persisted mode).
- Every existing screen renders correctly in both themes — contrast ≥ WCAG AA for body text.
- No `Colors.*`, no `text-white`, no `bg-[#...]` introduced.
