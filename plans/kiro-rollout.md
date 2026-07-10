# Appliance Credit Manager - Kiro Agent Rollout Plan

## Purpose

This document orchestrates implementation of the application phase-by-phase.

Kiro should work incrementally.

Do NOT attempt to generate the entire application in one iteration.

Every phase must:

1. Read project context
2. Understand business rules
3. Understand screen specifications
4. Implement only the current phase
5. Ensure application builds successfully
6. Stop and wait for validation before proceeding

---

# Project Context

Before every phase, read:

knowledge/project-kb.md
knowledge/business-rules.md
knowledge/database-schema.md
knowledge/workflows.md
knowledge/kiro-agent-rules.md

plans/kiro-rollout.md

skills/coding-standards.md

Read all relevant files inside:

specs/

These files are the authoritative source of truth.

Business rules always override implementation assumptions.

---

# Technology Stack

Framework:
Flutter

Language:
Dart

Design System:
Material 3

State Management:
Riverpod

Navigation:
GoRouter

Backend:
Supabase

Offline:
Drift

Realtime:
Supabase Realtime

Storage:
Supabase Storage

Maps:
Google Maps

Architecture:
Feature-first architecture

---

# Architecture Principles

Business logic never belongs inside widgets.

Widgets should be reusable and mostly stateless.

Providers orchestrate state.

Repositories contain data access logic.

Services contain infrastructure concerns.

Models should be immutable.

Every screen must support:

Loading
Empty
Error

Every implementation must compile before moving to the next phase.

---

#################################################

# PHASE 0

# PROJECT FOUNDATION

#################################################

## Objective

Create application foundation.

No business logic.

No repositories.

No database implementation.

No Supabase queries.

No Drift implementation.

Only scaffold and architecture.

---

## Read

