/*Start: Print to log if NOT in debug mode so you can save your log for final--part 1--rest at bottom */

													 
*ALERT: You will not see errors/notes in the log summary (task status)
        if you are NOT in debug mode.  We do want to keep a record of the 
        Ns and steps for easy reference during refreshes, 
        so make sure this section is on (=not starred out)
         for your final, permanent, non-debug run
*NOTE: This log is listed above the program name so we know the name of the program that the log is for;
*NOTE: You do not need to edit this section;
%MACRO print_stuff(printlog=);
 %IF &printlog = 0 %THEN %DO;
 proc printto log="&vrdc_logs./C_log_Step10_Carveout_&project_key._&RIFString._YJ_&logdate..log"; run;
 %END;
%MEND print_stuff;
%print_stuff(printlog=&debug_status)
/*End: Print to log--part 1--rest at bottom*/

/*Start: Setting up option for performance stats that are sent to the log--start times*/
*NOTE: You do not need to edit this section;
options fullstimer msglevel=i ; 
%put Program started at %sysfunc(time(),timeampm.) on %sysfunc(date(),worddate.).;
%let STARTDATE = %sysfunc(date(),worddate.);
%let STARTTIME = %sysfunc(time(),timeampm.);
%let start = %sysfunc(datetime()) ;
/*End: Setting up option for performance stats that are sent to the log*/


*
Program Name: Step10_Carveout_.sas
*When you save this program to your project-specific repo, make sure to rename to your project here and in repo
	Example: Step10_Setup_Libraries_Variables_GE_DaTscan.sas

Description:  
    -Identify Settings & codes of interest for project
    -Output files/tables are one table per setting--no deduping or clean-up done
    	-there is an option to put all settings in 1 file/table

Notes:
    Created from Step15_Carveout.sas 
            in https://github.com/docgraph/VRDC_Client_PFE_IG_Journey_and_Marketview_Milestone2
            on 08apr2020

Edit History:
08apr2020 (susan.hutfless@careset.com): 
    -add descriptions
    -move info from inside macro to outside
    -add automated logging
 16apr2020 (susan.hutfless@careset.com)
 	-add comments to make generic for all projects using GE_DaTscan as an example
 20may2020 (susan.hutfless@careset.com)
 	-make minor changes to catch up to SNY Vaccine test case;
*------------------------------------------------------------------------------------------------------------------------
COPYRIGHT: The DocGraph Journal 2020
LICENSE:    Proprietary Software, not available for sale or licensing
            This code represents trade secrets and commercial information owned by The DocGraph Journal
            considered privileged and confidential information.
*------------------------------------------------------------------------------------------------------------------------;

/*ALERT: You must run Step01_Setup_Libraries_Variables_ before this program*/

/*Start: identifying macros used in this project*
*NOTE: You do not need to edit this section;
            *this includes all stored macros used in this project directly 
            AND macros nested within macros--it is IMPORTANT to update this list
            so that if someone else tries to run the program and it doesn't work
            they can troubleshoot to see if the problem is a missing or altered macro from the includes folder;
	run_monthly.macro.sas;
	claim_table_from_name_monthly.sas;
	cline_table_from_name_monthly.sas;
	flush.sas;
	runquit.sas;
	npi_fields_attribution.sas;
	varexist.sas;
	_log_chk.sas;
/*End: identifying macros used in this project*/

**********************DO NOT EDIT STARTING HERE!!!!!!!!!!********************;
    ******IF YOU WANT TO/ NEED TO EDIT THIS TEMPLATE, MESSAGE #TECH ON SLACK********     ;
    *there are edits that CAN be made below this section FOR how the files generated are saved....;
*#########################################################################################################################;
%macro Step10_Carveout(current_year=,current_month=,rif_library=,last_year=,last_month=,
                        end_rif_string=,is_debug=,params=);
%put Macro started at %sysfunc(time(),timeampm.) on %sysfunc(date(),worddate.).;
*--------------------------------------------------------------------------------;
%local obs_limit data_limit merge_limit MY_LIBRARY SOURCE_STUB i this_rif;
*--------------------------------------------------------------------------------;
*--------------------------------------------------------------------------------;
%let settings_length = %sysfunc(countw(&SETTINGS_NAME)); *this counts the number of settings that we are looking at 
                                based on number of items in settings_name specified;

