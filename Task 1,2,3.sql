-- task 1
--qstn 1: Type Normalization: Cast all Likert items to INT.
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'stress_dataset';

--qstn 2: Recode Gender: 0 → 'Female', 1 → 'Male'
ALTER TABLE stress_dataset
ALTER COLUMN gender TYPE text
USING CASE 
        WHEN gender = 0 THEN 'Female'
        WHEN gender = 1 THEN 'Male'
        ELSE 'Unknown'
     END;

select gender from stress_dataset;

--qstn 3: Standardize target values to title case (Eustress/No Stress/Distress).
UPDATE stress_dataset
SET stress_type = INITCAP(stress_type);

select stress_type from stress_dataset;

--qstn 4: Create an age_valid flag for 15-30 (student band).
ALTER TABLE stress_dataset
ADD COLUMN age_valid INT;

UPDATE stress_dataset
SET age_valid = CASE 
                   WHEN age BETWEEN 15 AND 30 THEN 1 
                   ELSE 0 
                END;

select age_valid from stress_dataset;

--qstn 5: Build Composite Stress Score.
ALTER TABLE stress_dataset
ADD COLUMN composite_stress_score INT;

UPDATE stress_dataset
SET composite_stress_score = ROUND((
     stress_recent + rapid_heartbeat + anxiety1 + sleep_problems + anxiety2 +
      headaches + irritability + concentration + low_mood + illness + loneliness +
      workload + peer_competition + relationship_stress + professor_issues +
      work_env + relaxation_lack + home_env + conf_academic_perf + conf_subject_choice +
      activity_conflict + class_attendance + weight_change
) / 23.0 :: numeric, 2);

ALTER TABLE stress_dataset
ALTER COLUMN composite_stress_score TYPE NUMERIC
USING composite_stress_score::NUMERIC;

select composite_stress_score from stress_dataset;


--task 2
--qstn 1: Class Distribution: Counts and percentage for Eustress/No Stress/Distress.
SELECT 
    stress_type,
    COUNT(*) AS count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM stress_dataset), 2) AS percentage
FROM stress_dataset
GROUP BY stress_type;

select * from stress_dataset;

--qstn 2: Top Drivers (Proxy): For Distress cohort, list the 10 items with highest mean 
--        compared to overall mean (delta ranking).
SELECT 'stress_recent' AS item, 
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN stress_recent END) - AVG(stress_recent) AS delta
FROM stress_dataset
UNION ALL
SELECT 'rapid_heartbeat',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN rapid_heartbeat END) - AVG(rapid_heartbeat)
FROM stress_dataset
UNION ALL
SELECT 'anxiety1',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN anxiety1 END) - AVG(anxiety1)
FROM stress_dataset
UNION ALL
SELECT 'sleep_problems',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN sleep_problems END) - AVG(sleep_problems)
FROM stress_dataset
UNION ALL
SELECT 'anxiety2',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN anxiety2 END) - AVG(anxiety2)
FROM stress_dataset
UNION ALL
SELECT 'headaches',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN headaches END) - AVG(headaches)
FROM stress_dataset
UNION ALL
SELECT 'irritability',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN irritability END) - AVG(irritability)
FROM stress_dataset
UNION ALL
SELECT 'concentration',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN concentration END) - AVG(concentration)
FROM stress_dataset
UNION ALL
SELECT 'low_mood',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN low_mood END) - AVG(low_mood)
FROM stress_dataset
UNION ALL
SELECT 'illness',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN illness END) - AVG(illness)
FROM stress_dataset
UNION ALL
SELECT 'loneliness',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN loneliness END) - AVG(loneliness)
FROM stress_dataset
UNION ALL
SELECT 'workload',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN workload END) - AVG(workload)
FROM stress_dataset
UNION ALL
SELECT 'peer_competition',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN peer_competition END) - AVG(peer_competition)
FROM stress_dataset
UNION ALL
SELECT 'relationship_stress',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN relationship_stress END) - AVG(relationship_stress)
FROM stress_dataset
UNION ALL
SELECT 'professor_issues',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN professor_issues END) - AVG(professor_issues)
FROM stress_dataset
UNION ALL
SELECT 'work_env',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN work_env END) - AVG(work_env)
FROM stress_dataset
UNION ALL
SELECT 'relaxation_lack',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN relaxation_lack END) - AVG(relaxation_lack)
FROM stress_dataset
UNION ALL
SELECT 'home_env',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN home_env END) - AVG(home_env)
FROM stress_dataset
UNION ALL
SELECT 'conf_academic_perf',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN conf_academic_perf END) - AVG(conf_academic_perf)
FROM stress_dataset
UNION ALL
SELECT 'conf_subject_choice',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN conf_subject_choice END) - AVG(conf_subject_choice)
FROM stress_dataset
UNION ALL
SELECT 'activity_conflict',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN activity_conflict END) - AVG(activity_conflict)
FROM stress_dataset
UNION ALL
SELECT 'class_attendance',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN class_attendance END) - AVG(class_attendance)
FROM stress_dataset
UNION ALL
SELECT 'weight_change',
       AVG(CASE WHEN stress_type LIKE 'Distress%' THEN weight_change END) - AVG(weight_change)
FROM stress_dataset
ORDER BY delta DESC
LIMIT 10;


--task 3
--qstn 1: Rank students by Composite within Gender and Age band (DENSE_RANK());
--        return top-10 per segment.
SELECT *
FROM (
    SELECT 
        gender,
        age,
        composite_stress_score,
        DENSE_RANK() OVER (
            PARTITION BY gender, age 
            ORDER BY composite_stress_score DESC
        ) AS rank_within_segment
    FROM stress_dataset
    WHERE age BETWEEN 15 AND 30
) sub
WHERE rank_within_segment <= 10;

--qstn 2: Filters for Age (15-30), Gender, and Stress Type.
SELECT *
FROM stress_dataset
WHERE age BETWEEN 15 AND 30
  AND gender = 'Male'
  AND stress_type = 'Distress (Negative Stress) - Stress That Causes Anxiety And Impairs Well-Being.';

