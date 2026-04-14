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
}
gen fluency_pct = (words_correct / 72) * 100
label var fluency_pct "% of story words read correctly (out of 72)"

*--- 4. READING: comprehension percentage ---
* 3 literal questions (FL22A, FL22B, FL22C) + 2 inferential (FL22D, FL22E)
* 1=correct, anything else = not correct

gen comp_score = 0
foreach var in FL22A FL22B FL22C FL22D FL22E {
    replace comp_score = comp_score + 1 if `var' == 1
}
gen comp_pct = (comp_score / 5) * 100
label var comp_pct "% comprehension questions correct (out of 5)"


*--- 5. NUMERACY: percentage scores per sub-skill ---

* (a) Number reading: FL23A-FL23F (6 items), 1=correct
gen num_read_score = 0
foreach var in FL23A FL23B FL23C FL23D FL23E FL23F {
    replace num_read_score = num_read_score + 1 if `var' == 1
}
gen num_read_pct = (num_read_score / 6) * 100
label var num_read_pct "% number reading correct (out of 6)"

* (b) Number discrimination: FL24A-FL24E (5 items)
gen num_dis_score = 0
foreach var in FL24A FL24B FL24C FL24D FL24E {
    replace num_dis_score = num_dis_score + 1 if `var' == 1
}
gen num_dis_pct = (num_dis_score / 5) * 100
label var num_dis_pct "% number discrimination correct (out of 5)"

* (c) Addition: FL25A-FL25E (5 items)
gen num_add_score = 0
foreach var in FL25A FL25B FL25C FL25D FL25E {
    replace num_add_score = num_add_score + 1 if `var' == 1
}
gen num_add_pct = (num_add_score / 5) * 100
label var num_add_pct "% addition correct (out of 5)"

* (d) Number patterns: FL27A-FL27E (5 items)
gen num_patt_score = 0
foreach var in FL27A FL27B FL27C FL27D FL27E {
    replace num_patt_score = num_patt_score + 1 if `var' == 1
}
gen num_patt_pct = (num_patt_score / 5) * 100
label var num_patt_pct "% number patterns correct (out of 5)"

* (e) Overall numeracy percentage (out of 21 items total)
gen num_total_score = num_read_score + num_dis_score + num_add_score + num_patt_score
gen num_total_pct   = (num_total_score / 21) * 100
label var num_total_pct "% overall numeracy correct (out of 21)"

*--- 6. Restrict to valid age range (7-14) ---
foreach var in fluency_pct comp_pct ///
               num_total_pct  {
    replace `var' = . if CB3 < 7 | CB3 > 14
}

*--- 7. Quick summary ---
svyset [pw=fsweight]
svy: mean fluency_pct comp_pct num_total_pct 

*--- 8. Learning outcome var ---

egen learning = rowmean(fluency_pct comp_pct num_total_pct)


*--- 9. ICC calculate  ---

loneway learning stratum if HL4 == 2

                  One-way analysis of variance for learning: 
/*
                                             Number of obs =        4,100
                                                 R-squared =       0.1808

    Source                SS         df      MS            F     Prob > F
-------------------------------------------------------------------------
Between stratum         319826.4     62    5158.4903     14.37     0.0000
Within stratum           1449279  4,037    358.99901
-------------------------------------------------------------------------
Total                  1769105.4  4,099    431.59439

         Intraclass       Asy.        
         correlation      S.E.       [95% conf. interval]
         ------------------------------------------------
            0.17165     0.03329       0.10639     0.23690

         Estimated SD of stratum effect          8.624999
         Estimated SD within stratum             18.94727
         Est. reliability of a stratum mean       0.93041
              (evaluated at n=64.52)

.*/
