FROM openjdk:8-jdk-slim

# Installation des outils de base
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    ssh \
    rsync \
    vim \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Variables d'environnement
ENV JAVA_HOME=/usr/local/openjdk-8
ENV HADOOP_VERSION=3.3.4
ENV SPARK_VERSION=3.4.1
ENV PIG_VERSION=0.17.0
ENV HADOOP_HOME=/opt/hadoop
ENV SPARK_HOME=/opt/spark
ENV PIG_HOME=/opt/pig
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$PIG_HOME/bin

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

# Configuration SSH
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

# Installation connecteur MongoDB
RUN wget https://repo1.maven.org/maven2/org/mongodb/mongo-hadoop/mongo-hadoop-core/2.0.2/mongo-hadoop-core-2.0.2.jar -P $HADOOP_HOME/share/hadoop/common/lib/ && \
    wget https://repo1.maven.org/maven2/org/mongodb/mongodb-driver/3.12.11/mongodb-driver-3.12.11.jar -P $HADOOP_HOME/share/hadoop/common/lib/

WORKDIR /opt