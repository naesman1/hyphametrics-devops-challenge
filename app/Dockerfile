# STAGE 1: Build environment
# Using 'bookworm' (Debian 12) for a more stable security patch cycle
FROM python:3.11-slim-bookworm AS builder

WORKDIR /app

# Install build essentials
RUN apt-get update && apt-get install -y --no-install-recommends build-essential

COPY requirements.txt .
# Ensure pip is up to date and install dependencies
RUN pip install --no-cache-dir --user --upgrade pip setuptools wheel && \
    pip install --no-cache-dir --user -r requirements.txt

# STAGE 2: Runtime environment
FROM python:3.11-slim-bookworm

WORKDIR /app

# Security: Patch OS vulnerabilities and cleanup
RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Security: Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy artifacts
COPY --from=builder /root/.local /home/appuser/.local
COPY main.py .

RUN chown -R appuser:appuser /app
USER appuser

ENV PATH=/home/appuser/.local/bin:$PATH
CMD ["python", "main.py"]