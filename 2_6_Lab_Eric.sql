USE sakila;

-- 1. Which are the actors whose last names are not repeated?

SELECT first_name, last_name, COUNT(*) OVER (PARTITION BY last_name) as number_homonyms
FROM sakila.actor;

-- SELECT first_name, last_name, COUNT(*) OVER (PARTITION BY last_name) as number_homonyms
-- FROM sakila.actor
-- HAVING number_homonyms = 1;

-- SELECT first_name, last_name, COUNT(*) OVER (PARTITION BY last_name) as number_homonyms
-- FROM sakila.actor
-- HAVING COUNT(last_name) = 1;

-- SELECT first_name, last_name, COUNT(*) OVER (PARTITION BY last_name) as number_homonyms
-- FROM sakila.actor
-- WHERE number_homonyms = 1;

-- Willing to return first names & last names for the concerned actors, I first had  the idea to use
-- 'Partition By' to add a column after each name with the count of homonyms in the table.
-- This worked, but I then wanted to filter on this extra columns using WHERE or HAVING and I never
-- managed to have it working.
-- Looking for inspiration online, I saw some scripts nesting loops and this gave me the idea to use the loop 
-- created above and filter it out another loop. And it worked !!

SELECT first_name, last_name, number_homonyms
FROM 
	( SELECT first_name, last_name, COUNT(*) OVER (PARTITION BY last_name) AS number_homonyms
		FROM sakila.actor) AS actor_homonyms
WHERE number_homonyms = 1;
-- output = 66 actors with a unique last_name

-- if the list of last names was enough, the solution would be much simpler :
SELECT last_name, COUNT(*) as number_homonyms
FROM sakila.actor
GROUP BY last_name
HAVING number_homonyms = 1;



-- 2. Which last names appear more than once? We would use the same logic as in the previous question but this time
-- we want to include the last names of the actors where the last name was present more than once

SELECT first_name, last_name, number_homonyms
FROM 
( SELECT first_name, last_name, COUNT(*) OVER (PARTITION BY last_name) AS number_homonyms
FROM sakila.actor) AS actor_homonyms
WHERE number_homonyms > 1; 
-- output = 134 actors with a repeated last_name

-- if the list of last names was enough, the solution would be much simpler :
SELECT last_name, COUNT(*) as number_homonyms
FROM sakila.actor
GROUP BY last_name
HAVING number_homonyms > 1;
-- output = 55 last_names that appear more than once


-- 3. Using the rental table, find out how many rentals were processed by each employee.

SELECT staff_id, COUNT(rental_id)
FROM sakila.rental
GROUP BY staff_id;
-- output : employee 1 - 8 040 rentals / employee 2 - 8 004 rentals


-- 4. Using the film table, find out how many films were released each year.
SELECT release_year, COUNT(film_id)
FROM sakila.film
GROUP BY release_year;
-- output : 1000 movies in 2006

-- 5. Using the film table, find out for each rating how many films were there.

SELECT rating, COUNT(film_id)
FROM sakila.film
GROUP BY rating;
-- output : PG : 194 / G : 178 / NC-17 : 210 / etc.

-- 6. What is the mean length of the film for each rating type. Round off the average lengths to two decimal places

SELECT rating, ROUND(AVG(length), 2) AS average_length
FROM sakila.film
GROUP BY rating;
-- output is a table : PG : 112.01 / G : 111.05 / NC-17 : 113.23/ etc.

-- 7. Which kind of movies (rating) have a mean duration of more than two hours?

SELECT rating, ROUND(AVG(length), 2) AS average_length
FROM sakila.film
GROUP BY rating
HAVING average_length > 120;
-- output : only one category, PG-13 (120.44)



-- 8. Rank films by length (filter out the rows that have nulls or 0s in length column). In your output, only select
-- the columns title, length, and the rank.

SELECT title, length, RANK() OVER (ORDER BY length DESC) AS length_rank
FROM sakila.film
WHERE (length IS NOT NULL) AND (length != 0);
