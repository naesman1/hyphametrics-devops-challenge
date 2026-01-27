# STAGE 1: Build environment
FROM python:3.11-slim-bookworm AS builder

# Environment variables to optimize the build
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install system-level build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create and isolate a virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade core build tools within the venv
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install application dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# STAGE 2: Secure Runtime
FROM python:3.11-slim-bookworm

WORKDIR /app

# SECURITY: Patch OS-level vulnerabilities
RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# SECURITY: Purge pre-installed vulnerable packages from the base image
# This removes the versions Trivy often finds in /usr/local/lib/python3.11/
RUN pip uninstall -y wheel jaraco.context

# SECURITY: Create a non-root system user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy the clean virtual environment from the builder
COPY --from=builder /opt/venv /opt/venv
COPY main.py .

# Set environment to use the virtual environment
ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONDONTWRITEBYTECODE=1

# Change ownership and switch user
RUN chown -R appuser:appuser /app
USER appuser

CMD ["python", "main.py"]