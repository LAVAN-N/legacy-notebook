# Phase 0 - Project Initialization

You are the lead engineer for the Appliance Credit Manager project.

Before making any changes, read and understand all project documentation.

## Required Reading Order

1. knowledge/project-kb.md
2. knowledge/business-rules.md
3. knowledge/database-schema.md
4. knowledge/workflows.md
5. skills/coding-standards.md
6. knowledge/kiro-agent-rules.md
7. plans/kiro-rollout.md
8. All files inside specs/

These files are the authoritative source of truth.

Business rules override implementation assumptions.

Never assume requirements that are not explicitly documented.

---

# Current Goal

Implement ONLY Phase 0: Project Foundation.

Do not implement any business features.

Do not implement repositories.

Do not implement providers beyond project initialization.

Do not implement Supabase queries.

Do not implement Drift tables.

Do not implement business workflows.

Do not implement collections, sales, inventory, reports, or customer management.

---

# Tech Stack

Flutter
Material 3
Riverpod
GoRouter
Supabase
Drift

Architecture:
Feature-first architecture.

---

# Create Project Structure

lib/

app/
core/
shared/
features/

Generate:

app/
app.dart
router.dart
theme.dart

core/
constants/
errors/
extensions/
services/
utils/

shared/
models/
widgets/
providers/

features/
auth/
dashboard/
routes/
customers/
collections/
sales/
inventory/
reports/

Each feature should contain:

presentation/
screens/
widgets/

application/

domain/

data/

infrastructure/

---

# Implement Foundation

1. Material 3 theme
2. App entrypoint
3. ProviderScope
4. GoRouter setup
5. Supabase initialization placeholders
6. Feature-first structure
7. Placeholder screens only

---

# Placeholder Screens

SplashScreen
DashboardScreen
WeekdaysScreen
PlacesScreen
AreasScreen
CustomersScreen
CustomerDetailsScreen

Each screen should:

* Compile successfully
* Have AppBar
* Have placeholder content
* Support future expansion

---

# Navigation Flow

Splash
→ Dashboard
→ Weekday
→ Place
→ Area
→ Customer
→ Customer Details

Use placeholder navigation only.

No data integration.

---

# Requirements

Generate production-quality code.

Follow Flutter and Dart best practices.

Keep widgets small and composable.

Use Material 3.

Prepare for future Riverpod, Supabase, and Drift integration.

No mock business logic.

No sample repositories.

No speculative implementations.

---

# Deliverables

1. Folder structure created
2. Dependencies wired correctly
3. App compiles successfully
4. Theme configured
5. Router configured
6. Placeholder screens created
7. Navigation works

When finished:

1. Explain architectural decisions.
2. Provide generated folder tree.
3. List files created.
4. List manual actions required from me.
5. Stop and wait for approval before moving to Phase 1.
