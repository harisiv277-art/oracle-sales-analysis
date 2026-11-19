---Sales Data Analysis using Oracle SQL---

CREATE TABLE customers (
    customer_id   NUMBER PRIMARY KEY,
    customer_name VARCHAR2(100),
    city          VARCHAR2(50), 
    segments       VARCHAR2(30)
);

CREATE TABLE products (
    product_id    NUMBER PRIMARY KEY,
    product_name  VARCHAR2(100),
    categories    VARCHAR2(50),
    unit_price    NUMBER(10,2)
);

CREATE TABLE sales (
    sale_id      NUMBER PRIMARY KEY,
    sale_date    DATE,
    customer_id  NUMBER REFERENCES customers(customer_id),
    product_id   NUMBER REFERENCES products(product_id),
    quantity     NUMBER,
    discount     NUMBER(4,2)
);

-- Q: Loading data in the tables--

BEGIN 
    FOR i IN 1..100 LOOP
        INSERT into customers(customer_id,customer_name,city,segments)
        values(i,
        'customer ' || i,
        case MOD(i,4) when 0 then 'Chennai'
                      when 1 then 'Mumbai' 
                      when 2 then 'Banglore'
                      else 'Delhi' end,
        case MOD(i,3) when 0 then 'Retail'
                      when 1 then 'Corporate'
                      else 'Home office' end
        );
    END LOOP;
   
    FOR i IN 1..20 LOOP
        INSERT into products(product_id,product_name,categories,unit_price)
        values(i,
        'product ' || i,
        case MOD(i,3) when 0 then 'Electronics'
                      when 1 then 'Furniture'
                      else 'Stationery' end,
        i*1000
        );
    END LOOP;

    FOR i IN 1..2000 LOOP
    INSERT into sales(sale_id,sale_date,customer_id,product_id,quantity,discount)
    values(i,
        Date '2025-01-01' + MOD(i,365),
        MOD(i,100) + 1,
        MOD(i,20) + 1,
        MOD(i,5) + 1,
        MOD(i,3) * 0.05
    );
    END LOOP;
    commit;
END;
/

-- Q: (JOIN: full sales detail) What does each sale look like with customer and product info?

select s.sale_id,s.sale_date,c.customer_name,
c.city,p.product_name,p.categories,
s.quantity * p.unit_price * (1 - s.discount) as revenue
from sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN products p ON s.product_id = p.product_id;

-- Q:(GROUP BY: revenue by category, city, segment) Which category earns the most?

select p.categories, SUM(s.quantity * p.unit_price * (1 - s.discount)) as revenue
from sales s 
JOIN products p ON s.product_id = p.product_id
GROUP BY p.categories
ORDER BY revenue DESC;

-- Q: Which cities perform best?

select c.city,COUNT(*) as orders,
SUM(s.quantity * p.unit_price * (1 - s.discount)) as revenue
from sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN products p ON s.product_id = p.product_id
GROUP BY c.city
HAVING COUNT(*) > 100;

--Q: (Subquery: above-average customers) Which customers spend more than the average customer?

select customer_id,total_spent
from(
    select s.customer_id, SUM(s.quantity * p.unit_price) as total_spent
    from sales s
    JOIN products p ON s.product_id = p.product_id
    GROUP BY s.customer_id
    )
    WHERE total_spent > (
        select AVG(t) from (
            select SUM(s.quantity * p.unit_price) as t
            from sales s
            JOIN products p ON s.product_id = p.product_id
            GROUP BY s.customer_id
        )
    )
    ORDER BY total_spent DESC;

--Q (CTE: monthly revenue and growth) How is revenue trending month over month?
    
WITH monthly AS(
    select TRUNC(s.sale_date,'MM') as month,
        SUM(s.quantity * p.unit_price * (1 - s.discount)) as revenue
        from sales s 
        JOIN products p ON s.product_id = p.product_id
        GROUP BY TRUNC(s.sale_date,'MM')
)    
select month,
        ROUND(revenue,2) as revenue,
        ROUND(LAG(revenue) OVER (ORDER BY month),2) as prev_month,
        ROUND((revenue - LAG(revenue) OVER (ORDER BY month))
        / LAG(revenue) OVER (ORDER BY month) * 100,1) as growth_pct
from monthly
ORDER BY month;

-- Q: Who are the top 10 customers by spend?
    
select * from (
    select c.customer_name,
        SUM(s.quantity * p.unit_price * (1 - s.discount)) as total_spent,
        RANK() OVER(ORDER BY SUM(s.quantity * p.unit_price * (1 - s.discount))DESC) as spend_rank
    from sales s
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN products p ON s.product_id = p.product_id
    GROUP BY c.customer_name
    )
    where spend_rank <= 10;   

-- Q: What are the top 3 products in each category?
    
with product_rev as(
    select p.categories,p.product_name,
        SUM(s.quantity * p.unit_price * (1 - s.discount)) as revenue
        from sales s
        JOIN products p ON s.product_id = p.product_id
        GROUP BY p.categories,p.product_name
)    
select * from(
    select categories,product_name,
        RANK() OVER(PARTITION BY categories ORDER BY revenue DESC) as rank
        from product_rev
    )
    where rank <= 3; 

-- Q: What is the cumulative revenue over the year?    
    
select TRUNC(s.sale_date,'MM') as month,
    ROUND(SUM(SUM(s.quantity * p.unit_price * (1 - s.discount)))
        OVER (ORDER BY TRUNC(s.sale_date,'MM')),2) as running_revenue
    from sales s
    JOIN products p ON s.product_id = p.product_id
    GROUP BY TRUNC(s.sale_date,'MM')
    ORDER BY month;
