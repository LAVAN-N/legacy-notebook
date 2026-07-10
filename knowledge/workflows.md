# Workflows

# Morning Collection Visit

Collector
→ Visits customer
→ Reviews outstanding
→ Customer responds

Possible outcomes:

PAYMENT

PARTIAL_PAYMENT

CARRY_FORWARD

---

# Partial Payment Workflow

Outstanding:
₹10,000

Customer pays:
₹200

Customer says:
Will arrange remaining amount by evening.

System:

Create collection:

Status:
PARTIAL_PAYMENT

Amount:
₹200

Reason:
Will arrange remaining amount by evening.

Outstanding decreases by:
₹200

---

# Evening Revisit Workflow

Customer requested revisit.

Collector returns.

Customer may:

Pay
Pay partially
Carry forward again

Every visit becomes a separate collection activity.

History must be preserved.

---

# Credit Collection Plus New Sale

Customer gives:
₹5,000

Instructions:

₹3,000:
Credit payment.

₹2,000:
Advance for new product.

System:

Reduce outstanding by:
₹3,000

Create new sale.

Create sale item(s).

Increase outstanding by financed amount.

Update customer balance.

Add both activities to timeline.

---

# New Credit Sale

Customer purchases product.

Pays advance.

Remaining amount becomes customer credit.

System:

Create sale
Create sale items
Deduct inventory
Update outstanding
Add timeline activity

---

# Ready Sale

Customer purchases product.

Pays full amount.

System:

Create sale
Create sale items
Deduct inventory
No credit added

---

# Product Booking Workflow

Customer requests unavailable product.

Customer gives advance.

Product delivered later.

System:

Record advance
Create sale record
Preserve booking information
Update inventory on delivery

---

# Route Navigation Workflow

Dashboard
→ Weekday
→ Place
→ Area
→ Customer
→ Customer Details

---

# Customer Search Workflow

Search by:

Customer Name
Phone Number
Customer Code

Search result:

Photo
Name
Phone
Outstanding
Route information

Actions:

Open customer
Collect payment
Create sale
Call customer

---

# Customer Details Workflow

View:

Photo
Outstanding
Personal Information
Nominees
Proof Images
Location
Timeline

Actions:

Collect Payment
New Sale
Edit Customer

---

# Timeline Workflow

Unified customer history.

Timeline contains:

Collection Events
Sale Events

Filters:

All
Collections
Sales

Timeline ordering:

Newest first.

Every activity should preserve:

Date
Time
Amount
User
Notes
Reference information.
