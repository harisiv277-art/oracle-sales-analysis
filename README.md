# Sales Data Analysis using Oracle SQL

## Objective
Analyze sales data to find top-performing categories and cities, high-value customers and monthly revenue trends.

## Tools
Oracle Database, Oracle SQL Developer

## Dataset
Sales database with 3 tables: customers (100 rows), products (20 rows) and sales (2,000 rows).

## SQL Concepts Used
JOINs, GROUP BY / HAVING, subqueries, CTEs, window functions (RANK, LAG, running totals)

## Business Questions and Results

### 1. Full sales detail (JOIN)
![JOIN](screenshots/01_join.png)

### 2. Revenue by category (GROUP BY)
![Category](screenshots/02_groupby_category.png)

### 3. Revenue by city (GROUP BY)
![City](screenshots/03_groupby_city.png)

### 4. Customers spending above average (Subquery)
![Subquery](screenshots/04_subquery.png)

### 5. Monthly revenue growth (CTE + LAG)
![CTE](screenshots/05_cte_monthly_growth.png)

### 6. Top 10 customers (Window function)
![Top customers](screenshots/06_window_top_customers.png)

### 7. Top 3 products per category (Window function)
![Top products](screenshots/07_window_top_products.png)

### 8. Cumulative revenue (Window function)
![Running revenue](screenshots/08_window_running_revenue.png)

## Key Findings
- [Stationery] led revenue with ₹[24130000] ([37.9%]% of total).
- [Delhi] had the most orders ([500]); [Mumbai] had the lowest revenue.
- Month-over-month growth peaked in [March] at [9]%.
- [45] customers spent above average; the top 10 account for [26.3]% of revenue.

## Files
- `sales_analysis.sql`: table creation, data load and all queries
- `screenshots/`: query results
