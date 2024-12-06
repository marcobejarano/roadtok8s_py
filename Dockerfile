# Build Stage
FROM python:3.13.0-alpine3.20 AS builder
WORKDIR /app

COPY ./requirements.txt .
RUN apk add --no-cache \
        build-base \
        python3-dev \
        libffi-dev \
        openssl-dev && \
    python3 -m venv /opt/venv && \
    /opt/venv/bin/python -m pip install --upgrade pip && \
    /opt/venv/bin/python -m pip install -r requirements.txt

COPY ./src/ ./src
COPY ./conf/entrypoint.sh .

# Final Stage
FROM python:3.13.0-alpine3.20
WORKDIR /app

COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app /app

# Install redis package (includes both Redis server and redis-cli)
RUN apk add --no-cache redis && \
    chmod +x /app/entrypoint.sh

EXPOSE 8080

CMD [ "sh", "./entrypoint.sh" ]
