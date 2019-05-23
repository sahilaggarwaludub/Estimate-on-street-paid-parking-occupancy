-- Data cleaning for table annual_parking
-- Last updated 3/12/2019 by Allison Chapman

-- Change text columns to integer, replacing spaces with NULL
ALTER TABLE annual_parking
ALTER COLUMN bmw_dn TYPE int USING NULLIF(bmw_dn,' ')::integer,
ALTER COLUMN dp_count TYPE int USING NULLIF(dp_count,' ')::integer,
ALTER COLUMN elmntkey TYPE int USING NULLIF(elmntkey, ' ')::integer,
ALTER COLUMN parking_spaces TYPE int USING NULLIF(parking_spaces, ' ')::integer,
ALTER COLUMN rpz_blocks TYPE int USING NULLIF(rpz_blocks,' ')::integer,
ALTER COLUMN rpz_count TYPE int USING NULLIF(rpz_count,' ')::integer,
ALTER COLUMN study_year TYPE int USING NULLIF(study_year,' ')::integer,
ALTER COLUMN tg_car2go TYPE int USING NULLIF(tg_car2go,' ')::integer,
ALTER COLUMN total_vehicle_count TYPE int USING NULLIF(total_vehicle_count,' ')::integer;

-- Add study_month and study_day fields. study_year already exists.
-- Adding as text for now to populate more easily from text date_time field
-- Will update to int later
ALTER TABLE annual_parking
ADD COLUMN study_month text,
ADD COLUMN study_day text;

-- Split date_time into study_month and study_day fields using '-' separator
UPDATE annual_parking
SET study_month = split_part(date_time::TEXT,'-', 1)
SET study_day = split_part(date_time::TEXT,'-', 2);

-- Update study_month and study_day to integer
ALTER TABLE annual_parking
ALTER COLUMN study_month TYPE int USING study_month::integer,
ALTER COLUMN study_day TYPE int USING study_day::integer;

-- Add time column. Doing it this way in case something goes wrong splitting the time_stamp column
ALTER TABLE annual_parking
ADD COLUMN study_time text;

-- Drop date and 'T' (first 11 characters) from time_stamp
-- Ignore ' ' for now and replace with NULL later
UPDATE annual_parking
SET study_time = RIGHT(time_stamp, -11);

-- Update study_time to time format, changing '' to NULL
ALTER TABLE annual_parking
ALTER COLUMN study_time TYPE time USING NULLIF(study_time,'')::time

-- Create date field
ALTER TABLE annual_parking
ADD COLUMN study_date text;

-- Populate date field with first part of date_time field
UPDATE annual_parking
SET study_date = LEFT(date_time, -9)

-- Change study_date to date datatype
ALTER TABLE annual_parking
ALTER COLUMN study_date TYPE date USING NULLIF(study_date, '')::date;

-- Update csm, sub_area and time_stamp with NULL for missing
UPDATE annual_parking
SET csm = NULLIF(csm, ' ');

UPDATE annual_parking
SET sub_area = NULLIF(sub_area, ' ');

UPDATE annual_parking
SET time_stamp = NULLIF(time_stamp, ' ');

-- Update study_time with time from date_time (hour grain) if NULL
UPDATE annual_parking
SET study_time = 
CASE WHEN study_time ISNULL THEN CAST(RIGHT(date_time, 8) AS time)
	ELSE study_time
END

-- Split unitdesc into three fields
-- Create new fields
ALTER TABLE annual_parking
ADD COLUMN main_lane text,
ADD COLUMN between_one text,
ADD COLUMN between_second text;

-- Set fields using split_part
UPDATE annual_parking
SET main_lane = split_part(unitdesc, ' BETWEEN', 1);

UPDATE annual_parking
SET between_one = split_part(split_part(unitdesc, 'BETWEEN ', 2), ' AND', 1);

UPDATE annual_parking
SET between_second = split_part(split_part(unitdesc, 'BETWEEN ', 2), 'AND ', 2);