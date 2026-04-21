

use "C:\Users\wb635947\OneDrive - WBG\HEDGE Files - 03_GEPD_processed_data\School\Anonymized\first_grade_assessment.dta", clear

rename ecd_student_knowledge student_knowledge
rename ecd_student_proficiency student_proficient
rename m6s1q3 m8s1q3


append using "C:\Users\wb635947\OneDrive - WBG\HEDGE Files - 03_GEPD_processed_data\School\Anonymized\fourth_grade_assessment.dta"
keep if m8s1q3 == 2
