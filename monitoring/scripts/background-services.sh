#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 [start|stop|status] [service]"
  echo "Commands:"
  echo "  start - Start a service in the background"
  echo "  stop - Stop a running service"
  echo "  status - Check if a service is running"
  echo ""
  echo "Available services:"
  echo "  frontend - The main application"
  echo "  grafana - Grafana monitoring dashboard"
  echo "  prometheus - Prometheus metrics"
  echo "  all - All services"
  exit 1
}

# Check if command and service are provided
if [ $# -lt 2 ]; then
  usage
fi

COMMAND=$1
SERVICE=$2
LOGS_DIR="$HOME/.minikube-services"
mkdir -p "$LOGS_DIR"

# Function to get the port for a service
get_port() {
  local service=$1
  case "$service" in
    frontend-external)
      echo "80"
      ;;
    grafana)
      echo "3000"
      ;;
    prometheus)
      echo "9090"
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

# Function to get the local port for a service
get_local_port() {
  local service=$1
  case "$service" in
    frontend-external)
      echo "8080"
      ;;
    grafana)
      echo "3000"
      ;;
    prometheus)
      echo "9090"
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

# Function to start a service
start_service() {
  local service=$1
  local port=$(get_port "$service")
  local local_port=$(get_local_port "$service")

  if [ "$port" == "unknown" ]; then
    echo "Unknown service: $service"
    return 1
  fi

  # Check if service is already running
  if pgrep -f "kubectl port-forward service/$service" > /dev/null; then
    echo "$service is already running"
    return 0
  fi

  echo "Starting $service on port $local_port..."
  nohup kubectl port-forward service/$service $local_port:$port > "$LOGS_DIR/$service.log" 2>&1 &
  echo $! > "$LOGS_DIR/$service.pid"
  echo "$service started on http://localhost:$local_port"
}

# Function to stop a service
stop_service() {
  local service=$1

  if [ ! -f "$LOGS_DIR/$service.pid" ]; then
    echo "$service is not running"
    return 0
  fi

  local pid=$(cat "$LOGS_DIR/$service.pid")
  echo "Stopping $service (PID: $pid)..."
  kill $pid 2>/dev/null
  rm -f "$LOGS_DIR/$service.pid"
  echo "$service stopped"
}

# Function to check service status
status_service() {
  local service=$1

  if [ ! -f "$LOGS_DIR/$service.pid" ]; then
    echo "$service is not running"
    return 1
  fi

  local pid=$(cat "$LOGS_DIR/$service.pid")
  if ps -p $pid > /dev/null; then
    local local_port=$(get_local_port "$service")
    echo "$service is running on http://localhost:$local_port (PID: $pid)"
    return 0
  else
    echo "$service is not running (stale PID file)"
    rm -f "$LOGS_DIR/$service.pid"
    return 1
  fi
}

# Main logic
case "$COMMAND" in
  start)
    case "$SERVICE" in
      frontend)
        start_service frontend-external
        ;;
      grafana)
        start_service grafana
        ;;
      prometheus)
        start_service prometheus
        ;;
      all)
        start_service frontend-external
        start_service grafana
        start_service prometheus
        ;;
      *)
        echo "Unknown service: $SERVICE"
        usage
        ;;
    esac
    ;;
  stop)
    case "$SERVICE" in
      frontend)
        stop_service frontend-external
        ;;
      grafana)
        stop_service grafana
        ;;
      prometheus)
        stop_service prometheus
        ;;
      all)
        stop_service frontend-external
        stop_service grafana
        stop_service prometheus
        ;;
      *)
        echo "Unknown service: $SERVICE"
        usage
        ;;
    esac
    ;;
  status)
    case "$SERVICE" in
      frontend)
        status_service frontend-external
        ;;
      grafana)
        status_service grafana
        ;;
      prometheus)
        status_service prometheus
        ;;
      all)
        status_service frontend-external
        status_service grafana
        status_service prometheus
        ;;
      *)
        echo "Unknown service: $SERVICE"
        usage
        ;;
    esac
    ;;
  *)
    echo "Unknown command: $COMMAND"
    usage
    ;;
esac
