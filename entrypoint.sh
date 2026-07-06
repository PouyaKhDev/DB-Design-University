#!/bin/sh
echo "Ensuring database directory exists..."
mkdir -p /app/data

echo "Applying database migrations (django defaults)..."
python manage.py migrate --noinput

echo "Creating database schema and adding sample data..."
sqlite3 /app/data/db.sqlite3 < /app/db_init/schema.sql

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Starting Gunicorn..."
exec gunicorn core.wsgi:application \
    --bind 0.0.0.0:8000 \
    --workers 1 \
    --timeout 120


