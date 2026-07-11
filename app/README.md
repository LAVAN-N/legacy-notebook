# Field Credit Collection & Home Appliance Sales Management System

A mobile-first, offline-first Flutter application scaffolding designed for collection agents and sales tracking.

## Architecture

This prototype is built using modern Flutter and Dart patterns:
- **State Management**: [Riverpod 2.x](https://pub.dev/packages/flutter_riverpod) using `AsyncNotifier` to isolate side effects from the UI layer.
- **Routing**: [GoRouter 14.x](https://pub.dev/packages/go_router) with Shell Routing supporting a bottom navigation bar layout.
- **Code Generation**: [Freezed](https://pub.dev/packages/freezed) models for fully immutable and serializable data models.
- **Design System**: Tailored light theme using a warm paper background (`#F8F5EE`), deep teal primary, currency green, warning marigolds, and danger vermilion. Numeric fonts are displayed using Google Fonts' `Space Grotesk` with tabular figures, ensuring clean tabular lists for outstanding balance sheets.

## Technical Specifications
- Flutter SDK: `^3.24.0` (Dart `^3.5.0`)
- Indian numbering grouping formats for Rupee indicators (e.g., `₹12,00,000`).
- No raw `Colors.*` hex definitions exist inside screen features; all widgets retrieve colors from context extensions (`context.colors.primary` etc.) to guarantee seamless light/dark styling transitions.

---

## How to Compile & Run

### 1. Generate Models & Freezed Classes
Before running the app, you need to run `build_runner` to generate the code-generated classes (`*.freezed.dart`, `*.g.dart`):

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Launch Local Emulator
Run standard start actions:
```bash
flutter run
```

---

## Database Seeding & Mock Swapping

### SQL Migrations Location
PostgreSQL seeds and views reside under:
- `supabase/seed/001_schema_placeholder.sql`
- `supabase/seed/002_sample_data.sql`
- `supabase/seed/README.md`

### Swapping Mock Data for Real Supabase Backend
Currently, all repository providers are bound to the `MockRepository` implementation.
To swap them out for the real Supabase implementation when you build it, locate the provider declarations at the bottom of `lib/data/mock/mock_repository.dart` and swap them out:

```diff
// File: lib/data/mock/mock_repository.dart

-final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
-  return ref.watch(mockRepositoryProvider);
-});
+final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
+  return SupabaseCustomerRepository(); // Swap to real database repository
+});
```

Repeat this change for all other provider interfaces: `RouteRepository`, `CollectionRepository`, `SaleRepository`, and `ProductRepository`.
