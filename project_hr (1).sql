CREATE SCHEMA HR_SCHEMA;

USE HR_SCHEMA;

-- creating the table
CREATE TABLE project_hr
(
employee_id INT,
department VARCHAR(250),
region VARCHAR(250),
education VARCHAR(250),
gender VARCHAR(250),
recruitment_channel VARCHAR(250),
no_of_trainings INT,
age INT,
previous_year_rating varchar(250),
length_of_service INT,
KPIs_met_more_than_80 INT,
awards_won INT,
avg_training_score INT
);


SELECT * FROM project_hr;
DESC project_hr;


-- Step 1: Removing duplicate rows

SELECT COUNT(employee_id) 
FROM project_hr;

SELECT (COUNT(employee_id) - COUNT(DISTINCT employee_id)) no_of_duplicates
FROM project_hr;

-- checking the duplicate rows
SELECT 
	employee_id, 
    count(employee_id)
FROM 
	project_hr
GROUP BY 1
HAVING 
	count(employee_id) > 1    ;

-- deleting the duplicates
DELETE FROM project_id
WHERE 
	employee_id IN (
	SELECT 
		employee_id
	FROM (
		SELECT 
			employee_id,
			ROW_NUMBER() OVER (
				PARTITION BY employee_id
				ORDER BY employee_id) AS row_num
		FROM 
			project_hr
		
	) t
    WHERE row_num > 1
);
-- dealt with duplicates


-- Step 2: Removing rows for which numeric columns are having irrelevant data type values
DESC project_hr;

SELECT DISTINCT previous_year_rating
FROM project_hr;


SELECT COUNT(previous_year_rating)
FROM project_hr
WHERE previous_year_rating = 'None';



-- finding mean, median, mode for previous_year_rating for imputing
SELECT AVG(previous_year_rating) AS MEAN
FROM project_hr
WHERE previous_year_rating != 'None';
-- mean is approx 3.34


SELECT MAX(previous_year_rating) AS MODE
FROM project_hr
WHERE previous_year_rating = (
							SELECT previous_year_rating
                            FROM project_hr
                            GROUP BY previous_year_rating
                            ORDER BY count(previous_year_rating) DESC
                            LIMIT 1)
                            ;
-- mode is 3
-- MEDIAN
								
SET @rowindex := 0;
SELECT
   AVG(pp.previous_year_rating) as Median 
FROM
   (SELECT @rowindex:=@rowindex + 1 AS rowindex,
           p.previous_year_rating AS previous_year_rating
    FROM project_hr p
    ORDER BY p.previous_year_rating) AS pp
WHERE
pp.rowindex IN (FLOOR(@rowindex / 2), CEIL(@rowindex / 2));
-- median = 3

-- So mean, mode and median values are almost near 3 hence imputing the null values with 3

-- imputing the null values
UPDATE project_hr
SET previous_year_rating = 3
WHERE previous_year_rating = 'None';


-- rechecking the null values of previous_year_rating
SELECT COUNT(previous_year_rating)
FROM project_hr
WHERE previous_year_rating = 'None';

-- Now changing the datatype to int
ALTER TABLE project_hr
MODIFY COLUMN previous_year_rating INT;

-- checking the datatype for each column
SELECT column_name, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE table_schema = 'hr_schema' AND table_name = 'project_hr';

-- we checked all the datatypes and each column is assigned correct datatype

-- checking null_values_count for each column
SELECT 
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS age_null_count,
    SUM(CASE WHEN avg_training_score IS NULL THEN 1 ELSE 0 END) AS avg_training_null_count,
    SUM(CASE WHEN awards_won IS NULL THEN 1 ELSE 0 END) AS awards_won_null_count,
    SUM(CASE WHEN department IS NULL THEN 1 ELSE 0 END) AS deapt_null_count,
    SUM(CASE WHEN education IS NULL THEN 1 ELSE 0 END) AS education_null_count,
    SUM(CASE WHEN employee_id IS NULL THEN 1 ELSE 0 END) AS employeeid_null_count,
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS gender_null_count,
    SUM(CASE WHEN KPIs_met_more_than_80 IS NULL THEN 1 ELSE 0 END) AS KPIs_null_count,
    SUM(CASE WHEN length_of_service IS NULL THEN 1 ELSE 0 END) AS length_of_service_null_count,
    SUM(CASE WHEN no_of_trainings IS NULL THEN 1 ELSE 0 END) AS no_of_trainings_null_count,
    SUM(CASE WHEN previous_year_rating IS NULL THEN 1 ELSE 0 END) AS prev_yr_rating_null_count,
    SUM(CASE WHEN recruitment_channel IS NULL THEN 1 ELSE 0 END) AS recruitment_c_null_count,
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS region_null_count
FROM
	project_hr;

-- There are no null values for any column.

/*-------------------------------------------------------------------------------------- */
-- ANALYSIS

SELECT * FROM project_hr;


/*
1. Find the average age of employees in each department and gender group.
( Round average  age up to two decimal places if needed)
*/

SELECT department, gender, ROUND(AVG(age),2) Avg_age
FROM project_hr
GROUP BY 1, 2;


/*
2. List the top 3 departments with the highest average training scores.
 ( Round average scores up to two decimal places if needed)
*/
SELECT department, ROUND(AVG(avg_training_score),2) Avg_training_score
FROM
	project_hr
GROUP BY 1
ORDER BY Avg_training_score DESC
LIMIT 3;


