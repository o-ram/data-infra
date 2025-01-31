{{ config(materialized='table') }}

WITH stop_times_clean AS (
    SELECT *
    FROM {{ ref('stop_times_clean') }}
),

raw_time_parts AS (
    SELECT
        *,
        REGEXP_EXTRACT_ALL(arrival_time, "([0-9]+)") AS part_arr,
        REGEXP_EXTRACT_ALL(departure_time, "([0-9]+)") AS part_dep
    FROM stop_times_clean
),

int_time_parts AS (
    SELECT
        * EXCEPT (part_arr, part_dep, stop_sequence),
        ARRAY(SELECT CAST(num AS INT64) FROM UNNEST(raw_time_parts.part_arr) AS num) AS part_arr,
        ARRAY(SELECT CAST(num AS INT64) FROM UNNEST(raw_time_parts.part_dep) AS num) AS part_dep,
        CAST(stop_sequence AS INT64) AS stop_sequence
    FROM raw_time_parts
),

array_len_fix AS (
    SELECT
        * EXCEPT(part_arr, part_dep),
        CASE WHEN ARRAY_LENGTH(part_arr) = 0 THEN [NULL, NULL, NULL] ELSE part_arr END AS part_arr,
        CASE WHEN ARRAY_LENGTH(part_dep) = 0 THEN [NULL, NULL, NULL] ELSE part_dep END AS part_dep
    FROM int_time_parts
),

gtfs_schedule_dim_stop_times AS (
    SELECT
        * EXCEPT(continuous_pickup, continuous_drop_off, part_arr, part_dep),
        continuous_pickup AS stop_time_continuous_pickup,
        continuous_drop_off AS stop_time_continuous_drop_off,
        DENSE_RANK()
        OVER (PARTITION BY calitp_itp_id, calitp_url_number, trip_id ORDER BY stop_sequence)
        AS stop_sequence_rank,
        part_arr[OFFSET(0)] * 3600 + part_arr[OFFSET(1)] * 60 + part_arr[OFFSET(2)] AS arrival_ts,
        part_dep[OFFSET(0)] * 3600 + part_dep[OFFSET(1)] * 60 + part_dep[OFFSET(2)] AS departure_ts
    FROM array_len_fix
)

SELECT * FROM gtfs_schedule_dim_stop_times
