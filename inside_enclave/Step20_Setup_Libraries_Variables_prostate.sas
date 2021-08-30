*------------------------------------------------------------------------------------------------------------------------

Program Name: Step01_Setup_Libraries_Variables_.sas
*When you save this program to your project-specific repo, make sure to rename to your project here and in repo
	Example: Step01_Setup_Libraries_Variables_GE_DaTscan.sas

TemplateDescription: This program sets up the SAS environment for all subsequent steps

Description:  
	-You should use this program for ALL projects.
	-This file sets up the names of
		-libraries (folders)
		-macros
		-time periods (last year, rolling month)
		-codes (hcpcs, icd)
		-logs
	that are used by subsequent programs for your project.
Why is this file helpful?  
	-If you want/need to change a HCPCS/ICD/etc code, you can change it here in
		one place instead of having to search through all of your steps.
	-You can easily switch the file location from work./your local folder/the shared DUA folder
		depending on the stage of project development/project needs

************************IMPORTANT******************************************
You should read 100% of the text in this file.  If you have questions, make sure that you have read 100% of the text first.

If you think this template needs changes, send a message to the #tech slack channel and we'll set up a process
to review the suggested changes and make those the default for all projects.

Only make edits to the right of the equal signs below. If you are new to %let,
here is a good resource: https://www.lexjansen.com/wuss/2009/tut/TUT-Li.pdf

   FOLLOW THESE STEPS WHEN USING PARALLEL PROCESSING:
    1. Make sure this folder exists in the server inside SAS EG, if not create it: `Servers/sasCCW/files/setup` 
        Ensure that setup is all small letters.
    2. Save this Step01 document in the setup folder. Ensure that the filename includes the project name, 
        for example: Step01_Setup_libraries_Variables_GE_DaTscan_MV.sas
    3. Inside the SAS program that you will be running in parallel, add this command as first line (taking 
        note of the project-specific filename):
        %include "&myfiles_root./setup/Step01_Setup_libraries_Variables_GE_DaTscan_MV.sas"; 

***************************************************************************

Edit History:
10apr2020 by susan.hutfless@careset.com (created)
			in https://github.com/docgraph/VRDC_GE_MarketView_DaTscan_SPECT_Research
			Spring 2020
14apr2020 by susan.hutfless@careset.com: Edits with more instructions to modify 
			based on GE_DaTscan as an example
20may2020 by susan.hutfless@careset.com: Edits to match changes for SNY Vaccine
06jul2020 by faith@careset.com: 
			- Move running of includes.sas to the top.
			- Reordered where things are defined/declared. In general, macro vars that change from project to project
				are moved at the top.
			- The following macro variables are now automatically filled versus manually populated by the SAS programmer:
				= myInitials (line 239)
				= myVRDCname  (line 238)
				= settings_claim (lines 298-338)
				= settings_cline (lines 298-338)
				= These are additionally dependent on the value of debug_status
					= program_stub (line 280)
					= perm_lib (lines 267 and 275)
						
*------------------------------------------------------------------------------------------------------------------------
COPYRIGHT: The DocGraph Journal 2020
LICENSE:    Proprietary Software, not available for sale or licensing
            This code represents trade secrets and commercial information owned by The DocGraph Journal
            considered privileged and confidential information.
*------------------------------------------------------------------------------------------------------------------------;
*========================================================================================================================;
* Call all CareSet Macros stored in VRDC (DO NOT EDIT);
	%include "&myfiles_root./dua_027654/includes/includes.sas"; 
*========================================================================================================================;

*make sure that step00 is run;
%put length-----Faith will do this;
%runquit;
*========================================================================================================================;
* Start: Setup mac vars for debug status, dataset names, settings and time period.
* 
*   [debug_status] - Do you want debug on or off? 1=YES, 0=no which will run on all observations 
*   [stub_prefix]  - Edit this to be C if you are working on client work and D if working on a default;
*       the value depends on the type of project. "C" for client, "D" for default. 
		stub_prefix X is set based on the debug status in the DO NOT EDIT section
*   [n_debug] - pick number of observations that you want for debug (=run to test if program works instead of full run);
*   [run_last_year] - The two-digit year of the latest year in the observation period. - now set in previous step (Step00)
*   [run_last_month] - The number representing the latest month in the observation period. - now set in previous step (Step00)
*   [run_rolling_month] - The total number of months in the observation period. - now set in previous step (Step00)
*   [settings_name] - The 3-char representation of the FFS settings. This can contain multiple values separated 
        by spaces. CAR for Carrier, OUT for Outpatient, DME for DME, INP for Inpatient, HHA for Home Health Agency,
        HSP for Hospice, SNF for Skilled Nursing Facility. 