/*
3. Find the percentage of employees who have won awards in each region. 
(Round percentages up to two decimal places if needed)
*/

SELECT region, ROUND((SUM(awards_won)/COUNT(region))*100,2) awards_percentage
FROM project_hr
GROUP BY 1
HAVING SUM(awards_won)/COUNT(region) > 0
ORDER BY awards_percentage ;


/* 
4. Show the number of employees who have met more than 80% of
KPIs for each recruitment channel and education level.*/

SELECT recruitment_channel, education, COUNT(employee_id) no_of_employees_having_KPIs_80plus
FROM project_hr
WHERE KPIs_met_more_than_80 >0
GROUP BY 1,2;


/* 5. Find the average length of service for employees in each department,
considering only employees with previous year ratings greater than or equal to 4. 
( Round average length up to two decimal places if needed) */

SELECT department, ROUND(AVG(length_of_service),2) Avg_len_of_service
FROM project_hr
WHERE previous_year_rating >= 4
GROUP BY 1;


/* 6. List the top 5 regions with the highest average previous year ratings. 
( Round average ratings up to two decimal places if needed)*/

SELECT region, ROUND(AVG(previous_year_rating),2) Avg_prev_yr_rating
FROM project_hr
GROUP BY 1
ORDER BY Avg_prev_yr_rating DESC
LIMIT 5;


/* 7. List the departments with more than 100 employees having a length of service greater than 5 years.*/
SELECT department, COUNT(employee_id) as no_of_employee
FROM project_hr
WHERE length_of_service > 5
GROUP BY 1
HAVING COUNT(employee_id) > 100;


/* 8. Show the average length of service for employees who have attended more than 3 trainings, 
grouped by department and gender. 
( Round average length up to two decimal places if needed)*/
SELECT department, gender, ROUND(AVG(length_of_service),2) Avg_len_of_service
FROM project_hr
WHERE no_of_trainings > 3
GROUP BY 1,2;


/* 9. Find the percentage of female employees who have won awards, per department. 
Also show the number of female employees who won awards and total female employees. 
( Round percentage up to two decimal places if needed)*/
SELECT department, 
	ROUND((COUNT(CASE WHEN gender = 'f' AND awards_won > 0 THEN 1 END))/(COUNT(CASE WHEN gender = 'f' THEN 1 END))*100,2) total_F_awards_percent,
	COUNT( CASE WHEN gender = 'f' AND awards_won >0 THEN 1 END) total_F_awards,
    COUNT( CASE WHEN gender = 'f' THEN 1 END) total_F_employees
FROM project_hr
GROUP BY 1;



/* 10. Calculate the percentage of employees per department who have a length of service between 5 and 10 years. 
( Round percentage up to two decimal places if needed)*/
SELECT department, ROUND(COUNT(CASE WHEN length_of_service BETWEEN 5 AND 10 THEN 1 END)/(COUNT(*))*100,2) PERCENT_of_emp
FROM project_hr
GROUP BY 1;


/* 11. Find the top 3 regions with the highest number of employees who have met more than 80% of their KPIs 
and received at least one award, grouped by department and region.*/
SELECT department, region, COUNT(employee_id) no_of_employees
FROM project_hr
WHERE KPIs_met_more_than_80 > 0 AND awards_won > 0
GROUP BY 1,2
ORDER BY no_of_employees DESC
LIMIT 3;


/* 12. Calculate the average length of service for employees per education level and gender, considering only those employees 
who have completed more than 2 trainings and have an average training score greater than 75 
( Round average length up to two decimal places if needed)*/
SELECT education, gender, ROUND(AVG(length_of_service),2) avg_len_of_service
FROM project_hr
WHERE no_of_trainings > 2 AND avg_training_score > 75
GROUP BY 1,2;


/* 13. For each department and recruitment channel, find the total number of employees 
who have met more than 80% of their KPIs, have a previous_year_rating of 5, 
and have a length of service greater than 10 years.*/
SELECT department, recruitment_channel, COUNT(*) no_of_employees
FROM project_hr
WHERE previous_year_rating = 5 AND length_of_service > 10 AND KPIs_met_more_than_80 > 0
GROUP BY 1,2;


/* 14. Calculate the percentage of employees in each department who have received awards, have a previous_year_rating of 4 or 5, 
and an average training score above 70, grouped by department and gender 
( Round percentage up to two decimal places if needed).*/
SELECT department, gender, 
ROUND((COUNT(CASE WHEN awards_won > 0 AND previous_year_rating in (4,5) AND avg_training_score>70 THEN 1 END))/(COUNT(*))*100,2) percentage_of_employees
FROM project_hr
GROUP BY 1,2
ORDER BY percentage_of_employees DESC;


/*
15. List the top 5 recruitment channels with the highest average length of service for employees 
who have met more than 80% of their KPIs, have a previous_year_rating of 5, and an age between 
25 and 45 years, grouped by department and recruitment channel. 
( Round average length up to two decimal places if needed). */
SELECT department, recruitment_channel, ROUND(AVG(length_of_service),2) avg_len_of_service
FROM project_hr
WHERE KPIs_met_more_than_80 > 0 AND previous_year_rating = 5 AND age BETWEEN 25 AND 45
GROUP BY 1,2
ORDER BY avg_len_of_service DESC
LIMIT 5;



/*----------------------------------------------------------*/
SELECT age, AVG(previous_year_rating) avg_prev_yr_rating
FROM project_hr
GROUP BY 1
ORDER BY avg_prev_yr_rating DESC;




