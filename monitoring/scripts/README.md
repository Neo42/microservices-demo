# Monitoring Scripts

This directory contains scripts for setting up and managing the monitoring infrastructure for the microservices demo.

## Scripts

- `setup-monitoring.sh`: Sets up Prometheus and Grafana in the Kubernetes cluster
- `background-services.sh`: Manages port forwarding for services (Grafana, Prometheus, etc.)
- `monitoring-tools.sh`: Provides utilities for monitoring tasks (starting services, checking status, etc.)

## Usage

It's recommended to use the wrapper script in the root directory:

```bash
# Set up monitoring infrastructure
./monitoring.sh setup

# Start services
./monitoring.sh service start grafana
./monitoring.sh service start prometheus
./monitoring.sh service start all

# Stop services
./monitoring.sh service stop grafana
./monitoring.sh service stop all

# Check status
./monitoring.sh status

# Show URLs
./monitoring.sh urls

# Show logs
./monitoring.sh logs grafana
```

## Monitoring Dashboard

The Grafana dashboard shows the following metrics:

1. Requests per Second
2. CPU Utilization
3. Average Response Time
4. 95th Percentile Response Time

Access Grafana at http://localhost:3000 after starting the service.