*--------------------------------------------------------------------------------;
*--------------------------------------------------------------------------------;
%if &is_debug. =1 %then %do; 
    %let obs_limit = INOBS=&n_debug;
    %let data_limit = (obs=&n_debug);
    %let merge_limit = obs=&n_debug;
%end;
*--------------------------------------------------------------------------------;


***************************************************************************************************************************;
        * setting loop;
        * this loops through each of the settings;
        %DO setting_counter=1 %to &settings_length;
           
            * pull out the claim file (settings_claim), line/revenue file (settings_cline), and setting abbreviation (settings_name) of each of the settings ;
            %local this_claim this_cline this_name claim_table cline_table;
            *this is how you label CAR / OUT / etc for labeling in the output for the table names
                --it must be done this way because of the do-loop;
            %let this_setting_name = %scan(&SETTINGS_NAME, &setting_counter,' ');   
            
            * parse the claim and line/revenue table from the monthly file 
                --creates a temp file on the permanent library for the current setting/year/month;
            %let claim_table = &rif_library..%claim_table_from_name_monthly(&this_setting_name.,&current_month.);
            %let cline_table = &rif_library..%cline_table_from_name_monthly(&this_setting_name.,&current_month.);


            * this checks what settings and year/month we are at ;
            %flush(Current Setting: &this_setting_name. &current_year. &current_month.);

    
           * rename Rendering NPI and SPECIALTY CODE if setting is not CAR or DME
                --these variables are the same in the claim and line files and we want to know 
                    which source they came from so we prefix them with claim_ or rev_ ;                         
            %local rename_claim_npi rename_cline_npi rename_claim_type rename_cline_type;
            %let rename_claim_npi = ;
            %let rename_cline_npi = ;
            %let rename_claim_type = ;
            %let rename_cline_type = ;
            %if &this_setting_name ^= CAR and &this_setting_name ^= DME %then %do;
                %let rename_claim_npi = rename = (RNDRNG_PHYSN_NPI=claim_RNDRNG_PHYSN_NPI RNDRNG_PHYSN_SPCLTY_CD=claim_RNDRNG_PHYSN_SPCLTY_CD);
                %let rename_cline_npi = rename = (RNDRNG_PHYSN_NPI=rev_RNDRNG_PHYSN_NPI RNDRNG_PHYSN_SPCLTY_CD=rev_RNDRNG_PHYSN_SPCLTY_CD);
                %let rename_claim_type = rename = (NCH_CLM_TYPE_CD=claim_NCH_CLM_TYPE_CD );
                %let rename_cline_type = rename = (NCH_CLM_TYPE_CD=rev_NCH_CLM_TYPE_CD   );
            %end;
            * rename nch_clm_type_cd if setting is CAR or DME
                --these variables are the same in the claim and line files and we want to know 
                    which source they came from so we prefix them with claim_ or rev_ ; 
            %if &this_setting_name = CAR or &this_setting_name = DME %then %do;
                %let rename_claim_type = rename = (NCH_CLM_TYPE_CD=claim_NCH_CLM_TYPE_CD );
                %let rename_cline_type = rename = (NCH_CLM_TYPE_CD=rev_NCH_CLM_TYPE_CD   );
            %end;
          
            * This macro variable returns the right side of the equation to calculate a prioritized npi from existing NPI fields
                --this creates a list of NPI variables available in the current table being processed 
                    which will be used to keep only 1 npi--the first non-missing (non-null) npi in this list;
            * we create a list of all possible npi to check in each table we pass, both the claim and line/revenue files ;
            *npis defined in the set-up file;
            %local npi_list_count j this_npi;   *these are used in the called macro npi_fields_attribution;     
            %let attr_npilist= %npi_fields_attribution(claim_table=&claim_table.,
                        cline_table=&cline_table.,
                        npi_list=&npi_list
                        );
            %let attr_npi_hcp= %npi_fields_attribution(claim_table=&claim_table.,
                        cline_table=&cline_table.,
                        npi_list=&hcp_npi_list
                        );
            %let attr_npi_hco= %npi_fields_attribution(claim_table=&claim_table.,
                        cline_table=&cline_table.,
                        npi_list=&hco_npi_list
                        );

            * Create the carveout (=identify the monthly files);
            DATA &perm_lib..X_&project_key._CARV_&this_setting_name._&current_year.&current_month.;
                length ORDRNG_PHYSN_NPI $10;
                length setting      $3      ;
                length CLAIM_KEY    $30     ;
                length npi_hcp npi_hco npi_attr    $500 ;
            length ICD_GROUP1 has_hcpcs has_ndc 4    ;

                MERGE
                    &claim_table. (&merge_limit. &rename_claim_npi. &rename_claim_type.) 
                    &cline_table. (&merge_limit. &rename_cline_npi. &rename_cline_type.) 
                    ;
                BY BENE_ID CLM_ID clm_thru_dt;  *clm_thru_dt is optional--including decreases overwrite warnings in log;                                                                                
                                                                                        
                setting  = "&this_setting_name.";
                /*npi_hcp  = COALESCEC(&attr_npi_hcp);
                npi_hco  = COALESCEC(&attr_npi_hco);
                npi_attr = COALESCEC(&attr_npilist); 
            */
	    	if setting="OUT" then npi_hcp=COALESCEC(rev_RNDRNG_PHYSN_NPI, ORDRNG_PHYSN_NPI, claim_RNDRNG_PHYSN_NPI,OP_PHYSN_NPI, AT_PHYSN_NPI, OT_PHYSN_NPI, SRVC_LOC_NPI_NUM, ORG_NPI_NUM);
	    	if setting="CAR" then npi_hcp=PRF_PHYSN_NPI;
		    if setting="DME" then npi_hcp=RFR_PHYSN_NPI;
                * Generate an event key which is same patient & same day;
                claim_key =  CATS(PUT(CLM_THRU_DT, yymmddn8.),'|',PUT(BENE_ID,12.));
                label claim_key = "CareSet generated key that combines claim through date and bene_id";
                
                * Generate a clm_thru_dt for the setting;
                clm_thru_dt_&this_setting_name = clm_thru_dt;

                * Identify records with ICD inclusions ;
                ARRAY _internal_icds (*) ICD_DGNS_CD:;
                DO _i = 1 to dim(_internal_icds);
            
                    IF substr(_internal_icds(_i),1,&incl_ICD_dx_GROUP1_substr) IN (&incl_ICD_dx_GROUP1) THEN icd_group1 = 1; 
                    IF substr(_internal_icds(_i),1,&incl_ICD_dx_GROUP2_substr) IN (&incl_ICD_dx_GROUP2) THEN icd_group2 = 1; 
                    IF substr(_internal_icds(_i),1,&incl_ICD_dx_GROUP3_substr) IN (&incl_ICD_dx_GROUP3) THEN icd_group3 = 1; 
                    IF substr(_internal_icds(_i),1,&incl_ICD_dx_GROUP4_substr) IN (&incl_ICD_dx_GROUP4) THEN icd_group4 = 1;                        
                    *identify if record should be kept based on ICD;
                    IF icd_group1=1 or icd_group2=1 or icd_group3=1 or icd_group4=1 
                        THEN keep_icd=1; 
                    label keep_icd="record met ICD inclusion criteria";
                    label icd_group1 = "&incl_ICD_dx_GROUP1_label";
                    label icd_group2 = "&incl_ICD_dx_GROUP2_label";
                    label icd_group3 = "&incl_ICD_dx_GROUP3_label";
                    label icd_group4 = "&incl_ICD_dx_GROUP4_label";
                   END; * End ICD Array;
                                                        
                * Identify records with HCPCS & APC/revenue center inclusion;
                IF HCPCS_CD in (&incl_hcpcs.) THEN has_hcpcs = 1;
                
                    *identify if record should be kept based on hcpcs or rev_cntr;
                    if has_hcpcs=1 then keep_hcpcs=1; label keep_hcpcs="record met HCPCS inclusion criteria in step10";

                * Identify records with NDC of interest, but only for specific settings;               
                        *IMPORTANT: this is ndc from claims NOT from the rx file;
                %IF (      &this_setting_name. = OUT 
                        or &this_setting_name. = INP 
                        or &this_setting_name. = HSP 
                        or &this_setting_name. = HHA 
                        or &this_setting_name. = SNF    ) 
                %THEN %DO;
                    IF REV_CNTR_IDE_NDC_UPC_NUM IN (&incl_ndc.) THEN has_ndc=1  ;
                    IF REV_CNTR in (&incl_rev_cntr)             THEN has_rev_cntr = 1   ;
                %END;
                %IF (   &this_setting_name. = DME 
                        or &this_setting_name. = CAR    )
                %THEN %DO;
                    IF LINE_NDC_CD in (&incl_ndc.) THEN has_ndc=1;
                    has_rev_cntr = .    ;
                %END;
                if has_ndc=1 then keep_ndc=1; label keep_ndc="record met NDC inclusion criteria in step10";
                if has_rev_cntr=1 then keep_rev_cntr=1; label keep_rev_cntr="record met APC/revenue center inclusion criteria in steo10";

                * Only keep records with ICD, HCPCS or NDC codes of interest;
                if keep_icd=1 OR keep_hcpcs=1 OR keep_rev_cntr=1 OR keep_ndc=1
                then keep_this_record=1;
                if keep_this_record ne 1 then delete;
                format age_at_keep 5.2; /*forces age to have 2 decimal places*/
                age_at_keep = (clm_thru_dt - dob_dt)/365.25; label age_at_keep='age when met step10 carve out criteria';
            %runquit; 
      
        %END; * end setting loop ;
