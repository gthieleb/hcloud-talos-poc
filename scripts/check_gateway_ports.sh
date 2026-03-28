#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <gateway_host> <check_kube:true|false> <check_talos:true|false>"
  exit 1
fi

gateway_host="$1"
check_kube="$2"
check_talos="$3"

if [ -z "$gateway_host" ] || [ "$gateway_host" = "null" ]; then
  echo "Gateway host is empty/null"
  exit 1
fi

if [ "$check_kube" = "true" ]; then
  echo "Checking gateway kube API port 6443 on ${gateway_host}"
  nc -z -w 5 "$gateway_host" 6443
fi

if [ "$check_talos" = "true" ]; then
  echo "Checking gateway Talos API port 50000 on ${gateway_host}"
  nc -z -w 5 "$gateway_host" 50000
fi

echo "Gateway port checks passed"
