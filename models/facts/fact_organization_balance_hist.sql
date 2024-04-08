{{
    config(
        materialized='incremental',
        unique_key="uid",
        partition_by={
            "field": "DATE",
            "data_type": "date",
            "granularity": "month"
        },
        cluster_by=['ORGANIZATION_ID']
    )
}}

WITH balance_increase as (
  SELECT
    ORGANIZATION_ID,
    SUM(PAYMENT_AMOUNT / FX_RATE_PAYMENT) as TOTAL_AMOUNT_ADDED_USD,
  FROM {{ ref( 'stg_invoices' ) }}
  WHERE STATUS IN ('refunded','creadited')
  GROUP BY ORGANIZATION_ID
),

balance_deduction as (
  SELECT
    ORGANIZATION_ID,
    SUM(AMOUNT / FX_RATE) as TOTAL_AMOUNT_PAID_USD
  FROM {{ ref( 'stg_invoices' ) }}
  WHERE STATUS = 'paid' 
  AND PAYMENT_METHOD = 'client_balance'
  GROUP BY ORGANIZATION_ID
),

organizations as (
  SELECT
    CREATED_DATE,
    ORGANIZATION_ID,
    FIRST_PAYMENT_DATE,
    LAST_PAYMENT_DATE,
    COUNT_TOTAL_CONTRACTS_ACTIVE,
  FROM {{ ref( 'stg_organizations' ) }}
),

balance_calculation as (
  SELECT
    CURRENT_DATE() as DATE,
    o.ORGANIZATION_ID,
    o.FIRST_PAYMENT_DATE,
    o.LAST_PAYMENT_DATE,
    DATE_DIFF(CURRENT_DATE(), o.LAST_PAYMENT_DATE, DAY) AS DAYS_SINCE_LAST_PAYMENT,
    o.COUNT_TOTAL_CONTRACTS_ACTIVE,
    (IFNULL(bi.TOTAL_AMOUNT_ADDED_USD,0) - IFNULL(bd.TOTAL_AMOUNT_PAID_USD,0)) as CUSTOMER_BALANCE
  FROM organizations as o
  LEFT JOIN balance_increase as bi
  ON o.ORGANIZATION_ID = bi.ORGANIZATION_ID
  LEFT JOIN balance_deduction as bd
  ON o.ORGANIZATION_ID = bd.ORGANIZATION_ID
)

SELECT *,CONCAT(ORGANIZATION_ID,'-',DATE) as uid FROM balance_calculation