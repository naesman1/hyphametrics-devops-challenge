# STAGE 1: Build environment
# We use 'AS builder' to name this stage for later reference
FROM python:3.11-slim AS builder

WORKDIR /app

# Install build dependencies and update system packages
RUN apt-get update && apt-get install -y --no-install-recommends build-essential

# Copy requirements and install python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --user --upgrade pip setuptools wheel && \
    pip install --no-cache-dir --user -r requirements.txt

# STAGE 2: Runtime environment
FROM python:3.11-slim

WORKDIR /app

# Security: Patch OS vulnerabilities (Critical for Trivy scan)
RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Security: Create a non-root user to run the application
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy only the necessary artifacts from the builder stage
COPY --from=builder /root/.local /home/appuser/.local
COPY main.py .

# Set ownership and switch to non-root user
RUN chown -R appuser:appuser /app
USER appuser

# Configure PATH to include the local user-installed binaries
ENV PATH=/home/appuser/.local/bin:$PATH

# Execute the application
CMD ["python", "main.py"]