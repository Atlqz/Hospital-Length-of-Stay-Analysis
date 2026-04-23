-- ============================================================
-- FILE: 03_exploration.sql
-- PURPOSE: Answer the 3 core business questions
-- IMPORTANT: Write every result into the comment below each
-- query as you run it. These numbers become your README.
-- RUN THIS after 02_cleaning.sql
-- ============================================================

USE LOSAnalysis;
GO

-- ============================================================
-- CONTEXT QUERY: Overall dataset baseline
-- We looked at 100,000 hospital visits across 5 buildings
-- between January 2012 and January 2013. The average stay was 
-- 4.0 days. The shortest was 1 day and the longest was 
-- 17 days. This 4-day number is the starting point 
-- for all other comparisons.
-- ============================================================

SELECT
    COUNT(*)                            AS Total_Admissions,
    ROUND(AVG(CAST(lengthofstay AS FLOAT)), 2) AS Overall_Avg_LOS,
    MIN(lengthofstay)                   AS Min_LOS,
    MAX(lengthofstay)                   AS Max_LOS,
    ROUND(STDEV(lengthofstay), 2)       AS StdDev_LOS,
    MIN(vdate)                          AS Earliest_Admission,
    MAX(vdate)                          AS Latest_Admission
FROM Hospital_Admissions;
GO
-- >> Overall avg LOS: 4  Min: 1  Max: 17  Date range: 1/1/2012 to 1/1/2013
-- >> These are the most important reference numbers.

-- ============================================================
-- BUSINESS QUESTION 1:
-- Which comorbidities and lab values predict a longer stay?
-- ============================================================

-- Q1a: Average LOS for patients WITH each condition vs. WITHOUT
-- The "Gap" column is your key number — largest positive gap = biggest LOS driver
SELECT
    'Dialysis/Renal Failure'    AS Condition,
    ROUND(AVG(CASE WHEN dialysisrenalendstage=1 THEN CAST(lengthofstay AS FLOAT) END), 2) AS Avg_LOS_With,
    ROUND(AVG(CASE WHEN dialysisrenalendstage=0 THEN CAST(lengthofstay AS FLOAT) END), 2) AS Avg_LOS_Without,
    ROUND(AVG(CASE WHEN dialysisrenalendstage=1 THEN CAST(lengthofstay AS FLOAT) END) -
          AVG(CASE WHEN dialysisrenalendstage=0 THEN CAST(lengthofstay AS FLOAT) END), 2) AS Gap_Days,
    SUM(dialysisrenalendstage) AS Patient_Count
FROM Hospital_Admissions
UNION ALL
SELECT 'Asthma',
    ROUND(AVG(CASE WHEN asthma=1 THEN CAST(lengthofstay AS FLOAT) END), 2),
    ROUND(AVG(CASE WHEN asthma=0 THEN CAST(lengthofstay AS FLOAT) END), 2),
    ROUND(AVG(CASE WHEN asthma=1 THEN CAST(lengthofstay AS FLOAT) END) -
          AVG(CASE WHEN asthma=0 THEN CAST(lengthofstay AS FLOAT) END), 2),
    SUM(asthma) FROM Hospital_Admissions
UNION ALL
SELECT 'Iron Deficiency',
    ROUND(AVG(CASE WHEN irondef=1 THEN CAST(lengthofstay AS FLOAT) END), 2),
    ROUND(AVG(CASE WHEN irondef=0 THEN CAST(lengthofstay AS FLOAT) END), 2),
    ROUND(AVG(CASE WHEN irondef=1 THEN CAST(lengthofstay AS FLOAT) END) -
          AVG(CASE WHEN irondef=0 THEN CAST(lengthofstay AS FLOAT) END), 2),
    SUM(irondef) FROM Hospital_Admissions
