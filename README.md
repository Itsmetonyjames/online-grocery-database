# Online Grocery Delivery — Relational Database Design & Implementation

End-to-end relational database for a multi-city online grocery delivery service — from business requirements and ERD through normalisation to 3NF, SQL implementation, analytical queries, and role-based security.

---

## Project Overview

This project designs and implements a production-ready relational database for an online grocery delivery platform operating across multiple cities. The work follows a complete database engineering lifecycle — requirements analysis, conceptual modelling, normalisation, physical implementation, query development, and security design.

---

## Database Schema

8 tables fully normalised to Third Normal Form (3NF):

| Table | Description |
|---|---|
| `City` | Delivery locations and regions |
| `Customer` | Customer identity and contact details |
| `Category` | Product groupings (Vegetables, Dairy, Staples, etc.) |
| `Product` | Product catalogue with pricing and SKU |
| `Inventory` | Stock levels, safety stock, reorder quantities |
| `Order` | Order headers with status and totals |
| `OrderItem` | Line items linking orders to products |
| `Transaction` | Payment records tied to orders |

---

## Entity Relationship Diagram

The ERD maps 8 entities with the following key relationships:

- Customer → Order (1:M) — one customer places many orders
- City → Customer (1:M) — one city has many customers
- City → Order (1:M) — orders deliver to one city
- Category → Product (1:M) — one category groups many products
- Product → Inventory (1:M) — stock tracked per product
- Order → OrderItem (1:M) — each order has many line items
- Product → OrderItem (1:M) — products appear across many orders
- Order → Transaction (1:M) — payments linked to orders

---

## Normalisation

The design progressed through all three normal forms:

| Stage | What was addressed |
|---|---|
| **UNF → 1NF** | Eliminated repeating product groups within single rows |
| **1NF → 2NF** | Removed partial dependencies (OrderDate → OrderID only; UnitPrice → ProductID only) |
| **2NF → 3NF** | Removed transitive dependencies (CityName depending on CustomerName, not OrderID) |

Inventory and Transaction tables already satisfied 3NF and did not require decomposition.

---

## SQL Analytical Queries

Five business queries extracting operational insight:

| Query | Business Question |
|---|---|
| Q1 — Total sales by category | Which product categories generated the most revenue in March 2025? |
| Q2 — Top 10 products | What are the best-selling products by volume and value? |
| Q3 — Customer order history | What did each customer buy, and how often, in the last month? |
| Q4 — Inventory status | What is the current stock level and reorder urgency per product? |
| Q5 — Revenue by city | Which cities generate the most revenue, and how many orders do they place? |

### Sample finding — Revenue by City (2025)
| City | Orders | Revenue |
|---|---|---|
| Mumbai | 4 | ₹1,670 |
| Bengaluru | 4 | ₹1,644 |
| Kolkata | 2 | ₹1,180 |
| Chennai | 2 | ₹1,098 |
| Delhi | 4 | ₹1,092 |

---

## Security Design

Role-based access control with three permission levels:

| Role | Permissions |
|---|---|
| **DBA** | Full control — schema changes, DROP, DELETE, recovery |
| **Data Entry** | INSERT, UPDATE on operational tables — no schema access |
| **Analyst** | SELECT only — read-only reporting access |

Additional safeguards: NOT NULL constraints, CHECK constraints (quantities > 0, prices > 0), FOREIGN KEY referential integrity, DEFAULT values for timestamps and status fields, audit trail via SQL Server login tracing.

---

## Files

| File | Description |
|---|---|
| `SQL_Code.sql` | Full database implementation — schema, sample data, queries, indexes, security |
| `DB_Report_Clean.pdf` | Full project report (normalisation, design decisions, query analysis) |
| `ERD.pdf` | Entity-Relationship Diagram |

---

## How to Run

```sql
-- Run in SQL Server Management Studio (SSMS)
-- 1. Execute SQL_Code.sql to create database, tables, and sample data
-- 2. Run individual query sections for analytical outputs
```

**Requirements:** Microsoft SQL Server (any recent version) or Azure SQL

---

## Tools Used

`SQL Server` `T-SQL` `SSMS` `ERD Design` `Database Normalisation (3NF)` `Role-Based Access Control`

---

*Tony James — MSc Data Science, York St John University, London*  
[LinkedIn](https://linkedin.com/in/tony-james-4bba63195) | [GitHub](https://github.com/itsmetonyjames)
