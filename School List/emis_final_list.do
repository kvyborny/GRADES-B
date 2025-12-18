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

	
use "$data\Dataset\admin\emis_final_clean.dta", clear 							// prepared emis to get the vars
	ren EMISCode schoolemiscode
	ren SchoolName schoolname
	ren UC uc 
	ren Tehsil tehsil
	ren SubTehsil subtehsil
	ren VillageName villagename
	ren District district
	ren FunctionalStatus functionalstatus
	ren Location location

	tempfile emis
	sa `emis'
	
import delimited "$data\Dataset\osrm\DS_longlist_for_PMU.csv", clear			// got the missing vars from emis using emis id for the DS school list
	ren emiscode schoolemiscode
	keep schoolemiscode district schoollevel gender latitude longitude functionalstatus
	merge 1:1 schoolemiscode using `emis', keepusing (schoolname uc subtehsil villagename tehsil location)
	keep if _m == 3
	drop _m
	
	tempfile ds_list
	sa `ds_list'

import delimited "$data\Dataset\osrm\TE_longlist_high_conf_for_PMU.csv", clear	//cleaned the TE list to match the vars for appending

	drop te_isolated_high_conf needs_manual_check 
	
	merge 1:1 schoolemiscode using `emis', keepusing (location)
	keep if _m == 3
	drop _m
	
	append using `ds_list', gen(check_append)									// appended the DS list
	drop check_append


	save "$data\Dataset\admin\long_list.dta", replace							//saving .dta file
	export delimited using "$data\Dataset\admin\long_list.csv", replace			//saving the csv file