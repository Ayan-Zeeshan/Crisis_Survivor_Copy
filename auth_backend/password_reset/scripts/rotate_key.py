# def run():
#     import os
#     import datetime
#     import traceback
#     from dotenv import load_dotenv
#     from password_reset.firebase import db
#     from password_reset.utils.encryption import generate_ecc_keys, hybrid_encrypt, hybrid_decrypt
#     from cryptography.hazmat.backends import default_backend
#     from cryptography.hazmat.primitives import serialization

#     print("🚀 Starting key rotation script...", flush=True)

#     load_dotenv()

#     now = datetime.datetime.utcnow()
#     config_ref = db.collection("config").document("encryption_metadata")

#     def auto_update_env_on_railway(new_private_key, new_public_key):
#         import requests
#         import os

#         RAILWAY_TOKEN = os.environ.get("RAILWAY_API_TOKEN")
#         ENV_ID = os.environ.get("RAILWAY_ENVIRONMENT_ID")
#         PROJECT_ID = os.environ.get("RAILWAY_PROJECT_ID")

#         if not all([RAILWAY_TOKEN, ENV_ID]):
#             raise Exception("RAILWAY_API_TOKEN or RAILWAY_ENVIRONMENT_ID is missing.")

#         headers = {
#             "Authorization": f"Bearer {RAILWAY_TOKEN}",
#             "Content-Type": "application/json"
#         }

#         url = "https://gql.railway.app/graphql"

#         def mutation(name, value):
#             return {
#                 "query": """
#                 mutation UpsertVariable($input: UpsertVariableInput!) {
#                     upsertVariable(input: $input) {
#                         id
#                         name
#                         value
#                     }
#                 }
#                 """,
#                 "variables": {
#                     "input": {
#                         "environmentId": ENV_ID,
#                         "projectId": PROJECT_ID,
#                         "name": name,
#                         "value": value.replace('\n', '\\n')
#                     }
#                 }
#             }

#         print("Private Key:", new_private_key, flush=True)
#         print("Public Key:", new_public_key, flush=True)

#         for var_name, var_val in {
#             "ENCRYPTION_PRIVATE_KEY": new_private_key,
#             "ENCRYPTION_PUBLIC_KEY": new_public_key
#         }.items():
#             res = requests.post(url, headers=headers, json=mutation(var_name, var_val))
#             if res.status_code == 200:
#                 print(f"✅ Updated {var_name} and {var_val} on Railway.", flush=True)
#             else:
#                 print(f"❌ Failed to update {var_name}: {res.text}", flush=True)

#         # Redeploy the service to apply env var changes
#         try:
#             print("🔁 Triggering self-redeploy to apply new env vars...", flush=True)
#             redeploy_mutation = {
#                 "query": """
#                 mutation DeployEnvironment($input: DeployEnvironmentInput!) {
#                     deployEnvironment(input: $input) {
#                         id
#                     }
#                 }
#                 """,
#                 "variables": {
#                     "input": {
#                         "environmentId": ENV_ID,
#                         "projectId": PROJECT_ID
#                     }
#                 }
#             }
#             r = requests.post("https://gql.railway.app/graphql", headers=headers, json=redeploy_mutation)
#             if r.status_code == 200:
#                 print("✅ Redeployment triggered successfully.", flush=True)
#             else:
#                 print("❌ Failed to trigger redeployment:", r.text, flush=True)
#         except Exception as e:
#             print("❌ Exception during redeploy trigger:", e, flush=True)

#     try:
#         config_doc = config_ref.get()
#         print("First try block works!", flush=True)
#     except Exception as e:
#         print("🔥 Firestore unavailable. Skipping key rotation.", flush=True)
#         print(traceback.format_exc(), flush=True)
#         return

