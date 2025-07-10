CREATE OR REPLACE VIEW "GAP_PRODUCTS"."AKFIN_BIOMASS_V" AS
SELECT            SV.SURVEY_NAME,
           SV.SURVEY_DEFINITION_ID,
           B.YEAR,
           B.AREA_ID                   AS AREA_ID,
           B.SPECIES_CODE,
           N_HAUL,
           N_WEIGHT,
N_COUNT,
N_LENGTH,
CPUE_KGKM2_MEAN,
CPUE_KGKM2_VAR,
CPUE_NOKM2_MEAN,
CPUE_NOKM2_VAR,
BIOMASS_MT,
BIOMASS_VAR,
POPULATION_COUNT,
POPULATION_VAR,
           T.COMMON_NAME,
           T.SPECIES_NAME,
           A.AREA_TYPE                 AS AREA_TYPE,
           SV.SURVEY_CODE,
           A.DEPTH_MIN_M               AS DEPTH_MIN_M,
           A.DEPTH_MAX_M               AS DEPTH_MAX_M,
           A.AREA_NAME                 AS AREA_NAME,
           A.DESCRIPTION               AS AREA_DESCRIPTION,
           A.AREA_KM2,
           S.DESIGN_YEAR,
           SAA.REGION,
           SAA.REGULATORY_AREA,
           SAA.INPFC_BY_DEPTH,
           SAA.INPFC,
           SAA.DEPTH,
           SAA.NMFS_STATISTICAL_AREA,
           SAA.REGULATORY_AREA_BY_DEPTH,
           SAA.SUBAREA,           
           B.akfin_load_date as akfin_load_date
      --NULL AS MIN_STRATUM_POPULATION, /*deprecated*/
      --NULL AS MAX_STRATUM_POPULATION /*deprecated*/
      FROM GAP_PRODUCTS.AKFIN_BIOMASS  B
           JOIN GAP_PRODUCTS.AKFIN_SURVEY_DESIGN S
               ON     B.SURVEY_DEFINITION_ID = S.SURVEY_DEFINITION_ID
                  AND B.YEAR = S.YEAR
           LEFT JOIN GAP_PRODUCTS.AKFIN_SURVEY_V SV 
           ON B.SURVEY_DEFINITION_ID=SV.SURVEY_DEFINITION_ID
           JOIN GAP_PRODUCTS.AKFIN_AREA A
               ON     S.SURVEY_DEFINITION_ID = A.SURVEY_DEFINITION_ID
                  AND S.DESIGN_YEAR = A.DESIGN_YEAR
                  AND B.AREA_ID = A.AREA_ID
           /*LEFT JOIN GAP_PRODUCTS.AKFIN_TAXONOMIC_CLASSIFICATION T*/
           left join (select distinct species_code, species_name, common_name from gap_products.akfin_taxonomic_groups) t
               ON B.SPECIES_CODE = T.SPECIES_CODE
            /*LEFT JOIN GAP_PRODUCTS.STRATUM_GROUP_ASSIGNMENT. This is a pivoted version of the akfin_area and akfin_stratum_groups tables T*/   
           left join STRATUM_AREA_ASSIGNMENTS SAA
                ON SAA.SURVEY_DEFINITION_ID=B.SURVEY_DEFINITION_ID
                AND B.AREA_ID = SAA.STRATUM
                AND S.DESIGN_YEAR = SAA.DESIGN_YEAR;