*   [RIFString] - The filename suffix containing the RIF Type, the last year of the run, the number of months in 
        the run (rolling), and the last month of the run - now set in previous step (Step00)
*   The %global statement allows the macro vars to be used across programs and other macros in the same EG session;
*;
    %global debug_status stub_prefix n_debug;
    %global settings_name;

    %let debug_status   = 0; /*0*/
    %let stub_prefix    = C; 

    %let n_debug        = 100000; 

    %let settings_name  = CAR OUT;

*   print to log for QA check;
    Data _null_;
        PUT "PARAMETERS for project, debug, and time period:"   /  
            "debug_status=&debug_status | n_debug=&n_debug "  /
            "stub_prefix=&stub_prefix | project_key=&project_key " / 
            "run_last_year=&run_last_year_p | run_last_month=&run_last_month_p | run_rolling_month=&run_rolling_month_p"/ 
            "settings_name=&settings_name";
    %runquit;
* End: Setup project parameters    
*========================================================================================================================;


*========================================================================================================================;
*Start: section to read in project specific codes;
*You have 2 options for identifying codes for the macro--enter in list here (option 1) or call from file (option 2);
	
	*------------------------------------------------------------------------------------------------------------------------;
	*Start Option 1;
	*Susie: you need to add drg, icd procedure, hcpcs modifiers here & in step10;
		*Comment out the lines in this section if you will not use them, or 
			you could also delete this option from your project-specific code if you are sure the project won't use;
        * Enter '0' if this grouping is not needed;
		%let incl_hcpcs 		= '0'; 
		%let incl_rev_cntr		= '0'				;	*enter '0' if this grouping is not needed;
		%let incl_ndc			= '0'				; 	
		%let incl_ICD_dx_GROUP1	= 'C61',	'Z8546',	'R9721',	'Z125',	'Z192'				;	*Malignant prostate ;
		%let incl_ICD_dx_GROUP2	= 'C770',	'C771',	'C772',	'C773',	'C774',	'C775',	'C778',	'C779',	'C7800',	'C7801',	'C7802',	'C781',	
		'C782',	'C7830',	'C7839',	'C784',	'C785',	'C786',	'C787',	'C7880',	'C7889',	'C7900',	'C7901',	'C7902',	'C7910',	
		'C7911',	'C7919',	'C792',	'C7931',	'C7932',	'C7940',	'C7949',	'C7951',	'C7952',	'C7960',	'C7961',	'C7962',	
		'C7970',	'C7971',	'C7972',	'C7982',	'C7989',	'C799'			;
		%let incl_ICD_dx_GROUP3	= '0'				;	
		%let incl_ICD_dx_GROUP4	= '0'				;

        * Declare the number of characters to search in the SUBSTR() function. This will populate the 2nd argument in the 
          SUBSTR() function; 
        %let incl_ICD_dx_GROUP1_substr	= 7;
        %let incl_ICD_dx_GROUP2_substr	= 7;
        %let incl_ICD_dx_GROUP3_substr	= 7;
        %let incl_ICD_dx_GROUP4_substr	= 7;
        
		%global incl_hcpcs 	incl_rev_cntr 	incl_ndc 
				incl_ICD_dx_GROUP1 incl_ICD_dx_GROUP2 incl_ICD_dx_GROUP3 incl_ICD_dx_GROUP4	
                incl_ICD_dx_GROUP1_substr incl_ICD_dx_GROUP2_substr incl_ICD_dx_GROUP3_substr incl_ICD_dx_GROUP4_substr;
	*IF you have more than 4 icd dx groups contact the #tech channel on slack about editing the Step10_Carveout macro together;		
	*If you have ICD procedure groups or another ocding group NOT listed above, contact the #tech channel on slack;

	* Print to log for QA check;
    Data _null_;
        PUT "Printing project-specific codes:"/
            "incl_hcpcs=&incl_hcpcs"/
			"incl_rev_cntr=&incl_rev_cntr"/
			"incl_ndc=&incl_ndc"/
			"incl_ICD_dx_GROUP1=&incl_ICD_dx_GROUP1"/
			"incl_ICD_dx_GROUP2=&incl_ICD_dx_GROUP2"/
			"incl_ICD_dx_GROUP3=&incl_ICD_dx_GROUP3"/
			"incl_ICD_dx_GROUP4=&incl_ICD_dx_GROUP4"
    ;
    %runquit;

	/*End Option 1*/
	*------------------------------------------------------------------------------------------------------------------------;


	*------------------------------------------------------------------------------------------------------------------------;
	*Start Option 2;
		* This Option is for processing codes using an input table or CSV file.
			*** TO BE UPDATED BY FAITH ****
			
	*End Option 2;
	*------------------------------------------------------------------------------------------------------------------------;
	
*End: section to read in project specific codes;
*========================================================================================================================;


