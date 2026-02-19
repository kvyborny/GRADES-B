*Author: Umair Kiani/ Hijab Waheed
*Date: 16-12-2025
*Purpose: School list for GRADES B

***Globals

	if c(username) == "wb635947" {
		
		global data "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Data"
		
	}
	
	if c(username) == "wb630098" {
		
		global data "C:\Users\wb630098\WBG\Jayati Sethi - SAR GIL Projects Team Folder 2023\New Impact Evaluation Candidates\Pakistan GRADES-B\Data"
		
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
	
	
	destring KachaRoom PakkaRoom, replace force
	
	gen Shelterless = "Yes" if total_enrollment>0 & KachaRoom >= 0 & PakkaRoom ==0
	
	gen intervention_ece = 1 if boys_kachi >0 | girls_kachi>0 //Schools where only ECE material will be provided
	replace intervention_ece = 2 if SpaceForNewRooms =="Yes" & SchoolOwnedBy =="Educaton Department" & (boys_kachi >0 | girls_kachi>0) //Schools where construction will happen along with providing ECE material
	
	label define interv_lbl 1 "ECE" 2 "ECE Schools"
	label values intervention_ece interv_lbl
	
	ren BemisCode schoolemiscode

	keep schoolemiscode Location intervention_ece Shelterless ///
	District Tehsil SubTehsil UC  VillageName   /// 
	FunctionalStatus girls_enrol_p boys_enrol_p girls_enrol_total boys_enrol_total TotalRooms enrol_per_room SpaceForNewRooms SchoolOwnedBy girls_prop_p boys_prop_p girls_prop_total boys_prop_total total_enrollment TeachingMale TeachingFemale TotalTeachingStaff overcrowded girls* boys* // keeping the relevant vars only
	
	/*BuildingStructure BuildingCondition NoOfRoomsWithWindowsAndVantilati ProperSeverageSystem WaterFacilityInToilets BoundaryWall BoundaryWallStructure BoundaryWallCondition PlayGround ElectricityInArea ElectricityInSchool IfYesThenNametheSourceElectricit IfNoThenGiveTheDistanceOfNearest GasInArea GasInSchool IfYesThenNametheSourceGas GovtDrinkingWaterScheme DrinkingWaterAtSchool SourceOfWater WaterTank BB TelephoneAvailabe FunctionStatusTelephone ClosedReasonTelephone InternetAvailabe FunctionStatusInternet ClosedReasonInternet ScienceLab FunctionStatusScienceLab ClosedReasonScienceLab ComputerLab LibraryAvailable CleaningResponsibility WashbasinAvailable WaterforWashBasin SoapForWashBasin CleaningCycleOfWashBasin TeacherUsesTeachingMeterialOnHea MajorDiseaseCauseForAbsentism FirstaidKit TrainingOnFirstAidKit InspectionOfCleaning SeprateRoomForECE FullTimeTeacherForECE TrendExtraCracularActivity Activity1 AudioAndVideoEquipment TeacherUsesAudioAndVideoEquipmen TrainingOnMHMKits MHMKitsAtSchool PTSMC PTSMCParticipatedInAnyActivityCu NumberOfMeetingsConducted MeetingRecordesAvailable ChildOfPTSMCMembersAreEnrolled AnySDPFormPTSMCLast3Years ExaminationHall NumberOfVisitByEducationalManage KachaRoom PakkaRoom KachaHMR PakkaHMR KachaClerkOffice PakkaClerkOffice KachaHall PakkaHall KachaStaffRoom PakkaStaffRoom KachaGuardRoom PakkaGuardRoom KachaToilet PakkaToilet TotalToilets TotalStudentProfileEntered SencTeaching AppTeaching // keeping only relevant vars*/
	
	destring schoolemiscode, replace
	tempfile emis
	sa `emis'
	
********************************************************************************
*Generating overcrowded girls schools list
*******************************************************************************
	 preserve 
	 
	 rename schoolemiscode EMISCode
			
	 merge 1:1 EMISCode using  "$data\Dataset\admin\emis_final_clean.dta", keepusing (SchoolName Latitude Longitude gender Level /*STEPB BHCIP*/)
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
*	drop if STEPB ==1 
*	drop if BHCIP ==1
	drop if FunctionalStatus == "Non-Functional"
	
*	drop STEPB BHCIP
	
	keep if enrol_per_room >=40 & gender == "Girls"
	
	export delimited using "$data\Dataset\admin\overcrowded_girls_schools.csv", replace // list of overcrowded_girls_schools
	
	restore 
	
********************************************************************************
*DS and Transport schools
******************************************************************************
	
	
import delimited "$data\Dataset\osrm\DS_longlist_for_PMU_with_refGirls_ALL.csv", clear // OSRM output file 1
	
	ren emiscode schoolemiscode
	keep schoolemiscode ref_nearest_girls_emis refgirlsschoolname needs_manual_check ref_nearest_girls_emis_all refgirlsfunctionalstatus_all refgirlsschoolname_all //nearest 1 emis; nearest 1 name; nearest 2 status; nearest 2 emis; nearest 2 name
	
	ren ref_nearest_girls_emis nearest_girls_schoolemis 
	ren refgirlsschoolname nearest_girls_schoolname
	
	
	gen intervention = "Double shift"
	
	merge 1:1 schoolemiscode using `emis', keepusing ( Location intervention_ece  Shelterless SpaceForNewRooms SchoolOwnedBy girls_enrol_p boys_enrol_p girls_enrol_total boys_enrol_total girls_prop_p boys_prop_p total_enrollment TeachingMale TeachingFemale TotalTeachingStaff overcrowded enrol_per_room TotalRooms  girls_prop_total boys_prop_total girls* boys*) // got the missing vars from emis using emis id for the DS school list
	
	/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                        10,816
        from master                         5  (_merge==1)
        from using                     10,811  (_merge==2)

    Matched                             4,551  (_merge==3)
    -----------------------------------------



	*/
	
	drop if _m == 2 // dropping extra schools coming from EMIS
	drop _m
	
	tempfile ds_list
	sa `ds_list'

import delimited "$data\Dataset\osrm\TE_longlist_high_conf_for_PMU_with_ref_ANYFUNC.csv", clear	 //OSRM output file 2

	keep schoolemiscode ref_nearest_school_emis refschoolname needs_manual_check refanygirlsschoolname refanygirlsfunctionalstatus ref_nearest_girls_any_emis
	
	ren ref_nearest_school_emis nearest_girls_schoolemis  // nearest 1 EMIS //cleaned the TE list to match the vars for appending
	ren refschoolname nearest_girls_schoolname // nearest 1 name
	// nearest 1 distance 
	
	ren refanygirlsfunctionalstatus refgirlsfunctionalstatus_all // nearest 2 status
	ren ref_nearest_girls_any_emis ref_nearest_girls_emis_all // nearest 2 EMIS
	ren refanygirlsschoolname refgirlsschoolname_all // nearest 2 name
	// nearest 2 distance 
	
	gen intervention = "Transport"
	
	merge 1:1 schoolemiscode using `emis', keepusing (  Location intervention_ece Shelterless SpaceForNewRooms SchoolOwnedBy girls_enrol_p boys_enrol_p girls_enrol_total boys_enrol_total girls_prop_p boys_prop_p total_enrollment TeachingMale TeachingFemale TotalTeachingStaff overcrowded enrol_per_room TotalRooms  girls_prop_total boys_prop_total girls* boys*)
	
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
	
	tempfile master
	sa `master'

********************************************************************************
*Merging with emis clean dataset to get clean coordinates and gender
*******************************************************************************
	use "$data\Dataset\admin\emis_final_clean.dta", clear
	
	rename EMISCode schoolemiscode 
	
	merge 1:1 schoolemiscode using `master'
	
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
	
	
	replace ref_nearest_girls_emis_all =. if refgirlsfunctionalstatus_all!="Non-Functional"
	replace refgirlsschoolname_all ="" if refgirlsfunctionalstatus_all!="Non-Functional"
	replace refgirlsfunctionalstatus_all="" if refgirlsfunctionalstatus_all!="Non-Functional"
	
	ren (refgirlsfunctionalstatus_all refgirlsschoolname_all ref_nearest_girls_emis_all nearest_girls_schoolemis nearest_girls_schoolname schoolemiscode) ///
	(non_func_nearby non_func_schname non_func_emis near_girlcoed_emis near_girlcoed_name emiscode)
	replace non_func_nearby="Yes" if non_func_nearby=="Non-Functional"
	
	
	order emiscode SchoolName Level FunctionalStatus gender Latitude ///
	Longitude Location District near_girlcoed_emis near_girlcoed_name ///
	needs_manual_check non_func_nearby non_func_emis non_func_schname ///
	nearby_non_functional Shelterless
		
	keep emiscode SchoolName Level FunctionalStatus Latitude Longitude  ///
	Location gender District UC Tehsil near_girlcoed_emis near_girlcoed_name ///
	intervention_ece intervention_dste Shelterless nearby_non_functional non_func_schname non_func_emis
	
	gen master =1
	
	tempfile master2
	sa `master2'
	
	
********************************************************************************
*GRADES B 
******************************************************************************
	
	import excel "$data\Admin Data\GRADES B\GRADES Latest sheet 3278 schools (2).xlsx", sheet("Sheet1") firstrow clear
	
	replace Shelterless ="Yes" if Shelterless =="Shelter less" | Shelterless =="shelter less"	
	replace ECE = "ECE Schools" if ECE =="ECE schools"

	ren (BEMIS Gender RuralArea _GPSCoordinates_latitude _GPSCoordinates_longitude UnionCouncil) (emiscode gender Location Latitude Longitude UC)
	keep District SchoolName emiscode Level gender Location ECE Shelterless Latitude Longitude Doubleshift UC Tehsil
	
	
	tab ECE
		/*
			ECE |      Freq.     Percent        Cum.
	------------+-----------------------------------
			ECE |        465       14.77       14.77
	ECE Schools |      2,683       85.23      100.00
	------------+-----------------------------------
		  Total |      3,148      100.00

	*/
	
	destring emiscode, replace  
	gen assessment_done = 1
	ren Shelterless shelter_rtsm
	
	tempfile gradesb
	sa `gradesb'
	
	keep emiscode assessment_done
	merge 1:1 emiscode using `master2'											
	
	
	
	/*
	
    Result                      Number of obs
    -----------------------------------------
    Not matched                         6,145
        from master                     1,567  (_merge==1)
        from using                      4,578  (_merge==2)

    Matched                             1,711  (_merge==3)
    -----------------------------------------
*/

	drop if _merge ==1 															//keeping just master dataset observations that would also indicate those schools which have been prev assessed by RTSM
	
	tempfile master3															//Reflects the var added to identify previously assessed schools
	sa `master3'

	append using `gradesb' 
	
	replace Shelterless ="" if assessment_done ==1								//To ensure that shelterness for assessed comes only from rtsm list
	encode shelter_rtsm, gen (shelterless)
	encode ECE, gen(ece)
	encode Doubleshift, gen (ds)
	drop shelter_rtsm Doubleshift ECE
	ren (ece ds) (ECE Doubleshift)
	tab shelterless

	duplicates report emiscode assessment_done
	duplicates tag emiscode assessment_done, gen (tag)							// tagging the 1711 + 1711 duplicated schools
	sort emiscode

	foreach var of varlist ECE shelterless Doubleshift {
	
	* Sort by emiscode
	sort emiscode

	* Create a temporary variable with the non-missing value
	bysort emiscode: egen temp_`var' = max(`var')
	* Replace missing values
	replace `var' = temp_`var' if missing(`var')

	* Drop temp
	drop temp_`var'
	}
	
	replace intervention_ece=ECE if assessment_done ==1
	drop if assessment_done!=1 & nearby_non_functional=="Yes"
	
/*	gen intervention =""
	replace intervention= "DS Only" if intervention_dste=="Double shift" & nearby_non_functional!="Yes"
	replace intervention = "Transport" if  intervention_dste=="Transport" & nearby_non_functional!="Yes"
	replace intervention = "DS + ECE Schools" if intervention_dste=="Double shift" & intervention_ece ==2 & nearby_non_functional!="Yes" 
	replace intervention = "DS + ECE" if intervention_dste=="Double shift" & intervention_ece ==1 & nearby_non_functional!="Yes"
	replace intervention = "Transport + ECE" if intervention_dste=="Transport" & intervention_ece ==1 & nearby_non_functional!="Yes"
	replace intervention = "Transport + ECE Schools" if intervention_dste=="Transport" & intervention_ece ==2 & nearby_non_functional!="Yes"
	replace intervention = "ECE Only" if ECE==1 & intervention ==""
	replace intervention = "ECE Schools" if ECE==2 & intervention ==""
	replace intervention = "DS Only" if intervention_dste =="Double shift" & intervention=="" & master==1 & ECE==. & nearby_non_functional!="Yes"
	replace intervention = "Transport" if intervention_dste =="Transport" & intervention=="" & master==1 & ECE==. & nearby_non_functional!="Yes"
	
	replace Shelterless ="Yes" if shelterless==1 & assessment_done ==1
	replace intervention="DS_Girls_RTSM" if Doubleshift ==2 & intervention_dste=="" & intervention_ece==.
	replace intervention="DS_overcrowd_RTSM" if Doubleshift ==1 & intervention_dste=="" & intervention_ece==.
	replace intervention ="Shelterless Only" if intervention =="" & Shelterless !=""
	replace intervention ="ECE Schools" if emiscode ==16178
*/
	gen overcrowd_girls_DS="Yes" if Doubleshift==1
	drop if tag==1 & master==.													// dropping the EMIS set of 1711 schools
	
		
	replace District ="PISHIN" if District =="Pishin"
	replace District ="USTA MUHAMMAD" if District =="Usta Mohammad"
*	gen overcrowd_girls_DS="Yes" if Doubleshift==1
	replace FunctionalStatus="Functional" if assessment_done==1

*	replace intervention ="" if intervention =="DS_overcrowd_RTSM"
*	replace intervention="" if intervention=="Shelterless Only"
	
*	replace intervention="DS_Girls_RTSM" if intervention=="" & intervention_dste =="Double shift" & nearby_non_functional=="Yes" & Shelterless!="Yes"				//double check - not in proximity analysis
*	tab intervention
/*
           intervention |      Freq.     Percent        Cum.
------------------------+-----------------------------------
               DS + ECE |        994       14.12       14.12
       DS + ECE Schools |      1,996       28.36       42.48
                DS Only |        565        8.03       50.50
          DS_Girls_RTSM |         32        0.45       50.96
               ECE Only |        276        3.92       54.88
            ECE Schools |      1,501       21.32       76.20
              Transport |        262        3.72       79.93
        Transport + ECE |        537        7.63       87.56
Transport + ECE Schools |        876       12.44      100.00
------------------------+-----------------------------------
                  Total |      7,039      100.00

*/
	
*	replace intervention="DS Only" if intervention =="DS_Girls_RTSM"			//Just for the longlist to incorporate an intervention from RTSM field assessment - this should be verified
	
*	tab intervention, missing
	
/*
       intervention |      Freq.     Percent        Cum.
------------------------+-----------------------------------
                        |         38        0.54        0.54
               DS + ECE |        994       14.05       14.58
       DS + ECE Schools |      1,996       28.20       42.79
                DS Only |        597        8.44       51.22
               ECE Only |        276        3.90       55.12
            ECE Schools |      1,501       21.21       76.33
              Transport |        262        3.70       80.03
        Transport + ECE |        537        7.59       87.62
Transport + ECE Schools |        876       12.38      100.00
------------------------+-----------------------------------
                  Total |      7,077      100.00
*/
	drop _merge
*	drop Doubleshift tag shelterless ECE master intervention_dste intervention_ece
	
	tempfile master3
	sa `master3'
	
	import excel "$data\Admin Data\BHCIP\BHCIP_edited.xlsx", sheet("BHCIP 5 Districts Focused schoo") firstrow clear
	
	drop if BEMIS ==. 
	ren BEMIS emiscode 
	gen BHCIP = 1
	keep emiscode BHCIP
	
	tempfile bhcip_1
	sa `bhcip_1'
	
	import excel "$data\Admin Data\BHCIP\Already focused in BHCIP.xlsx", sheet("Sheet1") firstrow clear
	
	gen BHCIP = 1
	keep emiscode BHCIP
	
	append using `bhcip_1'
	
	tempfile bhcip
	sa `bhcip'
	
	
	import excel "$data\Admin Data\STEP B\STEP-B_Baseline_Survey_Flatsheet.xlsx", sheet("STEP-B Baseline Survey") firstrow clear
	
	destring BEMIS, replace
	rename BEMIS emiscode
	gen STEPB = 1
	
	
	keep emiscode STEPB
	tempfile stepb
	sa `stepb'
	 
	append using `bhcip'
	duplicates drop emiscode, force												//dropping one duplicate which was in list of 22 BHCIP as well as STEP B Schools -- Keeping StepB one
	
	merge 1:1 emiscode using `master3'
	
	drop if _merge==1
	drop _merge
	
	list emiscode ECE if BHCIP==1 & (ECE==1 | ECE==2)							//81 schools which are ECE in RTSM and are also part of BHCIP interventions

	/*
      +------------------------+
      | emiscode           ECE |
      |------------------------|
   3. |     1232   ECE Schools |
   8. |     1291   ECE Schools |
  10. |     1294   ECE Schools |
  11. |     1321   ECE Schools |
  21. |     1407   ECE Schools |
      |------------------------|
  23. |     1413   ECE Schools |
  26. |     1424   ECE Schools |
  30. |     1440   ECE Schools |
  33. |     1464   ECE Schools |
  45. |     1541   ECE Schools |
      |------------------------|
  47. |     1549           ECE |
  48. |     1650   ECE Schools |
  52. |     1731   ECE Schools |
  53. |     1732   ECE Schools |
  55. |     1735   ECE Schools |
      |------------------------|
  58. |     1743   ECE Schools |
  60. |     1747           ECE |
  61. |     1752   ECE Schools |
  74. |     1812   ECE Schools |
  92. |     3042   ECE Schools |
      |------------------------|
 108. |     3459   ECE Schools |
 109. |     4841   ECE Schools |
 111. |     4910           ECE |
 112. |     4952   ECE Schools |
 114. |     5020   ECE Schools |
      |------------------------|
 115. |     5021   ECE Schools |
 116. |     5024   ECE Schools |
 117. |     5027   ECE Schools |
 118. |     5029   ECE Schools |
 119. |     5068   ECE Schools |
      |------------------------|
 142. |     6805   ECE Schools |
 147. |     6817   ECE Schools |
 149. |     6824   ECE Schools |
 153. |     6838   ECE Schools |
 154. |     6839           ECE |
      |------------------------|
 155. |     6841   ECE Schools |
 156. |     6844   ECE Schools |
 161. |     9054   ECE Schools |
 166. |     9261   ECE Schools |
 172. |     9642   ECE Schools |
      |------------------------|
 175. |     9843   ECE Schools |
 178. |     9864   ECE Schools |
 179. |     9865   ECE Schools |
 183. |    10020   ECE Schools |
 184. |    10024   ECE Schools |
      |------------------------|
 192. |    10296           ECE |
 194. |    10315   ECE Schools |
 196. |    10383   ECE Schools |
 197. |    10445   ECE Schools |
 199. |    10494   ECE Schools |
      |------------------------|
 203. |    10677   ECE Schools |
 205. |    10761           ECE |
 207. |    10775   ECE Schools |
 209. |    10809   ECE Schools |
 222. |    11881   ECE Schools |
      |------------------------|
 229. |    12141   ECE Schools |
 231. |    12146   ECE Schools |
 238. |    12258   ECE Schools |
 240. |    12698   ECE Schools |
 243. |    12948   ECE Schools |
      |------------------------|
 246. |    12963   ECE Schools |
 251. |    13215   ECE Schools |
 252. |    13315           ECE |
 253. |    13328   ECE Schools |
 258. |    14574           ECE |
      |------------------------|
 260. |    14582           ECE |
 270. |    15355   ECE Schools |
 277. |    15662   ECE Schools |
 281. |    15883   ECE Schools |
 283. |    15967   ECE Schools |
      |------------------------|
 286. |    15986   ECE Schools |
 290. |    16448   ECE Schools |
 293. |    16659   ECE Schools |
 294. |    16664           ECE |
 296. |    17027   ECE Schools |
      |------------------------|
 313. |    17418   ECE Schools |
 316. |    17425   ECE Schools |
 326. |    50019   ECE Schools |
 328. |    50029   ECE Schools |
 331. |    50046   ECE Schools |
      |------------------------|
 333. |    56021   ECE Schools |
      +------------------------+
*/

	list emiscode ECE if STEPB==1 & (ECE==1 | ECE==2)							// 58 schools that have ECE interventions as per RTSM and are also part of STEPB 

