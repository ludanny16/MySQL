-- Load sakila database
USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.

SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT CONCAT(first_name, ' ', last_name) AS 'Actor Name'
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name LIKE "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:

SELECT first_name, last_name
FROM actor
WHERE last_name LIKE "%G%E%N%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT last_name, first_name
FROM actor
WHERE last_name LIKE "%L%I%";

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.

ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(255) AFTER first_name;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.

ALTER TABLE actor
MODIFY COLUMN middle_name BLOB;


-- 3c. Now delete the middle_name column.

ALTER TABLE actor
DROP COLUMN middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT count(*), last_name
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT count(*), last_name
FROM actor
GROUP BY last_name
HAVING COUNT(*) > 1;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

SELECT actor_id, last_name, first_name
FROM actor
WHERE first_name = "GROUCHO";

UPDATE actor
SET first_name = "HARPO"
WHERE actor_id = 172;

-- Double check if data have been updated
SELECT actor_id, last_name, first_name
FROM actor
WHERE first_name = "HARPO";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
UPDATE actor
SET first_name = "GROUCHO"
WHERE actor_id = 172;

-- Double check if data have been updated
SELECT actor_id, last_name, first_name
FROM actor
WHERE actor_id = 172;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

SHOW CREATE TABLE sakila.address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

-- Find matching values in both tables/address_id
SELECT* FROM staff;
SELECT* FROM address;

-- Inner Join

SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

-- Find matching values in both tables/staff_id
SELECT* FROM staff;
SELECT* FROM payment;

-- Inner Join

SELECT staff.staff_id, staff.last_name, staff.first_name, SUM(amount) as total_amount
FROM payment
INNER JOIN staff ON staff.staff_id = payment.staff_id
WHERE payment_date LIKE "2005-08%"
GROUP BY staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

-- Find matching values in both tables/film_id
SELECT* FROM film_actor;
SELECT* FROM film;

-- Inner Join

SELECT film.film_id, film.title, COUNT(actor_id) as number_of_actors
FROM film_actor
INNER JOIN film ON film_actor.film_id = film.film_id
GROUP BY film_id;

-- 6d. How many copies of the film (Hunchback Impossible) exist in the inventory system?

SELECT inventory.film_id, film.title, COUNT(inventory.film_id)
FROM inventory 
INNER JOIN film
USING(film_id)
GROUP BY inventory.film_id
HAVING film.title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

-- Find matching values in both tables/customer_id
SELECT* FROM customer;
SELECT* FROM payment;

--  Use JOIN Command

SELECT customer_id, c.last_name, c.first_name, SUM(amount) as total_paid
FROM payment AS p
JOIN customer AS c
USING(customer_id)
GROUP BY customer_id
ORDER BY last_name;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
FROM film
WHERE title LIKE "K%" OR title LIKE "Q%"
AND 
language_id IN
(
SELECT language_id
FROM language 
WHERE name="English"
); 


-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT actor_id, first_name, last_name
FROM actor 
WHERE actor_id IN
	(
	SELECT actor_id
	FROM film_actor
	WHERE film_id in
		(
		SELECT film_id 
		FROM film 
		WHERE title = "Alone Trip"
		)
	)
ORDER BY last_name;


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT CONCAT(first_name, ' ', last_name) AS 'Customer Name', email AS 'Email Address'
FROM customer
JOIN address
USING (address_id)
JOIN city
USING(city_id)
JOIN country
USING(country_id)
WHERE country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.

SELECT film_id, title, rating
FROM film
WHERE film_id IN  
	(
	SELECT film_id
	FROM film_category
	WHERE category_id in 

		(SELECT category_id
		FROM category
		WHERE name = 'Family'
		)
	);

-- 7e. Display the most frequently rented movies in descending order.

SELECT i.film_id, title, COUNT(film_id) AS Most_Popular_Movies
FROM rental AS r
JOIN inventory AS i
USING(inventory_id)
JOIN film AS f
USING(film_id)
GROUP BY film_id
ORDER BY Most_Popular_Movies DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT store_id, SUM(amount) AS Store_Revenue
FROM payment
JOIN staff
USING(staff_id)
GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT store_id, city, country 
FROM store
INNER JOIN address
USING(address_id)
INNER JOIN city
USING(city_id)
INNER JOIN country
USING(country_id); 

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

-- Check generes in category table
SELECT*
FROM category;

-- Display Data by Top Five Genres

SELECT category_id, category.name, SUM(amount) AS Gross_Revenue
FROM payment
JOIN rental
USING(rental_id)
JOIN inventory
USING(inventory_id)
JOIN film_category
USING(film_id)
JOIN category
USING (category_id)
GROUP BY category_id
ORDER BY Gross_Revenue DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_genres AS

SELECT category_id, category.name, SUM(amount) AS Gross_Revenue
FROM payment
JOIN rental
USING(rental_id)
JOIN inventory
USING(inventory_id)
JOIN film_category
USING(film_id)
JOIN category
USING (category_id)
GROUP BY category_id
ORDER BY Gross_Revenue DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?

SELECT * 
FROM top_five_genres;


-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top_five_genres;






