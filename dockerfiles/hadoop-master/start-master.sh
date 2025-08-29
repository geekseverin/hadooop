#!/bin/bash

echo "=== Démarrage du Master Hadoop/Spark ==="

# Configuration SSH
service ssh start

# Attendre que les workers soient prêts
sleep 30

# Formatage du NameNode si nécessaire
if [ ! -f /opt/hadoop/data/namenode/current/VERSION ]; then
    echo "Formatage du NameNode..."
    mkdir -p /opt/hadoop/data/namenode
    $HADOOP_HOME/bin/hdfs namenode -format -force -clusterID bigdata-cluster
fi

# Démarrage HDFS
echo "Démarrage HDFS..."
$HADOOP_HOME/sbin/start-dfs.sh

# Démarrage YARN
echo "Démarrage YARN..."
$HADOOP_HOME/sbin/start-yarn.sh

# Démarrage JobHistory Server
echo "Démarrage JobHistory Server..."
$HADOOP_HOME/bin/mapred --daemon start historyserver

# Démarrage Spark Master
echo "Démarrage Spark Master..."
$SPARK_HOME/sbin/start-master.sh

# Attendre que HDFS soit prêt
sleep 20

# Création des répertoires HDFS
echo "Création des répertoires HDFS..."
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /data
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /output
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /spark-logs

# Copie des données vers HDFS
echo "Copie des données vers HDFS..."
$HADOOP_HOME/bin/hdfs dfs -put /data/*.csv /data/ || echo "Données déjà présentes"

echo "Master Hadoop/Spark démarré avec succès!"

# Garder le conteneur en vie
tail -f /opt/hadoop/logs/*.log