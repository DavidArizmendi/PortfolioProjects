--THIS IS AN NYC AIRBNB RELATED PROJECT 
--I OBTAINED THE DATA FROM: http://insideairbnb.com/get-the-data

--THESE QUERIES SHOW SOME OF THE ANALYSIS I CAN DO USING SQL 
--THESE DATA CAN ALSO BE VISUALIZED ON TABLEAU, WHICH I HAVE DONE:
--HERE IS THE LINK TO MY NYC AIRBNB DASHBOARD: https://public.tableau.com/app/profile/david.arizmendi.flores

--I WILL ALSO LEAVE THE LINK TO MY TABLEAU PUBLIC WHERE I HAVE ADDED SOME OF THE ANALYSES I DO FOR FUN (: 
--TABLEAU PUBLIC: https://public.tableau.com/app/profile/david.arizmendi.flores



--SQL QUERIES FOR NYC AIRBNB 


--SECTION 1 


--1) Return everything from the neighborhoods table.

SELECT *
FROM neighborhoods;


--2) Return the price column from the listings table.

SELECT price
FROM listings;


--3) Return the first 10 rows of ALL the "availability" columns from the listings table.

SELECT has_availability, availability_30, availability_60, availability_90
FROM listings
LIMIT 10;


--4) According to the listings table, how many reviews have been left in total? Alias this as "total_reviews"

SELECT SUM(number_of_reviews) AS total_reviews
FROM listings;


--5) How many unique reviewers are there? Alias this as "unique_reviewers".

SELECT COUNT(DISTINCT reviewer_id) AS unique_reviewers
FROM reviews;


--6) What date was the earliest review posted? How about the most recent review?

SELECT MIN(review_date), MAX(review_date)
FROM reviews;


--7) Return a list of the unique neighborhoods in alphabetical order.

SELECT DISTINCT neighborhood
FROM neighborhoods. (THIS MIGHT BE neighbourhood?)
ORDER BY neighborhood;


--8) Return the room type and the number of people the listing accommodates. Sort first by room type alphabetically, then by accommodation number from highest to lowest.

SELECT room_type, accommodates
FROM listings
ORDER BY room_type, accommodates DESC
LIMIT 150;


--9) Return the names and number of listings for all the hosts who have more than one listing. Sort it from most to fewest listings.

SELECT host_id, name, host_listings_count
FROM hosts
WHERE host_listings_count > 1
ORDER BY host_listings_count DESC
LIMIT 25;


--10) Return the 10 newest hosts (i.e. the hosts who joined Airbnb most recently). Exclude any rows with null values in either the name or host_since columns.

SELECT name, host_since
FROM hosts
WHERE host_since IS NOT NULL AND name IS NOT NUlL
ORDER BY host_since DESC
LIMIT 10;


--11) Return all the listings that have an overall rating below 10 or above 89. Alias the rating column as "listing_rating".

SELECT listing_id, overall_rating AS listing_rating
FROM review_scores
WHERE overall_rating NOT BETWEEN 11 AND 89;


--12) Return the listing ID and neighborhood of all listings located in a neighborhood whose name includes "Heights".

SELECT listing_id, neighborhood
FROM listings
WHERE neighborhood LIKE '%Heights%';


--13) How many superhosts registered with Airbnb in 2012?

SELECT COUNT(host_id)
FROM hosts
WHERE EXTRACT(year from host_since) = 2012
AND is_superhost = 'true';


--14) How many listings contain the word "cozy" somewhere in their title?

SELECT COUNT(listing_title)
FROM listings
WHERE listing_title LIKE '%_ozy%';


--15) Find all the reviews written by someone with one of the following names: Triston, Xiomara, Salvatore, Jamari, Tomeika, Bertram. For each of these reviews, return the reviewer's name and their comments.

SELECT reviewer_name, comments
FROM reviews
WHERE reviewer_name IN ('Triston', 'Xiomara', 'Salvatore', 'Jamari', 'Tomeika', 'Bertram');


--16) Using the calendar table, return all the availabilities for the month of December of this year. Only include availabilities less than $200/night. Order the results chronologically and show the cheaper listings first.

SELECT listing_id, booking_date, price
FROM calendar
WHERE price < 200
AND available = 'true'
AND booking_date BETWEEN '2020-12-01' AND '2020-12-31'
ORDER BY booking_date, price;


--17) What is the average price per night for each borough?

SELECT borough, AVG(price)
FROM listings
GROUP BY borough;


--18) What are the average 30-, 60-, and 90-day availabilities of listings in each neighborhood of each borough? Alias the averages if desired. Sort the results alphabetically by borough then neighborhood.

SELECT borough, neighborhood, AVG(availability_30) AS avg_avail_30, 
AVG(availability_60) AS avg_avail_60, 
AVG(availability_90) AS avg_avail_90
FROM listings
GROUP BY borough, neighborhood
ORDER BY borough, neighborhood;


--19) How many hosts fall into each response time category? Alias the count as "num_hosts".

SELECT response_time, COUNT(host_id) AS num_hosts
FROM hosts
GROUP BY response_time
HAVING response_time IS NOT NULL;


--20) How many Manhattan listings fall into each room type category? Alias the count as "num_manhattan_listings".

SELECT room_type, COUNT(listing_id) AS num_manhattan_listings
FROM listings
GROUP BY room_type, borough
HAVING borough = 'Manhattan';


