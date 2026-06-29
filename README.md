# Final Enterprise Production DevSecOps Template — Single Service Repo

This repository template is designed for your final architecture:

```text
One GitHub repository = One microservice = One independent deployment pipeline
```

## Target Platform

```text
Project ID: controlled-substance-np-a3ea
Region: us-east4
GKE cluster: controlled-substance-np-useast4
Artifact Registry repo: controlled-substance-np-useast4
Deployment engine: GitHub Actions only
Deployment method: Helm upgrade/install to GKE
Cloud Build: Not used
Cloud Deploy: Not used
```

## What is included

```text
.github/workflows/devsecops.yml          # Enterprise CI/CD + DevSecOps pipeline
helm/app-chart/                          # Production-grade reusable Helm chart
values-dev.yaml                          # Dev environment Helm values
values-qa.yaml                           # QA values
values-stage.yaml                        # Stage values
values-prod.yaml                         # Prod values
Dockerfile                               # Production Java/Spring Boot Dockerfile
Dockerfile.react                         # Production React/Node/Nginx Dockerfile
nginx.conf                               # React runtime config
pom.xml                                  # Sample Spring Boot app with Actuator
src/main/java/com/example/Application.java
security/                                # Gitleaks, Trivy and OPA/Conftest policy
scripts/                                 # WIF setup and local validation helpers
```

## Required change per service repo

Edit `.github/workflows/devsecops.yml` and update these values:

```yaml
SERVICE_NAME: cs-threshold-core-service
APP_TYPE: java
DOCKERFILE_PATH: ./Dockerfile
```

For React:

```yaml
SERVICE_NAME: cs-threshold-mgmt-app
APP_TYPE: react
DOCKERFILE_PATH: ./Dockerfile.react
```

## Required GitHub secrets

Create these in GitHub repository secrets or environment secrets:

```text
WIF_PROVIDER
GCP_SERVICE_ACCOUNT
```

Example:

```text
WIF_PROVIDER=projects/<PROJECT_NUMBER>/locations/global/workloadIdentityPools/github-pool/providers/github-provider
GCP_SERVICE_ACCOUNT=github-gke-deployer@controlled-substance-np-a3ea.iam.gserviceaccount.com
```

## Runtime IAM reminders

The GitHub deployment service account normally needs:

```text
roles/artifactregistry.writer
roles/container.developer
roles/container.clusterViewer
```

The GKE node service account or runtime workload identity needs:

```text
roles/artifactregistry.reader
```

## Pipeline stages

```text
Checkout
Resolve environment and image tag
Build and unit test
Secret scan with Gitleaks
SAST with Semgrep
Dependency/filesystem scan with Trivy
Dockerfile and Helm misconfiguration scan
Helm lint and template render
Policy-as-code validation with Conftest
Authenticate to GCP using OIDC/WIF
Docker build using Buildx
Container image vulnerability scan
Push image to Artifact Registry
Get GKE credentials
Helm upgrade --install with --atomic and --wait
Kubernetes rollout verification
Show deployed workloads
```

## Branch and environment model

```text
develop   -> dev
release/* -> stage
main      -> prod
manual    -> selected environment
```

## Local validation

```bash
chmod +x scripts/*.sh
./scripts/local-validate.sh
./scripts/local-helm-render.sh dev
```

## Deploy manually from local machine after image exists

```bash
./scripts/deploy-one-service.sh cs-threshold-core-service dev-latest dev
```

## Notes

1. Do not commit real secrets into Helm values.
2. Use GitHub Environment approvals for stage and prod.
3. Use separate service accounts for dev, stage and prod if your security board requires stricter separation.
4. This package is GitHub Actions only. It intentionally excludes Cloud Build and Cloud Deploy.