/*      +------------------------+
      | emiscode           ECE |
      |------------------------|
   2. |     1226   ECE Schools |
   5. |     1245   ECE Schools |
   7. |     1288   ECE Schools |
  18. |     1403   ECE Schools |
  31. |     1446   ECE Schools |
      |------------------------|
  40. |     1525   ECE Schools |
  42. |     1532   ECE Schools |
  46. |     1545   ECE Schools |
  70. |     1794   ECE Schools |
  73. |     1810   ECE Schools |
      |------------------------|
  79. |     1858   ECE Schools |
  83. |     1915   ECE Schools |
  84. |     1929   ECE Schools |
  89. |     2133   ECE Schools |
  96. |     3355   ECE Schools |
      |------------------------|
  97. |     3358   ECE Schools |
  98. |     3361   ECE Schools |
  99. |     3378   ECE Schools |
 104. |     3416           ECE |
 105. |     3420   ECE Schools |
      |------------------------|
 106. |     3429   ECE Schools |
 120. |     5134   ECE Schools |
 122. |     6605   ECE Schools |
 125. |     6641   ECE Schools |
 126. |     6666   ECE Schools |
      |------------------------|
 127. |     6676   ECE Schools |
 129. |     6721   ECE Schools |
 132. |     6749   ECE Schools |
 135. |     6759   ECE Schools |
 136. |     6760   ECE Schools |
      |------------------------|
 137. |     6763   ECE Schools |
 138. |     6764   ECE Schools |
 141. |     6788   ECE Schools |
 144. |     6812   ECE Schools |
 146. |     6816   ECE Schools |
      |------------------------|
 158. |     9022   ECE Schools |
 165. |     9260   ECE Schools |
 167. |     9417   ECE Schools |
 168. |     9423   ECE Schools |
 181. |     9870   ECE Schools |
      |------------------------|
 186. |    10096   ECE Schools |
 187. |    10114   ECE Schools |
 190. |    10273   ECE Schools |
 195. |    10321   ECE Schools |
 200. |    10497   ECE Schools |
      |------------------------|
 216. |    11498   ECE Schools |
 245. |    12954   ECE Schools |
 248. |    13183   ECE Schools |
 249. |    13186           ECE |
 255. |    14407   ECE Schools |
      |------------------------|
 263. |    14587           ECE |
 264. |    14693   ECE Schools |
 269. |    15247   ECE Schools |
 273. |    15579   ECE Schools |
 285. |    15979   ECE Schools |
      |------------------------|
 298. |    17247   ECE Schools |
 302. |    17293   ECE Schools |
 330. |    50041   ECE Schools |
      +------------------------+
*/

	gen intervention =""
	replace intervention= "DS Only" if intervention_dste=="Double shift" & nearby_non_functional!="Yes" 
	replace intervention = "Transport" if  intervention_dste=="Transport" & nearby_non_functional!="Yes"
	replace intervention = "DS + ECE Schools" if intervention_dste=="Double shift" & intervention_ece ==2 & nearby_non_functional!="Yes" & STEPB!=1 & BHCIP!=1
	replace intervention = "DS + ECE" if intervention_dste=="Double shift" & intervention_ece ==1 & nearby_non_functional!="Yes" & STEPB!=1 & BHCIP!=1
	replace intervention = "Transport + ECE" if intervention_dste=="Transport" & intervention_ece ==1 & nearby_non_functional!="Yes" & STEPB!=1 & BHCIP!=1
	replace intervention = "Transport + ECE Schools" if intervention_dste=="Transport" & intervention_ece ==2 & nearby_non_functional!="Yes" & STEPB!=1 & BHCIP!=1
	replace intervention = "ECE Only" if ECE==1 & intervention =="" & STEPB!=1 & BHCIP!=1
	replace intervention = "ECE Schools" if ECE==2 & intervention =="" & STEPB!=1 & BHCIP!=1
