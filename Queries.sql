-- Which movie has the highest average rating
select m.title, avg(r.rating) as Avg_Rating
from movies m
join ratings r on m.movie_id= r.movie_id
group by m.movie_id, m.title
order by Avg_Rating Desc
Limit 1;



-- Top 5 movie genres with highest average rating
select g.genre_name, avg(r.rating) as Avg_Rating
from genres g
join movie_genres mg on g.genre_id = mg.genre_id
join ratings r on mg.movie_id=r.movie_id
group by g.genre_id
order by Avg_Rating Desc
Limit 5;


-- Average ratings of movies released each year
select release_year, Avg(r.rating) As Avg_Rating
from movies m
join ratings r on m.movie_id=r.movie_id
group by release_year
order by release_year;