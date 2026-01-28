import os
import json
import time
import logging
from google.cloud import pubsub_v1, storage
from google.api_core import exceptions
from http.server import BaseHTTPRequestHandler, HTTPServer
import threading

# --- DUMMY HEALTH CHECK FOR CLOUD RUN ---
class HealthCheckHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"OK")

def run_health_check():
    port = int(os.environ.get("PORT", 8080))
    server = HTTPServer(('0.0.0.0', port), HealthCheckHandler)
    server.serve_forever()

# Start health check server in a separate thread
threading.Thread(target=run_health_check, daemon=True).start()
# -----------------------------------------

# Configure logging for better observability
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configuration via Environment Variables
PROJECT_ID = os.getenv("PROJECT_ID")
SUBSCRIPTION_NAME = os.getenv("SUBSCRIPTION_NAME")
BUCKET_NAME = os.getenv("BUCKET_NAME")

def upload_to_gcs(payload):
    """Uploads a dummy JSON object to the GCS bucket"""
    try:
        client = storage.Client()
        bucket = client.get_bucket(BUCKET_NAME)
        blob = bucket.blob(f"archive/log_{int(time.time())}.json")
        
        blob.upload_from_string(
            data=json.dumps(payload),
            content_type='application/json'
        )
        logger.info(f"Successfully archived message to {BUCKET_NAME}")
    except exceptions.NotFound:
        # Basic error handling: check if bucket exists
        logger.error(f"Error: The bucket '{BUCKET_NAME}' was not found.")
    except Exception as e:
        logger.error(f"An unexpected error occurred: {e}")

def message_callback(message):
    """Callback function to handle incoming Pub/Sub messages """
    logger.info(f"Received message: {message.data}")
    
    # JSON payload for archiving
    dummy_payload = {
        "content": message.data.decode("utf-8"),
        "metadata": {
            "source": "pubsub-subscriber",
            "archived_at": time.time()
        }
    }
    
    upload_to_gcs(dummy_payload)
    message.ack()

def main():
    if not all([PROJECT_ID, SUBSCRIPTION_NAME, BUCKET_NAME]):
        logger.error("Missing required environment variables.")
        return

    subscriber = pubsub_v1.SubscriberClient()
    subscription_path = subscriber.subscription_path(PROJECT_ID, SUBSCRIPTION_NAME)

    logger.info(f"Listening for messages on {subscription_path}...")
    streaming_pull_future = subscriber.subscribe(subscription_path, callback=message_callback)

    with subscriber:
        try:
            streaming_pull_future.result()
        except KeyboardInterrupt:
            streaming_pull_future.cancel()
            logger.info("Service stopped by user.")
        except Exception as e:
            logger.error(f"Streaming pull failed: {e}")
            streaming_pull_future.cancel()

if __name__ == "__main__":
    main()