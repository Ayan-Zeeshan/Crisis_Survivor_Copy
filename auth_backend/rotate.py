# rotate.py
# from auth_backend.password_reset.scripts import rotate_key
import os
for root, dirs, files in os.walk("/app"):
    for name in files:
        print(os.path.join(root, name))
# rotate_key.run()