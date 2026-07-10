# Appliance Credit Manager - Kiro Agent Operating Rules

## Purpose

This document defines how Kiro agents should think, make decisions, generate code, and collaborate during implementation.

This project contains complex business workflows and financial operations. Incorrect assumptions can corrupt customer outstanding balances and collection history.

Agents must prioritize correctness, maintainability, and incremental delivery.

---

# Project Source of Truth

Always read:

knowledge/project-kb.md
knowledge/business-rules.md
knowledge/database-schema.md
knowledge/workflows.md

skills/coding-standards.md
plans/kiro-rollout.md

Read relevant files inside:

specs/

Never assume requirements that are not explicitly documented.

Business rules always override implementation assumptions.

---

# Agent Responsibilities

Kiro acts as:

Senior Flutter Engineer
Mobile Architect
Application Engineer
Backend Integrator
Database Integrator
Offline-First Engineer

Kiro is NOT:

Product Owner
Business Decision Maker
UX Designer

Use specifications and documentation as source of truth.

---

# General Rules

Never generate the entire application in one iteration.

Work phase-by-phase.

Each phase must:

Understand requirements
Implement only the current phase
Compile successfully
Wait for validation

---

# Architecture Rules

Architecture:

Presentation
→ Application
→ Domain
→ Data
→ Infrastructure

Dependencies must only move inward.

UI cannot directly access:

Supabase
Drift
Storage
Network

All data access goes through repositories.

---

# Feature Structure

feature/

presentation/
screens/
widgets/

application/
providers/
state/
services/

domain/
models/
repositories/

data/
datasources/
repositories/
mappers/

infrastructure/
realtime/
sync/
storage/

---

# Presentation Rules

Widgets should be:

Reusable
Composable
Mostly stateless

Avoid:

Business logic
Database calls
Long build methods
Complex conditions

Prefer:

Small widgets
Extracted components
Reusable cards
Reusable dialogs
Reusable bottom sheets

---

# State Management Rules

Use Riverpod.

Preferred order:

Provider
StateNotifierProvider
AsyncNotifierProvider

Use AsyncValue for:

Network operations
Loading states
Failure states

Avoid:

Global mutable state
Singleton services
Direct dependency construction

Use dependency injection through providers.

---

# Navigation Rules

Use GoRouter.

Navigation should be:

Type-safe
Declarative
Deep-link friendly

Avoid:

Named strings scattered across codebase
Navigator.push everywhere

Centralize routes.

---

# Model Rules

Models should be:

Immutable
Freezed based
Json Serializable
Value objects

Generate:

copyWith
Equality
Serialization

Never pass Map<String, dynamic> throughout the application.

Always use typed models.

---

# Repository Rules

Repositories are responsible for:

Reading
Writing
Updating
Deleting
Mapping

Repositories are NOT responsible for:

UI state
Widget logic

Repositories expose domain models.

Never expose raw database rows.

---

# Error Handling Rules

Every repository operation should return:

Success
Failure

Never crash UI.

Prefer:

Domain exceptions
Typed failures
Meaningful messages

---

# Logging Rules

Log:

Errors
Sync failures
Realtime disconnects
Unexpected states

Avoid excessive debug prints.

Centralize logging.

---

# Form Rules

Every form should support:

Validation
Loading state
Error state
Success state

Buttons should disable during submissions.

Prevent duplicate submissions.

---

# Search Rules

Search must support:

Customer Name
Phone Number
Customer Code

Prefer:

Debouncing
Pagination
Caching

Search should remain responsive.

---

#################################################

# CUSTOMER BUSINESS RULES

#################################################

Customer outstanding behaves as:

One running balance.

Never maintain separate EMIs per product.

Example:

TV Credit:
₹10,000

Fridge Credit:
₹5,000

Outstanding:
₹15,000

Customer pays:
₹3,000

Outstanding:
₹12,000

Customer purchases:

Washing Machine:
₹12,000

Advance:
₹2,000

Credit Added:
₹10,000

New Outstanding:
₹22,000

This calculation is critical.

Never violate this rule.

---

#################################################

# COLLECTION BUSINESS RULES

#################################################

Collections are chronological activities.

Collections are the primary business workflow.

A customer may have:

Morning payment
Morning partial payment
Evening payment
Carry forward

Multiple collections can occur on the same day.

All collection events are preserved.

Never overwrite previous collections.

---

# Collection Statuses

PAYMENT

Money collected.

PARTIAL_PAYMENT

Money collected.

Customer requests another visit.

CARRY_FORWARD

No money collected.

Customer requests future collection.

---

# Collection Notes

Collection notes belong to collection activities.

Examples:

Will arrange by evening
Come next week
Customer not available
Visit after 7 PM

Never discard collection notes.

---

#################################################

# SALES BUSINESS RULES

#################################################

Customer may:

Pay credit only
Purchase only
Pay and purchase
Partially pay and purchase
Book products with advance

All sales appear in customer history.

---

# Ready Sale

Full payment.

Adds:

₹0 credit.

---

# Credit Sale

Advance payment.

Adds:

financed_amount to outstanding.

---

# Outstanding Formula

Outstanding:

## SUM(financed_amount)

SUM(collection_amount)

Only:

PAYMENT
PARTIAL_PAYMENT

reduce outstanding.

CARRY_FORWARD does not.

This formula is critical.

Never duplicate calculations.

Create one centralized calculation service.

---

#################################################

# INVENTORY BUSINESS RULES

#################################################

Inventory is transaction-driven.

Stock:

SUM(transactions)

Never maintain manual stock counters.

Transaction Types:

PURCHASE
SALE
ADJUSTMENT

Stock calculations should be centralized.

---

#################################################

# TIMELINE RULES

#################################################

Customer timeline is unified.

Timeline includes:

Collections
Sales
Outstanding updates

Filters:

All
Collections
Sales

Timeline must be chronological.

Never lose historical activities.

Never mutate history.

History is append-only.

---

#################################################

# OFFLINE RULES

#################################################

Application must function with poor internet.

Collections and sales are business critical.

Requirements:

Offline creation
Offline edits
Queueing
Retry
Automatic synchronization

Never block users because of connectivity.

---

#################################################

# REALTIME RULES

#################################################

Realtime should update:

Dashboard
Outstanding
Timeline
Inventory
Customer Lists

Use optimistic updates.

Server should eventually become source of truth.

---

#################################################

# PERFORMANCE RULES

#################################################

Avoid rebuilding entire screens.

Prefer:

Selectors
Memoization
Pagination
Lazy loading
Cached images

Lists may eventually contain thousands of customers.

Design accordingly.

---

#################################################

# SECURITY RULES

#################################################

Never expose:

Supabase keys
Storage secrets
Raw SQL in UI

Use environment configuration.

Validate all input.

Never trust client input.

---

#################################################

# IMPLEMENTATION ORDER

#################################################

Foundation
→ Navigation
→ Read-only Collector App
→ Models
→ Providers
→ Infrastructure
→ Repositories
→ Customers
→ Collections
→ Sales
→ Inventory
→ Reports
→ Offline
→ Realtime
→ Hardening

Do not skip phases.

Do not merge multiple phases into one implementation.

Each phase must compile and be validated before proceeding.
