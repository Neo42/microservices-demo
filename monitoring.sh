#!/bin/bash

# Wrapper script for monitoring tools

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MONITORING_SCRIPTS_DIR="$SCRIPT_DIR/monitoring/scripts"

# Check if the command is for setup
if [ "$1" == "setup" ]; then
  $MONITORING_SCRIPTS_DIR/setup-monitoring.sh
  exit $?
fi

# Check if the command is for background services
if [ "$1" == "service" ]; then
  shift
  $MONITORING_SCRIPTS_DIR/background-services.sh "$@"
  exit $?
fi

# Otherwise, pass to monitoring-tools.sh
$MONITORING_SCRIPTS_DIR/monitoring-tools.sh "$@"
exit $?
