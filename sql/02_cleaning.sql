-- ============================================================
-- FILE: 02_cleaning.sql
-- PURPOSE: Fix all known data issues and engineer new columns
-- RUN THIS after 01_setup_and_import.sql
-- ============================================================

USE LOSAnalysis;
GO


-- ============================================================
-- STEP 1: NULL CHECK
-- Any column with unexpected NULLs needs a decision.
-- ============================================================

SELECT
    COUNT(*) - COUNT(eid)                       AS nulls_eid,
    COUNT(*) - COUNT(vdate)                     AS nulls_vdate,
    COUNT(*) - COUNT(rcount)                    AS nulls_rcount,
    COUNT(*) - COUNT(gender)                    AS nulls_gender,
    COUNT(*) - COUNT(hemo)                      AS nulls_hemo,
    COUNT(*) - COUNT(hematocrit)                AS nulls_hematocrit,
    COUNT(*) - COUNT(neutrophils)               AS nulls_neutrophils,
    COUNT(*) - COUNT(sodium)                    AS nulls_sodium,
    COUNT(*) - COUNT(glucose)                   AS nulls_glucose,
    COUNT(*) - COUNT(bloodureanitro)            AS nulls_bloodureanitro,
    COUNT(*) - COUNT(creatinine)                AS nulls_creatinine,
    COUNT(*) - COUNT(bmi)                       AS nulls_bmi,
    COUNT(*) - COUNT(pulse)                     AS nulls_pulse,
    COUNT(*) - COUNT(secondarydiagnosisnonicd9) AS nulls_secondary,
    COUNT(*) - COUNT(lengthofstay)              AS nulls_los,
    COUNT(*) - COUNT(facid)                     AS nulls_facid
FROM Hospital_Admissions;
GO
-- >> There are 0 nulls in all columns

-- ============================================================
-- STEP 2: VALIDATE LOS(Length of Stay) RANGE
-- LOS must be >= 1. Zero or negative is a data entry error.
-- ============================================================

-- Check how many invalid rows exist
SELECT COUNT(*) AS invalid_los_rows
FROM Hospital_Admissions
WHERE lengthofstay <= 0;
GO
-- >> Count = 0

-- Remove them if any exist
DELETE FROM Hospital_Admissions
WHERE lengthofstay <= 0;
GO

-- Also check for extreme outliers — max should be 17 per your inspection
SELECT MIN(lengthofstay) AS min_los,
       MAX(lengthofstay) AS max_los,
       AVG(CAST(lengthofstay AS FLOAT)) AS avg_los
FROM Hospital_Admissions;
GO
-- >> min_los = 1  max_los = 17  avg_los = 4.00103

-- ============================================================
-- STEP 3: VALIDATE BINARY FLAG COLUMNS
-- All comorbidity columns must contain only 0 or 1
-- ============================================================

SELECT
    SUM(CASE WHEN dialysisrenalendstage NOT IN (0,1) THEN 1 ELSE 0 END) AS bad_dialysis,
    SUM(CASE WHEN asthma               NOT IN (0,1) THEN 1 ELSE 0 END) AS bad_asthma,
    SUM(CASE WHEN irondef              NOT IN (0,1) THEN 1 ELSE 0 END) AS bad_irondef,
    SUM(CASE WHEN pneum                NOT IN (0,1) THEN 1 ELSE 0 END) AS bad_pneum,
    SUM(CASE WHEN substancedependence  NOT IN (0,1) THEN 1 ELSE 0 END) AS bad_substance,
    SUM(CASE WHEN psychologicaldisordermajor NOT IN (0,1) THEN 1 ELSE 0 END) AS bad_psych,
    SUM(CASE WHEN depress              NOT IN (0,1) THEN 1 ELSE 0 END) AS bad_depress,
    SUM(CASE WHEN psychother           NOT IN (0,1) THEN 1 ELSE 0 END) AS bad_psychother,
    SUM(CASE WHEN fibrosisandother     NOT IN (0,1) THEN 1 ELSE 0 END) AS bad_fibrosis,
    SUM(CASE WHEN malnutrition         NOT IN (0,1) THEN 1 ELSE 0 END) AS bad_malnutrition,
    SUM(CASE WHEN hemo                 < 0          THEN 1 ELSE 0 END) AS bad_hemo
