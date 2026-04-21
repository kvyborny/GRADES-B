/********************************************************************************
 	Purpose: 		Generate descriptives for School Enrollment (by Age and Gender) 
					in Pakistan VS. Balochistan in our study using PSLM data 
					for the year 2019-2020
			

	Created by: 	Hijab Waheed
	Date Created: 	14 April 2026

********************************************************************************/

*********************************
* Setting globals for directories
*********************************

		global 			dir "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan_KPRAP_C2_IE\Project files\Public data\PSLM_2019_2020"
		global 			output "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Data\Analysis\Descriptives"


	**************
	* Data Prep 
	**************	
			
		// Roster data
		use 			"$dir\roster.dta", clear
		
		drop 			if sb1q4==0
		
		sort 			hhcode idc
		format 			hhcode %20.0g
		rename 			sb1q4 gender
		keep 			hhcode province idc gender age district
			
		tempfile 		roster
		save 			`roster'
		
		// Data to get the variable for current enrollment status 
		use 			"$dir\secc1.dta", clear
		rename 			sc1q01 enrollment
		
		// Keeping just the "currently enrolled" sample
		*keep 			if enrollment==3
		gen 			enrol = (enrollment==3)
		
		*keep 			hhcode idc enrol enrollment sc1q05 sc1q09 sc1q14 sc1q16 region
		
		// Merge with roster 
		merge 			1:1 hhcode idc using `roster', keep(match) nogen
		
		// Saving cleaned data to be used further
		tempfile 	 	data
		save 			`data'



*****************************
*Descriptive Graph 1 | GER & NER: Balochistan vs Rest of Pakistan
*****************************
						
use 		`data', clear
* ===========================================================
* --- UPDATE IF NEEDED ---
local sex_var "gender"
* CRITICAL: run `tab sc1q14, nolabel` to confirm preschool codes
* Assumed: playgroup=25, nursery=26, prep=27
* -------------------------

* ============================================================
* STEP 1: Generate all indicators on the full dataset
* ============================================================

capture drop balochistan
gen balochistan = (province == 4)

