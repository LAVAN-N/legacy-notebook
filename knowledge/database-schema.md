# Database Schema

## Enums

### collection_status

PAYMENT

PARTIAL_PAYMENT

CARRY_FORWARD

---

### sale_type

READY

CREDIT

---

### inventory_transaction_type

PURCHASE

SALE

ADJUSTMENT

---

# Tables

## weekdays

id
name
sort_order

---

## places

id
weekday_id
name

---

## areas

id
place_id
name

---

## users

id
name
phone
role
status

---

## products

id
sku
name
brand
category
minimum_stock
image_url

---

## customers

id
customer_code
name
phone
alternate_phone
address
proof_url
location_url
weekday_id
place_id
area_id
sequence_number
status
created_by

---

## customer_nominees

id
customer_id
name
phone
relation

A customer can have multiple nominees.

---

## customer_proofs

id
customer_id
proof_type
image_url

A customer can have multiple proof images.

---

## collections

id
customer_id
visit_datetime
status
amount
reason
collected_by

Stores:

Payments
Partial payments
Carry forwards
Notes

---

## sales

id
customer_id
sale_datetime
sale_type
total_amount
advance_amount
financed_amount
sold_by
remarks

Stores:

Ready sales
Credit sales
Bookings

---

## sale_items

id
sale_id
product_id
quantity
unit_price
total_price
status
collected_amount
created_at

Supports:

Multiple products per sale.

---

## inventory_transactions

id
product_id
transaction_type
quantity
reference_id
remarks
created_by
created_at

Inventory movements should be fully auditable.

---

# Relationships

weekdays
1 → many
places

places
1 → many
areas

areas
1 → many
customers

customers
1 → many
customer_nominees

customers
1 → many
customer_proofs

customers
1 → many
collections

customers
1 → many
sales

sales
1 → many
sale_items

products
1 → many
sale_items

products
1 → many
inventory_transactions

---

# Database Views

## customer_outstanding_view

Outstanding:

## SUM(financed_amount)

SUM(collection_amount)

---

## customer_activity_view

Unified timeline containing:

Collections
Sales

ordered by activity timestamp.

---

## product_stock_view

Current Stock:

## Purchases

Sales
±
Adjustments

---

## route_summary_view

Weekday
Place
Area
Customer Count
Outstanding Amount

---

## customer_route_view

Contains:

Weekday
Place
Area
Customer
Outstanding

Used by route explorer.

---

## customer_dashboard_view

Contains:

Customer Information
Outstanding
Collection Status
Route Information

Used by:

Dashboard
Search
Customer Lists
