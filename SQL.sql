CREATE TABLE transactions_staging (
    step INTEGER,
    type VARCHAR(20),
    amount NUMERIC(18,2),
    nameOrig VARCHAR(20),
    oldbalanceOrg NUMERIC(18,2),
    newbalanceOrig NUMERIC(18,2),
    nameDest VARCHAR(20),
    oldbalanceDest NUMERIC(18,2),
    newbalanceDest NUMERIC(18,2),
    isFraud INTEGER,
    isFlaggedFraud INTEGER
);




CREATE TABLE transactions_raw AS
SELECT
    step,
    type,
    amount,
    nameOrig,
    oldbalanceOrg,
    newbalanceOrig,
    nameDest,
    oldbalanceDest,
    newbalanceDest,
    isFraud
FROM transactions_staging;

SELECT * FROM transactions_raw





CREATE TABLE transactions_clean AS
SELECT
    step,
    LOWER(type) AS type,
    amount,
    nameOrig,
    oldbalanceOrg,
    newbalanceOrig,
    nameDest,
    oldbalanceDest,
    newbalanceDest,
    isFraud,
    -- derived fields
    (oldbalanceOrg - newbalanceOrig) AS orig_balance_delta,
    (newbalanceDest - oldbalanceDest) AS dest_balance_delta,
    CASE WHEN nameDest LIKE 'M%' THEN TRUE ELSE FALSE END AS dest_is_merchant,
    CASE WHEN oldbalanceOrg = 0 AND newbalanceOrig = 0 AND amount > 0 THEN TRUE ELSE FALSE END AS orig_balance_error,
    CEIL(step / 24.0) AS sim_day,
    MOD(step, 24) AS hour_of_day
FROM transactions_raw
WHERE amount > 0;
 
CREATE INDEX idx_clean_type ON transactions_clean(type);
CREATE INDEX idx_clean_fraud ON transactions_clean(isFraud);
CREATE INDEX idx_clean_orig ON transactions_clean(nameOrig);
CREATE INDEX idx_clean_dest ON transactions_clean(nameDest);

SELECT * FROM transactions_clean




CREATE TABLE fraud_analysis AS
SELECT
    type,
    sim_day,
    hour_of_day,
    COUNT(*) AS total_txns,
    SUM(isFraud) AS fraud_txns,
    ROUND(SUM(isFraud)::NUMERIC / COUNT(*), 6) AS fraud_rate,
    SUM(CASE WHEN isFraud = 1 THEN amount ELSE 0 END) AS fraud_amount
FROM transactions_clean
GROUP BY type, sim_day, hour_of_day;
 
CREATE INDEX idx_fraud_type ON fraud_analysis(type);

SELECT * FROM fraud_analysis





CREATE TABLE customer_analysis AS
SELECT
    nameOrig,
    COUNT(*) AS num_txns,
    SUM(amount) AS total_sent,
    AVG(amount) AS avg_txn_amount,
    MAX(amount) AS max_txn_amount,
    SUM(isFraud) AS fraud_txns,
    COUNT(DISTINCT type) AS distinct_txn_types,
    MIN(step) AS first_step,
    MAX(step) AS last_step
FROM transactions_clean
GROUP BY nameOrig
ORDER BY num_txns DESC;
 
CREATE INDEX idx_cust_fraud ON customer_analysis(fraud_txns);

SELECT * FROM customer_analysis





-- Overview KPIs
CREATE VIEW dash_overview AS
SELECT
    COUNT(*) AS total_txns,
    SUM(amount) AS total_volume,
    SUM(isFraud) AS total_fraud_txns,
    ROUND(SUM(isFraud)::NUMERIC / COUNT(*) * 100, 4) AS fraud_pct,
    SUM(CASE WHEN isFraud = 1 THEN amount ELSE 0 END) AS fraud_volume
FROM transactions_clean;

SELECT * FROM dash_overview

-- Fraud by transaction type
CREATE VIEW dash_fraud_by_type AS
SELECT type, SUM(total_txns) AS total_txns, SUM(fraud_txns) AS fraud_txns,
       ROUND(SUM(fraud_txns)::NUMERIC / NULLIF(SUM(total_txns),0) * 100, 4) AS fraud_pct
FROM fraud_analysis
GROUP BY type
ORDER BY fraud_pct DESC;

SELECT * FROM dash_fraud_by_type

-- Fraud trend over time (daily)
CREATE VIEW dash_fraud_trend AS
SELECT sim_day, SUM(fraud_txns) AS fraud_txns, SUM(fraud_amount) AS fraud_amount
FROM fraud_analysis
GROUP BY sim_day
ORDER BY sim_day;

