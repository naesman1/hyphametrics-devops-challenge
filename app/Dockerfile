# app/Dockerfile 
FROM python:3.11-slim

WORKDIR /app


RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# no-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# copy dependencies 
COPY --from=builder /root/.local /home/appuser/.local
COPY main.py .

RUN chown -R appuser:appuser /app
USER appuser

ENV PATH=/home/appuser/.local/bin:$PATH
CMD ["python", "main.py"]