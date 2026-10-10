# =====================================================
# PART 3 : PYTHON APPLICATION PROGRAM
# MODULE : CMP-7025A Database Manipulation
# PURPOSE : Process transaction queue using psycopg2
# =====================================================

import os
import psycopg2

def process_transaction(cursor, line, outfile):
    parts = line.strip().split('#')
    task = parts[0]

    try:
        if task == 'A':
            cursor.execute(
                "INSERT INTO spectator VALUES (%s,%s,%s)",
                (int(parts[1]), parts[2], parts[3])
            )
            outfile.write("A: Spectator inserted successfully\n")

        elif task == 'B':
            cursor.execute(
                "INSERT INTO event VALUES (%s,%s,%s,%s,%s,%s)",
                (parts[1], parts[2], parts[3], parts[4], parts[5], int(parts[6]))
            )
            outfile.write("B: Event inserted successfully\n")

        elif task == 'C':
            cursor.execute("DELETE FROM spectator WHERE sno = %s", (int(parts[1]),))
            outfile.write("C: Spectator deleted\n")

        elif task == 'D':
            cursor.execute("DELETE FROM event WHERE ecode = %s", (parts[1],))
            outfile.write("D: Event deleted\n")

        elif task == 'E':
            cursor.execute(
                "INSERT INTO ticket VALUES ((SELECT COALESCE(MAX(tno),0)+1 FROM ticket), %s, %s)",
                (parts[1], int(parts[2]))
            )
            outfile.write("E: Ticket issued\n")

        elif task == 'F':
            cursor.execute("""
                 SELECT elocation, edate, COUNT(DISTINCT sno)
                 FROM event e JOIN ticket t ON e.ecode = t.ecode
                 GROUP BY elocation, edate
            """)
            outfile.write("F: Travel Report\n")
            for r in cursor.fetchall():
                 outfile.write(str(r) + "\n")

        elif task == 'G':
            cursor.execute("""
                 SELECT edesc, COUNT(tno)
                 FROM event e LEFT JOIN ticket t ON e.ecode = t.ecode
                 GROUP BY edesc
                 ORDER BY edesc
            """)
            outfile.write("G: Ticket Count per Event\n")
            for r in cursor.fetchall():
                 outfile.write(str(r) + "\n")

        elif task == 'H':
            cursor.execute("""
                SELECT edesc, COUNT(tno)
                FROM event e LEFT JOIN ticket t ON e.ecode = t.ecode
                WHERE e.ecode = %s
                GROUP BY edesc
            """, (parts[1],))
            outfile.write("H: Tickets for Event\n")
            for r in cursor.fetchall():
                outfile.write(str(r) + "\n")

        elif task == 'I':
            cursor.execute("""
                SELECT sname, edate, elocation, etime, edesc
                FROM spectator s
                JOIN ticket t ON s.sno = t.sno
                JOIN event e ON t.ecode = e.ecode
                WHERE s.sno = %s
            """, (int(parts[1]),))
            outfile.write("I: Spectator Schedule\n")
            for r in cursor.fetchall():
                outfile.write(str(r) + "\n")

        elif task == 'J':
            cursor.execute("""
                SELECT sname, t.ecode,
                CASE WHEN c.tno IS NULL THEN 'VALID' ELSE 'CANCELLED' END
                FROM ticket t
                JOIN spectator s ON t.sno = s.sno
                LEFT JOIN cancel c ON t.tno = c.tno
                WHERE t.tno = %s
            """, (int(parts[1]),))
            outfile.write("J: Ticket Status\n")
            for r in cursor.fetchall():
                outfile.write(str(r) + "\n")

        elif task == 'K':
            cursor.execute("SELECT * FROM cancel WHERE ecode = %s", (parts[1],))
            outfile.write("K: Cancelled Tickets\n")
            for r in cursor.fetchall():
                outfile.write(str(r) + "\n")

        elif task == 'L':
            cursor.execute("DELETE FROM cancel")
            cursor.execute("DELETE FROM ticket")
            cursor.execute("DELETE FROM spectator")
            cursor.execute("DELETE FROM event")
            outfile.write("L: All tables cleared\n")

    except Exception as e:
        outfile.write(f"ERROR ({task}): {str(e)}\n")



def main():
    conn = psycopg2.connect(
        dbname="postgres",
        user="postgres",
        password=os.environ.get("PGPASSWORD", ""),
        host="localhost",
        port="5432"
    )
    cursor = conn.cursor()

    infile = open("input.txt", "r")
    outfile = open("output.txt", "w")

    for line in infile:
        process_transaction(cursor, line, outfile)
        conn.commit()

    infile.close()
    outfile.close()
    cursor.close()
    conn.close()



if __name__ == "__main__":
    main()
