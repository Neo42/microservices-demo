# Microservices Monitoring

This directory contains the configuration files for monitoring the microservices demo application. The monitoring setup includes:

- **Prometheus**: For collecting and storing metrics
- **Grafana**: For visualizing metrics in dashboards

## Key Metrics

The monitoring setup focuses on four key metrics:

1. **Requests per Second**: Tracks the rate of incoming HTTP requests
2. **CPU Utilization**: Monitors the CPU usage of services
3. **Average Response Time**: Measures how long requests take to process on average
4. **95th Percentile Response Time**: Shows the response time threshold for 95% of requests

## Scripts

All monitoring scripts have been moved to the `scripts/` directory:

- `setup-monitoring.sh`: Sets up Prometheus and Grafana in the Kubernetes cluster
- `background-services.sh`: Manages port forwarding for services (Grafana, Prometheus, etc.)
- `monitoring-tools.sh`: Provides utilities for monitoring tasks (starting services, checking status, etc.)

A wrapper script `monitoring.sh` is available in the root directory for easier access.

## Setup

To set up the monitoring infrastructure:

```bash
./monitoring.sh setup
```

## Accessing Dashboards

After setting up the monitoring infrastructure, you can access the dashboards using:

```bash
# Start Grafana dashboard
./monitoring.sh service start grafana

# Start Prometheus UI
./monitoring.sh service start prometheus
```

Grafana will be available at http://localhost:3000 and Prometheus at http://localhost:9090.

## Monitoring Commands

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

## Dashboard Details

The Grafana dashboard includes four panels:

1. **Requests per Second**: Shows the rate of HTTP requests to the frontend service
2. **CPU Utilization**: Displays the CPU usage percentage of the frontend service
3. **Average Response Time**: Shows the average response time for requests
4. **95th Percentile Response Time**: Shows the 95th percentile response time threshold

## Adding Metrics for Other Services

Currently, only the frontend service has metrics implemented. To add metrics for other services:

1. Implement metrics collection in the service code (similar to frontend/metrics.go)
2. Ensure the service exposes a /metrics endpoint
3. Add appropriate annotations to the service's Kubernetes manifest to enable Prometheus scraping

The dashboard is designed to automatically include new services as they implement the same metric patterns.
