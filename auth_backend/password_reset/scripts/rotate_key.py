# # def run():
# #     import os
# #     import datetime
# #     import traceback
# #     import requests
# #     from dotenv import load_dotenv
# #     from password_reset.firebase import db
# #     from password_reset.utils.encryption import generate_ecc_keys, hybrid_encrypt, hybrid_decrypt
# #     import sys

# #     print("🚀 Starting key rotation script...", flush=True)


# #     load_dotenv()

# #     now = datetime.datetime.utcnow()
# #     config_ref = db.collection("config").document("encryption_metadata")
# #     def auto_update_env_on_railway(new_private_key, new_public_key):
# #         import requests
# #         import os

# #         RAILWAY_TOKEN = os.environ.get("RAILWAY_API_TOKEN")
# #         PROJECT_ID = os.environ.get("RAILWAY_PROJECT_ID")
# #         ENV_ID = os.environ.get("RAILWAY_ENVIRONMENT_ID")

# #         if not all([RAILWAY_TOKEN, PROJECT_ID, ENV_ID]):
# #             raise Exception("RAILWAY_API_TOKEN, RAILWAY_PROJECT_ID, or RAILWAY_ENV_ID is missing.")

# #         headers = {
# #             "Authorization": f"Bearer {RAILWAY_TOKEN}",
# #             "Content-Type": "application/json"
# #         }

# #         url = "https://backboard.railway.app/graphql"

# #         def mutation(name, value):
# #             return {
# #                 "query": """
# #                 mutation UpsertVariable($input: UpsertVariableInput!) {
# #                 upsertVariable(input: $input) {
# #                     id
# #                     name
# #                     value
# #                 }
# #                 }
# #                 """,
# #                 "variables": {
# #                     "input": {
# #                         "environmentId": ENV_ID,
# #                         "projectId": PROJECT_ID,
# #                         "name": name,
# #                         "value": value
# #                     }
# #                 }
# #             }

# #         for var_name, var_val in {
# #             "ENCRYPTION_PRIVATE_KEY": new_private_key,
# #             "ENCRYPTION_PUBLIC_KEY": new_public_key
# #         }.items():
# #             res = requests.post(url, headers=headers, json=mutation(var_name, var_val))
# #             if res.status_code == 200:
# #                 print(f"✅ Updated {var_name} on Railway.", flush=True)
# #             else:
# #                 print(f"❌ Failed to update {var_name}: {res.text}", flush=True)
# #     try:
# #         config_doc = config_ref.get()
# #         print("First try block works!", flush=True)
# #     except Exception as e:
# #         print("🔥 Firestore unavailable. Skipping key rotation.", flush=True)
# #         print(traceback.format_exc(), flush=True)
# #         return

# #     old_private_key = os.getenv("ENCRYPTION_PRIVATE_KEY")
# #     old_public_key = os.getenv("ENCRYPTION_PUBLIC_KEY")
# #     is_first_time = old_private_key is None or old_public_key is None

# #     if is_first_time:
# #         print("🆕 No keys in env. Encrypting docs for the first time...", flush=True)
# #     else:
# #         print("🔁 Rotating keys for all encrypted documents...", flush=True)

# #     new_private_key, new_public_key = generate_ecc_keys()
# #     docs = db.collection("users").stream()

# #     for doc in docs:
# #         try:
# #             doc_data = doc.to_dict()

# #             if is_first_time:
# #                 encrypted_fields = {
# #                     key: hybrid_encrypt(new_public_key, {key: value})
# #                     for key, value in doc_data.items()
# #                 }
# #                 doc.reference.set(encrypted_fields)
# #                 print(f"✅ Encrypted (first time): {doc.id}", flush=True)
# #                 print("second try block works!", flush=True)
# #             else:
# #                 decrypted_fields = {}
# #                 for key, encrypted_field in doc_data.items():
# #                     try:
# #                         decrypted = hybrid_decrypt(old_private_key, encrypted_field)
# #                         decrypted_fields[key] = list(decrypted.values())[0]
# #                     except Exception as e:
# #                         print(f"❌ Decryption failed for field '{key}' in doc {doc.id}: {e}", flush=True)
# #                         raise

# #                 re_encrypted_fields = {
# #                     key: hybrid_encrypt(new_public_key, {key: value})
# #                     for key, value in decrypted_fields.items()
# #                 }

# #                 doc.reference.set(re_encrypted_fields)
# #                 print(f"✅ Re-encrypted: {doc.id}")

# #         except Exception as e:
# #             print(f"❌ Failed to process doc {doc.id}: {e}", flush=True)
# #             print(traceback.format_exc())

# #     try:
# #         config_ref.set({"last_rotation": now})
# #         print("🧠 Saved new rotation timestamp in Firestore.", flush=True)
# #     except Exception as e:
# #         print(f"⚠️ Failed to save timestamp in Firestore: {e}", flush=True)

# #     try:
# #         auto_update_env_on_railway(new_private_key, new_public_key)
# #     except Exception as e:
# #         print("❌ Failed to auto-update Railway ENV vars:", flush=True)
# #         print(traceback.format_exc(), flush=True)
# def run():
#     import os
#     import datetime
#     import traceback
#     import requests
#     from dotenv import load_dotenv
#     from password_reset.firebase import db
#     from password_reset.utils.encryption import generate_ecc_keys, hybrid_encrypt, hybrid_decrypt

#     print("🚀 Starting key rotation script...", flush=True)

#     load_dotenv()

#     def fix_pem_format(pem_str):
#         return pem_str.replace('\\n', '\n').encode() if pem_str else None

#     now = datetime.datetime.utcnow()
#     config_ref = db.collection("config").document("encryption_metadata")

