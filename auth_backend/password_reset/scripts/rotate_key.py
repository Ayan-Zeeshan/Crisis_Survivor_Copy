# # def run():
# #     import os
# #     from dotenv import load_dotenv
# #     from password_reset.firebase import db
# #     from password_reset.utils.encryption import generate_ecc_keys, hybrid_encrypt, hybrid_decrypt

# #     load_dotenv()

# #     old_private_key = os.getenv("ENCRYPTION_PRIVATE_KEY")
# #     old_public_key = os.getenv("ENCRYPTION_PUBLIC_KEY")

# #     is_first_time = old_private_key is None or old_public_key is None

# #     if is_first_time:
# #         print("🆕 No encryption keys found. Encrypting all documents for the first time...")
# #     else:
# #         print("🔁 Rotating keys for all documents...")

# #     new_private_key, new_public_key = generate_ecc_keys()
# #     docs = db.collection("users").stream()

# #     for doc in docs:
# #         try:
# #             doc_data = doc.to_dict()

# #             if is_first_time:
# #                 encrypted_fields = {}
# #                 for key, value in doc_data.items():
# #                     encrypted_fields[key] = hybrid_encrypt(new_public_key, {key: value})
# #                 doc.reference.set(encrypted_fields)
# #                 print(f"✅ Encrypted doc for first time: {doc.id}")

# #             else:
# #                 decrypted_fields = {}
# #                 for key, encrypted_field in doc_data.items():
# #                     try:
# #                         decrypted = hybrid_decrypt(old_private_key, encrypted_field)
# #                         decrypted_fields[key] = list(decrypted.values())[0]
# #                     except Exception as e:
# #                         print(f"❌ Failed to decrypt field '{key}' in doc {doc.id}: {e}")
# #                         raise

# #                 re_encrypted_fields = {}
# #                 for key, value in decrypted_fields.items():
# #                     re_encrypted_fields[key] = hybrid_encrypt(new_public_key, {key: value})

# #                 doc.reference.set(re_encrypted_fields)
# #                 print(f"✅ Re-encrypted doc: {doc.id}")

# #         except Exception as e:
# #             print(f"❌ Failed to process doc {doc.id}: {e}")

# #     print("\n🚨 Update Railway ENV Vars:")
# #     print("→ ENCRYPTION_PRIVATE_KEY=\n" + new_private_key)
# #     print("→ ENCRYPTION_PUBLIC_KEY=\n" + new_public_key)
# def run():
#     import os
#     import datetime
#     from dotenv import load_dotenv
#     from google.cloud.firestore import Client
#     from password_reset.firebase import db
#     from password_reset.utils.encryption import generate_ecc_keys, hybrid_encrypt, hybrid_decrypt

#     load_dotenv()

#     now = datetime.datetime.utcnow()
#     config_ref = db.collection("config").document("encryption_metadata")
#     config_doc = config_ref.get()

#     last_rotation_time = None
#     if config_doc.exists:
#         last_rotation_time = config_doc.to_dict().get("last_rotation")

#     if last_rotation_time:
#         last_rotation_time = last_rotation_time.replace(tzinfo=None)
#         hours_since = (now - last_rotation_time).total_seconds() / 3600
#         if hours_since < 24:
#             print(f"🛑 Last rotation was {hours_since:.2f}h ago. Skipping...")
#             return

#     old_private_key = os.getenv("ENCRYPTION_PRIVATE_KEY")
#     old_public_key = os.getenv("ENCRYPTION_PUBLIC_KEY")

#     is_first_time = old_private_key is None or old_public_key is None

#     if is_first_time:
#         print("🆕 No encryption keys found. Encrypting all documents for the first time...")
#     else:
#         print("🔁 Rotating keys for all documents...")

#     new_private_key, new_public_key = generate_ecc_keys()
#     docs = db.collection("users").stream()

#     for doc in docs:
#         try:
#             doc_data = doc.to_dict()

#             if is_first_time:
#                 encrypted_fields = {
#                     key: hybrid_encrypt(new_public_key, {key: value})
#                     for key, value in doc_data.items()
#                 }
#                 doc.reference.set(encrypted_fields)
#                 print(f"✅ Encrypted doc for first time: {doc.id}")

#             else:
#                 decrypted_fields = {}
#                 for key, encrypted_field in doc_data.items():
#                     try:
#                         decrypted = hybrid_decrypt(old_private_key, encrypted_field)
#                         decrypted_fields[key] = list(decrypted.values())[0]
#                     except Exception as e:
#                         print(f"❌ Failed to decrypt field '{key}' in doc {doc.id}: {e}")
#                         raise

#                 re_encrypted_fields = {
#                     key: hybrid_encrypt(new_public_key, {key: value})
#                     for key, value in decrypted_fields.items()
#                 }

#                 doc.reference.set(re_encrypted_fields)
#                 print(f"✅ Re-encrypted doc: {doc.id}")

