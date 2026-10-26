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
		global 			hies "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Project files\Data\HIES"
		global 			output "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Project files\Data\Analysis\Descriptives"


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


*********************************************************************************
/* HIES (24-25)
*********************************************************************************/
		
		*roster data
		use "$hies/plist_roster.dta", clear
		
		
		sort 			hhcode idc
		format 			hhcode %20.0g
		rename			s1aq03 gender
		rename 			s1aq51 age
		keep 			hhcode province idc gender age 
			
		tempfile 		roster
		save 			`roster'
		
		// Data to get the educ/literacy vars
		use 			"$hies\sec_2ab_education.dta", clear
		merge 			1:1 hhcode idc using `roster', keep(match) nogen
		
		tempfile hies_data
		save `hies_data'
		

*****************************
*Descriptive Graph 1 | GER & NER: Balochistan vs Rest of Pakistan
*****************************
						
use 		`hies_data', clear 
* ===========================================================
* --- UPDATE IF NEEDED ---
local sex_var "gender"
rename s2bq01 enrollment
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
gen in_prim = (inrange(s2bq10, 1, 5) | inlist(s2bq10, 25, 26, 27)) & currently_att

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
replace in_correct_grade = (inlist(s2bq10, 25, 26, 27, 1, 2)        & currently_att) if age_br == 1
replace in_correct_grade = (inlist(s2bq10, 3, 4)        & currently_att) if age_br == 2
replace in_correct_grade = (s2bq10 == 5                  & currently_att) if age_br == 3

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
        subtitle("Balochistan vs Rest of Pakistan | HIES 2024-25",           ///
                 size(vsmall) color(gs8))                                    ///
        ytitle("GER (%)", size(vsmall))                                      ///
        ylabel(0(20)120, labsize(vsmall) angle(0) grid glcolor(gs14))        ///
        blabel(bar, format(%4.1f) size(small) color(gs6))                    ///
        note("GER = children currently enrolled in any school (ages 5-10) / population aged 5-10 × 100" ///
             "GER can exceed 100% due to over/under-age enrolment.",         ///
             size(vsmall) color(gs8))                                        ///
        graphregion(color(white)) plotregion(color(white))                   ///
        bgcolor(white) ysize(4) xsize(8)

    graph export "$output/graph1_GER_primary_balo_vs_rest_hies.png", replace width(2400)

    * --- GRAPH 2: NER ---
    graph bar ner_prim_pct1 ner_prim_pct2,                                   ///
        over(balochistan, label(labsize(small)))                             ///
        bargap(10)                                                           ///
        bar(1, color("31 119 180%80") lcolor(none))                          ///
        bar(2, color("214 39 40%80")  lcolor(none))                          ///
        legend(order(1 "Male" 2 "Female") position(6) rows(1) size(small))   ///
        title("Net Enrollment Rate: Primary (Ages 5-10)", size(small))       ///
        subtitle("Balochistan vs Rest of Pakistan | HIES 2024-25",           ///
                 size(vsmall) color(gs8))                                    ///
        ytitle("NER (%)", size(vsmall))                                      ///
        ylabel(0(10)100, labsize(vsmall) angle(0) grid glcolor(gs14))        ///
        blabel(bar, format(%4.1f) size(small) color(gs6))                    ///
        note("NER = children aged 5-10 enrolled in Playgroup/Nursery/Prep/Gr.1-5 / population aged 5-10 × 100", ///
             size(vsmall) color(gs8))                                        ///
        graphregion(color(white)) plotregion(color(white))                   ///
        bgcolor(white) ysize(4) xsize(8)

    graph export "$output/graph2_NER_primary_balo_vs_rest_hies.png", replace width(2400)

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
        subtitle("HIES 2024-25", size(vsmall) color(gs8))                   ///
        ytitle("NER (%)", size(vsmall))                                      ///
        ylabel(0(10)100, labsize(vsmall) angle(0) grid glcolor(gs14))        ///
        blabel(bar, format(%4.1f) size(small) color(gs6))                    ///
        note("NER = % enrolled at correct grade for age bracket:"            ///
             "5-6 = Preschool (Playgroup/Nursery/Prep) or Gr.1-2; 7-8 = Gr.3-4; 9-10 = Gr.5" ///
             "N (Male) = `N_m'; N (Female) = `N_f' (Balochistan only, ages <11).", ///
             size(vsmall) color(gs8))                                        ///
        graphregion(color(white)) plotregion(color(white))                   ///
        bgcolor(white) ysize(4) xsize(7)

    graph export "$output/graph3_NER_primary_age_bracket_balo_hies.png", replace width(2400)

