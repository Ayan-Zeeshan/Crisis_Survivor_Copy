FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

COPY . /app

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Run migrations and then start the server
CMD ["sh", "-c", "python manage.py makemigrations && python manage.py migrate && python run_waitress.py && python manage.py runscript rotate_key"]
