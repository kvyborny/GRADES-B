*Author: Hijab Waheed
*Date: 24-10-2025
*Purpose: School list

***Globals

	if c(username) == "wb635947" {
		
		global data "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Data"
		
	}
	
	if c(username) != "" {
		
		// Please add your file path accordingly
		
	}

***Clean EMIS data 
		
	clear
	import excel "$data\Admin Data\EMIS Data\Balochistan EMIS Flatsheet 2024-25.xlsx", sheet("16-8-25") firstrow clear
	//15362 obs
	
	*Tehsil cleaning
	replace Tehsil = strtrim(itrim(Tehsil))
	replace Tehsil = subinstr(Tehsil, char(160), " ", .)   // non-breaking spaces
	replace Tehsil = strtrim(itrim(Tehsil))
	replace Tehsil = upper(Tehsil)
	replace Tehsil = strtrim(itrim( ///
		subinstr(subinstr(subinstr(Tehsil, ".", "", .), ",", "", .), ";", "", .) ///
	))
	replace Tehsil = strtrim(itrim(Tehsil))

	replace Tehsil = "PHELLAWAGH" if inlist(Tehsil,"PAHILAWAGH","PHAILAWAGH","PHEALWAGH","PHELAWAG","PHEWALG","PIHLAWAGH")
	replace Tehsil = "PANHWAR" if inlist(Tehsil,"PANHWER","PANHAWAR","PANHWAR","PANHWAR ","PANHWERSANR", "PANHWERSANRE")
	replace Tehsil = "JHAT PAT" if inlist(Tehsil,"JHATPAT","JHAT PAT ")
	replace Tehsil = "DERA MURAD JAMALI" if inlist(Tehsil,"D M JAMALI","D.M.JAMALI","DERA MURAD JAMALI")
	replace Tehsil = "GHAFOORABAD" if inlist(Tehsil,"GHAFOOR ABAD","GHAFOORABAD","GHAFOORABAD ")
	replace Tehsil = "DALBANDIN" if inlist(Tehsil,"DALBANDIN ","DALBANDIN")
	replace Tehsil = "BABAKOT" if inlist(Tehsil,"BABAKOT","BAB KOT","BABA KOT","BABKOT")
	replace Tehsil = "NALL" if inlist(Tehsil,"NAL","NALL")
	replace Tehsil = "SOONMIANI (WINDER)" if strpos(Tehsil,"SOONMIANI")>0 & strpos(Tehsil,"WINDER")>0 | inlist(Tehsil,"SUNNI")
	replace Tehsil = "FAREEDABAD" if inlist(Tehsil,"FAREEDABAD ","FAREED ABAD","FARIDABAD","FARIDABAD ","FAREDABAD","FAREED","FREED ABAD")
	replace Tehsil = "KILLA SAIFULLAH" if inlist(Tehsil,"QILLA SAIFULLAH","KILLA SAIFULLAH")
	replace Tehsil = "BARSHORE" if Tehsil == "BARSHOR"
	replace Tehsil = "CHATTER" if Tehsil == "CHATTAR"
	replace Tehsil = "DASHT" if Tehsil == "DASTH"
	replace Tehsil = "DERA MURAD JAMALI" if Tehsil == "DMJAMALI"
	replace Tehsil = "GWARGO" if inlist(Tehsil,"GAWARGO","GAWARO")
	replace Tehsil = "HAIRDIN" if inlist(Tehsil,"HAIR DIN","HAIR DEEN","HAIR DAN","HAIRDIN")
	replace Tehsil = "JHAL MAGSI" if inlist(Tehsil,"JHALJAOO","JHAL JHAOO")
	replace Tehsil = "KHUCHLAK" if inlist(Tehsil,"KUCHLAK")
	replace Tehsil = "LIARI" if inlist(Tehsil,"LEYARI")
	replace Tehsil = "MANGOCHER" if inlist(Tehsil,"MANGOCHAR","MANGUCHER","MUNGOCHER")
	replace Tehsil = "MANJHI PUR" if inlist(Tehsil,"MANHJI PUR","MANJI PUR","MANJHI PURR","MANJYPUR")
	replace Tehsil = "MASHKAI" if inlist(Tehsil,"MASHKAY","MASHKEL","MASHKHEL")
	replace Tehsil = "MAWAND" if Tehsil == "MAWIND"
	replace Tehsil = "MEHRABAD" if Tehsil == "MEHR ABAD"
	replace Tehsil = "MUSAKHEL" if Tehsil == "MUSA KHAIL"
	replace Tehsil = "NANA SAHIB" if strpos(Tehsil,"NANA") & strpos(Tehsil,"SAHIB") | inlist(Tehsil,"NANA SAB","NANA SAHAB")
	replace Tehsil = "PANJGUR" if Tehsil == "PANJUR"
	replace Tehsil = "SAEED MUHAMMAD" if strpos(Tehsil,"SAEED") | strpos(Tehsil,"SAID")
	replace Tehsil = "SOHBATPUR" if inlist(Tehsil,"SOHBAT PUR")
	replace Tehsil = "TOISAR" if inlist(Tehsil,"TOI SER")
	replace Tehsil = "DUKI" if inlist(Tehsil,"DUKITHAL CHUTHYALI")
	replace Tehsil = "GIDDER" if inlist(Tehsil,"GIDDAR")
	replace Tehsil = "LAKHRA" if inlist(Tehsil,"LAKHTRA")
	replace Tehsil = "MACH" if inlist(Tehsil,"MACH BOLAN")
	replace Tehsil = "MEKHTAR" if inlist(Tehsil,"MEKHATR")
	replace Tehsil = "QILLA ABDULLAH" if inlist(Tehsil,"QILLA ABDULLAH (Q124)")
	replace Tehsil = "QUETTA" if inlist(Tehsil,"QUETA","QUTTA CITY","QUETTA CITY","QUUETTA")
	replace Tehsil = "SARANAN" if inlist(Tehsil,"SAR KHARAN","SARANANA")
	replace Tehsil = "MIR HASSAN" if inlist(Tehsil,"MEER HASSAN")
	
	replace Tehsil ="" if inlist(Tehsil,"0","SUB TEHSIL SUFAID", "NOT EXISTING","BITTI", "SARIAB")


	*Clean UC
	
	replace UC = strtrim(itrim(UC))
	replace UC = subinstr(UC, char(160), " ", .)   // non-breaking spaces
	replace UC = strtrim(itrim(UC))
	replace UC = upper(UC)
	replace UC = strtrim(itrim( ///
		subinstr(subinstr(subinstr(UC, ".", "", .), ",", "", .), ";", "", .) ///
	))
	replace UC = strtrim(itrim(UC))
	replace UC = subinstr(UC, "/", " ", .)
	replace UC = subinstr(UC, "-", " ", .)
	replace UC = strtrim(itrim(UC))

	replace UC = regexr(UC, "^(M\\s*C\\s*ORP\\s*)", "")      // MCORP / M CORP
	replace UC = regexr(UC, "^(M\\s*C\\s*)", "")            // MC / M C / M.C
	replace UC = regexr(UC, "^(U\\s*C\\s*)", "")            // UC / U C / U/C
	replace UC = regexr(UC, "^[0-9]+\\s*", "")              // leading numbers (e.g., "65 HANNA")
	replace UC = ustrregexra(UC, "\s*[0-9]+$", "")          // ending numbers
	replace UC = regexr(UC, "^[0-9]+\\s*,\\s*", "")         // leading "65, "
	replace UC = ustrregexra(UC, "^(UNION\s*COUNCIL|UNIONCOUNCIL)\s*", "")
	replace UC = ustrregexra(UC, "^(U\s*C|UC)\s*NO?\s*[0-9]{1,3}\s*", "")     // remove "UC 65", "U C NO07", etc.
	replace UC = ustrregexra(UC, "^(U\s*C|UC)\s*", "")                        // remove remaining "UC"
	replace UC = ustrregexra(UC, "^\(?H\s*[0-9]{1,3}\)?\s*", "")              // if something starts with "H 65"
	replace UC = ustrregexra(UC, "\(\s*H\s*[0-9]{1,3}\s*\)", "")              // drop "(H 65)" from name
	replace UC = strtrim(itrim(UC))
	replace UC = ustrregexra(UC, "^[0-9]{1,3}\s+", "")

	
	replace UC = "DERA MURAD JAMALI SHARQI" if UC == "DMJAMALI SHARQI" | UC == "D M JAMALI SHARQI" | UC == "DM JAMALI SHARQI"
	replace UC = "DERA MURAD JAMALI GHARBI" if UC == "DMJAMALI GHARBI" | UC == "D M JAMALI GHARBI" | UC == "DM JAMALI GHARBI"
	replace UC = "DERA MURAD JAMALI" if strpos(UC,"DERA MURAD JAMALI")>0
	replace UC = "GOL MASJID" if inlist(UC, "GOAL MASJID", "GOOL MASJID", "GOLL MASJID")
	replace UC = "LIAQUAT BAZAR" if inlist(UC, "LIAQAT BAZAR", "LIAQUAT BAZAR", "U C 3 LIAQAT BAZAR", "U C 3 LIAQUAT BAZAR")
	replace UC = "NAWA KILLI" if inlist(UC, "NAWAKILLI", "NAWA KILLI")
	replace UC = "SHARA E IQBAL" if strpos(UC, "SHAHRE") | strpos(UC, "SHARA") & strpos(UC, "IQBAL")
	replace UC = "DERA MURAD JAMALI SHARQI" if inlist(UC,"D M JAMALI SHARQI","DMJAMALI SHARQI","D M JAMALI SHARQI ","D M JAMALI SHARQI  ")
	replace UC = "DERA MURAD JAMALI GHARBI" if inlist(UC,"D M JAMALI GHARBI","DMJAMALI GHARBI","M JAMALI GHARBI","D M JAMALI GHARBI ","D M JAMALI GHARBI  ")
	replace UC = "DERA MURAD JAMALI"        if inlist(UC,"DMJAMALI","D M JAMALI","D M JAMALI ")
	replace UC = "WADH" if strpos(UC, "WADH")>0
	replace UC = "WASHUK" if strpos(UC, "WASHUK")>0
	replace UC = "ZERINA WAHIR" if inlist(UC, "ZEREENA WAHEER",  "ZERENA WAHAIR",  "ZEREENA WAHER", "ZERENA WAHER", "ZERINA WAHEER", "ZERINA WAHAIR", "ZERINA WAHIR", "ZERINA WAHAIR")
	replace UC = "ZERINA KHATTAN" if inlist(UC, "ZERINAKATTAN","ZERINAKHATTAN","ZERINAKHATAN", "ZERINA KATTAN")
	replace UC = "LIAQUAT BAZAR" if inlist(UC, "LIAQAT BAZAR", "U C 3 LIAQAT BAZAR", "U C 3 LIAQUAT BAZAR") 
	replace UC = "MUSAFAR PUR" if inlist(UC, "MUSAFAR POOR", "MUSAFAR PUR", "MUSAFER PUR", "MUSAFIR PUR", "MUSAFUR PUR")
	replace UC = "NALI YASEENZAI" if inlist(UC, "NALI YASEENZAI", "NALI YASIN ZAI")
	replace UC = "NARAZAI" if inlist(UC, "NARAZAI", "NAREZAI") 
	replace UC = "NOOR PUR" if inlist(UC, "NOOR POOR", "NOOR PUR", "NOORPUR")
	replace UC = "SASOL" if inlist(UC, "SASOL", "SASOOL")
	replace UC = "OUNARRA" if inlist(UC, "OUNARRA", "UONARRA")
	replace UC = "URYANI" if inlist(UC, "ORAYNI", "ORIYANI", "ORYANI", "URYANI")
	replace UC = "PAZZA" if inlist(UC, "UC PAZZA", "UC PAZZA ", "UC PAZZA", "UC PAZZA") | lower(UC)=="uc pazza"
	replace UC = "ANDARPUR" if inlist(UC, "ANDARPUR", "ANDER PUR")
	replace UC = "SORO" if inlist(UC, "SORO", "SORO ")
	replace UC = "LOAP" if inlist(UC, "LOAP", "LOOP")
	replace UC = "KANJAR" if inlist(UC, "KANJIER", "KANJERR", "KANJAR")
	replace UC = "PHESHI KAPAR" if inlist(UC, "PHESHI KAPAR", "PHESHI KAPA", "PEESHI KAPPER") 
	replace UC = "ZEEDI" if inlist(UC, "ZEEDI", "ZEDI")
	replace UC = "LIAQUAT BAZAR" if inlist(UC, "LIAQAT BAZAR", "LIAQUAT BAZAR")
	replace UC = "MA JINNAH" if inlist(UC, "MA JINNAH R", "MA JINNAH", "MA JINNAH ROAD", "MA JINNAH R" )
	replace UC = "AHMADI DARGA" if inlist(UC, "AHMDI DERGA", "AHMDI DARGA", "AHMADI DERGA")
	replace UC = "AHMED KHAN ZAI" if inlist(UC, "AHMED KHANZAI", "AHMED KHAN ZAI")
	replace UC = "AHMED WAL" if inlist(UC, "AHMED WALL", "AHMED WAL")
	replace UC = "ANJEERA" if inlist(UC, "ANJEERA", "ANJIRA",  "ANJEERI NUMBBER 1 KHAD KOCHA")
	replace UC = "AKBARABAD" if inlist(UC, "AKBERABAD", "AKBARABAD")
	replace UC = "AKHTARZAI" if inlist(UC, "AKHTERZAI", "AKHTARZAI KILLA SAIFULLAH", "AKHTARZAI")
	replace UC = "ALI ABAD" if inlist(UC, "ALIABAD", "ALI ABAD")
	replace UC = "ALI ABAD SHUMALI" if inlist(UC, "ALIABAD SHUMALI", "ALI ABAD SHUMALI")
	replace UC = "ANAM BOSTAN" if inlist(UC, "ANAMBOSTAN", "ANAM BOSTAN")
	replace UC = "ANDARPUR" if inlist(UC, "ANARPUR", "ANDARPUR", "ANDER PURH", "ANDRPUR","ANDURPUR")
	replace UC = "AHMEDABAD" if inlist(UC, "AHMED ABAD", "AHMEDABAD")
	replace UC = "ALLAH ABAD" if inlist(UC, "ALLAHABAD", "ALLAH ABAD")
	replace UC = "ASIF ABAD"  if inlist(UC, "ASIFABAD", "ASIF ABAD")
	replace UC = "FAIZABAD"   if inlist(UC, "FAIZ ABAD", "FAIZABAD")
	replace UC = "HAMID PUR"  if inlist(UC, "HAMIDPUR", "HAMID PUR")
	replace UC = "AKHTARZAI" if inlist(UC, "AKHTERZAI", "AKHTARZAI")
	replace UC = "ALIKHAIL"  if inlist(UC, "ALI KHAIL", "ALIKHAIL")
	replace UC = "BADAN ZAI" if inlist(UC, "BADAN ZAI", "BADENZAI", "BADEZAI")
	replace UC = "GADAKHAIL" if inlist(UC, "GADA KHAIL", "GADAI KHAIL", "GADI KHAIL", "GADAKHAIL", "GHADAKHAIL", "GHADA KHAIL")
	replace UC = "KHATTAN" if inlist(UC, "KHATTAN", "KATTAN")
	replace UC = "BALINA KHATTAN" if inlist(UC, "BALINA KHATTAN", "BALINA KATTAN")
	replace UC = "CHAD SHER ALI" if inlist(UC, "CHAD SHAIR ALI", "CHAD SHAR ALLI GUDDER", "CHAD SHER ALI",  "CHAID SHAIR ALI")
	replace UC = "BAGHAOO" if inlist(UC, "BAGHAO", "BAGHAOO", "BAGHAW")
	replace UC = "BALELI" if inlist(UC, "BALELEE", "BALELI", "BALELLI")
	replace UC = "BALNIGORE" if inlist(UC, "BALNEGORE", "BALNIGORE")
	replace UC = "BEDAR ANDROON" if inlist(UC,  "BEDAR ANDRON", "BEDAR ANDROON", "BEDAR UNDROON")
	replace UC = "DILSORA" if inlist(UC, "DILSORA", "DILSORA CHURMIAN")
	replace UC = "DIRGHI" if inlist(UC, "DIRGHI", "DIRGI")
	replace UC = "DRACHKO" if inlist(UC, "DRACHKO", "DARACHKO")
	replace UC = "DURUG" if inlist(UC, "DRUG", "DURUG")
	replace UC = "ESHANI" if inlist(UC, "ESHANI", "ESSAI", "EISSAI")
	replace UC = "GAZGI" if inlist(UC, "GAZG", "GAZGI")
	replace UC = "GHAIZ" if inlist(UC, "GHAIZ", "GHAIZH")
	replace UC = "GHERSHINAN" if inlist(UC, "GHARSHINAN", "GHERSHINAN", "GHERSNI")
	replace UC = "GORNARI" if inlist(UC,   "GORANARI",  "GORANI", "GORNARE", "GORNARHI",  "GORNARIE",  "GORNARI")
	replace UC = "HADERO" if inlist(UC, "HADEERA", "HADEERO", "HADERO", "HADIRO")
	replace UC = "HATIARY" if inlist(UC, "HATHYARI", "HATIARY")
	replace UC = "INAYAT ULLAH KAREZ" if inlist(UC,  "INAYAT ULLAH KAREEZ",  "INAYAT ULLAH KAREZ", "INYATULLAH KARAIZ")
	replace UC = "ISKALKO" if inlist(UC, "ISKALKO", "ISKALKOO")
	replace UC = "JHAT PAT" if inlist(UC, "JHAT PAT", "JHATPAT")
	replace UC = "JHUDAIR" if inlist(UC, "JHUDAIR", "JUDAIR", "JUDHAIR")
	replace UC = "KAN MEHTARZAI" if inlist(UC, "KAN MEHTARZAI", "KAN MEHTERZAI")
	replace UC = "KHAROOS WAH" if inlist(UC,  "KHAROOS WAH", "KHAROOSH WAH", "KHAROS WAH", "KHAROSWAH")
	replace UC = "LAWARA" if inlist(UC, "LAWARA", "LAWARAH", "LAWARH")
	replace UC = "LOPE PATRA" if inlist(UC, "LOPE PATARA", "LOPE PATRA", "LOP PATRA")
	replace UC = "ZEHRA ZAI" if inlist(UC, "ZEHRAZAI")
	replace UC = "ZARKHU" if inlist(UC, "ZARKH", "ZARKHO")
	replace UC = "YAT GARH" if inlist(UC, "YET GARH")
	replace UC = "YARU" if inlist(UC, "YAROO", "YARO")
	replace UC = "YARU II" if inlist(UC, "YARO II")
	replace UC = "WELPAT SHUMALI" if inlist(UC, "WELPAT SHOMALI", "WELPAT SHUMALI")
	replace UC = "WIALA AGHBARG" if inlist(UC, "WIALA AGHABARG", "WIALA AGHBARG")
	replace UC = "WAYARA" if inlist(UC, "WAYARA", "WAYARO")
	replace UC = "QILLA VIALA" if inlist(UC, "QILLA VIALA", "QILLA VILLA")


	
	replace UC = "" if inlist(UC, ".", "N/A", "NA", "NOT EXISTING", "NULL", "NONE")
	replace UC = "" if inlist(UC, "(MANI KHAWA )", "0", "21", "37", "48", "AAA")
	

