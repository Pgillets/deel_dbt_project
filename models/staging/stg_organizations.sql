{{
    config(
        materialized='table'
    )
}}

select * from {{ source( 'deel','src_csv_organizations' ) }}