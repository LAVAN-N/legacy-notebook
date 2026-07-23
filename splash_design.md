# Splash Screen — Flutter Implementation Spec

App: **Legacy Notebook** — Credit Collection & Sales Management
Direction: **Classic Editorial** (teal + gold, Bodoni Moda serif wordmark, framed ledger icon)

---

## 1. Purpose

Displayed for ~1.5–2.5 s while the app:

1. Initializes Riverpod providers and Drift SQLite.
2. Reads cached Supabase session.
3. Warms the offline sync engine.
4. Routes to `/dashboard` (authed) or `/login` (guest).

No user interaction. No CTAs. No progress percentages.

---

## 2. Layout (390 × 844 baseline, safe-area aware)

Three vertical zones using `Column` + `MainAxisAlignment.spaceBetween`, wrapped in `SafeArea`.

```text
┌──────────────────────────────┐  SafeArea top
│                              │  paddingTop  : 80
│      ESTABLISHED             │  Top branding block
│   NINETEEN NINETY-FOUR       │
│                              │  flex spacer
│        ┌────────┐            │  Ledger icon  80x96
│        │  ===   │            │
│        │  ==    │            │
│        │  ===   │            │
│        └────────┘            │
│            *                 │  gold diamond dot
│                              │  gap 40
│         Legacy               │  Bodoni Moda italic 42
│       N O T E B O O K        │  Bodoni Moda uppercase 38
│                              │  gap 32
│         -----                │  divider 48x1
│                              │  gap 24
│   CREDIT COLLECTION &        │  Inter 11, tracking 0.15em
│    SALES MANAGEMENT          │
│                              │  flex spacer
│   HOME APPLIANCE DIVISION    │  Inter 9, gold/50
│                              │  paddingBottom : 80
└──────────────────────────────┘  SafeArea bottom
```

---

## 3. Design Tokens

```dart
// lib/core/theme/splash_tokens.dart
class SplashTokens {
  static const bg          = Color(0xFF0A2E2B); // deep teal
  static const gold        = Color(0xFFC5A02E); // primary accent
  static const goldSoft    = Color(0x66C5A02E); // 40% (dividers)
  static const goldFaint   = Color(0x33C5A02E); // 20%
  static const wordmark    = Color(0xFFE5E7EB); // near-white
  static const wordmarkDim = Color(0xCCE5E7EB); // 80%
}
```

---

## 4. Typography

| Element                   | Family      | Weight     | Size | Case  | Tracking | Color         |
| ------------------------- | ----------- | ---------- | ---- | ----- | -------- | ------------- |
| "Established"             | Inter       | 600        | 10   | UPPER | 3.0 px   | gold @ 70%    |
| "Nineteen Ninety-Four"    | Inter       | 400        | 11   | UPPER | 2.2 px   | gold          |
| "Legacy"                  | Bodoni Moda | 300 italic | 42   | Title | -0.5 px  | wordmark      |
| "NOTEBOOK"                | Bodoni Moda | 400        | 38   | UPPER | 3.8 px   | gold          |
| Tagline (2 lines)         | Inter       | 300        | 11   | UPPER | 1.65 px  | wordmark @ 80%|
| "Home Appliance Division" | Inter       | 400        | 9    | UPPER | 0.9 px   | gold @ 50%    |

```yaml
dependencies:
  google_fonts: ^6.2.1
  flutter_native_splash: ^2.4.0
```

---

## 5. Spacing Scale

Base 4 px. Do not hardcode elsewhere.

| Between                              | Gap  |
| ------------------------------------ | ---- |
| SafeArea top → "Established"         | 80   |
| "Established" → "Nineteen…"          | 4    |
| Top block → icon                     | flex |
| Icon frame → gold diamond            | 8    |
| Icon → "Legacy"                      | 40   |
| "Legacy" → "NOTEBOOK"                | 4    |
| "NOTEBOOK" → divider                 | 32   |
| Divider → tagline                    | 24   |
| Tagline → bottom block               | flex |
| "Home Appliance Division" → SafeArea | 80   |

---

## 6. Ledger Icon (custom paint, no image asset)

```dart
class LedgerIcon extends StatelessWidget {
  const LedgerIcon({super.key});
  @override
  Widget build(BuildContext c) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80, height: 96,
          decoration: BoxDecoration(
            border: Border.all(color: SplashTokens.gold, width: 1.5),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Stack(children: [
            Positioned(left: 8, top: 0, bottom: 0,
              child: Container(width: 1, color: SplashTokens.goldSoft)),
            Positioned(left: 12, top: 0, bottom: 0,
              child: Container(width: 1, color: SplashTokens.goldSoft)),
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 32, height: 1, color: SplashTokens.gold.withOpacity(.6)),
                  const SizedBox(height: 12),
                  Container(width: 24, height: 1, color: SplashTokens.gold.withOpacity(.6)),
                  const SizedBox(height: 12),
                  Container(width: 32, height: 1, color: SplashTokens.gold.withOpacity(.6)),
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        Transform.rotate(
          angle: 0.785398,
          child: Container(width: 4, height: 4, color: SplashTokens.gold),
        ),
      ],
    );
  }
}
```

