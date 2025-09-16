# Student-Stress-Analysis-Using-SQL
Built a stress monitoring system in SQL by cleaning and normalizing student data, creating composite stress scores, analyzing stress cohorts, and ranking students using advanced queries with filters by age, gender, and stress type.

Task 1:
* Type Normalization: Cast all Likert items to INT.
* Recode Gender: 0 → 'Female', 1 → 'Male'
* Standardize target values to title case (Eustress/No Stress/Distress).
* Create an age_valid flag for 15-30 (student band).
* Build Composite Stress Score.

Task 2:
* Class Distribution: Counts and percentage for Eustress/No Stress/Distress.
* Top Drivers (Proxy): For Distress cohort, list the 10 items with highest mean compared to overall mean (delta ranking).

Task 3:
* Rank students by Composite within Gender and Age band (DENSE_RANK()):return top-10 per segment.
* Filters for Age (15-30), Gender, and Stress Type.
