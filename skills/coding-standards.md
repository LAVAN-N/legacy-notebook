# Coding Standards

## Objective

Maintain a scalable, maintainable, and production-ready Flutter codebase.

This project prioritizes:

* Simplicity
* Readability
* Maintainability
* Offline capability
* Fast field usage

Avoid overengineering.

---

# Technology Stack

Framework:
Flutter

Language:
Dart

Design:
Material 3

State Management:
Riverpod

Navigation:
GoRouter

Backend:
Supabase

Offline Database:
Drift

Storage:
Supabase Storage

Maps:
Google Maps

---

# Architecture

Use Feature-First Architecture.

Structure:

lib/
├── app/
├── core/
├── shared/
├── features/
└── main.dart

---

# Feature Structure

features/

feature_name/

presentation/
├── screens/
├── widgets/

application/

domain/

data/

---

# Layer Responsibilities

## Presentation

Responsibilities:

* UI
* User interactions
* Navigation
* Form rendering
* State consumption

Must not contain:

* SQL
* Supabase queries
* Business calculations
* Repository logic

---

## Application

Responsibilities:

* State orchestration
* Use cases
* Feature coordination
* Workflow execution

May depend on:

Domain
Data

Must not depend on:

Widgets

---

## Domain

Responsibilities:

* Entities
* Value objects
* Enums
* Business contracts

Must be independent.

No Flutter imports.

---

## Data

Responsibilities:

* Repositories
* DTOs
* Mappers
* Remote data sources
* Local data sources

Must not contain UI code.

---

# State Management

Use Riverpod.

Prefer:

Provider
FutureProvider
StreamProvider
Notifier
AsyncNotifier

Use AsyncValue for:

Loading
Success
Error

Avoid:

setState for business state.

Use local widget state only for:

Animations
Controllers
Temporary selections

---

# Navigation

Use GoRouter.

Requirements:

Type-safe navigation.

Deep-link ready.

Avoid:

Navigator.push
Navigator.pop throughout features.

Navigation should be centralized.

---

# Models

Models should be:

Immutable
Freezed
Json Serializable

Generate:

copyWith
toJson
fromJson

Avoid mutable models.

---

# Repository Pattern

Every repository should have:

Interface
Implementation

Example:

CustomerRepository
SupabaseCustomerRepository

Repositories should:

Return typed models
Handle mapping
Throw domain exceptions

Repositories should not contain UI concerns.

---

# Services

Services are infrastructure concerns.

Examples:

StorageService
LocationService
SyncService
RealtimeService

Services should remain reusable.

---

# Error Handling

Never swallow exceptions.

Create typed exceptions.

Examples:

NetworkException
ValidationException
StorageException
SyncException

All screens must support:

Loading State
Empty State
Error State

---

# Forms

Use:

Form
GlobalKey<FormState>

Validation should be reusable.

Prefer:

Custom validators.

Avoid validation logic inside widgets.

---

# Widgets

Prefer:

Small widgets
Reusable widgets
Stateless widgets

Avoid:

Massive screens
Deep nesting
Duplicated widgets

Large widgets should be broken into:

Section widgets
Card widgets
Tile widgets

---

# Styling

Use Material 3.

Requirements:

Large typography
Large touch targets
Outdoor readability
Minimal scrolling
Single-hand operation

Spacing:

4
8
12
16
20
24

Touch targets:

Minimum 48dp

Buttons:

Minimum 56dp

Cards:

12-16 radius

---

# Naming Conventions

Files:

snake_case.dart

Classes:

PascalCase

Variables:

camelCase

Providers:

customerProvider
customerRepositoryProvider

Repository Interfaces:

CustomerRepository

Implementations:

SupabaseCustomerRepository

---

# Async Operations

Use:

AsyncValue

Provide:

Loading
Success
Failure states

Never block UI.

---

# Realtime

Supabase Realtime should be used for:

Collections
Sales
Inventory updates

Avoid realtime subscriptions everywhere.

Subscribe only where necessary.

---

# Offline

Collections and sales must work offline.

Sync should occur automatically.

No data loss is acceptable.

Prefer:

Queue-based synchronization.

---

# Performance

Prefer:

Pagination
Lazy lists
Caching
Memoization where appropriate

Avoid:

Premature optimization.

---

# Golden Rules

Business logic never belongs inside widgets.

Repositories never render UI.

Models remain immutable.

Features remain isolated.

Every screen supports loading, empty, and error states.

Code should be understandable by another developer in less than five minutes.
