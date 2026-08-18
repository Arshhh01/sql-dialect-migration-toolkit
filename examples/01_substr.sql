-- Pattern: SUBSTR -> SUBSTRING
-- Extract the 4-character region code embedded in donor_code, e.g. 'NE01-88213'.

-- ── Teradata ──────────────────────────────────────────────────────────────
SELECT
    donor_id,
    SUBSTR(donor_code, 1, 4) AS region_code
FROM mkt.donor;

-- ── Redshift ──────────────────────────────────────────────────────────────
-- Redshift *does* support SUBSTR, but the standard-SQL SUBSTRING(... FROM ... FOR ...)
-- form is preferred here: it's unambiguous about start-vs-length argument order,
-- which is the single most common transcription error when a large query set is
-- ported by hand or with a naive find/replace.
SELECT
    donor_id,
    SUBSTRING(donor_code FROM 1 FOR 4) AS region_code
FROM mkt.donor;