CREATE OR REPLACE VIEW "GAP_PRODUCTS"."AKFIN_SIZECOMP_V" AS
  SELECT 
           SV.SURVEY_NAME,
           SV.SURVEY_DEFINITION_ID,
           SC.YEAR,
           SC.AREA_ID                   AS AREA_ID,
           SC.SPECIES_CODE,
           SC.LENGTH_MM,
           SC.SEX,
           POPULATION_COUNT            AS POPULATION_NUMBER,
           T.COMMON_NAME,
           T.SPECIES_NAME,
           A.AREA_TYPE                 AS AREA_TYPE,
           SV.SURVEY_CODE,
           A.DEPTH_MIN_M               AS DEPTH_MIN_M,
           A.DEPTH_MAX_M               AS DEPTH_MAX_M,
           A.AREA_NAME                 AS AREA_NAME,
           A.DESCRIPTION               AS AREA_DESCRIPTION,
            A.AREA_KM2,
           S.DESIGN_YEAR,
           SAA.REGION,
           SAA.REGULATORY_AREA,
           SAA.INPFC_BY_DEPTH,
           SAA.INPFC,
           SAA.DEPTH,
           SAA.NMFS_STATISTICAL_AREA,
           SAA.REGULATORY_AREA_BY_DEPTH,
           SAA.SUBAREA,           
           SC.akfin_load_date as akfin_load_date
      --NULL AS MIN_STRATUM_POPULATION, /*deprecated*/
      --NULL AS MAX_STRATUM_POPULATION /*deprecated*/
      FROM GAP_PRODUCTS.AKFIN_SIZECOMP  SC
           JOIN GAP_PRODUCTS.AKFIN_SURVEY_DESIGN S
               ON     SC.SURVEY_DEFINITION_ID = S.SURVEY_DEFINITION_ID
                  AND SC.YEAR = S.YEAR
           LEFT JOIN GAP_PRODUCTS.AKFIN_SURVEY_V SV 
           ON SC.SURVEY_DEFINITION_ID=SV.SURVEY_DEFINITION_ID
           JOIN GAP_PRODUCTS.AKFIN_AREA A
               ON     S.SURVEY_DEFINITION_ID = A.SURVEY_DEFINITION_ID
                  AND S.DESIGN_YEAR = A.DESIGN_YEAR
                  AND SC.AREA_ID = A.AREA_ID
           /*LEFT JOIN GAP_PRODUCTS.AKFIN_TAXONOMIC_CLASSIFICATION T*/
           left join (select distinct species_code, species_name, common_name from gap_products.akfin_taxonomic_groups) t
               ON SC.SPECIES_CODE = T.SPECIES_CODE
            /*LEFT JOIN GAP_PRODUCTS.STRATUM_GROUP_ASSIGNMENT. This is a pivoted version of the akfin_area and akfin_stratum_groups tables T*/   
           left join STRATUM_AREA_ASSIGNMENTS SAA
                ON SAA.SURVEY_DEFINITION_ID=SC.SURVEY_DEFINITION_ID
                AND SC.AREA_ID = SAA.STRATUM
                AND S.DESIGN_YEAR = SAA.DESIGN_YEAR
;

SELECT COUNT(*) FROM AKFIN_SIZECOMP; --3234183
SELECT COUNT(*) FROM AKFIN_SIZECOMP_V; --3234183

