FROM python:3.11-slim as builder
WORKDIR /app

# Actualizamos los paquetes del sistema para corregir CVE-2026-0861
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends build-essential

COPY requirements.txt .
RUN pip install --no-cache-dir --user --upgrade pip setuptools wheel && \
    pip install --no-cache-dir --user -r requirements.txt

# Create a non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy only the necessary files from the builder stage
COPY --from=builder /root/.local /home/appuser/.local
COPY main.py .

# Change ownership and switch to non-root user
RUN chown -R appuser:appuser /app
USER appuser

# Set the PATH for the non-root user's local bin
ENV PATH=/home/appuser/.local/bin:$PATH

CMD ["python", "main.py"]