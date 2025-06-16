import random, string 
from django.core.mail import send_mail
from django.http import JsonResponse
from .firebase import*
from .firebase import auth as firebase_auth
from .redis_client import redis
from django.views.decorators.csrf import csrf_exempt
import os
import base64
import json
from django.conf import settings
from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, firestore
from password_reset.utils.encryption import generate_ecc_keys, hybrid_encrypt, hybrid_decrypt, aes_decrypt

from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend

b64 = "ewogICJ0eXBlIjogInNlcnZpY2VfYWNjb3VudCIsCiAgInByb2plY3RfaWQiOiAiY3Jpc2lzLXN1cnZpdm9yIiwKICAicHJpdmF0ZV9rZXlfaWQiOiAiODdhYTNlZTBjNTExNDU0NjBmN2RhYTE4ZjY0OWYyNjYyODc4M2U5MCIsCiAgInByaXZhdGVfa2V5IjogIi0tLS0tQkVHSU4gUFJJVkFURSBLRVktLS0tLVxuTUlJRXZnSUJBREFOQmdrcWhraUc5dzBCQVFFRkFBU0NCS2d3Z2dTa0FnRUFBb0lCQVFEem1MK0xYNHhHQ1cxNlxub2IyRUwrNzJCKzFoSVFUQ3BjZG52eWpuY3V1MHd3WFFOSmpwaU9WZ2lHYUYxbllNa0g4MEdyQnRDWTU0QUZWWFxuc1MySndLR0dVR3pYcDIxV1ozMjFsNjhNMjcvcUNNVXdwN1JGbnNSSEFpQi9COEZxZ3FPR3RPSXlGMnhVeFlTQVxubTQ0UzZYTFZ0cmliWGV1RGt0ZnE5UVFsSWhxU0xIMEkrVWxKQlcyOU1DU1l0bWpIZ3VXQWsvVmg4ZTFyTXl0SlxuTVVqdFpEb2FHZmdaMWdwajhTcUNtNmt6UFJjQUFEdmpMUWNyNC9ZeEpzYnl0Y1JneGp1SWx0Nk1CZ2hxNnVHd1xuVmxJcnJ3a2FPSFJ5M3paZzk3cmRJNWRVMGVsdm92cllFd0Q3SkRZdkxKT21pNWZiMm5DOGRaTkZVNHFNanU2MVxucVJWRSt6eTNBZ01CQUFFQ2dnRUFEU0kvdFphRnZDTDIvYVVwMEM0N2JwVjMxWVJQdXVUd1R1WXVJT2gveitPeFxuOVF0WThVSjV4NDRqSlBVdXNUZTdQQVp5VzdhbnNVMm5URTZYdTNVZzRGcUd1OHZocDhaMXJ5eEorbUlBdzNBTVxubmJaMUVFbmlvRWQ3bEEzSmZtSWp5ZmdIdUJhdU54WGRNb2Z3alpGN3FRMHNmK2Y4OGoraEY2QjFSRUZGK0hxRlxucG9HY25kdllVWFJjdlNyOHRnQXd3SThsb1NxMmg4WDZsSVR3SUFBZFJjOEx1TTcwTGZHb01oWTI2K0NlQTRiRlxuQlBWbW5mdmNQYjNqeXA1SWptbTlEN0dwc3Izem5RUzVtL0hicnN4cnhFK0xIa3FZclE2UDhROHZ0RHZKL1d2RlxucGlPSURVWnpabVpCYlFKYVJXWFNIdnRQWjV1WEZybXlZQkQ5Z0g5dFJRS0JnUUQrUk5QWUt1N1ZvTzVjRkVTclxuSWtHV3dxbnBJdTJ6WjVSSmxDQmMzV0d5WG1UT1BLZTdWR0I1K2pRcXJ3ZjlZNEZKeStCZStUMDNYQ0RSZ0xFSlxubERVMHZOTVNmT0VJSytDSFlwamNwNW9wRUxkMzJVME45TUpEQkM3N0xseDh4YzN6Tk92NDI5NFd3dzl2Skc0YVxuRzJNWmswOW9jLzdhbmtaZ3NCN2MrUjNCc3dLQmdRRDFRVkhoYzlXOU9CQ0E3MlpFTDFuUU9pTFZvZjVxbDZ1YlxuYm5aOFdabmt1a1dXMXFYUXBOdnJEZVlaVll3VlhOUWJURmFUdlQrcmV4RmQvVUxGRytDVDdxdFJKOWJFSFl0V1xuOVcwMlN1QU9CcFZab3d2V3pCMVh0UlZ5V2t2M215MnFwNnJnTjIrRHo5UkZhdGE1WEF0cyszbUhUaWxaSmxhc1xuMUczUWxmeHU3UUtCZ1FEaEFmRmg2dVE5WWROczRuYTk1bXVhU1J0bzl3TFlid0czZHdDSWpWUG1MMGdQaFhkOFxuKzdjQVdoeU41U1F4NUR0R0hjZW80L0I3SytqUzNJcE9DcnhtdGU0bS95RjRSTFBGdXNmQkJBUVU4UGthY3M2UVxuV2hjS2pRb3lOeDJiUU1QMnc4OUtBdTl1dnlES1hyZWNITDQrcExCeG82eFV0QmxkZUoxbk9JQlBwd0tCZ0h5UVxuYm92NWowZUpvQ2c4YjA2V1ZpR0NSWXNIdWZaZGpsVmxaMXlGRGJxME9RQUJpVHBOWVQwalZBanVBRFloYmNGblxucGxsbk4xMWJKbGo4ZHRzeDY0QjNLaUFRQWU2ZHF0WEIxWFJMMXp5SWIzYVZiei9yYjhQS1AxaFRNRjVVUEg5K1xucFRVNE1yVlo2MUJPa1R5WDJWM0M0OWlyQkNrNVpiQm1QRmhDdFhHSkFvR0JBT1Z2MGdWdzVxcVBiSU9UVzZNMVxuTHVvRG9uUExGa0FlV0RYZEdvZ04vSnBMUENZVjdlSDhPTm5HRUt0bEE2SGl5TytkMnJEc2g5K3lDOHRreS92VFxuUXQySmJvQ0laWFpvcklaVG56NUJta3NEam1nZERTVjZUcjRNbGlNOEs1OS9RT212TXh2T2hseVh4UDByQUp3eVxuY1JBNE92d2xmVW9jNktGRUtuOGtDbDY2XG4tLS0tLUVORCBQUklWQVRFIEtFWS0tLS0tXG4iLAogICJjbGllbnRfZW1haWwiOiAiZmlyZWJhc2UtYWRtaW5zZGstZmJzdmNAY3Jpc2lzLXN1cnZpdm9yLmlhbS5nc2VydmljZWFjY291bnQuY29tIiwKICAiY2xpZW50X2lkIjogIjExMTA0OTA0NDM5MDg0OTA5NDAzNSIsCiAgImF1dGhfdXJpIjogImh0dHBzOi8vYWNjb3VudHMuZ29vZ2xlLmNvbS9vL29hdXRoMi9hdXRoIiwKICAidG9rZW5fdXJpIjogImh0dHBzOi8vb2F1dGgyLmdvb2dsZWFwaXMuY29tL3Rva2VuIiwKICAiYXV0aF9wcm92aWRlcl94NTA5X2NlcnRfdXJsIjogImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL29hdXRoMi92MS9jZXJ0cyIsCiAgImNsaWVudF94NTA5X2NlcnRfdXJsIjogImh0dHBzOi8vd3d3Lmdvb2dsZWFwaXMuY29tL3JvYm90L3YxL21ldGFkYXRhL3g1MDkvZmlyZWJhc2UtYWRtaW5zZGstZmJzdmMlNDBjcmlzaXMtc3Vydml2b3IuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20iLAogICJ1bml2ZXJzZV9kb21haW4iOiAiZ29vZ2xlYXBpcy5jb20iCn0="#os.getenv("FIREBASE_CREDENTIAL")

