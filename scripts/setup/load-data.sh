#!/bin/bash

echo "=== Chargement des données ==="

# Attente MongoDB
sleep 10

# Chargement des données dans MongoDB
mongoimport --host mongodb:27017 \
    --username admin --password password --authenticationDatabase admin \
    --db bigdata --collection employees \
    --type csv --file /data/csv/sample_data.csv --headerline

echo "Données chargées dans MongoDB avec succès!"