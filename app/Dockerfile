# Use a slim Python image to reduce size
FROM python:3.11-slim as builder

WORKDIR /app
COPY requirements.txt .

# Install dependencies in a local user directory
RUN pip install --no-cache-dir --user -r requirements.txt

FROM python:3.11-slim
WORKDIR /app

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