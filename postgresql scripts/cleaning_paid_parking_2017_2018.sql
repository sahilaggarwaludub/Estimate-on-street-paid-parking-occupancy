2018

CREATE VIEW parking_2018_clean
AS
SELECT split_part(blockfacename,' BETWEEN',1) as main_lane
	   , split_part(split_part(blockfacename,'BETWEEN ',2),' AND',1) as between_one
	   , split_part(split_part(blockfacename,'BETWEEN ',2),'AND ',2) as between_second
	   , sideofstreet
	   , to_date(substring(occupancydatetime,0,11),'YYYY-MM-DD') as date_of_transaction
	   , extract(month from to_date(substring(occupancydatetime,0,11),'YYYY-MM-DD')) as mm_transaction
	   , extract(year from to_date(substring(occupancydatetime,0,11),'YYYY-MM-DD')) as yyyy_transaction
	   , extract(day from to_date(substring(occupancydatetime,0,11),'YYYY-MM-DD')) as dd_transaction
	   , extract(dow from to_date(substring(occupancydatetime,0,11),'YYYY-MM-DD')) as dow_transaction					  
	   , extract(doy from to_date(substring(occupancydatetime,0,11),'YYYY-MM-DD')) as doy_transaction
	   , extract(week from to_date(substring(occupancydatetime,0,11),'YYYY-MM-DD')) as week_transaction							  
	   , substring(occupancydatetime,12,8) as time_of_transaction -- still in text
	   , cast(substring(occupancydatetime,12,2) AS INTEGER) as hour_transaction -- still in text
	   , cast(substring(occupancydatetime,15,2) AS INTEGER) as min_transaction -- still in text
	   , cast(substring(occupancydatetime,18,2) AS INTEGER) as seconds_transaction -- still in text							  
	   , paidoccupancy as occupied_spots
	   , (parkingspacecount-paidoccupancy) as empty_spots
	   , parkingspacecount as total_spots
	   , paidparkingarea
	   , paidparkingsubarea
	   , parkingcategory
	   , parkingtimelimitcategory
	   , cast(lat as DOUBLE PRECISION) as latitude
	   , cast(lon as DOUBLE PRECISION) as longitude
FROM parking_belltown_n_2018
limit 10								   
		

----------------------------------------------------
2017


CREATE VIEW parking_2017_clean
AS
SELECT split_part(substring(blockfacename,2,length(blockfacename)-2),' BETWEEN',1) as main_lane
	   , split_part(split_part(substring(blockfacename,2,length(blockfacename)-2),'BETWEEN ',2),' AND',1) as between_one
	   , split_part(split_part(substring(blockfacename,2,length(blockfacename)-2),'BETWEEN ',2),'AND ',2) as between_second
	   , substring(sideofstreet,2,length(sideofstreet)-2) 
	   , to_date(substring(occupancydatetime,36,10),'YYYY-MM-DD') as date_of_transaction
	   , extract(month from to_date(substring(occupancydatetime,36,10),'YYYY-MM-DD')) as mm_transaction
	   , extract(year from to_date(substring(occupancydatetime,36,10),'YYYY-MM-DD')) as yyyy_transaction
	   , extract(day from to_date(substring(occupancydatetime,36,10),'YYYY-MM-DD')) as dd_transaction
	   , extract(dow from to_date(substring(occupancydatetime,36,10),'YYYY-MM-DD')) as dow_transaction					  
	   , extract(doy from to_date(substring(occupancydatetime,36,10),'YYYY-MM-DD')) as doy_transaction
	   , extract(week from to_date(substring(occupancydatetime,36,10),'YYYY-MM-DD')) as week_transaction							  
	   , substring(occupancydatetime,47,8) as time_of_transaction -- still in text
	   , cast(substring(substring(occupancydatetime,47,8),1,2) AS INTEGER) as hour_transaction 
	   , cast(substring(substring(occupancydatetime,47,8),4,2) AS INTEGER) as min_transaction 
       , cast(substring(paidoccupancy,2,length(paidoccupancy)-2) AS INTEGER) as occupied_spots
	   , cast(substring(parkingspacecount,2,length(parkingspacecount)-2) AS INTEGER) as total_spots
	   , (cast(substring(parkingspacecount,2,length(parkingspacecount)-2) AS INTEGER)) - (cast(substring(paidoccupancy,2,length(paidoccupancy)-2) AS INTEGER)) as empty_slots
	   , substring(paidparkingarea,2,length(paidparkingarea)-2) as paidparkingarea
	   , substring(paidparkingsubarea,2,length(paidparkingsubarea)-2) as paidparkingsubarea
	   , substring(parkingcategory,2,length(parkingcategory)-2) as parkingcategory
	   , substring(parkingtimelimitcategory,2,length(parkingtimelimitcategory)-2) as parkingtimelimitcategory
	   , cast(substring(lat,2,length(lat)-2) as DOUBLE PRECISION) as latitude
	   , cast(substring(lon,2,length(lon)-2) as DOUBLE PRECISION) as longitude
FROM parking_belltown_n_2017
limit 10		