CREATE OR REPLACE VIEW "GAP_PRODUCTS"."AKFIN_AGECOMP_V" AS
  SELECT 
           SV.SURVEY_NAME,
           SV.SURVEY_DEFINITION_ID,
           AC.YEAR,
           AC.AREA_ID,
           AC.SPECIES_CODE,
           AC.SEX,
           AC.AGE,
           AC.POPULATION_COUNT,
           AC.LENGTH_MM_MEAN, 
           AC.LENGTH_MM_SD,
           AC.AREA_ID_FOOTPRINT,
           T.COMMON_NAME,
           T.SPECIES_NAME,
           A.AREA_TYPE,
           SV.SURVEY_CODE,
           A.DEPTH_MIN_M,
           A.DEPTH_MAX_M,
           A.AREA_NAME,
           A.DESCRIPTION               AS AREA_DESCRIPTION,
            A.AREA_KM2,
           S.DESIGN_YEAR,
           SAA.REGION,
           SAA.REGULATORY_AREA,
           SAA.INPFC_BY_DEPTH,
           SAA.INPFC,
           SAA.DEPTH,
           SAA.NMFS_STATISTICAL_AREA,
           SAA.REGULATORY_AREA_BY_DEPTH,
           SAA.SUBAREA,           
           AC.akfin_load_Date as akfin_load_date
      --NULL AS MIN_STRATUM_POPULATION, /*deprecated*/
      --NULL AS MAX_STRATUM_POPULATION /*deprecated*/
      FROM GAP_PRODUCTS.AKFIN_AGECOMP  AC
           JOIN GAP_PRODUCTS.AKFIN_SURVEY_DESIGN S
               ON     AC.SURVEY_DEFINITION_ID = S.SURVEY_DEFINITION_ID
                  AND AC.YEAR = S.YEAR
           LEFT JOIN GAP_PRODUCTS.AKFIN_SURVEY_V SV 
           ON AC.SURVEY_DEFINITION_ID=SV.SURVEY_DEFINITION_ID
           JOIN GAP_PRODUCTS.AKFIN_AREA A
               ON     S.SURVEY_DEFINITION_ID = A.SURVEY_DEFINITION_ID
                  AND S.DESIGN_YEAR = A.DESIGN_YEAR
                  AND AC.AREA_ID = A.AREA_ID
           /*LEFT JOIN GAP_PRODUCTS.AKFIN_TAXONOMIC_CLASSIFICATION T*/
           left join (select distinct species_code, species_name, common_name from gap_products.akfin_taxonomic_groups) t
               ON AC.SPECIES_CODE = T.SPECIES_CODE
            /*LEFT JOIN GAP_PRODUCTS.STRATUM_GROUP_ASSIGNMENT. This is a pivoted version of the akfin_area and akfin_stratum_groups tables T*/   
           left join STRATUM_AREA_ASSIGNMENTS SAA
                ON SAA.SURVEY_DEFINITION_ID=AC.SURVEY_DEFINITION_ID
                AND AC.AREA_ID = SAA.STRATUM
                AND S.DESIGN_YEAR = SAA.DESIGN_YEAR
;

SELECT COUNT(*) FROM AKFIN_AGECOMP; --680450
SELECT COUNT(*) FROM AKFIN_AGECOMP_V; --680450

SELECT COLUMN_NAME
  FROM all_tab_cols
 WHERE table_name = 'AKFIN_HAUL'
 and owner = 'GAP_PRODUCTS';
 
  CREATE OR REPLACE VIEW "GAP_PRODUCTS"."AKFIN_HAUL_V" AS
        SELECT 
            C.YEAR,
            C.SURVEY_DEFINITION_ID,
            C.SURVEY_NAME,
            SV.SURVEY_CODE,
            H.*,
            S.DESIGN_YEAR,
            SAA.REGION,
           SAA.REGULATORY_AREA,
           SAA.INPFC_BY_DEPTH,
           SAA.INPFC,
           SAA.DEPTH,
           SAA.NMFS_STATISTICAL_AREA,
           SAA.REGULATORY_AREA_BY_DEPTH,
           SAA.SUBAREA
        FROM AKFIN_HAUL H
        LEFT JOIN AKFIN_CRUISE C
        ON H.CRUISEJOIN = C.CRUISEJOIN
        LEFT JOIN GAP_PRODUCTS.AKFIN_SURVEY_DESIGN S
               ON     C.SURVEY_DEFINITION_ID = S.SURVEY_DEFINITION_ID
                  AND C.YEAR = S.YEAR
        LEFT JOIN GAP_PRODUCTS.AKFIN_SURVEY_V SV 
           ON C.SURVEY_DEFINITION_ID=SV.SURVEY_DEFINITION_ID
        LEFT JOIN STRATUM_AREA_ASSIGNMENTS SAA
        ON C.SURVEY_DEFINITION_ID = SAA.SURVEY_DEFINITION_ID
        AND H.STRATUM = SAA.STRATUM
        AND S.DESIGN_YEAR=SAA.DESIGN_YEAR
        ;

        SELECT COUNT(*) FROM GAP_PRODUCTS.AKFIN_HAUL; --34193
        SELECT COUNT(*) FROM GAP_PRODUCTS.AKFIN_HAUL_V; --
        
 CREATE OR REPLACE VIEW "GAP_PRODUCTS"."AKFIN_CATCH_V" AS
