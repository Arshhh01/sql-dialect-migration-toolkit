-- Pattern: ZEROIFNULL -> COALESCE
-- Total gift amount per campaign, treating NULL amounts as 0 so a campaign with no
-- recorded gifts yet still sums to 0 instead of NULL.

-- ── Teradata ──────────────────────────────────────────────────────────────
SELECT
    campaign_id,
    SUM(ZEROIFNULL(gift_amount)) AS total_gifts
FROM mkt.gift
GROUP BY campaign_id;

-- ── Redshift ──────────────────────────────────────────────────────────────
-- ZEROIFNULL is Teradata-proprietary and does not exist in Redshift (or in
-- standard SQL). COALESCE(col, 0) is the direct, portable equivalent.
SELECT
    campaign_id,
    SUM(COALESCE(gift_amount, 0)) AS total_gifts
FROM mkt.gift
GROUP BY campaign_id;
