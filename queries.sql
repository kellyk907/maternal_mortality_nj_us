-- Project 2: Maternal Mortality (NJ vs US) - SQL Queries

-- 1) Overall trend (recomputed from deaths/population)
SELECT
  location,
  year,
  SUM(deaths) AS deaths,
  SUM(population) AS population,
  ROUND( (CAST(SUM(deaths) AS REAL) / NULLIF(SUM(population), 0)) * 100000.0, 3 ) AS rate_per_100k
FROM maternal_mortality
GROUP BY location, year
ORDER BY location, year;

-- 2) Trend by race (raw rows)
SELECT
  location,
  race,
  year,
  deaths,
  population,
  rate AS crude_rate
FROM maternal_mortality
ORDER BY location, race, year;

-- 3) Latest year snapshot by race (NJ vs US + difference)
WITH maxyr AS (
  SELECT MAX(year) AS latest_year FROM maternal_mortality
)
SELECT
  m.year,
  m.race,
  ROUND(AVG(CASE WHEN m.location = 'United States' THEN m.rate END), 3) AS us_rate,
  ROUND(AVG(CASE WHEN m.location = 'New Jersey' THEN m.rate END), 3) AS nj_rate,
  ROUND(
    (AVG(CASE WHEN m.location = 'New Jersey' THEN m.rate END) -
     AVG(CASE WHEN m.location = 'United States' THEN m.rate END)), 3
  ) AS nj_minus_us
FROM maternal_mortality m
JOIN maxyr ON m.year = maxyr.latest_year
GROUP BY m.year, m.race
HAVING us_rate IS NOT NULL AND nj_rate IS NOT NULL
ORDER BY nj_minus_us DESC;

-- 4) Data quality checks
SELECT
  SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS missing_year,
  SUM(CASE WHEN race IS NULL OR TRIM(race) = '' THEN 1 ELSE 0 END) AS missing_race,
  SUM(CASE WHEN location IS NULL OR TRIM(location) = '' THEN 1 ELSE 0 END) AS missing_location,
  SUM(CASE WHEN deaths IS NULL THEN 1 ELSE 0 END) AS missing_deaths,
  SUM(CASE WHEN population IS NULL THEN 1 ELSE 0 END) AS missing_population,
  SUM(CASE WHEN rate IS NULL THEN 1 ELSE 0 END) AS missing_rate
FROM maternal_mortality;
