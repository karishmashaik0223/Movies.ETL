create database movies_etl;
show databases;
CREATE USER 'movie_user'@'localhost' IDENTIFIED BY 'Movie@123';
GRANT ALL PRIVILEGES ON movies_etl.* TO 'movie_user'@'localhost';
FLUSH PRIVILEGES;
SHOW DATABASES;
SELECT User, Host FROM mysql.user;
RENAME USER 'movie_user'@'%' TO  'movie_user'@'localhost;
RENAME USER 'movie_user'@'%' TO  'movie_user'@'localhost;
DROP USER 'movie_user'@'%';
CREATE USER 'movie_user'@'localhost' IDENTIFIED BY 'Movie@123';
FLUSH PRIVILEGES;
SHOW DATABASES;
SELECT User, Host FROM mysql.user;
USE  movies_etl;


CREATE TABLE movies(
movie_id INT PRIMARY KEY,
title VARCHAR(255) NOT NULL,
release_year INT,
director VARCHAR(255),
plot TEXT,
box_office DECIMAL(15,2),
imdb_id VARCHAR(20) unique,
runtime VARCHAR(50),
language VARCHAR(100),
country VARCHAR(100)
);

CREATE TABLE genres(
genre_id INT AUTO_INCREMENT PRIMARY KEY,
genre_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE movie_genres(
movie_id INT NOT NULL,
genre_id INT NOT NULL,
PRIMARY KEY (movie_id, genre_id),
FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE,
FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE CASCADE
);

CREATE TABLE users(
user_id INT PRIMARY KEY
);

CREATE TABLE ratings1 (
user_id INT NOT NULL,
movie_id INT NOT NULL,
rating DECIMAL(2,1) CHECK (rating BETWEEN 0 AND 10),
timestamp BIGINT,
PRIMARY KEY (user_id, movie_id),
FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE
);

SHOW TABLES;

SELECT COUNT(*) FROM movies;
SELECT COUNT(*) FROM ratings;
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM genres;

use movies_etl;
create table movies_data(
movieId INT PRIMARY KEY,
title VARCHAR(255) NOT NULL,
genre VARCHAR(100) NOT NULL
);

create table ratings_data(
user_id INT NOT NULL,
movie_id INT NOT NULL,
rating DECIMAL(2,1) CHECK (rating BETWEEN 0 AND 10),
timestamp BIGINT
);

insert into movies (movie_id, title, release_year )
select movieId,
TRIM(SUBSTRING_INDEX(title, '(', 1)) AS title,
TRIM(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(title, '(', -1), ')', 1), ')', '')) AS release_year
from movies_data;

Alter table movies_data
change movie_id movieId int;

Alter table ratings_data
change user_id userId int;

Alter table ratings_data
change movie_id movieId int;

Alter table movies_data
change genre genres varchar(100);

INSERT IGNORE INTO genres(genre_name)
SELECT DISTINCT TRIM(j.genre)
FROM movies_data m
JOIN JSON_TABLE(
       CONCAT('["', REPLACE(m.genres,'|','","'), '"]'),
       '$[*]' COLUMNS (genre VARCHAR(100) PATH '$')
     ) AS j;

Alter table Users
drop primary key;

insert  ignore into users(user_id)
select distinct userId
from ratings_data;

INSERT INTO ratings (user_id, movie_id, rating, `timestamp`)
SELECT t.userId, t.movieId, t.rating, t.`timestamp`
FROM (
  SELECT userId, movieId, rating, `timestamp`,
    ROW_NUMBER() OVER (PARTITION BY userId, movieId ORDER BY `timestamp` DESC) AS rn
  FROM ratings_data
) AS t
JOIN users  u ON u.user_id  = t.userId
JOIN movies m ON m.movie_id = t.movieId;

drop table ratings;
drop table ratings1;

CREATE TABLE ratings (
user_id INT NOT NULL,
movie_id INT NOT NULL,
rating DECIMAL(2,1) CHECK (rating BETWEEN 0 AND 10),
timestamp BIGINT,
PRIMARY KEY (user_id, movie_id),
FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
FOREIGN KEY (movie_id) REFERENCES movies(movie_id) ON DELETE CASCADE
);

INSERT IGNORE INTO movie_genres (movie_id, genre_id)
SELECT m.movieId, g.genre_id
FROM movies_data m
JOIN JSON_TABLE(
       CONCAT('["', REPLACE(m.genres,'|','","'), '"]'),
       '$[*]' COLUMNS (genre VARCHAR(100) PATH '$')
     ) jt
JOIN genres g ON g.genre_name = jt.genre;


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