UNION ALL
SELECT 'Pneumonia',
    ROUND(AVG(CASE WHEN pneum=1 THEN CAST(lengthofstay AS FLOAT) END), 2),
    ROUND(AVG(CASE WHEN pneum=0 THEN CAST(lengthofstay AS FLOAT) END), 2),
    ROUND(AVG(CASE WHEN pneum=1 THEN CAST(lengthofstay AS FLOAT) END) -
          AVG(CASE WHEN pneum=0 THEN CAST(lengthofstay AS FLOAT) END), 2),
    SUM(pneum) FROM Hospital_Admissions
UNION ALL
SELECT 'Substance Dependence',
    ROUND(AVG(CASE WHEN substancedependence=1 THEN CAST(lengthofstay AS FLOAT) END), 2),
    ROUND(AVG(CASE WHEN substancedependence=0 THEN CAST(lengthofstay AS FLOAT) END), 2),
    ROUND(AVG(CASE WHEN substancedependence=1 THEN CAST(lengthofstay AS FLOAT) END) -
          AVG(CASE WHEN substancedependence=0 THEN CAST(lengthofstay AS FLOAT) END), 2),
    SUM(substancedependence) FROM Hospital_Admissions
UNION ALL
SELECT 'Major Psychological Disorder',
    ROUND(AVG(CASE WHEN psychologicaldisordermajor=1 THEN CAST(lengthofstay AS FLOAT) END), 2),
    ROUND(AVG(CASE WHEN psychologicaldisordermajor=0 THEN CAST(lengthofstay AS FLOAT) END), 2),
    ROUND(AVG(CASE WHEN psychologicaldisordermajor=1 THEN CAST(lengthofstay AS FLOAT) END) -
          AVG(CASE WHEN psychologicaldisordermajor=0 THEN CAST(lengthofstay AS FLOAT) END), 2),
    SUM(psychologicaldisordermajor) FROM Hospital_Admissions
UNION ALL
SELECT 'Depression',
    ROUND(AVG(CASE WHEN depress=1 THEN CAST(lengthofstay AS FLOAT) END), 2),
    ROUND(AVG(CASE WHEN depress=0 THEN CAST(lengthofstay AS FLOAT) END), 2),
    ROUND(AVG(CASE WHEN depress=1 THEN CAST(lengthofstay AS FLOAT) END) -
          AVG(CASE WHEN depress=0 THEN CAST(lengthofstay AS FLOAT) END), 2),
    SUM(depress) FROM Hospital_Admissions
UNION ALL
SELECT 'Other Psychological',
    ROUND(AVG(CASE WHEN psychother=1 THEN CAST(lengthofstay AS FLOAT) END), 2),
    ROUND(AVG(CASE WHEN psychother=0 THEN CAST(lengthofstay AS FLOAT) END), 2),
    ROUND(AVG(CASE WHEN psychother=1 THEN CAST(lengthofstay AS FLOAT) END) -
          AVG(CASE WHEN psychother=0 THEN CAST(lengthofstay AS FLOAT) END), 2),
    SUM(psychother) FROM Hospital_Admissions
UNION ALL
SELECT 'Fibrosis',
    ROUND(AVG(CASE WHEN fibrosisandother=1 THEN CAST(lengthofstay AS FLOAT) END), 2),
    ROUND(AVG(CASE WHEN fibrosisandother=0 THEN CAST(lengthofstay AS FLOAT) END), 2),
    ROUND(AVG(CASE WHEN fibrosisandother=1 THEN CAST(lengthofstay AS FLOAT) END) -
          AVG(CASE WHEN fibrosisandother=0 THEN CAST(lengthofstay AS FLOAT) END), 2),
    SUM(fibrosisandother) FROM Hospital_Admissions
UNION ALL
SELECT 'Malnutrition',
    ROUND(AVG(CASE WHEN malnutrition=1 THEN CAST(lengthofstay AS FLOAT) END), 2),
    ROUND(AVG(CASE WHEN malnutrition=0 THEN CAST(lengthofstay AS FLOAT) END), 2),
    ROUND(AVG(CASE WHEN malnutrition=1 THEN CAST(lengthofstay AS FLOAT) END) -
          AVG(CASE WHEN malnutrition=0 THEN CAST(lengthofstay AS FLOAT) END), 2),
    SUM(malnutrition) FROM Hospital_Admissions
