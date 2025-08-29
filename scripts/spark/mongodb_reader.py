from pyspark.sql import SparkSession
from pymongo import MongoClient
import pandas as pd

def main():
    # Création de la session Spark
    spark = SparkSession.builder \
        .appName("MongoDBReader") \
        .config("spark.mongodb.input.uri", "mongodb://admin:password@mongodb:27017/bigdata.employees?authSource=admin") \
        .config("spark.mongodb.output.uri", "mongodb://admin:password@mongodb:27017/bigdata.results?authSource=admin") \
        .getOrCreate()
    
    try:
        # Connexion à MongoDB
        client = MongoClient('mongodb://admin:password@mongodb:27017/?authSource=admin')
        db = client.bigdata
        
        # Lecture des données depuis MongoDB
        employees_collection = db.employees
        employees_data = list(employees_collection.find())
        
        if employees_data:
            # Conversion en DataFrame Spark
            employees_df = spark.createDataFrame(employees_data)
            
            print("Données lues depuis MongoDB:")
            employees_df.show()
            
            # Analyse simple
            analysis = employees_df.groupBy("city") \
                .agg({"salary": "avg", "*": "count"}) \
                .withColumnRenamed("avg(salary)", "avg_salary") \
                .withColumnRenamed("count(1)", "employee_count")
            
            print("Analyse des données MongoDB:")
            analysis.show()
            
            # Sauvegarde
            analysis.coalesce(1).write.mode("overwrite") \
                .csv("/output/mongodb_analysis", header=True)
        else:
            print("Aucune donnée trouvée dans MongoDB")
    
    except Exception as e:
        print(f"Erreur lors de la lecture MongoDB: {e}")
    
    finally:
        spark.stop()

if __name__ == "__main__":
    main()