---

## 7. Full Widget

`lib/features/splash/splash_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});
  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<double> _rise;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _rise = Tween(begin: 8.0, end: 0.0).animate(_fade);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // await ref.read(appBootstrapProvider.future);
    if (!mounted) return;
    // context.go(session == null ? '/login' : '/dashboard');
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final inter = GoogleFonts.interTextTheme();
    final bodoni = GoogleFonts.bodoniModaTextTheme();

    return Scaffold(
      backgroundColor: SplashTokens.bg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, child) => Opacity(
            opacity: _fade.value,
            child: Transform.translate(offset: Offset(0, _rise.value), child: child),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(children: [
                  Text('ESTABLISHED',
                    style: inter.bodySmall!.copyWith(
                      fontSize: 10, fontWeight: FontWeight.w600,
                      letterSpacing: 3.0,
                      color: SplashTokens.gold.withOpacity(.7))),
                  const SizedBox(height: 4),
                  Text('NINETEEN NINETY-FOUR',
                    style: inter.bodySmall!.copyWith(
                      fontSize: 11, letterSpacing: 2.2,
                      color: SplashTokens.gold)),
                ]),
                Column(children: [
                  const LedgerIcon(),
                  const SizedBox(height: 40),
                  Text('Legacy',
                    style: bodoni.displayLarge!.copyWith(
                      fontSize: 42, height: 1.05,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -0.5,
                      color: SplashTokens.wordmark)),
                  const SizedBox(height: 4),
                  Text('NOTEBOOK',
                    style: bodoni.displayLarge!.copyWith(
                      fontSize: 38, height: 1.05,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 3.8,
                      color: SplashTokens.gold)),
                  const SizedBox(height: 32),
                  Container(width: 48, height: 1, color: SplashTokens.goldFaint),
                  const SizedBox(height: 24),
                  Text('CREDIT COLLECTION &\nSALES MANAGEMENT',
                    textAlign: TextAlign.center,
                    style: inter.bodySmall!.copyWith(
                      fontSize: 11, height: 1.6,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.65,
                      color: SplashTokens.wordmarkDim)),
                ]),
                Text('HOME APPLIANCE DIVISION',
                  style: inter.bodySmall!.copyWith(
                    fontSize: 9, letterSpacing: 0.9,
                    color: SplashTokens.gold.withOpacity(.5))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 8. Motion

| Element      | Animation                        | Duration | Curve        |
| ------------ | -------------------------------- | -------- | ------------ |
| Whole scene  | Opacity 0→1, translateY 8→0      | 900 ms   | easeOut      |
| Icon         | Scale 0.96 → 1.0 (optional)      | 700 ms   | easeOutCubic |
| Gold diamond | Delayed fade-in (+300 ms)        | 400 ms   | easeOut      |

No looping shimmer or progress bar — static after entry.

---

## 9. Native Splash (Android + iOS)

```yaml
flutter_native_splash:
  color: "#0A2E2B"
  image: assets/splash/ledger_mark_gold.png
  android_12:
    color: "#0A2E2B"
    image: assets/splash/ledger_mark_gold.png
  ios: true
  android: true
```

Run: `dart run flutter_native_splash:create`.

---

## 10. Routing

```dart
GoRoute(path: '/', builder: (_, __) => const SplashPage()),
```

`SplashPage` awaits `appBootstrapProvider` (auth session + Drift open + sync init) then `context.go('/dashboard')` or `/login`. Minimum on-screen duration: 1200 ms.

---

## 11. Accessibility

- Contrast: gold `#C5A02E` on `#0A2E2B` = 6.1 : 1 (AA large text).
- Wrap the scene in a single `Semantics(label: 'Legacy Notebook — Credit Collection and Sales Management', container: true)`.
- Respect `MediaQuery.textScalerOf(context)`; layout survives 1.3x scale.
- Honor `MediaQuery.disableAnimations` — skip fade/rise.

---

## 12. QA Checklist

- [ ] Renders on 360x640, 390x844, 412x915.
- [ ] Safe-area respected on notched devices.
- [ ] No layout shift when fonts load (preload via `GoogleFonts.pendingFonts`).
- [ ] Native splash color matches `#0A2E2B` exactly — no white flash.
- [ ] Minimum 1200 ms visible; max 3000 ms before forced navigation.