*	replace intervention = "DS Only" if intervention_dste =="Double shift" & intervention=="" & master==1 & ECE==. & nearby_non_functional!="Yes"
*	replace intervention = "Transport" if intervention_dste =="Transport" & intervention=="" & master==1 & ECE==. & nearby_non_functional!="Yes"
	replace intervention ="ECE Schools" if emiscode ==16178	

	replace Shelterless ="Yes" if shelterless==1 & assessment_done ==1
	replace intervention="DS_Girls_RTSM" if Doubleshift ==2 & intervention_dste=="" & intervention_ece==.
*	replace intervention="DS_overcrowd_RTSM" if Doubleshift ==1 & intervention_dste=="" & intervention_ece==.
*	replace intervention ="Shelterless Only" if intervention =="" & Shelterless !=""
*	replace intervention ="" if intervention =="DS_overcrowd_RTSM"				//30 obs
*	replace intervention="" if intervention=="Shelterless Only"tab
	
	replace intervention="DS_Girls_RTSM" if intervention=="" & intervention_dste =="Double shift" & nearby_non_functional=="Yes" & Shelterless!="Yes" & Doubleshift ==2				//double check 18 observations- not in proximity analysis
	replace intervention="DS_Girls_RTSM" if Doubleshift ==2 & intervention=="" & (STEPB==1 | BHCIP==1)

	replace intervention="DS Only" if intervention =="DS_Girls_RTSM"			//Just for the longlist to incorporate an intervention from RTSM field assessment - this should be verified

	tab intervention, missing
