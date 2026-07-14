# Splash Screen — Spec

## Purpose

Kill the "blank white flash" at cold start. Give the user an immediate branded moment while the router, theme, and mock/Drift repos wake up. **No spinner. No progress bar. No skeleton.** Just brand.

## Trigger

- First frame of the app after process start (Flutter: `runApp`; web prototype: root route mount).
- Also shown on explicit "cold reset" (e.g. user signs out).

## Duration

- Minimum on-screen time: **900 ms** (so it never feels like a flicker).
- Maximum on-screen time: **1800 ms**.
- Dismisses as soon as BOTH are true:
  1. Minimum time elapsed.
  2. Router has resolved the initial route AND theme controller has loaded persisted mode.

If bootstrap takes longer than the max, dismiss anyway and let the destination screen render its own empty/loading state.

## Visual

- Full-bleed background = current theme `background` token (respects system dark mode on very first launch, before user toggle exists).
- Centered wordmark: **"Field Collect"** in the display font (`Space Grotesk` 700, tracking `-0.02em`, size ≈ 44sp on mobile).
- Under the wordmark, a single line in body font, muted foreground, size 13sp:
  `Credit & sales, on the road.`
- A small brand mark (the same `व` circle used in `AppShell`) sits **48dp above** the wordmark, using `primary` on `primary-foreground`.
- Subtle fade-in of wordmark (opacity 0 → 1 over 280 ms, ease-out). No slide, no bounce.

## What NOT to include

- No `CircularProgressIndicator` / spinner.
- No progress %, no "Loading…" text.
- No logo animation beyond the fade.
- No version string, no build number (footer stays empty).

## Placement

- **Flutter:** `lib/features/splash/splash_screen.dart`. Wired as the initial `go_router` location `/`, which internally decides where to redirect to (`/dashboard`) once ready.
- **Web prototype:** an overlay component `src/components/prototype/Splash.tsx` mounted from `__root.tsx`; controlled by a `useSplash()` hook backed by a boolean that flips after the min-time timer AND `useRouterState({ select: s => s.status === 'idle' })`.

## Acceptance

- Cold launch never shows a blank/white frame before the splash.
- Splash disappears without a spinner ever appearing.
- On a very fast device (bootstrap <100 ms), splash still holds for 900 ms.
- Splash respects the persisted theme once it exists (light on light, dark on dark).
