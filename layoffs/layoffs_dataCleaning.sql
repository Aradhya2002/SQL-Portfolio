SELECT *
FROM layoffs;

-- Create Staging Table
SELECT *
INTO layoffs_staging
FROM layoffs;

-- Remove Duplicates
WITH duplicate_cte AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions ORDER BY (SELECT NULL)) AS row_num
FROM layoffs_staging)
SELECT *
INTO layoffs_staging2
FROM duplicate_cte;

SELECT *
FROM layoffs_staging2
WHERE row_num>1;

DELETE
FROM layoffs_staging2
WHERE row_num>1;

-- Standardize the data

-- Trim evident whitespaces
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Statdardize some values that are basically same
SELECT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Some values ending in unrelated charactors eg periods
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%';

SELECT DISTINCT country,TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
order by 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Turn date column into date datatype
SELECT *
FROM layoffs_staging2;

SELECT date
FROM layoffs_staging2;

SELECT date, TRIM(date)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET date = TRIM(date);

DELETE
FROM layoffs_staging2 
WHERE ISDATE(date) = 0;

SELECT 
TRY_CONVERT(DATE, date) 
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET date = TRY_CONVERT(DATE, date);

-- Remove carriage return characters (Enter) from initial import
SELECT funds_raised_millions
FROM layoffs_staging2
WHERE funds_raised_millions LIKE '%\r';

-- Convert funds_raised_millions column to INT
SELECT funds_raised_millions
FROM layoffs_staging2
ORDER BY 1 DESC;

UPDATE layoffs_staging2
SET funds_raised_millions = NULL
WHERE funds_raised_millions = 'NULL';

ALTER TABLE layoffs_staging2
ALTER COLUMN funds_raised_millions FLOAT;

-- NULL/Blank Values
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Airbnb';

-- Populating NULL/Blank Values with known data
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE t1
SET t1.industry = t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
WHERE (t1.industry IS NULL)
  AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2;

-- Remove rows with no value to us; in this case, where the relevant values are NULL
UPDATE layoffs_staging2
SET total_laid_off = NULL
WHERE total_laid_off = 'NULL';

UPDATE layoffs_staging2
SET percentage_laid_off = NULL
WHERE percentage_laid_off = 'NULL';

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2;

-- Remove any columns
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;

-- convert datatype of total_laid_off and percentage_laid_off to INT and FLOAT 
ALTER TABLE layoffs_staging2
ALTER COLUMN total_laid_off INT;

ALTER TABLE layoffs_staging2
ALTER COLUMN percentage_laid_off FLOAT;