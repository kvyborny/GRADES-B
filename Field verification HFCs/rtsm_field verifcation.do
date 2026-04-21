*Author: Umair Kiani/ Hijab Waheed
*Date: 16-12-2025
*Purpose: School list for GRADES B

***Globals

	if c(username) == "wb635947" {
		
		global rtsmdata "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Data\Admin Data\GRADES B\Round 2\Data\GRADES_B_RTSM_Field_Validation_Survey_-_all_versions_-_False_-_2026-03-17-09-27-46"
				
	}
	
	if c(username) == "wb635947" {
		
		global rtsmdata_clean "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Data\Admin Data\GRADES B\Round 2\Data\GRADES B RTSM Survey v.3.xlsx"
				
	}
	
	if c(username) == "wb630098" {
		
		global rtsmdata "C:\Users\wb630098\WBG\Jayati Sethi - SAR GIL Projects Team Folder 2023\New Impact Evaluation Candidates\Pakistan GRADES-B\Data\Admin Data\GRADES B\Round 2\Data\GRADES_B_RTSM_Field_Validation_Survey_-_all_versions_-_False_-_2026-03-17-09-27-46"
		
	}
	
	
********************************************************************************
*Loading the data
*******************************************************************************

import delimited "$rtsmdata", clear 

*Submission duplicates																// Submitted one form 10 times (additional 9 times)
duplicates report _uuid
duplicates report metarootuuid

*If school coordinates are unique 													// unique coordinates - schools are visited (verfied)
duplicates report gps_coordinates

*Intervention type and distance band 

encode nearest_school_distance_band, gen(dist_band)

label define dist_band_lbl ///
1  "1.0 to 1.5 km" ///
2  "Less than 1.0 km" ///
3  "More than 1.5 km"

tab nearest_school_distance_band dist_band
label values dist_band dist_band_lbl

tab  dist_band ds_te_label, col
																					//~81% DS schools have nearest girls/co-ed more than 1km away
																					//~52% of TE schools have nearest girls/co-ed more than 1.5 away
/*
	 
      
                 |           ds_te_label
       dist_band |            Double ..  Transpo.. |     Total
-----------------+---------------------------------+----------
   1.0 to 1.5 km |         0        237        159 |       396 
                 |      0.00      19.90      25.48 |     21.72 
-----------------+---------------------------------+----------
Less than 1.0 km |         0        203        116 |       319 
                 |      0.00      17.04      18.59 |     17.50 
-----------------+---------------------------------+----------
More than 1.5 km |         0        673        294 |       967 
                 |      0.00      56.51      47.12 |     53.04 
-----------------+---------------------------------+----------
               . |         8         78         55 |       141 
                 |    100.00       6.55       8.81 |      7.73 
-----------------+---------------------------------+----------
           Total |         8      1,191        624 |     1,823 
                 |    100.00     100.00     100.00 |    100.00 




*/

*Boys school reported as nearest school  
count if strmatch(upper(nearest_girls_school_name), "GB*") 							// 269

tab ds_te_label if strmatch(upper(nearest_girls_school_name), "GB*")

/*
         ds_te_label |      Freq.     Percent        Cum.
------------------+-----------------------------------
Double shift (DS) |        183       68.03       68.03
   Transport (TE) |         86       31.97      100.00
------------------+-----------------------------------
            Total |        269      100.00


*/

tab dist_band ds_te_label if strmatch(upper(nearest_girls_school_name), "GB*")

/*
    
                         |      ds_te_label
       dist_band | Double ..  Transpo.. |     Total
-----------------+----------------------+----------
   1.0 to 1.5 km |        52         17 |        69 
Less than 1.0 km |        57         56 |       113 
More than 1.5 km |        74         13 |        87 
-----------------+----------------------+----------
           Total |       183         86 |       269 
 

 
*/

***Clean data****


	
********************************************************************************
*Loading the data - CLEANED DATASET
*******************************************************************************

import excel "$rtsmdata_clean", sheet("GRADES B RTSM Field Validati...") firstrow clear 

drop if DateofVisit ==.

*Submission duplicates																// Submitted one form 10 times (additional 9 times)
duplicates report _uuid
duplicates report metarootuuid

*If school coordinates are unique 													// unique coordinates - schools are visited (verfied)
duplicates report GPSCoordinates

*Intervention type and distance band 

encode AR, gen(dist_band)

label define dist_band_lbl ///
1  "1.0 to 1.5 km" ///
2  "Less than 1.0 km" ///
3  "More than 1.5 km"

tab AR dist_band
label values dist_band dist_band_lbl

tab  dist_band ds_te_label, col
																					//~79% DS schools have nearest girls/co-ed more than 1km away
																					//~52% of TE schools have nearest girls/co-ed more than 1.5 away
/*
	 
      
         distance band to |
    this nearest |
     girls/co-ed |      ds_te_label
     school (km) | Double ..  Transpo.. |     Total
-----------------+----------------------+----------
   1.0 to 1.5 km |       238        154 |       392 
                 |     21.12      27.65 |     23.28 
-----------------+----------------------+----------
Less than 1.0 km |       177        113 |       290 
                 |     15.71      20.29 |     17.22 
-----------------+----------------------+----------
More than 1.5 km |       712        290 |     1,002 
                 |     63.18      52.06 |     59.50 
-----------------+----------------------+----------
           Total |     1,127        557 |     1,684 
                 |    100.00     100.00 |    100.00 



*/

*Boys school reported as nearest school  
count if strmatch(upper(AO), "GB*") 							// 6

tab ds_te_label if strmatch(upper(AO), "GB*")


tab dist_band ds_te_label if strmatch(upper(AO), "GB*")

/*
    
      3.3) Approximate |
distance band to |
    this nearest |
     girls/co-ed |      ds_te_label
     school (km) | Double ..  Transpo.. |     Total
-----------------+----------------------+----------
   1.0 to 1.5 km |         0          1 |         1 
Less than 1.0 km |         1          2 |         3 
More than 1.5 km |         2          0 |         2 
-----------------+----------------------+----------
           Total |         3          3 |         6 

 

 
*/