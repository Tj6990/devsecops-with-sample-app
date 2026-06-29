#!/usr/bin/env bash
set -euo pipefail
SERVICE_NAME="${1:-app}"
TAG="${2:-dev-latest}"
ENVIRONMENT="${3:-dev}"
PROJECT_ID="controlled-substance-np-a3ea"
REGION="us-east4"
REPO="controlled-substance-np-useast4"
IMAGE_REPO="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${SERVICE_NAME}"
helm upgrade --install "${SERVICE_NAME}" ./helm/app-chart \
  --namespace "${ENVIRONMENT}" \
  --create-namespace \
  -f "./values-${ENVIRONMENT}.yaml" \
  --set app.name="${SERVICE_NAME}" \
  --set image.repository="${IMAGE_REPO}" \
  --set image.tag="${TAG}" \
  --set global.environment="${ENVIRONMENT}" \
  --atomic \
  --wait \
  --timeout 5m \
  --history-max 10
