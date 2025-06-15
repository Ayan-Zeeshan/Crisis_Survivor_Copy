import os
import base64
import json
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives.kdf.hkdf import HKDF
from cryptography.hazmat.primitives import hashes, serialization
from dotenv import load_dotenv

load_dotenv()  # Loads .env variables for testing

def generate_ecc_keys():
    private_key = ec.generate_private_key(ec.SECP256R1())
    public_key = private_key.public_key()

    private_bytes = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    )
    public_bytes = public_key.public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )

    return private_bytes.decode(), public_bytes.decode()

def hybrid_encrypt(public_key_pem, plaintext_dict):
    public_key = serialization.load_pem_public_key(public_key_pem.encode())

    ephemeral_key = ec.generate_private_key(ec.SECP256R1())
    shared_secret = ephemeral_key.exchange(ec.ECDH(), public_key)

    aes_key = HKDF(
        algorithm=hashes.SHA256(), length=32, salt=None, info=b'hybrid-enc'
    ).derive(shared_secret)

    aesgcm = AESGCM(aes_key)
    nonce = os.urandom(12)
    plaintext = json.dumps(plaintext_dict).encode()
    ciphertext = aesgcm.encrypt(nonce, plaintext, None)

    return {
        'ciphertext': base64.b64encode(ciphertext).decode(),
        'nonce': base64.b64encode(nonce).decode(),
        'ephemeral_public_key': base64.b64encode(
            ephemeral_key.public_key().public_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PublicFormat.SubjectPublicKeyInfo
            )
        ).decode()
    }

def hybrid_decrypt(private_key_pem, encrypted_payload):
    # Fix in rotate_key.py: don't call encode() on an already-bytes key
    if isinstance(private_key_pem, str):
        private_key_pem = private_key_pem.encode()

    private_key = serialization.load_pem_private_key(private_key_pem, password=None)
    ephemeral_public_key = serialization.load_pem_public_key(
        base64.b64decode(encrypted_payload['ephemeral_public_key'])
    )

    shared_secret = private_key.exchange(ec.ECDH(), ephemeral_public_key)
    aes_key = HKDF(
        algorithm=hashes.SHA256(), length=32, salt=None, info=b'hybrid-enc'
    ).derive(shared_secret)

    aesgcm = AESGCM(aes_key)
    nonce = base64.b64decode(encrypted_payload['nonce'])
    ciphertext = base64.b64decode(encrypted_payload['ciphertext'])

    plaintext = aesgcm.decrypt(nonce, ciphertext, None)
    return json.loads(plaintext)

def fix_pem_format(pem_str):
    return pem_str.replace('\\n', '\n') if pem_str else None

if __name__ == "__main__":
    print("🔐 Running encryption test using Railway env vars...\n")

    private_key_env = os.getenv("ENCRYPTION_PRIVATE_KEY", "placeholder")
    public_key_env = os.getenv("ENCRYPTION_PUBLIC_KEY", "placeholder")

    if "placeholder" in [private_key_env, public_key_env]:
        print("⚠️ One or both keys are still 'placeholder'. Add real keys to test actual encryption.")
    else:
        try:
            private_key_fixed = fix_pem_format(private_key_env)
            public_key_fixed = fix_pem_format(public_key_env)

            print("✅ Retrieved keys from env!")

            sample_data = {"email": "ayan@utech.edu"}
            print(f"\n📤 Original data: {sample_data}")

            encrypted = hybrid_encrypt(public_key_fixed, sample_data)
            print(f"\n🔐 Encrypted: {json.dumps(encrypted, indent=2)}")

            decrypted = hybrid_decrypt(private_key_fixed, encrypted)
            print(f"\n🔓 Decrypted: {decrypted}")

        except Exception as e:
            print(f"❌ Exception during encryption test: {e}")
