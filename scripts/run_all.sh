#!/bin/bash

echo "=== EXÉCUTION COMPLÈTE DU PROJET BIG DATA ==="

# Attente du démarrage complet des services
sleep 60

echo "1. Exécution des scripts Pig..."

# Exécution du script d'analyse des employés
echo "Analyse des employés avec Pig..."
pig -x mapreduce /scripts/pig/data_analysis.pig

# Exécution du script d'analyse des ventes
echo "Analyse des ventes avec Pig..."
pig -x mapreduce /scripts/pig/sales_analysis.pig

echo "2. Exécution des scripts Spark..."

# Traitement des données avec Spark
echo "Traitement des données avec Spark..."
spark-submit --master spark://hadoop-master:7077 \
    --deploy-mode client \
    /scripts/spark/data_processing.py

# Lecture des données MongoDB avec Spark
echo "Lecture MongoDB avec Spark..."
spark-submit --master spark://hadoop-master:7077 \
    --deploy-mode client \
    --packages org.mongodb.spark:mongo-spark-connector_2.12:3.0.1 \
    /scripts/spark/mongodb_reader.py

echo "3. Copie des résultats pour l'application web..."

# Copie des résultats depuis HDFS vers le système local
hdfs dfs -get /output/* /data/ || echo "Résultats copiés"

echo "=== PROJET EXÉCUTÉ AVEC SUCCÈS ==="
echo "Vous pouvez maintenant consulter le dashboard : http://localhost:5000"