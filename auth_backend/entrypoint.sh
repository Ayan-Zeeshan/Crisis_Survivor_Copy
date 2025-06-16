set -e
echo "🚀 Entrypoint: Starting the app..."
# echo "Applying database migrations..."
python manage.py runserver

# echo "Starting server with waitress..."
# python run_waitress.py