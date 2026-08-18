-- Pattern: naive TIMESTAMP cast on timezone-carrying data
--
-- gift_ts arrives from the source system with an embedded UTC offset. A plain
-- CAST(... AS TIMESTAMP) silently drops the offset instead of converting through it,
-- which shifts every gift time by whatever the local offset happens to be — a bug
-- that's invisible until someone reconciles gift counts by hour against the source
-- system and finds a systematic few-hour skew.

-- ── Teradata (offset silently discarded) ─────────────────────────────────
SELECT
    gift_id,
    CAST(gift_ts AS TIMESTAMP) AS gift_ts_naive
FROM mkt.gift;

-- ── Redshift ──────────────────────────────────────────────────────────────
-- Cast to TIMESTAMPTZ so the offset is preserved, then convert explicitly to
-- the target zone at query time rather than baking an assumption into the cast.
SELECT
    gift_id,
    CAST(gift_ts AS TIMESTAMPTZ) AT TIME ZONE 'UTC' AS gift_ts_utc
FROM mkt.gift;
