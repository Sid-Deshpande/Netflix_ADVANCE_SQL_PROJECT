
CREATE TABLE netflix_data
(
   show_id VARCHAR(6),
   type VARCHAR(10),
   title VARCHAR(150),
   director VARCHAR(208),
   casts VARCHAR(1000),
   country VARCHAR(150),
   date_added VARCHAR(50),
   release_year INT,
   rating VARCHAR(10),
   duration VARCHAR(15),
   listed_in VARCHAR(100),
description VARCHAR(250)
);


SELECT * FROM netflix_data;


SELECT COUNT(*) as total_content 
FROM
netflix_data;


SELECT DISTINCT type
FROM 
netflix_data;


-- There are basically 15-20 business problems that should data analyst look into this 
-- netflix dataset

-- 1. Count the number of Movies and Tv Shows

      SELECT type, COUNT(*) as total_content
	  FROM netflix_data
	  GROUP BY type; 
	  
-- 2. Find the most common rating for movies and Tv Shows
      
-- 	  SELECT 
-- 	      type,
-- 		  rating,
-- 		  count(*),
-- 		  RANK() OVER(PARTITION BY type order by count(*) DESC) as ranking 
-- 		  FROM netflix_data
-- 		  GROUP BY type,rating;

-- This is the code for which we got all the rankings but we want number 1 ranking 
--  for movies and TV Shows

SELECT type,rating
FROM(
      SELECT 
	  type,
	  rating,
	  count(*),
	  RANK() OVER(PARTITION BY type order by count(*) DESC) as ranking 
	  FROM netflix_data
	  GROUP BY type,rating
	) as t1
WHERE ranking = 1;

--3. List all the movies released in a specific_year (eg-2020)(You can specify any year)

     SELECT * FROM netflix_data
	 WHERE release_year = 2020
	 AND type = 'Movie';
	 
-- 4. Find the Top 5 countries that have most content on netflix

      SELECT 
	  UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
	  count(show_id) as total_content
	  FROM netflix_data
	  GROUP BY 1
	  ORDER BY 2 DESC LIMIT 5
	  

--5. Find the Longest Movie and Tv.shows

     SELECT title, type, duration
     FROM netflix_data
     WHERE (type, duration) IN (
    SELECT type, MAX(duration)
    FROM netflix_data
    GROUP BY type
);


--6. Find the content added in last 5 years

       SELECT *
	   FROM netflix_data
	   WHERE 
	      TO_DATE(date_added,'Month DD, YYYY')>=CURRENT_DATE - INTERVAL '5 years'
		  

--7. Find all the movies/Tv shows by director 'Rajiv Chilaka'

     SELECT * FROM netflix_data
	 WHERE director like '%Rajiv Chilaka%';
	 
--8. List all the T.v shows with more than 5 seasons

      SELECT * from netflix_data
	  where 
	       type = 'TV Show'
		   AND
		   SPLIT_PART(duration,' ',1)::numeric > 5
		   
--9. Count the number of Content items in each genre

     SELECT 
	       UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,
		   COUNT(show_id) as total_content
     FROM netflix_data
	 GROUP BY 1;
	 
--10. Find each year and the average number of content release by India on netflix
      -- return top top 5 year and highest average content release
	  
     SELECT
	       EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD, YYYY')) as year,
		   COUNT(*) as yearly_content,
		   ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix_data WHERE country = 'India')::numeric * 100
		   ,2) AS avg_content_per_year
	FROM netflix_data
	WHERE country = 'India'
	GROUP BY 1;
	
--11. List all the Movies that are documentries

         SELECT * FROM netflix_data
		 where listed_in ILIKE '%documentaries%';
		
	
--12. Find all the content without director

         SELECT * FROM netflix_data
		 where director is NULL;
		 
--13. Find how many movies 'Srk' appeared in last 10 years.

         SELECT * FROM netflix_data
		 WHERE casts ILIKE '%Shah Rukh Khan%'
		 AND
		 release_year > EXTRACT(YEAR FROM CURRENT_DATE)-10;
		 
		 
--14.  Find the top 10 actors who have appeared in the highest number of movies produced in India

             SELECT
	         UNNEST(STRING_TO_ARRAY(casts,',')) as actors,
			 COUNT(*) as total_content
			 FROM netflix_data
			 WHERE country ILIKE '%India'
			 GROUP BY 1
			 ORDER BY 2 DESC
			 LIMIT 10
			 
			
--15. Categorize the content based on the presence of keywords 'Kill', 'Violence' in
--    the description field.Label the content containing these keyword as 'bad' and all other
--    Content as good. Count how many items fall into this category

         WITH new_table
		 as (
         SELECT *,
		        CASE WHEN 
				         description ILIKE '%KILL%' OR
						 description ILIKE '%violence%'
					THEN
					    'Bad_Content'
			    ELSE 'Good_content'
				
				END AS category
		FROM netflix_data
		)
		
		SELECT category, count(*) as total_content
		FROM new_table
		GROUP BY 1
		
     
	 

	 


		  
	  