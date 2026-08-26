-- ============================================
--            HR ATTRITION ANALYSIS
-- ============================================

-- Load and explore

CREATE DATABASE Hr_Emp_Attrition_data ;
USE hr_emp_attrition_data ;

CREATE TABLE hr_attrition (
  Age INTEGER,
  Attrition TEXT,
  BusinessTravel TEXT,
  DailyRate INTEGER,
  Department TEXT,
  DistanceFromHome INTEGER,
  Education INTEGER,
  EnvironmentSatisfaction INTEGER,
  Gender TEXT,
  JobRole TEXT,
  JobSatisfaction INTEGER,
  MaritalStatus TEXT,
  MonthlyIncome INTEGER,
  NumCompaniesWorked INTEGER,
  OverTime TEXT,
  PercentSalaryHike INTEGER,
  PerformanceRating INTEGER,
  WorkLifeBalance INTEGER,
  YearsAtCompany INTEGER,
  YearsInCurrentRole INTEGER,
  YearsSinceLastPromotion INTEGER
);

SELECT *
FROM hr_attrition
LIMIT 10;

-- 1. OVERALL ATTRITION

SELECT
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS left_company,
    ROUND( SUM(CASE WHEN 
          Attrition = 'Yes' THEN 1 
          ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS attrition_rate
FROM hr_attrition; 

-- 2. Attrition by Gender -->
SELECT Gender,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS left_company
FROM hr_attrition
GROUP BY Gender;

-- ============================================
--          Attrition Analysis queries
-- ============================================

-- Q1: Attrition rate by department -->

SELECT Department,
       COUNT(*) AS total,
       SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count,
       ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0  / COUNT(*), 2) AS  attrition_pct
FROM hr_attrition
GROUP BY Department
ORDER BY  attrition_pct DESC;

-- Q2: Does salary affect attrition?

SELECT
  CASE
    WHEN MonthlyIncome < 3000 THEN 'Low (under 3k)'
    WHEN MonthlyIncome BETWEEN 3000 AND 6000 THEN 'Mid (3k-6k)'
    WHEN MonthlyIncome BETWEEN 6000 AND 12000 THEN 'Upper Mid (6k-12k)'
    ELSE 'High (12k+)'
  END AS salary_band,
  COUNT(*) AS employees,
  ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
FROM hr_attrition
GROUP BY salary_band
ORDER BY attrition_rate DESC;

-- Q3: Overtime and attrition — biggest factor?

SELECT OverTime,
       COUNT(*) AS employees,
       SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count,
       ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
FROM hr_attrition
GROUP BY OverTime;

-- Q4: Job satisfaction vs attrition -->

SELECT JobSatisfaction,
       CASE JobSatisfaction
         WHEN 1 THEN 'Low'
         WHEN 2 THEN 'Medium'
         WHEN 3 THEN 'High'
       ELSE 'Very High'
       END AS satisfaction_level,
       COUNT(*) AS employees,
       ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
FROM hr_attrition
GROUP BY JobSatisfaction
ORDER BY JobSatisfaction;

-- Q5: Work-life balance impact -->

SELECT WorkLifeBalance,
       CASE WorkLifeBalance
         WHEN 1 THEN 'Bad'
         WHEN 2 THEN 'Good'
         WHEN 3 THEN 'Better'
	   ELSE 'Best'
       END AS wlb_level,
       COUNT(*) AS employees,
       ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
FROM hr_attrition
GROUP BY WorkLifeBalance
ORDER BY WorkLifeBalance;

-- Q6: Age group analysis -->

SELECT
  CASE
    WHEN Age < 25 THEN 'Under 25'
    WHEN Age BETWEEN 25 AND 35 THEN '25-35'
    WHEN Age BETWEEN 35 AND 45 THEN '35-45'
    ELSE 'Over 45'
  END AS age_group,
  COUNT(*) AS employees,
  ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) *100 / COUNT(*), 2) AS attrition_rate,
  ROUND(AVG(MonthlyIncome), 0) AS avg_salary
FROM hr_attrition
GROUP BY age_group
ORDER BY
  CASE
    WHEN age_group = 'Under 25' THEN 1
    WHEN age_group = '25-35' THEN 2
    WHEN age_group = '35-45' THEN 3
    ELSE 4
  END;

-- Q7: Years since promotion — do stuck employees leave?

SELECT
  CASE
    WHEN YearsSinceLastPromotion = 0 THEN 'Just promoted'
    WHEN YearsSinceLastPromotion BETWEEN 1 AND 2 THEN '1-2 years'
    WHEN YearsSinceLastPromotion BETWEEN 3 AND 5 THEN '3-5 years'
    ELSE 'Over 5 years'
  END AS promotion_gap,
  COUNT(*) AS employees,
  ROUND(100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS attrition_rate
FROM hr_attrition
GROUP BY promotion_gap
ORDER BY
  CASE
    WHEN promotion_gap = 'Just promoted' THEN 1
    WHEN promotion_gap =  '1-2 years' THEN 2
    WHEN promotion_gap = '3-5 years' THEN 3
    ELSE 4
  END;

-- IMP-Q8: Profile of employees most likely to leave -->
SELECT
  Department,
  JobRole,
  OverTime,
  ROUND(AVG(MonthlyIncome), 0) AS avg_salary,
  ROUND(AVG(YearsSinceLastPromotion), 1) AS avg_years_since_promo,
  COUNT(*) AS employees,
  ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate
FROM hr_attrition
GROUP BY Department, JobRole, OverTime
HAVING COUNT(*) >= 10
ORDER BY attrition_rate DESC
LIMIT 15;

                                      -- ====================
										  --  THANK YOU --
									  -- ====================