import subprocess
import os
import signal

def is_gunicorn_running():
    """Check if a gunicorn process is already running."""
    try:
        # `pgrep` will return 0 if the process is found
        subprocess.run(["pgrep", "-f", "gunicorn"], check=True, stdout=subprocess.DEVNULL)
        return True
    except subprocess.CalledProcessError:
        return False

def start_gunicorn():
    """Start gunicorn if not running."""
    print("Gunicorn not running. Starting it...")
    subprocess.Popen([
        "/app/venv/bin/gunicorn",
        "auth_backend.wsgi:application",
        "--bind", "0.0.0.0:8000"
    ])
    print("Gunicorn started!")

def main():
    if is_gunicorn_running():
        print("Gunicorn is already running. ✅")
    else:
        start_gunicorn()

if __name__ == "__main__":
    main()
