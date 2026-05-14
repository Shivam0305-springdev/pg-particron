FROM postgres:15-bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    postgresql-15-cron \
    postgresql-15-partman \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN echo "shared_preload_libraries='pg_cron'" >> /usr/share/postgresql/postgresql.conf.sample

COPY setup-extensions.sh /docker-entrypoint-initdb.d/
RUN chmod +x /docker-entrypoint-initdb.d/setup-extensions.sh
