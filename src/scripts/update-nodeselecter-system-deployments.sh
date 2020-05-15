#!/bin/bash

kubectl -n kube-system patch deployments coredns -p '{"spec": {"template": {"spec": {"nodeSelector": {"kubernetes.azure.com/mode": "system","beta.kubernetes.io/os": "linux"}}}}}'

kubectl -n kube-system patch deployments coredns-autoscaler -p '{"spec": {"template": {"spec": {"nodeSelector": {"kubernetes.azure.com/mode": "system","beta.kubernetes.io/os": "linux"}}}}}'

kubectl -n kube-system patch deployments tunnelfront -p '{"spec": {"template": {"spec": {"nodeSelector": {"kubernetes.azure.com/mode": "system","beta.kubernetes.io/os": "linux"}}}}}'

kubectl -n kube-system patch deployments metrics-server -p '{"spec": {"template": {"spec": {"nodeSelector": {"kubernetes.azure.com/mode": "system","beta.kubernetes.io/os": "linux"}}}}}'
