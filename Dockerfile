FROM python:3.12-slim
LABEL maintainer="PouyaKhajaviDev"

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./festival_app /app
COPY ./entrypoint.sh /app/entrypoint.sh

WORKDIR /app
EXPOSE 8000


RUN apt-get update && \
    apt-get install -y sqlite3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --upgrade pip && \
    pip install -r /tmp/requirements.txt && \
    chmod +x /app/entrypoint.sh && \
    rm -f /tmp/requirements.txt

ENTRYPOINT ["sh", "/app/entrypoint.sh"]