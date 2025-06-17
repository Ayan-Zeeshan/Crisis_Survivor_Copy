# password_reset/management/commands/rotatekeys.py

from django.core.management.base import BaseCommand
from password_reset.firebase import db  # now works without path hacks
from password_reset.utils.encryption import generate_ecc_keys, hybrid_encrypt, hybrid_decrypt

class Command(BaseCommand):
    help = "Deploys the main Django Project!"

    def handle(self, *args, **kwargs):
        from auth_backend import run_waitress
        run_waitress.run()
        self.stdout.write(self.style.SUCCESS("Started deployment successfully!"))
