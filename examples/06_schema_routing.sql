-- Pattern: unqualified table names relying on default-database context
--
-- Teradata resolves an unqualified table name against the session's default
-- database. Redshift has no equivalent implicit resolution — an unqualified name
-- either errors, or worse, silently resolves against `search_path` and hits a
-- same-named table in the wrong schema.

-- ── Teradata (relies on session default database = mkt) ─────────────────
SELECT donor_id, gift_amount
FROM gift
WHERE campaign_id = 4001;

-- ── Redshift ──────────────────────────────────────────────────────────────
-- Always fully qualify. This also makes the query safe to run from any client
-- or scheduler regardless of what search_path happens to be set to.
SELECT donor_id, gift_amount
FROM mkt.gift
WHERE campaign_id = 4001;