FROM Hospital_Admissions;
GO
-- >> All values are zero 

-- ============================================================
-- STEP 4: VALIDATE GENDER
-- Expected values: M or F only
-- ============================================================

SELECT gender, COUNT(*) AS Count
FROM Hospital_Admissions
GROUP BY gender
ORDER BY Count DESC;
GO
-- >> F: 57643
-- >> M: 42357

-- ============================================================
-- STEP 5: ADD ENGINEERED COLUMNS
-- These are the columns the entire analysis depends on.
-- ============================================================


-- 5a: comorbidity_count — total number of conditions per patient
-- This is one of the most powerful analysis variables in this dataset
ALTER TABLE Hospital_Admissions
ADD comorbidity_count INT;
GO

UPDATE Hospital_Admissions
SET comorbidity_count =
    dialysisrenalendstage +
    asthma +
    irondef +
    pneum +
    substancedependence +
    psychologicaldisordermajor +
    depress +
    psychother +
    fibrosisandother +
    malnutrition;
GO

-- Verify distribution
SELECT comorbidity_count, COUNT(*) AS Patient_Count,
       AVG(CAST(lengthofstay AS FLOAT)) AS Avg_LOS
FROM Hospital_Admissions
GROUP BY comorbidity_count
ORDER BY comorbidity_count;
GO
-- >> Does avg LOS increase as comorbidity_count goes up?
-- >> Yes

-- 5b: admission_month and admission_year, for seasonal trends
ALTER TABLE Hospital_Admissions
ADD admission_month INT,
    admission_year  INT;
GO

UPDATE Hospital_Admissions
SET admission_month = MONTH(vdate),
    admission_year  = YEAR(vdate);
GO

-- 5c: los_category — human-readable LOS bands for charts
ALTER TABLE Hospital_Admissions
ADD los_category VARCHAR(25);
GO

UPDATE Hospital_Admissions
SET los_category = CASE
    WHEN lengthofstay <= 3  THEN '1 - Short (1-3 days)'
    WHEN lengthofstay <= 7  THEN '2 - Medium (4-7 days)'
    WHEN lengthofstay <= 14 THEN '3 - Long (8-14 days)'
    ELSE                         '4 - Extended (15+ days)'
END;
GO
-- Note: the numeric prefix (1-, 2-, 3-, 4-) forces correct
-- sort order in Power BI which sorts alphabetically by default.

-- 5d: patient_type — first visit vs. readmitted (for Q2 headline)
ALTER TABLE Hospital_Admissions
ADD patient_type VARCHAR(15);
GO

UPDATE Hospital_Admissions
SET patient_type = CASE
    WHEN rcount = 0 THEN 'First Visit'
    ELSE 'Readmitted'
END;
GO

-- ============================================================
-- FINAL VERIFICATION — confirming all new columns exist and
-- have no NULLs before moving to 03_exploration.sql
-- ============================================================

SELECT TOP 5
    eid, rcount, comorbidity_count,
    los_category, patient_type, admission_month, admission_year,
    lengthofstay
FROM Hospital_Admissions;
GO

SELECT
    COUNT(*) - COUNT(comorbidity_count) AS nulls_comorbidity,
    COUNT(*) - COUNT(los_category)      AS nulls_los_category,
    COUNT(*) - COUNT(patient_type)      AS nulls_patient_type,
    COUNT(*) - COUNT(admission_month)   AS nulls_month,
    COUNT(*) - COUNT(admission_year)    AS nulls_year
FROM Hospital_Admissions;
GO
-- >> All values equal to zero, showing that everything went well.