SELECT * FROM dash_fraud_trend

-- Top risky customers
CREATE VIEW dash_top_risky_customers AS
SELECT nameOrig, num_txns, total_sent, fraud_txns
FROM customer_analysis
WHERE fraud_txns > 0
ORDER BY fraud_txns DESC, total_sent DESC
LIMIT 100;

SELECT * FROM dash_top_risky_customers




SELECT
    CASE
        WHEN amount < 10000 THEN '<10K'
        WHEN amount < 50000 THEN '10K-50K'
        WHEN amount < 100000 THEN '50K-100K'
        WHEN amount < 500000 THEN '100K-500K'
        ELSE '500K+'
    END AS amount_band,
    COUNT(*) AS total_txns,
    SUM(isFraud) AS fraud_txns,
    ROUND(SUM(isFraud)::numeric / COUNT(*) * 100, 4) AS fraud_pct,
    SUM(CASE WHEN isFraud = 1 THEN amount ELSE 0 END) AS fraud_volume
FROM transactions_clean
GROUP BY 1
ORDER BY fraud_pct DESC;





SELECT
    hour_of_day,
    COUNT(*) AS total_txns,
    SUM(isFraud) AS fraud_txns,
    ROUND(SUM(isFraud)::numeric / COUNT(*) * 100, 4) AS fraud_pct
FROM transactions_clean
GROUP BY hour_of_day
ORDER BY hour_of_day;




SELECT
    nameDest,
    COUNT(*) AS total_txns,
    SUM(isFraud) AS fraud_txns,
    SUM(amount) AS total_received
FROM transactions_clean
GROUP BY nameDest
HAVING SUM(isFraud) > 0
ORDER BY fraud_txns DESC, total_received DESC
LIMIT 100;



SELECT
    orig_balance_error,
    COUNT(*) AS total_txns,
    SUM(isFraud) AS fraud_txns,
    ROUND(SUM(isFraud)::numeric / COUNT(*) * 100, 4) AS fraud_pct
FROM transactions_clean
GROUP BY orig_balance_error;




SELECT
    sim_day,
    type,
    COUNT(*) AS total_txns,
    SUM(isFraud) AS fraud_txns,
    ROUND(SUM(isFraud)::numeric / COUNT(*) * 100, 4) AS fraud_pct,
    SUM(CASE WHEN isFraud = 1 THEN amount ELSE 0 END) AS fraud_volume
FROM transactions_clean
WHERE type = ''
GROUP BY sim_day, type
ORDER BY sim_day, type;



SELECT
    type,
    CASE
        WHEN amount < 10000 THEN '<10K'
        WHEN amount < 50000 THEN '10K-50K'
        WHEN amount < 100000 THEN '50K-100K'
        WHEN amount < 500000 THEN '100K-500K'
        ELSE '500K+'
    END AS amount_band,
    COUNT(*) AS total_txns,
    SUM(isFraud) AS fraud_txns,
    ROUND(
        SUM(isFraud)::numeric / COUNT(*) * 100, 4
    ) AS fraud_pct,
    SUM(CASE WHEN isFraud = 1 THEN amount ELSE 0 END) AS fraud_volume
FROM transactions_clean
GROUP BY type, amount_band
HAVING COUNT(*) >= 100
ORDER BY fraud_pct DESC;




CREATE VIEW dash_risk_segment AS
SELECT
    type,
    CASE
        WHEN amount < 10000 THEN '<10K'
        WHEN amount < 50000 THEN '10K-50K'
        WHEN amount < 100000 THEN '50K-100K'
        WHEN amount < 500000 THEN '100K-500K'
        ELSE '500K+'
    END AS amount_band,
    COUNT(*) AS total_txns,
    SUM(isFraud) AS fraud_txns,
    ROUND(
        SUM(isFraud)::numeric / COUNT(*) * 100, 4
    ) AS fraud_pct,
    SUM(CASE WHEN isFraud = 1 THEN amount ELSE 0 END) AS fraud_volume
FROM transactions_clean
GROUP BY type, amount_band
HAVING COUNT(*) >= 100;

SELECT * FROM dash_risk_segment



CREATE VIEW Amount_band_Hourly AS 
SELECT
	hour_of_day,
	CASE
		WHEN amount < 10000 THEN '<10K'
		WHEN amount < 50000 THEN '10K-50K'
		WHEN amount < 100000 THEN '50K-100K'
		WHEN amount < 500000 THEN '100K-500K'
		ELSE '500K+'
	END AS amount_band,
	COUNT(*) AS total_txns,
	SUM(isFraud) AS fraud_txns,
	ROUND(SUM(isFraud)::numeric/COUNT(*)*100,4)AS fraud_pct,
	SUM(CASE WHEN isFraud = 1 THEN amount ELSE 0 END) AS fraud_vol
