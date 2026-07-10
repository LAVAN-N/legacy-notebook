# Phase 1 - Presentation Layer Implementation

Read:

knowledge/project-kb.md
skills/coding-standards.md
knowledge/kiro-agent-rules.md
plans/kiro-rollout.md

Read all files inside:

specs/

The specs folder is the source of truth for UI implementation.

Business logic is not part of this phase.

---

## Objective

Convert screen specifications into Flutter presentation layer.

Implement production-quality UI only.

No business workflows.

No repositories.

No database operations.

No Supabase queries.

No Drift.

No calculations.

No persistence.

---

# Material 3 Requirements

Android-first

Large touch targets

Outdoor readability

Single-hand usage

Minimal cognitive load

Large typography

Minimal scrolling

Reusable widgets

Responsive layouts

---

# Build Design System

Generate reusable widgets and design tokens.

Create:

AppScaffold
SectionHeader
DashboardCard
SummaryCard
InfoCard
InfoTile
RouteCard
CustomerCard
SearchBar
StatusChip
AmountCard
ActionCard
EmptyState
LoadingState
ErrorState
PrimaryButton
SecondaryButton
TimelineCard
ConfirmationDialog

Widgets should be:

Composable
Reusable
Stateless whenever possible

Avoid massive widgets.

---

# Implement Dashboard

Sections:

Header
Greeting
Date

Summary Cards:

Today's Collections
Outstanding Customers
Today's Sales
Low Stock Products

Today's Route Card

Recent Activities

Quick Actions

Implement:

Loading State
Empty State
Error State
Populated State

Use mock data only.

---

# Implement Route Explorer

Flow:

Dashboard
→ Weekday
→ Place
→ Area
→ Customer

Screens:

Weekday Screen
Places Screen
Areas Screen
Customers Screen

Cards should display:

Name
Counts
Outstanding information
Status indicators

Search access should remain visible.

Use mock data only.

---

# Implement Customer Search

Search:

Customer Name
Phone Number
Customer Code

Implement:

Search field
Recent searches
Suggestions
Search results
Empty state
Loading state

Mock data only.

---

# Implement Customer Details

Sections:

Header
Photo
Name
Phone
Outstanding

Personal Information

Address
GPS Location

Nominees

Proof Images

Activity Timeline

Filters:

All
Collections
Sales

Sticky Actions:

Collect Payment
New Sale
Edit Customer

Timeline should visually resemble:

Messaging history
+
Bank statement history

Implement:

Loading State
Empty State
Error State
Populated State

Use mock data only.

---

# Navigation

All screens should be navigable.

Navigation must remain:

Dashboard
→ Weekday
→ Place
→ Area
→ Customer
→ Customer Details

No backend integration.

---

# Architecture Rules

Widgets:
Presentation only.

Providers:
Mock state only.

No repositories.

No services.

No business calculations.

No database access.

No network calls.

No persistence.

---

# Deliverables

1. Complete presentation layer
2. Reusable design system
3. Responsive layouts
4. Material 3 implementation
5. Loading, empty, error states
6. Mock navigation flow
7. Mock data providers

When finished provide:

1. Folder tree
2. Widget inventory
3. Screens implemented
4. Files created
5. Files modified
6. Manual actions required

Stop and wait for approval.
