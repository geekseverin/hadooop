FROM openjdk:8-jdk-slim

# Installation des outils de base avec gestion des erreurs réseau
RUN apt-get update --allow-insecure-repositories && apt-get install -y --allow-unauthenticated \
    wget \
    curl \
    ssh \
    rsync \
    vim \
    python3 \
    python3-pip \
    netcat \
    sudo \
    && rm -rf /var/lib/apt/lists/* || true

# Variables d'environnement - JAVA_HOME corrigé
ENV JAVA_HOME=/usr/local/openjdk-8
ENV HADOOP_VERSION=3.3.4
ENV SPARK_VERSION=3.4.1
ENV PIG_VERSION=0.17.0
ENV HADOOP_HOME=/opt/hadoop
ENV SPARK_HOME=/opt/spark
ENV PIG_HOME=/opt/pig
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$PIG_HOME/bin

# Configuration Hadoop pour JAVA_HOME
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop

# Installation Hadoop
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && \
    tar -xzf hadoop-$HADOOP_VERSION.tar.gz && \
    mv hadoop-$HADOOP_VERSION $HADOOP_HOME && \
    rm hadoop-$HADOOP_VERSION.tar.gz

# Installation Spark
RUN wget https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop3.tgz && \
    tar -xzf spark-$SPARK_VERSION-bin-hadoop3.tgz && \
    mv spark-$SPARK_VERSION-bin-hadoop3 $SPARK_HOME && \
    rm spark-$SPARK_VERSION-bin-hadoop3.tgz

# Installation Pig
RUN wget https://archive.apache.org/dist/pig/pig-$PIG_VERSION/pig-$PIG_VERSION.tar.gz && \
    tar -xzf pig-$PIG_VERSION.tar.gz && \
    mv pig-$PIG_VERSION $PIG_HOME && \
    rm pig-$PIG_VERSION.tar.gz

# Configuration des fichiers d'environnement Hadoop avec variables utilisateurs
RUN echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_NAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_DATANODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_SECONDARYNAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export YARN_RESOURCEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export YARN_NODEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export JAVA_HOME=$JAVA_HOME" >> $SPARK_HOME/conf/spark-env.sh

# Configuration SSH
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys && \
    echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

# Installation connecteur MongoDB
RUN wget https://repo1.maven.org/maven2/org/mongodb/mongo-hadoop/mongo-hadoop-core/2.0.2/mongo-hadoop-core-2.0.2.jar -P $HADOOP_HOME/share/hadoop/common/lib/ && \
    wget https://repo1.maven.org/maven2/org/mongodb/mongodb-driver/3.12.11/mongodb-driver-3.12.11.jar -P $HADOOP_HOME/share/hadoop/common/lib/

# Créer un fichier log4j.properties basique
RUN echo "log4j.rootLogger=WARN, console" > $HADOOP_HOME/etc/hadoop/log4j.properties && \
    echo "log4j.appender.console=org.apache.log4j.ConsoleAppender" >> $HADOOP_HOME/etc/hadoop/log4j.properties && \
    echo "log4j.appender.console.layout=org.apache.log4j.PatternLayout" >> $HADOOP_HOME/etc/hadoop/log4j.properties && \
    echo "log4j.appender.console.layout.ConversionPattern=%d{yy/MM/dd HH:mm:ss} %p %c{1}: %m%n" >> $HADOOP_HOME/etc/hadoop/log4j.properties

WORKDIR /opt