# # set -e
# # echo "🚀 Entrypoint: Starting the app..."
# # echo "Applying database migrations..."
# # python manage.py migrate    

# # echo "Starting server with waitress..."
# # python run_waitress.py
# #!/bin/bash
# set -e

# echo "🚀 Entrypoint: Starting the app..."
# echo "📦 Env Var Preview (first 10 chars): ${FIREBASE_CREDENTIAL_BASE64:0:10}"

# if [ -z "$FIREBASE_CREDENTIAL_BASE64" ]; then
#   echo "❌ FIREBASE_CREDENTIAL_BASE64 is not set"
#   exit 1
# fi

# echo "✅ FIREBASE_CREDENTIAL_BASE64 exists"

# echo "🗃️ Applying database migrations..."
# python manage.py migrate

# echo "🚀 Starting server with waitress..."
# python run_waitress.py
#!/bin/bash
set -e

echo "🧪 Checking Firebase env..."
if [ -z "$FIREBASE_CREDENTIAL_BASE64" ]; then
  echo "❌ Env not set. Exiting..."
  exit 1
fi

echo "📦 Running migrations..."
python manage.py migrate

echo "🚀 Starting server..."
exec python run_waitress.py