if not b64:
    raise Exception("FIREBASE_CREDENTIAL_BASE64 is not set.")

cred_dict = json.loads(base64.b64decode(b64))

# initialize_app(cred)

if not firebase_admin._apps:
        # cred = credentials.Certificate({
        #     "type": "service_account",
        #     "project_id": os.getenv("FIREBASE_PROJECT_ID"),
        #     "private_key_id": os.getenv("FIREBASE_PRIVATE_KEY_ID"),
        #     "private_key": os.getenv("FIREBASE_PRIVATE_KEY"),#.replace('\\n', '\n'),
        #     "client_email": os.getenv("FIREBASE_CLIENT_EMAIL"),
        #     "client_id": os.getenv("FIREBASE_CLIENT_ID"),
        #     "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        #     "token_uri": "https://oauth2.googleapis.com/token",
        #     "auth_provider_x509_cert_url": "https://www.googleapis.com/v1/certs",
        #     "client_x509_cert_url": os.getenv("FIREBASE_CLIENT_CERT_URL")
        # })
        cred = credentials.Certificate(cred_dict)
        firebase_admin.initialize_app(cred)

db = firestore.client()

# Init Firebase DB

def check_health(request):
    return JsonResponse({"status": "OK"}) 

@csrf_exempt
def check_email_exists(request, provider=None):
    if request.method != 'POST':
        return JsonResponse({'error': 'Invalid method'}, status=405)

    try:
        data = json.loads(request.body)
        email = data.get('email')
        provider = data.get('provider')

        if not email:
            return JsonResponse({'error': 'Email required'}, status=400)

        try:
            user = firebase_auth.get_user_by_email(email)
            exists = True
        except firebase_auth.UserNotFoundError:
            return JsonResponse({'exists': False})

        if provider:
            sign_in_methods = user.provider_data
            method_ids = [p.provider_id for p in sign_in_methods]
            if provider not in method_ids:
                return JsonResponse({'exists': False})
            return JsonResponse({'exists': True, 'provider': provider})
        else:
            all_providers = [p.provider_id for p in user.provider_data]
            return JsonResponse({'exists': True, 'provider': all_providers[0] if all_providers else None})

    except Exception as e:
        return JsonResponse({'error': 'Server error', 'details': str(e)}, status=500)

