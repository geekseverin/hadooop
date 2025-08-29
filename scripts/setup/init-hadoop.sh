#!/bin/bash

echo "=== Initialisation Hadoop ==="

# Formatage du NameNode
if [ ! -f /opt/hadoop/data/namenode/current/VERSION ]; then
    echo "Formatage du NameNode..."
    $HADOOP_HOME/bin/hdfs namenode -format -force
fi

# Démarrage HDFS
echo "Démarrage HDFS..."
$HADOOP_HOME/sbin/start-dfs.sh

# Démarrage YARN
echo "Démarrage YARN..."
$HADOOP_HOME/sbin/start-yarn.sh

# Démarrage JobHistory Server
echo "Démarrage JobHistory Server..."
$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver

# Création des répertoires HDFS
echo "Création des répertoires HDFS..."
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /data
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /output
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /spark-logs

# Copie des données
echo "Copie des données vers HDFS..."
$HADOOP_HOME/bin/hdfs dfs -put /data/*.csv /data/

echo "Hadoop initialisé avec succès!"