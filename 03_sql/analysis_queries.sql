-- Q1
SELECT 
    status_clean, 
    COUNT(transaction_id) AS transaction_count
FROM transaction_log
GROUP BY status_clean
ORDER BY transaction_count DESC;


-- Q2

SELECT 
    merchant_name_clean AS merchant,
    SUM(amount_usd) AS total_captured_gmv
FROM transaction_records
WHERE status_clean = 'Captured'
GROUP BY merchant_name_clean
ORDER BY total_captured_gmv DESC;


-- Q3
SELECT 
    merchant_name_clean AS merchant,
    SUM(amount_usd) AS merchant_gmv,
    ROUND(
        SUM(amount_usd) * 100 / (SELECT SUM(amount_usd) FROM transaction_records WHERE status_clean = 'Captured'), 
        2
    ) AS percentage
FROM transaction_records
WHERE status_clean = 'Captured'
GROUP BY merchant_name_clean
ORDER BY merchant_gmv DESC
LIMIT 10; 


-- Q4

SELECT 
    transaction_date,
    COUNT(transaction_id) AS success_count,
    SUM(amount_usd) AS daily_gmv
FROM transaction_records
WHERE status_clean = 'Captured'
GROUP BY transaction_date
ORDER BY transaction_date ASC;


-- Q5

SELECT 
    merchant_name_clean AS merchant,
    COUNT(CASE WHEN status_clean = 'Chargeback' THEN 1 END) AS total_chargebacks,
    COUNT(transaction_id) AS total_transactions,
    ROUND(
        (COUNT(CASE WHEN status_clean = 'Chargeback' THEN 1 END) * 100.0) / COUNT(transaction_id), 
        2
    ) AS chargeback_ratio_pct
FROM transaction_records
GROUP BY merchant_name_clean
HAVING chargeback_ratio_pct > 1.0
ORDER BY chargeback_ratio_pct DESC;


-- Q6

SELECT 
    gateway_region_clean AS region,
    COUNT(transaction_id) AS transaction_count,
    ROUND(AVG(risk_score_clean), 2) AS average_risk_score
FROM transaction_records
WHERE gateway_region_clean != 'MISSING'
GROUP BY gateway_region_clean
HAVING average_risk_score > 50 AND transaction_count > 20
ORDER BY average_risk_score DESC;


-- Q7

SELECT 
    user_id,
    user_name,
    transaction_date,
    COUNT(transaction_id) AS issue_count,
    GROUP_CONCAT(status_clean) AS status_list
FROM transaction_records
WHERE status_clean = 'Chargeback' 
   OR status_clean LIKE 'Failed%'
GROUP BY user_id, user_name, transaction_date
HAVING issue_count >= 3
ORDER BY issue_count DESC;


-- Q8

SELECT 
    merchant_name_clean AS merchant,
    COUNT(transaction_id) AS total_chargebacks,
    COUNT(DISTINCT user_id) AS unique_affected_users,
    SUM(amount_usd) AS total_chargeback_amount
FROM transaction_records
WHERE status_clean = 'Chargeback'
GROUP BY merchant_name_clean
ORDER BY total_chargeback_amount DESC;


