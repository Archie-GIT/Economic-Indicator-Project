Use Economic_Indicator;

SELECT * FROM Development_indicators;

SELECT DISTINCT Country_Name
FROM Development_indicators;


SELECT  MIN(Year) as min_year, MAX(Year) as max_year
FROM Development_indicators;

--TOP 10 Country by GDP
SELECT  TOP 10 Country_Name, Year, GDP
FROM Development_indicators
ORDER BY GDP DESC

--Avg GDP by region
SELECT Region, AVG(GDP) as average_gdp
FROM Development_indicators
GROUP BY Region
ORDER BY average_gdp DESC

--Country with highest unemployment
SELECT TOP 10 Country_name, ROUND(Avg(Unemployment),2) AS unemployment_rate
FROM Development_indicators
GROUP BY Country_name
ORDER BY unemployment_rate DESC


--Life exp by country
SELECT Country_Name, 
COALESCE( CAST(AVG(Life_expectancy_years) AS VARCHAR), 'Unknown') AS Avg_lifespan
FROM Development_indicators
GROUP BY Country_name
ORDER BY Avg_lifespan DESC;

--Country with highest internet users

SELECT Country_Name, AVG(Internet_Users) Avg_int_users
FROM Development_indicators
GROUP BY Country_name
ORDER BY Avg_int_users DESC;

--Avg lifeexp by region
SELECT Region, CAST( AVG(Life_expectancy_years) AS DECIMAL (10,2)) AS avg_living
FROM Development_indicators
GROUP BY Region
ORDER BY avg_living DESC;

--GDP trend over-time
SELECT
	Country_name, Year, GDP, Previous_gdp,
	ROUND((GDP - Previous_gdp)*100.0/ NULLIF(Previous_gdp,0),2) AS YOY_GDP
	FROM (
		SELECT Country_name, Year, GDP, 
		LAG(GDP) OVER(PARTITION BY Country_name ORDER BY Year) AS Previous_gdp
		FROM Development_indicators) t
ORDER BY Country_name
;

--Countries Above Global Average GDP
SELECT 
	Country_name, AVG(GDP) AS avg_gdp
	FROM Development_indicators
	GROUP BY Country_name
	HAVING AVG(GDP) > (SELECT AVG(GDP) AS avg_gdp_global FROM Development_indicators)
	ORDER BY avg_gdp desc

-- Create view or eco survey summary
CREATE VIEW Survey_summary AS
SELECT
	Country_Name, Region,
	AVG(GDP) AS avg_gdp,
	AVG(Life_expectancy_years) AS avg_life_exp,
    AVG(Unemployment) AS avg_unemp 
	FROM Development_indicators
	GROUP BY Country_name, Region

SELECT * FROM Survey_summary

--Ranking Countries by GDP
WITH GDP_ranking AS (
SELECT Country_Name, Year, GDP,
	RANK () OVER(PARTITION BY Year ORDER BY GDP DESC) AS rnk_country
FROM Development_indicators
)
SELECT * FROM GDP_ranking
WHERE rnk_country <= 5


--Rolling Average Example – GDP Trend
SELECT Country_Name, Region, Year, GDP,
	AVG(GDP) OVER (PARTITION BY Country_Name ORDER BY Year ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS Rolling_avg
FROM Development_indicators

--Region-wise avg GDP & life expectancy
SELECT
    Region,
    ROUND(AVG(GDP),2) AS avg_gdp,
    ROUND(AVG(Life_expectancy_years),2) AS avg_life_expectancy
FROM Development_indicators
GROUP BY Region
ORDER BY avg_gdp DESC;