***************************************************************************************************************************;

*#########################################################################################################################;
%mend; * end of Step10_Carveout macro; 
*#########################################################################################################################;


%run_monthly(
                last_year=&run_last_year,
                last_month=&run_last_month,
                rolling_month=&run_rolling_month,
                callback=Step10_Carveout,           /*you need above to run this*/
                is_debug=&debug_status,
                params=
                );

**********************STOP: DO NOT EDIT STARTING HERE!!!!!!!!!!********************;
*******You can edit below if you want to--otherwise the settings that your project does not use (as identified in step00) will save as empty files;



*save eligible records as permanent;
*do this by setting so can do a basic check of each setting type in step11;
*you only need to keep the file types that your project uses--the rest will be empty files/tables;

*these checks rely on formats--need access to DG/CS format library;							*************SUSIE IS STILL BUILDING THIS!!!!! KEEP FORMATS STARRED OUT UNTIL THEN******;
data &perm_lib..&stub_prefix._&project_key._CAR_&RIFString;   
set &perm_lib..X_&project_key._CARV_CAR_:  (drop=setting);
*delete denied claims;
/*if CARR_CLM_PMT_DNL_CD in('0','D') then delete;*/
setting='Carrier   ';
*assign year and quarter;
year=year(clm_thru_dt);  
quarter=qtr(clm_thru_dt);
month=month(clm_thru_dt);  
*make age categories;
if 65<=age_at_keep<70 then patient_age_category='65-69';
if 70<=age_at_keep<75 then patient_age_category='70-74';
if 75<=age_at_keep<80 then patient_age_category='75-79';
if 80<=age_at_keep<85 then patient_age_category='80-84';
if 85<=age_at_keep    then patient_age_category='85+  ';
/*keep patients 65 and above--project specific exclusion*/
*if age_at_keep<65 then delete; 
*format 
icd_dgns_cd1 line_icd_dgns_cd prncpal_dgns_cd $dgns.
hcpcs_cd $hcpcs.        
nch_clm_type_cd $clm_type_cd.
;
run;

