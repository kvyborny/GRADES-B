*Author: Umair Kiani/ Hijab Waheed
*Date: 16-12-2025
*Purpose: This do file compiles the school list for OSRM exercise (eligibility criteria) 
***Globals

	if c(username) == "wb635947" {
		
		global data "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Data"
		
	}
	
	if c(username) == "wb630098" {
		
		global data "C:\Users\wb630098\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Data"
		
	}


***EMIS

import excel "$data\Admin Data\EMIS Data\Balochistan EMIS Flatsheet 2024-25.xlsx", sheet("16-8-25") firstrow clear

	rename BemisCode BEMIS
	
	keep BEMIS SchoolName Genderupdated SchoolLevel FunctionalStatus // keeping only relevant vars
	
	tempfile emis_flatsheet
	sa `emis_flatsheet'

***merging for coordinates 

	import excel "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Data\Admin Data\Monitoring coordinates\RTSM sheeet with GPS.xlsx", sheet("Sheet1") firstrow clear
	
	rename BemisCode BEMIS
	rename SchoolName schoolname_rtsm
	keep BEMIS XCord YCord Level Gender schoolname_rtsm
	
	merge 1:1 BEMIS using `emis_flatsheet'										// 15 schools are in RTSM but not in EMIS and 567 schools in EMIS are not in RTSM - keeping both at this stage. 
	/*																			
	 Result                      Number of obs
    -----------------------------------------
    Not matched                           582
        from master                        15  (_merge==1)
        from using                        567  (_merge==2)

    Matched                            14,795  (_merge==3)
    -----------------------------------------

	*/
	ren _merge merge_emis_rtsm
	tempfile emis_flatsheet1
	sa `emis_flatsheet1'
	
	
import excel "$data\Admin Data\EMIS Data\emis_coordinates.xlsx", sheet("Sheet1") firstrow clear // first emis coordinates file

	ren GPSY Y
	ren GPSX X
	
	tempfile coord																					
	sa `coord'

import excel "$data\Admin Data\EMIS Data\emis_coordinates_1.xlsx", sheet("main sheet") firstrow clear // second emis coordinates file

	ren lat Y
	ren C X
	keep BEMIS X Y 
	destring BEMIS, force replace
	append using `coord'
	duplicates report BEMIS
	drop if X==.
	drop if Y==.

	tempfile coord_m																				// combined emis coordinates with other vars
	sa `coord_m'

	keep BEMIS X Y

	tempfile coordinates																			// coordinates with just X Y and EMIS
	sa `coordinates'
	
	merge 1:1 BEMIS using `emis_flatsheet1'
	
	/*																			
	   Result                      Number of obs
    -----------------------------------------
    Not matched                           584
        from master                         0  (_merge==1)
        from using                        584  (_merge==2)

    Matched                            14,793  (_merge==3)
	-----------------------------------------
	*/
	drop _m
	drop if X ==. & Y ==. & XCord ==. & YCord ==. 								// dropping the schools (545) for which we dont have coordinates in both RTSM and EMIS
	rename X X_emis
	rename Y Y_emis
	
	rename XCord Y 																//This was a mistake from the admin data, so fixing it here
	rename YCord X
	
	replace Y = Y_emis if Y==.													//Using EMIS coordinates for those school for which we do not have RTSM coordinates (22 schools)
	replace X = X_emis if X==.
	
	drop X_emis Y_emis
	
	rename Y Latitude
	rename X Longitude
	rename BEMIS EMISCode 
	
