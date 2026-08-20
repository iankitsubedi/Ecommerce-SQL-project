# E-commerce SQL Project

A small e-commerce database built from scratch while I'm learning PostgreSQL. This project was my way of practicing database design and SQL beyond just running pre-built exercises — I designed the schema myself, decided the constraints and delete behaviors, filled it with sample data, and wrote a set of queries to answer real business-style questions.

## What's in it

- **Schema**: 6 tables — `customers`, `categories`, `products`, `orders`, `order_items`, `reviews`
- **Constraints**: NOT NULL, UNIQUE, CHECK constraints (e.g. price/quantity can't be negative, ratings are bounded), and foreign keys linking every table together
- **Delete behavior (ON DELETE CASCADE / RESTRICT)**: chosen deliberately per relationship, not defaulted. For example:
  - Deleting an `order` cascades to delete its `order_items` (an item with no order doesn't mean anything on its own)
  - Deleting a `product` is restricted while it still has order history (so past sales records don't get silently erased)
  - Deleting a `category` is restricted while it still has products in it (forces reassignment first)
- **Sample data**: customers, products across 5 categories, orders, order items, and reviews

## Queries included

12 queries covering:
- Joins (orders overview, order item details, review details)
- Aggregation (revenue per category, orders per customer)
- Subqueries (never-ordered products, customers with no reviews)
- CTEs (customers/products spending or earning above average)
- Window functions (ranking customers by spend, top-rated product per category using `PARTITION BY`)
- Conditional aggregation (rating breakdown per product)

## Why this project

I wanted to move past just querying databases someone else already built, and actually go through the process of designing one — thinking through table relationships, what data should live where, and what should happen when something gets deleted. It's a simple project, but every part of it (schema, constraints, and all 12 queries) was written and debugged by me.

## Tech used
PostgreSQL, pgAdmin
