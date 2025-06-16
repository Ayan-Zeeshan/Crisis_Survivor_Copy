# # # FROM python:3.11-slim

# # # ENV PYTHONDONTWRITEBYTECODE 1
# # # ENV PYTHONUNBUFFERED 1

# # # WORKDIR /app

# # # COPY . /app

# # # RUN pip install --upgrade pip
# # # RUN pip install -r requirements.txt 

# # # # Run migrations and then start the server
# # # CMD ["sh", "-c", "python manage.py migrate && python run_waitress.py"]
# # FROM python:3.11-slim

# # ENV PYTHONDONTWRITEBYTECODE 1
# # ENV PYTHONUNBUFFERED 1

# # WORKDIR /app

# # # Install dependencies early (cached unless requirements.txt changes)
# # COPY requirements.txt /app/
# # RUN pip install --upgrade pip && pip install -r requirements.txt

# # # Copy the rest of the app
# # COPY . /app

# # # Add entrypoint
# # COPY entrypoint.sh /app/entrypoint.sh
# # RUN chmod +x entrypoint.sh
# # # RUN python manage.py migrate
# # # RUN python run_waitress.py
# # # CMD ["python", "run_waitress.py"]
# # # RUN /app/entrypoint.sh
# # # CMD ["/bin/bash", "/app/entrypoint.sh"]
# # ENTRYPOINT ["/app/entrypoint.sh"]
# FROM python:3.11-slim

# ENV PYTHONDONTWRITEBYTECODE=1
# ENV PYTHONUNBUFFERED=1

# WORKDIR /app

# COPY requirements.txt /app/
# RUN pip install --upgrade pip && pip install -r requirements.txt

# COPY . /app

# COPY entrypoint.sh /app/entrypoint.sh
# RUN chmod +x /app/entrypoint.sh

# ENTRYPOINT ["/app/entrypoint.sh"]
# FROM python:3.11-slim

# ENV PYTHONDONTWRITEBYTECODE 1
# ENV PYTHONUNBUFFERED 1

# WORKDIR /app

# COPY requirements.txt /app/
# RUN pip install --upgrade pip && pip install -r requirements.txt

# COPY . /app
# COPY entrypoint.sh /app/entrypoint.sh
# RUN chmod +x /app/entrypoint.sh

# # Install curl for sending logs
# RUN apt-get update && apt-get install -y curl && apt-get clean

# # Set Loggly endpoint and token (you can also set these in Railway env vars)
# ENV LOGGLY_ENDPOINT=https://logs.collector.na-01.cloud.solarwinds.com/v1/logs/bulk
# ENV LOGGLY_TOKEN=Rk3Ivo4u7Ya75xwsvJCMApXiinamr6O8LdTFZX7QKq32M5xt1znq_Yft7Cwm327S6I9QHYI

# # Entrypoint handles logging
# RUN /app/entrypoint.sh
# # ENTRYPOINT ["/app/entrypoint.sh"]
# CMD python run_waitress.py 2>&1 | tee /dev/stdout | while read line; do \
#     curl -s --location --request POST "$LOGGLY_ENDPOINT" \
#     --header "Content-Type: application/octet-stream" \
#     --header "Authorization: Bearer $LOGGLY_TOKEN" \
#     --data-raw "$line" > /dev/null; \
#     done
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

COPY . .

RUN apt-get update && apt-get install -y curl

ENV LOGGLY_ENDPOINT=https://logs.collector.na-01.cloud.solarwinds.com/v1/logs/bulk
ENV LOGGLY_TOKEN=Rk3Ivo4u7Ya75xwsvJCMApXiinamr6O8LdTFZX7QKq32M5xt1znq_Yft7Cwm327S6I9QHYI
ENV PORT=8000

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

RUN /app/entrypoint.sh
# ENTRYPOINT ["/app/entrypoint.sh"]
