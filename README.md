# Hospital Length of Stay Analysis | SQL · Python · Power BI

![SQL](https://img.shields.io/badge/SQL-Server-CC2927?style=flat-square&logo=microsoft-sql-server&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.11-blue?style=flat-square&logo=python)
![scikit-learn](https://img.shields.io/badge/scikit--learn-RandomForest-F7931E?style=flat-square&logo=scikit-learn)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=flat-square&logo=powerbi)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen?style=flat-square)

## Project Overview

End-to-end analysis of **100,000 hospital admissions** across 5 facilities between January 2012 and January 2013, sourced from the [Microsoft Hospital Length of Stay dataset on Kaggle](https://www.kaggle.com/datasets/aayushchou/hospital-length-of-stay-dataset-microsoft).

**Three business questions driving the analysis:**
1. Which patient comorbidities and clinical indicators predict a longer hospital stay?
2. Do readmitted patients stay significantly longer, and does each additional prior admission add measurable days?
3. Which facilities manage length of stay most efficiently for comparable patient profiles?

The pipeline runs from raw data through SQL (cleaning and exploration) → Python (EDA, statistical testing, and Random Forest modelling) → Power BI (interactive dashboard for operational reporting).

**Data quality note:** The `respiration` column was excluded from all analysis. 64,833 of 100,000 rows contained the identical value of 6.5 breaths/minute, far below the clinical normal range of 12–20, indicating a systematic data quality issue rather than real patient measurements. No age data was available in this dataset; this is noted as a limitation in the methodology.

---

## Key Findings

### Comorbidities and clinical indicators

- **Dialysis/renal failure patients averaged 2.14 extra days** above the 4.0-day overall mean, the largest single-condition LOS driver in the dataset. Every condition tested added at least 1 day, meaning no comorbidity in this dataset is operationally neutral.
- **LOS scales consistently with patient complexity:** patients with 0 conditions averaged 3.21 days, rising by approximately 1.5 days per additional condition to reach 8.29 days at 5 conditions. Even patients with a single diagnosed condition already exceeded the overall average by 0.99 days, meaning complexity effects begin at admission, not only in high-complexity cases.
- **Blood Urea Nitrogen (BUN) showed the most dramatic lab value divergence:** short-stay patients averaged 12.48 mg/dL (within normal range) versus 37.46 mg/dL for extended-stay patients, a 3x difference. Values above 20 mg/dL are clinically elevated; extended-stay patients averaged nearly double the upper normal limit, making BUN a practical early-warning marker for admission complexity.
- The Random Forest model ranked **hematocrit, BMI, and creatinine** as the 3rd, 4th, and 5th strongest LOS predictors after readmission history and total comorbidity count, all three are kidney and blood function indicators, reinforcing the renal theme across the dataset.

### Readmission and prior visit history

- **Readmitted patients averaged 5.57 days, more than double the 2.72-day average for first-time visitors**, a gap of 2.84 days confirmed as statistically significant (Mann-Whitney U test, p ≈ 0.00, n = 100,000).
- The relationship between readmission count and LOS is linear and consistent: rcount 0 = 2.72 days → rcount 1 = 3.70 → rcount 2 = 5.27 → rcount 3 = 6.27 → rcount 4 = 7.26 → rcount 5 = 8.29 days. Each prior admission adds roughly 1.1–1.5 days.
- **Critically, first-time and readmitted patients carry nearly identical average comorbidity counts (0.66 vs 0.67)**, yet their LOS differs by 2.84 days. This rules out comorbidity load as the explanation, readmission history is an independent predictor of longer stays, not merely a proxy for sicker patients.
- The Random Forest model confirmed this: **prior admission count (rcount) accounted for 56.5% of total feature importance**, by far the strongest single predictor, more than three times stronger than the next variable (total comorbidity count at 18.8%).

### Facility efficiency

- **Facility E recorded the highest average LOS at 5.16 days** versus the lowest facility at 3.27 days, a 1.89-day gap. Facility E also accounts for 20 extended stays (15+ days) while most other facilities have 2 or fewer, and Facility C has none.
- After adjusting for patient complexity (comparing only patients with 0 comorbidities), the facility gap narrows substantially, 3.32 days at Facility C versus 3.20 at Facilities A and E. This means most of Facility E's higher raw LOS is explained by treating more complex patients, not by operational inefficiency. However, Facility E's disproportionate share of extended stays persists after this adjustment and warrants specific investigation.

### What the model did not find

- **No seasonal variation:** monthly LOS hovered between 3.97 and 4.03 days across all 12 months, ruling out seasonal demand as a driver.
- **No secondary diagnosis effect:** secondary diagnosis count showed negligible LOS impact (3.99 to 4.12 days across all counts), suggesting these codes do not capture meaningful complexity beyond the primary comorbidity flags.
- **Gender gap is small and explained by complexity:** male patients averaged 4.19 days versus 3.86 for female patients, but males also carried higher average comorbidity counts (0.85 vs 0.53), accounting for most of the difference.

---

## Statistical Validation

| Test | Result |
|------|--------|
| Mann-Whitney U — readmitted vs. first-visit LOS | p ≈ 0.00 (significant) |
| LOS gap (readmitted vs. first-visit) | +2.84 days |
| Kruskal-Wallis — LOS across facilities | p < 0.05 (significant) |
| Random Forest RMSE (test set) | see notebook |
| Top predictor — prior admissions (rcount) | importance = 0.5651 |
| 2nd predictor — total comorbidity count | importance = 0.1878 |

---

## Business Recommendations

**1. Flag high-readmission patients at triage, not at discharge.**
Prior admissions account for 56% of LOS predictive power. A patient arriving with rcount ≥ 2 should automatically trigger early multidisciplinary team involvement and discharge planning from day one, not when the clinical team judges the patient "nearly ready." The data shows the complexity is already baked in at arrival.

**2. Use elevated BUN as a bed management signal.**
BUN at admission is 3x higher for extended-stay patients (37.46 vs 12.48 mg/dL). A simple admission screen flagging BUN > 20 mg/dL alongside rcount ≥ 1 would identify the majority of patients destined for stays beyond 7 days, allowing earlier resource allocation.

**3. Investigate Facility E's extended stay outliers specifically.**
The 1.89-day raw LOS gap between Facility E and the lowest facility narrows significantly after complexity adjustment, suggesting patient mix, not poor care, explains most of the difference. However, Facility E's 20 extended stays versus 0 at Facility C is not explained by complexity alone and should be audited for specific case types or care pathway gaps.

---

## Pipeline

```
Raw CSV
  └── SQL Server    — import, cleaning, feature engineering, exploration queries
       └── Python   — EDA (7 charts), Mann-Whitney & Kruskal-Wallis tests,
                      Random Forest feature importance (RMSE, R²)
            └── Power BI — 3-page interactive dashboard
```

---

## Tools & Techniques

| Tool | Usage |
|------|-------|
| SQL Server | Data import, NULL checking, duplicate removal, feature engineering (comorbidity_count, los_category, rcount), exploratory aggregation queries |
| Python — pandas | Data cleaning, feature engineering, data validation |
| Python — matplotlib / seaborn | 7 analytical charts with annotated findings |
| Python — scipy | Mann-Whitney U test, Kruskal-Wallis test |
| Python — scikit-learn | Random Forest Regressor, train/test split, feature importance ranking |
| Power BI | 3-page interactive dashboard with DAX measures, facility slicer, constant reference lines |

---

## Repository Structure

```
hospital-los-analysis/
│
├── sql/
│   ├── 01_setup_and_import.sql       # Database creation and CSV import
│   ├── 02_cleaning.sql               # NULL checks, validation, feature engineering
│   ├── 03_exploration.sql            # Business question queries with recorded results
│   └── 04_create_view.sql            # vw_LOS_Analysis view for Power BI connection
│
├── notebooks/
│   ├── 01_cleaning_and_features.py   # Data cleaning and feature engineering
│   ├── 02_eda_and_findings.py        # 7 exploratory charts
│   ├── 03_statistical_analysis.py    # Statistical tests and Random Forest model
│   └── chart1–8_*.png                # Exported chart images
│
├── dashboard/
│   └── los_dashboard.pdf             # Power BI dashboard export
│
└── README.md
```

---

## Data Source

Microsoft Hospital Length of Stay Dataset — available on [Kaggle](https://www.kaggle.com/datasets/aayushchou/hospital-length-of-stay-dataset-microsoft). Raw data not included in this repository; download directly from Kaggle.

---

## What I Would Do Next

- **Full predictive model with cross-validation:** The current Random Forest uses a single train/test split. A 5-fold cross-validated XGBoost model with hyperparameter tuning would produce more reliable RMSE estimates and is the production-grade next step.
- **SHAP values:** Replace feature importance bars with SHAP (SHapley Additive exPlanations), shows not just which features matter but how they affect individual predictions, which is far more interpretable for clinical teams.
- **Cost modelling:** If cost-per-bed-day data were available, the LOS gaps could be translated into direct financial impact, making the recommendations immediately actionable for budget discussions rather than operational ones only.
- **Age data:** Age was absent from this dataset and is a known strong predictor of hospital LOS. Repeating this analysis on a dataset with age would significantly improve both the model accuracy and the clinical relevance of the findings.
