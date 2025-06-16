# from waitress import serve
# from auth_backend.wsgi import application

# if __name__ == '__main__':
#     serve(application, host='0.0.0.0', port=8000)   
from waitress import serve
from auth_backend.wsgi import application
import logging
import sys

sys.stdout.reconfigure(line_buffering=True)

logging.basicConfig(level=logging.INFO)
logging.info("🔥 Starting Waitress server on port 8000...")
print("🔥 Starting Waitress server on port 8000...", flush=True)

if __name__ == '__main__':
    print("✅ Waitress is starting on http://0.0.0.0:8000",flush=True)  # Shows up in logs
    serve(application, host='0.0.0.0', port=8000)
