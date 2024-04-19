#!/bin/bash

set -e

# Delete the resource-quota namespace if it exists
kubectl delete ns resource-quota || true

# create namespace with resource quota
kubectl create ns resource-quota

# create resource quota
kubectl apply -f manifests/resource-quota.yaml -n resource-quota


# create a pod that does not exceed the resource quota
kubectl apply -f manifests/pod-does-not-exceed-quota.yaml -n resource-quota

# create a pod that exceeds the resource quota
# this will fail!!! 
# kubectl apply -f manifests/pod-exceeds-quota.yaml -n resource-quota