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

/* Xofigo patients who have BOTH “malignant prostate” and “metastatic identification” on the same claim. */
PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_NVS_KISQALI_P_encounter_bene AS /* bene_cnt = 7333*/
  SELECT distinct BENE_ID
  FROM &SHARED_LIBRARY..C_NVS_KISQALI_P_MT21R68_5                 /* bene_cnt =  */
  WHERE icd_group1 = 1 AND icd_group2 = 1
  ;
QUIT;

/* Xofigo claims that have at least 1 encounter */
PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_NVS_KISQALI_xofigo_clm AS  /* bene_cnt = 7333, clm_cnt = 29042, nrow = 29042 */
  SELECT clm.*
  FROM &SHARED_LIBRARY..C_NVS_KISQALI_MT21R41_5 AS clm
  JOIN &SHARED_LIBRARY..C_NVS_KISQALI_P_encounter_bene AS bene
  ON clm.BENE_ID = bene.BENE_ID 
  ;
QUIT;


/* Encounter Claims for Xofigo patients. */
PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_NVS_KISQALI_P_encounter AS /* bene_cnt = 7333, clm_cnt = 552186, nrow = 2196627 */
  SELECT *
  FROM &SHARED_LIBRARY..C_NVS_KISQALI_P_MT21R68_5            /* bene_cnt =  */
  WHERE icd_group1 = 1 AND icd_group2 = 1
  ;
QUIT;

/*Referring NPI [rfr_npi] We will identify explicit referrals by NPI using the referring NPI variable. If the explicit referring NPI is not 
available or the referring NPI variable matches the rendering NPI, then we will identify implicit referrals by a look back period of 120 days 
before Xofigo administration. We will identify the rendering NPI from the most recent encounter with the indication and will assign that NPI 
as the referring NPI. If both the referring NPI variable is missing and there is no implicit referral, the rendering NPI will be listed as the referring NPI.
Referring NPIs will be limited to NPPES Type 1 (professional) NPIs.  All taxonomies will be included.  We anticipate to see the following as most common:
Oncology
Urology
*/
/* Implicit Referring NPI */
/* Cases when there is no Explicit Referring NPI */
PROC SQL ;
  CREATE TABLE &SHARED_LIBRARY..&stub_prefix._&project_key._exp_rfr_null AS  /* bene_cnt = 5128, clm_cnt = 18738, nrow = 18738 */
  SELECT * 
  FROM  &perm_lib..C_NVS_KISQALI_xofigo_clm
  WHERE exp_rfr_npi IS NULL 
  ;
QUIT;

/* Join with prostate claims to get encounters within 120 days for Xofigo patient with null Explicit Referring NPI */
PROC SQL ;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_exp_null_encounter AS         /* bene_cnt = 5095, clm_cnt = 18595, nrow = 884892 we are losing  patients because they don’t have implicit referring npi in 120 days lookback period.*/
  SELECT xofigo_bene.BENE_ID AS xofigo_BENE_ID, 
        xofigo_CLM_ID,  
        xofigo_bene.CLM_THRU_DT AS xofigo_dt, 
        rndrng_npi,
        encounters.*
  FROM  &SHARED_LIBRARY..&stub_prefix._&project_key._exp_rfr_null AS xofigo_bene
  JOIN &SHARED_LIBRARY..C_NVS_KISQALI_P_encounter AS encounters 
  ON xofigo_bene.BENE_ID = encounters.BENE_ID
  WHERE xofigo_bene.CLM_THRU_DT >= encounters.CLM_THRU_DT 
      AND xofigo_bene.CLM_THRU_DT <= encounters.CLM_THRU_DT + 120   /*120 days before Xofigo administration*/
  ;
QUIT;

