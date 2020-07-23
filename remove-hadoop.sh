#!/bin/bash
kubectl delete -f datanode.yaml
kubectl delete -f namenode.yaml
kubectl delete -f configMap.yaml
kubectl delete -f config-pv-pvc.yaml 
kubectl delete -f hdfs-name-pv-pvc.yaml
rm -rf /mnt/data/hdfs/name/*
rm -rf /mnt/data/hadoop-config/*
