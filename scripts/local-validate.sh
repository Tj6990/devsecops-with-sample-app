#!/usr/bin/env bash
set -euo pipefail
mvn -B clean verify
helm lint ./helm/app-chart -f ./values-dev.yaml
helm template app ./helm/app-chart -f ./values-dev.yaml --set app.name=app --set image.repository=example/app --set image.tag=local > rendered.yaml
