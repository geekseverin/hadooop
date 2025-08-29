-- Chargement des données
data = LOAD '/data/sample_data.csv' USING PigStorage(',') 
       AS (id:int, name:chararray, age:int, city:chararray, salary:int);

-- Suppression de l'en-tête
clean_data = FILTER data BY id IS NOT NULL AND id > 0;

-- Analyse par ville
city_stats = GROUP clean_data BY city;
city_analysis = FOREACH city_stats GENERATE 
    group AS city,
    COUNT(clean_data) AS employee_count,
    AVG(clean_data.salary) AS avg_salary,
    MAX(clean_data.salary) AS max_salary,
    MIN(clean_data.salary) AS min_salary;

-- Sauvegarde des résultats
STORE city_analysis INTO '/output/city_analysis' USING PigStorage(',');

-- Analyse par tranche d'âge
age_groups = FOREACH clean_data GENERATE 
    name,
    (age < 30 ? 'Young' : (age < 35 ? 'Middle' : 'Senior')) AS age_group,
    salary;

age_stats = GROUP age_groups BY age_group;
age_analysis = FOREACH age_stats GENERATE 
    group AS age_group,
    COUNT(age_groups) AS count,
    AVG(age_groups.salary) AS avg_salary;

STORE age_analysis INTO '/output/age_analysis' USING PigStorage(',');

-- Affichage des résultats
DUMP city_analysis;
DUMP age_analysis;