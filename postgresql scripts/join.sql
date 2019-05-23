SELECT a.*
	   ,parking_spaces as total_spots_survey
	   ,total_vehicle_count as occupied_spots_survey
	   ,study_time as time_of_survey
	   ,w."hour" as weather_at_hour
	   ,w."AvgTempF" as average_temp
	   ,w."TotPrecin" as rain_inches
	   ,w."RelHum" as humidity
	   ,g."FAC_NAME" as parking_lot_name
	   ,g."RTE_1HR" as parking_lot_rate_1hr
	   ,g."RTE_2HR" as parking_lot_rate_2hr
	   ,g."RTE_3HR" as parking_lot_rate_3hr
	   ,g."RTE_ALLDAY" as parking_lot_rate_allday
	   ,ST_Distance(A.geog, g.geog) AS parking_lot_dist_m
	   ,name_of_event as "event"
	   ,employment
	   ,aawdt as avg_traffic_density
	   ,CASE WHEN aawdt is not null THEN 1 ELSE 0 END as main_city_street
	   
FROM parking_2018_cleaned a
--
LEFT JOIN annual_parking b
ON a.source_element_key = b.elmntkey
and a.date_of_transaction = b.study_date
and a.time_of_transaction between b.study_time - interval '30 minutes' and b.study_time + interval '30 minutes'
--
LEFT JOIN hourly_weather w
ON a.date_of_transaction = w."Date"
and a.hour_transaction = extract(hour from w.hour)
--
LEFT JOIN public_garages_lots g
ON ST_DWithin(A.geog, g.geog, 100)
--
LEFT JOIN s_events_permits_belltown p
ON p.event_date = a.date_of_transaction
--
LEFT JOIN seattle_employment e
ON e."year" = a.yyyy_transaction
and e."month" = a.mm_transaction
--
LEFT JOIN traffic_2017_2018 t
ON a.segkey = t.segkey
and a.yyyy_transaction = t."year"
---
--2018 view 

--changes in lat/long/geog/time


-- View: public.parking_2018_cleaned

-- DROP VIEW public.parking_2018_cleaned;

CREATE OR REPLACE VIEW public.parking_2018_cleaned AS
 SELECT parking_belltown_n_2018.sourceelementkey AS source_element_key,
    split_part(parking_belltown_n_2018.blockfacename, ' BETWEEN'::text, 1) AS main_lane,
    split_part(split_part(parking_belltown_n_2018.blockfacename, 'BETWEEN '::text, 2), ' AND'::text, 1) AS between_one,
    split_part(split_part(parking_belltown_n_2018.blockfacename, 'BETWEEN '::text, 2), 'AND '::text, 2) AS between_second,
    parking_belltown_n_2018.sideofstreet,
    to_date("substring"(parking_belltown_n_2018.occupancydatetime, 0, 11), 'YYYY-MM-DD'::text) AS date_of_transaction,
    date_part('month'::text, to_date("substring"(parking_belltown_n_2018.occupancydatetime, 0, 11), 'YYYY-MM-DD'::text)) AS mm_transaction,
    date_part('year'::text, to_date("substring"(parking_belltown_n_2018.occupancydatetime, 0, 11), 'YYYY-MM-DD'::text)) AS yyyy_transaction,
    date_part('day'::text, to_date("substring"(parking_belltown_n_2018.occupancydatetime, 0, 11), 'YYYY-MM-DD'::text)) AS dd_transaction,
    date_part('dow'::text, to_date("substring"(parking_belltown_n_2018.occupancydatetime, 0, 11), 'YYYY-MM-DD'::text)) AS dow_transaction,
    date_part('doy'::text, to_date("substring"(parking_belltown_n_2018.occupancydatetime, 0, 11), 'YYYY-MM-DD'::text)) AS doy_transaction,
    date_part('week'::text, to_date("substring"(parking_belltown_n_2018.occupancydatetime, 0, 11), 'YYYY-MM-DD'::text)) AS week_transaction,
    to_timestamp("substring"(parking_belltown_n_2018.occupancydatetime, 12, 8), 'HH24:MI:SS'::text)::time without time zone AS time_of_transaction,
    "substring"(parking_belltown_n_2018.occupancydatetime, 12, 2)::integer AS hour_transaction,
    "substring"(parking_belltown_n_2018.occupancydatetime, 15, 2)::integer AS min_transaction,
    "substring"(parking_belltown_n_2018.occupancydatetime, 18, 2)::integer AS seconds_transaction,
    parking_belltown_n_2018.paidoccupancy AS occupied_spots,
    parking_belltown_n_2018.parkingspacecount - parking_belltown_n_2018.paidoccupancy AS empty_spots,
    parking_belltown_n_2018.parkingspacecount AS total_spots,
    parking_belltown_n_2018.paidparkingarea,
    parking_belltown_n_2018.paidparkingsubarea,
    parking_belltown_n_2018.parkingcategory,
    parking_belltown_n_2018.parkingtimelimitcategory,
    parking_belltown_n_2018.lat AS latitude,
    parking_belltown_n_2018.lon AS longitude,
    parking_belltown_n_2018.geog,
    b."SEGKEY" AS segkey
   FROM parking_belltown_n_2018
     LEFT JOIN blockface b ON parking_belltown_n_2018.sourceelementkey = b."ELMNTKEY";

