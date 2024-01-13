  -- CREAMOS LA TABLA TOMANDO COMO FECHA DE CONSULTA '2022-12-12'
CREATE OR REPLACE TABLE keepcoding.ivr_summary AS
WITH
  calls AS (
  SELECT
    DISTINCT calls_ivr_id,
    calls_phone_number,
    calls_ivr_result,
    calls_vdn_label,
    calls_start_date,
    calls_end_date,
    calls_total_duration,
    calls_customer_segment,
    calls_ivr_language,
    calls_steps_module,
    calls_module_aggregation
  FROM
    `keepcoding.ivr_detail` ),
  document_type_1 AS (
  SELECT
    calls_ivr_id,
    ANY_VALUE(document_type) AS document_type
  FROM
    `keepcoding.ivr_detail`
  WHERE
    document_type != 'UNKNOWN'
  GROUP BY
    calls_ivr_id ),
  document_type AS (
  SELECT
    d.calls_ivr_id,
    d.document_type,
    ANY_VALUE(d.document_identification) AS document_identification
  FROM
    `keepcoding.ivr_detail` AS d
  INNER JOIN
    document_type_1 AS dt
  ON
    d.calls_ivr_id = dt.calls_ivr_id
    AND d.document_type = dt.document_type
  GROUP BY
    d.calls_ivr_id,
    d.document_type ),
  customer_phone AS (
  SELECT
    calls_ivr_id,
    ANY_VALUE(customer_phone) AS customer_phone
  FROM
    `keepcoding.ivr_detail`
  WHERE
    customer_phone != 'UNKNOWN'
  GROUP BY
    calls_ivr_id ),
  billing_account_id AS (
  SELECT
    calls_ivr_id,
    ANY_VALUE(billing_account_id) AS billing_account_id,
  FROM
    `keepcoding.ivr_detail`
  WHERE
    billing_account_id != 'UNKNOWN'
  GROUP BY
    calls_ivr_id ),
  masiva_lg AS (
  SELECT
    DISTINCT calls_ivr_id,
    module_name
  FROM
    `keepcoding.ivr_detail`
  WHERE
    module_name = "AVERIA_MASIVA" ),
  info_by_phone_lg AS (
  SELECT
    DISTINCT calls_ivr_id,
    step_name
  FROM
    `keepcoding.ivr_detail`
  WHERE
    step_name = "CUSTOMERINFOBYPHONE.TX"
    AND step_description_error = "UNKNOWN" ),
  info_by_dni_lg AS (
  SELECT
    DISTINCT calls_ivr_id,
    step_name
  FROM
    `keepcoding.ivr_detail`
  WHERE
    step_name = "CUSTOMERINFOBYDNI.TX"
    AND step_description_error = "UNKNOWN" ),
  dim_fechas AS (
  SELECT
    '2022-12-12' AS fecha ),
  phone_24H AS (
  SELECT
    calls_ivr_id,
    calls_phone_number,
    calls_start_date,
    calls_end_date,
    fecha,
    LAG(calls_end_date) OVER(PARTITION BY calls_phone_number ORDER BY calls_end_date) AS prev_calls,
    DATETIME_DIFF(LAG(calls_end_date) OVER(PARTITION BY calls_phone_number ORDER BY calls_end_date), CAST(fecha AS timestamp), HOUR) AS prev_days_diff,
  IF
    (DATETIME_DIFF(LAG(calls_end_date) OVER(PARTITION BY calls_phone_number ORDER BY calls_end_date), CAST(fecha AS timestamp), HOUR) BETWEEN -24
      AND 0, 1, 0) AS repeated_phone_24H,
    LEAD(calls_start_date) OVER(PARTITION BY calls_phone_number ORDER BY calls_start_date) AS next_calls,
    DATETIME_DIFF(LEAD(calls_start_date) OVER(PARTITION BY calls_phone_number ORDER BY calls_start_date), CAST(fecha AS timestamp), HOUR) AS next_days_diff,
  IF
    (DATETIME_DIFF(LEAD(calls_start_date) OVER(PARTITION BY calls_phone_number ORDER BY calls_start_date), CAST(fecha AS timestamp), HOUR) BETWEEN 0
      AND 24, 1, 0) AS cause_recall_phone_24H
  FROM
    `keepcoding.ivr_detail`
  CROSS JOIN
    dim_fechas )
SELECT
  c.calls_ivr_id AS ivr_id,
  c.calls_phone_number AS phone_number,
  c.calls_ivr_result AS ivr_result,
  CASE
    WHEN STARTS_WITH(c.calls_vdn_label, 'ATC') THEN 'FRONT'
    WHEN STARTS_WITH(c.calls_vdn_label, 'TECH') THEN 'TECH'
    WHEN STARTS_WITH(c.calls_vdn_label, 'ABSORPTION') THEN 'ABSORPTION'
  ELSE
  'RESTO'
END
  AS vdn_aggregation,
  c.calls_start_date AS start_date,
  c.calls_end_date AS end_date,
  c.calls_total_duration AS total_duration,
  c.calls_customer_segment AS customer_segment,
  c.calls_ivr_language AS ivr_language,
  c.calls_steps_module AS steps_module,
  c.calls_module_aggregation AS module_aggregation,
  IFNULL(d.document_type, 'UNKNOWN') AS document_type,
  IFNULL(d.document_identification, 'UNKNOWN') AS document_identification,
  IFNULL(cp.customer_phone, 'UNKNOWN') AS customer_phone,
  IFNULL(ba.billing_account_id, 'UNKNOWN') AS billing_account_id,
IF
  (ml.module_name IS NULL, 0, 1) AS masiva_lg,
IF
  (ibfl.step_name IS NULL, 0, 1) AS info_by_phone_lg,
IF
  (ibdl.step_name IS NULL, 0, 1) AS info_by_dni_lg,
  MAX(
  IF
    (ph.repeated_phone_24H IS NULL, 0, ph.repeated_phone_24H)) AS repeated_phone_24H,
  MAX(
  IF
    (ph.cause_recall_phone_24H IS NULL, 0,ph.cause_recall_phone_24H)) AS cause_recall_phone_24H
FROM
  calls AS c
LEFT JOIN
  document_type AS d
ON
  c.calls_ivr_id = d.calls_ivr_id
LEFT JOIN
  customer_phone AS cp
ON
  c.calls_ivr_id = cp.calls_ivr_id
LEFT JOIN
  billing_account_id AS ba
ON
  c.calls_ivr_id = ba.calls_ivr_id
LEFT JOIN
  masiva_lg AS ml
ON
  c.calls_ivr_id = ml.calls_ivr_id
LEFT JOIN
  info_by_phone_lg AS ibfl
ON
  c.calls_ivr_id = ibfl.calls_ivr_id
LEFT JOIN
  info_by_dni_lg AS ibdl
ON
  c.calls_ivr_id = ibdl.calls_ivr_id
LEFT JOIN
  phone_24H AS ph
ON
  c.calls_ivr_id = ph.calls_ivr_id
GROUP BY
  c.calls_ivr_id,
  c.calls_phone_number,
  c.calls_ivr_result,
  c.calls_vdn_label,
  c.calls_start_date,
  c.calls_end_date,
  c.calls_total_duration,
  c.calls_customer_segment,
  c.calls_ivr_language,
  c.calls_steps_module,
  c.calls_module_aggregation,
  d.document_type,
  d.document_identification,
  cp.customer_phone,
  ba.billing_account_id,
  ml.module_name,
  ibfl.step_name,
  ibdl.step_name