ORDER BY Gap_Days DESC;
GO
-- >> Which condition has the largest Gap_Days? Dialysis/Renal Failure with 2.14 extra days
-- >> Which condition has the smallest gap? Asthma with 1.05
-- Patients with kidney failure or on dialysis stayed 2.14 days longer than patients without it. 
-- This was the single biggest reason for a longer stay in the whole study.
-- Every health problem we looked at added at least 1 extra day to the visit. 
-- No sickness was "neutral"—they all make you stay longer. 
-- Asthma added the least extra time (1.05 days), 
-- which likely means it is either managed well or not the main reason people are admitted.

-- Q1b: LOS by comorbidity count (0 conditions up to 5+)
-- Does each additional condition add predictable days?
SELECT
    comorbidity_count,
    COUNT(*)                                        AS Patient_Count,
    ROUND(AVG(CAST(lengthofstay AS FLOAT)), 2)      AS Avg_LOS,
    ROUND(AVG(CAST(lengthofstay AS FLOAT)) -
        (SELECT AVG(CAST(lengthofstay AS FLOAT)) FROM Hospital_Admissions), 2) AS Gap_From_Overall_Avg
FROM Hospital_Admissions
GROUP BY comorbidity_count
ORDER BY comorbidity_count;
GO
-- >> Does LOS increase consistently as comorbidity_count rises? yes starting with 3.21 and getting around 1.5 each comrbidty_count
-- >> At what count does LOS first clearly exceed the overall average? At count 1 where its gap from the overall avg is 0.99
-- The more health issues a patient has, the longer they stay.

-- Patients with 0 issues: 3.21 days.
-- Add about 1.5 days for each new health issue.

-- Important finding: Even having just one health issue pushes the stay above the overall average (adding +0.99 days). 
-- This means the effect of being sick starts right away, not just when someone is very old or has many issues.


-- Q1c: Lab value averages for short stays vs. extended stays
-- Which lab values differ most between short and long-stay patients?
SELECT
    los_category,
    COUNT(*)                                AS Patient_Count,
    ROUND(AVG(hemo), 2)                     AS Avg_Hemo,
    ROUND(AVG(hematocrit), 2)               AS Avg_Hematocrit,
    ROUND(AVG(neutrophils), 2)              AS Avg_Neutrophils,
    ROUND(AVG(sodium), 2)                   AS Avg_Sodium,
    ROUND(AVG(glucose), 2)                  AS Avg_Glucose,
    ROUND(AVG(bloodureanitro), 2)           AS Avg_BUN,
    ROUND(AVG(creatinine), 2)               AS Avg_Creatinine,
    ROUND(AVG(bmi), 2)                      AS Avg_BMI,
    ROUND(AVG(pulse), 2)                    AS Avg_Pulse
FROM Hospital_Admissions
GROUP BY los_category
ORDER BY los_category;
GO
-- >> Which lab value shows the biggest difference between Short and Extended stays? 
-- >> Gluose 141.99 vs 128.79 and BUN 12.48 vs 37.46

-- A kidney test called BUN (Blood Urea Nitrogen) showed the biggest warning sign.

-- Short stays: Average BUN was 12.48 (normal).

-- Extended stays: Average BUN was 37.46 (3 times higher).

-- This is a strong signal. High BUN means kidneys are stressed. 
-- Patients with stressed kidneys take much longer to get better.
-- Blood sugar levels were different too, but the kidney number was a much clearer red flag.


-- ============================================================
-- BUSINESS QUESTION 2:
-- Do readmitted patients stay significantly longer?
-- ============================================================

-- Q2a: First visit vs. readmitted — headline comparison
SELECT
    patient_type,
    COUNT(*)                                        AS Total_Patients,
    ROUND(AVG(CAST(lengthofstay AS FLOAT)), 2)      AS Avg_LOS,
    ROUND(MIN(CAST(lengthofstay AS FLOAT)), 2)      AS Min_LOS,
    ROUND(MAX(CAST(lengthofstay AS FLOAT)), 2)      AS Max_LOS