ALTER TABLE public.parking_2018_cleaned
    OWNER TO trafficjam;


----------------
--GIS (join on lat/lon)

https://stackoverflow.com/questions/14153426/postgresql-optimising-joins-on-latitudes-and-longitudes-comparing-distances


ALTER TABLE parking_belltown_n_2018 ALTER COLUMN lat TYPE double precision USING lat::double precision;
ALTER TABLE parking_belltown_n_2018 ALTER COLUMN lon TYPE double precision USING lon::double precision;

CREATE EXTENSION postgis;

ALTER TABLE parking_belltown_n_2018 ADD COLUMN geog geography(Point,4326);
UPDATE parking_belltown_n_2018 SET geog = ST_MakePoint(lon, lat);
CREATE INDEX ON parking_belltown_n_2018 USING GIST (geog);

----------------------------------------

-- changes in the view during join process
a. change lat long to double precision in the table
b. add geog column in the table
c. change time field to time without time stamp in the view
d. add segkey from blockface in the view



-----------------------------------
--2017
CREATE OR REPLACE VIEW public.parking_2017_cleaned AS
 SELECT sourceelementkey AS source_element_key,
    split_part("substring"(parking_belltown_n_2017.blockfacename, 2, length(parking_belltown_n_2017.blockfacename) - 2), ' BETWEEN'::text, 1) AS main_lane,
    split_part(split_part("substring"(parking_belltown_n_2017.blockfacename, 2, length(parking_belltown_n_2017.blockfacename) - 2), 'BETWEEN '::text, 2), ' AND'::text, 1) AS between_one,
    split_part(split_part("substring"(parking_belltown_n_2017.blockfacename, 2, length(parking_belltown_n_2017.blockfacename) - 2), 'BETWEEN '::text, 2), 'AND '::text, 2) AS between_second,
    "substring"(parking_belltown_n_2017.sideofstreet, 2, length(parking_belltown_n_2017.sideofstreet) - 2) AS sideofstreet,
    to_date("substring"(parking_belltown_n_2017.occupancydatetime, 36, 10), 'YYYY-MM-DD'::text) AS date_of_transaction,
    date_part('month'::text, to_date("substring"(parking_belltown_n_2017.occupancydatetime, 36, 10), 'YYYY-MM-DD'::text)) AS mm_transaction,
    date_part('year'::text, to_date("substring"(parking_belltown_n_2017.occupancydatetime, 36, 10), 'YYYY-MM-DD'::text)) AS yyyy_transaction,
    date_part('day'::text, to_date("substring"(parking_belltown_n_2017.occupancydatetime, 36, 10), 'YYYY-MM-DD'::text)) AS dd_transaction,
    date_part('dow'::text, to_date("substring"(parking_belltown_n_2017.occupancydatetime, 36, 10), 'YYYY-MM-DD'::text)) AS dow_transaction,
    date_part('doy'::text, to_date("substring"(parking_belltown_n_2017.occupancydatetime, 36, 10), 'YYYY-MM-DD'::text)) AS doy_transaction,
    date_part('week'::text, to_date("substring"(parking_belltown_n_2017.occupancydatetime, 36, 10), 'YYYY-MM-DD'::text)) AS week_transaction,
    --"substring"(parking_belltown_n_2017.occupancydatetime, 47, 8) AS time_of_transaction,
    to_timestamp("substring"(occupancydatetime, 47, 8), 'HH24:MI:SS'::text)::time without time zone AS time_of_transaction,
    "substring"("substring"(parking_belltown_n_2017.occupancydatetime, 47, 8), 1, 2)::integer AS hour_transaction,
    "substring"("substring"(parking_belltown_n_2017.occupancydatetime, 47, 8), 4, 2)::integer AS min_transaction,
    "substring"(parking_belltown_n_2017.paidoccupancy, 2, length(parking_belltown_n_2017.paidoccupancy) - 2)::integer AS occupied_spots,
    "substring"(parking_belltown_n_2017.parkingspacecount, 2, length(parking_belltown_n_2017.parkingspacecount) - 2)::integer - "substring"(parking_belltown_n_2017.paidoccupancy, 2, length(parking_belltown_n_2017.paidoccupancy) - 2)::integer AS empty_slots,
    "substring"(parking_belltown_n_2017.parkingspacecount, 2, length(parking_belltown_n_2017.parkingspacecount) - 2)::integer AS total_spots,
    "substring"(parking_belltown_n_2017.paidparkingarea, 2, length(parking_belltown_n_2017.paidparkingarea) - 2) AS paidparkingarea,
    "substring"(parking_belltown_n_2017.paidparkingsubarea, 2, length(parking_belltown_n_2017.paidparkingsubarea) - 2) AS paidparkingsubarea,
    "substring"(parking_belltown_n_2017.parkingcategory, 2, length(parking_belltown_n_2017.parkingcategory) - 2) AS parkingcategory,
    "substring"(parking_belltown_n_2017.parkingtimelimitcategory, 2, length(parking_belltown_n_2017.parkingtimelimitcategory) - 2) AS parkingtimelimitcategory,
    lat as latitude,
    lon as longitude,
    geog,
    b."SEGKEY" AS segkey
   FROM parking_belltown_n_2017 
   LEFT JOIN blockface b 
   ON parking_belltown_n_2017.sourceelementkey = b."ELMNTKEY"