--21) Return the number of listings in each neighborhood, only including neighborhoods that have listings between 50 and 100. Alias this count as num_listings. Order it by the number of listings smallest to largest.

SELECT borough, neighborhood, COUNT(listing_id) AS num_listings
FROM listings
GROUP BY borough, neighborhood
HAVING COUNT(listing_id) BETWEEN 50 AND 100
ORDER BY num_listings;


--22) Return all the listings and that have overall ratings within 10 points of the average rating for the whole table. Alias the ratings as "listing_rating".

SELECT listing_id, overall_rating AS listing_rating
FROM review_scores
GROUP BY listing_id, overall_rating
HAVING overall_rating BETWEEN (AVG(overall_rating) - 10) 
AND (AVG(overall_rating) + 10);



--SECTION 2


--1) Do an inner join of listings and hosts based on host_id. Return the listing's title, neighborhood, and price as well as the host's name (aliased as "host_name") and response_time.

SELECT listing_title, l.neighborhood, l.price, name AS host_name, response_time
FROM listings AS l
INNER JOIN hosts AS h
USING (host_id);


--2) Do an inner join of listings and hosts based on host_id AND neighborhood. Return the listing's title, neighborhood, and price as well as the host's name (aliased as "host_name") and response_time.

SELECT listing_id, listing_title, l.neighborhood, l.price, name AS host_name, response_time
FROM listings AS l
INNER JOIN hosts AS h
ON l.host_id = h.host_id
AND l.neighborhood = h.neighborhood;


--3) Do a left join for review_scores and reviews based on listing_id. Return the listing_id and the reviewer's name as well as their comments, ratings, and scores.

SELECT rs.listing_id, reviewer_name, comments, overall_rating, 
location_score, cleanliness_score, communication_score, checkin_score
FROM review_scores AS rs
LEFT JOIN reviews AS r
USING (listing_id)
LIMIT 100;


--4) Find out the communication score for listings that have hosts with a response rate between 1% and 30%. Return the host_id, name, listing_id, response rate, and communication score. Order by communication score lowest to highest.

SELECT host_id, rs.listing_id, h.name, response_rate, communication_score
FROM hosts AS h
INNER JOIN review_scores AS rs
USING (host_id)
WHERE response_rate BETWEEN 1 AND 30
AND communication_score IS NOT NULL
ORDER BY communication_score;


--5) Return the listings posted by hosts who have more than one listing. Order by host_id.

SELECT host_id, name, listing_id, l.neighborhood, listing_title, room_type
FROM hosts AS h
INNER JOIN listings AS l
USING (host_id)
WHERE host_listings_count > 1
ORDER BY host_id;


--6) Do a multiple inner join to connect hosts, listings, and review_scores. Only include listings that can accommodate more than 4 people and that have more than 50 reviews. Return the host and listing id's, the host name, is_superhost, and overall_rating. Sort by host_id then listing_id.

SELECT h.host_id, l.listing_id, h.name AS host_name, is_superhost, overall_rating
FROM hosts AS h
INNER JOIN listings AS l
USING (host_id)
INNER JOIN review_scores AS rs
USING (listing_id)
WHERE accommodates > 4
AND number_of_reviews > 50
ORDER BY host_id, listing_id;


--7) Find out what dates are available in April for listings in SoHo, NoHo, Little Italy, or Chinatown. Return the booking date, the listing title, the neighborhood, and the price as given on the calendar. Order chronologically.

SELECT booking_date, listing_title, neighborhood, c.price
FROM listings AS l
LEFT JOIN calendar AS c
USING(listing_id)
WHERE available = 'true'
AND EXTRACT(month FROM booking_date) = 4
AND neighborhood IN ('SoHo', 'NoHo', 'Little Italy', 'Chinatown')
ORDER BY booking_date;


--8) Return host id, host name, host about description, and review comments for hosts with exactly 1 listing. Order by host_id.

SELECT host_id, name, host_about, comments
FROM hosts AS h
INNER JOIN listings AS l
USING (host_id)
INNER JOIN reviews AS r
USING (listing_id)
WHERE host_listings_count = 1
AND host_about IS NOT NULL
ORDER BY host_id;


--9) Return all the reviews for listings in Coney Island or Brighton Beach. This includes ratings, scores, and comments. Only include reviews with reviewer names.

SELECT rs.listing_id, reviewer_name, comments, overall_rating, 
location_score, cleanliness_score, communication_score, checkin_score
FROM review_scores AS rs
LEFT JOIN reviews AS r
USING (listing_id)
INNER JOIN listings AS l
USING (listing_id)
WHERE reviewer_name IS NOT NULL 
AND (neighborhood = 'Coney Island' OR neighborhood = 'Brighton Beach');


--10) Find availabilities at listings with superhosts in July and August. Return the listing_id, the date, the price, and whether or not the listing is instantly bookable. Order chronologically.

SELECT c.listing_id, booking_date, c.price, instant_bookable
FROM calendar AS c
INNER JOIN listings AS l
USING (listing_id)
INNER JOIN hosts AS h
USING (host_id)
WHERE (EXTRACT(month FROM booking_date) IN (07, 08))
AND available = 'true'
AND is_superhost = 'true'
ORDER BY booking_date;
