{{
    config(
        materialized='table',
        cluster_by=['STATUS','ORGANIZATION_ID']
    )
}}

select
    ORGANIZATION_ID,
    PARENT_INVOICE_ID,
    INVOICE_ID,
    TRANSACTION_ID,
    TYPE,
    STATUS,
    CURRENCY,
    PAYMENT_CURRENCY,
    PAYMENT_METHOD,
    AMOUNT,
    PAYMENT_AMOUNT,
    FX_RATE,
    FX_RATE_PAYMENT
from {{ source( 'deel','src_csv_invoices' ) }}