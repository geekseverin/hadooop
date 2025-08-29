#!/bin/bash

echo "=== Démarrage Worker Hadoop/Spark ==="

# Configuration SSH
service ssh start

# Attendre le master
echo "Attente du master..."
sleep 60

# Création des répertoires nécessaires selon le type
if [ "$SERVICE_TYPE" = "secondary" ]; then
    mkdir -p /opt/hadoop/data/secondary
elif [ "$SERVICE_TYPE" = "worker" ]; then
    mkdir -p /opt/hadoop/data/datanode
fi

# Attendre que le NameNode soit accessible
echo "Vérification de la connexion au NameNode..."
namenode_ready=0
for i in {1..20}; do
    if nc -z hadoop-master 9000 > /dev/null 2>&1; then
        echo "NameNode accessible"
        namenode_ready=1
        break
    fi
    echo "Tentative $i/20 - Attente NameNode..."
    sleep 10
done

if [ $namenode_ready -eq 0 ]; then
    echo "ERREUR: Impossible de se connecter au NameNode"
fi

# Détermination du type de service
if [ "$SERVICE_TYPE" = "secondary" ]; then
    echo "Démarrage Secondary NameNode..."
    $HADOOP_HOME/bin/hdfs --daemon start secondarynamenode
elif [ "$SERVICE_TYPE" = "worker" ]; then
    echo "Démarrage DataNode et NodeManager..."
    $HADOOP_HOME/bin/hdfs --daemon start datanode
    
    # Attendre un peu avant de démarrer NodeManager
    sleep 15
    $HADOOP_HOME/bin/yarn --daemon start nodemanager
    
    # Démarrage Spark Worker
    sleep 10
    $SPARK_HOME/sbin/start-worker.sh spark://hadoop-master:7077
fi

echo "Worker démarré avec succès!"

# Afficher le statut
echo "=== STATUS DU WORKER ==="
jps

# Garder le conteneur en vie
while true; do
    sleep 60
    echo "$(date): Worker en cours d'exécution..."
done