FROM Hospital_Admissions
GROUP BY patient_type
ORDER BY Avg_LOS DESC;
GO
-- >> Readmitted avg LOS: 5.57  First visit avg LOS: 2.272  Gap: 2.85 days

-- This is the biggest clue in the whole dataset. Patients who have been here before stay much longer.

-- First-time visit: Average stay is 2.27 days.
-- Returning patient: Average stay is 5.57 days.
-- Difference: Returning patients stay 3.30 extra days.

-- Knowing a patient's past visit history predicts a long stay better than almost any single sickness.

-- Q2b: Granular — LOS by each readmission count (0, 1, 2, 3, 4, 5)
-- Does each additional prior admission add more days?
SELECT
    rcount,
    COUNT(*)                                        AS Patient_Count,
    ROUND(AVG(CAST(lengthofstay AS FLOAT)), 2)      AS Avg_LOS,
    ROUND(STDEV(CAST(lengthofstay AS FLOAT)), 2)    AS StdDev_LOS
FROM Hospital_Admissions
GROUP BY rcount
ORDER BY rcount;
GO
-- >> Is there a clear upward trend from 0 to 5? yes, 2.72 -> 3.7 -> 5.27 -> 6.27 -> 7.26 -> 8.29
-- >> At what rcount does LOS spike most sharply? rcount 5: 8.29
-- The pattern is steady. Every time you come back, the stay gets longer.
-- The biggest single jump happens between the 1st and 2nd return visit. 
-- That seems to be a tipping point where patients get much more complicated to treat.


-- Q2c: Do readmitted patients also have more comorbidities?
-- (This rules out whether readmission is just a proxy for sicker patients)
SELECT
    patient_type,
    ROUND(AVG(CAST(comorbidity_count AS FLOAT)), 2) AS Avg_Comorbidities,
    ROUND(AVG(CAST(lengthofstay AS FLOAT)), 2)      AS Avg_LOS,
    COUNT(*)                                        AS Patient_Count
FROM Hospital_Admissions
GROUP BY patient_type;
GO
-- >> If readmitted patients have BOTH more comorbidities AND longer LOS,
-- >> the conditions explain part of the gap. If comorbidities are similar
-- >> but LOS is still longer, readmission itself is the driver.

-- First-timers have 0.66 health issues on average.

-- Returning patients have 0.67 health issues on average.

-- They are nearly the same in terms of how many sicknesses they have. Yet, returning patients stay 3.30 days longer.

--This proves the longer stay is not because they have more diagnoses on paper. 
-- There is something else about the act of returning itself—maybe failing health, lack of home support, 
-- or gaps in follow-up care—that is driving the extra days.

-- ============================================================
-- BUSINESS QUESTION 3:
-- Which facilities manage LOS most efficiently?
-- ============================================================