def generate_code(length=8):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length))

def get_decryption_keys():
    config_doc = db.collection("config").document("encryption_metadata").get()
    config_data = config_doc.to_dict()

    encrypted_ecc_key = config_data["encrypted_ecc_key"]
    encrypted_aes_key = config_data["encrypted_aes_key"]

    master_ecc_key_pem = os.getenv("MASTER_ECC_PRIVATE_KEY")
    master_private_key = serialization.load_pem_private_key(
        master_ecc_key_pem.encode(), password=None, backend=default_backend()
    )
    master_pem_str = master_private_key.private_bytes(
        serialization.Encoding.PEM, serialization.PrivateFormat.PKCS8,
        serialization.NoEncryption()
    ).decode()

    ecc_pem = hybrid_decrypt(master_pem_str, encrypted_ecc_key)["ecc_key"]
    ecc_private_key = serialization.load_pem_private_key(
        ecc_pem.encode(), password=None, backend=default_backend()
    )
    ecc_pem_str = ecc_private_key.private_bytes(
        serialization.Encoding.PEM, serialization.PrivateFormat.PKCS8,
        serialization.NoEncryption()
    ).decode()

    aes_hex = hybrid_decrypt(ecc_pem_str, encrypted_aes_key)["aes_key"]
    return bytes.fromhex(aes_hex)

@csrf_exempt
def send_reset_code(request):
    if request.method != 'POST':
        return JsonResponse({'error': 'Invalid method'}, status=405)

    try:
        data = json.loads(request.body)
        email = data.get('email')
        if not email:
            return JsonResponse({'error': 'Email required'}, status=400)

        # Decrypt and verify user exists in Firestore
        aes_key = get_decryption_keys()
        encrypted_email = None
        users_ref = db.collection("users")
        users = users_ref.stream()
        match_found = False
        for doc in users:
            enc_data = doc.to_dict()
            try:
                dec_email = aes_decrypt(aes_key, enc_data.get("email", ""))
                if dec_email == email:
                    match_found = True
                    break
            except:
                continue

        if not match_found:
            return JsonResponse({'error': 'User not found in Firestore'}, status=404)

        user = firebase_auth.get_user_by_email(email)

        reset_code = str(random.randint(100000, 999999))
        redis.setex(f"reset:{email}", 300, reset_code)

        send_mail(
            subject="Your Password Reset Code",
            message=f"Your code is: {reset_code}",
            from_email="crisissurvivor3@gmail.com",
            recipient_list=[email],
            fail_silently=False,
        )

        return JsonResponse({'success': True})

    except Exception as e:
        return JsonResponse({'error': 'Server error', 'details': str(e)}, status=500)

