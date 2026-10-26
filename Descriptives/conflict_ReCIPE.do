* ============================================================
* GRADES-B / KPRAP — ACLED Data Cleaning
* Filter Asia-Pacific export to Pakistan, then Balochistan, KP, Sindh & Punjab
* ============================================================

clear all
set more off

* ---- 1. Set path (use compound quotes because of the apostrophe in "Sethi's") ----
global raw `"C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Project files\Data\ACLED"'

* ---- 2. Import raw data (xlsx) ----
import excel `"$raw\Asia-Pacific_full_data_up_to-2026-07-10.xlsx"', sheet("Sheet1") firstrow clear


* ---- 3. Filter to KPK, Balochistan, Sindh & Punjab ----
keep if inlist(ADMIN1, "Balochistan", "Khyber Pakhtunkhwa")
keep if inlist(COUNTRY, "Pakistan")

count

* ---- 7. Parse event_date into a proper Stata date ----
* Excel imports sometimes bring event_date in as a numeric Excel date
* rather than text — check `describe` output from step 3 first.
* If event_date shows up as %td already (numeric/date type), skip this
* block entirely and just do: gen year = year(event_date)
capture confirm string variable EVENT_DATE
if !_rc {
    gen date = date(EVENT_DATE, "DMY")
    format date %td
}
else {
    gen date = EVENT_DATE
    format date %td
}
gen year = year(date)
gen month = month(date)

* ---- 8. Quick checks on the filtered sample ----
tab ADMIN1
tab year
tab EVENT_TYPE
tab EVENT_TYPE ADMIN1

* ---- 9. Save cleaned province-level file ----
save `"$raw\ACLED_Balochistan_KP_Sindh_Punjab_2018-2026.dta"', replace
export delimited `"$raw\ACLED_Balochistan_KP_Sindh_Punjab_2018-2026.csv"', replace

* ============================================================
* PART B — Stacked bar charts, raw counts, single y-axis
* Bar height = total events that year; number labeled on top
* ============================================================
global raw `"C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Project files\Data\ACLED"'
cd `"$raw"'

use "ACLED_Balochistan_KP_Sindh_Punjab_2018-2026.dta", clear

* ---- 10. Collapse to province-year-event_type counts ----
contract ADMIN1 YEAR EVENT_TYPE, freq(n)

* ---- 11. Year totals per province ----
bysort ADMIN1 YEAR: egen year_total = total(n)

* ---- 12. Clean event_type text into valid variable-name suffixes ----
gen etype = EVENT_TYPE
replace etype = subinstr(etype, " ", "_", .)
replace etype = subinstr(etype, "/", "_", .)
replace etype = subinstr(etype, "-", "_", .)

tab etype

save "collapsed_year_admin1_eventtype.dta", replace

