#!/bin/bash

# create namespace
kubectl create ns gpu-operator
kubectl label --overwrite ns gpu-operator pod-security.kubernetes.io/enforce=privileged

# add nvidia helm repo
helm repo add nvidia https://nvidia.github.io/gpu-operator && helm repo update

# helm install
helm install nvidia/gpu-operator \
    --set driver.enabled=false \
    --set toolkit.enabled=false \
    --debug \
    --wait \
    --namespace gpu-operator \
    --generate-name

# check logs for dcgm metrics exporter
POD_NAME=
kubectl logs $POD_NAME -n gpu-operator | grep -i dcgm