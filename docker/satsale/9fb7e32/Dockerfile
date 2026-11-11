FROM python:3.11-slim

ADD https://github.com/SatSale/SatSale/archive/9fb7e32fb087d551ccc7cdc660a9a3984ac08c0e.tar.gz /tmp/satsale.tar.gz
RUN mkdir /app && tar -xzf /tmp/satsale.tar.gz --strip-components=1 -C /app \
    && rm /tmp/satsale.tar.gz \
    && pip install --no-cache-dir -r /app/requirements.txt \
    && rm -rf /app/static/qr_codes \
    && ln -s /data/qr_codes /app/static/qr_codes \
    && ln -s /data/database.db /app/database.db

WORKDIR /app
ENV PYTHONDONTWRITEBYTECODE=1
