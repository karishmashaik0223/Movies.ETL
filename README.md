# Movies ETL & Analysis Project (MySQL)

##  Overview
This project demonstrates a complete **ETL (Extract, Transform, Load)** workflow using **MySQL** and the **MovieLens dataset**.  
The goal is to clean, normalize, and analyze movie and rating data by building a relational schema that supports advanced insights.

---

## Tools & Technologies
- **MySQL 8.3** — Data extraction, transformation, and analytics  
- **MovieLens Dataset** — Source for `movies.csv` and `ratings.csv`  
- **GitHub** — Version control and documentation  

---

##  ETL Process Overview

### 1) Extract
- Imported raw files `movies.csv` and `ratings.csv` into MySQL tables:
  - `movies_data`
  - `ratings_data`

### 2) Transform
- Cleaned movie titles and extracted release years.  
- Split genres into separate rows using MySQL’s `JSON_TABLE()` function.  
- Normalized the dataset into separate tables:
  - `movies`
  - `genres`
  - `movie_genres`
  - `users`
  - `ratings`

### 3) Load
- Loaded transformed data into final relational tables.  
- Established foreign keys to ensure referential integrity.  

### 4) Analyze
- Used SQL queries to identify:
  - Highest-rated movies  
  - Top genres  
  - Average ratings by year  
  - Most-rated movies  

---