SELECT  
C.CATCHJOIN,
C.SPECIES_CODE,
C.WEIGHT_KG,
C.COUNT,
T.COMMON_NAME,
T.SPECIES_NAME,
H.*
FROM AKFIN_CATCH C
 left join (select distinct species_code, species_name, common_name from gap_products.akfin_taxonomic_groups) t
               ON C.SPECIES_CODE = T.SPECIES_CODE
 LEFT JOIN AKFIN_HAUL_V H
 ON C.HAULJOIN=H.HAULJOIN;
 
         SELECT COUNT(*) FROM GAP_PRODUCTS.AKFIN_CATCH; --971788
        SELECT COUNT(*) FROM GAP_PRODUCTS.AKFIN_CATCH_V; --971788
        
         CREATE OR REPLACE VIEW "GAP_PRODUCTS"."AKFIN_CPUE_V" AS
SELECT  
C.SPECIES_CODE,
C.WEIGHT_KG,
C.COUNT,
C.AREA_SWEPT_KM2,
C.CPUE_KGKM2,
C.CPUE_NOKM2,
T.COMMON_NAME,
T.SPECIES_NAME,
H.*
FROM AKFIN_CPUE C
 left join (select distinct species_code, species_name, common_name from gap_products.akfin_taxonomic_groups) t
               ON C.SPECIES_CODE = T.SPECIES_CODE
 LEFT JOIN AKFIN_HAUL_V H
 ON C.HAULJOIN=H.HAULJOIN;
 
          SELECT COUNT(*) FROM GAP_PRODUCTS.AKFIN_CPUE; --21281100
        SELECT COUNT(*) FROM GAP_PRODUCTS.AKFIN_CPUE_V; --21281100

 CREATE OR REPLACE VIEW "GAP_PRODUCTS"."AKFIN_LENGTH_V" AS
SELECT         
C.SPECIES_CODE,
C.SEX,
C.FREQUENCY,
C.LENGTH_MM,
C.LENGTH_TYPE,
C.SAMPLE_TYPE,
T.COMMON_NAME,
T.SPECIES_NAME,
H.*
FROM AKFIN_LENGTH C
 left join (select distinct species_code, species_name, common_name from gap_products.akfin_taxonomic_groups) t
               ON C.SPECIES_CODE = T.SPECIES_CODE
 LEFT JOIN AKFIN_HAUL_V H
 ON C.HAULJOIN=H.HAULJOIN;


        SELECT COUNT(*) FROM GAP_PRODUCTS.AKFIN_LENGTH; --4448213
        SELECT COUNT(*) FROM GAP_PRODUCTS.AKFIN_LENGTH_V; --4448213
        
         CREATE OR REPLACE VIEW "GAP_PRODUCTS"."AKFIN_SPECIMEN_V" AS
SELECT  
C.SPECIMEN_ID,
C.SPECIES_CODE,
C.LENGTH_MM,
C.SEX,
C.WEIGHT_G,
C.AGE,
C.MATURITY,
C.GONAD_G,
C.SPECIMEN_SUBSAMPLE_METHOD,
C.SPECIMEN_SAMPLE_TYPE,
C.AGE_DETERMINATION_METHOD,
T.COMMON_NAME,
T.SPECIES_NAME,
H.*
FROM AKFIN_SPECIMEN C
 left join (select distinct species_code, species_name, common_name from gap_products.akfin_taxonomic_groups) t
               ON C.SPECIES_CODE = T.SPECIES_CODE
 LEFT JOIN AKFIN_HAUL_V H
 ON C.HAULJOIN=H.HAULJOIN;
 
         SELECT COUNT(*) FROM GAP_PRODUCTS.AKFIN_SPECIMEN_V; --588066
         SELECT COUNT(*) FROM GAP_PRODUCTS.AKFIN_SPECIMEN;
         
         --some poking around
