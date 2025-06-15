# password_reset/management/commands/rotatekeys.py

from django.core.management.base import BaseCommand
from password_reset.firebase import db  # now works without path hacks
from password_reset.utils.encryption import generate_ecc_keys, hybrid_encrypt, hybrid_decrypt

class Command(BaseCommand):
    help = "Rotates encryption keys and re-encrypts Firestore data"

    def handle(self, *args, **kwargs):
        from password_reset.scripts import rotate_key_test
        rotate_key_test.run()
        self.stdout.write(self.style.SUCCESS("Encryption keys rotated successfully!"))
