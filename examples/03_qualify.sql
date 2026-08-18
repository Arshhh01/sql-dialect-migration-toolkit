-- Pattern: QUALIFY -> wrap in a subquery and filter in WHERE
-- Get each donor's most recent gift.

-- ── Teradata ──────────────────────────────────────────────────────────────
SELECT
    donor_id,
    gift_id,
    gift_amount,
    gift_ts
FROM mkt.gift
QUALIFY ROW_NUMBER() OVER (PARTITION BY donor_id ORDER BY gift_ts DESC) = 1;

-- ── Redshift ──────────────────────────────────────────────────────────────
-- Redshift has no QUALIFY clause. Any query using it has to be restructured:
-- compute the window function in a subquery/CTE, then filter on it in the
-- outer WHERE clause. This is a pure syntax rewrite — the result set is
-- identical — but it's the single most common blocker when porting a large
-- Teradata query library, since QUALIFY is used heavily for "latest record"
-- and deduplication logic.
SELECT
    donor_id,
    gift_id,
    gift_amount,
    gift_ts
FROM (
    SELECT
        donor_id,
        gift_id,
        gift_amount,
        gift_ts,
        ROW_NUMBER() OVER (PARTITION BY donor_id ORDER BY gift_ts DESC) AS rn
    FROM mkt.gift
) ranked
WHERE rn = 1;
