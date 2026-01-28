# 🚀 Log Archiver Microservice
### DevOps & Cloud Architecture Technical Challenge

<div align="center">

![Python](https://img.shields.io/badge/Python-3.11-blue?logo=python&logoColor=white)
![GCP](https://img.shields.io/badge/GCP-Cloud%20Platform-4285F4?logo=google-cloud&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC?logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?logo=docker&logoColor=white)

</div>

---

## 🎯 Quick Start: Execution Order

**Choose your path:**

### 🧪 For Mock Mode (Local Testing Only):
```
1. Configure Terraform Backend (use "local" backend)
2. Navigate to /app directory
3. Build Docker image
4. Run container with mock environment variables
```
**Time:** ~5-10 minutes | **Cost:** Free

---

### ☁️ For Cloud Mode (Full GCP Deployment):
```
PHASE 1: GCP Bootstrap
  ├─ 1.1 Authenticate & configure GCP
  ├─ 1.2 Enable required APIs
  ├─ 1.3 Create Terraform state bucket
  └─ 1.4 Setup Workload Identity Federation

PHASE 2 (Part 1): GitHub Secrets - Before Terraform
  ├─ 2.1 Get WIF provider path
  └─ 2.2 Add GCP_PROJECT_ID and GCP_WIF_PROVIDER to GitHub
  
PHASE 3: Deploy Infrastructure with Terraform
  ├─ 3.1 Configure Terraform backend (use "gcs" backend)
  ├─ 3.2 Initialize Terraform
  ├─ 3.3 Apply infrastructure
  └─ 3.4 Save Service Account email from output

PHASE 2 (Part 2): Complete GitHub Secrets - After Terraform
  ├─ 2.3 Add GCP_SA_EMAIL to GitHub
  └─ 2.4 Grant WIF permissions to Service Account

PHASE 4: Deploy via CI/CD
  └─ 4.1 Push a release tag (v1.0.0)
```
**Time:** ~20-30 minutes | **Cost:** ~$0.01-0.05/month

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Two Ways to Run This Project](#-two-ways-to-run-this-project)
- [Architecture](#-architecture)
- [Execution Modes](#-execution-modes)
  - [Mock Mode (Local Testing)](#-mock-mode-local-testing)
  - [Cloud Mode (Production)](#%EF%B8%8F-cloud-mode-production)
- [Project Structure](#-project-structure)
- [Prerequisites](#%EF%B8%8F-prerequisites)
- [Critical Configuration: Terraform Backend](#%EF%B8%8F-critical-configuration-terraform-backend-setup)
- [Getting Started - Cloud Mode](#-getting-started)
  - [Phase 1: GCP Project Bootstrap](#phase-1-gcp-project-bootstrap)
  - [Phase 2 Part 1: Configure GitHub Secrets (Before Terraform)](#phase-2-configure-github-secrets-part-1---before-terraform)
  - [Phase 3: Deploy Infrastructure](#phase-3-deploy-infrastructure)
  - [Phase 2 Part 2: Complete GitHub Secrets (After Terraform)](#-phase-2-part-2-complete-github-secrets--wif-binding)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Security Features](#-security-features)
- [Cleanup](#-cleanup)
- [Architectural Insights](#-architectural-insights)

---

## 🎯 Overview

This microservice demonstrates a production-ready approach to building cloud-native applications. It ingests messages from **Google Cloud Pub/Sub** and archives them as JSON files in **Google Cloud Storage (GCS)**. The project showcases:

- ✅ Infrastructure as Code with Terraform
- ✅ Containerization best practices with Docker
- ✅ CI/CD automation with GitHub Actions
- ✅ Security-first development approach
- ✅ Two execution modes: local mock and cloud deployment

**What makes this unique?** This solution supports both **mock execution** for rapid local development and **cloud deployment** for production environments, allowing seamless testing without incurring cloud costs.

---

## 🎭 Two Ways to Run This Project

This project can be executed in **two different modes**, each designed for specific use cases:

### Comparison Table:

| Feature | 🧪 Mock Mode | ☁️ Cloud Mode |
|---------|-------------|--------------|
| **Purpose** | Local development & testing | Production deployment |
| **GCP Account** | ❌ Not required | ✅ Required |
| **Cost** | 💰 Free | 💰 Pay-per-use (free tier eligible) |
| **Setup Time** | ⚡ ~5 minutes | 🕐 ~20-30 minutes |
| **Infrastructure** | Simulated (containers only) | Real GCP resources |
| **Best For** | Learning, debugging, demos | Production, integration testing |
| **Backend State** | Local file (`terraform.tfstate`) | GCS bucket (remote state) |

---

### Quick Decision Guide:

**Choose Mock Mode if you:**
- 🎓 Want to learn how the application works
- 💻 Don't have a GCP account or want to avoid costs
- 🐛 Need to debug application logic quickly
- ⚡ Want immediate results without cloud setup

**Choose Cloud Mode if you:**
- 🚀 Need to deploy to production
- 🧪 Want to test with real cloud services
- 👥 Are working in a team with shared infrastructure
- 📊 Need full observability and monitoring

**Can I use both?** Yes! You can start with Mock Mode to understand the project, then switch to Cloud Mode for deployment. Just make sure to update the Terraform backend configuration (explained in the next section).

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLOUD ARCHITECTURE                        │
└─────────────────────────────────────────────────────────────────┘

     ┌──────────────┐         ┌──────────────┐         ┌──────────────┐
     │   Pub/Sub    │────────▶│  Application │────────▶│ GCS Bucket   │
     │    Topic     │         │  Container   │         │  (Archive)   │
     └──────────────┘         └──────────────┘         └──────────────┘
            │                        │                        │
            │                        │                        │
            ▼                        ▼                        ▼
     Service Account with minimal IAM permissions
     ● pubsub.subscriber (read messages)
     ● storage.objectCreator (write to bucket)


┌─────────────────────────────────────────────────────────────────┐
│                      DEPLOYMENT PIPELINE                         │
└─────────────────────────────────────────────────────────────────┘

  Release Tag (v1.0.x)
         │
         ▼
  ┌─────────────────┐
  │  GitHub Actions │
  └────────┬────────┘
           │
           ├──▶ Build Docker Image
           │
           ├──▶ Security Scan (Trivy)
           │
           ├──▶ Push to Artifact Registry
           │
           └──▶ Apply Terraform (Infrastructure)
```

---

## 🎭 Execution Modes

This project supports **two execution modes**, each designed for different purposes:

### 🧪 Mock Mode (Local Testing)

**Purpose:** Rapid development and testing without cloud infrastructure costs.

**How it works:**
1. Uses environment variables to simulate GCP services
2. Runs the application locally via Docker or Python
3. Logs messages to console instead of uploading to GCS
4. Perfect for development, debugging, and demonstrations

**When to use:**
- ✅ Initial development and testing
- ✅ Debugging application logic
- ✅ Running without GCP credentials
- ✅ Quick iterations during feature development

---

#### Prerequisites for Mock Mode:

**Required:**
- Docker Desktop installed and running
- Basic terminal/command line knowledge

**Optional:**
- Python 3.11+ (if running without Docker)
- Text editor (for viewing Dockerfile)

---

#### Setup Steps:

**⚠️ BEFORE YOU START:** Make sure you've configured the Terraform backend for Mock Mode (see the **Critical Configuration** section above). You should have the `backend "local"` uncommented in `terraform/providers.tf`.

---

**Step 0: Configure Terraform Backend (Important!)**

Before running mock mode, you need to **comment out** the real GCS backend in `terraform/providers.tf`:

```hcl
# terraform/providers.tf

terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # --- OPTION 1: Real Backend (COMMENT THIS for Mock Mode) ---
  # backend "gcs" {
  #   bucket = "devops-challenge-485523-tfstate"
  #   prefix = "log-archiver/state"
  # }

  # --- OPTION 2: Local Backend (UNCOMMENT for Mock Mode) ---
  # This uses local state file - perfect for testing without GCP
  backend "local" {
    path = "terraform.tfstate"
  }
}
```

**Why?** The GCS backend requires authentication to GCP. For mock mode, we use local state instead.

---

**Step 1: Navigate to Project Directory**

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# Clone the repository (if you haven't already)
git clone https://github.com/naesman1/hyphametrics-devops-challenge.git
cd hyphametrics-devops-challenge/app
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# Clone the repository (if you haven't already)
git clone https://github.com/naesman1/hyphametrics-devops-challenge.git
cd hyphametrics-devops-challenge\app
```
</details>

---

**Step 2: Set Mock Environment Variables**

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# Set mock environment variables
export PROJECT_ID="mock-project"
export SUBSCRIPTION_NAME="mock-subscription"
export BUCKET_NAME="mock-bucket"

# Verify they're set
echo "PROJECT_ID: $PROJECT_ID"
echo "SUBSCRIPTION_NAME: $SUBSCRIPTION_NAME"
echo "BUCKET_NAME: $BUCKET_NAME"
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# Set mock environment variables
$env:PROJECT_ID = "mock-project"
$env:SUBSCRIPTION_NAME = "mock-subscription"
$env:BUCKET_NAME = "mock-bucket"

# Verify they're set
Write-Host "PROJECT_ID: $env:PROJECT_ID"
Write-Host "SUBSCRIPTION_NAME: $env:SUBSCRIPTION_NAME"
Write-Host "BUCKET_NAME: $env:BUCKET_NAME"
```
</details>

---

**Step 3: Build the Docker Image**

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# Build the Docker image
docker build -t log-archiver:mock .

# Verify the image was created
docker images | grep log-archiver
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# Build the Docker image
docker build -t log-archiver:mock .

# Verify the image was created
docker images | Select-String log-archiver
```
</details>

---

**Step 4: Run the Container in Mock Mode**

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# Run the container with mock environment variables
docker run --rm \
  -e PROJECT_ID="$PROJECT_ID" \
  -e SUBSCRIPTION_NAME="$SUBSCRIPTION_NAME" \
  -e BUCKET_NAME="$BUCKET_NAME" \
  log-archiver:mock

# Alternative: Run interactively to see logs
docker run --rm -it \
  -e PROJECT_ID="mock-project" \
  -e SUBSCRIPTION_NAME="mock-subscription" \
  -e BUCKET_NAME="mock-bucket" \
  log-archiver:mock
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# Run the container with mock environment variables
docker run --rm `
  -e PROJECT_ID="$env:PROJECT_ID" `
  -e SUBSCRIPTION_NAME="$env:SUBSCRIPTION_NAME" `
  -e BUCKET_NAME="$env:BUCKET_NAME" `
  log-archiver:mock

# Alternative: Run interactively to see logs
docker run --rm -it `
  -e PROJECT_ID="mock-project" `
  -e SUBSCRIPTION_NAME="mock-subscription" `
  -e BUCKET_NAME="mock-bucket" `
  log-archiver:mock
```
</details>

---

**What happens in Mock Mode:**
- The application starts and attempts to connect to Pub/Sub
- Without real GCP credentials, it will gracefully handle connection errors
- Demonstrates the container works correctly
- All logs are visible for debugging

**Expected Output:**
```
INFO:__main__:Listening for messages on projects/mock-project/subscriptions/mock-subscription...
ERROR:__main__:Missing required environment variables or authentication failed
```

**Note:** This demonstrates the containerized application structure without requiring GCP setup. For full functionality, use Cloud Mode.

---

### ☁️ Cloud Mode (Production)

**Purpose:** Full production deployment on Google Cloud Platform.

**How it works:**
1. Terraform provisions all GCP resources (Pub/Sub, GCS, IAM)
2. GitHub Actions builds and deploys the Docker image
3. Application runs with real GCP credentials
4. Messages are processed and archived to cloud storage

**When to use:**
- ✅ Production deployments
- ✅ Integration testing with real cloud services
- ✅ Performance testing under load
- ✅ Demonstrating full end-to-end functionality

---

#### Prerequisites for Cloud Mode:

**Required:**
- Google Cloud SDK (gcloud) installed
- Terraform v1.0+ installed
- Active GCP Project with billing enabled
- GitHub account (for CI/CD)
- Git installed

**Required Permissions:**
- Owner or Editor role on GCP project
- Ability to create service accounts
- Ability to enable APIs

---

#### Important Configuration Steps:

**Step 0: Configure Terraform Backend for Cloud Mode**

Before deploying to GCP, you need to **uncomment** the real GCS backend in `terraform/providers.tf`:

```hcl
# terraform/providers.tf

terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # --- OPTION 1: Real Backend (UNCOMMENT for Cloud Mode) ---
  # This uses the bucket you created via the CLI
  backend "gcs" {
    bucket = "YOUR_PROJECT_ID-tfstate"  # Replace with your actual project ID
    prefix = "log-archiver/state"
  }

  # --- OPTION 2: Local Backend (COMMENT THIS for Cloud Mode) ---
  # backend "local" {
  #   path = "terraform.tfstate"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
```

**⚠️ Important Notes:**
- Replace `YOUR_PROJECT_ID` with your actual GCP Project ID
- The bucket must exist before running `terraform init`
- We create this bucket in Phase 1 below

---

**Architecture Components:**

| Component | Resource | Purpose |
|-----------|----------|---------|
| **Messaging** | Pub/Sub Topic & Subscription | Message ingestion queue |
| **Storage** | GCS Bucket | JSON file archive |
| **Compute** | Container (Cloud Run ready) | Application runtime |
| **Security** | Service Account | Minimal IAM permissions |
| **Registry** | Artifact Registry | Docker image storage |
| **IaC** | Terraform | Infrastructure provisioning |

**Key Features:**
- 🔒 **Security:** Workload Identity Federation (no JSON keys)
- 🏗️ **Infrastructure:** Fully automated with Terraform
- 🚀 **Deployment:** CI/CD with GitHub Actions
- 📊 **Observability:** Cloud Logging integration
- 💰 **Cost-Effective:** Pay-per-use with GCP free tier eligible

---

## 📁 Project Structure

```
hyphametrics-devops-challenge/
│
├── app/
│   ├── main.py              # Python application logic
│   ├── requirements.txt     # Python dependencies
│   └── Dockerfile           # Multi-stage container build
│
├── terraform/
│   ├── main.tf             # GCP resource definitions
│   ├── variables.tf        # Input variables
│   ├── outputs.tf          # Resource outputs
│   └── providers.tf        # Terraform & GCP provider config
│
├── .github/
│   └── workflows/
│       └── deploy.yaml     # CI/CD pipeline configuration
│
├── docs/
│   └── challenge.pdf       # Original technical requirements
│
└── README.md               # This file
```

---

## 🛠️ Prerequisites

To run this solution, you'll need:

### For Mock Mode:
- Docker Desktop
- Basic understanding of containers

### For Cloud Mode:
- **Google Cloud SDK (gcloud)**
- **Terraform (v1.0+)**
- **GCP Project** with billing enabled
- **GitHub Account** (for CI/CD)

---

## ⚙️ Critical Configuration: Terraform Backend Setup

**⚠️ IMPORTANT:** Before running either Mock or Cloud mode, you MUST configure the Terraform backend correctly in `terraform/providers.tf`.

### Why This Matters:

Terraform stores the state of your infrastructure in a "backend". The backend configuration determines where this state is stored:
- **Local Backend:** State stored on your computer (for testing/mock mode)
- **GCS Backend:** State stored in Google Cloud Storage (for production/cloud mode)

### Configuration Options:

The `terraform/providers.tf` file has two backend options. You must choose ONE based on your execution mode:

#### 📝 For Mock Mode (Local Testing):

**Use this configuration:**
```hcl
# terraform/providers.tf

terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # ✅ ACTIVE for Mock Mode - Local state file
  backend "local" {
    path = "terraform.tfstate"
  }

  # ❌ COMMENTED OUT for Mock Mode - Cloud state
  # backend "gcs" {
  #   bucket = "YOUR_PROJECT_ID-tfstate"
  #   prefix = "log-archiver/state"
  # }
}
```

**Steps:**
1. Comment out the entire `backend "gcs"` block
2. Uncomment the `backend "local"` block
3. Save the file

---

#### ☁️ For Cloud Mode (Production):

**Use this configuration:**
```hcl
# terraform/providers.tf

terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # ❌ COMMENTED OUT for Cloud Mode - Local state
  # backend "local" {
  #   path = "terraform.tfstate"
  # }

  # ✅ ACTIVE for Cloud Mode - Cloud state
  backend "gcs" {
    bucket = "YOUR_PROJECT_ID-tfstate"  # Replace with your actual Project ID!
    prefix = "log-archiver/state"
  }
}
```

**Steps:**
1. Comment out the entire `backend "local"` block
2. Uncomment the `backend "gcs"` block
3. **Replace `YOUR_PROJECT_ID`** with your actual GCP Project ID
4. Save the file

**⚠️ The GCS bucket MUST exist before running `terraform init`!** You'll create this bucket in Phase 1 of the Cloud Mode setup.

---

### Quick Reference Table:

| Mode | Backend Type | Configuration | When to Use |
|------|-------------|---------------|-------------|
| **Mock** | `local` | State file on your computer | Local testing, no GCP access |
| **Cloud** | `gcs` | State file in GCS bucket | Production deployment, team collaboration |

### Switching Between Modes:

If you need to switch modes, you'll need to reinitialize Terraform:

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# After changing the backend configuration
cd terraform
rm -rf .terraform/              # Remove old backend config
terraform init -reconfigure     # Reinitialize with new backend
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# After changing the backend configuration
cd terraform
Remove-Item -Recurse -Force .terraform  # Remove old backend config
terraform init -reconfigure             # Reinitialize with new backend
```
</details>

**✅ You're now ready to proceed with either Mock Mode or Cloud Mode!**

---

## 🚀 Getting Started

### Phase 1: GCP Project Bootstrap

Before deploying to the cloud, prepare your GCP environment:

#### 1. Authenticate and Configure GCP

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# Authenticate with GCP
gcloud auth login

# Set your project ID (replace with your actual project ID)
export PROJECT_ID="your-project-id-here"
gcloud config set project $PROJECT_ID

# Verify the configuration
gcloud config list
echo "Current Project: $(gcloud config get-value project)"
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# Authenticate with GCP
gcloud auth login

# Set your project ID (replace with your actual project ID)
$env:PROJECT_ID = "your-project-id-here"
gcloud config set project $env:PROJECT_ID

# Verify the configuration
gcloud config list
Write-Host "Current Project: $(gcloud config get-value project)"
```
</details>

---

#### 2. Enable Required APIs

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# Enable necessary GCP services (this may take 2-3 minutes)
gcloud services enable \
  iam.googleapis.com \
  sts.googleapis.com \
  pubsub.googleapis.com \
  storage.googleapis.com \
  artifactregistry.googleapis.com \
  cloudresourcemanager.googleapis.com

# Verify enabled services
gcloud services list --enabled | grep -E "(iam|pubsub|storage|artifact)"
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# Enable necessary GCP services (this may take 2-3 minutes)
gcloud services enable `
  iam.googleapis.com `
  sts.googleapis.com `
  pubsub.googleapis.com `
  storage.googleapis.com `
  artifactregistry.googleapis.com `
  cloudresourcemanager.googleapis.com

# Verify enabled services
gcloud services list --enabled | Select-String -Pattern "(iam|pubsub|storage|artifact)"
```
</details>

---

#### 3. Create Terraform State Bucket

Terraform needs a place to store its state file remotely:

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# Create the state bucket (replace PROJECT_ID with your actual project ID)
export PROJECT_ID=$(gcloud config get-value project)
gcloud storage buckets create gs://${PROJECT_ID}-tfstate \
  --location=us-central1 \
  --uniform-bucket-level-access

# Verify bucket creation
gcloud storage buckets list | grep tfstate

# Enable versioning (recommended for state safety)
gcloud storage buckets update gs://${PROJECT_ID}-tfstate \
  --versioning
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# Create the state bucket (replace PROJECT_ID with your actual project ID)
$PROJECT_ID = gcloud config get-value project
gcloud storage buckets create gs://${PROJECT_ID}-tfstate `
  --location=us-central1 `
  --uniform-bucket-level-access

# Verify bucket creation
gcloud storage buckets list | Select-String tfstate

# Enable versioning (recommended for state safety)
gcloud storage buckets update gs://${PROJECT_ID}-tfstate `
  --versioning
```
</details>

**⚠️ Important:** After creating this bucket, update `terraform/providers.tf` with your actual bucket name:
```hcl
backend "gcs" {
  bucket = "your-actual-project-id-tfstate"  # ← Update this!
  prefix = "log-archiver/state"
}
```

---

#### 4. Setup Workload Identity Federation

This eliminates the need for long-lived JSON service account keys:

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# Create Identity Pool
gcloud iam workload-identity-pools create github-pool \
  --location="global" \
  --display-name="GitHub Pool" \
  --description="Pool for GitHub Actions authentication"

# Verify pool creation
gcloud iam workload-identity-pools list --location="global"

# Create OIDC Provider
gcloud iam workload-identity-pools providers create-oidc github-provider \
  --workload-identity-pool="github-pool" \
  --location="global" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
  --display-name="GitHub OIDC Provider"

# Verify provider creation
gcloud iam workload-identity-pools providers list \
  --workload-identity-pool="github-pool" \
  --location="global"
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# Create Identity Pool
gcloud iam workload-identity-pools create github-pool `
  --location="global" `
  --display-name="GitHub Pool" `
  --description="Pool for GitHub Actions authentication"

# Verify pool creation
gcloud iam workload-identity-pools list --location="global"

# Create OIDC Provider
gcloud iam workload-identity-pools providers create-oidc github-provider `
  --workload-identity-pool="github-pool" `
  --location="global" `
  --issuer-uri="https://token.actions.githubusercontent.com" `
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" `
  --display-name="GitHub OIDC Provider"

# Verify provider creation
gcloud iam workload-identity-pools providers list `
  --workload-identity-pool="github-pool" `
  --location="global"
```
</details>

**✅ Checkpoint:** You should see both the pool and provider listed in the verification commands.

---

### Phase 2: Configure GitHub Secrets (Part 1 - Before Terraform)

⚠️ **CRITICAL: This phase is split into TWO parts:**
- **Part 1 (NOW):** Add `GCP_PROJECT_ID` and `GCP_WIF_PROVIDER` 
- **Part 2 (AFTER Terraform):** Add `GCP_SA_EMAIL` and run WIF binding

**Why?** The Service Account doesn't exist yet - Terraform will create it in Phase 3.

---

Your CI/CD pipeline needs these secrets to authenticate with GCP:

| Secret Name | When to Add | Example |
|-------------|-------------|---------|
| `GCP_PROJECT_ID` | ✅ **NOW (Part 1)** | `devops-challenge-123456` |
| `GCP_WIF_PROVIDER` | ✅ **NOW (Part 1)** | `projects/123456789/locations/global/...` |
| `GCP_SA_EMAIL` | ⏳ **AFTER Terraform (Part 2)** | `log-archiver-sa@PROJECT.iam.gserviceaccount.com` |

---

#### Step 1: Getting the WIF Provider Path

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# 1. Get your project number
PROJECT_NUMBER=$(gcloud projects describe $(gcloud config get-value project) \
  --format="value(projectNumber)")

echo "Project Number: $PROJECT_NUMBER"

# 2. Construct the provider path
WIF_PROVIDER="projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider"

echo "----------------------------------------"
echo "Add this to GitHub Secrets:"
echo "GCP_WIF_PROVIDER = $WIF_PROVIDER"
echo "----------------------------------------"

# 3. Copy to clipboard (optional - requires xclip or pbcopy)
# Linux: echo "$WIF_PROVIDER" | xclip -selection clipboard
# macOS: echo "$WIF_PROVIDER" | pbcopy
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# 1. Get your project number
$PROJECT_ID = gcloud config get-value project
$PROJECT_NUMBER = gcloud projects describe $PROJECT_ID --format="value(projectNumber)"

Write-Host "Project Number: $PROJECT_NUMBER"

# 2. Construct the provider path
$WIF_PROVIDER = "projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider"

Write-Host "----------------------------------------"
Write-Host "Add this to GitHub Secrets:"
Write-Host "GCP_WIF_PROVIDER = $WIF_PROVIDER"
Write-Host "----------------------------------------"

# 3. Copy to clipboard (optional)
# $WIF_PROVIDER | Set-Clipboard
```
</details>

---

#### Step 2: Adding Secrets to GitHub (Part 1 - Only TWO secrets for now)

1. Navigate to your GitHub repository
2. Go to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add **ONLY these TWO secrets for now:**

**Add Secret 1: GCP_PROJECT_ID**

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# Get your project ID
gcloud config get-value project
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# Get your project ID
gcloud config get-value project
```
</details>

- **Name:** `GCP_PROJECT_ID`
- **Value:** Your actual project ID (e.g., `devops-challenge-485523`)

---

**Add Secret 2: GCP_WIF_PROVIDER**

Use the value from Step 1 above.
- **Name:** `GCP_WIF_PROVIDER`
- **Value:** `projects/YOUR_PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider`

---

⏸️ **STOP HERE - Do NOT add GCP_SA_EMAIL yet!**

The Service Account doesn't exist yet. You'll add it in **Phase 2 (Part 2)** after running Terraform.

**Next:** Proceed to Phase 3 to create the infrastructure with Terraform.

---

### Phase 3: Deploy Infrastructure

**⚠️ Before proceeding:** Make sure you've updated `terraform/providers.tf` with your actual project ID in the backend configuration!

#### Option A: Local Terraform Deployment

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# 1. Navigate to Terraform directory
cd terraform

# 2. Set your project ID variable
export TF_VAR_project_id=$(gcloud config get-value project)

# 3. Initialize Terraform (downloads providers and configures backend)
terraform init

# 4. Validate configuration
terraform validate

# 5. Preview changes (see what will be created)
terraform plan -var="project_id=$TF_VAR_project_id"

# 6. Apply infrastructure (type 'yes' when prompted)
terraform apply -var="project_id=$TF_VAR_project_id"

# 7. View outputs (resource names, URLs, etc.)
terraform output
```

**Alternative: Auto-approve (skips confirmation)**
```bash
terraform apply -var="project_id=$TF_VAR_project_id" -auto-approve
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# 1. Navigate to Terraform directory
cd terraform

# 2. Set your project ID variable
$env:TF_VAR_project_id = gcloud config get-value project

# 3. Initialize Terraform (downloads providers and configures backend)
terraform init

# 4. Validate configuration
terraform validate

# 5. Preview changes (see what will be created)
terraform plan -var="project_id=$env:TF_VAR_project_id"

# 6. Apply infrastructure (type 'yes' when prompted)
terraform apply -var="project_id=$env:TF_VAR_project_id"

# 7. View outputs (resource names, URLs, etc.)
terraform output
```

**Alternative: Auto-approve (skips confirmation)**
```powershell
terraform apply -var="project_id=$env:TF_VAR_project_id" -auto-approve
```
</details>

---

**What this creates:**
- ✅ Pub/Sub Topic: `log-archiver-topic`
- ✅ Pub/Sub Subscription: `log-archiver-sub`
- ✅ GCS Bucket: `YOUR_PROJECT_ID-log-archive-storage`
- ✅ Service Account: `log-archiver-sa`
- ✅ Artifact Registry: `log-archiver-repo`
- ✅ IAM Bindings: Minimal permissions

**Expected Output:**
```hcl
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

pubsub_subscription_name = "log-archiver-sub"
pubsub_topic_name = "log-archiver-topic"
service_account_email = "log-archiver-sa@your-project-id.iam.gserviceaccount.com"
storage_bucket_url = "gs://your-project-id-log-archive-storage"
```

**⚠️ After successful apply:**
1. Copy the `service_account_email` from the output
2. Add it to GitHub Secrets as `GCP_SA_EMAIL`
3. Run the WIF binding command from Phase 2

---

#### Option B: Automated via CI/CD

Once GitHub Secrets are configured, simply push a release tag:

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# 1. Make sure all changes are committed
git add .
git commit -m "feat: initial cloud deployment configuration"

# 2. Create and push a release tag
git tag v1.0.0
git push origin v1.0.0

# 3. Watch the GitHub Actions workflow
# Go to: https://github.com/YOUR_USERNAME/hyphametrics-devops-challenge/actions
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# 1. Make sure all changes are committed
git add .
git commit -m "feat: initial cloud deployment configuration"

# 2. Create and push a release tag
git tag v1.0.0
git push origin v1.0.0

# 3. Watch the GitHub Actions workflow
# Go to: https://github.com/YOUR_USERNAME/hyphametrics-devops-challenge/actions
```
</details>

The GitHub Actions workflow will automatically:
1. ✅ Authenticate to GCP via Workload Identity
2. ✅ Build the Docker image
3. ✅ Scan for vulnerabilities with Trivy
4. ✅ Push to Artifact Registry
5. ✅ Apply Terraform changes

---

#### Troubleshooting Common Issues:

**Error: "Backend initialization required"**
```bash
# Solution: Run terraform init
terraform init -reconfigure
```

**Error: "Error loading state: NoSuchBucket"**
```bash
# Solution: Verify the state bucket exists and name is correct in providers.tf
gcloud storage buckets list | grep tfstate
```

**Error: "API has not been enabled"**
```bash
# Solution: Enable the missing API
gcloud services enable SERVICE_NAME.googleapis.com
```

**Error: "Permission denied on resource project"**
```bash
# Solution: Verify you have Owner/Editor role
gcloud projects get-iam-policy $(gcloud config get-value project) \
  --flatten="bindings[].members" \
  --filter="bindings.members:user:YOUR_EMAIL"
```

---

### ✅ Phase 3 Checkpoint

After successful `terraform apply`, verify:

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# Check all created resources
echo "=== Pub/Sub Resources ==="
gcloud pubsub topics list
gcloud pubsub subscriptions list

echo "=== Storage Bucket ==="
gcloud storage buckets list | grep log-archive

echo "=== Service Account ==="
gcloud iam service-accounts list | grep log-archiver

echo "=== Artifact Registry ==="
gcloud artifacts repositories list

# Get the Service Account email (SAVE THIS!)
echo "=== Service Account Email (needed for Phase 2 Part 2) ==="
terraform output service_account_email
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# Check all created resources
Write-Host "=== Pub/Sub Resources ==="
gcloud pubsub topics list
gcloud pubsub subscriptions list

Write-Host "=== Storage Bucket ==="
gcloud storage buckets list | Select-String log-archive

Write-Host "=== Service Account ==="
gcloud iam service-accounts list | Select-String log-archiver

Write-Host "=== Artifact Registry ==="
gcloud artifacts repositories list

# Get the Service Account email (SAVE THIS!)
Write-Host "=== Service Account Email (needed for Phase 2 Part 2) ==="
terraform output service_account_email
```
</details>

**🎉 Infrastructure Created Successfully!**

⚠️ **NEXT STEP:** Go to **Phase 2 (Part 2)** below to complete GitHub secrets and WIF binding.

---

## 🔗 Phase 2 (Part 2): Complete GitHub Secrets & WIF Binding

⚠️ **DO THIS AFTER Phase 3** - The Service Account now exists!

Now that Terraform has created the Service Account, you need to:
1. Add the `GCP_SA_EMAIL` secret to GitHub
2. Grant WIF permissions to the Service Account

---

### Step 1: Get the Service Account Email

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# Option 1: From Terraform output
cd terraform
terraform output service_account_email

# Option 2: Directly from GCP
gcloud iam service-accounts list --project=$(gcloud config get-value project) | grep log-archiver

# Copy the email address shown
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# Option 1: From Terraform output
cd terraform
terraform output service_account_email

# Option 2: Directly from GCP
gcloud iam service-accounts list --project=$(gcloud config get-value project) | Select-String log-archiver

# Copy the email address shown
```
</details>

**Expected output:**
```
log-archiver-sa@devops-challenge-485523.iam.gserviceaccount.com
```

---

### Step 2: Add GCP_SA_EMAIL to GitHub Secrets

1. Go to: `https://github.com/YOUR_USERNAME/hyphametrics-devops-challenge/settings/secrets/actions`
2. Click **New repository secret**
3. **Name:** `GCP_SA_EMAIL`
4. **Value:** `log-archiver-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com` (paste the email from Step 1)
5. Click **Add secret**

---

### Step 3: Grant WIF Permissions to Service Account

This allows GitHub Actions to impersonate the Service Account:

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# Set variables
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
export GITHUB_REPO="YOUR_GITHUB_USERNAME/hyphametrics-devops-challenge"  # e.g., "naesman1/hyphametrics-devops-challenge"

echo "Project ID: $PROJECT_ID"
echo "Project Number: $PROJECT_NUMBER"
echo "GitHub Repo: $GITHUB_REPO"

# Grant the WIF principal permission to impersonate the service account
gcloud iam service-accounts add-iam-policy-binding \
  "log-archiver-sa@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/attribute.repository/${GITHUB_REPO}"

# Verify the binding
echo "Verifying binding..."
gcloud iam service-accounts get-iam-policy \
  "log-archiver-sa@${PROJECT_ID}.iam.gserviceaccount.com"
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# Set variables
$PROJECT_ID = gcloud config get-value project
$PROJECT_NUMBER = gcloud projects describe $PROJECT_ID --format="value(projectNumber)"
$GITHUB_REPO = "YOUR_GITHUB_USERNAME/hyphametrics-devops-challenge"  # e.g., "naesman1/hyphametrics-devops-challenge"

Write-Host "Project ID: $PROJECT_ID"
Write-Host "Project Number: $PROJECT_NUMBER"
Write-Host "GitHub Repo: $GITHUB_REPO"

# Grant the WIF principal permission to impersonate the service account
gcloud iam service-accounts add-iam-policy-binding `
  "log-archiver-sa@${PROJECT_ID}.iam.gserviceaccount.com" `
  --role="roles/iam.workloadIdentityUser" `
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/attribute.repository/${GITHUB_REPO}"

# Verify the binding
Write-Host "Verifying binding..."
gcloud iam service-accounts get-iam-policy `
  "log-archiver-sa@${PROJECT_ID}.iam.gserviceaccount.com"
```
</details>

**Expected output:**
```yaml
bindings:
- members:
  - principalSet://iam.googleapis.com/projects/123456789/locations/global/workloadIdentityPools/github-pool/attribute.repository/naesman1/hyphametrics-devops-challenge
  role: roles/iam.workloadIdentityUser
etag: BwYiMZp1234=
version: 1
```

---

### Step 4: Verify All GitHub Secrets

Ensure you now have **ALL THREE** secrets configured:

Go to: `https://github.com/YOUR_USERNAME/hyphametrics-devops-challenge/settings/secrets/actions`

You should see:
- ✅ `GCP_PROJECT_ID`
- ✅ `GCP_WIF_PROVIDER`
- ✅ `GCP_SA_EMAIL`

**✅ Configuration Complete!** You're now ready to use the CI/CD pipeline.

---

## 🔄 CI/CD Pipeline

The deployment pipeline is triggered by **release tags** (e.g., `v1.0.1`, `v2.0.0`).

---

## ✅ **Prerequisites for CI/CD - COMPLETE CHECKLIST**

⚠️ **CRITICAL:** You MUST complete ALL phases in order before running CI/CD. Skipping steps will cause pipeline failures.

---

### **Quick Checklist:**

Use this checklist to ensure everything is ready:

| # | Requirement | Verification Command | Expected Result |
|---|-------------|---------------------|-----------------|
| 1️⃣ | **GCP APIs Enabled** | See commands below | All APIs active |
| 2️⃣ | **Terraform State Bucket** | See commands below | Bucket exists |
| 3️⃣ | **Workload Identity Pool** | See commands below | Pool and provider exist |
| 4️⃣ | **GitHub Secrets (Part 1)** | Check GitHub Settings | PROJECT_ID + WIF_PROVIDER |
| 5️⃣ | **Terraform Deployed** | See commands below | Resources created |
| 6️⃣ | **GitHub Secrets (Part 2)** | Check GitHub Settings | SA_EMAIL added |
| 7️⃣ | **WIF Binding Complete** | See commands below | Binding exists |
| 8️⃣ | **GitHub Workflow File** | Check repository | `.github/workflows/deploy.yaml` exists |

---

### **Detailed Verification Steps:**

#### ✅ **1. Verify GCP APIs are Enabled**

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# Check all required APIs
echo "Checking required APIs..."
gcloud services list --enabled --filter="name:iam.googleapis.com OR \
  name:sts.googleapis.com OR \
  name:pubsub.googleapis.com OR \
  name:storage.googleapis.com OR \
  name:artifactregistry.googleapis.com"

# Count enabled APIs (should be 5)
ENABLED_COUNT=$(gcloud services list --enabled --filter="name:iam.googleapis.com OR \
  name:sts.googleapis.com OR \
  name:pubsub.googleapis.com OR \
  name:storage.googleapis.com OR \
  name:artifactregistry.googleapis.com" | grep -c "NAME")

if [ $ENABLED_COUNT -eq 5 ]; then
  echo "✅ All APIs enabled"
else
  echo "❌ Missing APIs - run Phase 1 commands"
fi
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# Check all required APIs
Write-Host "Checking required APIs..."
gcloud services list --enabled --filter="name:iam.googleapis.com OR name:sts.googleapis.com OR name:pubsub.googleapis.com OR name:storage.googleapis.com OR name:artifactregistry.googleapis.com"

# Manual verification
$apis = @(
  "iam.googleapis.com",
  "sts.googleapis.com",
  "pubsub.googleapis.com",
  "storage.googleapis.com",
  "artifactregistry.googleapis.com"
)

foreach ($api in $apis) {
  $result = gcloud services list --enabled --filter="name:$api" 2>$null
  if ($result) {
    Write-Host "✅ $api enabled"
  } else {
    Write-Host "❌ $api NOT enabled - run Phase 1"
  }
}
```
</details>

**Expected:** All 5 APIs should show as enabled.

---

#### ✅ **2. Verify Terraform State Bucket Exists**

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="${PROJECT_ID}-tfstate"

# Check if bucket exists
if gcloud storage buckets describe gs://$BUCKET_NAME &>/dev/null; then
  echo "✅ Terraform state bucket exists: gs://$BUCKET_NAME"
else
  echo "❌ Bucket does NOT exist - create it in Phase 1"
  echo "Run: gcloud storage buckets create gs://$BUCKET_NAME --location=us-central1"
fi
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
$PROJECT_ID = gcloud config get-value project
$BUCKET_NAME = "$PROJECT_ID-tfstate"

# Check if bucket exists
$bucketCheck = gcloud storage buckets describe gs://$BUCKET_NAME 2>$null
if ($bucketCheck) {
  Write-Host "✅ Terraform state bucket exists: gs://$BUCKET_NAME"
} else {
  Write-Host "❌ Bucket does NOT exist - create it in Phase 1"
  Write-Host "Run: gcloud storage buckets create gs://$BUCKET_NAME --location=us-central1"
}
```
</details>

**Expected:** Bucket `YOUR_PROJECT_ID-tfstate` exists.

---

#### ✅ **3. Verify Workload Identity Federation**

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# Check WIF pool
echo "Checking Workload Identity Pool..."
if gcloud iam workload-identity-pools describe github-pool --location=global &>/dev/null; then
  echo "✅ WIF Pool exists"
else
  echo "❌ WIF Pool missing - run Phase 1 WIF setup"
fi

# Check WIF provider
echo "Checking WIF Provider..."
if gcloud iam workload-identity-pools providers describe github-provider \
  --workload-identity-pool=github-pool --location=global &>/dev/null; then
  echo "✅ WIF Provider exists"
else
  echo "❌ WIF Provider missing - run Phase 1 WIF setup"
fi

# Get WIF provider path for GitHub secrets
PROJECT_NUMBER=$(gcloud projects describe $(gcloud config get-value project) --format="value(projectNumber)")
echo ""
echo "WIF Provider Path (needed for GitHub secret):"
echo "projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider"
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# Check WIF pool
Write-Host "Checking Workload Identity Pool..."
$poolCheck = gcloud iam workload-identity-pools describe github-pool --location=global 2>$null
if ($poolCheck) {
  Write-Host "✅ WIF Pool exists"
} else {
  Write-Host "❌ WIF Pool missing - run Phase 1 WIF setup"
}

# Check WIF provider
Write-Host "Checking WIF Provider..."
$providerCheck = gcloud iam workload-identity-pools providers describe github-provider --workload-identity-pool=github-pool --location=global 2>$null
if ($providerCheck) {
  Write-Host "✅ WIF Provider exists"
} else {
  Write-Host "❌ WIF Provider missing - run Phase 1 WIF setup"
}

# Get WIF provider path for GitHub secrets
$PROJECT_ID = gcloud config get-value project
$PROJECT_NUMBER = gcloud projects describe $PROJECT_ID --format="value(projectNumber)"
Write-Host ""
Write-Host "WIF Provider Path (needed for GitHub secret):"
Write-Host "projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider"
```
</details>

**Expected:** Both pool and provider exist.

---

#### ✅ **4. Verify GitHub Secrets (Part 1 - Before Terraform)**

**Manual Check:**
1. Go to: `https://github.com/YOUR_USERNAME/hyphametrics-devops-challenge/settings/secrets/actions`
2. Verify these secrets exist:
   - ✅ `GCP_PROJECT_ID`
   - ✅ `GCP_WIF_PROVIDER`

**Expected:** Both secrets visible in GitHub settings (values are hidden).

---

#### ✅ **5. Verify Terraform Infrastructure is Deployed**

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
PROJECT_ID=$(gcloud config get-value project)

echo "=== Checking Pub/Sub Resources ==="
if gcloud pubsub topics describe log-archiver-topic &>/dev/null; then
  echo "✅ Pub/Sub Topic exists"
else
  echo "❌ Pub/Sub Topic missing - run terraform apply"
fi

if gcloud pubsub subscriptions describe log-archiver-sub &>/dev/null; then
  echo "✅ Pub/Sub Subscription exists"
else
  echo "❌ Pub/Sub Subscription missing - run terraform apply"
fi

echo ""
echo "=== Checking Storage Bucket ==="
if gcloud storage buckets describe gs://${PROJECT_ID}-log-archive-storage &>/dev/null; then
  echo "✅ GCS Archive Bucket exists"
else
  echo "❌ GCS Archive Bucket missing - run terraform apply"
fi

echo ""
echo "=== Checking Service Account ==="
if gcloud iam service-accounts describe log-archiver-sa@${PROJECT_ID}.iam.gserviceaccount.com &>/dev/null; then
  echo "✅ Service Account exists"
  gcloud iam service-accounts describe log-archiver-sa@${PROJECT_ID}.iam.gserviceaccount.com --format="value(email)"
else
  echo "❌ Service Account missing - run terraform apply"
fi

echo ""
echo "=== Checking Artifact Registry ==="
if gcloud artifacts repositories describe log-archiver-repo --location=us-central1 &>/dev/null; then
  echo "✅ Artifact Registry Repository exists"
else
  echo "❌ Artifact Registry Repository missing - run terraform apply"
fi
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
$PROJECT_ID = gcloud config get-value project

Write-Host "=== Checking Pub/Sub Resources ==="
if (gcloud pubsub topics describe log-archiver-topic 2>$null) {
  Write-Host "✅ Pub/Sub Topic exists"
} else {
  Write-Host "❌ Pub/Sub Topic missing - run terraform apply"
}

if (gcloud pubsub subscriptions describe log-archiver-sub 2>$null) {
  Write-Host "✅ Pub/Sub Subscription exists"
} else {
  Write-Host "❌ Pub/Sub Subscription missing - run terraform apply"
}

Write-Host ""
Write-Host "=== Checking Storage Bucket ==="
if (gcloud storage buckets describe gs://${PROJECT_ID}-log-archive-storage 2>$null) {
  Write-Host "✅ GCS Archive Bucket exists"
} else {
  Write-Host "❌ GCS Archive Bucket missing - run terraform apply"
}

Write-Host ""
Write-Host "=== Checking Service Account ==="
if (gcloud iam service-accounts describe log-archiver-sa@${PROJECT_ID}.iam.gserviceaccount.com 2>$null) {
  Write-Host "✅ Service Account exists"
  gcloud iam service-accounts describe log-archiver-sa@${PROJECT_ID}.iam.gserviceaccount.com --format="value(email)"
} else {
  Write-Host "❌ Service Account missing - run terraform apply"
}

Write-Host ""
Write-Host "=== Checking Artifact Registry ==="
if (gcloud artifacts repositories describe log-archiver-repo --location=us-central1 2>$null) {
  Write-Host "✅ Artifact Registry Repository exists"
} else {
  Write-Host "❌ Artifact Registry Repository missing - run terraform apply"
}
```
</details>

**Expected:** All 5 resources exist (Topic, Subscription, Bucket, Service Account, Artifact Registry).

---

#### ✅ **6. Verify GitHub Secrets (Part 2 - After Terraform)**

**Manual Check:**
1. Go to: `https://github.com/YOUR_USERNAME/hyphametrics-devops-challenge/settings/secrets/actions`
2. Verify this THIRD secret exists:
   - ✅ `GCP_SA_EMAIL`

**Expected:** All THREE secrets visible (PROJECT_ID, WIF_PROVIDER, SA_EMAIL).

---

#### ✅ **7. Verify WIF Binding is Complete**

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
PROJECT_ID=$(gcloud config get-value project)

echo "Checking WIF binding on Service Account..."
SA_POLICY=$(gcloud iam service-accounts get-iam-policy \
  log-archiver-sa@${PROJECT_ID}.iam.gserviceaccount.com \
  --format=json 2>/dev/null)

if echo "$SA_POLICY" | grep -q "workloadIdentityUser"; then
  echo "✅ WIF binding exists"
  echo ""
  echo "Binding details:"
  gcloud iam service-accounts get-iam-policy \
    log-archiver-sa@${PROJECT_ID}.iam.gserviceaccount.com
else
  echo "❌ WIF binding missing - run Phase 2 Part 2 commands"
  echo "Run the 'Grant WIF permissions' command from Phase 2 Part 2"
fi
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
$PROJECT_ID = gcloud config get-value project

Write-Host "Checking WIF binding on Service Account..."
$saPolicy = gcloud iam service-accounts get-iam-policy log-archiver-sa@${PROJECT_ID}.iam.gserviceaccount.com --format=json 2>$null

if ($saPolicy -match "workloadIdentityUser") {
  Write-Host "✅ WIF binding exists"
  Write-Host ""
  Write-Host "Binding details:"
  gcloud iam service-accounts get-iam-policy log-archiver-sa@${PROJECT_ID}.iam.gserviceaccount.com
} else {
  Write-Host "❌ WIF binding missing - run Phase 2 Part 2 commands"
  Write-Host "Run the 'Grant WIF permissions' command from Phase 2 Part 2"
}
```
</details>

**Expected:** Policy includes `roles/iam.workloadIdentityUser` binding.

---

#### ✅ **8. Verify GitHub Workflow File Exists**

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# Check if workflow file exists
if [ -f ".github/workflows/deploy.yaml" ] || [ -f ".github/workflows/deploy.yml" ]; then
  echo "✅ GitHub workflow file exists"
  ls -lh .github/workflows/deploy.y*ml
else
  echo "❌ Workflow file missing"
  echo "Create: .github/workflows/deploy.yaml"
  echo "You need to add the CI/CD workflow configuration file"
fi
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# Check if workflow file exists
if (Test-Path ".github/workflows/deploy.yaml") {
  Write-Host "✅ GitHub workflow file exists"
  Get-Item .github/workflows/deploy.yaml | Format-List Name, Length, LastWriteTime
} elseif (Test-Path ".github/workflows/deploy.yml") {
  Write-Host "✅ GitHub workflow file exists"
  Get-Item .github/workflows/deploy.yml | Format-List Name, Length, LastWriteTime
} else {
  Write-Host "❌ Workflow file missing"
  Write-Host "Create: .github/workflows/deploy.yaml"
  Write-Host "You need to add the CI/CD workflow configuration file"
}
```
</details>

**Expected:** File `.github/workflows/deploy.yaml` exists in your repository.

---

### **⚠️ STOP: Do NOT proceed until ALL checks pass**

If any verification fails:
1. Go back to the corresponding Phase
2. Complete the missing steps
3. Re-run verification
4. Only proceed when ALL ✅ are green

---

### **🎉 All Prerequisites Complete?**

If all verifications passed, you're ready to trigger the CI/CD pipeline!

**Final verification - Run ALL checks at once:**

<details>
<summary><b>🐧 Linux / macOS (Bash) - Complete Verification Script</b></summary>

```bash
#!/bin/bash
echo "================================"
echo "CI/CD Prerequisites Check"
echo "================================"
echo ""

PROJECT_ID=$(gcloud config get-value project)
PASS=0
FAIL=0

# 1. APIs
echo "1. Checking APIs..."
if [ $(gcloud services list --enabled --filter="name:iam.googleapis.com" | grep -c "NAME") -eq 1 ]; then
  echo "   ✅ APIs enabled"; ((PASS++))
else
  echo "   ❌ APIs missing"; ((FAIL++))
fi

# 2. State bucket
echo "2. Checking Terraform state bucket..."
if gcloud storage buckets describe gs://${PROJECT_ID}-tfstate &>/dev/null; then
  echo "   ✅ State bucket exists"; ((PASS++))
else
  echo "   ❌ State bucket missing"; ((FAIL++))
fi

# 3. WIF
echo "3. Checking Workload Identity..."
if gcloud iam workload-identity-pools describe github-pool --location=global &>/dev/null; then
  echo "   ✅ WIF configured"; ((PASS++))
else
  echo "   ❌ WIF missing"; ((FAIL++))
fi

# 4. Service Account
echo "4. Checking Service Account..."
if gcloud iam service-accounts describe log-archiver-sa@${PROJECT_ID}.iam.gserviceaccount.com &>/dev/null; then
  echo "   ✅ Service Account exists"; ((PASS++))
else
  echo "   ❌ Service Account missing"; ((FAIL++))
fi

# 5. Pub/Sub
echo "5. Checking Pub/Sub..."
if gcloud pubsub topics describe log-archiver-topic &>/dev/null; then
  echo "   ✅ Pub/Sub configured"; ((PASS++))
else
  echo "   ❌ Pub/Sub missing"; ((FAIL++))
fi

# 6. Bucket
echo "6. Checking GCS bucket..."
if gcloud storage buckets describe gs://${PROJECT_ID}-log-archive-storage &>/dev/null; then
  echo "   ✅ Archive bucket exists"; ((PASS++))
else
  echo "   ❌ Archive bucket missing"; ((FAIL++))
fi

# 7. Artifact Registry
echo "7. Checking Artifact Registry..."
if gcloud artifacts repositories describe log-archiver-repo --location=us-central1 &>/dev/null; then
  echo "   ✅ Artifact Registry exists"; ((PASS++))
else
  echo "   ❌ Artifact Registry missing"; ((FAIL++))
fi

# 8. WIF Binding
echo "8. Checking WIF binding..."
if gcloud iam service-accounts get-iam-policy log-archiver-sa@${PROJECT_ID}.iam.gserviceaccount.com --format=json 2>/dev/null | grep -q "workloadIdentityUser"; then
  echo "   ✅ WIF binding complete"; ((PASS++))
else
  echo "   ❌ WIF binding missing"; ((FAIL++))
fi

echo ""
echo "================================"
echo "Results: $PASS passed, $FAIL failed"
echo "================================"

if [ $FAIL -eq 0 ]; then
  echo "🎉 All prerequisites met! Ready for CI/CD"
  echo ""
  echo "Next steps:"
  echo "1. Verify GitHub secrets manually"
  echo "2. Push a release tag: git tag v1.0.0 && git push origin v1.0.0"
else
  echo "⚠️  Please fix failed checks before proceeding"
fi
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell) - Complete Verification Script</b></summary>

```powershell
Write-Host "================================"
Write-Host "CI/CD Prerequisites Check"
Write-Host "================================"
Write-Host ""

$PROJECT_ID = gcloud config get-value project
$PASS = 0
$FAIL = 0

# 1. APIs
Write-Host "1. Checking APIs..."
if (gcloud services list --enabled --filter="name:iam.googleapis.com" 2>$null) {
  Write-Host "   ✅ APIs enabled"; $PASS++
} else {
  Write-Host "   ❌ APIs missing"; $FAIL++
}

# 2. State bucket
Write-Host "2. Checking Terraform state bucket..."
if (gcloud storage buckets describe gs://${PROJECT_ID}-tfstate 2>$null) {
  Write-Host "   ✅ State bucket exists"; $PASS++
} else {
  Write-Host "   ❌ State bucket missing"; $FAIL++
}

# 3. WIF
Write-Host "3. Checking Workload Identity..."
if (gcloud iam workload-identity-pools describe github-pool --location=global 2>$null) {
  Write-Host "   ✅ WIF configured"; $PASS++
} else {
  Write-Host "   ❌ WIF missing"; $FAIL++
}

# 4. Service Account
Write-Host "4. Checking Service Account..."
if (gcloud iam service-accounts describe log-archiver-sa@${PROJECT_ID}.iam.gserviceaccount.com 2>$null) {
  Write-Host "   ✅ Service Account exists"; $PASS++
} else {
  Write-Host "   ❌ Service Account missing"; $FAIL++
}

# 5. Pub/Sub
Write-Host "5. Checking Pub/Sub..."
if (gcloud pubsub topics describe log-archiver-topic 2>$null) {
  Write-Host "   ✅ Pub/Sub configured"; $PASS++
} else {
  Write-Host "   ❌ Pub/Sub missing"; $FAIL++
}

# 6. Bucket
Write-Host "6. Checking GCS bucket..."
if (gcloud storage buckets describe gs://${PROJECT_ID}-log-archive-storage 2>$null) {
  Write-Host "   ✅ Archive bucket exists"; $PASS++
} else {
  Write-Host "   ❌ Archive bucket missing"; $FAIL++
}

# 7. Artifact Registry
Write-Host "7. Checking Artifact Registry..."
if (gcloud artifacts repositories describe log-archiver-repo --location=us-central1 2>$null) {
  Write-Host "   ✅ Artifact Registry exists"; $PASS++
} else {
  Write-Host "   ❌ Artifact Registry missing"; $FAIL++
}

# 8. WIF Binding
Write-Host "8. Checking WIF binding..."
$saPolicy = gcloud iam service-accounts get-iam-policy log-archiver-sa@${PROJECT_ID}.iam.gserviceaccount.com --format=json 2>$null
if ($saPolicy -match "workloadIdentityUser") {
  Write-Host "   ✅ WIF binding complete"; $PASS++
} else {
  Write-Host "   ❌ WIF binding missing"; $FAIL++
}

Write-Host ""
Write-Host "================================"
Write-Host "Results: $PASS passed, $FAIL failed"
Write-Host "================================"

if ($FAIL -eq 0) {
  Write-Host "🎉 All prerequisites met! Ready for CI/CD"
  Write-Host ""
  Write-Host "Next steps:"
  Write-Host "1. Verify GitHub secrets manually"
  Write-Host "2. Push a release tag: git tag v1.0.0; git push origin v1.0.0"
} else {
  Write-Host "⚠️  Please fix failed checks before proceeding"
}
```
</details>

---

## 🚀 **Ready to Deploy?**

Once all prerequisites are verified, proceed to trigger the pipeline below.

---

### How to Trigger the Pipeline:

The pipeline automatically runs when you push a **release tag** matching the pattern `v*.*.*` (e.g., `v1.0.0`, `v1.0.1`, `v2.0.0`).

#### Option A: First Deployment (v1.0.0)

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# 1. Navigate to your repository
cd /path/to/hyphametrics-devops-challenge

# 2. Ensure all changes are committed
git status

# 3. If there are uncommitted changes, commit them
git add .
git commit -m "feat: ready for production deployment"

# 4. Create the first release tag
git tag v1.0.0

# 5. Push the tag to trigger the pipeline
git push origin v1.0.0

# 6. Watch the pipeline execution
echo "Pipeline triggered! View at:"
echo "https://github.com/YOUR_USERNAME/hyphametrics-devops-challenge/actions"
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# 1. Navigate to your repository
cd D:\path\to\hyphametrics-devops-challenge

# 2. Ensure all changes are committed
git status

# 3. If there are uncommitted changes, commit them
git add .
git commit -m "feat: ready for production deployment"

# 4. Create the first release tag
git tag v1.0.0

# 5. Push the tag to trigger the pipeline
git push origin v1.0.0

# 6. Watch the pipeline execution
Write-Host "Pipeline triggered! View at:"
Write-Host "https://github.com/YOUR_USERNAME/hyphametrics-devops-challenge/actions"
```
</details>

---

#### Option B: Subsequent Deployments (Updates)

For updates and new features, increment the version number:

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# For minor updates (e.g., v1.0.0 → v1.0.1)
git add .
git commit -m "fix: improved error handling"
git tag v1.0.1
git push origin v1.0.1

# For new features (e.g., v1.0.1 → v1.1.0)
git add .
git commit -m "feat: added monitoring alerts"
git tag v1.1.0
git push origin v1.1.0

# For major changes (e.g., v1.1.0 → v2.0.0)
git add .
git commit -m "feat!: breaking changes - new architecture"
git tag v2.0.0
git push origin v2.0.0
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# For minor updates (e.g., v1.0.0 → v1.0.1)
git add .
git commit -m "fix: improved error handling"
git tag v1.0.1
git push origin v1.0.1

# For new features (e.g., v1.0.1 → v1.1.0)
git add .
git commit -m "feat: added monitoring alerts"
git tag v1.1.0
git push origin v1.1.0

# For major changes (e.g., v1.1.0 → v2.0.0)
git add .
git commit -m "feat!: breaking changes - new architecture"
git tag v2.0.0
git push origin v2.0.0
```
</details>

---

### Pipeline Stages:

```
┌──────────────┐
│ Tag Release  │
│  (v1.0.x)    │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────────┐
│ 1. Checkout Code                     │
│    - Clones repository               │
│    - Checks out the tagged version   │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│ 2. Authenticate to GCP               │
│    - Uses Workload Identity (OIDC)   │
│    - No JSON keys needed             │
│    - Impersonates Service Account    │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│ 3. Build Docker Image                │
│    - Multi-stage build               │
│    - Security hardening              │
│    - Tags: v1.0.0 and latest         │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│ 4. Security Scan (Trivy)             │
│    - Vulnerability detection         │
│    - Compliance check                │
│    - Fails on HIGH/CRITICAL issues   │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│ 5. Push to Artifact Registry         │
│    - Authenticates to GAR            │
│    - Pushes versioned tag (v1.0.0)   │
│    - Updates latest tag              │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│ 6. Apply Terraform                   │
│    - Plans infrastructure changes    │
│    - Applies updates                 │
│    - Updates resources if needed     │
└──────────────────────────────────────┘
```

---

### Monitoring Pipeline Execution:

#### View Pipeline Status:

<details>
<summary><b>🌐 Web Interface (Recommended)</b></summary>

1. Navigate to: `https://github.com/YOUR_USERNAME/hyphametrics-devops-challenge/actions`
2. Click on the most recent workflow run
3. Watch real-time logs for each step
4. Check for success ✅ or failure ❌ indicators

</details>

<details>
<summary><b>🐧 Linux / macOS (Bash) - Using GitHub CLI</b></summary>

```bash
# Install GitHub CLI (if not already installed)
# macOS: brew install gh
# Linux: https://github.com/cli/cli/blob/trunk/docs/install_linux.md

# Authenticate
gh auth login

# Watch workflow runs
gh run list --limit 5

# View specific run details
gh run view

# Watch run in real-time
gh run watch
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell) - Using GitHub CLI</b></summary>

```powershell
# Install GitHub CLI
# Download from: https://cli.github.com/
# Or via winget: winget install --id GitHub.cli

# Authenticate
gh auth login

# Watch workflow runs
gh run list --limit 5

# View specific run details
gh run view

# Watch run in real-time
gh run watch
```
</details>

---

### Pipeline Success Verification:

After the pipeline completes successfully, verify the deployment:

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# 1. Verify Docker image was pushed to Artifact Registry
gcloud artifacts docker images list \
  us-central1-docker.pkg.dev/$(gcloud config get-value project)/log-archiver-repo

# 2. Check the specific version
gcloud artifacts docker images describe \
  us-central1-docker.pkg.dev/$(gcloud config get-value project)/log-archiver-repo/log-archiver:v1.0.0

# 3. List all available tags
gcloud artifacts docker tags list \
  us-central1-docker.pkg.dev/$(gcloud config get-value project)/log-archiver-repo/log-archiver

# 4. Verify infrastructure is up-to-date
cd terraform
terraform plan -var="project_id=$(gcloud config get-value project)"
# Should show: "No changes. Your infrastructure matches the configuration."
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# 1. Verify Docker image was pushed to Artifact Registry
$PROJECT_ID = gcloud config get-value project
gcloud artifacts docker images list `
  us-central1-docker.pkg.dev/$PROJECT_ID/log-archiver-repo

# 2. Check the specific version
gcloud artifacts docker images describe `
  us-central1-docker.pkg.dev/$PROJECT_ID/log-archiver-repo/log-archiver:v1.0.0

# 3. List all available tags
gcloud artifacts docker tags list `
  us-central1-docker.pkg.dev/$PROJECT_ID/log-archiver-repo/log-archiver

# 4. Verify infrastructure is up-to-date
cd terraform
terraform plan -var="project_id=$PROJECT_ID"
# Should show: "No changes. Your infrastructure matches the configuration."
```
</details>

---

### Testing the Deployed Application:

Once the pipeline succeeds, you can test the application:

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# 1. Pull the deployed image from Artifact Registry
PROJECT_ID=$(gcloud config get-value project)
gcloud auth configure-docker us-central1-docker.pkg.dev

docker pull us-central1-docker.pkg.dev/${PROJECT_ID}/log-archiver-repo/log-archiver:v1.0.0

# 2. Authenticate for local testing
gcloud auth application-default login

# 3. Run the container locally with real GCP resources
docker run --rm \
  -e PROJECT_ID="${PROJECT_ID}" \
  -e SUBSCRIPTION_NAME="log-archiver-sub" \
  -e BUCKET_NAME="${PROJECT_ID}-log-archive-storage" \
  -v ~/.config/gcloud:/root/.config/gcloud:ro \
  us-central1-docker.pkg.dev/${PROJECT_ID}/log-archiver-repo/log-archiver:v1.0.0

# 4. Test by publishing a message to Pub/Sub
gcloud pubsub topics publish log-archiver-topic \
  --message="Test message from CI/CD verification"

# 5. Check if the JSON was archived to GCS
gcloud storage ls gs://${PROJECT_ID}-log-archive-storage/archive/
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# 1. Pull the deployed image from Artifact Registry
$PROJECT_ID = gcloud config get-value project
gcloud auth configure-docker us-central1-docker.pkg.dev

docker pull us-central1-docker.pkg.dev/${PROJECT_ID}/log-archiver-repo/log-archiver:v1.0.0

# 2. Authenticate for local testing
gcloud auth application-default login

# 3. Run the container locally with real GCP resources
docker run --rm `
  -e PROJECT_ID="$PROJECT_ID" `
  -e SUBSCRIPTION_NAME="log-archiver-sub" `
  -e BUCKET_NAME="$PROJECT_ID-log-archive-storage" `
  -v ${env:APPDATA}/gcloud:/root/.config/gcloud:ro `
  us-central1-docker.pkg.dev/${PROJECT_ID}/log-archiver-repo/log-archiver:v1.0.0

# 4. Test by publishing a message to Pub/Sub
gcloud pubsub topics publish log-archiver-topic `
  --message="Test message from CI/CD verification"

# 5. Check if the JSON was archived to GCS
gcloud storage ls gs://${PROJECT_ID}-log-archive-storage/archive/
```
</details>

---

### Common Pipeline Issues:

| Error | Cause | Solution |
|-------|-------|----------|
| **Authentication failed** | GitHub secrets not configured | Verify all 3 secrets in GitHub Settings |
| **Permission denied to Artifact Registry** | WIF binding missing | Run Phase 2 Part 2 commands |
| **Terraform state locked** | Previous apply didn't complete | Wait 5 min or force-unlock in GCP Console |
| **Image scan failed** | Critical vulnerabilities found | Review Trivy output, update dependencies |
| **Terraform plan shows changes** | Local vs remote state mismatch | Run `terraform plan` locally to sync |

---

### Key Pipeline Features:

- 🔐 **Secure Authentication:** Uses Workload Identity Federation (OIDC) - No JSON keys stored
- 🛡️ **Security Scanning:** Trivy checks for vulnerabilities before deployment
- 🏷️ **Version Tagging:** Images tagged with Git version (v1.0.0) + latest
- 📊 **Terraform Plan:** Shows infrastructure changes before applying
- 🔄 **Idempotent:** Safe to run multiple times - only applies necessary changes
- ⚡ **Fast:** Parallel execution where possible
- 📝 **Audit Trail:** All deployments tracked in GitHub Actions history

---

### Versioning Strategy:

Follow [Semantic Versioning](https://semver.org/):

| Version Change | When to Use | Example |
|----------------|-------------|---------|
| **v1.0.0 → v1.0.1** | Bug fixes, patches | Fixed error handling |
| **v1.0.1 → v1.1.0** | New features (backwards compatible) | Added monitoring |
| **v1.1.0 → v2.0.0** | Breaking changes | Changed API structure |

---

### Rolling Back a Deployment:

If you need to rollback to a previous version:

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# 1. List available tags
git tag -l

# 2. Deploy previous version by pushing old tag
git push origin v1.0.0 --force

# Or create a new tag pointing to old commit
git tag v1.0.2 v1.0.0
git push origin v1.0.2
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# 1. List available tags
git tag -l

# 2. Deploy previous version by pushing old tag
git push origin v1.0.0 --force

# Or create a new tag pointing to old commit
git tag v1.0.2 v1.0.0
git push origin v1.0.2
```
</details>

---

## 🔒 Security Features

This project implements multiple security best practices:

### Docker Security:

```dockerfile
# ✅ Multi-stage build (smaller attack surface)
FROM python:3.11-slim-bookworm AS builder
# ... build stage ...

FROM python:3.11-slim-bookworm
# ✅ Non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser

# ✅ Minimal dependencies (only production packages)
# ✅ Security patches applied
RUN apt-get update && apt-get upgrade -y
```

### GCP Security:

- ✅ **IAM Principle of Least Privilege:** Service account has only required permissions
- ✅ **No Public Access:** GCS bucket blocks public access
- ✅ **Workload Identity:** No long-lived JSON keys
- ✅ **Uniform Bucket Access:** Simplified security model
- ✅ **Encrypted at Rest:** GCP default encryption

### Permissions Breakdown:

| Permission | Resource | Why Needed |
|------------|----------|------------|
| `pubsub.subscriber` | Subscription | Read messages from queue |
| `storage.objectCreator` | Bucket | Write JSON files |
| `artifactregistry.writer` | Registry | Push Docker images |

---

## 🧹 Cleanup

To remove all resources and avoid charges:

### 1. Destroy Infrastructure

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# Navigate to Terraform directory
cd terraform

# Destroy all resources (type 'yes' when prompted)
terraform destroy -var="project_id=$(gcloud config get-value project)"

# Alternative: Auto-approve (skips confirmation)
terraform destroy -var="project_id=$(gcloud config get-value project)" -auto-approve

# Verify resources are deleted
gcloud pubsub topics list
gcloud storage buckets list | grep log-archive
gcloud iam service-accounts list | grep log-archiver
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# Navigate to Terraform directory
cd terraform

# Destroy all resources (type 'yes' when prompted)
$PROJECT_ID = gcloud config get-value project
terraform destroy -var="project_id=$PROJECT_ID"

# Alternative: Auto-approve (skips confirmation)
terraform destroy -var="project_id=$PROJECT_ID" -auto-approve

# Verify resources are deleted
gcloud pubsub topics list
gcloud storage buckets list | Select-String log-archive
gcloud iam service-accounts list | Select-String log-archiver
```
</details>

**This removes:**
- ❌ Pub/Sub topic and subscription
- ❌ GCS bucket and all contents
- ❌ Service account
- ❌ Artifact Registry repository
- ❌ All IAM bindings

---

### 2. Remove Workload Identity Federation (Optional)

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# Delete the OIDC provider
gcloud iam workload-identity-pools providers delete github-provider \
  --workload-identity-pool="github-pool" \
  --location="global" \
  --quiet

# Delete the identity pool
gcloud iam workload-identity-pools delete github-pool \
  --location="global" \
  --quiet

# Verify deletion
gcloud iam workload-identity-pools list --location="global"
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# Delete the OIDC provider
gcloud iam workload-identity-pools providers delete github-provider `
  --workload-identity-pool="github-pool" `
  --location="global" `
  --quiet

# Delete the identity pool
gcloud iam workload-identity-pools delete github-pool `
  --location="global" `
  --quiet

# Verify deletion
gcloud iam workload-identity-pools list --location="global"
```
</details>

---

### 3. Remove State Bucket (Optional)

**⚠️ Warning:** Only delete this if you're completely done with the project. You cannot recover the state file after deletion.

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# Delete the state bucket and all contents
PROJECT_ID=$(gcloud config get-value project)
gcloud storage rm -r gs://${PROJECT_ID}-tfstate

# Verify deletion
gcloud storage buckets list | grep tfstate
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# Delete the state bucket and all contents
$PROJECT_ID = gcloud config get-value project
gcloud storage rm -r gs://${PROJECT_ID}-tfstate

# Verify deletion
gcloud storage buckets list | Select-String tfstate
```
</details>

---

### 4. Disable APIs (Optional)

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# Disable services to stop any potential charges
gcloud services disable pubsub.googleapis.com --force
gcloud services disable artifactregistry.googleapis.com --force
gcloud services disable iam.googleapis.com --force

# Note: storage.googleapis.com cannot be disabled as it's required for GCP
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# Disable services to stop any potential charges
gcloud services disable pubsub.googleapis.com --force
gcloud services disable artifactregistry.googleapis.com --force
gcloud services disable iam.googleapis.com --force

# Note: storage.googleapis.com cannot be disabled as it's required for GCP
```
</details>

---

### 5. Clean Local Files (Optional)

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# Remove Terraform state files and cache
cd terraform
rm -rf .terraform/
rm -f .terraform.lock.hcl
rm -f terraform.tfstate*

# Remove Docker images
docker rmi log-archiver:mock
docker system prune -a --volumes
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# Remove Terraform state files and cache
cd terraform
Remove-Item -Recurse -Force .terraform
Remove-Item -Force .terraform.lock.hcl
Remove-Item -Force terraform.tfstate*

# Remove Docker images
docker rmi log-archiver:mock
docker system prune -a --volumes
```
</details>

---

### Complete Cleanup Verification

<details>
<summary><b>🐧 Linux / macOS (Bash)</b></summary>

```bash
# Verify nothing remains
echo "=== Checking Pub/Sub ==="
gcloud pubsub topics list

echo "=== Checking Storage ==="
gcloud storage buckets list | grep -E "(log-archive|tfstate)"

echo "=== Checking Service Accounts ==="
gcloud iam service-accounts list | grep log-archiver

echo "=== Checking Artifact Registry ==="
gcloud artifacts repositories list

echo "=== Checking WIF ==="
gcloud iam workload-identity-pools list --location="global"

echo "=== Cleanup Complete! ==="
```
</details>

<details>
<summary><b>🪟 Windows (PowerShell)</b></summary>

```powershell
# Verify nothing remains
Write-Host "=== Checking Pub/Sub ==="
gcloud pubsub topics list

Write-Host "=== Checking Storage ==="
gcloud storage buckets list | Select-String -Pattern "(log-archive|tfstate)"

Write-Host "=== Checking Service Accounts ==="
gcloud iam service-accounts list | Select-String log-archiver

Write-Host "=== Checking Artifact Registry ==="
gcloud artifacts repositories list

Write-Host "=== Checking WIF ==="
gcloud iam workload-identity-pools list --location="global"

Write-Host "=== Cleanup Complete! ==="
```
</details>

---

## 💡 Architectural Insights

### Question 1: Secret Management in GKE

**How would you inject sensitive database credentials into the container at runtime?**

I would use **Google Secret Manager** integrated with the **CSI Secret Store Driver** for Kubernetes. This approach:

- ✅ Mounts secrets as volumes or environment variables
- ✅ Keeps sensitive data out of container images
- ✅ Prevents secrets from being committed to Git
- ✅ Supports automatic rotation
- ✅ Provides audit logging

**Example implementation:**
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

---

### Question 2: Private VPC Connectivity

**If this service needed to access a private MongoDB instance in another VPC, how would you architect the connectivity?**

I would implement **VPC Network Peering** to establish a private connection between the two VPCs:

1. **VPC Peering:** Connect both VPCs at the network layer
2. **Firewall Rules:** Allow traffic only on MongoDB port (27017) from specific source ranges
3. **Private DNS:** Use Cloud DNS private zones for service discovery
4. **No Public IPs:** All communication stays on Google's private network

**Benefits:**
- ✅ Low latency (no internet routing)
- ✅ No bandwidth costs between VPCs
- ✅ Enhanced security (private network only)
- ✅ Supports transitive peering

**Alternative:** For more complex scenarios, consider **Shared VPC** or **VPN/Interconnect**.

---

### Question 3: Observability & Alerting

**The service is failing silently in production. What tools would you set up for immediate alerts?**

I would implement a multi-layered observability strategy:

#### 1. **Log-Based Alerts (Cloud Logging)**
```bash
# Alert on ERROR level logs
resource.type="cloud_run_revision"
severity="ERROR"
textPayload=~"upload_to_gcs failed"
```

#### 2. **Metric-Based Alerts (Cloud Monitoring)**
- Monitor `pubsub/subscription/num_unacked_messages_by_region`
- Alert when unacknowledged messages exceed threshold
- Indicates processing failures or backlogs

#### 3. **Uptime Checks**
- Health endpoint monitoring
- Container restart detection
- Service availability tracking

#### 4. **Error Reporting**
- Automatic error grouping
- Stack trace collection
- Integration with Cloud Logging


