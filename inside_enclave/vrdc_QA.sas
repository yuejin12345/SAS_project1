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

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt,  /* bene_cnt = 7147, clm_cnt = 27935, nrow = 27935 */
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_NVS_KISQALI_MT21R40_4
  FROM &SHARED_LIBRARY..C_NVS_KISQALI_MT21R40_4
  ;
QUIT;


PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, /* bene_cnt = 4984, clm_cnt = 18026, nrow = 18026 */
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as NVS_exp_npi_QA
  FROM YJI989SL.NVS_exp_npi_QA
  ;
QUIT;


PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, /* bene_cnt = 0, clm_cnt = 0, nrow = 0 */
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as NVS_rndrng_QA
  FROM YJI989SL.NVS_rndrng_QA
  ;
QUIT;


/* --------------------------------- Step40_Report1 ---------------------------------*/
PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, /* bene_cnt = 7083*/
  count(*) as C_NVS_KISQALI_P_encounter_bene
  FROM &SHARED_LIBRARY..C_NVS_KISQALI_P_encounter_bene
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_NVS_KISQALI_xofigo_clm
  FROM &SHARED_LIBRARY..C_NVS_KISQALI_xofigo_clm
  ;
QUIT;


PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT encounter_CLM_ID) as clm_cnt, 
  count(*) as C_NVS_KISQALI_P_encounter
  FROM &SHARED_LIBRARY..C_NVS_KISQALI_P_encounter
  ;
QUIT;


PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as &stub_prefix._&project_key._exp_rfr_null
  FROM &SHARED_LIBRARY..&stub_prefix._&project_key._exp_rfr_null
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT xofigo_BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_exp_null_encounter
  FROM &SHARED_LIBRARY..C_nvs_kisqali_exp_null_encounter
  ;
QUIT;


PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_exp_null_enc_Tran
  FROM &SHARED_LIBRARY..C_nvs_kisqali_exp_null_enc_Tran
  ;
QUIT;






PROC SQL;  
  SELECT count(DISTINCT xofigo_BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_exp_null_enc_onc
  FROM &SHARED_LIBRARY..C_nvs_kisqali_exp_null_enc_onc
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT xofigo_BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_date
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_date
  ;
QUIT;


PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_clm
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_clm
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_c_RNDRNG
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_c_RNDRNG
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt,
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_OP
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_OP
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_AT
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_AT
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_OT
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_OT
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_SRVC_LOC
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_SRVC_LOC
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt,
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_ORG
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_ORG
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt,
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_OP1
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_OP1
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_OP2
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_OP2
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_AT1
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_AT1
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_AT2
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_AT2
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_OT1
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_OT1
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_OT2
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_OT2
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_SRVC_LOC1
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_SRVC_LOC1
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_SRVC_LOC2
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_SRVC_LOC2
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_ORG1
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_ORG1
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_ORG2
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_ORG2
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_OUTCAR
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_OUTCAR
  ;
QUIT;


PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_OUTCAR2
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_OUTCAR2
  ;
QUIT;


PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_no_imp_npi
  FROM &SHARED_LIBRARY..C_nvs_kisqali_no_imp_npi
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_rfr_npi
  FROM &SHARED_LIBRARY..C_nvs_kisqali_rfr_npi
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_NVS_KISQALI_xofigo_clm,
  count(distinct rndrng_npi) as rndrng_npi_cnt,
  count(distinct exp_rfr_npi) as rfr_npi_cnt
  FROM &SHARED_LIBRARY..C_NVS_KISQALI_xofigo_clm
  WHERE exp_rfr_npi IS NOT NULL
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_OUTCAR2,
  count(distinct rndrng_npi) as rndrng_npi_cnt,
  count(distinct imp_rfr_npi_unattri) as rfr_npi_cnt
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_OUTCAR2
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_recent_clm
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_clm
  ;
QUIT;

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT xofigo_CLM_ID) as clm_cnt, 
  count(*) as C_nvs_kisqali_no_imp_npi,
  count(distinct rndrng_npi) as rndrng_npi_cnt,
  count(distinct rfr_npi) as rfr_npi_cnt
  FROM &SHARED_LIBRARY..C_nvs_kisqali_no_imp_npi
  ;
QUIT;

/* --------------------------------- Step60_Report1_ind ---------------------------------*/

PROC SQL;  
  SELECT count(DISTINCT BENE_ID) as bene_cnt, 
  count(DISTINCT encounter_CLM_ID) as clm_cnt, 
  count(*) as C_NVS_KISQALI_ind_clm
  FROM &SHARED_LIBRARY..C_NVS_KISQALI_ind_clm
  ;
QUIT;












%let S30_ENDDATE = %sysfunc(date(),worddate.);
%let S30_ENDTIME = %sysfunc(time(),timeampm.);
%let S30_end = %sysfunc(datetime()) ;
%let S30_duration = %sysevalf((&S30_end. - &S30_start.)/60, ceil);

%flush("DURATION: &S30_duration. mins. || STARTED: &S30_STARTDATE. &S30_STARTTIME. || FINISHED: &S30_ENDDATE. &S30_ENDTIME.");