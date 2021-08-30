*------------------------------------------------------------------------------------------------------------------------

Program Name: Step60_2019_Indication_Volumes.sas

Description:  Report 1 & 1b


Starting Author: Amy Jin (amy@docgraph.com)

*------------------------------------------------------------------------------------------------------------------------
COPYRIGHT: The DocGraph Journal 2020
LICENSE:    Proprietary Software, not available for sale or licensing
            This code represents trade secrets and commercial information owned by The DocGraph Journal
            considered privileged and confidential information.
*------------------------------------------------------------------------------------------------------------------------;
options fullstimer msglevel=i ;

%include "&myfiles_root./dua_027654/includes/includes.sas";

%put Program started at %sysfunc(time(),timeampm.) on %sysfunc(date(),worddate.).;

%let S30_STARTDATE = %sysfunc(date(),worddate.);
%let S30_STARTTIME = %sysfunc(time(),timeampm.);
%let S30_start = %sysfunc(datetime()) ;



/* Ind claims that have at least 1 encounter */
PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_NVS_KISQALI_ind_clm AS  /* bene_cnt = 209953 , clm_cnt = 3613679, nrow = 15134347 */
  SELECT clm.*
  FROM &perm_lib..&stub_prefix._&project_key._i_&RIFString. AS clm
  WHERE icd_group1 = 1 AND icd_group2 = 1
  ;
QUIT;


PROC SQL ;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_R1_ind AS 
  SELECT DISTINCT
  year(CLM_THRU_DT) AS year_id,
  &run_last_month. AS mth_end_id,
  'Xofigo' as brand,
  exp_rfr_npi as rfr_npi,
  rndrng_npi,
  COUNT(DISTINCT BENE_ID ) AS ind_pat_cnt
  FROM &perm_lib..C_NVS_KISQALI_ind_clm 
  GROUP BY year_id, brand, rfr_npi, rndrng_npi
  ;
QUIT;


/* convert npi to int */
data &SHARED_LIBRARY..C_nvs_kisqali_R1_ind;
  set &SHARED_LIBRARY..C_nvs_kisqali_R1_ind;
  rfr_npi_int = input(rfr_npi, 10.);
  drop rfr_npi;
  rename rfr_npi_int = rfr_npi;
run;

PROC SQL ;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_R1_merged AS 
  SELECT R1.*, ind.ind_pat_cnt
  FROM &perm_lib..C_nvs_kisqali_R1_flag as R1
  LEFT JOIN &perm_lib..C_nvs_kisqali_R1_ind as ind
  ON R1.year_id = ind.year_id AND R1.mth_end_id = ind.mth_end_id and R1.rfr_npi = ind.rfr_npi AND R1.rndrng_npi = ind.rndrng_npi
  ;
QUIT;



/* Flagging 
Only a few type 2 npis in report 1:
5850 out of 5876 rfr_npi are type 1 and
2825 out of 2829 rndrng_npi are type 1 */
PROC SQL ;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_R1_merged_zero AS 
  SELECT year_id, 
  mth_end_id,
  brand, 
  rfr_npi, 
  rndrng_npi, 
  pat_cnt,
  adm_frst_dt, 
  adm_lst_dt,
  CASE WHEN ind_pat_cnt = . THEN 0 ELSE ind_pat_cnt END AS ind_pat_cnt
  FROM &perm_lib..C_nvs_kisqali_R1_merged
  WHERE rfr_npi IS NOT NULL AND rndrng_npi IS NOT NULL;
QUIT;

PROC SQL ;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_R1_merged_flag AS 
  SELECT year_id, 
  mth_end_id,
  brand, 
  rfr_npi, 
  rndrng_npi, 
  CASE WHEN pat_cnt <11 AND pat_cnt <> 0 THEN -6 ELSE pat_cnt END AS pat_cnt,
  adm_frst_dt, 
  adm_lst_dt,
  CASE WHEN ind_pat_cnt <11 AND ind_pat_cnt <> 0 AND ind_pat_cnt <> . THEN -6 ELSE ind_pat_cnt END AS ind_pat_cnt
  FROM &perm_lib..C_nvs_kisqali_R1_merged_zero
  WHERE rfr_npi IS NOT NULL AND rndrng_npi IS NOT NULL;
