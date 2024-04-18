#!/bin/bash

# exit on error
set -e

# delete minikube if -d flag is passed
if [ "$1" == "-d" ]; then
  minikube delete --all
fi

# start minikube
minikube start
ADDONS_TO_ENABLE=(metrics-server ingress)
for addon in "${ADDONS_TO_ENABLE[@]}"; do
  minikube addons enable $addon
done

# prometheus helm chart
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# crate monitoring namespace
kubectl create ns monitoring

# install prometheus
helm install prometheus prometheus-community/prometheus -n monitoring -f values/prometheus-values.yaml
kubectl expose service prometheus-server --type=LoadBalancer --port=9090 --name=prometheus-server-lb -n monitoring

# wait for prometheus to be ready
echo "Waiting for Prometheus to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=prometheus -n monitoring --timeout=300s

# grafana helm chart
helm repo add grafana https://grafana.github.io/helm-charts

# install grafana with x-frame-options disabled
helm install grafana grafana/grafana -f values/grafana-values.yaml -n monitoring
kubectl expose service grafana --type=LoadBalancer --port=3000 --name=grafana-lb -n monitoring

# print grafana password
kubectl get secret -n monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# wait for grafana to be ready
echo "Waiting for Grafana to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=grafana -n monitoring --timeout=300s

# start minikube tunnel
minikube tunnel