*========================================================================================================================;
*Start labeling of ICD groups from option 1 or option 2 above
	*if you don't have any icd codes for this project, you can leave this as is;
%let incl_ICD_dx_GROUP1_label = Malignant prostate ;					
%let incl_ICD_dx_GROUP2_label = Metastatic identification;
%let incl_ICD_dx_GROUP3_label = EDIT THIS TO DESCRIBE CONDITION REPRESENTED BY GROUP 3;	
%let incl_ICD_dx_GROUP4_label = EDIT THIS TO DESCRIBE CONDITION REPRESENTED BY GROUP 4;
/*End labeling of ICD groups*/
*========================================================================================================================;


*========================================================================================================================;
/*Start Labeling of NPIs for the project*/
	*Some projects have a specific order of NPIs---this list should match the data spec--star out NPIs NOT of interest;
	*HCP = health care provider/physician;
	*HCO = health care organization/facility;
	*PRVDR_NUM (same as CCN) and all variables with UPIN are not included in our eligible NPI lists;
		*PRVDR_NUM is the CMS hospital id -- primary facility indicator for inpatient & outpatient files;
*Susie: make sure that this matches the data spec template & includes all possible npis from resdac data dictionary & proc contents;
	%let hcp_npi_list = rev_RNDRNG_PHYSN_NPI	claim_RNDRNG_PHYSN_NPI  OP_PHYSN_NPI  	PRF_PHYSN_NPI	          		;
	%let hco_npi_list = SRVC_LOC_NPI_NUM		ORG_NPI_NUM 		CARR_CLM_SOS_NPI_NUM	CARR_CLM_BLG_NPI_NUM	 	
						CPO_ORG_NPI_NUM	PRVDR_NPI		;
	%let npi_list     = &hcp_npi_list &hco_npi_list	;
	%global hcp_npi_list hco_npi_list npi_list 		;


	* Print to log for QA check;
    Data _null_;
        PUT "Labeling NPIs for the project:"/
            "hcp_npi_list=&hcp_npi_list"/
			"hco_npi_list=&hco_npi_list"/
			"npi_list=&npi_list"
    ;
    %runquit;

/*End Labeling of NPIs for the project*/
*========================================================================================================================;


*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!;
*           STOP!     DO NOT EDIT BEYOND THIS POINT. IF YOU NEED TO EDIT, CONTACT THE TECH TEAM.
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!;


*========================================================================================================================;
/*Start: Setup system options*/
*do not edit this section;
	/*set system files to compress and reuse space for speedier processing*/
		OPTIONS COMPRESS=YES REUSE=YES;
	/*set up mprint for macro debugging--use mfile mlogicnest other m- as needed*/
		OPTIONS MPRINT;
	/*gives more info for performance and indices*/
		OPTIONS FULLSTIMER MSGLEVEL=I;
/*End: Setup system options*/
*========================================================================================================================;

*========================================================================================================================;
* Start: formats used by Careset;
*%include "/sas/vrdc/users/shu172/files/jhu_vrdc_code/medicare_formats.sas";			*****SUSIE: build for CS*******;
*set up options fmtsearch;
* End: formats used by Careset; 
*========================================================================================================================;

*========================================================================================================================;
* Start: Automaticlaly setup user-specific parameters
*   [myVRDCname] - your username, automatically detected.                                
*   [myinitials] - This will be used to add the user's initials to dataset names and logs
* ;
    %global myVRDCname YJI989 ;
    %let myVRDCname     = %sysfunc(dequote(&_CLIENTUSERID));
    %let myinitials     = %substr(&myVRDCname,1,2);
   	
* Print to log for QA check;
    Data _null_;
        PUT "User-specific parameters:"/
            "myVRDCname=&myVRDCname | myinitials=&myinitials "
    ;
    %runquit;

* End: Automaticlaly setup user-specific parameters;               
*========================================================================================================================;

*========================================================================================================================;
* Start: Set other project parameters depending on the value 'debug_status'                                                     
*   [perm_lib] - The SAS library where the output dataset will be stored. When debug_status = 1, set to the user's 
*       personal library. Otherwise, set to the shared library SH027654.
*   [obs_limit] - When debug_status = 1, this limits the number of observations (inobs) to process in a PROC SQL statement. 
*       When debug_status = 0, no value is returned.
*   [data_limit] - When debug_status = 1, this limits the number of observations to process in a DATA STEP when it is the 
*       only option in a DATA statement or SET statement. When debug_status = 0, no value is returned.
*   [merge_limit] - When debug_status = 1, this limits the number of observaitons to process in a DATA STEP when other 
*       options such as KEEP, DROP, RENAME, etc. exists in a DATA statement or SET statement. When debug_status = 0, 
*       no value is returned.
*   [program_stub] - Prefix of the output datasets 

