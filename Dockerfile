FROM migrate/migrate:v4.18.3

WORKDIR /

COPY migrations /migrations
COPY seeds /seeds
COPY scripts/seed.sh /seed.sh

RUN chmod +x /seed.sh