#     old_private_key_raw = os.getenv("ENCRYPTION_PRIVATE_KEY", "")
#     old_public_key_raw = os.getenv("ENCRYPTION_PUBLIC_KEY", "")
#     print("✅ Project ID:", os.environ.get("RAILWAY_PROJECT_ID"), flush=True)
#     print("✅ Env ID:", os.environ.get("RAILWAY_ENVIRONMENT_ID"), flush=True)
#     print("✅ Token Exists:", bool(os.environ.get("RAILWAY_API_TOKEN")), flush=True)

#     is_first_time = not old_private_key_raw.strip() or not old_public_key_raw.strip()

#     if old_private_key_raw:
#         fixed_key = old_private_key_raw.encode('utf-8').decode('unicode_escape').encode('utf-8')
#         old_private_key = serialization.load_pem_private_key(
#             fixed_key,
#             password=None,
#             backend=default_backend()
#         )
#     else:
#         old_private_key = None

#     if is_first_time:
#         print("🆕 No keys in env. Encrypting docs for the first time...", flush=True)
#     else:
#         print("🔁 Rotating keys for all encrypted documents...", flush=True)

#     new_private_key, new_public_key = generate_ecc_keys()
#     docs = db.collection("users").stream()

#     found_docs = False

#     for doc in docs:
#         found_docs = True
#         try:
#             doc_data = doc.to_dict()
#             if not doc_data:
#                 print(f"⚠️ Skipping empty doc: {doc.id}", flush=True)
#                 continue

#             if is_first_time:
#                 encrypted_fields = {}
#                 for key, value in doc_data.items():
#                     if value is None:
#                         encrypted_fields[key] = None
#                     else:
#                         encrypted_fields[key] = hybrid_encrypt(new_public_key, {"value": value})
#                 doc.reference.set(encrypted_fields)
#                 print(f"✅ Encrypted (first time): {doc.id}", flush=True)
#             else:
#                 decrypted_fields = {}
#                 for key, encrypted_field in doc_data.items():
#                     if encrypted_field is None:
#                         decrypted_fields[key] = None
#                         continue
#                     try:
#                         decrypted = hybrid_decrypt(old_private_key, encrypted_field)
#                         decrypted_fields[key] = decrypted["value"]
#                     except Exception as e:
#                         print(f"❌ Decryption failed for field '{key}' in doc {doc.id}: {e}", flush=True)
#                         raise

#                 re_encrypted_fields = {}
#                 for key, value in decrypted_fields.items():
#                     if value is None:
#                         re_encrypted_fields[key] = None
#                     else:
#                         re_encrypted_fields[key] = hybrid_encrypt(new_public_key, {"value": value})

#                 doc.reference.set(re_encrypted_fields)
#                 print(f"✅ Re-encrypted: {doc.id}", flush=True)

#         except Exception as e:
#             print(f"❌ Failed to process doc {doc.id}: {e}", flush=True)
#             print(traceback.format_exc())

#     if not found_docs:
#         print("📭 No documents found in 'users/' collection. Skipping encryption.", flush=True)

#     try:
#         config_ref.set({"last_rotation": now})
#         print("🧠 Saved new rotation timestamp in Firestore.", flush=True)
#     except Exception as e:
#         print(f"⚠️ Failed to save timestamp in Firestore: {e}", flush=True)

