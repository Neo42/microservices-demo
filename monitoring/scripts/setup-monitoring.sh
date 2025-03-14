#!/bin/bash

# This script sets up the monitoring infrastructure (Prometheus and Grafana)
# for visualizing the three key metrics:
# 1. Requests per second
# 2. CPU utilization
# 3. Response time
# Note: Currently, only the frontend service has metrics implemented.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MONITORING_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

# Check if minikube is running
if ! minikube status | grep -q "host: Running"; then
  echo "Minikube is not running. Please start minikube first."
  exit 1
fi

# Apply Prometheus configuration
echo "Setting up Prometheus..."
kubectl apply -f $MONITORING_DIR/prometheus.yaml

# Apply Grafana ConfigMaps
echo "Setting up Grafana ConfigMaps..."
kubectl apply -f $MONITORING_DIR/grafana-configmaps.yaml

# Apply Grafana deployment
echo "Setting up Grafana..."
kubectl apply -f $MONITORING_DIR/grafana.yaml

echo "Monitoring setup complete!"
echo "You can access the services using:"
echo "  $SCRIPT_DIR/background-services.sh start grafana    # Grafana dashboard"
echo "  $SCRIPT_DIR/background-services.sh start prometheus # Prometheus metrics"
echo ""
echo "The dashboard shows three key metrics:"
echo "  1. Requests per second"
echo "  2. CPU utilization"
echo "  3. Response time"