-- Q3a: Raw LOS by facility
SELECT
    facid,
    COUNT(*)                                        AS Total_Admissions,
    ROUND(AVG(CAST(lengthofstay AS FLOAT)), 2)      AS Avg_LOS,
    ROUND(MIN(CAST(lengthofstay AS FLOAT)), 2)      AS Min_LOS,
    ROUND(MAX(CAST(lengthofstay AS FLOAT)), 2)      AS Max_LOS,
    SUM(CASE WHEN los_category = '4 - Extended (15+ days)' THEN 1 ELSE 0 END) AS Extended_Stays,
    ROUND(SUM(CASE WHEN los_category = '4 - Extended (15+ days)' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS Pct_Extended
FROM Hospital_Admissions
GROUP BY facid
ORDER BY Avg_LOS DESC;
GO
-- >> Which facility has the highest avg LOS? E: 5.16  Lowest? 3.27
-- >> Is the gap driven by extended stays or a general shift? Extended stays for fac E is 20 with the rest having 2 except for C with 0

-- Facility E keeps patients the longest: 5.16 days.
-- The lowest facility keeps patients 3.27 days.
-- That's a gap of 1.89 days.

-- Facility E also has 20 cases of very long stays (15+ days). 
-- Most other buildings have only 2 cases or less. This is a big cost difference when you multiply it by thousands of patients.



-- Q3b: Complexity-adjusted comparison
-- Compare facilities for the SAME comorbidity count
-- If Facility A still has higher LOS than Facility B for patients
-- with 0 conditions, that is a genuine operational difference
SELECT
    facid,
    comorbidity_count,
    COUNT(*)                                        AS Patient_Count,
    ROUND(AVG(CAST(lengthofstay AS FLOAT)), 2)      AS Avg_LOS
FROM Hospital_Admissions
GROUP BY facid, comorbidity_count
ORDER BY comorbidity_count, facid;
GO
-- >> For patients with 0 comorbidities, which facility has the highest LOS? 
-- C with 3.32 but the rest dont have much of difference with the lowest being A and E with 3.2

-- Fastest building: 3.32 days.

-- Facility E: 3.20 days.

-- Difference: Just 0.12 days.

-- This tells us Facility E's long average stay is mostly because they treat sicker patients, 
-- not because they are slow or inefficient. However, their number of extreme 15+ day stays is 
-- still unusually high and needs a closer look.


-- Q3c: LOS category distribution per facility (% breakdown)
SELECT
    facid,
    ROUND(SUM(CASE WHEN los_category = '1 - Short (1-3 days)'    THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS Pct_Short,
    ROUND(SUM(CASE WHEN los_category = '2 - Medium (4-7 days)'   THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS Pct_Medium,
    ROUND(SUM(CASE WHEN los_category = '3 - Long (8-14 days)'    THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS Pct_Long,
    ROUND(SUM(CASE WHEN los_category = '4 - Extended (15+ days)' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS Pct_Extended,
    COUNT(*) AS Total
FROM Hospital_Admissions
GROUP BY facid
ORDER BY Pct_Extended DESC;
GO

-- ============================================================
-- BONUS QUERIES
-- ============================================================

-- Gender breakdown
SELECT
    gender,
    COUNT(*)                                        AS Total,
    ROUND(AVG(CAST(lengthofstay AS FLOAT)), 2)      AS Avg_LOS,
    ROUND(AVG(CAST(comorbidity_count AS FLOAT)), 2) AS Avg_Comorbidities
FROM Hospital_Admissions
GROUP BY gender
ORDER BY Avg_LOS DESC;
GO

-- Seasonal trend: avg LOS and admission volume by month
-- M avg los 4.19 and avg com 0.85
-- F avg los 3.86 and avg com 0.53
SELECT
    admission_year,
    admission_month,
    COUNT(*)                                        AS Admissions,
    ROUND(AVG(CAST(lengthofstay AS FLOAT)), 2)      AS Avg_LOS
FROM Hospital_Admissions
GROUP BY admission_year, admission_month
ORDER BY admission_year, admission_month;
GO
-- >> Are there months where avg LOS is noticeably higher? No they are all hovering around 3.97 and 4.03

-- Secondary diagnosis count vs. LOS
SELECT
    secondarydiagnosisnonicd9,
    COUNT(*)                                        AS Patient_Count,
    ROUND(AVG(CAST(lengthofstay AS FLOAT)), 2)      AS Avg_LOS
FROM Hospital_Admissions
GROUP BY secondarydiagnosisnonicd9
ORDER BY secondarydiagnosisnonicd9;
GO
-- >> Does more secondary diagnoses correlate with longer LOS? No 3.99 to 4.12

-- >> Other Notes

-- Time of Year: It didn't matter. Stays were flat at about 4.0 days every month. Winter flu season didn't make stays longer here.

-- Other Health Notes in File: Having extra notes in the chart (secondary issues) didn't change the length of stay much.

-- Gender: Men stayed slightly longer (4.19 days vs 3.86 days for women). 
-- This is likely because the men in this group had more health issues on average.