***Prepare EMIS with coordinates***
	//EMIS
	//15362 obs

	rename BemisCode BEMIS

	merge 1:1 BEMIS using "$data\Dataset\admin\bemis_coordinates.dta", keepusing(GPSY GPSX) // Merge coordinates from another file
	rename _merge _merge1
	drop if _merge1 == 2
	//13220 matched
	
	merge 1:1 BEMIS using "$data\Dataset\admin\bemis_coordinates_1.dta", keepusing(GPSY GPSX) update //  Merge coordinates from another file
	rename _merge _merge2
	//15362
	
	keep if GPSX !=. // dropping the schools for which we do not have coordinates
	//14778
	
	destring, replace
	keep BEMIS SchoolName District Tehsil SubTehsil UC VillageName SchoolContactNo Location Genderupdated SchoolLevel Shift GPSY GPSX // keeping important vars only (for the purpose of python code only)
	
	
	*working
	*stepb schools
	merge 1:1 BEMIS using "$data\Dataset\gradesb\stepsb.dta", keepusing (BEMIS)
	rename _merge merge_stepb
	gen stepb = 1 if merge_stepb == 3

	
	*
	sort Tehsil
	by Tehsil: gen girls_n = sum(Genderupdated != "Boys" & SchoolLevel == "Primary" & stepb!=1)
	replace girls_n = . if !(Genderupdated != "Boys" & SchoolLevel == "Primary" & stepb!=1)

	//atleast 1 girls/co edu school primary level school which is not a stepb school in 107 (out of 120) tehsils 
	
	bys Tehsil: egen girls_n_count = count( girls_n)
	
	// min 1 school (2 tehsils) and max 175 

	br Tehsil girls_n girls_n_count Genderupdated SchoolLevel stepb 
	
	
	*collapse girls_n_count, by(Tehsil)

	
	sort UC
	by UC: gen girls_n_uc = sum(Genderupdated != "Boys" & SchoolLevel == "Primary" & stepb!=1)
	replace girls_n_uc = . if !(Genderupdated != "Boys" & SchoolLevel == "Primary" & stepb!=1)

	//atleast 1 girls/co edu school primary level school which is not a stepb school in 919 (out of 1438) UCs 
	
	bys UC: egen girls_n_count_uc = count( girls_n_uc)
	
	// min 1 school and max 47 

	br UC girls_n_uc girls_n_count_uc Genderupdated SchoolLevel stepb
	
	
	collapse girls_n_count_uc, by(UC)
	
	save "$data\Dataset\admin\emis_data.dta", replace
	export excel using "$data\Dataset\admin\emis_data.xlsx", firstrow(variables) replace