#     try:
#         auto_update_env_on_railway(new_private_key, new_public_key)
#     except Exception as e:
#         print("❌ Failed to auto-update Railway ENV vars:", flush=True)
#         print(traceback.format_exc(), flush=True)
def run():
    import os
    import datetime
    import traceback
    from dotenv import load_dotenv
    from password_reset.firebase import db
    from password_reset.utils.encryption import (
        generate_ecc_keys,
        hybrid_encrypt,
        hybrid_decrypt,
        generate_aes_key,
        aes_encrypt,
        aes_decrypt
    )
    from cryptography.hazmat.backends import default_backend
    from cryptography.hazmat.primitives import serialization

    print("🚀 Starting key rotation script...", flush=True)
    load_dotenv()
    now = datetime.datetime.utcnow()

    config_ref = db.collection("config").document("encryption_metadata")
    master_private_key_pem = os.getenv("MASTER_ECC_PRIVATE_KEY").encode()
    master_private_key = serialization.load_pem_private_key(
        master_private_key_pem,
        password=None,
        backend=default_backend()
    )

    try:
        config_doc = config_ref.get()
        config_data = config_doc.to_dict() or {}
        encrypted_ecc_key = config_data.get("encrypted_ecc_key")
        last_rotation = config_data.get("last_rotation")
        print("📄 Loaded config from Firestore.", flush=True)
    except Exception as e:
        print("🔥 Firestore unavailable. Skipping key rotation.", flush=True)
        print(traceback.format_exc(), flush=True)
        return

    is_first_time = encrypted_ecc_key is None

    if is_first_time:
        print("🆕 First-time setup. Generating keys and encrypting data...", flush=True)

        ecc_private_key, ecc_public_key = generate_ecc_keys()
        aes_key = generate_aes_key()

        encrypted_aes_key = hybrid_encrypt(ecc_public_key, {"aes_key": aes_key.hex()})
        encrypted_ecc_key = hybrid_encrypt(master_private_key.public_key(), {
            "ecc_key": ecc_private_key.private_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PrivateFormat.PKCS8,
                encryption_algorithm=serialization.NoEncryption()
            ).decode()
        })

        docs = db.collection("users").stream()
        for doc in docs:
            doc_data = doc.to_dict()
            encrypted_fields = {}
            for k, v in doc_data.items():
                if v is None:
                    encrypted_fields[k] = None
                else:
                    encrypted_fields[k] = aes_encrypt(aes_key, v)
            doc.reference.set(encrypted_fields)
            print(f"✅ Encrypted doc: {doc.id}", flush=True)

        config_ref.set({
            "encrypted_ecc_key": encrypted_ecc_key,
            "encrypted_aes_key": encrypted_aes_key,
            "last_rotation": now
        })
        print("🔐 Stored encrypted keys in Firestore.", flush=True)

    else:
        print("🔁 Rotating encryption keys...", flush=True)

        decrypted_ecc_key_pem = hybrid_decrypt(master_private_key, encrypted_ecc_key)["ecc_key"].encode()
        ecc_private_key = serialization.load_pem_private_key(
            decrypted_ecc_key_pem,
            password=None,
            backend=default_backend()
        )

        encrypted_aes_key = config_data["encrypted_aes_key"]
        decrypted_aes_hex = hybrid_decrypt(ecc_private_key, encrypted_aes_key)["aes_key"]
        old_aes_key = bytes.fromhex(decrypted_aes_hex)

        new_aes_key = generate_aes_key()
        new_ecc_private_key, new_ecc_public_key = generate_ecc_keys()

        new_encrypted_aes_key = hybrid_encrypt(new_ecc_public_key, {"aes_key": new_aes_key.hex()})
        new_encrypted_ecc_key = hybrid_encrypt(master_private_key.public_key(), {
            "ecc_key": new_ecc_private_key.private_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PrivateFormat.PKCS8,
                encryption_algorithm=serialization.NoEncryption()
            ).decode()
        })

        docs = db.collection("users").stream()
        for doc in docs:
            doc_data = doc.to_dict()
            decrypted_fields = {}
            for k, encrypted_val in doc_data.items():
                if encrypted_val is None:
                    decrypted_fields[k] = None
                else:
                    decrypted_fields[k] = aes_decrypt(old_aes_key, encrypted_val)

            re_encrypted_fields = {}
            for k, v in decrypted_fields.items():
                if v is None:
                    re_encrypted_fields[k] = None
                else:
                    re_encrypted_fields[k] = aes_encrypt(new_aes_key, v)

            doc.reference.set(re_encrypted_fields)
            print(f"🔄 Rotated doc: {doc.id}", flush=True)

        config_ref.set({
            "encrypted_ecc_key": new_encrypted_ecc_key,
            "encrypted_aes_key": new_encrypted_aes_key,
            "last_rotation": now
        })
        print("✅ Updated encrypted keys in Firestore.", flush=True)
