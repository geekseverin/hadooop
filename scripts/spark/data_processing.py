from pyspark.sql import SparkSession
from pyspark.sql.functions import col, avg, sum, count, max, min, when
from pyspark.sql.types import *

def main():
    # Création de la session Spark
    spark = SparkSession.builder \
        .appName("BigDataAnalysis") \
        .getOrCreate()
    
    # Lecture des données CSV
    employees_df = spark.read.csv("/data/sample_data.csv", header=True, inferSchema=True)
    sales_df = spark.read.csv("/data/sales_data.csv", header=True, inferSchema=True)
    
    print("=== ANALYSE DES EMPLOYÉS ===")
    employees_df.show()
    
    # Analyse des employés par ville
    city_analysis = employees_df.groupBy("city") \
        .agg(count("*").alias("employee_count"),
             avg("salary").alias("avg_salary"),
             max("salary").alias("max_salary"),
             min("salary").alias("min_salary"))
    
    print("Analyse par ville:")
    city_analysis.show()
    
    # Sauvegarde
    city_analysis.coalesce(1).write.mode("overwrite") \
        .csv("/output/spark_city_analysis", header=True)
    
    print("=== ANALYSE DES VENTES ===")
    sales_df.show()
    
    # Calcul du chiffre d'affaires
    sales_with_revenue = sales_df.withColumn("revenue", col("price") * col("quantity"))
    
    # Analyse par région
    region_analysis = sales_with_revenue.groupBy("region") \
        .agg(count("*").alias("product_count"),
             sum("revenue").alias("total_revenue"),
             avg("revenue").alias("avg_revenue"))
    
    print("Analyse par région:")
    region_analysis.show()
    
    # Top 10 des produits
    top_products = sales_with_revenue.orderBy(col("revenue").desc()).limit(10)
    
    print("Top 10 des produits:")
    top_products.show()
    
    # Sauvegarde des résultats
    region_analysis.coalesce(1).write.mode("overwrite") \
        .csv("/output/spark_region_analysis", header=True)
    
    top_products.coalesce(1).write.mode("overwrite") \
        .csv("/output/spark_top_products", header=True)
    
    print("Analyse terminée avec succès!")
    
    spark.stop()

if __name__ == "__main__":
    main()