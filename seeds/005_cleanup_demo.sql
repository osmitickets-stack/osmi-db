DELETE FROM ticketing.ticket_types
WHERE event_id IN (
    SELECT id
    FROM ticketing.events
    WHERE slug='osmi-festival-inauguracion'
);

DELETE FROM ticketing.events
WHERE slug='osmi-festival-inauguracion';