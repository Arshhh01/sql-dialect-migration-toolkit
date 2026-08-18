-- Pattern: case-sensitivity / collation mismatch on join keys
--
-- Symptom in production: a join that returned the expected row counts in Teradata
-- silently drops rows in Redshift after migration — no error, just a lower number
-- on a dashboard. Root cause: donor_code is stored as 'NE01-88213' in one system and
-- 'ne01-88213' in another. Teradata's default collation is case-insensitive; Redshift
-- is case-sensitive by default, so the two no longer match.

-- ── Teradata (worked by accident, relying on default case-insensitive collation) ──
SELECT
    d.donor_id,
    c.campaign_name
FROM mkt.donor d
JOIN source_system.campaign_ref c
    ON d.donor_code = c.donor_code_legacy;

-- ── Redshift ──────────────────────────────────────────────────────────────
-- Two ways to fix, pick based on whether case genuinely never carries meaning:

-- Option A: explicit COLLATE on the comparison (Redshift supports per-expression
-- case-insensitive collation)
SELECT
    d.donor_id,
    c.campaign_name
FROM mkt.donor d
JOIN source_system.campaign_ref c
    ON d.donor_code COLLATE "case_insensitive" = c.donor_code_legacy COLLATE "case_insensitive";

-- Option B: normalize both sides explicitly — more portable, easier to grep for in a
-- large codebase, and doesn't rely on collation being supported the same way if the
-- warehouse changes again in the future.
SELECT
    d.donor_id,
    c.campaign_name
FROM mkt.donor d
JOIN source_system.campaign_ref c
    ON LOWER(d.donor_code) = LOWER(c.donor_code_legacy);
