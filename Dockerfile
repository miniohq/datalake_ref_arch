## Starting from Ubuntu
FROM --platform=linux/amd64 ubuntu:22.04

## Create a Non-Root User
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends dialog apt-utils
RUN apt-get update && apt-get -y install sudo && apt-get install wget -y && apt-get install curl -y && apt-get install nano
RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

## Switch to Non-Root User
USER docker

## Set Home to Workdir
WORKDIR /home/docker/

## Install TZData
RUN DEBIAN_FRONTEND=noninteractive TZ="America/New York" sudo -E apt-get -y install tzdata

## Install Git
RUN sudo apt install git -y

## Install Java 17
RUN sudo wget https://download.java.net/java/GA/jdk17/0d483333a00540d886896bac774ff48b/35/GPL/openjdk-17_linux-x64_bin.tar.gz
RUN sudo tar xvf openjdk-17_linux-x64_bin.tar.gz
RUN sudo mv jdk-17 /opt/
RUN echo 'JAVA_HOME=/opt/jdk-17' >> ~/.bashrc
RUN echo 'PATH=$PATH:$JAVA_HOME/bin' >> ~/.bashrc
RUN echo "alias java17='/opt/jdk-17/bin/java'" >> ~/.bashrc
RUN . ~/.bashrc

## Install Java 11 for Spark
RUN sudo apt-get install openjdk-11-jdk -y

## Install Python 2, 3 and Pip/Pip3
RUN sudo apt-get install python2 python3 pip -y

## Insall Coursier - a scala application and artifact manager
RUN curl -fL https://github.com/coursier/launchers/raw/master/cs-x86_64-pc-linux.gz | gzip -d > cs
RUN sudo chmod +x cs 
RUN ./cs setup -y
RUN sudo ./cs install scala3
RUN sudo ./cs install scala3-compiler
RUN echo 'PATH=$PATH:~/.local/share/coursier/bin' >> ~/.bashrc
RUN . ~/.bashrc

## Install Apache Spark
RUN sudo apt-get install python3 python3-dev -y
RUN sudo wget https://dlcdn.apache.org/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz
RUN sudo wget https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.4.3/iceberg-spark-runtime-3.5_2.12-1.4.3.jar
RUN sudo mkdir -p /opt/spark/jars
RUN sudo mv iceberg-spark-runtime-3.5_2.12-1.4.3.jar /opt/spark/jars/
RUN sudo chown docker:docker /opt/spark/jars/iceberg-spark-runtime-3.5_2.12-1.4.3.jar
# RUN sudo tar -xvzf spark-3.3.0-bin-hadoop3.2.tgz -C /opt/spark
RUN sudo tar -xf spark-3.5.0-bin-hadoop3.tgz -C /opt/spark --strip-component 1
RUN sudo chmod -R 777 /opt/spark
RUN echo 'SPARK_HOME=/opt/spark' >> ~/.bashrc
RUN echo 'PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin' >> ~/.bashrc
RUN echo 'PYSPARK_PYTHON=/usr/bin/python3' >> ~/.bashrc
RUN echo 'SPARK_MASTER_HOST=0.0.0.0' >> ~/.bashrc
RUN . ~/.bashrc

RUN pip install notebook pyspark

EXPOSE 8888
EXPOSE 8080
EXPOSE 8081
EXPOSE 7077
EXPOSE 4040
EXPOSE 18080
EXPOSE 19120

## Start Container
CMD ~/.local/bin/jupyter-notebook --ip 0.0.0.0