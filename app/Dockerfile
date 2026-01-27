# STAGE 1: Build environment
FROM python:3.11-slim-bookworm AS builder

# Prevent Python from writing .pyc files (Avoids false positive secret detection)
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy and install requirements with explicit security upgrades
COPY requirements.txt .
RUN pip install --no-cache-dir --user --upgrade pip setuptools wheel && \
    pip install --no-cache-dir --user -r requirements.txt && \
    pip install --no-cache-dir --user --upgrade jaraco.context>=6.1.0 wheel>=0.46.2 protobuf>=5.0.0

# STAGE 2: Runtime environment
FROM python:3.11-slim-bookworm

# Prevent .pyc files in runtime as well
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
WORKDIR /app

# Security: Patch OS vulnerabilities
RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Security: Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy artifacts from builder stage
COPY --from=builder /root/.local /home/appuser/.local
COPY main.py .

# Set permissions and switch to non-root user
RUN chown -R appuser:appuser /app
USER appuser

# Ensure local binaries are in the PATH
ENV PATH=/home/appuser/.local/bin:$PATH

CMD ["python", "main.py"]