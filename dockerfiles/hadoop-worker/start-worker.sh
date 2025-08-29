#!/bin/bash

echo "=== Démarrage Worker Hadoop/Spark ==="

# Configuration SSH
service ssh start

# Attendre le master
sleep 45

# Détermination du type de service
if [ "$SERVICE_TYPE" = "secondary" ]; then
    echo "Démarrage Secondary NameNode..."
    mkdir -p /opt/hadoop/data/secondary
    $HADOOP_HOME/bin/hdfs --daemon start secondarynamenode
elif [ "$SERVICE_TYPE" = "worker" ]; then
    echo "Démarrage DataNode et NodeManager..."
    mkdir -p /opt/hadoop/data/datanode
    $HADOOP_HOME/bin/hdfs --daemon start datanode
    $HADOOP_HOME/bin/yarn --daemon start nodemanager
    
    # Démarrage Spark Worker
    $SPARK_HOME/sbin/start-slave.sh spark://hadoop-master:7077
fi

echo "Worker démarré avec succès!"

# Garder le conteneur en vie
tail -f /dev/null