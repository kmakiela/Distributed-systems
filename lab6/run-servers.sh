#!/bin/bash

rm -rf /home/krzysztof/zk-data

mkdir -p /home/krzysztof/zk-data/zk1 
mkdir -p /home/krzysztof/zk-data/zk2 
mkdir -p /home/krzysztof/zk-data/zk3 

echo "1" >> /home/krzysztof/zk-data/zk1/myid
echo "2" >> /home/krzysztof/zk-data/zk2/myid
echo "3" >> /home/krzysztof/zk-data/zk3/myid

gnome-terminal -- ./apache-zookeeper-3.5.5-bin/bin/zkServer.sh start-foreground zk1.cfg
gnome-terminal -- ./apache-zookeeper-3.5.5-bin/bin/zkServer.sh start-foreground zk2.cfg
gnome-terminal -- ./apache-zookeeper-3.5.5-bin/bin/zkServer.sh start-foreground zk3.cfg

