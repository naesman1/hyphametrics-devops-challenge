# STAGE 1: Build environment
FROM python:3.11-slim-bookworm AS builder

# Prevent .pyc files and enable unbuffered logging
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy and install requirements with security pinning
COPY requirements.txt .
RUN pip install --no-cache-dir --user --upgrade pip setuptools wheel && \
    pip install --no-cache-dir --user -r requirements.txt && \
    pip install --no-cache-dir --user --upgrade jaraco.context>=6.1.0 wheel>=0.46.3 protobuf>=5.0.0

# STAGE 2: Runtime environment
FROM python:3.11-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /app

# Security: Patch OS packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Security: Non-root user configuration
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy binaries and source code
COPY --from=builder /root/.local /home/appuser/.local
COPY main.py .

# Ownership adjustment for non-root execution
RUN chown -R appuser:appuser /app
USER appuser

# Environment path configuration
ENV PATH=/home/appuser/.local/bin:$PATH

CMD ["python", "main.py"]