data &perm_lib..&stub_prefix._&project_key._OUT_&RIFString;      
/*length ORDRNG_PHYSN_NPI $10; */                                            
set &perm_lib..X_&project_key._CARV_OUT_:   (drop=setting) ;
*delete denied claims;
/*ansi1=REV_CNTR_1ST_ANSI_CD; ansi2=REV_CNTR_2nd_ANSI_CD; ansi3=REV_CNTR_3rd_ANSI_CD; ansi4=REV_CNTR_4th_ANSI_CD;
array ansi(4) ansi1-ansi4;
do i=1 to 4;
    if substr(ansi(i),3,2) in('19','20','21','25','31','33','34','39','55','56','62','A1','A8') then delete;
    if substr(ansi(i),2,3) in('129','135','138','B14','B18','B23') then delete;
end;
if CLM_MDCR_NON_PMT_RSN_CD ne ' ' then delete;*delete those that Medicare did not pay for;*/
*if NCH_PRMRY_PYR_CD not in(' ', 'M', 'N') then delete; *optional: delete those where Medicare was not primary payer;

setting='Outpatient';
*assign year and quarter;
year=year(clm_thru_dt);  
quarter=qtr(clm_thru_dt);
month=month(clm_thru_dt); 
*make age categories;
if 65<=age_at_keep<70 then patient_age_category='65-69';
if 70<=age_at_keep<75 then patient_age_category='70-74';
if 75<=age_at_keep<80 then patient_age_category='75-79';
if 80<=age_at_keep<85 then patient_age_category='80-84';
if 85<=age_at_keep    then patient_age_category='85+  '; 
/*keep patients 65 and above--project specific exclusion*/
*if age_at_keep<65 then delete; 
*format 
icd_dgns_cd1 prncpal_dgns_cd $dgns.
hcpcs_cd $hcpcs.        
nch_clm_type_cd $clm_type_cd.
ICD_PRCDR_CD1 $prcdr.
; 
run;
* data &perm_lib..C_&project_name._INP; 
* set &perm_lib..X_&project_name._INP:    ;
* run;
* data &perm_lib..&stub_prefix._&project_key._DME_&RIFString;   
* set &perm_lib..X_&project_key._CARV_DME:    (drop=setting);
* setting='DME       ';
* year=year(clm_thru_dt);  
* quarter=qtr(clm_thru_dt);
* month=month(clm_thru_dt); 
* *make age categories;
* if 65<=age_at_keep<70 then patient_age_category='65-69';
* if 70<=age_at_keep<75 then patient_age_category='70-74';
* if 75<=age_at_keep<80 then patient_age_category='75-79';
* if 80<=age_at_keep<85 then patient_age_category='80-84';
* if 85<=age_at_keep    then patient_age_category='85+  ';  
* run;
* data &perm_lib..C_&project_name._SNF;   
* set &perm_lib..X_&project_name._SNF:    ;
* run;
* data &perm_lib..C_&project_name._HSP;   
* set &perm_lib..X_&project_name._HSP:    ;
* run;
* data &perm_lib..C_&project_name._HHA;   
* set &perm_lib..X_&project_name._HHA:    ;
* run;


