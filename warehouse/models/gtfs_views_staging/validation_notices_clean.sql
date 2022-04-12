{{ config(materialized='table') }}

WITH validation_notices as (
    select *
    from {{ source('gtfs_type2', 'validation_notices') }}
)

, validation_notices_clean as (

    -- Must trim string fields that come from raw GTFS tables that we clean & load into views
    -- (To allow joining with the cleaned data after this is run)
    -- This table has over 70 columns, so even though EXCEPT is a bit messy it still seems cleaner

    SELECT
        * EXCEPT(
        calitp_deleted_at
        , fareId
        , previousFareId
        , shapeId
        , routeId
        , currentDate
        , feedEndDate
        , routeColor
        , routeTextColor
        , tripId
        , tripIdA
        , tripIdB
        , routeShortName
        , routeLongName
        , routeDesc
        , stopId
        , stopName
        , serviceIdA
        , serviceIdB
        , departureTime
        , arrivalTime
        , parentStation
        , parentStopName)
        , COALESCE(calitp_deleted_at, "2099-01-01") AS calitp_deleted_at
        , TRIM(fareId) as fareId
        , TRIM(previousFareId) as previousFareId
        , TRIM(shapeId) as shapeId
        , TRIM(routeId) as routeId
        , TRIM(currentDate) as currentDate
        , TRIM(feedEndDate) as feedEndDate
        , TRIM(routeColor) as routeColor
        , TRIM(routeTextColor) as routeTextColor
        , TRIM(tripId) as tripId
        , TRIM(tripIdA) as tripIdA
        , TRIM(tripIdB) as tripIdB
        , TRIM(routeShortName) as routeShortName
        , TRIM(routeLongName) as routeLongName
        , TRIM(routeDesc) as routeDesc
        , TRIM(stopId) as stopId
        , TRIM(stopName) as stopName
        , TRIM(serviceIdA) as serviceIdA
        , TRIM(serviceIdB) as serviceIdB
        , TRIM(departureTime) as departureTime
        , TRIM(arrivalTime) as arrivalTime
        , TRIM(parentStation) as parentStation
        , TRIM(parentStopName) as parentStopName
    FROM validation_notices
)

SELECT * FROM validation_notices_clean
