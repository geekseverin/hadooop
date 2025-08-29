#!/bin/bash

echo "=== DÉMARRAGE DU PROJET BIG DATA ==="

# Nettoyage des anciens conteneurs
echo "Nettoyage des anciens conteneurs..."
docker-compose down 2>/dev/null || true

# Build de l'image de base Hadoop
echo "Construction de l'image de base..."
docker build -t hadoop-base:latest ./dockerfiles/hadoop-base/

# Démarrage des services
echo "Démarrage des conteneurs..."
docker-compose up -d

# Attendre que les services soient prêts
echo "Attente du démarrage des services..."
sleep 30

# Vérifier que les conteneurs sont en cours d'exécution
echo "Vérification des conteneurs..."
docker ps --format "table {{.Names}}\t{{.Status}}"

# Attendre plus longtemps pour le démarrage complet
echo "Attente du démarrage complet (3 minutes)..."
sleep 180

# Vérifier à nouveau les conteneurs
echo "Vérification finale des conteneurs..."
docker ps --format "table {{.Names}}\t{{.Status}}"

# Vérifier spécifiquement le conteneur master
if docker ps | grep -q hadoop-master; then
    echo "Conteneur hadoop-master en cours d'exécution"
    
    # Vérifier les logs du master
    echo "Logs du master (dernières 20 lignes):"
    docker logs --tail 20 hadoop-master
    
    # Exécuter le script principal dans le conteneur master
    echo "Exécution du traitement dans le conteneur Hadoop..."
    docker exec hadoop-master /scripts/run_all.sh
else
    echo "ERREUR: Le conteneur hadoop-master ne fonctionne pas!"
    echo "Logs du conteneur hadoop-master:"
    docker logs hadoop-master
    exit 1
fi

echo "=== PROJET DÉMARRÉ ==="
echo "Dashboard disponible sur : http://localhost:5000"
echo "NameNode UI : http://localhost:9870"
echo "YARN UI : http://localhost:8088"
echo "Spark UI : http://localhost:8080"