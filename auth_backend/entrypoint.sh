# # # # # set -e
# # # # # echo "🚀 Entrypoint: Starting the app..."
# # # # # echo "Applying database migrations..."
# # # # # python manage.py migrate    

# # # # # echo "Starting server with waitress..."
# # # # # python run_w          aitress.py
# # # # #!/bin/bash
# # # # set -e

# # # # echo "🚀 Entrypoint: Starting the app..."
# # # # echo "📦 Env Var Preview (first 10 chars): ${FIREBASE_CREDENTIAL_BASE64:0:10}"

# # # # if [ -z "$FIREBASE_CREDENTIAL_BASE64" ]; then
# # # #   echo "❌ FIREBASE_CREDENTIAL_BASE64 is not set"
# # # #   exit 1
# # # # fi

# # # # echo "✅ FIREBASE_CREDENTIAL_BASE64 exists"

# # # # echo "🗃️ Applying database migrations..."
# # # # python manage.py migrate

# # # # echo "🚀 Starting server with waitress..."
# # # # python run_waitress.py
# # # #!/bin/bash
# # # set -e

# # # # echo "🧪 Checking Firebase env..."
# # # # if [ -z "$FIREBASE_CREDENTIAL" ]; then
# # # #   echo "❌ Env not set. Exiting..."
# # # #   exit 1
# # # # fi

# # # echo "📦 Running migrations..."
# # # python manage.py migrate

# # # echo "🚀 Starting server..."
# # # exec python run_waitress.py

# # # sleep 3
# # # tail -f server.log
# # #!/bin/bash
# # set -e

# # echo "📦 Running migrations..."
# # python manage.py migrate

# # echo "🚀 Starting server..."
# # exec python run_waitress.py
# #!/bin/bash
# # set -e

# # log() {
# #     echo -e "$1"
# #     curl -s --location --request POST "$LOGGLY_ENDPOINT" \
# #         --header "Content-Type: application/octet-stream" \
# #         --header "Authorization: Bearer $LOGGLY_TOKEN" \
# #         --data-raw "$1" > /dev/null
# # }

# # log "🚀 ENTRYPOINT STARTED"
# # log "📦 Applying database migrations..."
# # python manage.py migrate || {
# #     log "❌ Migration failed."
# #     exit 1
# # }

# # log "✅ Migrations complete. Starting server..."
# # exec python run_waitress.py

# #!/bin/bash
# set -e

# log() {
#     echo -e "$1"  
#     curl -s --location --request POST "$LOGGLY_ENDPOINT" \
#         --header "Content-Type: application/octet-stream" \
#         --header "Authorization: Bearer $LOGGLY_TOKEN" \
#         --data-raw "$1" > /dev/null
# }

# log "🚀 ENTRYPOINT STARTED"
# log "📦 Running Django migrations..."
# python manage.py migrate

# log "✅ Starting Django app on 0.0.0.0:8000"
# exec gunicorn auth_backend.wsgi:application --bind 0.0.0.0:8000 --timeout 120
#!/bin/bash
# set -e

# log() {
#     echo -e "$1"  
#     curl -s --location --request POST "$LOGGLY_ENDPOINT" \
#         --header "Content-Type: application/octet-stream" \
#         --header "Authorization: Bearer $LOGGLY_TOKEN" \
#         --data-raw "$1" > /dev/null
# }

# log "🚀 ENTRYPOINT STARTED"
# log "📦 Running Django migrations..."
# python manage.py migrate || {
#     log "❌ Migration failed."
#     exit 1
# }

# log "✅ Starting Django app on 0.0.0.0:8000"
# exec gunicorn auth_backend.wsgi:application --bind 0.0.0.0:8000 --timeout 120

#!/bin/bash
set -e

log() {
  echo -e "$1"
  curl -s --location --request POST "$LOGGLY_ENDPOINT" \
    --header "Content-Type: application/octet-stream" \
    --header "Authorization: Bearer $LOGGLY_TOKEN" \
    --data-raw "$1" > /dev/null
}

log "🚀 Starting key rotation script..."
python key_rotation.py || log "❌ Key rotation failed"

log "📦 Running Django migrations..."
python manage.py migrate || log "❌ Migration failed"

log "✅ Starting Django app on 0.0.0.0:8000"
exec gunicorn auth_backend.wsgi:application --bind 0.0.0.0:8000 --timeout 120