@csrf_exempt
def verify_code(request):
    if request.method != 'POST':
        return JsonResponse({'error': 'Invalid method'}, status=405)

    data = json.loads(request.body)
    email = data.get('email')
    code = data.get('code')

    stored_code = redis.get(f'reset:{email}')
    if stored_code is None:
        return JsonResponse({'error': 'Code expired or not found'}, status=400)

    if stored_code.decode('utf-8') != code:
        redis.delete(f'reset:{email}')
        return JsonResponse({'error': 'Invalid code'}, status=401)

    user = firebase_auth.get_user_by_email(email)
    custom_token = firebase_auth.create_custom_token(user.uid)

    redis.delete(f'reset:{email}')

    return JsonResponse({
        'success': True,
        'message': 'Verification successful.',
        'token': custom_token.decode('utf-8')
    })

@csrf_exempt
def delete_user(request):
    if request.method != 'POST':
        return JsonResponse({'error': 'Invalid method'}, status=405)

    try:
        data = json.loads(request.body)
        requester_email = data.get('requester_email')  # the one initiating delete
        target_uid = data.get('uid')
        target_email = data.get('email')

        if not requester_email:
            return JsonResponse({'error': 'Requester email required'}, status=400)
        if not target_uid and not target_email:
            return JsonResponse({'error': 'Provide either uid or email of user to delete'}, status=400)

        # Import Firestore client
        from .firebase import db

        # 🔍 Search Firestore for requester doc by email
        users_ref = db.collection('users')
        query = users_ref.where('email', '==', requester_email).limit(1).stream()
        requester_doc = next(query, None)

        if not requester_doc:
            return JsonResponse({'error': 'Requester not found in Firestore'}, status=404)

        role = requester_doc.to_dict().get('role', '').lower()

        # Get UID by email if not already provided
        if target_email and not target_uid:
            try:
                target_user = firebase_auth.get_user_by_email(target_email)
                target_uid = target_user.uid
            except firebase_auth.UserNotFoundError:
                return JsonResponse({'error': 'Target user not found by email'}, status=404)

        if role != 'admin':
            if requester_email != target_email:
                return JsonResponse({'error': 'Permission denied: only admins can delete others'}, status=403)

        # ✅ Deletion logic — move this **outside** the `if role != 'admin'` block
        firebase_auth.delete_user(target_uid)

        # 🔍 Delete target Firestore doc by email
        target_query = users_ref.where('email', '==', target_email).stream()
        for doc in target_query:
            doc.reference.delete()

        return JsonResponse({'success': True, 'message': f'User {target_uid} deleted'})

    except Exception as e:
        return JsonResponse({'error': 'Server error', 'details': str(e)}, status=500)



@csrf_exempt
def secure_save_user(request):
    if request.method != 'POST':
        return JsonResponse({'error': 'Invalid method'}, status=405)

    try:
        data = json.loads(request.body)

        payload = {
            "username": data.get("username"),
            "email": data.get("email"),
            "role": data.get("role", ""),  # optional
            "time": data.get("time")
        }

        public_key = os.environ['ENCRYPTION_PUBLIC_KEY']

        encrypted_fields = {}
        for key, value in payload.items():
            encrypted_fields[key] = hybrid_encrypt(public_key, {key: value})

        db.collection("users").add(encrypted_fields)

        return JsonResponse({'success': True})
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)


@csrf_exempt
def rotate_keys_view(request):
    if request.method != 'POST':
        return JsonResponse({"error": "Only POST allowed"}, status=405)

    load_dotenv()

    
    old_private_key = os.getenv("ENCRYPTION_PRIVATE_KEY")
    new_private_key, new_public_key = generate_ecc_keys()

    docs = db.collection("users").stream()
    success_count = 0
    failed_docs = []

    for doc in docs:
        try:
            doc_data = doc.to_dict()
            decrypted_fields = {}

            for key, encrypted_field in doc_data.items():
                decrypted = hybrid_decrypt(old_private_key, encrypted_field)
                decrypted_fields[key] = list(decrypted.values())[0]  # Get just the value

            new_encrypted_fields = {}
            for key, value in decrypted_fields.items():
                new_encrypted_fields[key] = hybrid_encrypt(new_public_key, {key: value})

            doc.reference.set(new_encrypted_fields)
            success_count += 1

        except Exception as e:
            failed_docs.append({"id": doc.id, "error": str(e)})

    print("→ ENCRYPTION_PRIVATE_KEY=\n" + new_private_key)
    print("→ ENCRYPTION_PUBLIC_KEY=\n" + new_public_key)

    return JsonResponse({
        "message": "Key rotation complete",
        "successfully_rotated": success_count,
        "failed_docs": failed_docs[:3],
        "new_keys": {
            "private": new_private_key,
            "public": new_public_key
        }
    })

