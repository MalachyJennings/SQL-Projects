-- Data Cleaning 
-- I have removed many of my select statements here just for sake of making it easier for any viewing to read my functions
SELECT * 
FROM layoffs_staging;

-- 1. Remove Duplicates

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT*
FROM layoffs;



WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
partition by company, industry, total_laid_off, percentage_laid_off, `date`, country, funds_raised_millions, stage) as row_num
FROM layoffs_staging
)
SELECT * 
from duplicate_cte
WHERE row_num > 1;



CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
partition by company, industry, total_laid_off, percentage_laid_off, `date`, country, funds_raised_millions, stage) as row_num
FROM layoffs_staging;


DELETE
FROM layoffs_staging2
wherE row_num > 1;

-- Standardizing Date

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Trims and Spelling mistakes

UPDATE layoffs_staging2
SET company = TRIM(company);


UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Filling in Blank Values

UPDATE layoffs_staging2
SET industry = 'Travel'
WHERE company = 'Airbnb' AND industry = '';

UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry ='';

UPDATE layoffs_staging2 t1 
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

-- Removing Row_Num column to complete the data set

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;





