-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?
use sakila;
select * from inventory;

-- how many copies for each films? 
select film_id, count(*) copiesofeachfilms from inventory
group by film_id
order by count(*); 

-- what is the film id of hunchback impossible?
select * from film
where title = 'Hunchback Impossible';

-- use subquery to merge = 6 copies
select film_id, count(*) hunchback_copies from inventory
where film_id = (select film_id from film where title = 'Hunchback Impossible')
group by film_id;

-- 2.List all films whose length is longer than the average of all the films.
select * from film
where length > ?
order by length;

-- what is average of all the films?
select avg(length) from film;

-- complete query
select * from film
where length > (select avg(length) from film)
order by length;

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.
select actor_id from film_actor
where film_id = 12; -- ? which number ?

-- find out what is film_id of alone trip
select film_id from film
where title ='Alone Trip';

select actor_id from film_actor
where film_id = (select film_id from film where title ='Alone Trip');


-- 4. Sales have been lagging among young families, 
-- and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

select film_id from film_category
where category_id = ?;

select category_id from category
where name = 'family';

select film_id from film_category
where category_id = (select category_id from category
where name = 'family');

-- 5. Get name and email from customers from Canada using subqueries.
select * from country;
select * from city;
select * from address;

-- identify country id of canada from country table
select country_id, country from country where country='canada';

-- find city_id from city table (sub query with canada)
select city_id from city
where country_id = (select country_id from country where country='canada');

-- find address_id from address table (from sub query with city_id from city table ( sub query of canada)
select address_id from address
where city_id in (select city_id from city where country_id = (select country_id from country where country='canada'));

-- find customer info which matching with address_id using subquery
select first_name,last_name,email from customer
where address_id in (select address_id from address where city_id in (select city_id from city where country_id = (select country_id from country where country='canada')))
order by first_name;

-- 5-1 Do the same with joins. Note that to create a join, 
-- you will have to identify the correct tables with their primary keys and foreign keys, 
-- that will help you get the relevant information.

select * from country;
select * from city;
select * from address;
select * from customer;

select c.first_name, c.last_name, c.email from customer c
join address ad on c.address_id = ad.address_id
join city ci on ad.city_id = ci.city_id
join country co on ci.country_id = co.country_id
where country = 'canada'
order by first_name;

-- 6.Which are films starred by the most prolific actor? 
-- Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

-- prolific actor_id = 107
select actor_id from film_actor
group by actor_id
order by count(film_id) desc
limit 1;

-- films list played by actor 107 
select film_id from film_actor
where actor_id = (select actor_id from film_actor
group by actor_id
order by count(film_id) desc
limit 1);

-- film title of those film_id
select film_id, title from film
where film_id in (select film_id from film_actor
where actor_id = (select actor_id from film_actor
group by actor_id
order by count(film_id) desc
limit 1));

-- 7.Films rented by most profitable customer. You can use the customer table and payment table to
-- find the most profitable customer ie the customer that has made the largest sum of payments

-- who is the most profitable customer
select customer_id from payment
group by customer_id
order by sum(amount) desc
limit 1;

-- inventory_id of rented by customer id 526

select inventory_id from rental
where customer_id = (select customer_id from payment
group by customer_id
order by sum(amount) desc
limit 1);

-- film_id of those inventory_ids
select distinct film_id from inventory
where inventory_id in (select inventory_id from rental
where customer_id = (select customer_id from payment
group by customer_id
order by sum(amount) desc
limit 1))
order by film_id;

-- I want to know the title of those film_ids

select title, film_id from film
where film_id in (select distinct film_id from inventory
where inventory_id in (select inventory_id from rental
where customer_id = (select customer_id from payment
group by customer_id
order by sum(amount) desc
limit 1)))
order by title;
