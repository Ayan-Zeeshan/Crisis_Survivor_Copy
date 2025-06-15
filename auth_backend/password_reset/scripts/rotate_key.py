# def run():
#     import os
#     from dotenv import load_dotenv
#     from password_reset.firebase import db
#     from password_reset.utils.encryption import generate_ecc_keys, hybrid_encrypt, hybrid_decrypt

#     load_dotenv()

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
#                 encrypted_fields = {}
#                 for key, value in doc_data.items():
#                     encrypted_fields[key] = hybrid_encrypt(new_public_key, {key: value})
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

#                 re_encrypted_fields = {}
#                 for key, value in decrypted_fields.items():
#                     re_encrypted_fields[key] = hybrid_encrypt(new_public_key, {key: value})

#                 doc.reference.set(re_encrypted_fields)
#                 print(f"✅ Re-encrypted doc: {doc.id}")

#         except Exception as e:
#             print(f"❌ Failed to process doc {doc.id}: {e}")

#     print("\n🚨 Update Railway ENV Vars:")
#     print("→ ENCRYPTION_PRIVATE_KEY=\n" + new_private_key)
#     print("→ ENCRYPTION_PUBLIC_KEY=\n" + new_public_key)
def run():
    import os
    import datetime
    from dotenv import load_dotenv
    from google.cloud.firestore import Client
    from password_reset.firebase import db
    from password_reset.utils.encryption import generate_ecc_keys, hybrid_encrypt, hybrid_decrypt

    load_dotenv()

    now = datetime.datetime.utcnow()
    config_ref = db.collection("config").document("encryption_metadata")
    config_doc = config_ref.get()

    last_rotation_time = None
    if config_doc.exists:
        last_rotation_time = config_doc.to_dict().get("last_rotation")

    if last_rotation_time:
        last_rotation_time = last_rotation_time.replace(tzinfo=None)
        hours_since = (now - last_rotation_time).total_seconds() / 3600
        if hours_since < 24:
            print(f"🛑 Last rotation was {hours_since:.2f}h ago. Skipping...")
            return

    old_private_key = os.getenv("ENCRYPTION_PRIVATE_KEY")
    old_public_key = os.getenv("ENCRYPTION_PUBLIC_KEY")

    is_first_time = old_private_key is None or old_public_key is None

    if is_first_time:
        print("🆕 No encryption keys found. Encrypting all documents for the first time...")
    else:
        print("🔁 Rotating keys for all documents...")

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
                print(f"✅ Encrypted doc for first time: {doc.id}")

            else:
                decrypted_fields = {}
                for key, encrypted_field in doc_data.items():
                    try:
                        decrypted = hybrid_decrypt(old_private_key, encrypted_field)
                        decrypted_fields[key] = list(decrypted.values())[0]
                    except Exception as e:
                        print(f"❌ Failed to decrypt field '{key}' in doc {doc.id}: {e}")
                        raise

                re_encrypted_fields = {
                    key: hybrid_encrypt(new_public_key, {key: value})
                    for key, value in decrypted_fields.items()
                }

                doc.reference.set(re_encrypted_fields)
                print(f"✅ Re-encrypted doc: {doc.id}")

        except Exception as e:
            print(f"❌ Failed to process doc {doc.id}: {e}")

    # 🧠 Save last rotation timestamp
    config_ref.set({"last_rotation": now})
    print("\n🕐 Updated last_rotation in Firestore")

    print("\n🚨 Update Railway ENV Vars:")
    print("→ ENCRYPTION_PRIVATE_KEY=\n" + new_private_key)
    print("→ ENCRYPTION_PUBLIC_KEY=\n" + new_public_key)
