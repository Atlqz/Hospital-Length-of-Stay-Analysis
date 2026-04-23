-- ============================================================
-- FILE: 04_create_view.sql
-- PURPOSE: Create a clean view for Power BI to connect to
-- RUN THIS after 03_exploration.sql
-- ============================================================

USE LOSAnalysis;
GO

IF OBJECT_ID('vw_LOS_Analysis', 'V') IS NOT NULL
    DROP VIEW vw_LOS_Analysis;
GO

CREATE VIEW vw_LOS_Analysis AS
SELECT
    eid,
    vdate,
    admission_month,
    admission_year,
    rcount,
    patient_type,
    gender,

    -- Comorbidity flags
    dialysisrenalendstage,
    asthma,
    irondef,
    pneum,
    substancedependence,
    psychologicaldisordermajor,
    depress,
    psychother,
    fibrosisandother,
    malnutrition,
    comorbidity_count,

    -- Lab values 
    hemo,
    hematocrit,
    neutrophils,
    sodium,
    glucose,
    bloodureanitro,
    creatinine,
    bmi,
    pulse,

    secondarydiagnosisnonicd9,
    discharged,
    facid,
    lengthofstay,
    los_category
FROM Hospital_Admissions;
GO

-- Verify the view
SELECT TOP 5 * FROM vw_LOS_Analysis;
GO
SELECT COUNT(*) AS View_Row_Count FROM vw_LOS_Analysis;
GO

-- ============================================================
-- HOW TO CONNECT POWER BI TO THIS VIEW:
--
-- Option A (SQL Server connection):
--   1. Power BI Desktop > Get Data > SQL Server
--   2. Server: localhost
--   3. Database: LOSAnalysis
--   4. In Navigator, select vw_LOS_Analysis > Load
--
-- Option B (CSV — simpler if SQL connection is tricky):
--   Export los_cleaned.csv from Python (Notebook 1) and use
--   Get Data > Text/CSV in Power BI instead.
--   Both options give identical results.
-- ============================================================