***GRADES B data clean, merge, and save***
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
	bysort BEMIS: gen dup_id = _n
	keep if dup_id == 1 // Remove duplicates 
	
	rename U govt_own_building
	rename V space_construction
	rename W space_construction_specify
	rename X land_available
	rename Y donate_land 
	rename Z play_area
	
	egen total_girls_PS = rowtotal (BG BH BI BJ BK BL)
	egen total_boys_PS = rowtotal (Kachi Class1 Class2 Class3 Class4 Class5)
	gen gender_ratio = total_boys_PS/total_girls_PS
	
	save "$data\Dataset\gradesb\gradesb.dta", replace
	
	/*
	*merge surveyauto database
	rename BEMIS EMISCode
	merge 1:1 EMISCode using "$data\Dataset\Database\database.dta"
	rename _merge merge_database
	
	keep if merge_database == 1 | merge_database == 3
	
	save "$data\Dataset\gradesb\gradesb_surveyauto.dta", replace
	*/
***STEP B data***
	import excel "$data\Admin Data\STEP B\STEP-B_Baseline_Survey_Flatsheet.xlsx", sheet("STEP-B Baseline Survey") firstrow clear
	
	isid BEMIS
	destring BEMIS, replace force
	
	save "$data\Dataset\gradesb\stepsb.dta", replace
	

