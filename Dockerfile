FROM migrate/migrate:v4.18.3

COPY migrations /migrations
COPY seeds /seeds

ENTRYPOINT ["migrate"]