select distinct(area_id) from akfin_agecomp where survey_definition_id = 98;

select * from akfin_sizecomp_v;

select * from akfin_SIZECOMP_v
where year=2024
and survey_definition_id=52
and species_code = 21740
and area_type='DEPTH'
;

SELECT DISTINCT(AREA_TYPE), SURVEY_DEFINITION_ID FROM AKFIN_AREA ORDER BY SURVEY_DEFINITION_ID;

create table stratum_area_assignments_bu as select * from stratum_area_assignments;

-- function for pivoting stratum groups
-- Remove akfin_load_date from result columns
drop view stratum_area_assignment_v;

create or replace view stratum_area_assignments as 
WITH area AS (
    SELECT *
    FROM AKFIN_AREA
    -- Exclude akfin_load_date if needed
),
sd AS (
    SELECT *
    FROM AKFIN_SURVEY_DESIGN
),
sd_sum AS (
    SELECT DISTINCT survey_definition_id, design_year
    FROM sd
),
area_current_design AS (
    SELECT a.*
    FROM area a
    INNER JOIN sd_sum s
        ON a.survey_definition_id = s.survey_definition_id
        AND a.design_year = s.design_year
),
strata AS (
    SELECT a.*, a.area_id AS stratum
    FROM area_current_design a
    WHERE a.area_type = 'STRATUM'
),
sg AS (
    SELECT g.*
    FROM AKFIN_STRATUM_GROUPS g
    INNER JOIN sd_sum s
        ON g.survey_definition_id = s.survey_definition_id
        AND g.design_year = s.design_year
),
sa AS (
    SELECT
        sg.survey_definition_id,
        sg.stratum,
        a.area_type,
        a.area_name,
        sg.design_year
    FROM sg
    INNER JOIN area_current_design a
        ON sg.survey_definition_id = a.survey_definition_id
        AND sg.design_year = a.design_year
        AND sg.area_id = a.area_id
    WHERE a.area_type != 'STRATUM'
)
SELECT
    survey_definition_id,
    stratum,
    design_year,
    LISTAGG(CASE WHEN area_type = 'REGION' THEN area_name END, ', ') 
        WITHIN GROUP (ORDER BY area_name) AS REGION,
    LISTAGG(CASE WHEN area_type = 'REGULATORY AREA' THEN area_name END, ', ') 
        WITHIN GROUP (ORDER BY area_name) AS REGULATORY_AREA,
    LISTAGG(CASE WHEN area_type = 'INPFC BY DEPTH' THEN area_name END, ', ') 
        WITHIN GROUP (ORDER BY area_name) AS INPFC_BY_DEPTH,
    LISTAGG(CASE WHEN area_type = 'INPFC' THEN area_name END, ', ') 
        WITHIN GROUP (ORDER BY area_name) AS INPFC,
    LISTAGG(CASE WHEN area_type = 'DEPTH' THEN area_name END, ', ') 
        WITHIN GROUP (ORDER BY area_name) AS DEPTH,
    LISTAGG(CASE WHEN area_type = 'NMFS STATISTICAL AREA' THEN area_name END, ', ') 
        WITHIN GROUP (ORDER BY area_name) AS NMFS_STATISTICAL_AREA,
    LISTAGG(CASE WHEN area_type = 'REGULATORY AREA BY DEPTH' THEN area_name END, ', ') 
        WITHIN GROUP (ORDER BY area_name) AS REGULATORY_AREA_BY_DEPTH,
    LISTAGG(CASE WHEN area_type = 'SUBAREA' THEN area_name END, ', ') 
        WITHIN GROUP (ORDER BY area_name) AS SUBAREA
FROM sa
GROUP BY survey_definition_id, stratum, design_year
ORDER BY survey_definition_id, stratum, design_year;
commit;