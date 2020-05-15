#!/bin/bash

kubectl -n kube-system rollout restart deployment coredns

kubectl -n kube-system rollout restart deployment coredns-autoscaler

kubectl -n kube-system rollout restart deployment tunnelfront

kubectl -n kube-system rollout restart deployment metrics-server
