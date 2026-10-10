# Event Ticketing Database System

A PostgreSQL database and Python program for issuing and cancelling event tickets. Built for the Database Manipulation module of my MSc Data Science at the University of East Anglia (2026).

## What it does

- Stores events, spectators, tickets and cancellations in four linked tables.
- Enforces the booking rules inside the database, so bad data is rejected at the source.
- Reads a queue of transactions from a text file, runs each one, and writes the result or the error to a report.

## Files

| File | What it is |
|---|---|
| [schema.sql](schema.sql) | Tables, constraints, triggers, a view and test data |
| [transactions.sql](transactions.sql) | The transactions run by hand in SQL, including tests that should fail |
| [app.py](app.py) | Python program that processes a transaction queue with psycopg2 |
| [sample_output.txt](sample_output.txt) | Output from a sample run |

## Database design

- **Tables:** `event`, `spectator`, `ticket`, `cancel`
- **Constraints:** primary and foreign keys, a unique rule so a spectator cannot hold two tickets for one event, and CHECK rules on event dates, start times and capacity.
- **Triggers:** two PL/pgSQL triggers stop an event or a spectator being deleted while they still have valid tickets.
- **View:** ticket count per event.

## Transactions supported

The Python program handles 12 transaction types (A to L): add a spectator, add an event, delete a spectator, delete an event, issue a ticket, a travel report, tickets per event, tickets for one event, a spectator's schedule, a ticket's status, cancelled tickets for an event, and clearing all tables.

## How to run

1. Create the database objects: `psql -d postgres -f schema.sql`
2. Install the driver: `pip install psycopg2-binary`
3. Set your database password: `export PGPASSWORD=your_password`
4. Put the transactions in `input.txt`, one per line, with fields separated by `#` (for example `A#100#K Misri#k.misri@uea.ac.uk`).
5. Run `python app.py`. Results are written to `output.txt`.

**Tools:** PostgreSQL, PL/pgSQL, Python, psycopg2

## About

Garapati Nandala Harsha, MSc Data Science, University of East Anglia. [LinkedIn](https://www.linkedin.com/in/garapati-nandala-harsha)
