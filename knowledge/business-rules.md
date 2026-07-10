# Business Rules

## Rule 1

Customer credit behaves as one running balance.

Never maintain separate EMIs per product.

---

## Rule 2

Outstanding Calculation:

Outstanding =
SUM(financed_amount)
--------------------

SUM(collection_amount)

---

## Rule 3

Ready Sale

Ready sales never increase outstanding.

Example:

Price:
₹5,000

Paid:
₹5,000

Credit Added:
₹0

---

## Rule 4

Credit Sale

Credit sales increase outstanding.

Example:

Price:
₹12,000

Advance:
₹2,000

Financed Amount:
₹10,000

Outstanding increases by:
₹10,000

---

## Rule 5

Collections are chronological activities.

A customer may have multiple collection entries on the same day.

Example:

09:00 AM
Partial Payment:
₹200

06:00 PM
Payment:
₹300

Both activities must be preserved.

---

## Rule 6

Collection statuses:

PAYMENT

PARTIAL_PAYMENT

CARRY_FORWARD

---

## Rule 7

Collection notes belong to collection activities.

Examples:

Will arrange by evening.
Come next week.
Customer not available.
Visit after 7 PM.

---

## Rule 8

Partial payment is a first-class collection status.

Example:

Outstanding:
₹10,000

Paid:
₹200

Reason:
Will arrange remaining amount by evening.

Status:
PARTIAL_PAYMENT

---

## Rule 9

Carry forward never changes outstanding.

Carry forward only records future intent.

Example:

Status:
CARRY_FORWARD

Amount:
₹0

Reason:
Come next week.

Outstanding remains unchanged.

---

## Rule 10

Customer may pay credit and purchase during the same visit.

Example:

Cash Given:
₹5,000

Credit Payment:
₹3,000

Advance:
₹2,000

New Purchase:
Washing Machine

Credit Added:
₹10,000

Outstanding:

## Previous Outstanding

₹3,000
+
₹10,000

---

## Rule 11

Inventory must always be transaction-driven.

Never maintain editable stock counters.

Current Stock:

## Purchases

Sales
±
Adjustments

---

## Rule 12

Customer timeline always displays:

Collections
Sales
Outstanding

ordered chronologically.

---

## Rule 13

Application must tolerate poor network conditions.

Collections and sales should eventually synchronize.

No data loss is acceptable.

---

## Rule 14

Collection and sale activities are immutable records.

Never overwrite history.

Always create new activity records.

---

## Rule 15

Every activity should preserve:

Date
Time
User
Amount
Notes
Reference information
