*Author: Umair Kiani/ Hijab Waheed
*Date: 16-12-2025
*Purpose: School list for GRADES B

***Globals

	if c(username) == "wb635947" {
		
		global data "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Data"
		
	}
	
	if c(username) == "wb630098" {
		
		global data "C:\Users\wb630098\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Data"
		
	}


***Merging for coordinates

import excel "$data\Admin Data\EMIS Data\Balochistan EMIS Flatsheet 2024-25.xlsx", sheet("16-8-25") firstrow clear

	rename BemisCode BEMIS
	/*
	*Enrollment from Kachi - Grade 5
	
	local girls_p KGSt PGSt GSt DS DW EA
	local boys_p KBSt PBSt BSt DQ DU DY
	
	destring `girls_p', replace force
	destring `boys_p', replace force 
	
	egen girls_enrol_p = rowtotal(`girls_p')
	egen boys_enrol_p= rowtotal(`boys_p')
	
	Enrollment from Kachi - Grade 12
	
	local girls_total KGSt PGSt GSt DS DW EA EE EI EM EQ EU EY FC
	local boys_total KBSt PBSt BSt DQ DU DY EC EG EK EO ES EW FA
	
	destring `girls_total', replace force
	destring `boys_total', replace force 
	
	egen girls_enrol_total = rowtotal(`girls_total')
	egen boys_enrol_total = rowtotal(`boys_total')	
	
	gen enrol_per_room = (girls_enrol_total + boys_enrol_total)/TotalRooms
	replace enrol_per_room = 0 if enrol_per_room ==.

	keep BEMIS SchoolName Genderupdated SchoolLevel FunctionalStatus District Tehsil Location
	*SubTehsil UC VillageName Genderupdated SchoolLevel FunctionalStatus girls_enrol_p boys_enrol_p girls_enrol_total boys_enrol_total TotalRooms enrol_per_room SpaceForNewRooms SchoolOwnedBy // keep only relevant vars
	*/
	keep BEMIS SchoolName 
	tempfile emis_flatsheet
	sa `emis_flatsheet'
	
import excel "$data\Admin Data\EMIS Data\emis_coordinates.xlsx", sheet("Sheet1") firstrow clear // first emis coordinates file

	ren GPSY Y
	ren GPSX X
	
	tempfile coord																					
	sa `coord'

import excel "$data\Admin Data\EMIS Data\emis_coordinates_1.xlsx", sheet("main sheet") firstrow clear // second emis coordinates file

	ren lat Y
	ren C X
	keep BEMIS X Y SchoolName 
	*District Tehsil SubTehsil UC VillageName FunctionalStatus Genderupdated
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
	
	merge 1:1 BEMIS using `emis_flatsheet'										// merge with original EMIS to keep original EMIS data and new X Y
	
	
/*	
    Result                      Number of obs
    -----------------------------------------
    Not matched                           599
        from master                        15  (_merge==1)
        from using                        584  (_merge==2)

    Matched                            14,778  (_merge==3)
    -----------------------------------------
*/
	keep if _m==3																					// only relevant where coordinates exist
    drop _merge	
	
	duplicates report X Y
	duplicates tag X Y, gen (emis_xy_dup)
	
	rename BEMIS EMISCode
	rename X X_emis
	rename Y Y_emis
	
	tempfile master
	sa `master'
	
	

***Using Survey Auto's school coordinates
	
	use "$data\Dataset\database\database.dta", clear
	
	keep EMISCode Latitude Longitude SchoolName
	duplicates report EMISCode
	duplicates report Latitude Longitude
	
	merge 1:1 EMISCode using `master' 									// Merge surveyauto database to get their coordinates 
	
	/*
	 Result                      Number of obs
    -----------------------------------------
    Not matched                         1,393
        from master                       802  (_merge==1)
        from using                        591  (_merge==2)

    Matched                            13,468  (_merge==3)
    -----------------------------------------
	*/
	
	rename Longitude X_sa
	rename Latitude Y_sa
	rename _merge merge_sa
																		// check on how different the coordinates (EMIS v Surveyauto)
	geodist Y_emis X_emis Y_sa X_sa, gen (emis_v_sa)
	sum emis_v_sa, d
	
	count if emis_v_sa ==0 // schools with same coordinates
	//8,565
	count if emis_v_sa >0 & emis_v_sa <1
	//3,336
	count if emis_v_sa >1
	//2,966
	count if emis_v_sa >3
	//2,874
	
	rename EMISCode schoolemiscode
	merge 1:1 schoolemiscode using "$data\Dataset\admin\long_list.dta", keepusing(schoolname) //checking for the long of schools now
	/*
	  Result                      Number of obs
    -----------------------------------------
    Not matched                         7,012
        from master                     7,012  (_merge==1)
        from using                          0  (_merge==2)

    Matched                             7,855  (_merge==3)
    -----------------------------------------
	*/
	gen long_list = 1 if _m == 3
	drop _m 
	
	count if emis_v_sa ==0 & long_list==1 // schools with same coordinates
	//4,438
	count if emis_v_sa >0 & emis_v_sa <1 & long_list==1
	//1,899
	count if emis_v_sa >1 & long_list==1 & emis_v_sa !=.
	//1,193
	count if emis_v_sa >3 & long_list==1 & emis_v_sa !=.
	//1,151
	
	tempfile emis_coor
	sa `emis_coor'
	
***Using already assessed schools' coordinates
	
	use "$data\Dataset\gradesb\gradesb.dta", clear
	ren BEMIS schoolemiscode
	keep schoolemiscode _GPSCoordinates_longitude _GPSCoordinates_latitude
	rename _GPSCoordinates_longitude X_rtsm
	rename _GPSCoordinates_latitude Y_rtsm
	
	merge 1:1 schoolemiscode using `emis_coor'
	/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                        11,390
        from master                         8  (_merge==1)
        from using                     11,382  (_merge==2)

    Matched                             3,485  (_merge==3)
    -----------------------------------------
	*/
	
	gen assessment_done =  "Yes" if _m == 3
	replace assessment_done = "No" if _m !=3
	drop _m 
	
	geodist Y_sa X_sa Y_rtsm X_rtsm, gen (sa_v_rtsm)
	geodist Y_emis X_emis Y_rtsm X_rtsm, gen (emis_v_rtsm)
	
save "$data\Dataset\admin\coordinates_checks.dta", replace							//saving .dta file
export delimited using "$data\Dataset\admin\lcoordinates_checks.csv", replace			//saving the csv file