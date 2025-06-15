def run():
    import os
    from dotenv import load_dotenv
    from password_reset.firebase import db
    from password_reset.utils.encryption import generate_ecc_keys, hybrid_encrypt, hybrid_decrypt

    load_dotenv()

    old_private_key = os.getenv("ENCRYPTION_PRIVATE_KEY")
    old_public_key = os.getenv("ENCRYPTION_PUBLIC_KEY")

    is_first_time = old_private_key is None or old_public_key is None

    if is_first_time:
        print("🆕 No encryption keys found. Encrypting all documents for the first time...")
    else:
        print("🔁 Rotating keys for all documents...")

    # Generate new keypair
    new_private_key, new_public_key = generate_ecc_keys()

    docs = db.collection("users").stream()

    for doc in docs:
        try:
            doc_data = doc.to_dict()

            if is_first_time:
                # First-time encryption
                encrypted = hybrid_encrypt(new_public_key, doc_data)
                doc.reference.set(encrypted)
                print(f"✅ Encrypted doc for first time: {doc.id}")
            else:
                # Decrypt with old key
                try:
                    decrypted = hybrid_decrypt(old_private_key, doc_data)
                except Exception as decrypt_error:
                    print(f"❌ Could not decrypt doc {doc.id}: {decrypt_error}")
                    continue

                # Re-encrypt with new key
                re_encrypted = hybrid_encrypt(new_public_key, decrypted)
                doc.reference.set(re_encrypted)
                print(f"✅ Re-encrypted doc: {doc.id}")

        except Exception as e:
            print(f"❌ Failed to process doc {doc.id}: {e}")

    print("\n🚨 Update Railway ENV Vars:")
    print("→ ENCRYPTION_PRIVATE_KEY=\n" + new_private_key)
    print("→ ENCRYPTION_PUBLIC_KEY=\n" + new_public_key)
