{{ config(materialized='table') }}

WITH calendar_dates AS (
    SELECT *
    FROM {{ source('gtfs_type2', 'calendar_dates') }}
),

calendar_dates_clean AS (

    -- Trim all string fields
    -- Incoming schema explicitly defined in gtfs_schedule_history external table definition

    SELECT
        calitp_itp_id,
        calitp_url_number,
        TRIM(service_id) AS service_id,
        TRIM(exception_type) AS exception_type,
        calitp_extracted_at,
        calitp_hash,
        PARSE_DATE("%Y%m%d", TRIM(date)) AS date,
        COALESCE(calitp_deleted_at, "2099-01-01") AS calitp_deleted_at
    FROM calendar_dates
)

SELECT * FROM calendar_dates_clean