restore




********************************************
* Descriptive Graph 4: Dropout at each grade
********************************************
		use `data', clear

* Keep relevant  group

		keep if inlist(district, 412, 420, 426, 413, 417, 411, 429, 414, 416)
		
* =========================================================
* Step 0: Sample sizes for boys and girls (ever-enrolled, valid grade info)
* =========================================================
		quietly count if gender == 1 & sc1q05 < 25 & sc1q05 != .
		local n_boys = r(N)
		quietly count if gender == 2 & sc1q05 < 25 & sc1q05 != .
		local n_girls = r(N)
		
* =========================================================
* Step 1: Calculate dropout rates (11 categories x 2 genders)
* sc1q05==1 → shown as "Grade 2" (dropped out before completing grade 2)
* sc1q05==10 → shown as "Grade 10 Complete"
* =========================================================

matrix results = J(22, 3, .)

local row = 1

forvalues g = 1/10 {
    forvalues s = 1/2 {

        quietly count if gender == `s' & sc1q05 >= `g' & sc1q05 < 25 
        local denom = r(N)

        quietly count if gender == `s' & sc1q05 == `g'
        local numer = r(N)

        if `denom' > 0 {
            local dr = `numer' / `denom' * 100
        }
        else {
            local dr = .
        }

        matrix results[`row', 1] = `g'
        matrix results[`row', 2] = `s'
        matrix results[`row', 3] = `dr'
        local row = `row' + 1
    }
}

* =========================================================
* Step 3: Convert to dataset
* =========================================================

preserve
    clear
    svmat results, names(col)
    rename c1 grade
    rename c2 gender
    rename c3 dr

    * Round for clean labels
    gen dr_r = round(dr, 1)

    * Offset x for side-by-side bars
    gen x_boys  = grade - 0.2
    gen x_girls = grade + 0.2

    label define gender_lbl 1 "Boys" 2 "Girls"
    label values gender gender_lbl

* =========================================================
* Step 4: Graph
* =========================================================

    twoway ///
        (bar dr x_boys  if gender == 1, barwidth(0.35) ///
            fcolor("31 73 125") lcolor("31 73 125")) ///
        (bar dr x_girls if gender == 2, barwidth(0.35) ///
            fcolor("197 160 60") lcolor("197 160 60")) ///
        (scatter dr x_boys if gender == 1, msymbol(none) ///
            mlabel(dr_r) mlabformat(%3.0f) mlabposition(12) ///
            mlabcolor("31 73 125") mlabsize(vsmall)) ///
        (scatter dr x_girls if gender == 2, msymbol(none) ///
            mlabel(dr_r) mlabformat(%3.0f) mlabposition(12) ///
            mlabcolor("140 100 20") mlabsize(vsmall)), ///
        xlab(1 "2" 2 "3" 3 "4" 4 "5" 5 "6" 6 "7" 7 "8" ///
             8 "9" 9 "10" 10 "10 completed (no further education)", ///
             angle(15) labsize(small)) ///
        ylabel(0(5)65, labsize(small) format(%3.0f)) /// 
        xtitle("") ///
        ytitle("") ///
        title("School dropout rates by completed grade, among ever-enrolled students", size(small)) ///
		subtitle("Study Districts: kech, naserabad, quetta, kharan, loralai, kalat, sibi, khuzdar, lasbela", size(vsmall)) ///
        legend(order(1 "Boys" 2 "Girls") position(11) ring(0) ///
               region(lcolor(none)) size(small)) ///
        graphregion(color(white)) plotregion(color(white)) ///
        note("Source: PSLM 2019-20." ///
	 "Dropout rate is defined as the share of individuals who left school after completing each grade, calculated as the number whose highest completed grade" ///
	 "is grade g divided by all who reached grade g." ///
	 "{it: dr(g)= completed grade g-1/ reached grade g-1}" ///
	  "Sample: Girls and boys who attended school in the past" ///
	  "N boys = `n_boys', N girls = `n_girls'.", size(vsmall) justification(left)) ///
	 
	 graph export "$output/studydistricts_dropout.png", replace width(2400)


restore

**************************************************************************
**Descriptive Graph 5
*Balochistan: Reasons to drop out in grade 1, 2, 3 - for girls and boys
**************************************************************************

use `data', clear

preserve
    keep if inlist(district, 412, 420, 426, 413, 417, 411, 429, 414, 416)
	keep if sc1q05 == 1 | sc1q05 == 2 | sc1q05 == 3
    drop if missing(sc1q10)
    collapse (count) n = enrollment, by(sc1q10 gender)
    bysort gender: egen gender_total = total(n)
    gen pct = (n / gender_total) * 100
    quietly summarize gender_total if gender == 1
    local N_male = r(mean)
    quietly summarize gender_total if gender == 2
    local N_female = r(mean)
    rename pct pct_
    reshape wide pct_ n gender_total, i(sc1q10) j(gender)
    replace pct_1 = 0 if missing(pct_1)
    replace pct_2 = 0 if missing(pct_2)
    graph hbar pct_1 pct_2,                                          ///
        over(sc1q10, sort(pct_2) descending                          ///
             label(labsize(vsmall)) axis(lcolor(none)) gap(80))       ///
        bargap(20)                                                    ///
        bar(1, color("31 119 180%80")  lcolor(none))                 ///
        bar(2, color("214 39 40%80")   lcolor(none))                 ///
        legend(order(1 "Male" 2 "Female")                            ///
               position(6) rows(1) size(small))       ///
        title("Why Did Children Leave School? By Gender",            ///
              size(small) color(black))                              ///
        subtitle("Balochistan, study districts; Dropouts in Grade 1, 2, or 3",           ///
                 size(vsmall) color(gs8))                            ///
        ytitle("Share within gender (%)", size(vsmall))              ///
        ylabel(0(5)50, labsize(vsmall) angle(0) grid glcolor(gs14))  ///
        blabel(bar, format(%4.1f) size(vsmall) color(gs6))            ///
        note("Percentages are column percentages within each gender." ///
             "N (Male) = `N_male'; N (Female) = `N_female'."         ///
             "Sample restricted to highest grade = grade 1, 2, or 3."            ///
			 "Study Districts: kech, naserabad, quetta, kharan, loralai, kalat, sibi, khuzdar, lasbela." ///
			 "Zhob is one of the study districts but pslm does not have the data.", size(vsmall) color(gs8)) /// 
        graphregion(color(white)) plotregion(color(white))           ///
        bgcolor(white) ysize(5) xsize(7)							///
		
		graph export "$output/dropout_studydistricts_reason.png", replace width(2400)

restore


				
*****************************
*Descriptive Graph 6a
*Balochistan: enrollment status in balochistan v ROP
*****************************
						
		use 		`data', clear

* ── Step 1: Define area ────────────────────────────────────────────────────
gen area_n = 1 if inlist(district, 412, 420, 426, 413, 417, 411, 429, 414, 416)
replace area_n = 2 if area_n == .

label define arealbl 1 "Study Districts" 2 "Rest of Pakistan (ROP)"
label values area_n arealbl

* ── Step 2: Keep only relevant variables ──────────────────────────────────
keep gender enrollment area_n

* ── Step 3: Create a count variable (separate from enrollment) ────────────
gen one = 1

* ── Step 4: Collapse ──────────────────────────────────────────────────────
collapse (sum) n=one, by(gender enrollment area_n)

* ── Step 5: Compute percentages within gender and area ────────────────────
bysort gender area_n: egen total = sum(n)
gen pct = (n / total) * 100

* ── Step 6: Reshape wide on gender ────────────────────────────────────────
reshape wide n pct total, i(area_n enrollment) j(gender)
rename pct1 boys
rename pct2 girls

* ── Step 6b: Pull sample N by area and gender ──────────────────────────────
quietly summarize total1 if area_n == 1
local n_boys_sd  = round(r(mean))
quietly summarize total2 if area_n == 1
local n_girls_sd = round(r(mean))
quietly summarize total1 if area_n == 2
local n_boys_rop  = round(r(mean))
quietly summarize total2 if area_n == 2
local n_girls_rop = round(r(mean))

* ── Step 7: Sort ──────────────────────────────────────────────────────────
sort area_n enrollment

* ── Step 8: Plot ──────────────────────────────────────────────────────────
graph bar boys girls, ///
    over(enrollment, gap(15) ///
         relabel(1 "Never attended" 2 "Attended in past" 3 "Currently enrolled") ///
         label(angle(45) labsize(small))) ///
    over(area_n, gap(60)) ///
    bargap(10) ///
    bar(1, color("70 105 140") lcolor(none)) ///
    bar(2, color("255 178 102") lcolor(none)) ///
    ytitle("% within gender", size(small)) ///
    ylabel(0(20)100, glcolor(gs14) glpattern(dash)) ///
    title("Enrollment Status by Gender and Area", ///
          size(medlarge) color(black)) ///
    legend(order(1 "Boys" 2 "Girls") pos(6) row(1) region(lcolor(none))) ///
    blabel(bar, position(outside) format(%2.0f) size(vsmall)) ///
    graphregion(color(white)) plotregion(color(white)) ///
     note("Note: Percentages are within gender (boys sum to 100%, girls sum to 100%)." ///
	"Study Districts: kech, naserabad, quetta, kharan, loralai, kalat, sibi, khuzdar, lasbela." ///
	"Zhob is one of the study districts but pslm does not have the data." ///
	"N: Study Districts — Boys = `n_boys_sd', Girls = `n_girls_sd'; ROP — Boys = `n_boys_rop', Girls = `n_girls_rop'.")
	
	graph export "$output/studydistricts_enrollment.png", replace width(2400)

	
	*****************************
*Descriptive Graph 6b
*Balochistan: enrollment status in balochistan v ROP, ages 5-10
*****************************
						
		use 		`data', clear

* ── Step 1: Define area ────────────────────────────────────────────────────
gen area_n = 1 if inlist(district, 412, 420, 426, 413, 417, 411, 429, 414, 416)
replace area_n = 2 if area_n == .
label define arealbl 1 "Study Districts" 2 "Rest of Pakistan (ROP)"
label values area_n arealbl

* ── Step 1b: Restrict to age 5-10 (inclusive) ──────────────────────────────
keep if inrange(age, 5, 10)

* ── Step 2: Keep only relevant variables ──────────────────────────────────
keep gender enrollment area_n

* ── Step 3: Create a count variable (separate from enrollment) ────────────
gen one = 1

* ── Step 4: Collapse ──────────────────────────────────────────────────────
collapse (sum) n=one, by(gender enrollment area_n)

* ── Step 5: Compute percentages within gender and area ────────────────────
bysort gender area_n: egen total = sum(n)
gen pct = (n / total) * 100

* ── Step 6: Reshape wide on gender ────────────────────────────────────────
reshape wide n pct total, i(area_n enrollment) j(gender)
rename pct1 boys
rename pct2 girls

* ── Step 6b: Pull sample N by area and gender ──────────────────────────────
quietly summarize total1 if area_n == 1
local n_boys_sd  = round(r(mean))
quietly summarize total2 if area_n == 1
local n_girls_sd = round(r(mean))
quietly summarize total1 if area_n == 2
local n_boys_rop  = round(r(mean))
quietly summarize total2 if area_n == 2
local n_girls_rop = round(r(mean))

* ── Step 7: Sort ──────────────────────────────────────────────────────────
sort area_n enrollment

* ── Step 8: Plot ──────────────────────────────────────────────────────────
graph bar boys girls, ///
    over(enrollment, gap(15) ///
         relabel(1 "Never attended" 2 "Attended in past" 3 "Currently enrolled") ///
         label(angle(45) labsize(small))) ///
    over(area_n, gap(60)) ///
    bargap(10) ///
    bar(1, color("70 105 140") lcolor(none)) ///
    bar(2, color("255 178 102") lcolor(none)) ///
    ytitle("% within gender", size(small)) ///
    ylabel(0(20)100, glcolor(gs14) glpattern(dash)) ///
    title("Enrollment Status by Gender and Area, Ages 5-10", ///
          size(medlarge) color(black)) ///
    legend(order(1 "Boys" 2 "Girls") pos(6) row(1) region(lcolor(none))) ///
    blabel(bar, position(outside) format(%2.0f) size(vsmall)) ///
    graphregion(color(white)) plotregion(color(white)) ///
     note("Note: Percentages are within gender (boys sum to 100%, girls sum to 100%)." ///
	"Sample restricted to children aged 5-10 (inclusive)." ///
	"Study Districts: kech, naserabad, quetta, kharan, loralai, kalat, sibi, khuzdar, lasbela." ///
	"Zhob is one of the study districts but pslm does not have the data." ///
	"N: Study Districts — Boys = `n_boys_sd', Girls = `n_girls_sd'; ROP — Boys = `n_boys_rop', Girls = `n_girls_rop'.")
	
	graph export "$output/studydistricts_enrollment_age5to10.png", replace width(2400)
	
*******************************************************************************
**Descriptive 8: Reasons of never enrolling
******************************************************************************

use `data', clear

preserve
    drop if missing(sc1q02)
	keep if inlist(district, 412, 420, 426, 413, 417, 411, 429, 414, 416)
    collapse (count) n = enrollment, by(sc1q02 gender)
    bysort gender: egen gender_total = total(n)
    gen pct = (n / gender_total) * 100
    quietly summarize gender_total if gender == 1
    local N_male = r(mean)
    quietly summarize gender_total if gender == 2
    local N_female = r(mean)
    rename pct pct_
    reshape wide pct_ n gender_total, i(sc1q02) j(gender)
    replace pct_1 = 0 if missing(pct_1)
    replace pct_2 = 0 if missing(pct_2)
    graph hbar pct_1 pct_2,                                          ///
        over(sc1q02, sort(pct_2) descending                          ///
             label(labsize(vsmall)) axis(lcolor(none)) gap(80))       ///
        bargap(20)                                                    ///
        bar(1, color("31 119 180%80")  lcolor(none))                 ///
        bar(2, color("214 39 40%80")   lcolor(none))                 ///
        legend(order(1 "Male" 2 "Female")                            ///
               position(6) rows(1) size(small))       ///
        title("Why Did Children Never Attend School? By Gender",            ///
              size(small) color(black))                              ///
        subtitle("Balochistan, Study Districts",           ///
                 size(vsmall) color(gs8))                            ///
        ytitle("Share within gender (%)", size(vsmall))              ///
        ylabel(0(5)100, labsize(vsmall) angle(0) grid glcolor(gs14))  ///
        blabel(bar, format(%4.1f) size(vsmall) color(gs6))            ///
        note("Percentages are column percentages within each gender." ///
             "N (Male) = `N_male'; N (Female) = `N_female'."         ///
             size(vsmall) color(gs8))                                ///
        graphregion(color(white)) plotregion(color(white))           ///
        bgcolor(white) ysize(5) xsize(7)							///
		note("Study Districts: kech, naserabad, quetta, kharan, loralai, kalat, sibi, khuzdar, lasbela." ///
	         "Zhob is one of the study districts but pslm does not have the data.") ///
	
	graph export "$output/studydistricts_reason_neverattended.png", replace width(2400)
	
restore

*******************************************************************************
**Descriptive 8b: Reasons of never enrolling, Ages 5-10
******************************************************************************
use `data', clear
preserve
    drop if missing(sc1q02)
	keep if inlist(district, 412, 420, 426, 413, 417, 411, 429, 414, 416)
	keep if inrange(age, 5, 10)
    collapse (count) n = enrollment, by(sc1q02 gender)
    bysort gender: egen gender_total = total(n)
    gen pct = (n / gender_total) * 100
    quietly summarize gender_total if gender == 1
    local N_male = r(mean)
    quietly summarize gender_total if gender == 2
    local N_female = r(mean)
    rename pct pct_
    reshape wide pct_ n gender_total, i(sc1q02) j(gender)
    replace pct_1 = 0 if missing(pct_1)
    replace pct_2 = 0 if missing(pct_2)
    graph hbar pct_1 pct_2,                                          ///
        over(sc1q02, sort(pct_2) descending                          ///
             label(labsize(vsmall)) axis(lcolor(none)) gap(80))       ///
        bargap(20)                                                    ///
        bar(1, color("31 119 180%80")  lcolor(none))                 ///
        bar(2, color("214 39 40%80")   lcolor(none))                 ///
        legend(order(1 "Male" 2 "Female")                            ///
               position(6) rows(1) size(small))       ///
        title("Why Did Children Never Attend School? By Gender, Ages 5-10",            ///
              size(small) color(black))                              ///
        subtitle("Balochistan, Study Districts",           ///
                 size(vsmall) color(gs8))                            ///
        ytitle("Share within gender (%)", size(vsmall))              ///
        ylabel(0(5)100, labsize(vsmall) angle(0) grid glcolor(gs14))  ///
        blabel(bar, format(%4.1f) size(vsmall) color(gs6))            ///
        note("Percentages are column percentages within each gender." ///
             "N (Male) = `N_male'; N (Female) = `N_female'."         ///
             "Sample restricted to children aged 5-10 (inclusive)."  ///
             "Study Districts: kech, naserabad, quetta, kharan, loralai, kalat, sibi, khuzdar, lasbela." ///
	         "Zhob is one of the study districts but pslm does not have the data.", ///
             size(vsmall) color(gs8))                                ///
        graphregion(color(white)) plotregion(color(white))           ///
        bgcolor(white) ysize(5) xsize(7)
	
	graph export "$output/studydistricts_reason_neverattended_age5to10.png", replace width(2400)

restore

