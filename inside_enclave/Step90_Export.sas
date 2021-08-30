*------------------------------------------------------------------------------------------------------------------------

Program Name: Step90_Export.sas

Description:  
Exports all the final files to CSV files.

Starting Author: REPLACEME_Program_Author

TemplateDescription: Exports all the final files to CSV files.
*------------------------------------------------------------------------------------------------------------------------
COPYRIGHT: The DocGraph Journal 2019
LICENSE:    Proprietary Software, not available for sale or licensing
            This code represents trade secrets and commercial information owned by The DocGraph Journal
            considered privileged and confidential information.
*------------------------------------------------------------------------------------------------------------------------;


%include "&myfiles_root./dua_027654/includes/includes.sas";


*#########################################################################################################################;
%macro Step90_Export(rif_list);
%put Macro started at %sysfunc(time(),timeampm.) on %sysfunc(date(),worddate.).;
*--------------------------------------------------------------------------------;
%local is_debug obs_limit MY_LIBRARY PROGRAM_STUB SOURCE_STUB i this_rif;
*--------------------------------------------------------------------------------;
*--------------------------------------------------------------------------------;
*
* Configurable Values
* Note: define all variables as local
*
*--------------------------------------------------------------------------------;


%let is_debug = 0;
%let SOURCE_STUB = ; *Prefix of the source table;
%let FILE_DIR = %project_key; * Folder where exported data will be saved (project key is from Step00); 
%let FILE_STUB = %project_key.%RIFString.%github_version_tag.; *File name stub, all variables from Step00;

* We use this to loop through each of the settings so its easier to modify codes at the same time vs copying and pasting ;
%local SETTINGS_NAME SETTINGS_CLAIM SETTINGS_CLINE settings_length setting_counter;
*To use this section, remove all mention of the settings that you do not need ;
*This is very order sensitive, so you need to be sure that the order of the settings for the next three variables remains the same;
%let SETTINGS_NAME = CAR DME OUT INP SNF HSP HHA;
%let SETTINGS_CLAIM = &CARRIER_CLAIM_STUB.  &DME_CLAIM_STUB. &INSTOUT_CLAIM_STUB. &INPATIENT_CLAIM_STUB. &SNF_CLAIM_STUB. &HSP_CLAIM_STUB. &HHA_CLAIM_STUB.;
%let SETTINGS_CLINE = &CARRIER_LINE_STUB. &DME_LINE_STUB. &INSTOUT_LINE_STUB. &INPATIENT_LINE_STUB. &SNF_LINE_STUB. &HSP_LINE_STUB. &HHA_LINE_STUB.;
%let settings_length = %sysfunc(countw(&SETTINGS_NAME));

*Create a macro variable with todays date in MySQL format;
data _null_;
	call symputx('todays_mysql_date',put(date(),yymmdd10.), 'g');
run;
*now &todays_mysql_date will resolve as expected;

*--------------------------------------------------------------------------------;
*--------------------------------------------------------------------------------;
* This allows us to define an observation limit when in DEBUG mode;
%let obs_limit =; 
%let data_limit =;
%let merge_limit = ;
%if &is_debug. =1 %then %do; 
    %let obs_limit = INOBS=1000;
    %let data_limit = (obs=1000);
    %let merge_limit = obs=10000;
%end;
*--------------------------------------------------------------------------------;


***************************************************************************************************************************;

	* proc export data=&SHARED_LIBRARY..C_nvs_kisqali_R1_flag 
	* 	OUTFILE= "&myfiles_root./Amy/nvs_kisqali_report1_MT&run_last_year_p.R&run_rolling_month_p._&run_last_month_p..v0.1.1.csv"
	* 	replace;
	* 	PUTNAMES=YES; 
	* run;

	proc export data=&SHARED_LIBRARY..C_nvs_kisqali_R1_merged_flag1 
		OUTFILE= "&myfiles_root./Amy/nvs_kisqali_report1_MT&run_last_year.R&run_rolling_month._&run_last_month..v0.1.3.csv"
		replace;
		PUTNAMES=YES; 
	run;

***************************************************************************************************************************;



*#########################################################################################################################;
%mend; * end main program macro;
*#########################################################################################################################;

%Step90_Export();