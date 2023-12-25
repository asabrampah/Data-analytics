
SELECT *
FROM employee;
-- extract 
SELECT CONCAT( 
	LOWER(REPLACE(employee_name,' ','.')), '@ndogowater.gov')
    AS new_email
FROM employee;
-- update employee table, add staff email address  by replacing space btw first and last name with '.' and adding company domain name(@ndogowater.gov)
UPDATE employee
	SET email= CONCAT( 
	LOWER(REPLACE(employee_name,' ','.')), '@ndogowater.gov');
-- extract data from the employee table --
SELECT *
FROM employee;
-- view phone number column, trim phone number column to remove extra space character and count the lengh of phone number characters in phone number column --
SELECT phone_number, TRIM(phone_number) AS updated_contact,LENGTH(TRIM(phone_number)) AS contact_length
FROM employee;
-- update phone_number, trim phone numbers to remove extra space character --
UPDATE employee
	SET phone_number= TRIM(phone_number);
-- Use the employee table to count how many of our employees live in each town. --
SELECT 
	town_name, 
    COUNT(town_name) AS staff_count
FROM employee
GROUP BY town_name;
-- determine the employee_id of top 3 employees with highest visits --
SELECT assigned_employee_id, COUNT(visit_count) AS number_of_visits
FROM visits
GROUP BY assigned_employee_id
ORDER BY SUM(visit_count) DESC
LIMIT 3;
/* Let's first look at the number of records each employee collected. So find the correct table, figure out what function to use and how to group, order
and limit the results to only see the top 3 employee_ids with the highest number of locations visited.*/
SELECT assigned_employee_id, employee_name, email, phone_number, position
FROM employee
WHERE assigned_employee_id IN (1, 30, 34);
-- Create a query that counts the number of records per town and province --
SELECT town_name, COUNT(town_name) AS number_of_people
FROM location
GROUP BY town_name;
SELECT province_name, COUNT(town_name) AS number_of_people
FROM location
GROUP BY province_name;
/*1. Create a result set showing:
• province_name
• town_name
• An aggregated count of records for each town (consider naming this records_per_town).
• Ensure your data is grouped by both province_name and town_name.
2. Order your results primarily by province_name. Within each province, further sort the towns by their record counts in descending order.*/
SELECT
	province_name,
    town_name,
	COUNT(town_name)  AS records_per_town
FROM location
GROUP BY province_name, town_name
ORDER BY province_name, COUNT(town_name) DESC;
-- look at the number of records for each location type --
SELECT location_type, COUNT(location_type) AS records_per_location_type
FROM location
GROUP BY location_type;
SELECT SUM(number_of_people_served) AS population
FROM water_source;
-- we want to count how many of each of the different water source types there are, --
SELECT type_of_water_source, COUNT(type_of_water_source) AS total
FROM water_source
GROUP BY type_of_water_source
ORDER BY type_of_water_source DESC;
-- What is the average number of people that are served by each water source? --
SELECT type_of_water_source, ROUND(AVG(number_of_people_served),2) AS average_consumption, ROUND(AVG(number_of_people_served), 0) AS average_consumption_rounded
FROM water_source
GROUP BY type_of_water_source;
/* calculate the total number of people served by each type of water source in total, to make it easier to interpret, order them so the most
people served by a source is at the top.*/
SELECT 
	type_of_water_source, 
    SUM(number_of_people_served) AS total_no_of_people_served, 
	SUM(number_of_people_served)/27628140*100 AS percentage_of_people_served, 
    ROUND(SUM(number_of_people_served)/27628140*100) AS percentage_of_people_served_rounded 
FROM water_source
GROUP BY type_of_water_source
ORDER BY SUM(number_of_people_served) DESC;
-- rank the total number of people served based on the type of water source excluding tap in home type of water source--
SELECT
	type_of_water_source,
    SUM(number_of_people_served) AS total_no_of_people_served,
    rank() OVER (ORDER BY SUM(number_of_people_served)DESC) AS rankings
FROM water_source
WHERE type_of_water_source <> 'tap_in_home'
GROUP BY type_of_water_source
ORDER BY SUM(number_of_people_served) DESC;
-- rank the total number of people served based on the type of water source and source id excluding tap in home type of water source--
SELECT 
	source_id,
    type_of_water_source,
    number_of_people_served,
		RANK() OVER (PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC) AS priority_ranking
FROM water_source
	WHERE type_of_water_source <> 'tap_in_home'
        ORDER BY number_of_people_served DESC;
-- rank the total number of people served based on the type of water source and source id excluding tap in home type of water source using row numbers--
SELECT
source_id,
    type_of_water_source,
    number_of_people_served,
		ROW_NUMBER() OVER (PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC) AS priority_ranking
FROM water_source
	WHERE type_of_water_source <> 'tap_in_home'
        ORDER BY number_of_people_served DESC;
SELECT *
FROM visits; 
-- calculate how long the survey took --
SELECT MIN(time_of_record) AS start_date, MAX(time_of_record) AS end_date, DATEDIFF('2021-01-01 09:10:00', '2023-07-14 13:53:00') AS survey_time_period
FROM visits;      
        SELECT MIN(time_of_record) AS start_date, MAX(time_of_record) AS end_date, DATEDIFF(MIN(time_of_record), MAX(time_of_record)) AS survey_time_period
FROM visits;
-- how long people have to queue on average in Maji Ndogo. Keep in mind that many sources like taps_in_home have no queues --
SELECT AVG(NULLIF(time_in_queue,0)) AS avg_time_in_queue
FROM visits;
-- let's look at the queue times aggregated across the different days of the week. --
SELECT DAYNAME(time_of_record) AS day_of_the_week, AVG(NULLIF(time_in_queue,0)) AS avg_time_in_queue, ROUND(AVG(NULLIF(time_in_queue,0))) AS avg_time_in_queue_rounded
FROM visits
GROUP BY DAYNAME(time_of_record);
-- look at what time during the day people collect water. --
SELECT TIME_FORMAT(time_of_record, '%H:00') AS hour_of_day, ROUND(AVG(NULLIF(time_in_queue,0))) AS avg_time_in_queue_rounded
FROM visits
GROUP BY TIME_FORMAT(time_of_record, '%H:00')
ORDER BY TIME_FORMAT(time_of_record, '%H:00');
-- average queue time per hour for each day --
SELECT TIME_FORMAT(time_of_record, '%H:00') AS hour_of_day, 
	ROUND(AVG(
    CASE 
    		WHEN DAYNAME(time_of_record) = 'Sunday' THEN (time_in_queue) 
       ELSE NULL
	END
),0) AS Sunday,
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
ELSE NULL
END
),0) AS Monday,
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
ELSE NULL
END
),0) AS Tuesday,
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
ELSE NULL
END
),0) AS Wednesday,
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
ELSE NULL
END
),0) AS Thursday,
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
ELSE NULL
END
),0) AS Friday,
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
ELSE NULL
END
),0) AS Saturday
FROM visits
 WHERE time_in_queue !=0
GROUP BY TIME_FORMAT(time_of_record, '%H:00')
ORDER BY  TIME_FORMAT(time_of_record, '%H:00');