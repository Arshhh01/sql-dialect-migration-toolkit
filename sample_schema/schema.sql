-- Synthetic schema used by every example in this repo.
-- Fictional company ("Northwind Marketing Co."), fictional data — not tied to any
-- real employer or client system.

CREATE SCHEMA IF NOT EXISTS mkt;

CREATE TABLE mkt.campaign (
    campaign_id     INTEGER PRIMARY KEY,
    campaign_name   VARCHAR(200),
    channel         VARCHAR(50),      -- 'email', 'direct_mail', 'social'
    start_date      DATE,
    end_date        DATE,
    budget_usd      DECIMAL(12,2)
);

CREATE TABLE mkt.donor (
    donor_id        INTEGER PRIMARY KEY,
    donor_code      VARCHAR(20),      -- source-system identifier, mixed case in source
    signup_date     DATE,
    region          VARCHAR(50),
    lifetime_value  DECIMAL(12,2)
);

CREATE TABLE mkt.gift (
    gift_id         INTEGER PRIMARY KEY,
    donor_id        INTEGER REFERENCES mkt.donor(donor_id),
    campaign_id     INTEGER REFERENCES mkt.campaign(campaign_id),
    gift_amount     DECIMAL(12,2),
    gift_ts         TIMESTAMP,        -- carries source timezone offset
    raw_source_flag VARCHAR(10)       -- e.g. '01' meaning active; ZEROIFNULL'd upstream in Teradata
);
