/* This portion of the file is considered authoritative by OneRing */

        *The project key is used to link OneRing, the data downloaded from VRDC, the data warehouse import process and slack, etc etc.;
        %global project_key;
        %let project_key = nvs_kisqali;

        %global github_release_tag;
        * v(product_revision_number).(code_revision_number).(identical_download_number);
        * Any updates to the code, should increment the code_revision_number by one, and reset the download_number to zero;
        * It is acceptable to programmatically overright the last number, if and only if is represented by an 'X' in this file;
        * OneRing will understand that a v.5.6.X in this file, will produce files that increment in the 'X' slot.. ;
        * note that as X is programatically calculated, it must always go up at least by one integer between downloads;

        * If you aren't sure what to set the github_release_tag to, please leave the default value below and submit the %let;
        %let github_release_tag = v0.0.1;

        %global RIFType;
        
        *If you aren't sure what to set the RIFType to, please leave the default value below (MT) and submit the %let;
        *With the addition of monthly data, technically any RIF carveout reaching back more than ~6 months would result in MT;
        *This is because it would pull from Monthly RIF Files (RM) and then Quarterly RIF Files (RQ) resulting in Mixed Type (MT);

        *Mixed Type (i.e. Part D plus Part C, etc) Files;
        %let RIFType = MT;

        *Part C (medicare advantage) Files;
        *%let RIFType = MA;

        *MBSF Files;
        *%let RIFType = MBSF;

        *ACO Files;
        *%let RIFType = AC;

        *PartD Files;
        *%let RIFType = PD;

        *Medicaid Max Files;
        *%let RIFType = MM;

        *Yearly RIFO Files;
        *%let RIFType = RO;
        
        *Yearly RIF Files;
        *%let RIFType = RF;
        
        *yearly RIFS Files;
        *%let RIFType = RS;

        *Monthly RIF Files;
        *%let RIFType = RM; 

        *Quarterly RIF Files;
        *%let RIFType = RQ;
        
        %global run_last_year;
        *The latest year of the run; 
        %let run_last_year = 21;
        
        %global run_last_month;
        *The latest month of the run;
        %let run_last_month = 5;
        
        %global run_rolling_month;
        *The total number of months in the run;
        %let run_rolling_month = 41;
        
        *For convenience we demonstrate how to take these variables and form a RIFString;
        *It is acceptable and good for this to move out of this file and to be calcuated dynamically;
        
        %global RIFString;
        *This is the resulting RIFString. It should be used in both data files and in file outputs.;
        %let RIFString= &RIFType.&run_last_year.R&run_rolling_month._&run_last_month.;   