QUIT;

/* convert npi to int */
data &SHARED_LIBRARY..C_nvs_kisqali_R1_merged_flag;
  set &SHARED_LIBRARY..C_nvs_kisqali_R1_merged_flag;
  rndrng_npi_int = input(rndrng_npi, 10.);
  drop rndrng_npi;
  rename rndrng_npi_int = rndrng_npi;
run;

PROC SQL ;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_R1_merged_flag1 AS 
  SELECT R1.year_id, 
  CASE WHEN R1.year_id in (2018, 2019, 2020) THEN 12 ELSE R1.mth_end_id END AS mth_end_id, 
  R1.brand, 
  R1.rfr_npi, 
  R1.rndrng_npi, 
  nppes_rfr.primary_taxonomy_description AS rfr_npi_spclty_desc,
  nppes_rfr.first_name AS rfr_frst_nm,
  '' AS rfr_mid_nm, 
  nppes_rfr.last_name AS rfr_lst_nm,

  nppes_rndrng.primary_taxonomy_description AS rndrng_npi_spclty_desc,
  nppes_rndrng.first_name AS rndrng_frst_nm,
  '' AS rndrng_mid_nm, 
  nppes_rndrng.last_name AS rndrng_lst_nm,

  R1.ind_pat_cnt,
  R1.pat_cnt,
  R1.adm_frst_dt, 
  R1.adm_lst_dt,
  CASE WHEN rfr_npi = rndrng_npi THEN 1 ELSE 0 END AS flg_slf_rfr
  FROM &perm_lib..C_nvs_kisqali_R1_merged_flag AS R1
  LEFT JOIN &SHARED_LIBRARY..PUF_CMS_NPPES_QUICK_DB AS nppes_rfr
  ON R1.rfr_npi = nppes_rfr.npi 
  LEFT JOIN &SHARED_LIBRARY..PUF_CMS_NPPES_QUICK_DB AS nppes_rndrng
  ON R1.rndrng_npi = nppes_rndrng.npi ;
QUIT;

/* QA */ 
* PROC SQL;
*   CREATE TABLE YJI989SL.C_nvs_kisqali_R1_RFR_type1 AS
*   SELECT *
*   FROM &SHARED_LIBRARY..C_nvs_kisqali_R1 AS R1
*   JOIN &SHARED_LIBRARY..PUF_CMS_NPPES_QUICK_DB AS NPPES
*   ON R1.rfr_npi = NPPES.npi 
*   WHERE NPPES.entity_type_code = 1
*   ;
* QUIT;

* PROC SQL;
*   CREATE TABLE YJI989SL.C_nvs_kisqali_R1_RNDRING_type1 AS
*   SELECT *
*   FROM &SHARED_LIBRARY..C_nvs_kisqali_R1 AS R1
*   JOIN &SHARED_LIBRARY..PUF_CMS_NPPES_QUICK_DB AS NPPES
*   ON R1.rndrng_npi = NPPES.npi 
*   WHERE NPPES.entity_type_code = 1
*   ;
* QUIT;


%let S30_ENDDATE = %sysfunc(date(),worddate.);
%let S30_ENDTIME = %sysfunc(time(),timeampm.);
%let S30_end = %sysfunc(datetime()) ;
%let S30_duration = %sysevalf((&S30_end. - &S30_start.)/60, ceil);

%flush("DURATION: &S30_duration. mins. || STARTED: &S30_STARTDATE. &S30_STARTTIME. || FINISHED: &S30_ENDDATE. &S30_ENDTIME.");