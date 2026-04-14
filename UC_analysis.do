*Author: Hijab Waheed
*Date: 23-02-2025
*Purpose: School list for GRADES B

***Globals

	if c(username) == "wb635947" {
		
		global data "C:\Users\wb635947\OneDrive - WBG\Jayati Sethi's files - Pakistan GRADES-B\Data"
		
	}
	
	if c(username) == "wb630098" {
		
		global data "C:\Users\wb630098\WBG\Jayati Sethi - SAR GIL Projects Team Folder 2023\New Impact Evaluation Candidates\Pakistan GRADES-B\Data"
		
	}

	
********************************************************************************
*Upload the shape file (UC level)
********************************************************************************

import delimited "$data\Analysis\shapefile_UCs.csv", bindquote(strict) clear

keep if province == "Balochistan"
distinct uc 


/*

       |        Observations
       |      total   distinct
-------+----------------------
    uc |        549        529
*/

********************************************************************************
*Upload the shape file (Tehsil level)
********************************************************************************

import delimited "$data\Analysis\shapefile_tehsil.csv", bindquote(strict) clear

keep if province == "BALOCHISTAN"
distinct tehsil 


/*

		|        Observations
        |      total   distinct
--------+----------------------
 tehsil |        130        130

*/
	
	
********************************************************************************
*Upload longlist 
********************************************************************************
	
import delimited using "$data\Dataset\admin\long_list_updated.csv", clear

distinct uc
/*

       |        Observations
       |      total   distinct
-------+----------------------
    uc |       7020       1006
*/

	replace tehsil = upper(tehsil)
	replace tehsil = trim(tehsil)
