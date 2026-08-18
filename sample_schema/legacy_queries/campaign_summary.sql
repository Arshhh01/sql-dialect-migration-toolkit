-- Example legacy Teradata query, provided so the linter has something to scan.
SELECT
    campaign_id,
    SUM(ZEROIFNULL(gift_amount)) AS total_gifts,
    CAST(gift_ts AS TIMESTAMP) AS gift_ts_naive
FROM gift
QUALIFY ROW_NUMBER() OVER (PARTITION BY campaign_id ORDER BY gift_ts DESC) = 1;
