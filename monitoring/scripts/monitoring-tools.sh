#!/bin/bash

# monitoring-tools.sh - Helper script for monitoring tasks

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function show_usage {
  echo "Usage: $0 [command]"
  echo ""
  echo "Commands:"
  echo "  start           - Start all monitoring services"
  echo "  status          - Check status of monitoring services"
  echo "  restart         - Restart all monitoring services"
  echo "  logs [service]  - Show logs for a specific service (grafana, prometheus, locust)"
  echo "  urls            - Show URLs for all monitoring services"
  echo "  help            - Show this help message"
  echo ""
}

function start_services {
  echo "Starting monitoring services..."
  $SCRIPT_DIR/background-services.sh start all
  echo "Services started. Use '$SCRIPT_DIR/monitoring-tools.sh urls' to see access URLs."
}

function check_status {
  echo "Checking monitoring services status..."
  echo ""
  echo "Grafana:"
  kubectl get pods | grep grafana
  echo ""
  echo "Prometheus:"
  kubectl get pods | grep prometheus
  echo ""
  echo "Locust:"
  kubectl get pods | grep locust
  echo ""
  echo "Service endpoints:"
  kubectl get svc | grep -E 'grafana|prometheus|locust'
}

function restart_services {
  echo "Restarting monitoring services..."
  $SCRIPT_DIR/background-services.sh stop all
  sleep 2
  $SCRIPT_DIR/background-services.sh start all
  echo "Services restarted. Use '$SCRIPT_DIR/monitoring-tools.sh urls' to see access URLs."
}

function show_logs {
  if [ -z "$1" ]; then
    echo "Error: Please specify a service (grafana, prometheus, locust)"
    exit 1
  fi

  service=$1
  pod=$(kubectl get pods | grep $service | awk '{print $1}')

  if [ -z "$pod" ]; then
    echo "Error: No pod found for service $service"
    exit 1
  fi

  echo "Showing logs for $service pod ($pod)..."
  kubectl logs $pod
}

function show_urls {
  echo "Monitoring URLs:"
  echo "  Grafana:    http://localhost:3000"
  echo "  Prometheus: http://localhost:9090"
  echo "  Locust:     http://localhost:8089"
  echo ""
  echo "Grafana login (if prompted):"
  echo "  Username: admin"
  echo "  Password: admin"
}

# Main script logic
if [ $# -eq 0 ]; then
  show_usage
  exit 0
fi

command=$1
shift

case $command in
  start)
    start_services
    ;;
  status)
    check_status
    ;;
  restart)
    restart_services
    ;;
  logs)
    show_logs $1
    ;;
  urls)
    show_urls
    ;;
  help)
    show_usage
    ;;
  *)
    echo "Unknown command: $command"
    show_usage
    exit 1
    ;;
esac

exit 0