/* Transpose implicit referring npi from all field to get imp_rfr_npi_unattri */
PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_exp_null_enc_Tran AS        /* bene_cnt = 5095, clm_cnt = 18595, nrow = 393427 */
  SELECT *, claim_RNDRNG_PHYSN_NPI AS imp_rfr_npi_unattri, 
  'claim_RNDRNG_PHYSN_NPI' AS imp_rfr_npi_source
  FROM &SHARED_LIBRARY..C_nvs_kisqali_exp_null_encounter                  
  WHERE setting = 'Outpatient' AND claim_RNDRNG_PHYSN_NPI IS NOT NULL
  UNION 
    SELECT *, OP_PHYSN_NPI AS imp_rfr_npi_unattri , 
  'OP_PHYSN_NPI' AS imp_rfr_npi_source
  FROM &SHARED_LIBRARY..C_nvs_kisqali_exp_null_encounter 
  WHERE setting = 'Outpatient' AND OP_PHYSN_NPI IS NOT NULL
  UNION 
    SELECT *, AT_PHYSN_NPI AS imp_rfr_npi_unattri, 
  'AT_PHYSN_NPI' AS imp_rfr_npi_source 
  FROM &SHARED_LIBRARY..C_nvs_kisqali_exp_null_encounter 
  WHERE setting = 'Outpatient' AND AT_PHYSN_NPI IS NOT NULL
    UNION 
    SELECT *, OT_PHYSN_NPI AS imp_rfr_npi_unattri, 
  'OT_PHYSN_NPI' AS imp_rfr_npi_source 
  FROM &SHARED_LIBRARY..C_nvs_kisqali_exp_null_encounter 
  WHERE setting = 'Outpatient' AND OT_PHYSN_NPI IS NOT NULL
    UNION 
    SELECT *, SRVC_LOC_NPI_NUM AS imp_rfr_npi_unattri, 
  'SRVC_LOC_NPI_NUM' AS imp_rfr_npi_source 
  FROM &SHARED_LIBRARY..C_nvs_kisqali_exp_null_encounter 
  WHERE setting = 'Outpatient' AND SRVC_LOC_NPI_NUM IS NOT NULL
    UNION 
    SELECT *, ORG_NPI_NUM AS imp_rfr_npi_unattri, 
  'ORG_NPI_NUM' AS imp_rfr_npi_source 
  FROM &SHARED_LIBRARY..C_nvs_kisqali_exp_null_encounter 
  WHERE setting = 'Outpatient' AND ORG_NPI_NUM IS NOT NULL
    UNION 
    SELECT *, PRF_PHYSN_NPI AS imp_rfr_npi_unattri, 
  'PRF_PHYSN_NPI' AS imp_rfr_npi_source 
  FROM &SHARED_LIBRARY..C_nvs_kisqali_exp_null_encounter 
  WHERE setting = 'Carrier' AND PRF_PHYSN_NPI IS NOT NULL
;
QUIT;

/* convert npi to int */
data &SHARED_LIBRARY..C_nvs_kisqali_exp_null_enc_Tran;
  set &SHARED_LIBRARY..C_nvs_kisqali_exp_null_enc_Tran;
  imp_rfr_npi_unattri_int = input(imp_rfr_npi_unattri, 10.);
  drop imp_rfr_npi_unattri;
  rename imp_rfr_npi_unattri_int = imp_rfr_npi_unattri;
run;



/* The implicit referring NPI method is designed to find the most recent Oncologist, MedOnc, HemOnc or Urologist  that the Patient saw by using the taxonomy of the Provider defined in NPPES. 
We cannot use the old imp_rfr_npi for now because taxonomy type is more important than the npi source. 
 */
PROC SQL ;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_exp_null_enc_onc AS         /* bene_cnt = 4567, clm_cnt = 16095, nrow = 108959 */
  SELECT encounter.*, nppes.primary_taxonomy_description, nppes.primary_taxonomy_code
  FROM &SHARED_LIBRARY..C_nvs_kisqali_exp_null_enc_Tran AS encounter 
  JOIN &SHARED_LIBRARY..PUF_CMS_NPPES_QUICK_DB AS nppes 
  ON encounter.imp_rfr_npi_unattri = nppes.npi
  WHERE nppes.primary_taxonomy_code in ('207RH0000X','207RH0003X','207RX0202X','207ZH0000X','2086X0206X',
'208800000X','2088F0040X','163WX0200X','163WU0100X','364SX0200X','246QH0000X','261QX0200X')
  ;
QUIT;




/* Find the most recent encounter date within 120 days for Xofigo patient with null Explicit Referring NPI */
PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_recent_date AS     /* bene_cnt = 4567, clm_cnt = 16095, nrow = 16095 */
  SELECT DISTINCT xofigo_BENE_ID, 
        xofigo_CLM_ID, 
        xofigo_dt, 
        MAX(CLM_THRU_DT) AS max_encounter_CLM_THRU_DT format date9.
  FROM &SHARED_LIBRARY..C_nvs_kisqali_exp_null_enc_onc
  GROUP BY xofigo_BENE_ID, xofigo_dt
  ;