capture drop sex_lbl
recode `sex_var' (1=1 "Male") (2=2 "Female"), gen(sex_lbl)

* Currently attending
capture drop currently_att
gen currently_att = (enrollment == 3)

* Primary school: Playgroup / Nursery / Prep (25,26,27) + Grade 1-5 (1-5)
capture drop in_prim
gen in_prim = (inrange(sc1q14, 1, 5) | inlist(sc1q14, 25, 26, 27)) & currently_att

* Official age group — Primary: 5-10
capture drop prim_age
gen prim_age = (age >= 5 & age <= 10)

* GER numerator: currently enrolled in ANY school, within official age group
capture drop ger_prim_num
gen ger_prim_num = currently_att & prim_age

* NER numerator: enrolled at correct LEVEL and correct AGE
capture drop ner_prim
gen ner_prim = in_prim & prim_age

* Age brackets for Graph 3
capture drop age_br
gen age_br = .
replace age_br = 1 if age >= 5  & age <= 6
replace age_br = 2 if age >= 7  & age <= 8
replace age_br = 3 if age >= 9  & age <= 10

label define abr_lbl 1 "5-6" 2 "7-8" 3 "9-10", replace
label values age_br abr_lbl

* Correct-grade indicator for Graph 3 NER Primary
capture drop in_correct_grade
gen in_correct_grade = .
replace in_correct_grade = (inlist(sc1q14, 25, 26, 27, 1, 2)        & currently_att) if age_br == 1
replace in_correct_grade = (inlist(sc1q14, 3, 4)        & currently_att) if age_br == 2
replace in_correct_grade = (sc1q14 == 5                  & currently_att) if age_br == 3

* ============================================================
* GRAPHS 1 & 2: GER and NER — Balochistan vs Rest, by Gender
* 4 bars: Balo Male, Balo Female, Rest Male, Rest Female
* ============================================================

preserve

    collapse (sum) prim_age ger_prim_num ner_prim, ///
             by(balochistan sex_lbl)

    gen ger_prim_pct = (ger_prim_num / prim_age) * 100
    gen ner_prim_pct = (ner_prim     / prim_age) * 100

    * Reshape wide by sex so male/female are separate variables
    keep balochistan sex_lbl ger_prim_pct ner_prim_pct
    reshape wide ger_prim_pct ner_prim_pct, i(balochistan) j(sex_lbl)
    * sex_lbl: 1=Male, 2=Female → ger_prim_pct1, ger_prim_pct2

    label define balo_lbl 0 "Rest of Pakistan" 1 "Balochistan", replace
    label values balochistan balo_lbl
    sort balochistan

    * --- GRAPH 1: GER ---
    graph bar ger_prim_pct1 ger_prim_pct2,                                   ///
        over(balochistan, label(labsize(small)))                             ///
        bargap(10)                                                           ///
        bar(1, color("31 119 180%80") lcolor(none))                          ///
        bar(2, color("214 39 40%80")  lcolor(none))                          ///
        legend(order(1 "Male" 2 "Female") position(6) rows(1) size(small))   ///
        title("Gross Enrollment Rate: Primary (Ages 5-10)", size(small))     ///
        subtitle("Balochistan vs Rest of Pakistan | PSLM 2019-20",           ///
                 size(vsmall) color(gs8))                                    ///
        ytitle("GER (%)", size(vsmall))                                      ///
        ylabel(0(20)120, labsize(vsmall) angle(0) grid glcolor(gs14))        ///
        blabel(bar, format(%4.1f) size(small) color(gs6))                    ///
        note("GER = children currently enrolled in any school (ages 5-10) / population aged 5-10 × 100" ///
             "GER can exceed 100% due to over/under-age enrolment.",         ///
             size(vsmall) color(gs8))                                        ///
        graphregion(color(white)) plotregion(color(white))                   ///
        bgcolor(white) ysize(4) xsize(8)

    graph export "$output/graph1_GER_primary_balo_vs_rest.png", replace width(2400)

    * --- GRAPH 2: NER ---
    graph bar ner_prim_pct1 ner_prim_pct2,                                   ///
        over(balochistan, label(labsize(small)))                             ///
        bargap(10)                                                           ///
        bar(1, color("31 119 180%80") lcolor(none))                          ///
        bar(2, color("214 39 40%80")  lcolor(none))                          ///
        legend(order(1 "Male" 2 "Female") position(6) rows(1) size(small))   ///
        title("Net Enrollment Rate: Primary (Ages 5-10)", size(small))       ///
        subtitle("Balochistan vs Rest of Pakistan | PSLM 2019-20",           ///
                 size(vsmall) color(gs8))                                    ///
        ytitle("NER (%)", size(vsmall))                                      ///
        ylabel(0(10)100, labsize(vsmall) angle(0) grid glcolor(gs14))        ///
        blabel(bar, format(%4.1f) size(small) color(gs6))                    ///
        note("NER = children aged 5-10 enrolled in Playgroup/Nursery/Prep/Gr.1-5 / population aged 5-10 × 100", ///
             size(vsmall) color(gs8))                                        ///
        graphregion(color(white)) plotregion(color(white))                   ///
        bgcolor(white) ysize(4) xsize(8)

    graph export "$output/graph2_NER_primary_balo_vs_rest.png", replace width(2400)

restore

* ============================================================
* GRAPH 3: NER Primary by Age Bracket — Balochistan only
* 8 bars: Male/Female within 4 age brackets
*   <5   → Preschool (Playgroup/Nursery/Prep)
*   5-6  → Grade 1 or 2
*   7-8  → Grade 3 or 4
*   9-10 → Grade 5
* ============================================================

preserve

    keep if balochistan == 1
    keep if age_br != .

    collapse (mean) ner_m = in_correct_grade (count) n = age, by(age_br sex_lbl)

    gen ner_pct = ner_m * 100
    drop ner_m

    reshape wide ner_pct n, i(age_br) j(sex_lbl)
    replace ner_pct1 = 0 if missing(ner_pct1)
    replace ner_pct2 = 0 if missing(ner_pct2)

    quietly summarize n1
    local N_m = r(sum)
    quietly summarize n2
    local N_f = r(sum)

    * --- GRAPH 3: NER Primary by Age Bracket ---
    graph bar ner_pct1 ner_pct2,                                             ///
        over(age_br, label(labsize(small)))                                  ///
        bargap(20)                                                           ///
        bar(1, color("31 119 180%80") lcolor(none))                          ///
        bar(2, color("214 39 40%80")  lcolor(none))                          ///
        legend(order(1 "Male" 2 "Female") position(6) rows(1) size(small))   ///
        title("Net Enrollment Rate, Primary School by Age Bracket — Balochistan", ///
              size(small))                                                   ///
        subtitle("PSLM 2019-20", size(vsmall) color(gs8))                   ///
        ytitle("NER (%)", size(vsmall))                                      ///
        ylabel(0(10)100, labsize(vsmall) angle(0) grid glcolor(gs14))        ///
        blabel(bar, format(%4.1f) size(small) color(gs6))                    ///
        note("NER = % enrolled at correct grade for age bracket:"            ///
             "5-6 = Preschool (Playgroup/Nursery/Prep) or Gr.1-2; 7-8 = Gr.3-4; 9-10 = Gr.5" ///
             "N (Male) = `N_m'; N (Female) = `N_f' (Balochistan only, ages <11).", ///
             size(vsmall) color(gs8))                                        ///
        graphregion(color(white)) plotregion(color(white))                   ///
        bgcolor(white) ysize(4) xsize(7)

    graph export "$output/graph3_NER_primary_age_bracket_balo.png", replace width(2400)

restore
