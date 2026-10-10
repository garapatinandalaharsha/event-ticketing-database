-- =====================================================
-- PART 1 : DATABASE DEFINITION AND TEST DATA
-- MODULE : CMP-7025A Database Manipulation
-- PURPOSE : Define schema, constraints, triggers, views,
--           and insert own test data for validation
-- =====================================================

-- =========================
-- TABLE: event
-- =========================
CREATE TABLE event (
    ecode CHAR(4) PRIMARY KEY,
    edesc VARCHAR(20) NOT NULL,
    elocation VARCHAR(20) NOT NULL,
    edate DATE NOT NULL
        CHECK (edate BETWEEN DATE '2026-07-01' AND DATE '2026-07-31'),
    etime TIME NOT NULL
        CHECK (etime >= TIME '09:00'),
    emax SMALLINT NOT NULL
        CHECK (emax BETWEEN 1 AND 1000)
);

-- =========================
-- TABLE: spectator
-- =========================
CREATE TABLE spectator (
    sno INTEGER PRIMARY KEY,
    sname VARCHAR(20) NOT NULL,
    semail VARCHAR(20) UNIQUE NOT NULL
);

-- =========================
-- TABLE: ticket
-- =========================
CREATE TABLE ticket (
    tno INTEGER PRIMARY KEY,
    ecode CHAR(4) REFERENCES event(ecode),
    sno INTEGER REFERENCES spectator(sno),
    CONSTRAINT uq_ticket UNIQUE (ecode, sno)
);

-- =========================
-- TABLE: cancel
-- =========================
CREATE TABLE cancel (
    tno INTEGER PRIMARY KEY REFERENCES ticket(tno),
    ecode CHAR(4),
    sno INTEGER,
    cdate TIMESTAMP NOT NULL,
    cuser VARCHAR(128) NOT NULL
);

-- =====================================================
-- FUNCTION & TRIGGER:
-- Prevent deletion of spectator with valid tickets
-- =====================================================
CREATE OR REPLACE FUNCTION prevent_spectator_delete()
RETURNS TRIGGER AS $$
BEGIN
     IF EXISTS (
         SELECT 1
         FROM ticket t
         WHERE t.sno = OLD.sno
            AND NOT EXISTS (
                SELECT 1 FROM cancel c WHERE c.tno = t.tno
            )
     ) THEN
         RAISE EXCEPTION 'Spectator has valid tickets';
     END IF;
     RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_spectator_delete
BEFORE DELETE ON spectator
FOR EACH ROW
EXECUTE FUNCTION prevent_spectator_delete();

-- =====================================================
-- FUNCTION & TRIGGER:
-- Prevent deletion of event with valid tickets
-- =====================================================
CREATE OR REPLACE FUNCTION prevent_event_delete()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ticket t
        WHERE t.ecode = OLD.ecode
           AND NOT EXISTS (
               SELECT 1 FROM cancel c WHERE c.tno = t.tno
           )
    ) THEN
        RAISE EXCEPTION 'Event has valid tickets';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_event_delete
BEFORE DELETE ON event
FOR EACH ROW
EXECUTE FUNCTION prevent_event_delete();

-- =========================
-- VIEW: Ticket count per event
-- =========================
CREATE VIEW vw_ticket_count_per_event AS
SELECT e.ecode,
       e.edesc,
       COUNT(t.tno) AS total_tickets
FROM event e
LEFT JOIN ticket t ON e.ecode = t.ecode
GROUP BY e.ecode, e.edesc;

-- =========================
-- OWN TEST DATA FOR PART 1
-- =========================

-- Events
INSERT INTO event VALUES
('A100','100 metres sprint','Stadium 1','2026-07-12','16:00',1000),
('JUDO','Judo','Arena 2','2026-07-12','10:00',3);

-- Spectators
INSERT INTO spectator VALUES
(100,'J Chin','j.chin@uea.ac.uk'),
(200,'W Wang','whw@somewhere.net');

-- Tickets
INSERT INTO ticket VALUES
(1,'A100',100),
(2,'JUDO',200);