QUIT;





/* Find the most encounter claims within 120 days for Xofigo patient with null Explicit Referring NPI 
If the most recent encounter has multiple claims on the same most recent date, referring attribution will 
be assigned to all relevant attributed NPIs.
There are 200/22031 imp_rfr_npi_unattri <> imp_rfr_npi, which makes sense because imp_rfr_npi_unattri is unattributed and imp_rfr_npi is attributed. */
PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_recent_clm AS      /* bene_cnt = 4567, clm_cnt = 16095, nrow = 26747 */
  SELECT DISTINCT BENE_ID, 
      most_recent_date.xofigo_BENE_ID, 
      most_recent_date.xofigo_CLM_ID, 
      most_recent_date.xofigo_dt, 
      most_recent_date.max_encounter_CLM_THRU_DT,
      imp_rfr_npi_unattri, 
      imp_rfr_npi_source,
      rndrng_npi,
      encounter.encounter_dt, 
      encounter.encounter_CLM_ID, 
      encounter.imp_rfr_npi, 
      encounter.setting
  FROM &SHARED_LIBRARY..C_nvs_kisqali_exp_null_enc_onc AS encounter
  JOIN &SHARED_LIBRARY..C_nvs_kisqali_recent_date AS most_recent_date
  ON encounter.xofigo_BENE_ID = most_recent_date.xofigo_BENE_ID
    AND encounter.CLM_THRU_DT = most_recent_date.max_encounter_CLM_THRU_DT
  ;
QUIT;


/* convert npi to int */
data &SHARED_LIBRARY..C_nvs_kisqali_recent_clm;
  set &SHARED_LIBRARY..C_nvs_kisqali_recent_clm;
  imp_rfr_npi_int = input(imp_rfr_npi, 10.);
  drop imp_rfr_npi;
  rename imp_rfr_npi_int = imp_rfr_npi;
run;



/* Implicit Referring NPI order for OUT: 
Rendering Physician NPI (claim_RNDRNG_PHYSN_NPI) 
Operating Physician NPI (OP_PHYSN_NPI)   
Attending Physician NPI (AT_PHYSN_NPI)    
Other Physician NPI (OT_PHYSN_NPI)    
Service Location NPI (SRVC_LOC_NPI_NUM) 
Organizational NPI (ORG_NPI_NUM)
 */
PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_recent_c_RNDRNG AS      /* bene_cnt = 6, clm_cnt = 13, nrow = 19 */
  SELECT *
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_clm
  WHERE imp_rfr_npi_source = 'claim_RNDRNG_PHYSN_NPI' AND setting = 'Outpatient'
;
QUIT;

PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_recent_OP AS            /* bene_cnt = 773, clm_cnt = 1903, nrow = 2409 */
  SELECT *
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_clm
  WHERE imp_rfr_npi_source = 'OP_PHYSN_NPI' AND setting = 'Outpatient'
;
QUIT;

PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_recent_AT AS            /* bene_cnt = 3304, clm_cnt = 10648, nrow = 13120 */
  SELECT *
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_clm
  WHERE imp_rfr_npi_source = 'AT_PHYSN_NPI' AND setting = 'Outpatient'
;
QUIT;

PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_recent_OT AS            /* bene_cnt = 13, clm_cnt = 25, nrow = 25 */
  SELECT *
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_clm
  WHERE imp_rfr_npi_source = 'OT_PHYSN_NPI' AND setting = 'Outpatient'
;
QUIT;

PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_recent_SRVC_LOC AS      /* bene_cnt = 16, clm_cnt = 41, nrow = 49 */
  SELECT *
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_clm
  WHERE imp_rfr_npi_source = 'SRVC_LOC_NPI_NUM' AND setting = 'Outpatient'
;
QUIT;

PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_recent_ORG AS           /* bene_cnt = 16, clm_cnt = 38, nrow = 42 */
  SELECT *
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_clm
  WHERE imp_rfr_npi_source = 'ORG_NPI_NUM' AND setting = 'Outpatient'
;
QUIT;

