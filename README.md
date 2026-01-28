# 🚀 Log Archiver Microservice
### DevOps & Cloud Architecture Technical Challenge

<div align="center">

![Python](https://img.shields.io/badge/Python-3.11-blue?logo=python&logoColor=white)
![GCP](https://img.shields.io/badge/GCP-Cloud%20Platform-4285F4?logo=google-cloud&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?logo=docker&logoColor=white)

</div>

---

## 🎯 Choose Your Path

This project can be deployed in **THREE independent ways**. Choose the path that fits your needs:

| Path | Time | Cost | Best For |
|------|------|------|----------|
| 🧪 **[Path 1: Mock Mode](#-path-1-mock-mode)** | 5-10 min | FREE | Learning, demos, no GCP needed |
| ☁️ **[Path 2: Manual Cloud](#%EF%B8%8F-path-2-manual-cloud-deployment)** | 20-30 min | ~$0.01/mo | Understanding the process, one-time setup |
| 🚀 **[Path 3: Full CI/CD](#-path-3-full-cicd-pipeline)** | 30-40 min | ~$0.01/mo | Production, automated deployments |

**⚠️ Important:** Each path is completely INDEPENDENT with its own prerequisites, steps, and cleanup.

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)

### **Execution Paths:**
- [🧪 PATH 1: Mock Mode](#-path-1-mock-mode)
- [☁️ PATH 2: Manual Cloud Deployment](#%EF%B8%8F-path-2-manual-cloud-deployment)
- [🚀 PATH 3: Full CI/CD Pipeline](#-path-3-full-cicd-pipeline)

### **Additional Resources:**
- [Security Features](#-security-features)
- [Architectural Insights](#-architectural-insights)

---

## 🎯 Overview

This microservice ingests messages from **Google Cloud Pub/Sub** and archives them as JSON files in **Google Cloud Storage**. It demonstrates:

- ✅ Infrastructure as Code with Terraform
- ✅ Production-ready Docker containerization  
- ✅ CI/CD automation with GitHub Actions
- ✅ Security best practices (WIF, non-root containers)
- ✅ Multiple deployment options

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   CLOUD ARCHITECTURE                     │
└─────────────────────────────────────────────────────────┘

  ┌──────────────┐         ┌──────────────┐         ┌──────────────┐
  │   Pub/Sub    │────────▶│  Application │────────▶│ GCS Bucket   │
  │    Topic     │         │  Container   │         │  (Archive)   │
  └──────────────┘         └──────────────┘         └──────────────┘
         │                        │                        │
         │                        │                        │
         ▼                        ▼                        ▼
  Service Account with minimal IAM permissions:
  ● pubsub.subscriber (read messages)
  ● storage.objectCreator (write files)
```

---

## 📁 Project Structure

```
hyphametrics-devops-challenge/
│
├── app/
│   ├── main.py              # Python application
│   ├── requirements.txt     # Dependencies
│   └── Dockerfile           # Multi-stage container
│
├── terraform/
│   ├── main.tf             # GCP resources
│   ├── variables.tf        # Input variables
│   ├── outputs.tf          # Outputs
│   └── providers.tf        # Backend config
│
├── .github/workflows/
│   └── deploy.yaml         # CI/CD pipeline
│
└── README.md
```

---

# 🧪 PATH 1: Mock Mode

**What:** Run the application locally in Docker without ANY cloud infrastructure.

**When to use:** Learning Docker, quick demos, testing application logic.

**What you get:** Proof that the containerized application works correctly.

---

## Prerequisites for Path 1

✅ **Required:**
- Docker Desktop installed and running
- Git (to clone repository)
- Terminal/PowerShell

❌ **NOT required:**
- GCP account
- GCP credentials  
- Terraform
- GitHub account

**Time:** 5-10 minutes | **Cost:** FREE

---

## Steps for Path 1

### Step 1: Clone and Navigate

<details>
<summary><b>🐧 Bash</b></summary>

```bash
git clone https://github.com/naesman1/hyphametrics-devops-challenge.git
cd hyphametrics-devops-challenge/app
```
</details>

<details>
<summary><b>🪟 PowerShell</b></summary>

```powershell
git clone https://github.com/naesman1/hyphametrics-devops-challenge.git
cd hyphametrics-devops-challenge\app
```
</details>

---

### Step 2: Build Docker Image

<details>
<summary><b>🐧 Bash</b></summary>

```bash
docker build -t log-archiver:mock .
docker images | grep log-archiver
```
</details>

<details>
<summary><b>🪟 PowerShell</b></summary>

```powershell
docker build -t log-archiver:mock .
docker images | Select-String log-archiver
```
</details>

---

### Step 3: Run Container

<details>
<summary><b>🐧 Bash</b></summary>

```bash
docker run --rm \
  -e PROJECT_ID="mock-project" \
  -e SUBSCRIPTION_NAME="mock-subscription" \
  -e BUCKET_NAME="mock-bucket" \
  log-archiver:mock
```
</details>

<details>
<summary><b>🪟 PowerShell</b></summary>

```powershell
docker run --rm `
  -e PROJECT_ID="mock-project" `
  -e SUBSCRIPTION_NAME="mock-subscription" `
  -e BUCKET_NAME="mock-bucket" `
  log-archiver:mock
```
</details>

**Expected output:**
```
INFO:__main__:Listening for messages on projects/mock-project/subscriptions/mock-subscription...
ERROR: DefaultCredentialsError: Your default credentials were not found...
```

✅ **This error is EXPECTED!** It proves:
- Container builds correctly ✅
- Application starts ✅
- Environment variables work ✅

---

## Cleanup for Path 1

<details>
<summary><b>🐧 Bash</b></summary>

```bash
# Remove image
docker rmi log-archiver:mock

# (Optional) Clean Docker system
docker system prune -a
```
</details>

<details>
<summary><b>🪟 PowerShell</b></summary>

```powershell
# Remove image
docker rmi log-archiver:mock

# (Optional) Clean Docker system
docker system prune -a
```
</details>

**✅ Done!** No cloud resources to clean up.

---

---

# ☁️ PATH 2: Manual Cloud Deployment

**What:** Deploy full infrastructure manually using Terraform + test the application with real GCP resources.

**When to use:** Understanding how everything works, one-time deployments, learning GCP.

**What you get:** Complete working system in GCP (Pub/Sub + GCS + Docker image in registry).

---

## Prerequisites for Path 2

✅ **Required:**
- GCP account with billing enabled
- gcloud CLI installed
- Terraform v1.0+ installed
- Docker Desktop
- Owner or Editor role on GCP project

❌ **NOT required:**
- GitHub account
- CI/CD setup
- Workload Identity Federation

**Time:** 20-30 minutes | **Cost:** ~$0.01-0.05/month

---

## Steps for Path 2

### Step 1: Setup GCP Project

<details>
<summary><b>🐧 Bash</b></summary>

```bash
# Authenticate
gcloud auth login
gcloud auth application-default login

# Set project
export PROJECT_ID="your-project-id"
gcloud config set project $PROJECT_ID

# Enable APIs
gcloud services enable \
  pubsub.googleapis.com \
  storage.googleapis.com \
  artifactregistry.googleapis.com \
  iam.googleapis.com

# Create state bucket
gcloud storage buckets create gs://${PROJECT_ID}-tfstate \
  --location=us-central1
```
</details>

<details>
<summary><b>🪟 PowerShell</b></summary>

```powershell
# Authenticate
gcloud auth login
gcloud auth application-default login

# Set project
$env:PROJECT_ID = "your-project-id"
gcloud config set project $env:PROJECT_ID

# Enable APIs
gcloud services enable `
  pubsub.googleapis.com `
  storage.googleapis.com `
  artifactregistry.googleapis.com `
  iam.googleapis.com

# Create state bucket
gcloud storage buckets create gs://${env:PROJECT_ID}-tfstate `
  --location=us-central1
```
</details>

---

### Step 2: Configure Terraform Backend

Edit `terraform/providers.tf`:

```hcl
terraform {
  backend "gcs" {
    bucket = "YOUR_PROJECT_ID-tfstate"  # ← Replace with your project ID
    prefix = "log-archiver/state"
  }
}
```

---

### Step 3: Deploy Infrastructure

<details>
<summary><b>🐧 Bash</b></summary>

```bash
cd terraform

# Initialize
terraform init

# Plan (review changes)
terraform plan -var="project_id=$PROJECT_ID"

# Apply
terraform apply -var="project_id=$PROJECT_ID"

# Save outputs
terraform output
```
</details>

<details>
<summary><b>🪟 PowerShell</b></summary>

```powershell
cd terraform

# Initialize
terraform init

# Plan (review changes)
terraform plan -var="project_id=$env:PROJECT_ID"

# Apply
terraform apply -var="project_id=$env:PROJECT_ID"

# Save outputs
terraform output
```
</details>

**Created resources:**
- ✅ Pub/Sub Topic & Subscription
- ✅ GCS Archive Bucket
- ✅ Service Account with IAM permissions
- ✅ Artifact Registry Repository

---

### Step 4: Build and Push Docker Image

<details>
<summary><b>🐧 Bash</b></summary>

```bash
cd ../app

# Configure Docker auth
gcloud auth configure-docker us-central1-docker.pkg.dev

# Build image
docker build -t us-central1-docker.pkg.dev/${PROJECT_ID}/log-archiver-repo/log-archiver:v1.0.0 .

# Push image
docker push us-central1-docker.pkg.dev/${PROJECT_ID}/log-archiver-repo/log-archiver:v1.0.0
```
</details>

<details>
<summary><b>🪟 PowerShell</b></summary>

```powershell
cd ..\app

# Configure Docker auth
gcloud auth configure-docker us-central1-docker.pkg.dev

# Build image
docker build -t us-central1-docker.pkg.dev/${env:PROJECT_ID}/log-archiver-repo/log-archiver:v1.0.0 .

# Push image
docker push us-central1-docker.pkg.dev/${env:PROJECT_ID}/log-archiver-repo/log-archiver:v1.0.0
```
</details>

---

### Step 5: Test the Application

<details>
<summary><b>🐧 Bash</b></summary>

```bash
# Publish test message
gcloud pubsub topics publish log-archiver-topic \
  --message="Test message from manual deployment"

# Run application locally
docker run --rm \
  -e PROJECT_ID="$PROJECT_ID" \
  -e SUBSCRIPTION_NAME="log-archiver-sub" \
  -e BUCKET_NAME="${PROJECT_ID}-log-archive-storage" \
  -v ~/.config/gcloud:/root/.config/gcloud:ro \
  us-central1-docker.pkg.dev/${PROJECT_ID}/log-archiver-repo/log-archiver:v1.0.0

# Check archived files
gcloud storage ls gs://${PROJECT_ID}-log-archive-storage/archive/
```
</details>

<details>
<summary><b>🪟 PowerShell</b></summary>

```powershell
# Publish test message
gcloud pubsub topics publish log-archiver-topic `
  --message="Test message from manual deployment"

# Run application locally
docker run --rm `
  -e PROJECT_ID="$env:PROJECT_ID" `
  -e SUBSCRIPTION_NAME="log-archiver-sub" `
  -e BUCKET_NAME="$env:PROJECT_ID-log-archive-storage" `
  -v ${env:APPDATA}\gcloud:/root/.config/gcloud:ro `
  us-central1-docker.pkg.dev/${env:PROJECT_ID}/log-archiver-repo/log-archiver:v1.0.0

# Check archived files
gcloud storage ls gs://${env:PROJECT_ID}-log-archive-storage/archive/
```
</details>

**✅ Success!** You should see JSON files in the GCS bucket.

---

## Cleanup for Path 2

<details>
<summary><b>🐧 Bash</b></summary>

```bash
# 1. Destroy infrastructure
cd terraform
terraform destroy -var="project_id=$PROJECT_ID" -auto-approve

# 2. Delete state bucket
gcloud storage rm -r gs://${PROJECT_ID}-tfstate

# 3. Remove local Docker image
docker rmi us-central1-docker.pkg.dev/${PROJECT_ID}/log-archiver-repo/log-archiver:v1.0.0

# 4. Verify cleanup
gcloud pubsub topics list
gcloud storage buckets list
gcloud artifacts repositories list
```
</details>

<details>
<summary><b>🪟 PowerShell</b></summary>

```powershell
# 1. Destroy infrastructure
cd terraform
terraform destroy -var="project_id=$env:PROJECT_ID" -auto-approve

# 2. Delete state bucket
gcloud storage rm -r gs://${env:PROJECT_ID}-tfstate

# 3. Remove local Docker image
docker rmi us-central1-docker.pkg.dev/${env:PROJECT_ID}/log-archiver-repo/log-archiver:v1.0.0

# 4. Verify cleanup
gcloud pubsub topics list
gcloud storage buckets list
gcloud artifacts repositories list
```
</details>

**✅ All resources removed!**

---

---

# 🚀 PATH 3: Full CI/CD Pipeline

**What:** Automated deployment via GitHub Actions triggered by release tags.

**When to use:** Production environments, team collaboration, continuous delivery.

**What you get:** Fully automated pipeline that builds, tests, and deploys on every release.

---

## Prerequisites for Path 3

✅ **Required:**
- Everything from Path 2 (GCP account, gcloud, Terraform, Docker)
- GitHub account
- Repository forked/cloned to your GitHub

**Time:** 30-40 minutes | **Cost:** ~$0.01-0.05/month

---

## Steps for Path 3

### Step 1: Setup GCP (Same as Path 2 Step 1)

<details>
<summary><b>🐧 Bash</b></summary>

```bash
# 1. Set your Project ID variable
export PROJECT_ID="<YOUR_PROJECT_ID>"
gcloud config set project $PROJECT_ID

# 2. Authenticate with Google Cloud
gcloud auth login

# 3. Create the dedicated Service Account
gcloud iam service-accounts create log-archiver-sa \
    --display-name="Log Archiver Service Account"

# 1. Create the Terraform state bucket
gcloud storage buckets create gs://${PROJECT_ID}-tfstate --location=us-central1

# 2. Grant the Service Account permissions to manage the state file
gcloud storage buckets add-iam-policy-binding gs://${PROJECT_ID}-tfstate \
    --member="serviceAccount:log-archiver-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/storage.objectAdmin"

# Grant Owner role to the Service Account at the project level
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:log-archiver-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/owner"
```
</details>

<details>
<summary><b>🪟 PowerShell</b></summary>

```powershell
# Set your Project ID variable
$env:PROJECT_ID = "<YOUR_PROJECT_ID>"
gcloud config set project $env:PROJECT_ID

# Authenticate with Google Cloud
gcloud auth login

# Create the dedicated Service Account
gcloud iam service-accounts create log-archiver-sa `
    --display-name="Log Archiver Service Account"

# Create the Terraform state bucket
gcloud storage buckets create gs://${env:PROJECT_ID}-tfstate --location=us-central1

# Grant the Service Account permissions to manage the state file
gcloud storage buckets add-iam-policy-binding gs://${env:PROJECT_ID}-tfstate `
    --member="serviceAccount:log-archiver-sa@${env:PROJECT_ID}.iam.gserviceaccount.com" `
    --role="roles/storage.objectAdmin"

# Grant Owner role to the Service Account at the project level
gcloud projects add-iam-policy-binding $env:PROJECT_ID `
    --member="serviceAccount:log-archiver-sa@${env:PROJECT_ID}.iam.gserviceaccount.com" `
    --role="roles/owner"


# Enable APIs
gcloud services enable `
  pubsub.googleapis.com `
  storage.googleapis.com `
  artifactregistry.googleapis.com `
  iam.googleapis.com `
  sts.googleapis.com

# Create state bucket
gcloud storage buckets create gs://${env:PROJECT_ID}-tfstate `
  --location=us-central1
```
</details>

---

### Step 2: Setup Workload Identity Federation

<details>
<summary><b>🐧 Bash</b></summary>

```bash
# Create WIF pool
gcloud iam workload-identity-pools create github-pool \
  --location="global" \
  --display-name="GitHub Pool"

# Create WIF provider
gcloud iam workload-identity-pools providers create-oidc github-provider \
  --workload-identity-pool="github-pool" \
  --location="global" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository"

# Get WIF provider path (save this for GitHub secrets)
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
echo "WIF_PROVIDER: projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider"
```
</details>

<details>
<summary><b>🪟 PowerShell</b></summary>

```powershell
# Create WIF pool
gcloud iam workload-identity-pools create github-pool `
  --location="global" `
  --display-name="GitHub Pool"

# Create WIF provider
gcloud iam workload-identity-pools providers create-oidc github-provider `
  --workload-identity-pool="github-pool" `
  --location="global" `
  --issuer-uri="https://token.actions.githubusercontent.com" `
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository"

# Get WIF provider path (save this for GitHub secrets)
$PROJECT_NUMBER = gcloud projects describe $env:PROJECT_ID --format="value(projectNumber)"
Write-Host "WIF_PROVIDER: projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider"
```
</details>

---

### Step 3: Configure Terraform and Deploy

Follow Path 2 Steps 2-3 to configure Terraform backend and deploy infrastructure.

**After terraform apply**, get the Service Account email:

<details>
<summary><b>🐧 Bash</b></summary>

```bash
cd terraform
SA_EMAIL=$(terraform output -raw service_account_email)
echo "Service Account Email: $SA_EMAIL"
```
</details>

<details>
<summary><b>🪟 PowerShell</b></summary>

```powershell
cd terraform
$SA_EMAIL = terraform output -raw service_account_email
Write-Host "Service Account Email: $SA_EMAIL"
```
</details>

---

### Step 4: Grant WIF Permissions

<details>
<summary><b>🐧 Bash</b></summary>

```bash
# Replace with your GitHub username/repo
GITHUB_REPO="YOUR_USERNAME/hyphametrics-devops-challenge"

PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

gcloud iam service-accounts add-iam-policy-binding \
  "log-archiver-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/attribute.repository/${GITHUB_REPO}"
```
</details>

<details>
<summary><b>🪟 PowerShell</b></summary>

```powershell
# Replace with your GitHub username/repo
$GITHUB_REPO = "YOUR_USERNAME/hyphametrics-devops-challenge"

$PROJECT_NUMBER = gcloud projects describe $env:PROJECT_ID --format="value(projectNumber)"

gcloud iam service-accounts add-iam-policy-binding `
  "log-archiver-sa@${env:PROJECT_ID}.iam.gserviceaccount.com" `
  --role="roles/iam.workloadIdentityUser" `
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/attribute.repository/${GITHUB_REPO}"
```
</details>

---

### Step 5: Add GitHub Secrets

Go to: `https://github.com/YOUR_USERNAME/hyphametrics-devops-challenge/settings/secrets/actions`

Add these THREE secrets:

| Secret Name | Value | How to Get |
|-------------|-------|------------|
| `GCP_PROJECT_ID` | Your project ID | `gcloud config get-value project` |
| `GCP_WIF_PROVIDER` | WIF provider path | From Step 2 output |
| `GCP_SA_EMAIL` | Service Account email | From Step 3 output |

---

### Step 6: Trigger Pipeline

<details>
<summary><b>🐧 Bash</b></summary>

```bash
# Commit any changes
git add .
git commit -a -m "feat: ready for CI/CD deployment"

# Create and push release tag
git tag v1.0.0
git push origin v1.0.0

# Watch pipeline
echo "View at: https://github.com/YOUR_USERNAME/hyphametrics-devops-challenge/actions"
```
</details>

<details>
<summary><b>🪟 PowerShell</b></summary>

```powershell
# Commit any changes
git add .
git commit -a -m "feat: ready for CI/CD deployment"

# Create and push release tag
git tag v1.0.0
git push origin v1.0.0

# Watch pipeline
Write-Host "View at: https://github.com/YOUR_USERNAME/hyphametrics-devops-challenge/actions"
```
</details>

**The pipeline will:**
1. ✅ Build Docker image
2. ✅ Scan for vulnerabilities
3. ✅ Push to Artifact Registry
4. ✅ Apply Terraform changes

---

### Step 7: Verify Deployment

<details>
<summary><b>🐧 Bash</b></summary>

```bash
# Check image in registry
gcloud artifacts docker images list \
  us-central1-docker.pkg.dev/${PROJECT_ID}/log-archiver-repo

# Test the system
gcloud pubsub topics publish log-archiver-topic \
  --message="Test from CI/CD"

# Check archived files
gcloud storage ls gs://${PROJECT_ID}-log-archive-storage/archive/
```
</details>

<details>
<summary><b>🪟 PowerShell</b></summary>

```powershell
# Check image in registry
gcloud artifacts docker images list `
  us-central1-docker.pkg.dev/${env:PROJECT_ID}/log-archiver-repo

# Test the system
gcloud pubsub topics publish log-archiver-topic `
  --message="Test from CI/CD"

# Check archived files
gcloud storage ls gs://${env:PROJECT_ID}-log-archive-storage/archive/
```
</details>

---

## Cleanup for Path 3

<details>
<summary><b>🐧 Bash</b></summary>

```bash
# 1. Destroy infrastructure
cd terraform
terraform destroy -var="project_id=$PROJECT_ID" -auto-approve

# 2. Delete WIF resources
gcloud iam workload-identity-pools providers delete github-provider \
  --workload-identity-pool="github-pool" \
  --location="global" \
  --quiet

gcloud iam workload-identity-pools delete github-pool \
  --location="global" \
  --quiet

# 3. Delete state bucket
gcloud storage rm -r gs://${PROJECT_ID}-tfstate

# 4. Remove GitHub secrets manually
echo "Go to GitHub Settings → Secrets → Delete GCP_PROJECT_ID, GCP_WIF_PROVIDER, GCP_SA_EMAIL"

# 5. Verify cleanup
gcloud pubsub topics list
gcloud storage buckets list
gcloud artifacts repositories list
gcloud iam workload-identity-pools list --location="global"
```
</details>

<details>
<summary><b>🪟 PowerShell</b></summary>

```powershell
# 1. Destroy infrastructure
cd terraform
terraform destroy -var="project_id=$env:PROJECT_ID" -auto-approve

# 2. Delete WIF resources
gcloud iam workload-identity-pools providers delete github-provider `
  --workload-identity-pool="github-pool" `
  --location="global" `
  --quiet

gcloud iam workload-identity-pools delete github-pool `
  --location="global" `
  --quiet

# 3. Delete state bucket
gcloud storage rm -r gs://${env:PROJECT_ID}-tfstate

# 4. Remove GitHub secrets manually
Write-Host "Go to GitHub Settings → Secrets → Delete GCP_PROJECT_ID, GCP_WIF_PROVIDER, GCP_SA_EMAIL"

# 5. Verify cleanup
gcloud pubsub topics list
gcloud storage buckets list
gcloud artifacts repositories list
gcloud iam workload-identity-pools list --location="global"
```
</details>

**✅ All resources removed!**

---

---

## 🔒 Security Features

This project implements multiple security best practices:

### Docker Security:
- ✅ Multi-stage build (reduced attack surface)
- ✅ Non-root user (`appuser`)
- ✅ Minimal base image (`python:3.11-slim`)
- ✅ Security patches applied
- ✅ No secrets in image

### GCP Security:
- ✅ Principle of Least Privilege (minimal IAM permissions)
- ✅ No public bucket access (`public_access_prevention = enforced`)
- ✅ Workload Identity Federation (no JSON keys)
- ✅ Uniform bucket-level access
- ✅ Encrypted at rest (GCP default)

### CI/CD Security:
- ✅ OIDC authentication (no long-lived credentials)
- ✅ Vulnerability scanning with Trivy
- ✅ Secrets managed via GitHub Secrets
- ✅ Audit trail in GitHub Actions

---

## 💡 Architectural Insights

### Question 1: Secret Management in GKE

**How would you inject sensitive database credentials into the container at runtime?**

I would use **Google Secret Manager** integrated with the **CSI Secret Store Driver**:

```yaml
apiVersion: v1
kind: Pod
spec:
  volumes:
  - name: secrets
    csi:
      driver: secrets-store.csi.k8s.io
      volumeAttributes:
        secretProviderClass: "db-credentials"
  containers:
  - name: app
    volumeMounts:
    - name: secrets
      mountPath: "/mnt/secrets"
      readOnly: true
```

**Benefits:**
- Secrets never in Git or container images
- Automatic rotation support
- Audit logging
- Native Kubernetes integration

---

### Question 2: Private VPC Connectivity

**If this service needed to access a private MongoDB in another VPC, how would you architect connectivity?**

I would use **VPC Network Peering**:

1. **VPC Peering:** Connect both VPCs at network layer
2. **Firewall Rules:** Allow only port 27017 from specific ranges
3. **Private DNS:** Use Cloud DNS private zones for service discovery
4. **No Public IPs:** All traffic stays on Google's private network

**Benefits:**
- Low latency (no internet routing)
- No bandwidth costs between VPCs
- Enhanced security
- Transitive peering support

---

### Question 3: Observability & Alerting

**The service is failing silently in production. What tools would you set up?**

Multi-layered observability:

**1. Log-Based Alerts (Cloud Logging)**
```
severity="ERROR" AND textPayload=~"upload_to_gcs failed"
```

**2. Metric-Based Alerts (Cloud Monitoring)**
- Monitor `pubsub/subscription/num_unacked_messages`
- Alert when threshold exceeded (processing backlog)

**3. Uptime Checks**
- Health endpoint monitoring
- Container restart detection

**4. Error Reporting**
- Automatic error grouping
- Stack trace collection