***SchoolName 
	replace SchoolName = schoolname_rtsm if SchoolName ==""							//Taking schoolname from RTSM for those schools which are not in the EMIS  
	drop schoolname_rtsm
		
	tempfile emis_clean
	sa `emis_clean'
	
	
***Tagging already assessed schools

	use "$data\Dataset\prelim_gradesb\prelim_gradesb.dta", clear
	rename BEMIS EMISCode 
	rename SchoolLevel schoollevel
	
	gen schoolname_gradesb = substr(SchoolName, strpos (SchoolName, "-") + 1, .)
	
	keep EMISCode _GPSCoordinates_latitude _GPSCoordinates_longitude schoolname_gradesb schoollevel
	
	merge 1:1 EMISCode using `emis_clean'
	
	/* Result                      Number of obs
    -----------------------------------------
    Not matched                        11,357
        from master                        10  (_merge==1)
        from using                     11,347  (_merge==2)

    Matched                             3,483  (_merge==3)
    -----------------------------------------
	*/
	
	gen assessment_done =  "Yes" if _m == 3 |  _m == 1
	replace assessment_done = "No" if _m ==2
	drop _m 
	
	replace Latitude = _GPSCoordinates_latitude if Latitude ==.					//Getting coordinates of 10 schools which are not in EMIS but are in already assessed schools
	replace Longitude = _GPSCoordinates_longitude if Longitude ==.
	drop _GPSCoordinates_longitude _GPSCoordinates_latitude
	
	
	replace SchoolName = schoolname_gradesb if SchoolName == ""					//Getting schoolname of 10 schools which are not in EMIS but are in already assessed schools
	drop schoolname_gradesb
	
	drop if EMISCode == 10222 | EMISCode == 3248								//These two schools are dropped because the difference between the coordinates of EMIS and SurveyAuto is more than 3km - we can not rely on these coordinates from EMIS. These schools are also not part of the already assessed schools.
	
	drop if EMISCode == 17989 | EMISCode == 15375 								//These two schools are dropped because the longitude and latitude provided by RTSM dataset was not making sense and we do not have their reliable coordinates in any other dataset
	
***Cleaning gender variable 

	gen gender = Gender															//Using gender variable from the RTSM data and cleaning it by looking at the schoolname + this set of code also adds gender for the 10 schools coming from GRADES B dataset
	replace gender = "Girls" if regexm(SchoolName, "^GG")
	replace gender = "Boys" if regexm(SchoolName, "^GB")
	replace gender = Gender if Gender == "Co-Education"
	replace gender = Gender if regexm(SchoolName, "^GP")
	tab Gender gender, m
	gen gender_changed = 1 if Gender != gender
	drop Gender Genderupdated

****Cleaning school level variable
	replace SchoolLevel = schoollevel if SchoolLevel ==""						//Filling EMIS level with GRADES B level for those 10 schools are not in EMIS but are already assesed
	replace Level = SchoolLevel if Level ==""									//Using RTSM Level and filling in with EMIS where RTSM is missing 
	replace Level = "HIGH" if Level == "high" |  Level == "High"
	replace Level = "HIGHER SECONDARY" if Level == "higher secondary" |  Level == "Higher Secondary"
	replace Level = "MIDDLE" if Level== "Middle"
	replace Level = "PRIMARY" if Level == "Primary"
	tab Level SchoolLevel, m
	drop SchoolLevel schoollevel
	
***Dropping non functional schools
	drop if FunctionalStatus == "Non-Functional"
	
	drop gender_changed 

	tempfile emis_clean1
	sa `emis_clean1'
	
***Dropping STEP B schools
	

import excel "$data\Admin Data\STEP B\STEP-B_Baseline_Survey_Flatsheet.xlsx", sheet("STEP-B Baseline Survey") firstrow clear

	keep BEMIS
	rename BEMIS EMISCode
	
	destring EMISCode, force replace
	merge 1:1 EMISCode using `emis_clean1'
	
	/*   Result                      Number of obs
    -----------------------------------------
    Not matched                        11,817
        from master                         3  (_merge==1)
        from using                     11,814  (_merge==2)

    Matched                               437  (_merge==3)
    -----------------------------------------

*/
	keep if _m==2
	drop _merge

	tempfile emis_clean2																		// dropped Step-B schools from EMIS
	sa `emis_clean2'
	
	
import excel "$data\Admin Data\BHCIP\BHCIP_edited.xlsx", sheet("BHCIP 5 Districts Focused schoo") firstrow clear

	drop if BEMIS ==.
	ren BEMIS EMISCode
	keep EMISCode
	
	merge 1:1 EMISCode using `emis_clean2'
	
	/*  Result                      Number of obs
    -----------------------------------------
    Not matched                        11,550
        from master                        11  (_merge==1)
        from using                     11,539  (_merge==2)

    Matched                               275  (_merge==3)
    -----------------------------------------
*/
	
	keep if _m==2
	drop _merge

	
	save "$data\Dataset\admin\emis_final_clean.dta", replace
	export delimited using "$data\Dataset\admin\emis_final_clean.csv", replace

	