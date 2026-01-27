# STAGE 1: Build environment
# Using bookworm for a more stable security patch cycle than the testing branch
FROM python:3.11-slim-bookworm AS builder

# Set the working directory
WORKDIR /app

# Install system dependencies required for building Python packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file and install dependencies
# Using --user to keep the dependencies isolated in a specific directory
COPY requirements.txt .
RUN pip install --no-cache-dir --user --upgrade pip setuptools wheel && \
    pip install --no-cache-dir --user -r requirements.txt

# STAGE 2: Final Runtime Image
FROM python:3.11-slim-bookworm

# Set the working directory
WORKDIR /app

# SECURITY: Patch OS vulnerabilities to mitigate Trivy findings (e.g., glibc, sqlite)
RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# SECURITY: Create a non-root system user for security best practices
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy the pre-installed packages and the application code from the builder stage
COPY --from=builder /root/.local /home/appuser/.local
COPY main.py .

# SECURITY: Ensure the non-root user owns the application directory
RUN chown -R appuser:appuser /app

# Switch to the non-root user
USER appuser

# SECURITY: Force-patch specific sub-dependencies often flagged in security scans
# This ensures libraries like wheel and jaraco.context are at safe versions
RUN pip install --no-cache-dir --user --upgrade jaraco.context>=6.1.0 wheel>=0.46.2 protobuf>=5.0.0

# Configure PATH to include the local user-installed binaries
ENV PATH=/home/appuser/.local/bin:$PATH

# Define the entry point for the application
CMD ["python", "main.py"]