* 
* Default values (i.e. debug_status = 0);
	* NOTE: we don't set the default value for &stub_prefix here because it's user-defined above (line 42);
    %global perm_lib obs_limit data_limit merge_limit program_stub; 
    %let perm_lib = SH027654; 
    %let obs_limit = ;
    %let data_limit = ;
    %let merge_limit = ;
        
*   Set the values for the debug run (i.e. debug_status = 1);
        %if &debug_status=1 %then %do;
            %let stub_prefix = X;
            %let perm_lib    = &myVRDCname.SL;
            %let obs_limit   = inobs = &n_debug.;
            %let data_limit  = (obs = &n_debug.);
            %let merge_limit = obs = &n_debug.;                    
        %end; 
    %let program_stub   = &stub_prefix._&project_key; 

*   Print to log for QA check;
    Data _null_;
        PUT "Parameters dependent on DEBUG STATUS (debug_status=&debug_status)"/
            "perm_lib=&perm_lib | obs_limit=&obs_limit | data_limit=&data_limit | merge_limit=&merge_limit"/
			"program_stub =&program_stub"
        ;
    %runquit;
* End: Set other project parameters depending on the value 'debug_status'                                                     
*========================================================================================================================;


*========================================================================================================================;
* DO NOT EDIT
Start: Create the macvar containing the prefix of the claim- and line-/revenue-filenames (Part A and Part B only);
*
*   This macro will loop through each of the settings defined in '&settings_name', and assign assign the corresponding
*   claim-level filename.;
*                                                                                                                        ;
%global settings_claim settings_cline;
    %MACRO get_ffs_filenames(); 
        * Initialize the mac var containing the claim- and line-level filenames;
        %let settings_claim = ;
        %let settings_cline = ;

        * Identify the number of settings to be run;
        %let n_settings = %sysfunc(countw(&settings_name.));

        * Loop through each setting;
        %do _i = 1 %to &n_settings;
            * get the name of the setting currently being processed in the loop;
            %let this_setting =  %scan(&settings_name., &_i.,' ');
            %put &this_setting;
            %if &this_setting = CAR %then %do;
                %let settings_claim = &settings_claim. BCARRIER_CLAIMS;
                %let settings_cline = &settings_cline. BCARRIER_LINE;
            %end;
            %else %if &this_setting = DME %then %do;
                %let settings_claim = &settings_claim. &this_setting._CLAIMS;
                %let settings_cline = &settings_cline. &this_setting._LINE;
            %end;
            %else %if &this_setting = OUT %then %do;
                %let settings_claim = &settings_claim. OUTPATIENT_CLAIMS;
                %let settings_cline = &settings_cline. OUTPATIENT_REVENUE;
            %end;
            %else %if &this_setting = INP %then %do;
                %let settings_claim = &settings_claim. INPATIENT_CLAIMS;
                %let settings_cline = &settings_cline. INPATIENT_REVENUE;
            %end;
            %else %if &this_setting = HSP %then %do;
                %let settings_claim = &settings_claim. HOSPICE_CLAIMS;
                %let settings_cline = &settings_cline. HOSPICE_REVENUE;
            %end;
            %else %do;
                %let settings_claim = &settings_claim. &this_setting._CLAIMS;
                %let settings_cline = &settings_cline. &this_setting._REVENUE; 
            %end;
        %end;
    %MEND;
    %get_ffs_filenames();

* Print to log for QA check;
    DATA _null_;
        PUT "FFS Setting Parameters: "/
		"settings_name=&settings_name"/
        "settings_claim=&settings_claim"/
		"settings_cline=&settings_cline"
        ;
    %runquit;

    
* End: Create the macvar containing the prefix of the claim- and line-/revenue-filenams;
*========================================================================================================================;


***susie move to sample code as a way to look at what is in your library or the shared directory;
*we also need to make a clean up task at the end of each project and use this as a tool;
*========================================================================================================================;
/*START: Look at the members of the libraries that you will access to see what files already exist*/
        proc sql;
            title1 "Checking if there is pre-existing use of this project key in &perm_lib";
            Select * 
            from dictionary.tables 
            where memname LIKE "X_&project_key" or 
                  memname LIKE "&stub_prefix._&project_key." or 
                  UPCASE(memname) LIKE UPCASE("&program_stub");
            ;
        %runquit;
        
/*End: Look at the members of the libraries that you will access to see what files already exist*/
*========================================================================================================================;


*========================================================================================================================;
/*Start: Location where you will store your log files*/
*do not edit this section;
	%let vrdc_logs 	= &myfiles_root./dua_027654/logs  ;
	%let logdate	= %sysfunc(today(),date9.);
	%global vrdc_logs logdate;
 /*End: Location where you will store your log files*/
*========================================================================================================================;

