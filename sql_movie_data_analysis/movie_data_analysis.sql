SELECT *
FROM imdb_top_1000;

-- Which movies give the best combination of critical acclaim and box-office return?
SELECT Series_Title, Released_Year, IMDB_Rating, Gross,
	ROUND(
    CASE WHEN Gross IS NOT NULL AND Gross > 0
      THEN IMDB_Rating * LN(Gross)
      ELSE IMDB_Rating
    END, 4) AS weighted_score
FROM imdb_top_1000
WHERE IMDB_Rating IS NOT NULL
ORDER BY weighted_score DESC
LIMIT 50;

-- Which genres generate highest average gross and highest average ratings?
SELECT
  Genre,
  COUNT(*) AS movie_count,
  ROUND(AVG(IMDB_Rating), 3) AS avg_rating,
  ROUND(AVG(Gross), 2) AS avg_gross
FROM imdb_top_1000
GROUP BY Genre
HAVING COUNT(*) >= 5
ORDER BY avg_gross DESC;

-- How do ratings and runtimes change by decade? Are older films still top rated?
SELECT
  Released_Year,
  COUNT(*) AS titles,
  ROUND(AVG(IMDB_Rating), 3) AS avg_rating,
  ROUND(AVG(Runtime), 1) AS avg_runtime
FROM imdb_top_1000
WHERE Released_Year IS NOT NULL
GROUP BY Released_Year
ORDER BY Released_Year;

-- Which directors or lead stars consistently deliver high-rated or high-grossing films?
SELECT
  Director,
  COUNT(*) AS titles,
  ROUND(AVG(IMDB_Rating), 3) AS avg_rating,
  ROUND(SUM(Gross), 2) AS total_gross
FROM imdb_top_1000
GROUP BY Director
HAVING COUNT(*) >= 3
ORDER BY avg_rating DESC, total_gross DESC
LIMIT 50;

-- Are niche genres (low-count genres) worth keeping in catalog relative to blockbusters?
SELECT 
  Genre, cnt,
  ROUND(avg_gross, 2) AS avg_gross,
  ROUND(avg_rating, 3) AS avg_rating,
  CASE WHEN cnt >= 20 THEN 'Popular' ELSE 'Niche' END AS bucket
FROM (
  SELECT 
    Genre,
    COUNT(*) AS cnt,
    AVG(Gross) AS avg_gross,
    AVG(IMDB_Rating) AS avg_rating
  FROM imdb_top_1000
  GROUP BY Genre
) AS genre_stats
ORDER BY cnt DESC;

-- Does audience engagement (votes) correlate with revenue? Which titles over- or under-perform vs votes?
SELECT
  Series_Title, Released_Year, No_of_Votes, Gross,
  ROUND(Gross / No_of_Votes, 2) AS revenue_per_vote
FROM imdb_top_1000
ORDER BY revenue_per_vote DESC
LIMIT 50;

-- Which low-performing titles (low rating, low gross, low votes) can be deprioritized or removed?
SELECT
  Series_Title, Released_Year, IMDB_Rating, No_of_Votes, Gross
FROM imdb_top_1000
WHERE (IMDB_Rating < 6.0 OR IMDB_Rating IS NULL)
  AND (No_of_Votes < 50000 OR No_of_Votes IS NULL)
  AND (Gross IS NULL OR Gross < 1000000)
ORDER BY IMDB_Rating ASC, No_of_Votes ASC;