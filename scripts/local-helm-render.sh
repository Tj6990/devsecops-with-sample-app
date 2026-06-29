#!/usr/bin/env bash
set -euo pipefail
ENVIRONMENT="${1:-dev}"
SERVICE_NAME="${2:-app}"
IMAGE_REPO="us-east4-docker.pkg.dev/controlled-substance-np-a3ea/controlled-substance-np-useast4/${SERVICE_NAME}"
helm template "${SERVICE_NAME}" ./helm/app-chart \
  -f "./values-${ENVIRONMENT}.yaml" \
  --namespace "${ENVIRONMENT}" \
  --set app.name="${SERVICE_NAME}" \
  --set image.repository="${IMAGE_REPO}" \
  --set image.tag="local"
