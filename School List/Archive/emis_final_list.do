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

	
********************************************************************************
*Generating vars from EMIS
*******************************************************************************
	
import excel "$data\Admin Data\EMIS Data\Balochistan EMIS Flatsheet 2024-25.xlsx", sheet("16-8-25") firstrow clear


	*Enrollment from Kachi - Grade 5
	
	local girls_p KGSt PGSt GSt DS DW EA
	local boys_p KBSt PBSt BSt DQ DU DY

	
	destring `girls_p', replace force
	destring `boys_p', replace force 
	
	egen girls_enrol_p = rowtotal(`girls_p')
	egen boys_enrol_p= rowtotal(`boys_p')
	
	*Enrollment from Kachi - Grade 12
	
	local girls_total KGSt PGSt GSt DS DW EA EE EI EM EQ EU EY FC
	local boys_total KBSt PBSt BSt DQ DU DY EC EG EK EO ES EW FA
	
	destring `girls_total', replace force
	destring `boys_total', replace force 
	
	egen girls_enrol_total = rowtotal(`girls_total') // Total girls enrollment from Kachi - Grade 12
	egen boys_enrol_total = rowtotal(`boys_total')	// Total boys enrollment from Kachi - Grade 12
	
	gen total_enrollment =  girls_enrol_total + boys_enrol_total // Total enrollment in the school from Kachi - Grade 12
	
	* Rename girls enrollment
	rename KGSt girls_kachi
	rename PGSt girls_pakki
	rename GSt  girls_g2
	rename DS   girls_g3
	rename DW   girls_g4
	rename EA   girls_g5
	rename EE	girls_g6
	rename EI	girls_g7
	rename EM	girls_g8
	rename EQ	girls_g9
	rename EU	girls_g10
	rename EY	girls_g11
	rename FC	girls_g12

	* Rename boys enrollment
	rename KBSt boys_kachi
	rename PBSt boys_pakki
	rename BSt  boys_g2
	rename DQ   boys_g3
	rename DU   boys_g4
	rename DY   boys_g5
	rename EC   boys_g6
	rename EG   boys_g7
	rename EK   boys_g8
	rename EO   boys_g9
	rename ES   boys_g10
	rename EW   boys_g11
	rename FA   boys_g12

	gen enrol_per_room = total_enrollment/TotalRooms // Students per classroom
	replace enrol_per_room = 0 if enrol_per_room ==.
	
	gen overcrowded=1 if enrol_per_room >=40
	replace overcrowded =0 if enrol_per_room<40
	
	gen girls_prop_p = (girls_enrol_p / (girls_enrol_p + boys_enrol_p))*100 // Girls proportion in primary school classes (Kachi - G12)
	gen boys_prop_p = (boys_enrol_p / (girls_enrol_p + boys_enrol_p))*100 // Boys proportion in primary school classes (Kachi - G12)
	
	gen girls_prop_total = (girls_enrol_total / (girls_enrol_total + boys_enrol_total))*100 // Girls proportion in the whole school (Kachi - G5)
	gen boys_prop_total = (boys_enrol_total / (girls_enrol_total + boys_enrol_total))*100 // Boys proportion in the whole school (Kachi - G5)
	
	
	destring KachaRoom, replace force
	gen shelterless_emis = "Yes" if total_enrollment>0 & TotalRooms ==0 & TotalRooms !=. | TotalRooms==KachaRoom
	
	gen intervention_ece = 1 if boys_kachi >0 | girls_kachi>0
	replace intervention_ece = 2 if SpaceForNewRooms =="Yes" & SchoolOwnedBy =="Educaton Department" & (boys_kachi >0 | girls_kachi>0)
	
	label define interv_lbl 1 "ECE" 2 "ECE Schools"
	label values intervention_ece interv_lbl
	
	ren BemisCode schoolemiscode

	keep schoolemiscode Location intervention_ece shelterless_emis ///
	District Tehsil SubTehsil UC  VillageName   /// 
	FunctionalStatus girls_enrol_p boys_enrol_p girls_enrol_total boys_enrol_total TotalRooms enrol_per_room SpaceForNewRooms SchoolOwnedBy girls_prop_p boys_prop_p girls_prop_total boys_prop_total total_enrollment TeachingMale TeachingFemale TotalTeachingStaff overcrowded girls* boys* 
	
	/*BuildingStructure BuildingCondition NoOfRoomsWithWindowsAndVantilati ProperSeverageSystem WaterFacilityInToilets BoundaryWall BoundaryWallStructure BoundaryWallCondition PlayGround ElectricityInArea ElectricityInSchool IfYesThenNametheSourceElectricit IfNoThenGiveTheDistanceOfNearest GasInArea GasInSchool IfYesThenNametheSourceGas GovtDrinkingWaterScheme DrinkingWaterAtSchool SourceOfWater WaterTank BB TelephoneAvailabe FunctionStatusTelephone ClosedReasonTelephone InternetAvailabe FunctionStatusInternet ClosedReasonInternet ScienceLab FunctionStatusScienceLab ClosedReasonScienceLab ComputerLab LibraryAvailable CleaningResponsibility WashbasinAvailable WaterforWashBasin SoapForWashBasin CleaningCycleOfWashBasin TeacherUsesTeachingMeterialOnHea MajorDiseaseCauseForAbsentism FirstaidKit TrainingOnFirstAidKit InspectionOfCleaning SeprateRoomForECE FullTimeTeacherForECE TrendExtraCracularActivity Activity1 AudioAndVideoEquipment TeacherUsesAudioAndVideoEquipmen TrainingOnMHMKits MHMKitsAtSchool PTSMC PTSMCParticipatedInAnyActivityCu NumberOfMeetingsConducted MeetingRecordesAvailable ChildOfPTSMCMembersAreEnrolled AnySDPFormPTSMCLast3Years ExaminationHall NumberOfVisitByEducationalManage KachaRoom PakkaRoom KachaHMR PakkaHMR KachaClerkOffice PakkaClerkOffice KachaHall PakkaHall KachaStaffRoom PakkaStaffRoom KachaGuardRoom PakkaGuardRoom KachaToilet PakkaToilet TotalToilets TotalStudentProfileEntered SencTeaching AppTeaching // keeping only relevant vars*/
	
	destring schoolemiscode, replace
	tempfile emis
	sa `emis'
	
********************************************************************************
*Generating overcrowded girls schools list
*******************************************************************************
	 preserve 
	 
	 rename schoolemiscode EMISCode
			
	 merge 1:1 EMISCode using  "$data\Dataset\admin\emis_final_clean.dta", keepusing (SchoolName Latitude Longitude gender Level STEPB BHCIP)
	 /*
	       Result                      Number of obs
    -----------------------------------------
    Not matched                         3,139
        from master                     3,124  (_merge==1)
        from using                         15  (_merge==2)

    Matched                            12,238  (_merge==3)
    -----------------------------------------

*/

	drop if _m == 1
	drop if STEPB ==1 
	drop if BHCIP ==1
	drop if FunctionalStatus == "Non-Functional"
	
	drop STEPB BHCIP
	
	keep if enrol_per_room >=40 & gender == "Girls"
	
	export delimited using "$data\Dataset\admin\overcrowded_girls_schools.csv", replace // list of overcrowded_girls_schools
	
	restore 
	
********************************************************************************
*DS and Transport schools
******************************************************************************
	
	
import delimited "$data\Dataset\osrm\DS_longlist_for_PMU_with_refGirls_ALL.csv", clear
			// got the missing vars from emis using emis id for the DS school list
	
	ren emiscode schoolemiscode
	keep schoolemiscode ref_nearest_girls_emis refgirlsschoolname needs_manual_check ref_nearest_girls_emis_all refgirlsfunctionalstatus_all refgirlsschoolname_all //nearest 1 emis; nearest 1 name; nearest 2 status; nearest 2 emis; nearest 2 name
	
	ren ref_nearest_girls_emis nearest_girls_schoolemis 
	ren refgirlsschoolname nearest_girls_schoolname
	
	
	gen intervention = "Double shift"
	
	merge 1:1 schoolemiscode using `emis', keepusing ( Location intervention_ece  shelterless_emis SpaceForNewRooms SchoolOwnedBy girls_enrol_p boys_enrol_p girls_enrol_total boys_enrol_total girls_prop_p boys_prop_p total_enrollment TeachingMale TeachingFemale TotalTeachingStaff overcrowded enrol_per_room TotalRooms  girls_prop_total boys_prop_total girls* boys*)
	
	/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                        10,816
        from master                         5  (_merge==1)
        from using                     10,811  (_merge==2)

    Matched                             4,551  (_merge==3)
    -----------------------------------------



	*/
	
	drop if _m == 2
	drop _m
	
	tempfile ds_list
	sa `ds_list'

import delimited "$data\Dataset\osrm\TE_longlist_high_conf_for_PMU_with_ref_ANYFUNC.csv", clear	//cleaned the TE list to match the vars for appending

	keep schoolemiscode ref_nearest_school_emis refschoolname needs_manual_check refanygirlsschoolname refanygirlsfunctionalstatus ref_nearest_girls_any_emis
	
	ren ref_nearest_school_emis nearest_girls_schoolemis  // nearest 1 EMIS
	ren refschoolname nearest_girls_schoolname // nearest 1 name
	// nearest 1 distance 
	
	ren refanygirlsfunctionalstatus refgirlsfunctionalstatus_all // nearest 2 status
	ren ref_nearest_girls_any_emis ref_nearest_girls_emis_all // nearest 2 EMIS
	ren refanygirlsschoolname refgirlsschoolname_all // nearest 2 name
	// nearest 2 distance 
	
	gen intervention = "Transport"
	
	merge 1:1 schoolemiscode using `emis', keepusing (  Location intervention_ece shelterless_emis SpaceForNewRooms SchoolOwnedBy girls_enrol_p boys_enrol_p girls_enrol_total boys_enrol_total girls_prop_p boys_prop_p total_enrollment TeachingMale TeachingFemale TotalTeachingStaff overcrowded enrol_per_room TotalRooms  girls_prop_total boys_prop_total girls* boys*)
	
	/*
	    Result                      Number of obs
    -----------------------------------------
    Not matched                        13,324
        from master                         0  (_merge==1)
        from using                     13,324  (_merge==2)

    Matched                             2,038  (_merge==3)
    -----------------------------------------


	*/
	
	keep if _m == 3
	drop _m
	
	append using `ds_list', gen(check_append)									// appended the DS list
	drop check_append	
	
	gen nearby_non_functional = "Yes" if refgirlsfunctionalstatus_all == "Non-Functional"
	replace nearby_non_functional = "No" if refgirlsfunctionalstatus_all != "Non-Functional"
	
	
	*****Categories*****
	
	rename intervention intervention_dste
	
	gen intervention =""
	replace intervention = "Transport + ECE" if intervention_ece == 1 & intervention_dste == "Transport"
	replace intervention = "DS + ECE" if intervention_ece == 1 & intervention_dste == "Double shift"
	replace intervention = "Transport + ECE Schools" if intervention_ece == 2 & intervention_dste == "Transport"
	replace intervention = "DS + ECE Schools" if intervention_ece == 2 & intervention_dste == "Double shift"
	replace intervention = "DS only" if intervention_ece == . & intervention_dste == "Double shift"
	replace intervention = "Transport only" if intervention_ece == . & intervention_dste == "Transport"
	
	tempfile master
	sa `master'




********************************************************************************
*GRADES B 
******************************************************************************
	
	import excel "$data\Admin Data\GRADES B\GRADES Latest sheet 3278 schools (2).xlsx", sheet("Sheet1") firstrow clear
	
	rename BEMIS schoolemiscode
	destring schoolemiscode, replace  
	keep schoolemiscode 
	
	merge 1:1 schoolemiscode using `master' 
	
	/*
	  Result                      Number of obs
    -----------------------------------------
    Not matched                         6,167
        from master                     1,567  (_merge==1)
        from using                      4,600  (_merge==2)

    Matched                             1,711  (_merge==3)
    -----------------------------------------

*/
	gen assessment_done = "Yes" if _m == 3 | _m == 1
	replace assessment_done = "No" if _m ==2
	keep if _m==2 | _m==3
	drop _m
	
	tempfile gradesb_dste
	sa `gradesb_dste'

	
********************************************************************************
*Merging with emis clean dataset to get clean coordinates and gender
*******************************************************************************
	use "$data\Dataset\admin\emis_final_clean.dta", clear
	
	rename EMISCode schoolemiscode 
	
	merge 1:1 schoolemiscode using `gradesb_dste'
	
	/*
	   Result                      Number of obs
    -----------------------------------------
    Not matched                         5,659
        from master                     5,659  (_merge==1)
        from using                          0  (_merge==2)

    Matched                             6,594  (_merge==3)
    -----------------------------------------

	*/
	
	keep if _m==3
	drop _m
	
	tempfile master1
	sa `master1'

********************************************************************************
*Merging with clean UC, Tehsil, Subtehsil data
******************************************************************************

	import excel "$data\Admin Data\EMIS Data\school name with UC.xlsx", sheet("Sheet1") firstrow clear
	
	rename BemisCode schoolemiscode 
	keep schoolemiscode Division District Tehsil SubTehsil UC VillageName
	
	merge 1:1 schoolemiscode using `master1'
	
	/*    
    Result                      Number of obs
    -----------------------------------------
    Not matched                         8,781
        from master                     8,776  (_merge==1)
        from using                          5  (_merge==2)

    Matched                             6,589  (_merge==3)
    -----------------------------------------


	*/
	keep if _m == 3 | _m ==2
	
	gen emis_info_missing = 1 if _m ==2
	
	drop _m
	
	
********************************************************************************
*Dropping STEP B and BHCIP schools
******************************************************************************
	

	***dropping STEP B, BHCIP
	
	drop if STEPB ==1 
	drop if BHCIP ==1	
	drop STEPB BHCIP
	drop emis_info_missing
	
	drop if nearby_non_functional == "Yes" & assessment_done != "Yes" 			// dropping those schools where non functional schools are
	
	tempfile master2
	sa `master2'
	
	

	
	replace ref_nearest_girls_emis_all =. if refgirlsfunctionalstatus_all!="Non-Functional"
	replace refgirlsschoolname_all ="" if refgirlsfunctionalstatus_all!="Non-Functional"
	replace refgirlsfunctionalstatus_all="" if refgirlsfunctionalstatus_all!="Non-Functional"
	ren refgirlsfunctionalstatus_all non_func_nearby
	ren refgirlsschoolname_all non_func_schname
	ren ref_nearest_girls_emis_all non_func_emis
	replace non_func_nearby="Yes" if non_func_nearby=="Non-Functional"
	ren nearest_girls_schoolemis near_girlcoed_emis
	ren nearest_girls_schoolname near_girlcoed_name
	ren schoolemiscode emiscode
	*ren ECE ece_oldassessment
	*ren Shelterless shelterless_oldassessment
	order emiscode SchoolName Division District Tehsil SubTehsil UC VillageName Level FunctionalStatus gender Latitude Longitude intervention Location assessment_done near_girlcoed_emis near_girlcoed_name needs_manual_check non_func_nearby non_func_emis non_func_schname
	br nearby_non_functional non_func_nearby
	drop nearby_non_functional
		
	keep emiscode SchoolName District intervention Tehsil assessment_done Latitude Longitude near_girlcoed_emis near_girlcoed_name FunctionalStatus gender VillageName intervention intervention_ece intervention_dste
	
	
	
	save "$data\Dataset\admin\long_list.dta", replace							//saving .dta file 
	export delimited using "$data\Dataset\admin\long_list.csv", replace			//saving the csv file
	
	