/* Keep OP_PHYSN_NPI if claim_RNDRNG_PHYSN_NPI is not available */
PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_recent_OP1 AS           /* bene_cnt = 772, clm_cnt = 1902, nrow = 2408 */
  SELECT OP.*
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_c_RNDRNG AS RNDRNG 
  RIGHT JOIN &SHARED_LIBRARY..C_nvs_kisqali_recent_OP AS OP
  ON RNDRNG.xofigo_CLM_ID = OP.xofigo_CLM_ID 
  WHERE RNDRNG.xofigo_CLM_ID IS NULL 
  ;
QUIT;

/* Claims when claim_RNDRNG_PHYSN_NPI is implicit rfr npi 
  + Claims when OP_PHYSN_NPI is implicit rfr npi  */
PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_recent_OP2 AS           /* bene_cnt = 778, clm_cnt = 1915, nrow = 2427 */
  SELECT * 
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_OP1
  UNION 
  SELECT * 
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_c_RNDRNG
  ;
QUIT;

/* Keep AT_PHYSN_NPI if claim_RNDRNG_PHYSN_NPI/OP_PHYSN_NPI is not available */
PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_recent_AT1 AS           /* bene_cnt = 2837, clm_cnt = 8765, nrow = 10734 */
  SELECT lower_priority.*
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_OP2 AS higher_priority 
  RIGHT JOIN &SHARED_LIBRARY..C_nvs_kisqali_recent_AT AS lower_priority
  ON higher_priority.xofigo_CLM_ID = lower_priority.xofigo_CLM_ID 
  WHERE higher_priority.xofigo_CLM_ID IS NULL 
  ;
QUIT;

/* Claims when claim_RNDRNG_PHYSN_NPI is implicit rfr npi 
  + Claims when OP_PHYSN_NPI is implicit rfr npi  
  + Claims when AT_PHYSN_NPI is implicit rfr npi*/
PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_recent_AT2 AS           /* bene_cnt = 3307, clm_cnt = 10680, nrow = 13161 */ 
  SELECT * 
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_OP2
  UNION 
  SELECT * 
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_AT1
  ;
QUIT;


/* Keep OT_PHYSN_NPI if claim_RNDRNG_PHYSN_NPI/OP_PHYSN_NPI/AT_PHYSN_NPI is not available */
PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_recent_OT1 AS           /* bene_cnt = 3, clm_cnt = 5, nrow = 5 */ 
  SELECT lower_priority.*
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_AT2 AS higher_priority 
  RIGHT JOIN &SHARED_LIBRARY..C_nvs_kisqali_recent_OT AS lower_priority
  ON higher_priority.xofigo_CLM_ID = lower_priority.xofigo_CLM_ID 
  WHERE higher_priority.xofigo_CLM_ID IS NULL 
  ;
QUIT;

/* Claims when claim_RNDRNG_PHYSN_NPI is implicit rfr npi 
  + Claims when OP_PHYSN_NPI is implicit rfr npi  
  + Claims when AT_PHYSN_NPI is implicit rfr npi
  + Claims when OT_PHYSN_NPI is implicit rfr npi */
PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_recent_OT2 AS           /* bene_cnt = 3308, clm_cnt = 10685, nrow = 13166 */ 
  SELECT * 
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_AT2
  UNION 
  SELECT * 
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_OT1
  ;
QUIT;


/* Keep SRVC_LOC_NPI_NUM if claim_RNDRNG_PHYSN_NPI/OP_PHYSN_NPI/AT_PHYSN_NPI/OT_PHYSN_NPI is not available */
PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_recent_SRVC_LOC1 AS      /* bene_cnt = 9, clm_cnt = 29, nrow = 35 */
  SELECT lower_priority.*
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_OT2 AS higher_priority 
  RIGHT JOIN &SHARED_LIBRARY..C_nvs_kisqali_recent_SRVC_LOC AS lower_priority
  ON higher_priority.xofigo_CLM_ID = lower_priority.xofigo_CLM_ID 
  WHERE higher_priority.xofigo_CLM_ID IS NULL 
  ;
QUIT;

/* Claims when claim_RNDRNG_PHYSN_NPI is implicit rfr npi 
  + Claims when OP_PHYSN_NPI is implicit rfr npi  
  + Claims when AT_PHYSN_NPI is implicit rfr npi
  + Claims when OT_PHYSN_NPI is implicit rfr npi
  + Claims when SRVC_LOC_NPI_NUM is implicit rfr npi */
PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_recent_SRVC_LOC2 AS      /* bene_cnt = 3315, clm_cnt = 10714, nrow = 13201 */ 
  SELECT * 
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_OT2
  UNION 
  SELECT * 
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_SRVC_LOC1
  ;
QUIT;

/* Keep ORG_NPI_NUM if claim_RNDRNG_PHYSN_NPI/OP_PHYSN_NPI/AT_PHYSN_NPI/OT_PHYSN_NPI/SRVC_LOC_NPI_NUM is not available */
PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_recent_ORG1 AS            /* bene_cnt = 1, clm_cnt = 2, nrow = 2 */
  SELECT lower_priority.*
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_SRVC_LOC2 AS higher_priority 
  RIGHT JOIN &SHARED_LIBRARY..C_nvs_kisqali_recent_ORG AS lower_priority
  ON higher_priority.xofigo_CLM_ID = lower_priority.xofigo_CLM_ID 
  WHERE higher_priority.xofigo_CLM_ID IS NULL 
  ;
QUIT;

/* Claims when claim_RNDRNG_PHYSN_NPI is implicit rfr npi 
  + Claims when OP_PHYSN_NPI is implicit rfr npi  
  + Claims when AT_PHYSN_NPI is implicit rfr npi
  + Claims when OT_PHYSN_NPI is implicit rfr npi
  + Claims when SRVC_LOC_NPI_NUM is implicit rfr npi
  + Claims when ORG_NPI_NUM is implicit rfr npi */
PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_recent_ORG2 AS            /* bene_cnt = 3316, clm_cnt = 10716, nrow = 13203 */
  SELECT * 
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_SRVC_LOC2
  UNION 
  SELECT * 
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_ORG1
  ;
QUIT;

/* Keep OUT if CAR is not available, ie we choose implicit rfr npi from Car over Outpatient if both are available on the most recent claim date */
PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_recent_OUTCAR AS          /* bene_cnt = 1982, clm_cnt = 5379, nrow = 7600 */
  SELECT higher_priority.*
  FROM (SELECT * FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_clm WHERE setting = 'Carrier') AS higher_priority 
  LEFT JOIN &SHARED_LIBRARY..C_nvs_kisqali_recent_ORG2 AS lower_priority
  ON higher_priority.xofigo_CLM_ID = lower_priority.xofigo_CLM_ID 
  WHERE lower_priority.xofigo_CLM_ID IS NULL 
  ;
QUIT;

/* Merge CAR + OUT most recent clm with imp_rfr_npi_unattri */
PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_recent_OUTCAR2 AS         /* bene_cnt = 4567, clm_cnt = 16095, nrow = 20803 */
  SELECT * 
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_ORG2
  UNION 
  SELECT * 
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_OUTCAR
  ;
QUIT;



/* If both the referring NPI variable is missing and there is no implicit referral, the rendering NPI will be listed as the referring NPI. */
PROC SQL; 
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_no_imp_npi AS       /* bene_cnt = 1000, clm_cnt = 2643, nrow = 2643 */
  SELECT DISTINCT non_exp_npi_claims.BENE_ID, 
        non_exp_npi_claims.xofigo_CLM_ID,  
        non_exp_npi_claims.CLM_THRU_DT, 
        non_exp_npi_claims.rndrng_npi, 
        non_exp_npi_claims.rndrng_npi AS rfr_npi,
        imp_rfr_npi_claims.*
  FROM &SHARED_LIBRARY..C_nvs_kisqali_recent_OUTCAR2 AS imp_rfr_npi_claims 
  RIGHT JOIN &SHARED_LIBRARY..&stub_prefix._&project_key._exp_rfr_null AS non_exp_npi_claims 
  ON imp_rfr_npi_claims.xofigo_BENE_ID = non_exp_npi_claims.BENE_ID 
    and imp_rfr_npi_claims.xofigo_CLM_ID = non_exp_npi_claims.xofigo_CLM_ID
    and imp_rfr_npi_claims.xofigo_dt = non_exp_npi_claims.CLM_THRU_DT
