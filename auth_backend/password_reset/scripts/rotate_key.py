# import os
# from dotenv import load_dotenv
# import firebase_admin
# from firebase_admin import credentials, initialize_app, firestore
# from password_reset.utils.encryption import generate_ecc_keys, hybrid_decrypt, hybrid_encrypt

# # ✅ Load Railway env vars
# load_dotenv()

# # ✅ Initialize Firebase Admin SDK (if not already initialized)
# if not firebase_admin._apps:
#     cred = credentials.Certificate({
#         "type": "service_account",
#         "project_id": os.getenv("FIREBASE_PROJECT_ID"),
#         "private_key_id": os.getenv("FIREBASE_PRIVATE_KEY_ID"),
#         "private_key": os.getenv("FIREBASE_PRIVATE_KEY").replace('\\n', '\n'),
#         "client_email": os.getenv("FIREBASE_CLIENT_EMAIL"),
#         "client_id": os.getenv("FIREBASE_CLIENT_ID"),
#         "auth_uri": "https://accounts.google.com/o/oauth2/auth",
#         "token_uri": "https://oauth2.googleapis.com/token",
#         "auth_provider_x509_cert_url": "https://www.googleapis.com/v1/certs",
#         "client_x509_cert_url": os.getenv("FIREBASE_CLIENT_CERT_URL")
#     })
#     initialize_app(cred)

# # ✅ Firestore DB
# db = firestore.client()

# # ✅ Load old keys from Railway ENV
# old_private_key = os.getenv("ENCRYPTION_PRIVATE_KEY")
# old_public_key = os.getenv("ENCRYPTION_PUBLIC_KEY")

# # ✅ Generate new ECC keypair
# new_private_key, new_public_key = generate_ecc_keys()

# # ✅ Rotate Firestore 'users' documents
# docs = db.collection("users").stream()

# print("🔁 Rotating keys for all documents...")
# for doc in docs:
#     try:
#         doc_data = doc.to_dict()

#         # 🔓 Attempt decryption
#         try:
#             decrypted = hybrid_decrypt(old_private_key, doc_data)
#         except Exception as decrypt_error:
#             print(f"❌ Could not decrypt doc {doc.id}: {decrypt_error}")
#             continue

#         # 🔐 Encrypt with new key
#         re_encrypted = hybrid_encrypt(new_public_key, decrypted)

#         # ✅ Save updated doc
#         doc.reference.set(re_encrypted)
#         print(f"✅ Re-encrypted doc: {doc.id}")
#     except Exception as e:
#         print(f"❌ Failed to rotate doc {doc.id}: {e}")

# # ✅ Print new keys for Railway ENV manual update
# print("\n🚨 Update Railway ENV Vars:")
# print("→ ENCRYPTION_PRIVATE_KEY=\n" + new_private_key)
# print("→ ENCRYPTION_PUBLIC_KEY=\n" + new_public_key)
# password_reset/scripts/rotate_key.py

def run():
    import os
    from dotenv import load_dotenv
    import firebase_admin
    from firebase_admin import credentials, firestore
    from password_reset.firebase import db
    from password_reset.utils.encryption import generate_ecc_keys, hybrid_encrypt, hybrid_decrypt

    load_dotenv()

    # if not firebase_admin._apps:
    #     cred = credentials.Certificate({
    #         "type": "service_account",
    #         "project_id": os.getenv("FIREBASE_PROJECT_ID"),
    #         "private_key_id": os.getenv("FIREBASE_PRIVATE_KEY_ID"),
    #         "private_key": os.getenv("FIREBASE_PRIVATE_KEY").replace('\\n', '\n'),
    #         "client_email": os.getenv("FIREBASE_CLIENT_EMAIL"),
    #         "client_id": os.getenv("FIREBASE_CLIENT_ID"),
    #         "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    #         "token_uri": "https://oauth2.googleapis.com/token",
    #         "auth_provider_x509_cert_url": "https://www.googleapis.com/v1/certs",
    #         "client_x509_cert_url": os.getenv("FIREBASE_CLIENT_CERT_URL")
    #     })
    #     firebase_admin.initialize_app(cred)

    # db = firestore.client()

    old_private_key = os.getenv("ENCRYPTION_PRIVATE_KEY")
    old_public_key = os.getenv("ENCRYPTION_PUBLIC_KEY")

    new_private_key, new_public_key = generate_ecc_keys()

    print("🔁 Rotating keys for all documents...")
    docs = db.collection("users").stream()
    for doc in docs:
        try:
            doc_data = doc.to_dict()
            try:
                decrypted = hybrid_decrypt(old_private_key, doc_data)
            except Exception as decrypt_error:
                print(f"❌ Could not decrypt doc {doc.id}: {decrypt_error}")
                continue

            re_encrypted = hybrid_encrypt(new_public_key, decrypted)
            doc.reference.set(re_encrypted)
            print(f"✅ Re-encrypted doc: {doc.id}")
        except Exception as e:
            print(f"❌ Failed to rotate doc {doc.id}: {e}")

    print("\n🚨 Update Railway ENV Vars:")
    print("→ ENCRYPTION_PRIVATE_KEY=\n" + new_private_key)
    print("→ ENCRYPTION_PUBLIC_KEY=\n" + new_public_key)
