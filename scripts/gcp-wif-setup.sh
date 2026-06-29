#!/usr/bin/env bash
set -euo pipefail
PROJECT_ID="controlled-substance-np-a3ea"
REGION="us-east4"
GAR_REPO="controlled-substance-np-useast4"
WIF_POOL_ID="github-pool"
WIF_PROVIDER_ID="github-provider"
SA_NAME="github-gke-deployer"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
GITHUB_ORG="YOUR_GITHUB_ORG"
GITHUB_REPO="YOUR_REPO_NAME"
PROJECT_NUMBER="$(gcloud projects describe ${PROJECT_ID} --format='value(projectNumber)')"

gcloud config set project "${PROJECT_ID}"
gcloud services enable iamcredentials.googleapis.com sts.googleapis.com container.googleapis.com artifactregistry.googleapis.com

gcloud artifacts repositories describe "${GAR_REPO}" --location="${REGION}" >/dev/null 2>&1 || \
  gcloud artifacts repositories create "${GAR_REPO}" --repository-format=docker --location="${REGION}" --description="App Docker repository"

gcloud iam service-accounts describe "${SA_EMAIL}" >/dev/null 2>&1 || \
  gcloud iam service-accounts create "${SA_NAME}" --display-name="GitHub Actions GKE Helm Deployer"

for role in roles/artifactregistry.writer roles/container.developer roles/container.clusterViewer; do
  gcloud projects add-iam-policy-binding "${PROJECT_ID}" --member="serviceAccount:${SA_EMAIL}" --role="$role"
done

gcloud iam workload-identity-pools describe "${WIF_POOL_ID}" --location="global" >/dev/null 2>&1 || \
  gcloud iam workload-identity-pools create "${WIF_POOL_ID}" --location="global" --display-name="GitHub Actions Pool"

gcloud iam workload-identity-pools providers describe "${WIF_PROVIDER_ID}" --location="global" --workload-identity-pool="${WIF_POOL_ID}" >/dev/null 2>&1 || \
  gcloud iam workload-identity-pools providers create-oidc "${WIF_PROVIDER_ID}" \
    --location="global" \
    --workload-identity-pool="${WIF_POOL_ID}" \
    --display-name="GitHub Provider" \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.ref=assertion.ref" \
    --attribute-condition="assertion.repository == '${GITHUB_ORG}/${GITHUB_REPO}'"

gcloud iam service-accounts add-iam-policy-binding "${SA_EMAIL}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${WIF_POOL_ID}/attribute.repository/${GITHUB_ORG}/${GITHUB_REPO}"

echo "WIF_PROVIDER=projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${WIF_POOL_ID}/providers/${WIF_PROVIDER_ID}"
echo "GCP_SERVICE_ACCOUNT=${SA_EMAIL}"
