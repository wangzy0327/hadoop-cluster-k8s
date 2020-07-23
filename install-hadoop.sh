#!/bin/bash
kubectl apply -f config-pv-pvc.yaml
kubectl apply -f hdfs-name-pv-pvc.yaml
kubectl apply -f configMap.yaml
kubectl apply -f namenode.yaml
kubectl apply -f datanode.yaml
kubectl apply -f web-ui.yaml
