

use "C:\Users\wb635947\OneDrive - WBG\HEDGE Files - 03_GEPD_processed_data\School\Anonymized\first_grade_assessment.dta", clear

rename ecd_student_knowledge student_knowledge
rename ecd_student_proficiency student_proficient

append using "C:\Users\wb635947\OneDrive - WBG\HEDGE Files - 03_GEPD_processed_data\School\Anonymized\fourth_grade_assessment.dta"