FROM transactions_clean
GROUP BY hour_of_day, amount_band
ORDER BY hour_of_day, amount_band;

SELECT * FROM Amount_band_Hourly





CREATE VIEW Amount_band_Daily AS 
SELECT
	sim_day,
	CASE
		WHEN amount < 10000 THEN '<10K'
		WHEN amount < 50000 THEN '10K-50K'
		WHEN amount < 100000 THEN '50K-100K'
		WHEN amount < 500000 THEN '100K-500K'
		ELSE '500K+'
	END AS amount_band,
	COUNT(*) AS total_txns,
	SUM(isFraud) AS fraud_txns,
	ROUND(SUM(isFraud)::numeric/COUNT(*)*100,4)AS fraud_pct,
	SUM(CASE WHEN isFraud = 1 THEN amount ELSE 0 END) AS fraud_vol
FROM transactions_clean
GROUP BY sim_day, amount_band
ORDER BY sim_day, amount_band;

SELECT * FROM Amount_band_Daily





CREATE VIEW Amount_band_Daily AS 
SELECT
	sim_day,
	CASE
		WHEN amount < 200000 THEN '<200K'
		WHEN amount < 50000 THEN '10K-50K'
		WHEN amount < 100000 THEN '50K-100K'
		WHEN amount < 500000 THEN '100K-500K'
		ELSE '500K+'
	END AS amount_band,
	COUNT(*) AS total_txns,
	SUM(isFraud) AS fraud_txns,
	ROUND(SUM(isFraud)::numeric/COUNT(*)*100,4)AS fraud_pct,
	SUM(CASE WHEN isFraud = 1 THEN amount ELSE 0 END) AS fraud_vol
FROM transactions_clean
GROUP BY sim_day, amount_band
ORDER BY sim_day, amount_band;





SELECT
    COUNT(*) FILTER (
        WHERE type = 'transfer'
          AND isFraud = 1
    ) AS transfer_fraud,

    COUNT(*) FILTER (
        WHERE type = 'transfer'
          AND isFraud = 1
          AND amount > 200000
    ) AS transfer_fraud_over_200k,

    COUNT(*) FILTER (
        WHERE type = 'transfer'
          AND isFraud = 1
          AND amount < 200000
    ) AS transfer_fraud_under_200k,

    COUNT(*) FILTER (
        WHERE type = 'transfer'
          AND amount > 200000
    ) AS transfer_over_200k_flagged,

    ROUND(
        COUNT(*) FILTER (
            WHERE type = 'transfer'
              AND amount > 200000
              AND isFraud = 1
        )::numeric
        /
        NULLIF(
            COUNT(*) FILTER (
                WHERE type = 'transfer'
                  AND amount > 200000
            ), 0
        ) * 100,
        2
    ) AS flagged_also_fraud_pct

FROM transactions_clean;





CREATE VIEW amount_band_Weekday AS
SELECT
    CASE MOD(sim_day - 1, 7)
        WHEN 0 THEN 'Monday'
        WHEN 1 THEN 'Tuesday'
        WHEN 2 THEN 'Wednesday'
        WHEN 3 THEN 'Thursday'
        WHEN 4 THEN 'Friday'
        WHEN 5 THEN 'Saturday'
        WHEN 6 THEN 'Sunday'
    END AS day_of_week,

    MOD(sim_day - 1, 7) AS day_order,

    hour_of_day,

    CASE
        WHEN amount < 50000 THEN '<50K'
        WHEN amount < 100000 THEN '50K-100K'
        WHEN amount < 200000 THEN '100K-200K'
        WHEN amount < 500000 THEN '200K-500K'
        ELSE '500K+'
    END AS amount_band,

    COUNT(*) AS total_txns,

    SUM(isFraud) AS fraud_transactions,

    ROUND(
        SUM(isFraud)::numeric / COUNT(*) * 100,
        4
    ) AS fraud_pct,

    SUM(
        CASE WHEN isFraud = 1 THEN amount ELSE 0 END
    ) AS fraud_volume

FROM transactions_clean

GROUP BY
    day_of_week,
    day_order,
    hour_of_day,
    amount_band

ORDER BY
    day_order,
    hour_of_day,
    amount_band;

SELECT * FROM amount_band_Weekday