* ---- 13. Loop over all four provinces ----
foreach prov in "Balochistan" "Khyber Pakhtunkhwa" "Sindh" "Punjab" {

    use "collapsed_year_admin1_eventtype.dta", clear
    keep if ADMIN1 == "`prov'"

    tab ADMIN1
    count
    if r(N) == 0 {
        di as error "No observations for `prov' — check ADMIN1 spelling"
        exit 198
    }

    local provfile = subinstr("`prov'", " ", "_", .)

    preserve
        keep YEAR year_total
        duplicates drop
        save "`provfile'_totals.dta", replace
    restore

    drop EVENT_TYPE year_total ADMIN1

    duplicates report YEAR etype

    reshape wide n, i(YEAR) j(etype) string

    merge 1:1 YEAR using "`provfile'_totals.dta", nogen
    sort YEAR

    * CHECK — confirm exact column names before the hardcoded gen lines below
    ds n*
    di "`r(varlist)'"

    foreach v of varlist n* {
        replace `v' = 0 if missing(`v')
    }

    * ---- 14. Cumulative RAW COUNTS for stacking ----
    gen cum0 = 0
    gen cum1 = cum0 + nBattles
    gen cum2 = cum1 + nViolence_against_civilians
    gen cum3 = cum2 + nExplosions_Remote_violence
    gen cum4 = cum3 + nRiots
    gen cum5 = cum4 + nProtests
    gen cum6 = cum5 + nStrategic_developments

    * Sanity check — should be 0 for every row
    gen check = cum6 - year_total
    sum check
    drop check

    * ---- 15. Axis scaling ----
    summarize year_total
    local ymax = ceil(r(max)/50)*50
    local step = `ymax'/5

    * ---- 16. Build the stacked chart ----
    twoway ///
        (rbar cum0 cum1 YEAR, barw(0.7) fcolor("31 119 180") lcolor(white) lwidth(vthin)) ///
        (rbar cum1 cum2 YEAR, barw(0.7) fcolor("255 127 14") lcolor(white) lwidth(vthin)) ///
        (rbar cum2 cum3 YEAR, barw(0.7) fcolor("44 160 44")  lcolor(white) lwidth(vthin)) ///
        (rbar cum3 cum4 YEAR, barw(0.7) fcolor("214 39 40")  lcolor(white) lwidth(vthin)) ///
        (rbar cum4 cum5 YEAR, barw(0.7) fcolor("148 103 189") lcolor(white) lwidth(vthin)) ///
        (rbar cum5 cum6 YEAR, barw(0.7) fcolor("140 86 75")  lcolor(white) lwidth(vthin)) ///
        (scatter cum6 YEAR, msymbol(none) mlabel(year_total) mlabpos(12) ///
            mlabsize(small) mlabcolor(black)), ///
        yscale(range(0 `ymax')) ///
        ylabel(0(`step')`ymax', angle(horizontal) labsize(small)) ///
        ytitle("Number of events", size(small)) ///
        xlabel(`=YEAR[1]'(1)`=YEAR[_N]', labsize(small)) ///
        xtitle("") ///
        title("`prov': Number and Composition of Conflict Events by Year", size(medium)) ///
        subtitle("Number above each bar = total ACLED events recorded that year", size(vsmall)) ///
        legend(order(1 "Battles" 2 "Violence against civilians" 3 "Explosions/Remote violence" ///
            4 "Riots" 5 "Protests" 6 "Strategic developments") ///
            position(bottom) rows(2) size(vsmall) region(lcolor(white))) ///
        graphregion(color(white)) plotregion(margin(medium)) ///
        note("Source: ACLED, accessed 10 July 2026", size(vsmall))

    graph export "`provfile'_event_composition.png", width(2000) height(1400) replace
}

* ============================================================
* PART C — Violence Against Civilians: cross-province trend line
* ============================================================
use "collapsed_year_admin1_eventtype.dta", clear
keep if etype == "Violence_against_civilians"
keep ADMIN1 YEAR n

* ---- Clean province names into valid variable-name suffixes ----
replace ADMIN1 = subinstr(ADMIN1, " ", "_", .)

reshape wide n, i(YEAR) j(ADMIN1) string

foreach v of varlist n* {
    replace `v' = 0 if missing(`v')
}

* Rename for readability (adjust if your reshape produced different names —
* run `ds n*` first to confirm)
rename nBalochistan vac_Balochistan
rename nKhyber_Pakhtunkhwa vac_KP
rename nSindh vac_Sindh
rename nPunjab vac_Punjab

sort YEAR

* ---- Axis scaling ----
egen rowmax = rowmax(vac_Balochistan vac_KP vac_Sindh vac_Punjab)
summarize rowmax
local ymax = ceil(r(max)/10)*10
local step = `ymax'/5
drop rowmax

* ---- Build the trend chart ----
twoway ///
    (connected vac_Balochistan YEAR, lcolor("214 39 40") mcolor("214 39 40") msymbol(O) lwidth(medthick)) ///
    (connected vac_KP YEAR, lcolor("31 119 180") mcolor("31 119 180") msymbol(D) lwidth(medthick)) ///
    (connected vac_Sindh YEAR, lcolor("44 160 44") mcolor("44 160 44") msymbol(T) lwidth(medthick)) ///
    (connected vac_Punjab YEAR, lcolor("255 127 14") mcolor("255 127 14") msymbol(S) lwidth(medthick)), ///
    yscale(range(0 `ymax')) ///
    ylabel(0(`step')`ymax', angle(horizontal) labsize(small)) ///
    ytitle("Number of events", size(small)) ///
    xlabel(`=YEAR[1]'(1)`=YEAR[_N]', labsize(small)) ///
    xtitle("") ///
    title("Violence Against Civilians: Trend by Province", size(medium)) ///
    subtitle("ACLED-recorded events, by year", size(vsmall)) ///
    legend(order(1 "Balochistan" 2 "Khyber Pakhtunkhwa" 3 "Sindh" 4 "Punjab") ///
        position(bottom) rows(1) size(small) region(lcolor(white))) ///
    graphregion(color(white)) plotregion(margin(medium)) ///
    note("Source: ACLED, accessed 10 July 2026", size(vsmall))

graph export "Violence_Against_Civilians_trend_by_province.png", width(2000) height(1400) replace