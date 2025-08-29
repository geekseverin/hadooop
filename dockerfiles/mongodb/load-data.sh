#!/bin/bash

echo "=== Chargement des données MongoDB ==="

# Attente du démarrage de MongoDB
sleep 15

# Import des données CSV si elles existent
if [ -f /data/csv/sample_data.csv ]; then
    mongoimport --host localhost:27017 \
        --username admin --password password --authenticationDatabase admin \
        --db bigdata --collection employees \
        --type csv --file /data/csv/sample_data.csv --headerline \
        --drop || echo "Import terminé"
fi

echo "Données chargées dans MongoDB!"