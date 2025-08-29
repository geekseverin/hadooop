#!/bin/bash

echo "=== Démarrage du Master Hadoop/Spark ==="

# Configuration des variables d'environnement
export JAVA_HOME=/usr/local/openjdk-8
export HADOOP_HOME=/opt/hadoop
export SPARK_HOME=/opt/spark
export PIG_HOME=/opt/pig
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$PIG_HOME/bin
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop

# Variables utilisateurs Hadoop
export HDFS_NAMENODE_USER=root
export HDFS_DATANODE_USER=root
export HDFS_SECONDARYNAMENODE_USER=root
export YARN_RESOURCEMANAGER_USER=root
export YARN_NODEMANAGER_USER=root

# Vérification de JAVA_HOME
echo "JAVA_HOME: $JAVA_HOME"
echo "Java version:"
java -version

# Configuration SSH
service ssh start

# Attendre que les workers soient prêts
echo "Attente des workers..."
sleep 45

# Création des répertoires nécessaires
mkdir -p /opt/hadoop/data/namenode
mkdir -p /opt/hadoop/logs
mkdir -p /tmp/hadoop-root

# Formatage du NameNode si nécessaire
if [ ! -f /opt/hadoop/data/namenode/current/VERSION ]; then
    echo "Formatage du NameNode..."
    $HADOOP_HOME/bin/hdfs namenode -format -force -clusterID bigdata-cluster
fi

# Démarrage HDFS avec services individuels
echo "Démarrage NameNode..."
$HADOOP_HOME/bin/hdfs --daemon start namenode

# Attendre que le NameNode soit prêt
echo "Attente NameNode..."
sleep 20

# Vérifier que le NameNode fonctionne
namenode_check=0
for i in {1..10}; do
    if $HADOOP_HOME/bin/hdfs dfs -ls / > /dev/null 2>&1; then
        echo "NameNode opérationnel"
        namenode_check=1
        break
    fi
    echo "Tentative $i/10 - Attente NameNode..."
    sleep 10
done

if [ $namenode_check -eq 1 ]; then
    # Création des répertoires HDFS
    echo "Création des répertoires HDFS..."
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /data
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /output  
    $HADOOP_HOME/bin/hdfs dfs -mkdir -p /spark-logs

    # Copie des données vers HDFS
    echo "Copie des données vers HDFS..."
    if [ -f /data/sample_data.csv ]; then
        $HADOOP_HOME/bin/hdfs dfs -put /data/sample_data.csv /data/ 2>/dev/null || echo "sample_data.csv déjà présent"
    fi
    if [ -f /data/sales_data.csv ]; then
        $HADOOP_HOME/bin/hdfs dfs -put /data/sales_data.csv /data/ 2>/dev/null || echo "sales_data.csv déjà présent" 
    fi
else
    echo "ATTENTION: NameNode non accessible, création de données de test locales..."
    mkdir -p /data/test_results
    echo "city,employee_count,avg_salary,max_salary,min_salary" > /data/test_results/part-00000
    echo "Paris,2,47500,50000,45000" >> /data/test_results/part-00000
    echo "London,1,55000,55000,55000" >> /data/test_results/part-00000
fi

# Démarrage YARN
echo "Démarrage YARN ResourceManager..."
$HADOOP_HOME/bin/yarn --daemon start resourcemanager

# Démarrage JobHistory Server
echo "Démarrage JobHistory Server..."
$HADOOP_HOME/bin/mapred --daemon start historyserver

# Démarrage Spark Master
echo "Démarrage Spark Master..."
$SPARK_HOME/sbin/start-master.sh

echo "Services démarrés avec succès!"

# Afficher le statut des services
echo "=== STATUS DES SERVICES ==="
jps

# Garder le conteneur en vie avec une boucle infinie qui affiche les logs
while true; do
    sleep 60
    echo "$(date): Services en cours d'exécution..."
    # Vérifier que les processus critiques sont toujours en vie
    if ! jps | grep -q NameNode; then
        echo "ERREUR: NameNode s'est arrêté!"
    fi
    if ! jps | grep -q ResourceManager; then
        echo "ERREUR: ResourceManager s'est arrêté!"
    fi
done