***Python data output save***

	*Import the output file and save as .dta file
	import delimited "$data\Dataset\nearest_girls_school\closest_schools.csv", clear
	rename schoolemiscode BEMIS
	save "$data\Dataset\nearest_girls_school\closest_schools.dta", replace


***EMIS data***

	import excel "$data\Admin Data\EMIS Data\Balochistan EMIS Flatsheet 2024-25.xlsx", sheet("16-8-25") firstrow clear

	rename BemisCode BEMIS
	destring, replace //Destring BEMIS for merging
	duplicates report BEMIS

	*merge with the output file of python for the closest schools coordinates*

	merge 1:1 BEMIS using "$data\Dataset\nearest_girls_school\closest_schools.dta", keepusing(schoolname gender schoollatitude schoollongitude closestschool closestschoolemiscode closestschoollatitude closestschoollongitude distancekm)
	rename _merge merge_closestschool

	*merge with the GRADES B data*
	
	merge 1:1 BEMIS using "$data\Dataset\gradesb\gradesb.dta", keepusing(Istheschoolfunctional total_girls_PS total_boys_PS gender_ratio govt_own_building space_construction space_construction_specify land_available donate_land play_area)
	rename _merge merge_gradesb
	
	*merge with STEPS B data*
	
	merge 1:1 BEMIS using "$data\Dataset\gradesb\stepsb.dta", keepusing (BEMIS)
	rename _merge merge_stepb
	
	gen stepb = 1 if merge_stepb == 3
	
	*merge with the SurveyAuto database*
	rename BEMIS EMISCode
	merge 1:1 EMISCode using "$data\Dataset\Database\database.dta"
	rename _merge merge_database

	*Cleaning*

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
	

	*Demand > Capacity for  school
	local St KBSt KGSt PBSt PGSt TwoBSt TwoGSt ThreeBSt ThreeGSt FourBSt FourGSt FiveBSt FiveGSt //
	destring *St, replace
	
	local lvl K P Two Three Four Five
	foreach var of local lvl  {
		gen enrollment_`=lower("`var'")' = `var'BSt + `var'GSt
	}
	
	egen mean_enrol = rowmean(enrollment_k enrollment_p enrollment_two enrollment_three enrollment_four enrollment_five)
	gen enrollment_40_G = 1 if mean_enrol > 40 & Genderupdated == "Girls"
	gen enrollment_40_B = 1 if mean_enrol > 40 & Genderupdated == "Boys"
	gen enrollment_60_G = 1 if mean_enrol > 60 & Genderupdated == "Girls"
	gen enrollment_60_B = 1 if mean_enrol > 60 & Genderupdated == "Boys"
	
	*Boys schools with <5 girls 
	egen mean_enrol_g = rowmean(KGSt  PGSt  TwoGSt  ThreeGSt  FourGSt  FiveGSt)
	gen enrollment_5_B = 1 if mean_enrol_g <=5  &  Genderupdated == "Boys"
	
	egen mean_enrol_b = rowmean(KBSt  PBSt  TwoBSt  ThreeBSt  FourBSt  FiveBSt)
	gen ratio_gender_emis = mean_enrol_b/mean_enrol_g
	
	*Nearest girls school is more than 1km away
	destring distancekm, replace force
	gen nearest_girls_school_1km = 1 if distancekm >= 1
	
	*HQ districts
	gen dis = 1 if District == "QUETTA " | District == "KALAT" | District == "KECH" | District == "SIBI" | District == "ZHOB" | District == "NASEER ABAD" | District == "KHARAN"
	
	*OOSC
	count if enrollment_40_G == 1  & nearest_girls_school_1km == 1
	gen OOSC_female_per = (OOSCFemale/SchoolAgePopulationFemale )*100
	
	*DS
	gen DS = 1 if enrollment_5_B == 1   & nearest_girls_school_1km == 1 

	
	*Distance between school and centroid
	
	geodist schoollatitude schoollongitude centroid_latitude centroid_longitude , generate(dist_school_centroid)
	gen Trans = 1 if dist_school_centroid >1.5 & Genderupdated == "Girls" & mean_enrol_g != 0
	
	geodist centroid_latitude centroid_longitude closestschoollatitude closestschoollongitude, generate(dist_centreoid_nearestgirlschool)
	
	count if DS == 1 & dist_centreoid_nearestgirlschool >1.5 & nearest_girls_school_1km == 1
	
	*Closest girls schools to selected boys school for transport 
	
	preserve
	 
	gen closestschoolemiscode1 = closestschoolemiscode if dist_centreoid_nearestgirlschool >1.5 & nearest_girls_school_1km == 1 & closestschoolemiscode !=.  
	bysort closestschoolemiscode1: gen dup_id_trans = _n
	keep if dup_id_trans == 1
	keep if closestschoolemiscode1 !=.
	drop EMISCode
	rename closestschoolemiscode EMISCode

	tempfile transport_girls
	save `transport_girls'
	
	restore 
	
	merge 1:1 EMISCode using `transport_girls', keepusing (dup_id_trans)
	rename _merge merge_transport_girls
	gen transport_girls = 1 if merge_transport_girls == 3

	
	***Sample count***
	
	*Double shift 
	
	count if DS == 1 
	count if DS == 1 & dist_centreoid_nearestgirlschool >1.5 & nearest_girls_school_1km == 1 // DS + Trans 
	
	count if DS == 1 & SpaceForNewRooms == "Yes" 
	count if DS == 1 & FunctionalStatus == "Functional" 
	count if DS == 1 & stepb !=1
	count if DS == 1 & SpaceForNewRooms == "Yes" & stepb !=1

	count if DS == 1 & dist_centreoid_nearestgirlschool >1.5 & nearest_girls_school_1km == 1 & SpaceForNewRooms == "Yes" 
	count if DS == 1 & dist_centreoid_nearestgirlschool >1.5 & nearest_girls_school_1km == 1 & FunctionalStatus == "Functional"  
	count if DS == 1 & dist_centreoid_nearestgirlschool >1.5 & nearest_girls_school_1km == 1 & stepb !=1
	count if DS == 1 & dist_centreoid_nearestgirlschool >1.5 & nearest_girls_school_1km == 1 & stepb !=1 & SpaceForNewRooms == "Yes" & merge_gradesb == 3

	count if DS == 1 & dist_centreoid_nearestgirlschool >=1.5 & OOSC_female_per>10
	count if DS == 1 & dist_centreoid_nearestgirlschool >=1.5 & OOSC_female_per>25
	count if DS == 1 & dist_centreoid_nearestgirlschool >=1.5 & OOSC_female_per>50
	count if DS == 1 & dist_centreoid_nearestgirlschool >=1.5 & OOSC_female_per>75
	

	*Transport 
	count if transport_girls == 1 
	
	count if transport_girls == 1 & SpaceForNewRooms == "Yes" 
	count if transport_girls == 1 & FunctionalStatus == "Functional" 
	count if transport_girls == 1 & stepb !=1
	count if transport_girls == 1 & SpaceForNewRooms == "Yes"  & stepb !=1
	count if transport_girls == 1 & SpaceForNewRooms == "Yes"  & stepb !=1 & merge_gradesb == 3


	
	*ECE/Primary Education
	
	tab space_construction 
	tab Istheschoolfunctional
	

	count if DS == 1 & dist_centreoid_nearestgirlschool >=1.5 & nearest_girls_school_1km == 1 & merge_gradesb == 3 & space_construction == "Yes" & Istheschoolfunctional == "Yes" & stepb != 1

	count if DS == 1 & dist_centreoid_nearestgirlschool >=1.5 & nearest_girls_school_1km == 1 & SpaceForNewRooms == "Yes" & FunctionalStatus == "Functional" & stepb !=1
	
	
