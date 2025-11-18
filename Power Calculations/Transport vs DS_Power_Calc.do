/********************************************************************
* Date Modified:  18/11/25
* Last Modified by: Umair Kiani
* Project: GRADES - B

*Transport Access vs Double Shift IE

Transport × Double Shift IE – Year 3 power, 2x2

Design in Year 3:
  Factor A: Transport (0 = no transport, 1 = transport)
  Factor B: Double shift (0 = no double shift yet, 1 = double shift starts now)

Cells:
  1) Transport only            
  2) Double shift only         
  3) Transport + double shift  
  4) Neither                   

********************************************************************/

clear all
set more off

* Key assumptions
local alpha  0.05        // two-sided significance level
local power  0.80        // desired power
local delta  0.15        // MDE to detect (in SD units, outcome standardized)
local sd     1           // individual-level SD
local k      12          // students per school (cluster size)
local rho    0.35        // school-level ICC (conservative, from KPRAP)

display as text "Assumptions:"
display as text "  MDE = " `delta' " SD, ICC = " `rho' ", k = " `k' ", sd = " `sd' ", alpha = " `alpha'

quietly power twomeans 0 (`delta'), cluster ///
    m1(`k') m2(`k') sd(`sd') rho(`rho') alpha(`alpha') power(`power')

* Required schools per pooled arm 
capture local J_pooled = ceil(r(K1))
if _rc local J_pooled = ceil(r(k1))

* Convert pooled requirement to per-cell requirement for the 2x2
local J_cell  = ceil(`J_pooled' / 2)   // schools per arm (per cell)
local J_total = 4 * `J_cell'          // total schools across 4 cells

display as result "Required schools per pooled arm (for each main effect): " `J_pooled'
display as result "Required schools per cell (each of 4 arms):            " `J_cell'
display as result "Total Year 3 schools for full 2x2 design:              " `J_total'

