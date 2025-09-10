-- Exploratory Data Analysis
SELECT *
FROM layoffs_staging2;

-- data date scope
SELECT MIN(date),MAX(date)
FROM layoffs_staging2;

-- most laid off
SELECT TOP 10 *
FROM layoffs_staging2
ORDER BY total_laid_off DESC;

-- went completely under: by number of people
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off= 1
ORDER BY total_laid_off DESC;

-- went completly under: by funds raised
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off= 1
ORDER BY funds_raised_millions DESC;

-- specific company
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Amazon';

-- total laid off by company
SELECT 
	company, 
	SUM(total_laid_off) total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- total laid off by industry
SELECT 
	industry,
	SUM(total_laid_off) 
FROM layoffs_staging2
group by industry
order by 2 desc;

-- specific industry
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Data'
Order by total_laid_off desc;

-- total laid off by country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- total laid off by year
SELECT YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 2 DESC;

-- total laid off by year & month
SELECT SUBSTRING(date,1,7) AS month, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(date,1,7) IS NOT NULL
GROUP BY SUBSTRING(date,1,7)
ORDER BY 1;

-- total laid off by year & month, with rolling total
WITH rolling_cte AS
(
SELECT SUBSTRING(date,1,7) AS month, SUM(total_laid_off) as total_off
FROM layoffs_staging2
WHERE SUBSTRING(date,1,7) IS NOT NULL
GROUP BY SUBSTRING(date,1,7)
)
SELECT month, total_off, SUM(total_off) OVER(ORDER BY month) AS rolling_total
FROM rolling_cte;

-- total laid off by year, month and industry
SELECT SUBSTRING(date,1,7) AS month,industry, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(date,1,7) IS NOT NULL
GROUP BY SUBSTRING(date,1,7),industry
ORDER BY 1;

-- total laid off  with scope
SELECT 
	MIN(date),
	MAX(date),
	SUM(total_laid_off) total_laid_off
FROM layoffs_staging2;

-- total laid off by stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

--total laid off by year & industry and ranked
WITH industry_years (years, industry, total_laid_off) AS
(
SELECT YEAR(date), industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry, YEAR(date)
), industry_year_ranked AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM industry_years
WHERE years IS NOT NULL
)
SELECT *
FROM industry_year_ranked
WHERE ranking <= 5;

--total laid off by year & company and ranked
WITH company_years (years, company, total_laid_off) AS
(
SELECT YEAR(date), company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(date)
), company_year_ranked AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_years
WHERE years IS NOT NULL
)
SELECT *
FROM company_year_ranked
WHERE ranking <= 5;