/*
*Sample*
	count if enrollment_40_G == 1  & nearest_girls_school_1km == 1 
	count if enrollment_60_G == 1  & nearest_girls_school_1km == 1 
	count if enrollment_5_B == 1   & nearest_girls_school_1km == 1 
	count if enrollment_40_B == 1  
	count if enrollment_60_B == 1 
	count if Genderupdated == "Boys" & mean_enrol_b != 0

	count if enrollment_40_G == 1  & nearest_girls_school_1km == 1 & dis == 1
	count if enrollment_60_G == 1  & nearest_girls_school_1km == 1 & dis == 1
	count if enrollment_5_B == 1   & nearest_girls_school_1km == 1 & dis == 1
	count if enrollment_40_B == 1  & dis == 1
	count if enrollment_60_B == 1  & dis == 1
	count if Genderupdated == "Boys" & dis == 1 & mean_enrol_b != 0

	count if enrollment_40_G == 1  & nearest_girls_school_1km == 1 &  merge_gradesb == 3 & Istheschoolfunctional == "Yes"
	count if enrollment_60_G == 1  & nearest_girls_school_1km == 1 &  merge_gradesb == 3 & Istheschoolfunctional == "Yes"
	count if enrollment_5_B == 1   & nearest_girls_school_1km == 1 &  merge_gradesb == 3 & Istheschoolfunctional == "Yes"
	count if enrollment_40_B == 1  &  merge_gradesb == 3 & Istheschoolfunctional == "Yes"
	count if enrollment_60_B == 1  &  merge_gradesb == 3 & Istheschoolfunctional == "Yes"
	count if Genderupdated == "Boys"  &  merge_gradesb == 3 & Istheschoolfunctional == "Yes" & mean_enrol_b != 0
	
	
	count if enrollment_40_G == 1  & nearest_girls_school_1km == 1 & dis == 1 &  merge_gradesb == 3 & Istheschoolfunctional == "Yes"
	count if enrollment_60_G == 1  & nearest_girls_school_1km == 1 & dis == 1 &  merge_gradesb == 3 & Istheschoolfunctional == "Yes"
	count if enrollment_5_B == 1   & nearest_girls_school_1km == 1 & dis == 1 &  merge_gradesb == 3 & Istheschoolfunctional == "Yes"
	count if enrollment_40_B == 1  & dis == 1 &  merge_gradesb == 3 & Istheschoolfunctional == "Yes"
	count if enrollment_60_B == 1  & dis == 1 &  merge_gradesb == 3 & Istheschoolfunctional == "Yes"
	count if Genderupdated == "Boys"  & dis == 1 &  merge_gradesb == 3 & Istheschoolfunctional == "Yes" & mean_enrol_b != 0
*/
	
	
save "$data\Dataset\admin\emis_database.dta", replace