# from django.http import JsonResponse
# from django.views.decorators.csrf import csrf_exempt
# from firebase_admin import firestore
# import json
# import os

from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend

from password_reset.utils.encryption import *
@csrf_exempt
def send_data(request):
    if request.method != "POST":
        return JsonResponse({"error": "Only POST allowed"}, status=405)

    try:
        body = json.loads(request.body)

        uid = body.get("uid")  # Don't encrypt UID
        if not uid:
            return JsonResponse({"error": "Missing uid"}, status=400)

        # Load encrypted ECC key from Firestore
        config_ref = db.collection("config").document("encryption_metadata")
        config_doc = config_ref.get()
        config_data = config_doc.to_dict()

        encrypted_ecc_key = config_data["encrypted_ecc_key"]
        encrypted_aes_key = config_data["encrypted_aes_key"]

        # Decrypt ECC private key using master ECC private key
        master_ecc_key_pem = os.getenv("MASTER_ECC_PRIVATE_KEY")
        master_private_key = serialization.load_pem_private_key(
            master_ecc_key_pem.encode(),
            password=None,
            backend=default_backend()
        )
        master_private_key_pem_str = master_private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        ).decode()

        ecc_private_pem = hybrid_decrypt(master_private_key_pem_str, encrypted_ecc_key)["ecc_key"]

        ecc_private_key = serialization.load_pem_private_key(
            ecc_private_pem.encode(),
            password=None,
            backend=default_backend()
        )
        ecc_private_pem_str = ecc_private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        ).decode()

        aes_hex = hybrid_decrypt(ecc_private_pem_str, encrypted_aes_key)["aes_key"]
        aes_key = bytes.fromhex(aes_hex)

        encrypted_data = {}
        for k, v in body.items():
            if k == "uid":  # Don't encrypt UID
                continue
            encrypted_data[k] = aes_encrypt(aes_key, v)

        db.collection("users").document(uid).set(encrypted_data)

        return JsonResponse({"success": True})

    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)


def receive_data(request):
    try:
        email = request.GET.get("email")
        if not email:
            return JsonResponse({"error": "Email query param required"}, status=400)

        # Search user by email field
        users_ref = db.collection("users")
        query = users_ref.where("email", "==", aes_encrypt(b"temp_key", email)).stream()
        doc = None
        for d in query:
            doc = d
            break

        if not doc:
            return JsonResponse({"error": "User not found"}, status=404)

        doc_data = doc.to_dict()

        # Load encrypted ECC key from Firestore
        config_ref = db.collection("config").document("encryption_metadata")
        config_doc = config_ref.get()
        config_data = config_doc.to_dict()

        encrypted_ecc_key = config_data["encrypted_ecc_key"]
        encrypted_aes_key = config_data["encrypted_aes_key"]

        # Decrypt ECC private key using master ECC private key
        master_ecc_key_pem = os.getenv("MASTER_ECC_PRIVATE_KEY")
        master_private_key = serialization.load_pem_private_key(
            master_ecc_key_pem.encode(),
            password=None,
            backend=default_backend()
        )
        master_private_key_pem_str = master_private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        ).decode()

        ecc_private_pem = hybrid_decrypt(master_private_key_pem_str, encrypted_ecc_key)["ecc_key"]

        ecc_private_key = serialization.load_pem_private_key(
            ecc_private_pem.encode(),
            password=None,
            backend=default_backend()
        )
        ecc_private_pem_str = ecc_private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        ).decode()

        aes_hex = hybrid_decrypt(ecc_private_pem_str, encrypted_aes_key)["aes_key"]
        aes_key = bytes.fromhex(aes_hex)

        decrypted_data = {}
        for k, v in doc_data.items():
            if v is None:
                decrypted_data[k] = None
            else:
                decrypted_data[k] = aes_decrypt(aes_key, v)

        return JsonResponse({"data": decrypted_data})

    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)
