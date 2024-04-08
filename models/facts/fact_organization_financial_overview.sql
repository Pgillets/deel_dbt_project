{{
    config(
        materialized='table',
        partition_by={
            "field": "CREATED_DATE",
            "data_type": "timestamp",
            "granularity": "month"
        },
        cluster_by=['ORGANIZATION_ID']
    )
}}

WITH paid_invoices_overview as (
  SELECT
    ORGANIZATION_ID,
    COUNT(INVOICE_ID) AS TOTAL_INVOICES_PAID,
    SUM(PAYMENT_AMOUNT / FX_RATE_PAYMENT) as TOTAL_PAYMENT_AMOUNT_USD,
    AVG(PAYMENT_AMOUNT / FX_RATE_PAYMENT) as AVG_PAYMENT_AMOUNT_USD,
  FROM {{ ref( 'stg_invoices' ) }}
  WHERE status = 'paid'
  GROUP BY ORGANIZATION_ID
),

open_and_pending_invoices_overview as (
  SELECT
    ORGANIZATION_ID,
    COUNT(INVOICE_ID) AS TOTAL_INVOICES_OPEN_OR_PENDING,
    SUM(AMOUNT / FX_RATE) as TOTAL_AMOUNT_TO_RECEIVE_USD
  FROM {{ ref( 'stg_invoices' ) }}
  WHERE status in ('open','pending')
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
)

SELECT
  o.CREATED_DATE,
  o.ORGANIZATION_ID,
  o.FIRST_PAYMENT_DATE,
  o.LAST_PAYMENT_DATE,
  DATE_DIFF(CURRENT_DATE(), o.LAST_PAYMENT_DATE, DAY) AS DAYS_SINCE_LAST_PAYMENT,
  o.COUNT_TOTAL_CONTRACTS_ACTIVE,
  i.TOTAL_INVOICES_PAID,
  i.TOTAL_PAYMENT_AMOUNT_USD,
  i.AVG_PAYMENT_AMOUNT_USD,
  opi.TOTAL_INVOICES_OPEN_OR_PENDING,
  opi.TOTAL_AMOUNT_TO_RECEIVE_USD
FROM organizations as o
LEFT JOIN paid_invoices_overview as i
ON o.ORGANIZATION_ID = i.ORGANIZATION_ID
LEFT JOIN open_and_pending_invoices_overview as opi
ON o.ORGANIZATION_ID = opi.ORGANIZATION_ID