#     def auto_update_env_on_railway(new_private_key, new_public_key):
#         import requests
#         import os

#         RAILWAY_TOKEN = os.environ.get("RAILWAY_API_TOKEN")
#         PROJECT_ID = os.environ.get("RAILWAY_PROJECT_ID")
#         ENV_ID = os.environ.get("RAILWAY_ENVIRONMENT_ID")

#         if not all([RAILWAY_TOKEN, PROJECT_ID, ENV_ID]):
#             raise Exception("RAILWAY_API_TOKEN, RAILWAY_PROJECT_ID, or RAILWAY_ENV_ID is missing.")

#         headers = {
#             "Authorization": f"Bearer {RAILWAY_TOKEN}",
#             "Content-Type": "application/json"
#         }

#         url = "https://backboard.railway.app/graphql"

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
#     is_first_time = not old_private_key_raw.strip() or not old_public_key_raw.strip()

#     old_private_key = fix_pem_format(old_private_key_raw)
#     old_public_key = fix_pem_format(old_public_key_raw)

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

    print("🚀 Starting key rotation script...", flush=True)

    load_dotenv()

    def fix_pem_format(pem_str):
        return pem_str.replace('\\n', '\n').encode() if pem_str else None

    now = datetime.datetime.utcnow()
    config_ref = db.collection("config").document("encryption_metadata")

    # def auto_update_env_on_railway(new_private_key, new_public_key):
    #     import requests
    #     import os

    #     RAILWAY_TOKEN = os.environ.get("RAILWAY_API_TOKEN")
    #     ENV_ID = os.environ.get("RAILWAY_ENVIRONMENT_ID")

    #     if not all([RAILWAY_TOKEN, ENV_ID]):
    #         raise Exception("RAILWAY_API_TOKEN or RAILWAY_ENVIRONMENT_ID is missing.")

    #     headers = {
    #         "Authorization": f"Bearer {RAILWAY_TOKEN}",
    #         "Content-Type": "application/json"
    #     }

    #     url = "https://backboard.railway.app/graphql"

    #     def mutation(name, value):
    #         return {
    #             "query": """
    #             mutation UpsertVariable($input: UpsertVariableInput!) {
    #                 upsertVariable(input: $input) {
    #                     id
    #                     name
    #                     value
    #                 }
    #             }
    #             """,
    #             "variables": {
    #                 "input": {
    #                     "environmentId": ENV_ID,
    #                     "name": name,
    #                     "value": value.replace('\n', '\\n')
    #                 }
    #             }
    #         }

    #     for var_name, var_val in {
    #         "ENCRYPTION_PRIVATE_KEY": new_private_key,
    #         "ENCRYPTION_PUBLIC_KEY": new_public_key
    #     }.items():
    #         res = requests.post(url, headers=headers, json=mutation(var_name, var_val))
    #         if res.status_code == 200:
    #             print(f"✅ Updated {var_name} on Railway.", flush=True)
    #         else:
    #             print(f"❌ Failed to update {var_name}: {res.text}", flush=True)
    def list_env_vars_on_railway():
        import os
        import requests

        RAILWAY_TOKEN = os.environ.get("RAILWAY_API_TOKEN")
        ENV_ID = os.environ.get("RAILWAY_ENVIRONMENT_ID")

        if not all([RAILWAY_TOKEN, ENV_ID]):
            raise Exception("Missing RAILWAY_API_TOKEN or RAILWAY_ENVIRONMENT_ID")

        headers = {
            "Authorization": f"Bearer {RAILWAY_TOKEN}",
            "Content-Type": "application/json"
        }

        query = {
            "query": """
            query GetVariables($environmentId: String!) {
            variables(environmentId: $environmentId) {
                edges {
                node {
                    id
                    name
                    value
                }
                }
            }
            }
            """,
            "variables": {
                "environmentId": ENV_ID
            }
        }

        response = requests.post("https://backboard.railway.app/graphql", headers=headers, json=query)
        
        if response.status_code == 200:
            data = response.json()
            vars = data.get("data", {}).get("variables", {}).get("edges", [])
            print("🔍 Current environment variables:",flush=True)
            for var in vars:
                name = var["node"]["name"]
                val = var["node"]["value"]
                print(f" - {name} = {val[:10]}...",flush=True)  # show only first 10 chars for safety
        else:
            print(f"❌ Failed to fetch env vars: {response.text}",flush=True)

    try:
        config_doc = config_ref.get()
        print("First try block works!", flush=True)
    except Exception as e:
        print("🔥 Firestore unavailable. Skipping key rotation.", flush=True)
        print(traceback.format_exc(), flush=True)
        return

    old_private_key_raw = os.getenv("ENCRYPTION_PRIVATE_KEY", "")
    old_public_key_raw = os.getenv("ENCRYPTION_PUBLIC_KEY", "")
    print("✅ Project ID:", os.environ.get("RAILWAY_PROJECT_ID"),flush=True)
    print("✅ Env ID:", os.environ.get("RAILWAY_ENVIRONMENT_ID"),flush=True)
    print("✅ Token Exists:", bool(os.environ.get("RAILWAY_API_TOKEN")),flush=True)

    is_first_time = not old_private_key_raw.strip() or not old_public_key_raw.strip()

    old_private_key = fix_pem_format(old_private_key_raw)
    old_public_key = fix_pem_format(old_public_key_raw)

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
        list_env_vars_on_railway()
        # auto_update_env_on_railway(new_private_key, new_public_key)
    except Exception as e:
        print("❌ Failed to auto-update Railway ENV vars:", flush=True)
        print(traceback.format_exc(), flush=True)
