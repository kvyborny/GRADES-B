*Author: Hijab Waheed
*Date: 24-12-2025
*Purpose: School list for GRADES B

***Globals

	if c(username) == "wb635947" {
		
		global data "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Data"
		
	}
	
	if c(username) == "wb630098" {
		
		global data "C:\Users\wb630098\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Data"
		
	}


	
	use "$data\Dataset\admin\emis_final_clean.dta", clear
	
	preserve
	keep EMISCode SchoolName District Tehsil SubTehsil UC SchoolLevel FunctionalStatus SchoolOwnedBy SpaceForNewRooms girls_enrol_p boys_enrol_p enrol_per_room Latitude Longitude gender assessment_done girls_enrol_total boys_enrol_total girls_prop_p boys_prop_p TotalRooms gender_changed total_enrollment
	keep if enrol_per_room >=40 & gender == "Girls"
	
	rename EMISCode schoolemiscode
	merge 1:1 schoolemiscode using "$data\Dataset\admin\long_list.dta"
	
	/* 
    Result                      Number of obs
    -----------------------------------------
    Not matched                         8,074
        from master                       368  (_merge==1)
        from using                      7,706  (_merge==2)

    Matched                               149  (_merge==3)
	*/
	drop if _m == 2
	gen transport_eligible = "Yes" if _m == 3
	replace transport_eligible = "No" if _m ==1
	drop _m 	
	drop schoolname district tehsil uc subtehsil villagename schoollevel functionalstatus latitude longitude intervention location school_owned_by space_new_room
	
	export delimited using "$data\Dataset\admin\overcrowded_girls_schools.csv", replace // list of overcrowded_girls_schools
	
	restore
	
	keep if gender_changed == 1
	
	drop SchoolLevel FunctionalStatus SchoolOwnedBy SpaceForNewRooms TotalRooms girls_enrol_p boys_enrol_p girls_enrol_total boys_enrol_total enrol_per_room Latitude Longitude gender_changed assessment_done 
	
	export delimited using "$data\Dataset\admin\gender_changed.csv", replace // list of schools where we changed the 
