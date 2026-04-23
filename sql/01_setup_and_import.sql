-- ============================================================
-- FILE: 01_setup_and_import.sql
-- PURPOSE: Create database, create table, load CSV
-- RUN THIS FIRST
-- ============================================================

CREATE DATABASE LOSAnalysis;
GO

USE LOSAnalysis;
GO


CREATE TABLE Hospital_Admissions (
    eid                         INT,
    vdate                       DATE,
    rcount                      INT,
    gender                      VARCHAR(1),
    dialysisrenalendstage       INT,
    asthma                      INT,
    irondef                     INT,
    pneum                       INT,
    substancedependence         INT,
    psychologicaldisordermajor  INT,
    depress                     INT,
    psychother                  INT,
    fibrosisandother            INT,
    malnutrition                INT,
    hemo                        FLOAT,
    hematocrit                  FLOAT,
    neutrophils                 FLOAT,
    sodium                      FLOAT,
    glucose                     FLOAT,
    bloodureanitro              FLOAT,
    creatinine                  FLOAT,
    bmi                         FLOAT,
    pulse                       FLOAT,
    secondarydiagnosisnonicd9   INT,
    discharged                  DATE,
    facid                       VARCHAR(5),
    lengthofstay                INT
);
GO

-- ============================================================
-- HOW TO IMPORT:
-- Either import through export wizard
-- OR use BULK INSERT after changing the file path below:
-- ============================================================

BULK INSERT Hospital_Admissions
FROM 'C:/hospital_los_excel_cleaned.csv' -- add your file path here
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

SELECT TOP 10 * FROM Hospital_Admissions;
GO
SELECT COUNT(*) AS Total_Rows FROM Hospital_Admissions;
GO
-- Expected: 100,000 rows

Drop Table Hospital_Admissions
