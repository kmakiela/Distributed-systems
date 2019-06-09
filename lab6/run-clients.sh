#!/bin/bash

gnome-terminal -- ./apache-zookeeper-3.5.5-bin/bin/zkCli.sh -server localhost:2181
gnome-terminal -- ./apache-zookeeper-3.5.5-bin/bin/zkCli.sh -server localhost:2182
gnome-terminal -- ./apache-zookeeper-3.5.5-bin/bin/zkCli.sh -server localhost:2183

