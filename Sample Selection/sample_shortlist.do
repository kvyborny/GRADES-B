*Author: Hijab Waheed
*Date: 24-10-2025
*Purpose: Finding the nearest schools to the Grade B schools using EMIS data

***Globals

	if c(username) == "wb635947" {
		
		global data "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Data"
		
	}
	
	if c(username) != "" {
		
		// Please add your file path accordingly
		
	}



***STEP 1: Prepare EMIS data with coordinates***
	import excel "$data\Admin Data\EMIS Data\Balochistan EMIS Flatsheet 2024-25.xlsx", sheet("16-8-25") firstrow clear
	//15362 obs

	rename BemisCode BEMIS

	merge 1:1 BEMIS using "$data\Dataset\admin\bemis_coordinates.dta", keepusing(GPSY GPSX) // Merge coordinates from another file
	//13220 obs

	keep if _merge == 3 // dropping the schools for which we do not have coordinates
	destring, replace
	keep BEMIS SchoolName District Tehsil SubTehsil UC VillageName SchoolContactNo Location Genderupdated SchoolLevel Shift GPSY GPSX // keeping important vars only (for the purpose of python code only)

	save "$data\Dataset\admin\emis_data.dta", replace
	export excel using "$data\Dataset\admin\emis_data.xlsx", firstrow(variables) replace

***STEP 2: Run a nearest school matching exercise on the EMIS data***
//RUN PYTHON CODE ON "emis_data"


***STEP 3: Clean GRADES B data and save


*GRADES B data clean, merge, and save
import excel "$data\Admin Data\GRADES B\GRADES-B basleline Complete data.xlsx", sheet("Sheet1") firstrow clear

destring, replace //Destring BEMIS for merging

duplicates report BEMIS
/* 
--------------------------------------
   Copies | Observations       Surplus
----------+---------------------------
        1 |         3204             0
        2 |          552           276
        3 |           36            24
        4 |            4             3
--------------------------------------
*/
duplicates tag BEMIS, gen (dup)
drop if dup !=0 // Remove duplicates 

save "$data\Dataset\gradesb\gradesb.dta", replace



***STEP 4: Merge the nearest closest file with the EMIS data***

	*Import the output file and save as .dta file
	import delimited "$data\Dataset\nearest_girls_school\closest_schools.csv", clear
	rename schoolemiscode BEMIS
	save "$data\Dataset\nearest_girls_school\closest_schools.dta", replace


	*EMIS, merge and save

	import excel "$data\Admin Data\EMIS Data\Balochistan EMIS Flatsheet 2024-25.xlsx", sheet("16-8-25") firstrow clear

	rename BemisCode BEMIS
	destring, replace //Destring BEMIS for merging
	duplicates report BEMIS

	*merge with the output file of python for the closest schools coordinates

	merge 1:1 BEMIS using "$data\Dataset\nearest_girls_school\closest_schools.dta", keepusing(schoolname gender shift schoollocation schoollatitude schoollongitude closestschool closestschoolemiscode schoollongitude closestschoollongitude distancekm)
	rename _merge merge_closestschool

	*merge with the GRADES B data for reliable functional schools 
	
	merge 1:1 BEMIS using "$data\Dataset\gradesb\gradesb.dta", keepusing (Istheschoolfunctional)
	rename _merge merge_gradesb
	
	*merge with the SurveyAuto database
	rename BEMIS EMISCode
	merge 1:1 EMISCode using "$data\Dataset\database.dta"
	

	*Cleaning variables 

	local oldvars BSt GSt DQ DS DU DW DY EA EC EE EG EI EK EM EO EQ ES EU EW EY FA FC
	local newvars TwoBSt TwoGSt ThreeBSt ThreeGSt FourBSt FourGSt FiveBSt FiveGSt SixBSt SixGSt ///
				  SevenBSt SevenGSt EightBSt EightGSt NineBSt NineGSt TenBSt TenGSt ///
				  ElevenBSt ElevenGSt TwelveBSt TwelveGSt

	local n : word count `oldvars'
	forvalues i = 1/`n' {
		rename `: word `i' of `oldvars'' `: word `i' of `newvars''
	}

	local St KBSt KGSt PBSt PGSt TwoBSt TwoGSt ThreeBSt ThreeGSt FourBSt FourGSt FiveBSt FiveGSt //
	destring *St, replace
				  
	foreach var of local St {
		
		replace `var' = "0" if `var'== "NULL"
	} 
	

	*Demand > Capacity for girls school
	local St KBSt KGSt PBSt PGSt TwoBSt TwoGSt ThreeBSt ThreeGSt FourBSt FourGSt FiveBSt FiveGSt //
	destring *St, replace
	
	local lvl K P Two Three Four Five
	foreach var of local lvl  {
		gen enrollment_`=lower("`var'")' = `var'BSt + `var'GSt
	}
	
	/*egen maxval_40 = rowmax(enrollment_k enrollment_p enrollment_two enrollment_three enrollment_four enrollment_five)
	gen enrollment_40_G = 1 if maxval_40 > 40 & Genderupdated == "Girls"
	*/
	
	egen mean_40 = rowmean(enrollment_k enrollment_p enrollment_two enrollment_three enrollment_four enrollment_five)
	gen enrollment_40_G = 1 if mean_40 > 40 & Genderupdated == "Girls"
	
	*Boys schools with <5 girls 

	/*egen minval_5 = rowmin(KGSt  PGSt  TwoGSt  ThreeGSt  FourGSt  FiveGSt) 
	gen enrollment_5_B = 1 if minval_5 <=5  &  Genderupdated == "Boys"
	*/
	
	egen mean_5 = rowmean(KGSt  PGSt  TwoGSt  ThreeGSt  FourGSt  FiveGSt)
	gen enrollment_5_B = 1 if mean_5 <=5  &  Genderupdated == "Boys"
	
	*Functional
	gen functional = 1 if Istheschoolfunctional == "Yes"
	replace functional = 1 if FunctionalStatus ==  "Functional" 
	replace functional = 0 if Istheschoolfunctional == "No"

	
	*Nearest girls school is less than 1km away

	gen nearest_girls_school_1km = 1 if distancekm >1
	replace nearest_girls_school_1km = 0 if distancekm <=1
	replace nearest_girls_school_1km =. if closestschool == ""

	count if enrollment_40_G == 1  & nearest_girls_school_1km == 1 & _merge == 3
//69  (13 functional)
	count if  enrollment_5_B == 1 & nearest_girls_school_1km == 1 & _merge == 3
// 4,391 (GRADES-B functionality: 914 functional, 74 not functional )


save "$data\Dataset\admin\emis_data_clean.dta", replace

