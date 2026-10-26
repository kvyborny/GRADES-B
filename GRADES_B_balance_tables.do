/*==============================================================================
  GRADES-B Impact Evaluation
  Baseline balance tables: IE schools, RTSM school-survey data
--------------------------------------------------------------------------------
  Purpose : Test balance of school characteristics across the three randomized
            arms (Transport, Double shift, Comparison) for the 307 IE schools
            (one per cluster) in IE_school_list_for_PMU_DRAFT.xlsx, sheet
            "IE schools".

  Data    : Every IE school is in exactly ONE of two RTSM rounds:
              - Fall 2025 pre-assessment (127 schools)
                  GRADES Latest sheet 3278 schools (2).xlsx, Sheet1
              - May 2026 field validation (180 schools)
                  GRADES_B Baseline Phase two V.3.xlsx, first sheet
                  (labelled, de-duplicated Kobo export; 3,619 schools)
            Only questions asked in BOTH rounds, with the same wording, units
            and skip logic, are used (see the "Variable definitions" and
            "Excluded questions" sheets of GRADES_B_balance_RESULTS.xlsx).

  Method  : iebaltab (ietoolkit v7+). Difference = raw difference in means;
            p-values from OLS of the variable on the pair dummy with tehsil
            fixed effects (the IE school's tehsil in the PMU IE list, 41
            tehsils) and robust SEs (one school per cluster, so robust =
            clustered at the cluster level; cluster fixed effects are not
            possible for the same reason). Set global fe below to
            "district_fe" to use district fixed effects (12) instead.
            Column order Transport (1), Double shift (2), Comparison (3), so
            pairs read T-DS, T-C, DS-C.

  Tables  : (1) All 307 IE schools, three arms (as randomized).
            (2) Like-for-like: Transport vs girls'/co-ed Comparison schools.
            (3) Like-for-like: Double shift vs boys' Comparison schools.
            Transport IE schools are all girls'/co-ed and Double-shift IE
            schools are all boys', so table (1) mechanically shows
            differences in anything gendered (girls' enrolment, girls'
            toilets, ...). Read (2) and (3) for those variables.

  Columns are located by Excel column letter. Every column used is checked
  against its header text first; the do-file stops if a file has changed.

  Author  : Hijab Waheed
  Created : 26 Oct 2026
==============================================================================*/

version 15
clear all
set more off
set varabbrev off

*------------------------------------------------------------------------------
* 0. Paths (edit to your machine)
*------------------------------------------------------------------------------
global grades    "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Project files\Data"
global baldir    "${grades}\Analysis\Balance tables"
global out       "${baldir}\output"

global ie_list   "${grades}\Randomized\IE_school_list_for_PMU_DRAFT.xlsx"
global fall_rtsm "${grades}\Admin Data\GRADES B\Round 1\GRADES Latest sheet 3278 schools (2).xlsx"
global may_rtsm  "${grades}\Admin Data\GRADES B\Round 2\Data\GRADES_B Baseline Phase two V.3.xlsx"

* fixed effects for the balance regressions: tehsil_fe (default) or district_fe
global fe "tehsil_fe"

capture mkdir "${out}"
foreach d in 3arm TvC_girls DSvC_boys {
    capture mkdir "${out}/`d'"
}

capture which iebaltab
if _rc ssc install ietoolkit, replace

*------------------------------------------------------------------------------
* Helper programs
*------------------------------------------------------------------------------
* Header checks. Some Excel headers contain line breaks (Alt+Enter) or double
* spaces, e.g. Fall column DG is "8.1) Total No<line break> of Kacha Rooms?".
* Line breaks are turned into spaces and repeated spaces collapsed before
* comparing.

