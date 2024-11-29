CREATE TABLE netflix (
    show_id VARCHAR(10),
    type VARCHAR(20),
    title VARCHAR(255),
    director VARCHAR(255),
    casts TEXT,
    country VARCHAR(255),
    date_added DATE,
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(50),
    listed_in VARCHAR(255),
    description TEXT
);

COPY Netflix FROM 'E:\Sql_Python_Projects\001_Project_DIsney_Sql\netflix_titles.csv' DELIMITER ',' CSV HEADER;

select * from netflix;

-- 1. Count the number of Movies vs TV Shows
select count(*) as total_movie_count from netflix
where type = 'Movie';

-- 2. Find the most common rating for movies and TV shows
with cte as (select 
	type, 
	rating,
	count(*) as total_count,
	rank() over(partition by type order by count(*) desc) as rnk
from netflix
group by type, rating)
select type, rating from cte
where rnk = 1
;

-- 3. List all movies released in a specific year (e.g., 2020)
select title from netflix
where release_year = 2020 and type = 'Movie';

-- 4. Find the top 5 countries with the most content on Hotstar
-- NUll values are handeled, also country those are
select 
	trim(unnest(string_to_array(country, ','))) as distinct_country,
	count(type) as content_count
from netflix
where country is not null
group by distinct_country
order by content_count desc
limit 5;

-- 5. Identify the longest movie
select type, title, duration from netflix
where type = 'Movie'
order by duration desc 
limit 1;

-- 6. Find content added in the last 3 years
-- format the date from table to YYYY-DD-MM format
select 
	* 
from netflix
where to_date(date_added, 'Month DD, YYYY') >= Current_Date - interval '3 year';

--7. Find all the movies/TV shows by director 'Robert Vince'!
-- Kevin Deters, works in team, so in this querry segregate the value speerated by, and store in a different column to filterout the vlaue.
-- Trim function is using to remove unwanted space
with cte as (select 
	type,
	title, 
	trim(unnest(string_to_array(director, ','))) as indv_director
from netflix)
select * from cte
where indv_director = 'Kevin Deters';

--2nd solution
select type, title, director 
from netflix
where director ilike '%Kevin Deters%'

-- 8. List all TV shows with more than 5 seasons
-- use aplit_part function to split the '5 seasons' or '7 Seasons' into 5, 7.
select 
	type,
	duration,
	split_part(duration,' ',1)::integer as season
from netflix
where 
	type = 'TV Show' 
	and
	split_part(duration,' ',1)::integer > 5;

-- 9. Count the number of content items in each genre
select
	trim(unnest (string_to_array(listed_in,','))) as genre,
	count(show_id) as total_item
from netflix
group by genre
order by count(show_id) desc;

-- 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.
select 
	title,
	case 
		when 
			description ilike '%Kill%'
			or
			description ilike '%violence%' then 'voilent_category'
			else
			'good_category'
		end as category
from netflix
