*Author: Umair Kiani/ Hijab Waheed
*Date: 16-12-2025
*Purpose: School list for GRADES B

***Globals

	if c(username) == "wb635947" {
		
		global rtsmdata "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Data\Admin Data\GRADES B\Round 2\Data\GRADES_B_RTSM_Field_Validation_Survey_-_all_versions_-_False_-_2026-02-19-08-24-41.csv"
		
	}
	
	if c(username) == "wb630098" {
		
		global rtsmdata "C:\Users\wb630098\WBG\Jayati Sethi - SAR GIL Projects Team Folder 2023\New Impact Evaluation Candidates\Pakistan GRADES-B\Data\Admin Data\GRADES B\Round 2\Data\GRADES_B_RTSM_Field_Validation_Survey_-_all_versions_-_False_-_2026-02-19-08-24-41.csv"
		
	}

	
********************************************************************************
*Loading the data
*******************************************************************************

import delimited "$rtsmdata", clear 

*Submission duplicates																// no duplicates
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
																					//87.3% DS schools have nearest girls/co-ed more than 1km away
																					//52.85% of TE schools have nearest girls/co-ed more than 1.5 away
/*
	             |      ds_te_label
       dist_band | Double ..  Transpo.. |     Total
-----------------+----------------------+----------
   1.0 to 1.5 km |        16          4 |        20 
                 |     25.40      14.81 |     22.22 
-----------------+----------------------+----------
Less than 1.0 km |         8          9 |        17 
                 |     12.70      33.33 |     18.89 
-----------------+----------------------+----------
More than 1.5 km |        39         14 |        53 
                 |     61.90      51.85 |     58.89 
-----------------+----------------------+----------
           Total |        63         27 |        90 
                 |    100.00     100.00 |    100.00 


*/

*Boys school reported as nearest school  
count if strmatch(upper(nearest_girls_school_name), "GB*") 							// 11

tab ds_te_label if strmatch(upper(nearest_girls_school_name), "GB*")

/*
    ds_te_label |      Freq.     Percent        Cum.
------------------+-----------------------------------
Double shift (DS) |          5       45.45       45.45
   Transport (TE) |          6       54.55      100.00
------------------+-----------------------------------
            Total |         11      100.00
*/

tab dist_band ds_te_label if strmatch(upper(nearest_girls_school_name), "GB*")

/*
        |      ds_te_label
       dist_band | Double ..  Transpo.. |     Total
-----------------+----------------------+----------
   1.0 to 1.5 km |         1          1 |         2 
Less than 1.0 km |         2          4 |         6 
More than 1.5 km |         2          1 |         3 
-----------------+----------------------+----------
           Total |         5          6 |        11 
*/