/*	
          intervention |      Freq.     Percent        Cum.
------------------------+-----------------------------------
                        |        115        1.62        1.62
               DS + ECE |        952       13.45       15.08
       DS + ECE Schools |      1,915       27.06       42.14
                DS Only |        729       10.30       52.44
               ECE Only |        265        3.74       56.18
            ECE Schools |      1,426       20.15       76.33
              Transport |        364        5.14       81.48
        Transport + ECE |        492        6.95       88.43
Transport + ECE Schools |        819       11.57      100.00
------------------------+-----------------------------------
                  Total |      7,077      100.00

*/	
	drop if intervention =="" & (ECE ==1|ECE==2) & assessment_done ==1 & Doubleshift ==. & overcrowd_girls_DS =="" & Shelterless ==""
*	drop intervention_dste intervention_ece master shelterless ECE Doubleshift tag
	tab intervention, missing
	
	/*
			intervention |      Freq.     Percent        Cum.
	------------------------+-----------------------------------
							|         63        0.90        0.90
				   DS + ECE |        952       13.55       14.45
		   DS + ECE Schools |      1,915       27.26       41.71
					DS Only |        729       10.38       52.09
				   ECE Only |        265        3.77       55.86
				ECE Schools |      1,426       20.30       76.16
				  Transport |        364        5.18       81.34
			Transport + ECE |        492        7.00       88.34
	Transport + ECE Schools |        819       11.66      100.00
	------------------------+-----------------------------------
					  Total |      7,025      100.00

	*/	
	
	tempfile PMU_shortlist
	sa `PMU_shortlist'
	
	*cleaning UC var
	
	*estpost tab District ///
	esttab using "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Data\Analysis\Misc\schools_by_district.csv", ///
    cells("b pct(fmt(2))") unstack nonumber nomtitle noobs replace

	*estpost tab District intervention ///
	esttab using "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Data\Analysis\Misc\district_by_intervention.csv", ///
    cells("b") unstack nonumber nomtitle noobs replace
	
	replace UC = strtrim(UC)
	
		* Ensure consistent case first
	replace UC = upper(UC)

	* Standardize UC names
	replace UC = "AHMADI DARGA" if inlist(UC,"AHMDI DERGA","AHMADI DARGA")

	replace UC = "AIRI ANDROON" if inlist(UC,"AIRY ANDROON","AIRI ANDROON")

	replace UC = "ALLAHABAD" if inlist(UC,"ALLAH ABAD","ALLAHABAD")

	replace UC = "ANJEERA" if inlist(UC,"ANJIRA","ANJEERA")

	replace UC = "ARANJI" if inlist(UC,"ARRANJI","ARANJI")

	replace UC = "BAGHAO" if inlist(UC,"BAGHAOO","BAGHAO")

	replace UC = "BEEH" if inlist(UC,"BEEH","BEEH ")

	replace UC = "CHAPPAR" if inlist(UC,"CHAPAR","CHAPPAR")

	replace UC = "CHIB KALMATI" if inlist(UC,"CHEB KALMATI","CHIB KALMATI")

	replace UC = "DRAKHALA" if UC=="DRAKHALA"

	replace UC = "GOMZAI" if inlist(UC,"GOMAZI","GOMZAI")

	replace UC = "KOHBUN" if inlist(UC,"KOHBON","KOHBUN")

	replace UC = "LAHORE" if UC=="LAHORE"

	replace UC = "LAJWAR SYEDAN" if UC=="LAJWAR SYEDAN"

	replace UC = "MALIKI" if inlist(UC,"MALKI","MALIKI")

	replace UC = "MANJHOTI" if inlist(UC,"MANJHOOTI","MANJHOTI")

	replace UC = "MANNA" if UC=="MANNA"

	replace UC = "MC NAAL" if inlist(UC,"MC NALL","MC NAAL")

	replace UC = "GADDANI" if inlist(UC,"GADDANI","GADANI TWON","GADANI TOWN")

	replace UC = "HATHYARI" if inlist(UC,"HATHYARI","HATIARY")

	replace UC = "INAYAT ULLAH KAREZ" if inlist(UC,"INAYAT ULLAH KAREZ","INYATULLAH KARAIZ")
	
	replace UC = "ISKALKO" if inlist(UC,"ISKALKO","ASKALKO")

	replace UC = "GISHKORE" if inlist(UC,"GISHKOR","GISHKORE")
	
	replace UC = "HANNA" if inlist(UC,"HANNA","HANNA (H-65)","U/C 65, HANNA")

	replace UC = "NOOR PUR" if inlist(UC,"NOOR POOR","NOORPUR","NOOR PUR")

	replace UC = "NORAK" if inlist(UC,"NORAK","NOURAK")

	replace UC = "PALLERI" if inlist(UC,"PALLERI","PALLERY","PALLIREE")

	replace UC = "PAROOM" if inlist(UC,"PAROME","PAROOM")

	replace UC = "PHELLAWAGH" if inlist(UC,"PHELAWAGH","PHELLAWAGH")

	replace UC = "PHESHI KAPAR" if inlist(UC,"PEESHI KAPPER","PHESHI KAPAR")

	replace UC = "QABOOLA" if inlist(UC,"QABOOLA","QABULA")

	replace UC = "QILLA VIALA" if inlist(UC,"QILLA VIALA","QILLA VILLA")

	replace UC = "RAMZAY PUR" if inlist(UC,"RAMZAY PUR","RAMZE PUR")

	replace UC = "SADDAR MUSLIM BAGH" if inlist(UC,"SADAR MUSLIM BAGH","SADDAR MUSLIM BAGH")

	replace UC = "SEGAI" if inlist(UC,"SEGAI","SEGI")

	replace UC = "SHABUK NAREEN" if inlist(UC,"SHABUK NAREEN","SHABUK NARINE")

	replace UC = "SHIN GHAR SOUTH 1" if inlist(UC,"SHIN GHAR SOUTH 1","SHING GHAR SOUTH 1")

	replace UC = "SORI MEHTERZAI" if inlist(UC,"SORI MEHTERZAI","SORIMEHTERZAI")

	replace UC = "SOTGAN" if inlist(UC,"SOTAGAN","SOTGAN")

	replace UC = "THUL" if inlist(UC,"THUL","THULL")

	replace UC = "TOR SHAH" if inlist(UC,"TOR SHAH","TORA SHAH")

	replace UC = "TOWN" if inlist(UC,"TOWAN","TOWN")

	replace UC = "WALA AKRAM" if inlist(UC,"WALA AKRAM","WALLA AKRAM")

	replace UC = "WAYARA" if inlist(UC,"WAYARA","WAYARO")

	replace UC = "WIALA AGHBARG" if inlist(UC,"VIYALA  AGHBARG","WIALA AGHABARG","WIALA AGHBARG","WIALA AGHBARG 1","WIALA AGHBARG1")

	replace UC = "YAT GARH" if inlist(UC,"YAT GARH","YET GARH")

	replace UC = "ZARKHO" if inlist(UC,"ZARKHO","ZARKHU")

	recast str15 UC

	*estpost tab UC ///
	esttab using "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Data\Analysis\Misc\schools_by_uc.csv", ///
    cells("b pct(fmt(2))") unstack nonumber label nomtitle noobs replace

	*estpost tab UC intervention ///
	esttab using "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Data\Analysis\Misc\uc_by_intervention.csv", ///
    cells("b") unstack nonumber label nomtitle noobs replace
	
	save "$data\Dataset\admin\long_list.dta", replace							//saving .dta file 
	export delimited using "$data\Dataset\admin\long_list.csv", replace			//saving the csv file
	
	drop if assessment_done == 1 
	
	preserve
	gen count = 1
	collapse (sum) count, by(UC) 
	 histogram count, frequency addlabel addlabopts(mlabsize(tiny) mlabangle(forty_five)) xtitle("Count of Schools") title("Schools by UCs") note("N UCs = 1040; Bin size = 5 schools")
	 tab count
	  graph export "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Data\Analysis\Misc\schools_by_ucs.png", as(png) name("schools_by_ucs"), replace
	restore
	
	

	
	