{{ config(materialized='table') }}

WITH gtfs_rt_fact_files AS (
    SELECT *
    FROM {{ ref('gtfs_rt_fact_files') }}
),

daily_tot AS (
    SELECT
        date_extracted,
        calitp_itp_id,
        calitp_url_number,
        name,
        count(calitp_extracted_at) AS file_count_day
    FROM gtfs_rt_fact_files
    GROUP BY
        date_extracted,
        calitp_itp_id,
        calitp_url_number,
        name
),

wide_hourly AS (
    SELECT *
    FROM
        (SELECT
            date_extracted,
            calitp_itp_id,
            calitp_url_number,
            name,
            calitp_extracted_at,
            hour_extracted
            FROM gtfs_rt_fact_files)
    PIVOT(
        count(calitp_extracted_at) file_count_hr
        FOR hour_extracted IN
        (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
            11, 12, 13, 14, 15, 16, 17, 18, 19,
            20, 21, 22, 23)
    )
),

gtfs_rt_fact_files_wide_hourly AS (
    SELECT *
    FROM daily_tot
    LEFT JOIN wide_hourly
        USING (date_extracted, calitp_itp_id, calitp_url_number, name)
)

SELECT *
FROM gtfs_rt_fact_files_wide_hourly
