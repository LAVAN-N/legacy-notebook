# Project Knowledge Base

## Project Name

Appliance Credit Manager

## Project Type

Field-based Home Appliance Sales and Credit Collection Management System.

## Purpose

Digitize and centralize the operations of a home appliance business where products are sold directly in villages and residential areas and customer credits are collected through recurring field visits.

The application should allow both the owner and substitute collectors to manage the business without requiring operational knowledge from a single individual.

---

# Users

## Owner

Full access to all modules and reports.

Responsibilities:

* Manage customers
* Manage inventory
* View reports
* Monitor collections
* Monitor sales
* Configure routes

---

## Collector

Handles field operations.

Responsibilities:

* Visit customers
* Collect payments
* Record carry forwards
* Record partial payments
* Create sales
* Book products
* View customer histories

---

## Substitute Collector

Temporary replacement for collector.

Responsibilities:

* Follow routes
* View customer information
* Collect payments
* Record sales
* Add notes
* Update activities

Application should allow substitute collectors to operate independently.

---

# Business Model

The store is not the primary source of customers.

Collectors travel to predefined places every week.

Each day of the week is associated with one or more places.

Each place contains one or more areas.

Each area contains customers.

Collectors visit customers at their homes.

Primary activities:

1. Credit collection
2. Product sales
3. Product bookings
4. Customer management
5. Inventory management

---

# Weekly Route System

Navigation hierarchy:

Dashboard
→ Weekday
→ Place
→ Area
→ Customer

Example:

Monday
→ Village A
→ North Street
→ Customer

Tuesday
→ Village B
→ Main Road
→ Customer

The route hierarchy is the primary navigation of the application.

---

# Product Sales

Products can be sold in two ways.

## Ready Sale

Customer pays the full amount.

Example:

Mixer
Price: ₹3,000

Paid:
₹3,000

Credit Added:
₹0

---

## Credit Sale

Customer pays advance and takes the product.

Example:

Television
Price: ₹20,000

Advance:
₹5,000

Credit Added:
₹15,000

---

# Customer Credit Principle

The business maintains one running outstanding balance per customer.

The application never manages separate EMIs per product.

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

Customer purchases Washing Machine:

Price:
₹12,000

Advance:
₹2,000

Credit Added:
₹10,000

New Outstanding:
₹22,000

All customer credits behave as one running balance.

---

# Collection Activities

Collections are the primary business activity.

Collectors visit customers every week.

Possible outcomes:

Payment
Partial Payment
Carry Forward

Customers may:

Pay full amount
Pay partial amount
Request revisit in evening
Request revisit another day
Request next week's collection

Collection activities can occur multiple times per day.

---

# Sales During Collection

Collectors often carry products during collection visits.

Customer may:

Pay only
Purchase only
Pay and purchase
Partially pay and purchase
Book products with advance

Sales and collections may happen in the same visit.

All activities should be preserved in history.

---

# Product Booking

Sometimes products are unavailable.

Customer gives advance.

Product is delivered later.

Application must support:

Advance collection
Delayed delivery
Sale history preservation

---

# Inventory

Inventory is transaction-based.

Stock increases:

Purchases

Stock decreases:

Sales

Adjustments:

Damaged products
Lost products
Manual corrections

---

# Customer Timeline

Every customer should have a unified activity history.

Timeline should include:

Collections
Sales
Outstanding changes
Notes

Timeline filters:

All
Collections
Sales

Timeline should feel similar to:

Messaging history
Bank statement history

---

# Design Goals

Mobile-first
Material 3
Single-hand usage
Fast navigation
Minimal typing
Outdoor readability
Large touch targets
Minimal cognitive load

---

# Success Criteria

A substitute collector should be able to:

Open application
→ Select weekday
→ Select place
→ Select area
→ Select customer
→ View outstanding
→ Collect payment
→ Record sale
→ View history

without requiring assistance from the owner.
