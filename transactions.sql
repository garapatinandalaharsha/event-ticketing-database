-- =====================================================
-- PART 2 : INTERACTIVE SQL TRANSACTIONS
-- PURPOSE : Execute and test Transactions of Interest
-- NOTE    : Assessment_data.txt must be loaded first
-- =====================================================

-- -------------------------
-- Task A: Insert spectator
-- -------------------------
INSERT INTO spectator (sno, sname, semail)
VALUES (100, 'K Misri', 'k.misri@uea.ac.uk');

SELECT * FROM spectator;

-- -------------------------
-- Task B(i): Insert event
-- -------------------------
INSERT INTO event
VALUES ('A200','200 metres sprint','Stadium 1','2026-08-10','16:00',1000);

SELECT * FROM event;

-- -------------------------
-- Task E(i): Issue ticket
-- -------------------------
INSERT INTO ticket (tno, ecode, sno)
VALUES ((SELECT COALESCE(MAX(tno),0)+1 FROM ticket),'A100',100);

SELECT * FROM ticket;

-- -------------------------
-- Task F: Travel report
-- -------------------------
SELECT e.elocation,
       e.edate,
       COUNT(DISTINCT t.sno) AS total_spectators
FROM event e
JOIN ticket t ON e.ecode = t.ecode
GROUP BY e.elocation, e.edate
ORDER BY e.elocation, e.edate;

-- -------------------------
-- Task G: Tickets per event
-- -------------------------
SELECT e.edesc,
       COUNT(t.tno) AS total_tickets
FROM event e
LEFT JOIN ticket t ON e.ecode = t.ecode
GROUP BY e.edesc
ORDER BY e.edesc;

-- -------------------------
-- Task H: Tickets for event
-- -------------------------
SELECT e.edesc,
       COUNT(t.tno) AS total_tickets
FROM event e
LEFT JOIN ticket t ON e.ecode = t.ecode
WHERE e.ecode = 'A100'
GROUP BY e.edesc;

-- -------------------------
-- Task I: Spectator schedule
-- -------------------------
SELECT s.sname,
       e.edate,
       e.elocation,
       e.etime,
       e.edesc
FROM spectator s
JOIN ticket t ON s.sno = t.sno
JOIN event e ON t.ecode = e.ecode
WHERE s.sno = 200;

-- -------------------------
-- Task J: Ticket status
-- -------------------------
SELECT s.sname,
       t.ecode,
       CASE
            WHEN c.tno IS NULL THEN 'VALID'
            ELSE 'CANCELLED'
       END AS status
FROM ticket t
JOIN spectator s ON t.sno = s.sno
LEFT JOIN cancel c ON t.tno = c.tno
WHERE t.tno = 20;
-- -------------------------
-- Task K: Cancelled tickets
-- -------------------------
SELECT * FROM cancel WHERE ecode = 'A100';

-- -------------------------
-- Task D: Delete event (fail)
-- -------------------------
DELETE FROM event WHERE ecode = 'A100';

-- -------------------------
-- Task C: Delete spectator
-- -------------------------
DELETE FROM spectator WHERE sno = 300;
DELETE FROM spectator WHERE sno = 400;

-- -------------------------
-- Constraint testing
-- -------------------------
INSERT INTO ticket VALUES ((SELECT COALESCE(MAX(tno),0)+1 FROM ticket),'JUDO',400);
INSERT INTO event VALUES ('A400','400 metres sprint','Stadium 1','2026-07-12','10:00',1000);
INSERT INTO event VALUES ('A900','900 metres sprint','Stadium 1','2023-07-12','10:00',1000);
INSERT INTO ticket VALUES ((SELECT COALESCE(MAX(tno),0)+1 FROM ticket),'AXXX',100);
INSERT INTO ticket VALUES ((SELECT COALESCE(MAX(tno),0)+1 FROM ticket),'A400',900);
