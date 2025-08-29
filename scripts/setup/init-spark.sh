#!/bin/bash

echo "=== Initialisation Spark ==="

# Démarrage Spark Master
$SPARK_HOME/sbin/start-master.sh

# Démarrage Spark Workers sur les nœuds workers
$SPARK_HOME/sbin/start-slaves.sh

echo "Spark initialisé avec succès!"