/* rev_RNDRNG_PHYSN_NPI, claim_RNDRNG_PHYSN_NPI and OP_PHYSN_NPI in CAR/DME are numeric but in OUT are char
So before the merging step, will need to convert them to the same type */
*data &perm_lib..C_NVS_KISQALI_CAR_MT21R41_5_char;   
*set &perm_lib..C_NVS_KISQALI_CAR_MT21R41_5;
data &perm_lib..C_NVS_KISQALI_CAR_MT&run_last_year.R&run_rolling_month._&run_last_month._char;   
set &perm_lib..C_NVS_KISQALI_CAR_MT&run_last_year.R&run_rolling_month._&run_last_month.;
rev_RNDRNG_PHYSN_NPI_char = put(rev_RNDRNG_PHYSN_NPI, 10.);
claim_RNDRNG_PHYSN_NPI_char = put(claim_RNDRNG_PHYSN_NPI, 10.);
OP_PHYSN_NPI_char = put(OP_PHYSN_NPI, 10.);
ORDRNG_PHYSN_NPI_char = put(ORDRNG_PHYSN_NPI, 10.);
SRVC_LOC_NPI_NUM_char = put(SRVC_LOC_NPI_NUM, 10.);
AT_PHYSN_NPI_char = put(AT_PHYSN_NPI, 10.);
OT_PHYSN_NPI_char = put(OT_PHYSN_NPI, 10.);
drop rev_RNDRNG_PHYSN_NPI claim_RNDRNG_PHYSN_NPI OP_PHYSN_NPI ORDRNG_PHYSN_NPI SRVC_LOC_NPI_NUM AT_PHYSN_NPI OT_PHYSN_NPI;
rename rev_RNDRNG_PHYSN_NPI_char = rev_RNDRNG_PHYSN_NPI
        claim_RNDRNG_PHYSN_NPI_char = claim_RNDRNG_PHYSN_NPI 
        OP_PHYSN_NPI_char = OP_PHYSN_NPI
        ORDRNG_PHYSN_NPI_char = ORDRNG_PHYSN_NPI
        SRVC_LOC_NPI_NUM_char = SRVC_LOC_NPI_NUM
        AT_PHYSN_NPI_char = AT_PHYSN_NPI
        OT_PHYSN_NPI_char = OT_PHYSN_NPI
;
run;