WHERE imp_rfr_npi_claims.xofigo_CLM_ID IS NULL AND imp_rfr_npi_claims.BENE_ID IS NULL AND imp_rfr_npi_claims.xofigo_dt IS NULL
;
QUIT;


/* convert npi to int */
data &SHARED_LIBRARY..C_nvs_kisqali_no_imp_npi;
  set &SHARED_LIBRARY..C_nvs_kisqali_no_imp_npi;
  rfr_npi_int = input(rfr_npi, 10.);
  drop rfr_npi;
  rename rfr_npi_int = rfr_npi;
run;
data &SHARED_LIBRARY..C_NVS_KISQALI_xofigo_clm;
  set &SHARED_LIBRARY..C_NVS_KISQALI_xofigo_clm;
  exp_rfr_npi_int = input(exp_rfr_npi, 10.);
  drop exp_rfr_npi;
  rename exp_rfr_npi_int = exp_rfr_npi;
run;




/* Use explicit referring npi's, if available, else we will use implicit referring npis for referring npi's */
PROC SQL;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_rfr_npi AS /* bene_cnt = 7333, clm_cnt = 29042, nrow = 32606 */
  SELECT BENE_ID, 
      xofigo_CLM_ID,
      CLM_THRU_DT AS xofigo_dt,
      'Xofigo' AS brand,
      rndrng_npi,
      'exp_rfr_npi' as rfr_npi_source,            /* bene_cnt = 2813, clm_cnt = 10304, nrow = 10304, rndrng_npi_cnt = 829, rfr_npi_cnt = 1904 */
      exp_rfr_npi as rfr_npi
  FROM  &perm_lib..C_NVS_KISQALI_xofigo_clm       /* bene_cnt = 7333, clm_cnt = 29042, nrow = 29042 */
  WHERE exp_rfr_npi IS NOT NULL
  UNION 
  SELECT BENE_ID, 
      xofigo_CLM_ID,
      xofigo_dt,
      'Xofigo' AS brand, 
      rndrng_npi,
      'imp_rfr_npi' as rfr_npi_source,            /* bene_cnt = 4567, clm_cnt = 16095, nrow = 20803, rndrng_npi_cnt = 2232, rfr_npi_cnt = 2765 */
      imp_rfr_npi_unattri as rfr_npi 
  FROM  &perm_lib..C_nvs_kisqali_recent_OUTCAR2       /* bene_cnt = 4567, clm_cnt = 16095, nrow = 20803 */
  UNION 
  SELECT BENE_ID,
      xofigo_CLM_ID,
      CLM_THRU_DT AS xofigo_dt,
      'Xofigo' AS brand,                 
      rndrng_npi,
      'rndrng_npi' as rfr_npi_source, 
      rfr_npi
  FROM &SHARED_LIBRARY..C_nvs_kisqali_no_imp_npi  /* bene_cnt = 1000, clm_cnt = 2643, nrow = 2643, rndrng_npi_cnt = 638, rfr_npi_cnt = 637 */
  ;
QUIT;



PROC SQL ;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_R1 AS 
  SELECT DISTINCT
  year(xofigo_dt) AS year_id,
  &run_last_month. AS mth_end_id,
  brand,
  rfr_npi,
  rndrng_npi,
  COUNT(DISTINCT BENE_ID ) AS pat_cnt,
  min(xofigo_dt ) AS adm_frst_dt format date9.,
  max(xofigo_dt ) AS adm_lst_dt format date9.
  FROM &SHARED_LIBRARY..C_nvs_kisqali_rfr_npi 
  GROUP BY year_id, brand, rfr_npi, rndrng_npi
  ;
QUIT;



/* Flagging 
Only a few type 2 npis in report 1:
 out of  rfr_npi are type 1 and
 out of  rndrng_npi are type 1 */
PROC SQL ;
  CREATE TABLE &SHARED_LIBRARY..C_nvs_kisqali_R1_flag AS 
  SELECT year_id, 
  mth_end_id,
  brand, 
  rfr_npi, 
  rndrng_npi, 
  CASE WHEN pat_cnt <11 AND pat_cnt <> 0 THEN -6 ELSE pat_cnt END AS pat_cnt,
  adm_frst_dt, 
  adm_lst_dt
  FROM &SHARED_LIBRARY..C_nvs_kisqali_R1
  WHERE rfr_npi IS NOT NULL AND rndrng_npi IS NOT NULL;
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