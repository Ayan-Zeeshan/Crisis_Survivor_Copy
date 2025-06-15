
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
#                 print(f"✅ Updated {var_name} on Railway.", flush=True)
#             else:
#                 print(f"❌ Failed to update {var_name}: {res.text}", flush=True)

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
#         fixed_key = old_private_key_raw.replace('\\n', '\n').encode()
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
#                         encrypted_fields[key] = hybrid_encrypt(new_public_key, {key: value})
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
#                         decrypted_fields[key] = list(decrypted.values())[0]
#                     except Exception as e:
#                         print(f"❌ Decryption failed for field '{key}' in doc {doc.id}: {e}", flush=True)
#                         raise

#                 re_encrypted_fields = {}
#                 for key, value in decrypted_fields.items():
#                     if value is None:
#                         re_encrypted_fields[key] = None
#                     else:
#                         re_encrypted_fields[key] = hybrid_encrypt(new_public_key, {key: value})

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
    from password_reset.utils.encryption import generate_ecc_keys, hybrid_encrypt, hybrid_decrypt
    from cryptography.hazmat.backends import default_backend
    from cryptography.hazmat.primitives import serialization

    print("🚀 Starting key rotation script...", flush=True)

    load_dotenv()

    now = datetime.datetime.utcnow()
    config_ref = db.collection("config").document("encryption_metadata")

    def auto_update_env_on_railway(new_private_key, new_public_key):
        import requests
        import os

        RAILWAY_TOKEN = os.environ.get("RAILWAY_API_TOKEN")
        ENV_ID = os.environ.get("RAILWAY_ENVIRONMENT_ID")
        PROJECT_ID = os.environ.get("RAILWAY_PROJECT_ID")

        if not all([RAILWAY_TOKEN, ENV_ID]):
            raise Exception("RAILWAY_API_TOKEN or RAILWAY_ENVIRONMENT_ID is missing.")

        headers = {
            "Authorization": f"Bearer {RAILWAY_TOKEN}",
            "Content-Type": "application/json"
        }

        url = "https://gql.railway.app/graphql"

        def mutation(name, value):
            return {
                "query": """
                mutation UpsertVariable($input: UpsertVariableInput!) {
                    upsertVariable(input: $input) {
                        id
                        name
                        value
                    }
                }
                """,
                "variables": {
                    "input": {
                        "environmentId": ENV_ID,
                        "projectId": PROJECT_ID,
                        "name": name,
                        "value": value.replace('\n', '\\n')
                    }
                }
            }

        print("Private Key:", new_private_key, flush=True)
        print("Public Key:", new_public_key, flush=True)

        for var_name, var_val in {
            "ENCRYPTION_PRIVATE_KEY": new_private_key,
            "ENCRYPTION_PUBLIC_KEY": new_public_key
        }.items():
            res = requests.post(url, headers=headers, json=mutation(var_name, var_val))
            if res.status_code == 200:
                print(f"✅ Updated {var_name} and {var_val} on Railway.", flush=True)
            else:
                print(f"❌ Failed to update {var_name}: {res.text}", flush=True)

    try:
        config_doc = config_ref.get()
        print("First try block works!", flush=True)
    except Exception as e:
        print("🔥 Firestore unavailable. Skipping key rotation.", flush=True)
        print(traceback.format_exc(), flush=True)
        return

    old_private_key_raw = os.getenv("ENCRYPTION_PRIVATE_KEY", "")
    old_public_key_raw = os.getenv("ENCRYPTION_PUBLIC_KEY", "")
    print("✅ Project ID:", os.environ.get("RAILWAY_PROJECT_ID"), flush=True)
    print("✅ Env ID:", os.environ.get("RAILWAY_ENVIRONMENT_ID"), flush=True)
    print("✅ Token Exists:", bool(os.environ.get("RAILWAY_API_TOKEN")), flush=True)

    is_first_time = not old_private_key_raw.strip() or not old_public_key_raw.strip()

    if old_private_key_raw:
        fixed_key = old_private_key_raw.encode('utf-8').decode('unicode_escape').encode('utf-8')
        old_private_key = serialization.load_pem_private_key(
            fixed_key,
            password=None,
            backend=default_backend()
        )
    else:
        old_private_key = None

    if is_first_time:
        print("🆕 No keys in env. Encrypting docs for the first time...", flush=True)
    else:
        print("🔁 Rotating keys for all encrypted documents...", flush=True)

    new_private_key, new_public_key = generate_ecc_keys()
    docs = db.collection("users").stream()

    found_docs = False

    for doc in docs:
        found_docs = True
        try:
            doc_data = doc.to_dict()
            if not doc_data:
                print(f"⚠️ Skipping empty doc: {doc.id}", flush=True)
                continue

            if is_first_time:
                encrypted_fields = {}
                for key, value in doc_data.items():
                    if value is None:
                        encrypted_fields[key] = None
                    else:
                        encrypted_fields[key] = hybrid_encrypt(new_public_key, {key: value})
                doc.reference.set(encrypted_fields)
                print(f"✅ Encrypted (first time): {doc.id}", flush=True)
            else:
                decrypted_fields = {}
                for key, encrypted_field in doc_data.items():
                    if encrypted_field is None:
                        decrypted_fields[key] = None
                        continue
                    try:
                        decrypted = hybrid_decrypt(old_private_key, encrypted_field)
                        decrypted_fields[key] = list(decrypted.values())[0]
                    except Exception as e:
                        print(f"❌ Decryption failed for field '{key}' in doc {doc.id}: {e}", flush=True)
                        raise

                re_encrypted_fields = {}
                for key, value in decrypted_fields.items():
                    if value is None:
                        re_encrypted_fields[key] = None
                    else:
                        re_encrypted_fields[key] = hybrid_encrypt(new_public_key, {key: value})

                doc.reference.set(re_encrypted_fields)
                print(f"✅ Re-encrypted: {doc.id}", flush=True)

        except Exception as e:
            print(f"❌ Failed to process doc {doc.id}: {e}", flush=True)
            print(traceback.format_exc())

    if not found_docs:
        print("📭 No documents found in 'users/' collection. Skipping encryption.", flush=True)

    try:
        config_ref.set({"last_rotation": now})
        print("🧠 Saved new rotation timestamp in Firestore.", flush=True)
    except Exception as e:
        print(f"⚠️ Failed to save timestamp in Firestore: {e}", flush=True)

    try:
        auto_update_env_on_railway(new_private_key, new_public_key)
    except Exception as e:
        print("❌ Failed to auto-update Railway ENV vars:", flush=True)
        print(traceback.format_exc(), flush=True)
