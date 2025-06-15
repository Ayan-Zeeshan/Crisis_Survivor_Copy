import os
import firebase_admin
from firebase_admin import auth, credentials
from dotenv import load_dotenv
from firebase_admin import firestore

load_dotenv()  # in case you're loading from .env

if not firebase_admin._apps:
    cred = credentials.Certificate({
        "type": "service_account",
        "project_id": os.getenv("FIREBASE_PROJECT_ID"),
        "private_key_id": os.getenv("FIREBASE_PRIVATE_KEY_ID"),
        "private_key": os.getenv("FIREBASE_PRIVATE_KEY").replace('\\n', '\n'),
        "client_email": os.getenv("FIREBASE_CLIENT_EMAIL"),
        "client_id": os.getenv("FIREBASE_CLIENT_ID"),
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": os.getenv("FIREBASE_CLIENT_CERT_URL")
    })
    firebase_admin.initialize_app(cred)

# cred = credentials.Certificate("crisis-survivor-firebase-adminsdk-fbsvc-87aa3ee0c5.json")
# firebase_admin.initialize_app(cred)
# db = firestore.client()
    
# ✅ Export Firestore client
db = firestore.client()