#         except Exception as e:
#             print(f"❌ Failed to process doc {doc.id}: {e}")

#     # 🧠 Save last rotation timestamp
#     config_ref.set({"last_rotation": now})
#     print("\n🕐 Updated last_rotation in Firestore")

#     print("\n🚨 Update Railway ENV Vars:")
#     print("→ ENCRYPTION_PRIVATE_KEY=\n" + new_private_key)
#     print("→ ENCRYPTION_PUBLIC_KEY=\n" + new_public_key)
def run():
    import os
    import datetime
    import traceback
    from dotenv import load_dotenv
    from google.cloud.firestore_v1.base import Client
    from google.api_core.exceptions import GoogleAPIError
    from password_reset.firebase import db
    from password_reset.utils.encryption import generate_ecc_keys, hybrid_encrypt, hybrid_decrypt

    load_dotenv()

    now = datetime.datetime.utcnow()
    config_ref = db.collection("config").document("encryption_metadata")

    try:
        config_doc = config_ref.get()
        last_rotation_time = config_doc.to_dict().get("last_rotation") if config_doc.exists else None
    except GoogleAPIError as e:
        print("🔥 Firestore unavailable. Skipping key rotation.")
        print(traceback.format_exc())
        return

    # Auto-create config doc if missing
    if last_rotation_time:
        last_rotation_time = last_rotation_time.replace(tzinfo=None)
        hours_since = (now - last_rotation_time).total_seconds() / 3600
        if hours_since < 24:
            print(f"🛑 Last rotation was {hours_since:.2f}h ago. Skipping...")
            return
    else:
        print("🔧 No encryption_metadata found — creating it for first time...")

    # Load current keys
    old_private_key = os.getenv("ENCRYPTION_PRIVATE_KEY")
    old_public_key = os.getenv("ENCRYPTION_PUBLIC_KEY")
    is_first_time = old_private_key is None or old_public_key is None

    if is_first_time:
        print("🆕 No keys in env. Encrypting docs for the first time...")
    else:
        print("🔁 Rotating keys for all encrypted documents...")

    new_private_key, new_public_key = generate_ecc_keys()
    docs = db.collection("users").stream()

    for doc in docs:
        try:
            doc_data = doc.to_dict()

            if is_first_time:
                encrypted_fields = {
                    key: hybrid_encrypt(new_public_key, {key: value})
                    for key, value in doc_data.items()
                }
                doc.reference.set(encrypted_fields)
                print(f"✅ Encrypted (first time): {doc.id}")
            else:
                decrypted_fields = {}
                for key, encrypted_field in doc_data.items():
                    try:
                        decrypted = hybrid_decrypt(old_private_key, encrypted_field)
                        decrypted_fields[key] = list(decrypted.values())[0]
                    except Exception as e:
                        print(f"❌ Decryption failed for field '{key}' in doc {doc.id}: {e}")
                        raise

                re_encrypted_fields = {
                    key: hybrid_encrypt(new_public_key, {key: value})
                    for key, value in decrypted_fields.items()
                }

                doc.reference.set(re_encrypted_fields)
                print(f"✅ Re-encrypted: {doc.id}")

        except Exception as e:
            print(f"❌ Failed to process doc {doc.id}: {e}")
            print(traceback.format_exc())

    # Save rotation timestamp
    try:
        config_ref.set({"last_rotation": now})
        print("🧠 Saved new rotation timestamp in Firestore.")
    except Exception as e:
        print(f"⚠️ Failed to save timestamp in Firestore: {e}")

    # Final instructions for Railway
    print("\n🚨 Update these Railway ENV Vars manually:")
    print("→ ENCRYPTION_PRIVATE_KEY=\n" + new_private_key)
    print("→ ENCRYPTION_PUBLIC_KEY=\n" + new_public_key)

    # Optional: Auto-push to Railway API (commented by default)
    # auto_update_env_on_railway(new_private_key, new_public_key)

def auto_update_env_on_railway(new_private_key, new_public_key):
    import requests
    import os

    RAILWAY_TOKEN = os.environ.get("RAILWAY_API_TOKEN")
    PROJECT_ID = "your_project_id_here"
    ENV_ID = "your_env_id_here"  # Can be production/staging or actual env UUID

    headers = {
        "Authorization": f"Bearer {RAILWAY_TOKEN}",
        "Content-Type": "application/json"
    }

    url = f"https://backboard.railway.app/graphql"

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
                    "value": value
                }
            }
        }

    for var_name, var_val in {
        "ENCRYPTION_PRIVATE_KEY": new_private_key,
        "ENCRYPTION_PUBLIC_KEY": new_public_key
    }.items():
        res = requests.post(url, headers=headers, json=mutation(var_name, var_val))
        if res.status_code == 200:
            print(f"✅ Updated {var_name} on Railway.")
        else:
            print(f"❌ Failed to update {var_name}: {res.text}")
