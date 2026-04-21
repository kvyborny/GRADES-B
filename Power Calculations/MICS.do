*======================================================
* Foundational Learning - Continuous Scores
* Balochistan, Pakistan MICS6
* Story word count = 72 (Group A country)
*======================================================
***Globals

	if c(username) == "wb635947" {
		
		global data "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Data\MICS\Pakistan (Baluchistan) SPSS Datasets"
		
	}
	
	if c(username) == "wb630098" {
		
		global data ""
		
	}
	
*--- 1. Load and fix variable name casing ---
import spss using "$data\fs.sav", clear   


keep if CB3 >= 7 & CB3 <= 10
keep if HL4 == 2


* Balochistan-specific fix: rename all to uppercase
local uppervars  fs* hh* 
rename `uppervars', upper
rename FSWEIGHT, lower   // weight variable stays lowercase

*--- 2. Keep only completed foundational skills interviews ---
* FL28==1 means the interview was completed
keep if FL28 == 1

*--- 3. READING: word fluency percentage ---
* Each FL19W* = one word: 0=correct, 1=incorrect, 2=no attempt
* Balochistan story = 72 words

gen words_correct = 0
foreach num of numlist 1/72 {
    replace words_correct = words_correct + 1 if FL19W`num' == 0
	replace words_correct = 0 if FL19W`num' == 1
	replace words_correct = . if FL19W`num' == 2
	replace words_correct = . if FL19W`num' == .
}
gen fluency_pct = (words_correct / 72) * 100
label var fluency_pct "% of story words read correctly (out of 72)"

*--- 4. READING: comprehension percentage ---
* 3 literal questions (FL22A, FL22B, FL22C) + 2 inferential (FL22D, FL22E)
* 1=correct, anything else = not correct

gen comp_score = 0
foreach var in FL22A FL22B FL22C FL22D FL22E {
    replace comp_score = comp_score + 1 if `var' == 1
	replace comp_score = 0 if `var' == 2
	replace comp_score = . if `var' == 3 | `var' == 9 | `var' == .
}
gen comp_pct = (comp_score / 5) * 100
label var comp_pct "% comprehension questions correct (out of 5)"


*--- 5. NUMERACY: percentage scores per sub-skill ---

* (a) Number reading: FL23A-FL23F (6 items), 1=correct
gen num_read_score = 0
foreach var in FL23A FL23B FL23C FL23D FL23E FL23F {
    replace num_read_score = num_read_score + 1 if `var' == 1
	replace num_read_score = 0 if `var' == 2
	replace num_read_score = . if `var' == 3
}
gen num_read_pct = (num_read_score / 6) * 100
label var num_read_pct "% number reading correct (out of 6)"

* (b) Number discrimination: FL24A-FL24E (5 items)
gen num_dis_score = 0
foreach var in FL24A FL24B FL24C FL24D FL24E {
    replace num_dis_score = num_dis_score + 1 if `var' == 1
	replace num_dis_score = 0 if `var' == 2
	replace num_dis_score = . if `var' == 3
}
gen num_dis_pct = (num_dis_score / 5) * 100
label var num_dis_pct "% number discrimination correct (out of 5)"

* (c) Addition: FL25A-FL25E (5 items)
gen num_add_score = 0
foreach var in FL25A FL25B FL25C FL25D FL25E {
    replace num_add_score = num_add_score + 1 if `var' == 1
	replace num_add_score = 0 if `var' == 2
	replace num_add_score = . if `var' == 3
}
gen num_add_pct = (num_add_score / 5) * 100
label var num_add_pct "% addition correct (out of 5)"

* (d) Number patterns: FL27A-FL27E (5 items)
gen num_patt_score = 0
foreach var in FL27A FL27B FL27C FL27D FL27E {
    replace num_patt_score = num_patt_score + 1 if `var' == 1
	replace num_patt_score = 0 if `var' == 2
	replace num_patt_score = . if `var' == 3
}
gen num_patt_pct = (num_patt_score / 5) * 100
label var num_patt_pct "% number patterns correct (out of 5)"

* (e) Overall numeracy percentage (out of 21 items total)
gen num_total_score = num_read_score + num_dis_score + num_add_score + num_patt_score
gen num_total_pct   = (num_total_score / 21) * 100
label var num_total_pct "% overall numeracy correct (out of 21)"

*--- 6. Quick summary ---
svyset [pw=fsweight]
*svy: mean fluency_pct comp_pct num_total_pct 

*--- 7. Learning outcome var ---

gen learning1 = (0.5*fluency_pct + 0.5*comp_pct)
gen learning2 = (0.25*num_read_pct + 0.25*num_dis_pct + 0.25*num_add_pct +  0.25*num_patt_pct)
egen learning = rowmean(learning1 learning2)

*--- 8. ICC calculate  ---

loneway learning HH1