/*You can move this to another step*/
data &perm_lib..&stub_prefix._&project_key._&RIFString. (keep = BENE_ID brand CLM_THRU_DT rndrng_npi exp_rfr_npi xofigo: rev_RNDRNG_PHYSN_NPI claim_RNDRNG_PHYSN_NPI OP_PHYSN_NPI ORDRNG_PHYSN_NPI SRVC_LOC_NPI_NUM AT_PHYSN_NPI OT_PHYSN_NPI);   
set &perm_lib..&stub_prefix._&project_key._CAR_&RIFString._char &perm_lib..&stub_prefix._&project_key._OUT_&RIFString. /*perm_lib..&stub_prefix._&project_key._DME_&RIFString*/ ;
rndrng_npi = npi_hcp; 
/*if rndrng_npi = '' & AT_PHYSN_NPI ne '' then do; rndrng_npi = AT_PHYSN_NPI; end;*/
if rndrng_npi ne RFR_PHYSN_NPI then do; exp_rfr_npi = RFR_PHYSN_NPI; end;
brand = 'Xofigo';
xofigo_dt = put(CLM_THRU_DT, DATE9.);
xofigo_CLM_ID = CLM_ID;
xofigo_HCPCS = HCPCS_CD;
xofigo_NDC_OUT = REV_CNTR_IDE_NDC_UPC_NUM;
xofigo_NDC_CAR = LINE_NDC_CD;
run;

/* Dedup and sort by BENE_ID xofigo_dt rndrng_npi */
PROC SORT DATA = &perm_lib..&stub_prefix._&project_key._&RIFString nodupkey; BY BENE_ID xofigo_dt rndrng_npi; RUN;

/* QA: Explicit Referring NP converage, how many of them are missing */
PROC SQL; 
CREATE TABLE YJI989SL.NVS_exp_npi_QA AS 
SELECT *
FROM  &perm_lib..&stub_prefix._&project_key._&RIFString 
WHERE exp_rfr_npi IS NULL;
QUIT;

PROC SQL; 
CREATE TABLE YJI989SL.NVS_rndrng_QA AS 
SELECT *
FROM  &perm_lib..&stub_prefix._&project_key._&RIFString 
WHERE rndrng_npi IS NULL;
QUIT;


    
/*Start: if you want to save 1 file with ALL of the settings stacked (in addition to each file individually,
do this & then delete the files above*
data    &permanent;
set     &perm_lib..X_&project_name._:   ; *alternatively could set car out....;
run;
/*End: if you want to save 1 file with ALL of the settings stacked (in addition to each file individually,
do this & then delete the files above*/


*Start: delete temp datasets if NOT in debug;
*NOTE: You do not need to edit this section -- you might want to * out the proc datasets until you are 100% sure that program worked;
%MACRO print_stuff(printlog=);
 %IF &printlog = 0 %THEN %DO;
        proc datasets lib=&perm_lib nolist;
         delete X_&project_key: ;
        run;
        quit;
 %END;
%MEND print_stuff;
%print_stuff(printlog=&debug_status)
/*End: delete temp datasets if NOT in debug*/

/*Start: Setting up option for performance stats that are sent to the log--end times*/
*NOTE: You do not need to edit this section;
%let ENDDATE = %sysfunc(date(),worddate.);
%let ENDTIME = %sysfunc(time(),timeampm.);
%let end = %sysfunc(datetime()) ;
%let duration = %sysevalf((&end. - &start.)/60, ceil);
%flush("DURATION: &duration. mins. || STARTED: &STARTDATE. &STARTTIME. || FINISHED: &ENDDATE. &ENDTIME.");
/*End: Setting up option for performance stats that are sent to the log--end times*/



/*Start: Print to log--part 2 */
*NOTE: You do not need to edit this section;
%MACRO print_stuff(printlog=);
 %IF &printlog = 0 %THEN %DO;
    proc printto;
    run;
    %_log_chk (log=&vrdc_logs./C_log_Step10_Carveout_&project_key._&RIFString._YJ_&logdate..log); 
    *The log checker checks your log for common mistakes/errors/warnings
        --Make sure to review errors counts in the LOG of the log checker & the output data for errors that you may have missed;
 %END;
%MEND print_stuff;
%print_stuff(printlog=&debug_status)
/*End: Print to log--part 2 */             


   
