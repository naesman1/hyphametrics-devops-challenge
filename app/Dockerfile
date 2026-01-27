# STAGE 1: Build environment
# Using a stable base image for production consistency
FROM python:3.11-slim-bookworm AS builder

# Prevent Python from writing .pyc files and enable unbuffered logging
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies required for building certain Python wheels
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create a virtual environment to isolate clean dependencies
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade core tools before installing application requirements
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Force upgrade specific problematic libraries to their secure versions
# This overrides any transitive dependencies pulled by other packages
RUN pip install --no-cache-dir --upgrade \
    jaraco.context>=6.1.0 \
    wheel>=0.46.3 \
    protobuf>=5.0.0

# STAGE 2: Runtime environment
FROM python:3.11-slim-bookworm

# Maintain environment configurations
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /app

# Security: Apply latest OS security patches
RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Security: Create a non-root system user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy the clean virtual environment from the builder stage
COPY --from=builder /opt/venv /opt/venv
COPY main.py .

# Ensure the application runs with restricted permissions
RUN chown -R appuser:appuser /app
USER appuser

# Execute the application
CMD ["python", "main.py"]