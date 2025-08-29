-- Chargement des données de ventes
sales = LOAD '/data/sales_data.csv' USING PigStorage(',') 
        AS (product_id:int, product_name:chararray, category:chararray, 
            price:double, quantity:int, sales_date:chararray, region:chararray);

-- Nettoyage des données
clean_sales = FILTER sales BY product_id IS NOT NULL AND product_id > 0;

-- Calcul du chiffre d'affaires
sales_with_revenue = FOREACH clean_sales GENERATE 
    product_id,
    product_name,
    category,
    price,
    quantity,
    (price * quantity) AS revenue,
    region;

-- Analyse par région
region_stats = GROUP sales_with_revenue BY region;
region_analysis = FOREACH region_stats GENERATE 
    group AS region,
    COUNT(sales_with_revenue) AS product_count,
    SUM(sales_with_revenue.revenue) AS total_revenue,
    AVG(sales_with_revenue.revenue) AS avg_revenue;

STORE region_analysis INTO '/output/region_analysis' USING PigStorage(',');

-- Top produits par chiffre d'affaires
top_products = ORDER sales_with_revenue BY revenue DESC;
top_10_products = LIMIT top_products 10;

STORE top_10_products INTO '/output/top_products' USING PigStorage(',');

DUMP region_analysis;
DUMP top_10_products;