* chkhdr: stop unless the header (row 1) of column `col' contains `phrase'
capture program drop chkhdr
program define chkhdr
    args col phrase
    capture confirm variable `col'
    if _rc {
        di as error "Column `col' not found in the imported sheet"
        exit 111
    }
    if strpos(lower(strtrim(itrim(subinstr(subinstr(`col'[1], char(10), " ", .), char(13), " ", .)))), lower("`phrase'")) == 0 {
        di as error "Header check failed: column `col' does not contain [`phrase']"
        exit 9
    }
end

* chkexact: stop unless the header of column `col' is exactly `text'
capture program drop chkexact
program define chkexact
    args col text
    if strtrim(itrim(subinstr(subinstr(`col'[1], char(10), " ", .), char(13), " ", .))) != "`text'" {
        di as error "Header check failed: column `col' is not [`text']"
        exit 9
    }
end

* yn: Yes/No text -> 1/0, blank -> missing; stop on any other value
capture program drop yn
program define yn
    args newvar col
    quietly gen double `newvar' = .
    quietly replace `newvar' = 1 if lower(strtrim(`col')) == "yes"
    quietly replace `newvar' = 0 if lower(strtrim(`col')) == "no"
    capture assert inlist(lower(strtrim(`col')), "yes", "no", "")
    if _rc {
        di as error "Unexpected values in column `col' (`newvar'):"
        tab `col' if !inlist(lower(strtrim(`col')), "yes", "no", ""), missing
        exit 9
    }
end

* num: text -> number, blank -> missing; stop on any non-numeric entry
capture program drop num
program define num
    args newvar col
    quietly gen double `newvar' = real(strtrim(`col'))
    capture assert !missing(`newvar') if strtrim(`col') != ""
    if _rc {
        di as error "Non-numeric values in column `col' (`newvar'):"
        list bemis `col' if missing(`newvar') & strtrim(`col') != ""
        exit 9
    }
end

* grades: enrolment by grade (Kachi, Class 1-12) for one sex; blank = 0
*         (May form skips Classes 6-12 in primary schools)
capture program drop grades
program define grades
    args prefix cols
    local glist kachi c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12
    forvalues k = 1/13 {
        local g : word `k' of `glist'
        local c : word `k' of `cols'
        num `prefix'_`g' `c'
        quietly replace `prefix'_`g' = 0 if missing(`prefix'_`g')
    }
end

* chkgrades: header checks for the 13 grade columns of one sex
capture program drop chkgrades
program define chkgrades
    args cols
    forvalues k = 1/13 {
        local c : word `k' of `cols'
        if `k' == 1 chkexact `c' "Kachi"
        else        chkexact `c' "Class `=`k'-1'"
    }
end

* savemat: iebaltab can display only one statistic per comparison in the table
*         (we display the difference with stars). It stores all of them in
*         r(iebtab_rmat) / r(iebtab_fmat): N, mean, SE per group; diff, N, beta,
*         t, p, SE per comparison; F-test. Copy them to balR / balF right after
*         iebaltab, then call savemat to write them to Excel.
capture program drop savemat
program define savemat
    args file
    putexcel set "`file'", sheet("all stats") replace
    putexcel A1 = matrix(balR), names
    putexcel set "`file'", sheet("F-test") modify
    putexcel A1 = matrix(balF), names
end

*------------------------------------------------------------------------------
* 1. IE school list (307 schools, one per cluster), arms, district and tehsil
*------------------------------------------------------------------------------
import excel using "${ie_list}", sheet("IE schools") clear allstring
chkhdr A "Group"
chkhdr C "District"
chkhdr D "Tehsil"
chkhdr F "Cluster ID"
chkhdr G "BEMIS"
chkhdr H "School Name"
chkhdr J "Gender"
drop in 1
gen bemis       = real(G)
gen cluster_id  = real(F)
gen group_str   = strtrim(A)
gen district    = strtrim(C)
gen tehsil      = strtrim(D)
gen school_name = strtrim(H)
gen gender      = strtrim(J)
keep bemis cluster_id group_str district tehsil school_name gender
drop if missing(bemis)
isid bemis
isid cluster_id
assert _N == 307

gen     arm = 1 if group_str == "Transport"
replace arm = 2 if group_str == "Double shift"
replace arm = 3 if group_str == "Comparison"
assert !missing(arm)
label define arm 1 "Transport" 2 "Double shift" 3 "Comparison"
label values arm arm
label var arm "Randomized arm"

encode district, gen(district_fe)
label var district_fe "District of the IE school (alternative fixed effects)"

gen tehsil_str = district + " | " + tehsil
encode tehsil_str, gen(tehsil_fe)
label var tehsil_fe "Tehsil of the IE school (fixed effects)"

gen girls_coed = (gender != "Boys")
label define girls_coed 0 "Boys' school" 1 "Girls'/co-ed school"
label values girls_coed girls_coed
label var girls_coed "IE school is a girls' or co-ed school"

tab arm girls_coed
tempfile ie
save `ie'


*------------------------------------------------------------------------------
* 2. Fall 2025 pre-assessment (127 IE schools)
*------------------------------------------------------------------------------
import excel using "${fall_rtsm}", clear allstring

* header checks
chkhdr D "BEMIS"
chkhdr AB  "Government-owned Building"
chkhdr AC  "space available for construction within the school premises"
chkhdr AG  "space for play area available"
chkhdr AQ  "under the CPD program"
chkhdr AR  "Is PTSMC Formed"
chkhdr DX  "Is a playground available"
chkhdr EC  "Boundary wall already available"
chkhdr EI  "Is a Gate already available"
chkhdr EK  "Does the roof need repairing"
chkhdr EL  "Does the roof need replacement"
chkhdr EM  "Is Water Available"
chkhdr EP  "Is electricity available in the school"
chkhdr ES  "Is gas available in the school"
chkhdr EU  "Is a water tank available in the school"
chkhdr EX  "Is a water pump available"
chkhdr FA  "Is an ECE room available in the school"
chkhdr FH  "is there shortage of desk"
chkhdr FL  "Is there any student with disability"
chkhdr AT  "PTSMC Members Trained"
chkhdr AU  "Is PTSMC Functional"
chkhdr ER  "is Electricity available in the area"
chkhdr DB  "Teachers Posted"
chkhdr DC  "teachers trained on ECE"
chkhdr DD  "teachers trained on induction"
chkhdr DG  "Total No of Kacha Rooms"
chkhdr DH  "Total No of Pakka Rooms"
chkhdr DI  "Functional Kacha Rooms"
chkhdr DJ  "Functional Pakka Rooms"
chkhdr DK  "Kacha Rooms"
chkhdr DL  "Non-Functional Pakka Rooms"
chkhdr DO  "Total No. of Boys Toilets"
chkhdr DP  "Total No. of Girls Toilets"
chkhdr DY  "additional rooms needed to be constructed"
chkhdr DZ  "rooms that need repair"
chkhdr EA  "additional toilets needed to be constructed"
chkhdr EB  "toilets that need repair"
chkhdr EF  "Windows that need repair"
chkhdr EG  "Room Doors that need Repair"
chkhdr EH  "Room Doors that need replacement"
chkhdr FE  "Students desks available"
chkhdr FF  "Multipurpose tables"
chkhdr FG  "Gillam available for ECE"
chkhdr DK  "Non-Function"
chkexact DB "Total Teachers Posted"
chkhdr DS  "Functional Boys Toilets"
chkhdr DT  "Functional Girls Toilets"
chkgrades "AY AZ BA BB BC BD BF BG BH BJ BK BL BM"
chkgrades "BP BQ BR BS BT BU BW BX BY CA CB CC CD"
chkexact BO "Total Boys"
chkexact CF "Total Girls"

drop in 1
gen bemis = real(D)
drop if missing(bemis)
isid bemis
merge 1:1 bemis using `ie', keep(match) keepusing(arm) nogenerate
drop arm
assert _N == 127

* yes/no items and counts (same question in both rounds)
yn  govt_bldg      AB
yn  space_constr   AC
yn  play_space     AG
yn  cpd            AQ
yn  ptsmc_formed   AR
yn  playground     DX
yn  boundary       EC
yn  gate           EI
yn  roof_repair    EK
yn  roof_replace   EL
yn  water          EM
yn  elec_school    EP
yn  gas            ES
yn  water_tank     EU
yn  water_pump     EX
yn  ece_room       FA
yn  desk_short     FH
yn  disab          FL
yn  ptsmc_trained_c AT
yn  ptsmc_func_c   AU
yn  elec_area_c    ER
num tch_posted     DB
num tch_ece        DC
num tch_induct     DD
num rm_kacha       DG
num rm_pakka       DH
num rm_func_k_c    DI
num rm_func_p_c    DJ
num rm_nonf_k_c    DK
num rm_nonf_p_c    DL
num tl_boys        DO
num tl_girls       DP
num need_rooms     DY
num need_rm_rep    DZ
num need_toilets   EA
num need_tl_rep    EB
num need_windows   EF
num need_door_rep  EG
num need_door_new  EH
num desks          FE
num mp_tables      FF
num gillam         FG

* enrolment by grade
grades b "AY AZ BA BB BC BD BF BG BH BJ BK BL BM"
grades g "BP BQ BR BS BT BU BW BX BY CA CB CC CD"
* grade columns must add up to the reported totals
egen double _sb = rowtotal(b_kachi b_c1 b_c2 b_c3 b_c4 b_c5 b_c6 b_c7 b_c8 b_c9 b_c10 b_c11 b_c12)
egen double _sg = rowtotal(g_kachi g_c1 g_c2 g_c3 g_c4 g_c5 g_c6 g_c7 g_c8 g_c9 g_c10 g_c11 g_c12)
num _tb BO
num _tg CF
assert _sb == _tb & _sg == _tg
drop _sb _sg _tb _tg

* functional toilets (one question per sex in this round)
num tl_boys_func  DS
num tl_girls_func DT

gen src_fall = 1
keep bemis govt_bldg space_constr play_space cpd ptsmc_formed playground boundary gate ///
        roof_repair roof_replace water elec_school gas water_tank water_pump ece_room ///
        desk_short disab ptsmc_trained_c ptsmc_func_c elec_area_c tch_posted tch_ece ///
        tch_induct rm_kacha rm_pakka rm_func_k_c rm_func_p_c rm_nonf_k_c rm_nonf_p_c ///
        tl_boys tl_girls need_rooms need_rm_rep need_toilets need_tl_rep need_windows ///
        need_door_rep need_door_new desks mp_tables gillam b_kachi b_c1 b_c2 b_c3 b_c4 ///
        b_c5 b_c6 b_c7 b_c8 b_c9 b_c10 b_c11 b_c12 g_kachi g_c1 g_c2 g_c3 g_c4 g_c5 ///
        g_c6 g_c7 g_c8 g_c9 g_c10 g_c11 g_c12 tl_boys_func tl_girls_func src_fall
tempfile fall
save `fall'


*------------------------------------------------------------------------------
* 3. May 2026 field validation (180 IE schools)
*------------------------------------------------------------------------------
import excel using "${may_rtsm}", clear allstring

* header checks
chkhdr I "BEMIS"
chkhdr AE  "Government-owned Building"
chkhdr AF  "space available for construction within the school premises"
chkhdr AJ  "space for play area available"
chkhdr CO  "under the CPD program"
chkhdr CZ  "Is PTSMC Formed"
chkhdr GH  "Is a playground available"
chkhdr GM  "Boundary wall already available"
chkhdr GS  "Is a Gate already available"
chkhdr GU  "Does the roof need repairing"
chkhdr GV  "Does the roof need replacement"
chkhdr GW  "Is Water Available"
chkhdr GZ  "Is electricity available in the school"
chkhdr HE  "Is gas available in the school"
chkhdr HG  "Is a water tank available in the school"
chkhdr HO  "Is a water pump available"
chkhdr HU  "Is an ECE room available in the school"
chkhdr IB  "is there shortage of desk"
chkhdr IF  "Is there any student with disability"
chkhdr DC  "PTSMC Members Trained"
chkhdr DD  "Is PTSMC Functional"
chkhdr HB  "is Electricity available in the area"
chkhdr FH  "Teachers Posted"
chkhdr FK  "teachers trained on ECE"
chkhdr FL  "teachers trained on induction"
chkhdr FM  "Total No of Kacha Rooms"
chkhdr FN  "Total No of Pakka Rooms"
chkhdr FO  "Functional Kacha Rooms"
chkhdr FP  "Functional Pakka Rooms"
chkhdr FQ  "Kacha Rooms"
chkhdr FR  "Non-Functional Pakka Rooms"
chkhdr FT  "Total No. of Boys Toilets"
chkhdr GA  "Total No. of Girls Toilets"
chkhdr GI  "additional rooms needed to be constructed"
chkhdr GJ  "rooms that need repair"
chkhdr GK  "additional toilets needed to be constructed"
chkhdr GL  "toilets that need repair"
chkhdr GP  "Windows that need repair"
chkhdr GQ  "Room Doors that need Repair"
chkhdr GR  "Room Doors that need replacement"
chkhdr HY  "Students desks available"
chkhdr HZ  "Multipurpose tables"
chkhdr IA  "Gillam available for ECE"
chkhdr FQ  "Non-Function"
chkexact FH "Total Government Teachers Posted"
chkhdr JS  "9.6) No. of Functional Boys Toilets"
chkhdr JU  "9.6) No. of Functional Girls Toilets"
chkhdr FW  "Functional Pakka Boys Toilets"
chkhdr FX  "Functional Kacha Boys Toilets"
chkhdr GD  "Functional Pakka Girls Toilets"
chkhdr GE  "Functional Kacha Girls Toilets"
chkgrades "DI DJ DK DL DM DN DO DP DQ DR DS DT DU"
chkgrades "DY DZ EA EB EC ED EE EF EG EH EI EJ EK"
chkexact DV "Total Boys"
chkexact EL "Total Girls"

drop in 1
gen bemis = real(I)
drop if missing(bemis)
isid bemis
merge 1:1 bemis using `ie', keep(match) keepusing(arm) nogenerate
drop arm
assert _N == 180

* yes/no items and counts (same question in both rounds)
yn  govt_bldg      AE
yn  space_constr   AF
yn  play_space     AJ
yn  cpd            CO
yn  ptsmc_formed   CZ
yn  playground     GH
yn  boundary       GM
yn  gate           GS
yn  roof_repair    GU
yn  roof_replace   GV
yn  water          GW
yn  elec_school    GZ
yn  gas            HE
yn  water_tank     HG
yn  water_pump     HO
yn  ece_room       HU
yn  desk_short     IB
yn  disab          IF
yn  ptsmc_trained_c DC
yn  ptsmc_func_c   DD
yn  elec_area_c    HB
num tch_posted     FH
num tch_ece        FK
num tch_induct     FL
num rm_kacha       FM
num rm_pakka       FN
num rm_func_k_c    FO
num rm_func_p_c    FP
num rm_nonf_k_c    FQ
num rm_nonf_p_c    FR
num tl_boys        FT
num tl_girls       GA
num need_rooms     GI
num need_rm_rep    GJ
num need_toilets   GK
num need_tl_rep    GL
num need_windows   GP
num need_door_rep  GQ
num need_door_new  GR
num desks          HY
num mp_tables      HZ
num gillam         IA

* enrolment by grade
grades b "DI DJ DK DL DM DN DO DP DQ DR DS DT DU"
grades g "DY DZ EA EB EC ED EE EF EG EH EI EJ EK"
* grade columns must add up to the reported totals
egen double _sb = rowtotal(b_kachi b_c1 b_c2 b_c3 b_c4 b_c5 b_c6 b_c7 b_c8 b_c9 b_c10 b_c11 b_c12)
egen double _sg = rowtotal(g_kachi g_c1 g_c2 g_c3 g_c4 g_c5 g_c6 g_c7 g_c8 g_c9 g_c10 g_c11 g_c12)
num _tb DV
num _tg EL
assert _sb == _tb & _sg == _tg
drop _sb _sg _tb _tg

* functional toilets: Feb-Mar form versions asked one question per sex (JS, JU);
* Apr-May versions split it into pakka + kacha (FW+FX boys, GD+GE girls)
num tl_boys_func  JS
num tl_girls_func JU
num _fw FW
num _fx FX
num _gd GD
num _ge GE
replace tl_boys_func  = _fw + cond(missing(_fx), 0, _fx) if missing(tl_boys_func)
replace tl_girls_func = _gd + cond(missing(_ge), 0, _ge) if missing(tl_girls_func)
assert !missing(tl_boys_func, tl_girls_func)
drop _fw _fx _gd _ge

gen src_fall = 0
keep bemis govt_bldg space_constr play_space cpd ptsmc_formed playground boundary gate ///
        roof_repair roof_replace water elec_school gas water_tank water_pump ece_room ///
        desk_short disab ptsmc_trained_c ptsmc_func_c elec_area_c tch_posted tch_ece ///
        tch_induct rm_kacha rm_pakka rm_func_k_c rm_func_p_c rm_nonf_k_c rm_nonf_p_c ///
        tl_boys tl_girls need_rooms need_rm_rep need_toilets need_tl_rep need_windows ///
        need_door_rep need_door_new desks mp_tables gillam b_kachi b_c1 b_c2 b_c3 b_c4 ///
        b_c5 b_c6 b_c7 b_c8 b_c9 b_c10 b_c11 b_c12 g_kachi g_c1 g_c2 g_c3 g_c4 g_c5 ///
        g_c6 g_c7 g_c8 g_c9 g_c10 g_c11 g_c12 tl_boys_func tl_girls_func src_fall
tempfile may
save `may'


*------------------------------------------------------------------------------
* 4. Combine rounds, merge arms, corrections
*------------------------------------------------------------------------------
use `fall', clear
append using `may'
isid bemis
merge 1:1 bemis using `ie', assert(match) nogenerate
assert _N == 307
count if src_fall == 1
assert r(N) == 127

* Correction: BEMIS 14586 (GGHS Essa Daman Chaman, Transport). The May file's
* first sheet records 0 students in every grade; the PMU "Working sheet" of the
* same file has the girls' grade breakdown (total 68). Use those values.
egen double _chk = rowtotal(b_* g_*) if bemis == 14586
assert _chk == 0 if bemis == 14586
drop _chk
replace g_kachi = 3  if bemis == 14586
replace g_c1    = 6  if bemis == 14586
replace g_c2    = 10 if bemis == 14586
replace g_c3    = 11 if bemis == 14586
replace g_c4    = 3  if bemis == 14586
replace g_c5    = 4  if bemis == 14586
replace g_c6    = 8  if bemis == 14586
replace g_c7    = 6  if bemis == 14586
replace g_c8    = 6  if bemis == 14586
replace g_c9    = 5  if bemis == 14586
replace g_c10   = 6  if bemis == 14586

*------------------------------------------------------------------------------
* 5. Balance variables
*------------------------------------------------------------------------------
* enrolment
egen double enr_girls = rowtotal(g_kachi g_c1 g_c2 g_c3 g_c4 g_c5 g_c6 g_c7 g_c8 g_c9 g_c10 g_c11 g_c12)
egen double enr_boys  = rowtotal(b_kachi b_c1 b_c2 b_c3 b_c4 b_c5 b_c6 b_c7 b_c8 b_c9 b_c10 b_c11 b_c12)
gen  double enr_total = enr_girls + enr_boys
gen  double sh_girls  = 100 * enr_girls / enr_total if enr_total > 0
gen  double enr_g_kachi = g_kachi
egen double enr_g_prim  = rowtotal(g_c1 g_c2 g_c3 g_c4 g_c5)
gen  double enr_g_c5    = g_c5
gen  double enr_b_kachi = b_kachi
egen double enr_b_prim  = rowtotal(b_c1 b_c2 b_c3 b_c4 b_c5)
egen double _post = rowtotal(g_c6 g_c7 g_c8 g_c9 g_c10 g_c11 g_c12 b_c6 b_c7 b_c8 b_c9 b_c10 b_c11 b_c12)
gen  double any_c6_12 = (_post > 0)
drop _post

* teachers: tch_posted = sum of the 17 cadre counts. Fall and the May Feb-Apr form
* versions call it "Total Teachers Posted" (no government/non-government split);
* the May April versions call it "Total Government Teachers Posted" and ask about
* non-government teachers separately (not used: asked of 74 IE schools only).
gen double ptr = enr_total / tch_posted if tch_posted > 0

* classrooms and toilets
gen double rm_func    = rm_func_k_c + rm_func_p_c
gen double rm_nonfunc = rm_nonf_k_c + rm_nonf_p_c
gen double no_pakka   = (rm_pakka == 0) if !missing(rm_pakka)
gen double spr        = enr_total / rm_func if rm_func > 0
gen double any_tl_g   = (tl_girls_func > 0) if !missing(tl_girls_func)

* items asked only of a sub-group, made unconditional
gen double elec_any = elec_area_c
replace    elec_any = 1 if elec_school == 1
gen double ptsmc_trained = ptsmc_trained_c
replace    ptsmc_trained = 0 if ptsmc_formed == 0
gen double ptsmc_func    = ptsmc_func_c
replace    ptsmc_func    = 0 if ptsmc_formed == 0

* labels
label var enr_total      "Total enrolment (Kachi-Class 12)"
label var enr_girls      "Girls enrolled (Kachi-Class 12)"
label var enr_boys       "Boys enrolled (Kachi-Class 12)"
label var sh_girls       "Girls' share of enrolment (percent)"
label var enr_g_kachi    "Girls enrolled in Kachi (pre-primary)"
label var enr_g_prim     "Girls enrolled in Classes 1-5"
label var enr_g_c5       "Girls enrolled in Class 5"
label var enr_b_kachi    "Boys enrolled in Kachi (pre-primary)"
label var enr_b_prim     "Boys enrolled in Classes 1-5"
label var any_c6_12      "Has students in Classes 6-12 (=1)"
label var tch_posted     "Teachers posted (sum of 17 cadre posts)"
label var tch_ece        "Teachers trained in ECE"
label var tch_induct     "Teachers with induction training"
label var ptr            "Pupil-teacher ratio (teachers posted)"
label var rm_pakka       "Pakka rooms"
label var rm_kacha       "Kacha rooms"
label var rm_func        "Functional rooms (pakka + kacha)"
label var rm_nonfunc     "Non-functional rooms (pakka + kacha)"
label var no_pakka       "No pakka room (=1)"
label var spr            "Students per functional room"
label var tl_boys        "Boys' toilets (total)"
label var tl_girls       "Girls' toilets (total)"
label var tl_boys_func   "Functional boys' toilets"
label var tl_girls_func  "Functional girls' toilets"
label var any_tl_g       "Has a functional girls' toilet (=1)"
label var govt_bldg      "Government-owned building (=1)"
label var space_constr   "Space for construction on premises (=1)"
label var play_space     "Space for play area (=1)"
label var playground     "Playground available (=1)"
label var boundary       "Boundary wall available (=1)"
label var gate           "Gate available (=1)"
label var water          "Water available (=1)"
label var elec_school    "Electricity in school (=1)"
label var elec_any       "Electricity in school or in the area (=1)"
label var gas            "Gas in school (=1)"
label var water_tank     "Water tank in school (=1)"
label var water_pump     "Water pump available (=1)"
label var ece_room       "ECE room available (=1)"
label var desk_short     "Shortage of desks (=1)"
label var desks          "Student desks (number)"
label var mp_tables      "Multipurpose tables (number)"
label var gillam         "Gillam for ECE students (number)"
label var need_rooms     "Additional rooms needed"
label var need_rm_rep    "Rooms needing repair"
label var need_toilets   "Additional toilets needed"
label var need_tl_rep    "Toilets needing repair"
label var need_windows   "Windows needing repair/replacement"
label var need_door_rep  "Doors needing repair"
label var need_door_new  "Doors needing replacement"
label var roof_repair    "Roof needs repair (=1)"
label var roof_replace   "Roof needs replacement (=1)"
label var ptsmc_formed   "PTSMC formed (=1)"
label var ptsmc_trained  "PTSMC formed and members trained (=1)"
label var ptsmc_func     "PTSMC formed and functional (=1)"
label var cpd            "School under CPD programme (=1)"
label var disab          "Any student with a disability (=1)"
label var src_fall       "Data from Fall 2025 pre-assessment (=1)"

* balance variable lists (one per table panel)
* Panel A: Enrolment
global bal_A enr_total enr_girls enr_boys sh_girls enr_g_kachi enr_g_prim enr_g_c5 enr_b_kachi ///
        enr_b_prim any_c6_12
* Panel B: Teachers
global bal_B tch_posted tch_ece tch_induct ptr
* Panel C: Rooms and toilets
global bal_C rm_pakka rm_kacha rm_func rm_nonfunc no_pakka spr tl_boys tl_girls tl_boys_func ///
        tl_girls_func any_tl_g
* Panel D: Facilities, land and furniture
global bal_D govt_bldg space_constr play_space playground boundary gate water elec_school ///
        elec_any gas water_tank water_pump ece_room desk_short desks mp_tables gillam
* Panel E: Repair and construction needs (as recorded by enumerator)
global bal_E need_rooms need_rm_rep need_toilets need_tl_rep need_windows need_door_rep ///
        need_door_new roof_repair roof_replace
* Panel F: Management, programmes and data source
global bal_F ptsmc_formed ptsmc_trained ptsmc_func cpd disab src_fall

* joint F-test set: no missing values, no exact linear dependence
global ftest_vars enr_girls enr_boys enr_g_kachi enr_b_kachi tch_posted rm_pakka rm_kacha rm_func ///
        tl_girls_func tl_boys_func govt_bldg space_constr play_space playground ///
        boundary gate water elec_school water_tank ece_room desk_short need_rooms ///
        need_toilets roof_repair ptsmc_formed src_fall

* the F-test set must have no missing values (iebaltab v7 drops fmissok)
foreach v of global ftest_vars {
    assert !missing(`v')
}

compress
save "${out}/grades_b_balance_data.dta", replace

*------------------------------------------------------------------------------
* 6. Balance tables
*------------------------------------------------------------------------------
* iebaltab v7 shows ONE statistic per comparison: stats(... pair(diff)) shows the
* difference in means with significance stars. p-values and N per comparison are
* written to the matching *_allstats.xlsx file (columns p_1_2, n_1_2, etc.).
local opts groupvar(arm) fixedeffect(${fe}) vce(robust) ///
    stats(desc(se) pair(diff)) rowvarlabels nonote replace
* F-test tables: same, but the F-test row shows its p-value instead of the F statistic
local optsF groupvar(arm) fixedeffect(${fe}) vce(robust) ///
    stats(desc(se) pair(diff) f(p)) rowvarlabels nonote replace

local note3 "Robust standard errors in parentheses. Differences are raw differences in means. Stars from OLS of each variable on the pair dummy with tehsil fixed effects and robust standard errors: * p<0.10, ** p<0.05, *** p<0.01. One IE school per cluster."
if "${fe}" == "district_fe" local note3 : subinstr local note3 "tehsil fixed effects" "district fixed effects"

* (1) All IE schools, three arms
foreach p in A B C D E F {
    iebaltab ${bal_`p'}, `opts' order(1 2 3)                     ///
        savexlsx("${out}/3arm/bal_3arm_`p'.xlsx")                 ///
        savetex("${out}/3arm/bal_3arm_`p'.tex") addnote("`note3'")
    mat balR = r(iebtab_rmat)
    mat balF = r(iebtab_fmat)
    savemat "${out}/3arm/bal_3arm_`p'_allstats.xlsx"
}
iebaltab ${ftest_vars}, `optsF' order(1 2 3) ftest                 ///
    savexlsx("${out}/3arm/bal_3arm_ftest.xlsx")                   ///
    savetex("${out}/3arm/bal_3arm_ftest.tex") addnote("`note3'")
mat balR = r(iebtab_rmat)
mat balF = r(iebtab_fmat)
savemat "${out}/3arm/bal_3arm_ftest_allstats.xlsx"

* (2) Like-for-like: Transport vs girls'/co-ed Comparison schools
foreach p in A B C D E F {
    iebaltab ${bal_`p'} if girls_coed == 1 & inlist(arm, 1, 3), `opts' ///
        savexlsx("${out}/TvC_girls/bal_TvC_girls_`p'.xlsx")             ///
        savetex("${out}/TvC_girls/bal_TvC_girls_`p'.tex") addnote("`note3'")
    mat balR = r(iebtab_rmat)
    mat balF = r(iebtab_fmat)
    savemat "${out}/TvC_girls/bal_TvC_girls_`p'_allstats.xlsx"
}
iebaltab ${ftest_vars} if girls_coed == 1 & inlist(arm, 1, 3), `optsF' ftest ///
    savexlsx("${out}/TvC_girls/bal_TvC_girls_ftest.xlsx")                   ///
    savetex("${out}/TvC_girls/bal_TvC_girls_ftest.tex") addnote("`note3'")
mat balR = r(iebtab_rmat)
mat balF = r(iebtab_fmat)
savemat "${out}/TvC_girls/bal_TvC_girls_ftest_allstats.xlsx"

* (3) Like-for-like: Double shift vs boys' Comparison schools
foreach p in A B C D E F {
    iebaltab ${bal_`p'} if girls_coed == 0 & inlist(arm, 2, 3), `opts' ///
        savexlsx("${out}/DSvC_boys/bal_DSvC_boys_`p'.xlsx")             ///
        savetex("${out}/DSvC_boys/bal_DSvC_boys_`p'.tex") addnote("`note3'")
    mat balR = r(iebtab_rmat)
    mat balF = r(iebtab_fmat)
    savemat "${out}/DSvC_boys/bal_DSvC_boys_`p'_allstats.xlsx"
}
iebaltab ${ftest_vars} if girls_coed == 0 & inlist(arm, 2, 3), `optsF' ftest ///
    savexlsx("${out}/DSvC_boys/bal_DSvC_boys_ftest.xlsx")                   ///
    savetex("${out}/DSvC_boys/bal_DSvC_boys_ftest.tex") addnote("`note3'")
mat balR = r(iebtab_rmat)
mat balF = r(iebtab_fmat)
savemat "${out}/DSvC_boys/bal_DSvC_boys_ftest_allstats.xlsx"

*------------------------------------------------------------------------------
* 7. All balance results in ONE Excel file: ${out}/GRADES_B_balance_ALL.xlsx
*    Sheets "1 Three arms", "2 T vs C girls-coed", "3 DS vs C boys": one row per
*    variable (all 57) with N, mean, SE per group and difference, p-value, N per
*    comparison. Sheet "F-tests": N, F and p-value of each joint F-test.
*------------------------------------------------------------------------------
global allvars ${bal_A} ${bal_B} ${bal_C} ${bal_D} ${bal_E} ${bal_F}
global onefile "${out}/GRADES_B_balance_ALL.xlsx"
capture erase "${onefile}"

* xlsheet: writes the last iebaltab result (copied to matrix balR) to one sheet
*   groups(): group codes in the table, e.g. "1 2 3"
*   pairs():  comparisons, e.g. "1_2 1_3 2_3" (1 Transport, 2 Double shift, 3 Comparison)
capture program drop xlsheet
program define xlsheet
    syntax, sheet(string) groups(string) pairs(string)
    local vars : rownames balR
    local nv   : word count `vars'
    forvalues i = 1/`nv' {
        local v : word `i' of `vars'
        local lab`i' : variable label `v'
    }
    foreach g of local groups {
        local gname`g' : label arm `g'
    }
    local sn_n    "N"
    local sn_mean "Mean"
    local sn_se   "SE"
    local sn_diff "Difference"
    local sn_p    "p-value"
    preserve
    clear
    quietly set obs `nv'
    quietly gen str32  variable = ""
    quietly gen str244 varlabel = ""
    forvalues i = 1/`nv' {
        quietly replace variable = "`: word `i' of `vars''" in `i'
        quietly replace varlabel = `"`lab`i''"' in `i'
    }
    label var variable "Variable"
    label var varlabel "Label"
    foreach g of local groups {
        foreach s in n mean se {
            quietly gen double `s'_`g' = .
            local c = colnumb(balR, "`s'_`g'")
            forvalues i = 1/`nv' {
                quietly replace `s'_`g' = el(balR, `i', `c') in `i'
            }
            label var `s'_`g' "`gname`g'': `sn_`s''"
        }
    }
    foreach p of local pairs {
        local g1 = substr("`p'", 1, 1)
        local g2 = substr("`p'", 3, 1)
        foreach s in diff p n {
            quietly gen double `s'_`p' = .
            local c = colnumb(balR, "`s'_`p'")
            forvalues i = 1/`nv' {
                quietly replace `s'_`p' = el(balR, `i', `c') in `i'
            }
            label var `s'_`p' "`gname`g1'' - `gname`g2'': `sn_`s''"
        }
    }
    export excel using "${onefile}", sheet("`sheet'") sheetreplace firstrow(varlabels)
    restore
end

* frow: fills one row of the F-test sheet from an iebaltab F-test matrix
capture program drop frow
program define frow
    args r m pr tbl cmp
    quietly replace table      = "`tbl'" in `r'
    quietly replace comparison = "`cmp'" in `r'
    quietly replace N      = el(`m', 1, colnumb(`m', "fn_`pr'")) in `r'
    quietly replace F      = el(`m', 1, colnumb(`m', "ff_`pr'")) in `r'
    quietly replace pvalue = el(`m', 1, colnumb(`m', "fp_`pr'")) in `r'
end

local est groupvar(arm) fixedeffect(${fe}) vce(robust)

* balance tables: all variables, one sheet each
iebaltab ${allvars}, `est' order(1 2 3)
mat balR = r(iebtab_rmat)
xlsheet, sheet("1 Three arms") groups("1 2 3") pairs("1_2 1_3 2_3")

iebaltab ${allvars} if girls_coed == 1 & inlist(arm, 1, 3), `est'
mat balR = r(iebtab_rmat)
xlsheet, sheet("2 T vs C girls-coed") groups("1 3") pairs("1_3")

iebaltab ${allvars} if girls_coed == 0 & inlist(arm, 2, 3), `est'
mat balR = r(iebtab_rmat)
xlsheet, sheet("3 DS vs C boys") groups("2 3") pairs("2_3")

* joint F-tests
iebaltab ${ftest_vars}, `est' order(1 2 3) ftest
mat F1 = r(iebtab_fmat)
iebaltab ${ftest_vars} if girls_coed == 1 & inlist(arm, 1, 3), `est' ftest
mat F2 = r(iebtab_fmat)
iebaltab ${ftest_vars} if girls_coed == 0 & inlist(arm, 2, 3), `est' ftest
mat F3 = r(iebtab_fmat)

preserve
clear
quietly set obs 5
gen str40 table      = ""
gen str40 comparison = ""
gen double N      = .
gen double F      = .
gen double pvalue = .
frow 1 F1 1_2 "1 Three arms"        "Transport - Double shift"
frow 2 F1 1_3 "1 Three arms"        "Transport - Comparison"
frow 3 F1 2_3 "1 Three arms"        "Double shift - Comparison"
frow 4 F2 1_3 "2 T vs C girls-coed" "Transport - Comparison"
frow 5 F3 2_3 "3 DS vs C boys"      "Double shift - Comparison"
label var table      "Table"
label var comparison "Comparison"
label var N          "N (schools in the F-test)"
label var F          "F statistic"
label var pvalue     "p-value"
export excel using "${onefile}", sheet("F-tests") sheetreplace firstrow(varlabels)
restore

di as result "Done. Tables saved in ${out}; all results in one file: ${onefile}"