knowledge/*
specs/application-architecture*
specs/navigation*
specs/design-system*

---

## Install Dependencies

Core

flutter_riverpod
hooks_riverpod
flutter_hooks
riverpod_annotation

Navigation

go_router

Backend

supabase_flutter

Serialization

freezed_annotation
json_annotation

Dev Dependencies

build_runner
freezed
json_serializable

Offline

drift
drift_flutter
sqlite3_flutter_libs
drift_dev

Utilities

connectivity_plus
intl
uuid
collection
path_provider
path

Maps

google_maps_flutter
geolocator
url_launcher

Media

image_picker
cached_network_image

---

## Generate Structure

lib/

app/
core/
shared/
features/

---

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

---

## Configure

Material 3 theme

ProviderScope

GoRouter

Supabase initialization placeholders

App entrypoint

---

## Create Placeholder Screens

SplashScreen
DashboardScreen
WeekdaysScreen
PlacesScreen
AreasScreen
CustomersScreen
CustomerDetailsScreen

Use placeholders only.

---

## Deliverables

Application builds successfully.

Navigation works.

Theme works.

Folder structure exists.

No backend integration.

STOP.

Wait for validation.

---

#################################################

# PHASE 1

# READ-ONLY COLLECTOR APPLICATION

#################################################

## Objective

Build complete collector navigation using mock data.

No repositories.

No Supabase.

No business logic.

No persistence.

---

## Read

specs/dashboard*
specs/routes*
specs/customers*
specs/customer-details*
specs/search*

---

## Implement Dashboard

Sections:

Header
Greeting
Date

Summary Cards:

Today's Collections
Outstanding Customers
Today's Sales
Low Stock Products

Today's Route

Recent Activities

Quick Actions

Use mock data.

---

## Implement Route Explorer

Flow:

Dashboard
→ Weekday
→ Place
→ Area
→ Customer

Generate:

Weekday screen
Places screen
Areas screen
Customer list screen

---

## Implement Customer Search

Search:

Customer Name
Phone
Customer Code

Mock data only.

---

## Implement Customer Details

Sections:

Header
Outstanding
Personal Information
Address
GPS Location
Nominees
Proof Images
Timeline

Timeline:

All
Collections
Sales

Bottom Actions:

Collect Payment
New Sale
Edit Customer

Mock data only.

---

## Deliverables

Collector can navigate entire application.

All screens follow specifications.

No backend integration.

STOP.

Wait for validation.

---

#################################################

# PHASE 2

# DOMAIN MODELS

#################################################

## Objective

Implement immutable domain models.

No repositories.

No providers.

No business workflows.

---

## Read

knowledge/database-schema.md

---

## Generate Models

User
Weekday
Place
Area
Product
Customer
CustomerNominee
CustomerProof
Collection
Sale
SaleItem
InventoryTransaction

---

## Requirements

Freezed

Json Serializable

copyWith

Equatable behavior

Type-safe enums

Nullable handling

Date conversions

---

## Generate Enums

CollectionStatus

PAYMENT
PARTIAL_PAYMENT
CARRY_FORWARD

SaleType

READY
CREDIT

InventoryTransactionType

PURCHASE
SALE
ADJUSTMENT

---

## Deliverables

Code generation succeeds.

Models compile.

STOP.

Wait for validation.

---

#################################################

# PHASE 3

# PRESENTATION STATE

#################################################

## Objective

Introduce Riverpod.

Still no backend.

Still mock data.

---

## Generate

Screen providers

State objects

Loading states

Empty states

Error states

Search providers

Filter providers

Selected route providers

Theme providers

---

## Requirements

AsyncValue

Notifier

AutoDispose where appropriate

No repositories.

No persistence.

---

## Deliverables

Application runs using providers and mock data.

STOP.

Wait for validation.

---

#################################################

# PHASE 4

# SUPABASE INFRASTRUCTURE

#################################################

## Objective

Prepare infrastructure.

No business workflows.

---

## Generate

Supabase client provider

Storage provider

Realtime provider

Connectivity provider

Error handlers

Base repository abstractions

Repository interfaces

---

## Requirements

Dependency injection through Riverpod.

No UI changes.

No queries.

---

## Deliverables

Infrastructure layer exists.

Compiles successfully.

STOP.

Wait for validation.

---

#################################################

# PHASE 5

# REPOSITORIES

#################################################

## Objective

Implement repositories.

No business workflows.

---

## Generate

CustomerRepository

CollectionRepository

SalesRepository

InventoryRepository

ReportsRepository

RouteRepository

---

## Requirements

Interface + implementation

Pagination support

Search support

Mapping layer

Exception handling

Realtime subscription hooks

Offline placeholders

---

## Deliverables

Repositories compile.

No business calculations.

STOP.

Wait for validation.

---

#################################################

# PHASE 6

# CUSTOMER MODULE

#################################################

## Objective

Implement customer management.

---

## Implement

Customer List

Customer Details

Customer Search

Create Customer

Edit Customer

Nominees

Proof Images

GPS Location Picker

---

## Requirements

Google Maps pin selection.

Save:

location_url

Proof images stored using:

Supabase Storage

Nominee supports:

Multiple entries
Dynamic add/remove

---

## Deliverables

Customer management functional.

STOP.

Wait for validation.

---

#################################################

# PHASE 7

# COLLECTION MODULE

#################################################

## Objective

Implement the primary business workflow.

Collections are chronological activities.

---

## Business Rules

Customer may have:

Morning payment

Morning partial payment

Evening payment

Carry forward

Multiple collections on same day

Collection notes belong to collection activities.

---

## Implement

Collection Form

Collection Timeline

Collection Filters

Outstanding refresh

Customer activity integration

---

## Statuses

PAYMENT

PARTIAL_PAYMENT

CARRY_FORWARD

---

## Requirements

Optimistic updates

Realtime refresh

Offline queue support

Retry mechanism

Conflict handling

---

## Deliverables

Collection workflow complete.

STOP.

Wait for validation.

---

#################################################

# PHASE 8

# SALES MODULE

#################################################

## Objective

Implement product sales.

---

## Business Rules

Outstanding is:

## SUM(financed_amount)

SUM(collection_amount)

Never manage EMIs per product.

Maintain one customer balance.

---

## Implement

Product picker

Cart

Ready sale

Credit sale

Advance booking

Outstanding refresh

Timeline integration

Inventory deduction

---

## Requirements

Large numeric input UX.

Offline support.

Realtime updates.

---

## Deliverables

Sales workflow complete.

STOP.

Wait for validation.

---

#################################################

# PHASE 9

# INVENTORY MODULE

#################################################

## Objective

Transaction-driven inventory.

---

## Implement

Products

Stock movements

Purchases

Adjustments

Low stock

Reports

---

## Rules

Current stock is derived from transactions.

Never manually update stock counters.

---

## Deliverables

Inventory complete.

STOP.

Wait for validation.

---

#################################################

# PHASE 10

# REPORTS

#################################################

## Implement

Dashboard Metrics

Customer Ledger

Route Summary

Collector Performance

Inventory Reports

Date filters

Exports

---

## Deliverables

Reports functional.

STOP.

Wait for validation.

---

#################################################

# PHASE 11

# OFFLINE + REALTIME

#################################################

## Objective

Production hardening.

---

## Implement

Drift database

Local repositories

Sync queue

Background sync

Retry mechanism

Connectivity listeners

Conflict resolution

Supabase Realtime subscriptions

Optimistic updates

---

## Requirements

Collections and sales must work without internet.

Synchronization must occur automatically.

No data loss.

---

## Deliverables

Application operates offline and online.

STOP.

Wait for validation.

---

#################################################

# PHASE 12

# FINAL HARDENING

#################################################

## Implement

Performance optimization

Error boundaries

Crash handling

Image caching

Loading skeletons

Accessibility

Form validation

Code cleanup

Documentation

---

## Acceptance Criteria

Collector can:

Open app
→ Select weekday
→ Select place
→ Select area
→ Open customer
→ View outstanding
→ Record collection
→ Record sale
→ View history
→ Work offline
→ Synchronize automatically

without assistance from the owner.
