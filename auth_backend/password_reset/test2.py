# from cryptography.hazmat.primitives.asymmetric import ec
# from cryptography.hazmat.primitives import serialization, hashes
# from cryptography.hazmat.primitives.kdf.hkdf import HKDF
# from cryptography.hazmat.primitives.ciphers.aead import AESGCM
# import base64
# import json

# def hybrid_decrypt(private_key_pem: str, encrypted_obj: dict) -> dict:
#     # Load ECC private key
#     private_key = serialization.load_pem_private_key(
#         private_key_pem.encode(), password=None
#     )

#     # Decode ECC-encrypted AES key
#     ephemeral_public_key_bytes = base64.b64decode(encrypted_obj['ephemeral_key'])
#     aes_nonce = base64.b64decode(encrypted_obj['nonce'])
#     aes_ciphertext = base64.b64decode(encrypted_obj['ciphertext'])

#     ephemeral_public_key = serialization.load_der_public_key(ephemeral_public_key_bytes)
#     shared_key = private_key.exchange(ec.ECDH(), ephemeral_public_key)

#     derived_aes_key = HKDF(
#         algorithm=hashes.SHA256(),
#         length=32,
#         salt=None,
#         info=b'hybrid-ecdh-aes',
#     ).derive(shared_key)

#     aesgcm = AESGCM(derived_aes_key)
#     decrypted = aesgcm.decrypt(aes_nonce, aes_ciphertext, None)

#     return json.loads(decrypted.decode())

# # Example usage:
# # decrypted = hybrid_decrypt(YOUR_PRIVATE_KEY_PEM_STRING, your_encrypted_dict)
# # print(decrypted)
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives import serialization, hashes
from cryptography.hazmat.primitives.kdf.hkdf import HKDF
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
import base64
import json
import traceback


def hybrid_decrypt(private_key_pem: str, encrypted_obj: dict) -> dict:
    try:
        private_key = serialization.load_pem_private_key(
            private_key_pem.encode(), password=None
        )

        ephemeral_public_key_bytes = base64.b64decode(encrypted_obj['ephemeral_key'])
        aes_nonce = base64.b64decode(encrypted_obj['nonce'])
        aes_ciphertext = base64.b64decode(encrypted_obj['ciphertext'])

        ephemeral_public_key = serialization.load_der_public_key(ephemeral_public_key_bytes)
        shared_key = private_key.exchange(ec.ECDH(), ephemeral_public_key)

        derived_aes_key = HKDF(
            algorithm=hashes.SHA256(),
            length=32,
            salt=None,
            info=b'hybrid-ecdh-aes',
        ).derive(shared_key)

        aesgcm = AESGCM(derived_aes_key)
        decrypted = aesgcm.decrypt(aes_nonce, aes_ciphertext, None)

        return json.loads(decrypted.decode())

    except Exception as e:
        print(f"❌ Failed to decrypt field: {e}")
        return None  # returning None to signal decryption failure


def decrypt_json_file(input_file: str, output_file: str, private_key_pem: str):
    with open(input_file, 'r') as f:
        original_data = json.load(f)

    decrypted_data = {}

    for doc_id, fields in original_data.items():
        decrypted_fields = {}
        for key, value in fields.items():
            if value is None:
                decrypted_fields[key] = None  # Keep nulls untouched
            elif isinstance(value, dict) and all(k in value for k in ['ephemeral_key', 'nonce', 'ciphertext']):
                result = hybrid_decrypt(private_key_pem, value)
                if result:
                    decrypted_fields[key] = list(result.values())[0]  # unwrap decrypted dict
                else:
                    decrypted_fields[key] = value  # leave original encrypted value
            else:
                decrypted_fields[key] = value  # already plain

        decrypted_data[doc_id] = decrypted_fields

    with open(output_file, 'w') as f:
        json.dump(decrypted_data, f, indent=2)

    print(f"✅ Decrypted data saved to {output_file}")


# Example usage:
# Paste your ECC private key below (use multiline string if needed)
PRIVATE_KEY_PEM = """-----BEGIN EC PRIVATE KEY-----
...
-----END EC PRIVATE KEY-----"""

decrypt_json_file("users.json", "users_decrypted.json", PRIVATE_KEY_PEM)
