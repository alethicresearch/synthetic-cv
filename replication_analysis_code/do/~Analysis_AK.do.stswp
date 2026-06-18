*** IMPORTING DATASET

** columns 5 and 6 from initial data (the ones with the promt) were too heavy, so in this part of the code I am just dropping these two columns
import delimited using data_first.csv, bindquotes(strict) maxquotedrows(unlimited) colrange(1:4)
save part1.dta

clear
import delimited using data_first.csv, bindquotes(strict) maxquotedrows(unlimited) colrange(7:)
save part2.dta

use part1.dta, replace
merge 1:1 _n using part2.dta

save final_part.dta, replace

//checking that dataset imported correctly by comparing with Sankalpa's summary (Excel) file
//collapse (count) freq = caseid, by(variant sub_variant provider type_of_question)

* notice that each caseid has different number of values
use final_part.dta, replace
tab caseid // shouldn't it be  2 variants * 2 subvariants * 9 providers * 11 runs = 396 rows??









*** CREATING PLOTS (Yes share - bid amounts plots)

** main graphs
// make qsa binary and take averages

*for actual data (I got the same results as in Table 2 from the paper)
use final_part.dta, replace
tab qsa_actual_response
drop if qsa_actual_response=="Refused to answer"
gen actual_qsa = 0
replace actual_qsa = 1 if qsa_actual_response == "Support"

collapse (mean) actual_qsa, by(bidding_amount)
save actual_qsa.dta, replace


* for demographics only synthetic data
use final_part.dta, replace
keep if variant=="demographics only"
tab qsa 
drop if qsa == "Unknown"
gen synth_qsa = 0
replace synth_qsa = 1 if qsa == "Support"

collapse (mean) synth_qsa, by(bidding_amount)
save synth_demonly.dta, replace
// NEED to calculate confidence intervals


* for beliefs+demographics synthetic data
use final_part.dta, replace
keep if variant=="beliefs + demographics"
tab qsa // has "Somewhat Oppose" and "Somewhat Support" values
drop if qsa == "Refused" | qsa == "Unknown"
gen synth_beliefs = 0
replace synth_beliefs = 1 if qsa == "Support" | qsa == "Somewhat Support"

collapse (mean) synth_beliefs, by(bidding_amount)
save synth_beliefs.dta, replace
// NEED to calculate confidence intervals


* merging them all
use actual_qsa.dta, replace
merge 1:1 _n using synth_demonly.dta
drop _merge
merge 1:1 _n using synth_beliefs.dta

// plotting data
twoway ///
    (line actual_qsa bidding_amount, mcolor(blue) msymbol(o)) ///
    (line synth_qsa bidding_amount, mcolor(red) msymbol(+)) ///
	(line synth_beliefs bidding_amount, mcolor(green) msymbol(×)), ///
    legend(order(1 "Actual" 2 "Dem_only" 3 "Dem+beliefs")) ///
	ylabel(0(0.1)1) ///
    title("Main Plot")

*changing y-axis scale
twoway ///
    (line actual_qsa bidding_amount, mcolor(blue) msymbol(o)) ///
    (line synth_qsa bidding_amount, mcolor(red) msymbol(+)) ///
	(line synth_beliefs bidding_amount, mcolor(green) msymbol(×)), ///
    legend(order(1 "Actual" 2 "Dem_only" 3 "Dem+beliefs")) ///
    title("Main Plot (rescaled)")
// NEED to calculate confidence intervals




** graphs conditioned on the model used:

///////////////// "openrouter.deepseek/deepseek-chat-v3.1" /////////////////////////////

* for demographics only synthetic data
use final_part.dta, replace
keep if variant=="demographics only"
keep if provider=="openrouter.deepseek/deepseek-chat-v3.1"
tab qsa 
drop if qsa == "Unknown"
gen synth_qsa = 0
replace synth_qsa = 1 if qsa == "Support"

collapse (mean) synth_qsa, by(bidding_amount)
save synth_demonly_deepseek3.dta, replace
// NEED to calculate confidence intervals


* for beliefs+demographics synthetic data
use final_part.dta, replace
keep if variant=="beliefs + demographics"
keep if provider=="openrouter.deepseek/deepseek-chat-v3.1"
tab qsa // has "Somewhat Oppose" and "Somewhat Support" values
drop if qsa == "Refused" | qsa == "Unknown"
gen synth_beliefs = 0
replace synth_beliefs = 1 if qsa == "Support" | qsa == "Somewhat Support"

collapse (mean) synth_beliefs, by(bidding_amount)
save synth_beliefs_deepseek3.dta, replace
// NEED to calculate confidence intervals


* merging them all
use actual_qsa.dta, replace
merge 1:1 _n using synth_demonly_deepseek3.dta
drop _merge
merge 1:1 _n using synth_beliefs_deepseek3.dta

// plotting data
twoway ///
    (line actual_qsa bidding_amount, mcolor(blue) msymbol(o)) ///
    (line synth_qsa bidding_amount, mcolor(red) msymbol(+)) ///
	(line synth_beliefs bidding_amount, mcolor(green) msymbol(×)), ///
    legend(order(1 "Actual" 2 "Dem_only" 3 "Dem+beliefs")) ///
	ylabel(0(0.1)1) ///
    title("deepseek-chat-v3")

*changing y-axis scale
twoway ///
    (line actual_qsa bidding_amount, mcolor(blue) msymbol(o)) ///
    (line synth_qsa bidding_amount, mcolor(red) msymbol(+)) ///
	(line synth_beliefs bidding_amount, mcolor(green) msymbol(×)), ///
    legend(order(1 "Actual" 2 "Dem_only" 3 "Dem+beliefs")) ///
    title("deepseek-chat-v3 (rescaled)")
// NEED to calculate confidence intervals


///////////////// "openrouter.deepseek/deepseek-chat-v3.1" /////////////////////////////

* for demographics only synthetic data
use final_part.dta, replace
keep if variant=="demographics only"
keep if provider=="openrouter.deepseek/deepseek-r1"
tab qsa 
drop if qsa == "Unknown"
gen synth_qsa = 0
replace synth_qsa = 1 if qsa == "Support"

collapse (mean) synth_qsa, by(bidding_amount)
save synth_demonly_deepseek_r1.dta, replace
// NEED to calculate confidence intervals


* for beliefs+demographics synthetic data
use final_part.dta, replace
keep if variant=="beliefs + demographics"
keep if provider=="openrouter.deepseek/deepseek-r1"
tab qsa // has "Somewhat Oppose" and "Somewhat Support" values
drop if qsa == "Refused" | qsa == "Unknown"
gen synth_beliefs = 0
replace synth_beliefs = 1 if qsa == "Support" | qsa == "Somewhat Support"

//keep if bidding_amount==155
//tab qsa

collapse (mean) synth_beliefs, by(bidding_amount)
save synth_beliefs_deepseek_r1.dta, replace
// NEED to calculate confidence intervals


* merging them all
use actual_qsa.dta, replace
merge 1:1 _n using synth_demonly_deepseek_r1.dta
drop _merge
merge 1:1 _n using synth_beliefs_deepseek_r1.dta

// plotting data
twoway ///
    (line actual_qsa bidding_amount, mcolor(blue) msymbol(o)) ///
    (line synth_qsa bidding_amount, mcolor(red) msymbol(+)) ///
	(line synth_beliefs bidding_amount, mcolor(green) msymbol(×)), ///
    legend(order(1 "Actual" 2 "Dem_only" 3 "Dem+beliefs")) ///
	ylabel(0(0.1)1) ///
    title("deepseek-chat-r1")

*changing y-axis scale
twoway ///
    (line actual_qsa bidding_amount, mcolor(blue) msymbol(o)) ///
    (line synth_qsa bidding_amount, mcolor(red) msymbol(+)) ///
	(line synth_beliefs bidding_amount, mcolor(green) msymbol(×)), ///
    legend(order(1 "Actual" 2 "Dem_only" 3 "Dem+beliefs")) ///
    title("deepseek-chat-r1 (rescaled)")
// NEED to calculate confidence intervals


///////////////// "openrouter.google/gemini-2.5-flash" /////////////////////////////

* for demographics only synthetic data
use final_part.dta, replace
keep if variant=="demographics only"
keep if provider=="openrouter.google/gemini-2.5-flash"
tab qsa 
drop if qsa == "Unknown"
gen synth_qsa = 0
replace synth_qsa = 1 if qsa == "Support"

collapse (mean) synth_qsa, by(bidding_amount)
save synth_demonly_gemini-2.5.dta, replace
// NEED to calculate confidence intervals


* for beliefs+demographics synthetic data
use final_part.dta, replace
keep if variant=="beliefs + demographics"
keep if provider=="openrouter.google/gemini-2.5-flash"
tab qsa // has "Somewhat Oppose" and "Somewhat Support" values
drop if qsa == "Refused" | qsa == "Unknown"
gen synth_beliefs = 0
replace synth_beliefs = 1 if qsa == "Support" | qsa == "Somewhat Support"

//keep if bidding_amount==155
//tab qsa

collapse (mean) synth_beliefs, by(bidding_amount)
save synth_beliefs_gemini-2.5.dta, replace
// NEED to calculate confidence intervals


* merging them all
use actual_qsa.dta, replace
merge 1:1 _n using synth_demonly_gemini-2.5.dta
drop _merge
merge 1:1 _n using synth_beliefs_gemini-2.5.dta

// plotting data
twoway ///
    (line actual_qsa bidding_amount, mcolor(blue) msymbol(o)) ///
    (line synth_qsa bidding_amount, mcolor(red) msymbol(+)) ///
	(line synth_beliefs bidding_amount, mcolor(green) msymbol(×)), ///
    legend(order(1 "Actual" 2 "Dem_only" 3 "Dem+beliefs")) ///
	ylabel(0(0.1)1) ///
    title("gemini-2.5")

*changing y-axis scale
twoway ///
    (line actual_qsa bidding_amount, mcolor(blue) msymbol(o)) ///
    (line synth_qsa bidding_amount, mcolor(red) msymbol(+)) ///
	(line synth_beliefs bidding_amount, mcolor(green) msymbol(×)), ///
    legend(order(1 "Actual" 2 "Dem_only" 3 "Dem+beliefs")) ///
    title("gemini-2.5 (rescaled)")
// NEED to calculate confidence intervals


///////////////// "openrouter.google/gemini-2.5-flash-lite" /////////////////////////////

* for demographics only synthetic data
use final_part.dta, replace
keep if variant=="demographics only"
keep if provider=="openrouter.google/gemini-2.5-flash-lite"
tab qsa 
drop if qsa == "Unknown"
gen synth_qsa = 0
replace synth_qsa = 1 if qsa == "Support"

collapse (mean) synth_qsa, by(bidding_amount)
save synth_demonly_gemini-2.5-lite.dta, replace
// NEED to calculate confidence intervals


* for beliefs+demographics synthetic data
use final_part.dta, replace
keep if variant=="beliefs + demographics"
keep if provider=="openrouter.google/gemini-2.5-flash-lite"
tab qsa // has "Somewhat Oppose" and "Somewhat Support" values
drop if qsa == "Refused" | qsa == "Unknown"
gen synth_beliefs = 0
replace synth_beliefs = 1 if qsa == "Support" | qsa == "Somewhat Support"

//keep if bidding_amount==155
//tab qsa

collapse (mean) synth_beliefs, by(bidding_amount)
save synth_beliefs_gemini-2.5-lite.dta, replace
// NEED to calculate confidence intervals


* merging them all
use actual_qsa.dta, replace
merge 1:1 _n using synth_demonly_gemini-2.5-lite.dta
drop _merge
merge 1:1 _n using synth_beliefs_gemini-2.5-lite.dta

// plotting data
twoway ///
    (line actual_qsa bidding_amount, mcolor(blue) msymbol(o)) ///
    (line synth_qsa bidding_amount, mcolor(red) msymbol(+)) ///
	(line synth_beliefs bidding_amount, mcolor(green) msymbol(×)), ///
    legend(order(1 "Actual" 2 "Dem_only" 3 "Dem+beliefs")) ///
	ylabel(0(0.1)1) ///
    title("gemini-2.5")

*changing y-axis scale
twoway ///
    (line actual_qsa bidding_amount, mcolor(blue) msymbol(o)) ///
    (line synth_qsa bidding_amount, mcolor(red) msymbol(+)) ///
	(line synth_beliefs bidding_amount, mcolor(green) msymbol(×)), ///
    legend(order(1 "Actual" 2 "Dem_only" 3 "Dem+beliefs")) ///
    title("gemini-2.5-lite (rescaled)")
// NEED to calculate confidence intervals


///////////////// "openrouter.meta-llama/llama-4-scout" /////////////////////////////

* for demographics only synthetic data
use final_part.dta, replace
keep if variant=="demographics only"
keep if provider=="openrouter.meta-llama/llama-4-scout"
tab qsa 
drop if qsa == "Unknown"
gen synth_qsa = 0
replace synth_qsa = 1 if qsa == "Support"

collapse (mean) synth_qsa, by(bidding_amount)
save synth_demonly_meta-llama.dta, replace
// NEED to calculate confidence intervals


* for beliefs+demographics synthetic data
use final_part.dta, replace
keep if variant=="beliefs + demographics"
keep if provider=="openrouter.meta-llama/llama-4-scout"
tab qsa // has "Somewhat Oppose" and "Somewhat Support" values
drop if qsa == "Refused" | qsa == "Unknown"
gen synth_beliefs = 0
replace synth_beliefs = 1 if qsa == "Support" | qsa == "Somewhat Support"

//keep if bidding_amount==155
//tab qsa

collapse (mean) synth_beliefs, by(bidding_amount)
save synth_beliefs_meta-llama.dta, replace
// NEED to calculate confidence intervals


* merging them all
use actual_qsa.dta, replace
merge 1:1 _n using synth_demonly_meta-llama.dta
drop _merge
merge 1:1 _n using synth_beliefs_meta-llama.dta

// plotting data
twoway ///
    (line actual_qsa bidding_amount, mcolor(blue) msymbol(o)) ///
    (line synth_qsa bidding_amount, mcolor(red) msymbol(+)) ///
	(line synth_beliefs bidding_amount, mcolor(green) msymbol(×)), ///
    legend(order(1 "Actual" 2 "Dem_only" 3 "Dem+beliefs")) ///
	ylabel(0(0.1)1) ///
    title("meta-llama")

*changing y-axis scale
twoway ///
    (line actual_qsa bidding_amount, mcolor(blue) msymbol(o)) ///
    (line synth_qsa bidding_amount, mcolor(red) msymbol(+)) ///
	(line synth_beliefs bidding_amount, mcolor(green) msymbol(×)), ///
    legend(order(1 "Actual" 2 "Dem_only" 3 "Dem+beliefs")) ///
    title("meta-llama (rescaled)")
// NEED to calculate confidence intervals


///////////////// "openrouter.openai/gpt-5-mini" /////////////////////////////

* for demographics only synthetic data
use final_part.dta, replace
keep if variant=="demographics only"
keep if provider=="openrouter.openai/gpt-5-mini"
tab qsa 
drop if qsa == "Unknown"
gen synth_qsa = 0
replace synth_qsa = 1 if qsa == "Support"

collapse (mean) synth_qsa, by(bidding_amount)
save synth_demonly_openai.dta, replace
// NEED to calculate confidence intervals


* for beliefs+demographics synthetic data
use final_part.dta, replace
keep if variant=="beliefs + demographics"
keep if provider=="openrouter.openai/gpt-5-mini"
tab qsa // has "Somewhat Oppose" and "Somewhat Support" values
drop if qsa == "Refused" | qsa == "Unknown"
gen synth_beliefs = 0
replace synth_beliefs = 1 if qsa == "Support" | qsa == "Somewhat Support"

//keep if bidding_amount==155
//tab qsa

collapse (mean) synth_beliefs, by(bidding_amount)
save synth_beliefs_openai.dta, replace
// NEED to calculate confidence intervals


* merging them all
use actual_qsa.dta, replace
merge 1:1 _n using synth_demonly_openai.dta
drop _merge
merge 1:1 _n using synth_beliefs_openai.dta

// plotting data
twoway ///
    (line actual_qsa bidding_amount, mcolor(blue) msymbol(o)) ///
    (line synth_qsa bidding_amount, mcolor(red) msymbol(+)) ///
	(line synth_beliefs bidding_amount, mcolor(green) msymbol(×)), ///
    legend(order(1 "Actual" 2 "Dem_only" 3 "Dem+beliefs")) ///
	ylabel(0(0.1)1) ///
    title("openai")

*changing y-axis scale
twoway ///
    (line actual_qsa bidding_amount, mcolor(blue) msymbol(o)) ///
    (line synth_qsa bidding_amount, mcolor(red) msymbol(+)) ///
	(line synth_beliefs bidding_amount, mcolor(green) msymbol(×)), ///
    legend(order(1 "Actual" 2 "Dem_only" 3 "Dem+beliefs")) ///
    title("openai (rescaled)")
// NEED to calculate confidence intervals










	
*** LOGIT MODELS AND WTP

** changing variables to convenient format

use final_part.dta, replace

gen natgas=0
replace natgas=1 if type_of_question=="natural gas and renewables, such as solar and wind power"

gen nuclear=0
replace nuclear=1 if type_of_question=="nuclear power and renewables, such as solar and wind power"

gen college = 0
replace college = 1 if highest_level_of_school=="Bachelor's degree"
replace college = 1 if highest_level_of_school=="Master's degree"
replace college = 1 if highest_level_of_school=="Professional or doctorate degree"

gen inc0000 = 0
replace inc0000 = 0.25 if income == "Less than $5,000"
replace inc0000 = 0.625 if income == "$5,000 to $7,499"
replace inc0000 = 0.875 if income == "$7,500 to $9,999"
replace inc0000 = 1.125 if income == "$10,000 to $12,499"
replace inc0000 = 1.375 if income == "$12,500 to $14,999"
replace inc0000 = 1.75 if income == "$15,000 to $19,999"
replace inc0000 = 2.25 if income == "$20,000 to $24,999"
replace inc0000 = 2.75 if income == "$25,000 to $29,999"
replace inc0000 = 3.25 if income == "$30,000 to $34,999"
replace inc0000 = 3.75 if income == "$35,000 to $39,999"
replace inc0000 = 4.5 if income == "$40,000 to $49,999"
replace inc0000 = 5.5 if income == "$50,000 to $59,999"
replace inc0000 = 6.75 if income == "$60,000 to $74,999"
replace inc0000 = 8 if income == "$75,000 to $84,999"
replace inc0000 = 9.25 if income == "$85,000 to $99,999"
replace inc0000 = 11.25 if income == "$100,000 to $124,999"
replace inc0000 = 13.75 if income == "$125,000 to $149,999"
replace inc0000 = 16.25 if income == "$150,000 to $174,999"
replace inc0000 = 18.75 if income == "$175,000 to $199,999"

gen male=0
replace male=1 if gender=="Male"

gen white=0
replace white=1 if race == "White, non-Hispanic"

gen repub=0
replace repub=1 if political_party=="Republicans"

gen indep=0
replace indep=1 if political_party=="Independent"

gen noparty=0
replace noparty=1 if political_party=="No party/not interested in politics" | political_party=="Other"

destring bidding_amount household_size age, replace

save temp.dta, replace


** checking data - whether I can reproduce the same results as in paper using actual data

use temp.dta, replace
keep if variant=="demographics only"
duplicates drop caseid, force // 1010 distinct observations

tab qsa_actual_response
drop if qsa_actual_response == "Refused to answer"
gen actual_qsa = 0
replace actual_qsa = 1 if qsa_actual_response == "Support"

logit actual_qsa bidding_amount natgas nuclear college male household_size inc0000 age white repub indep noparty
eststo m1: mfx
esttab, se margin star(* 0.10 ** 0.05 *** 0.01) // the results are the same as in the paper!!

drop _merge
merge m:1 caseid using data_merge

*overall WTP
summarize natgas nuclear college male household_size inc0000 age white repub indep noparty
matrix temppool=(.3473684,.3384875,.277193,.4809198,2.931083,6.768487,45.87227,.6815938,.2418971,.2251066,.1953216)
matrix temppool=(.3489318,.3346897 ,.2878942 ,.4821974,2.816887,7.222279,48.81892,.7436419,.2655137,.242116,.1678535)

wtpcikr bidding_amount natgas nuclear college male household_size inc0000 age white repub indep noparty, reps(1000) mym(temppool)



** now working with synthetic data with demographics only

use temp.dta, replace
keep if variant == "demographics only"
tab qsa
drop if qsa == "Refused" | qsa == "Unknown"
gen synth_qsa = 0
replace synth_qsa = 1 if qsa == "Support" | qsa == "Somewhat Support"

logit synth_qsa bidding_amount natgas nuclear college male household_size inc0000 age white repub indep noparty
eststo m2: mfx

drop _merge
merge m:1 caseid using data_merge

*overall WTP
matrix temppool=(.3473684,.3384875,.277193,.4809198,2.931083,6.768487,45.87227,.6815938,.2418971,.2251066,.1953216)

collapse (mean) actual_qsa bidding_amount natgas nuclear college male household_size inc0000 age white repub indep noparty weight, by(caseid)

wtpcikr bidding_amount natgas nuclear college male household_size inc0000 age white repub indep noparty, reps(1000) mym(temppool)


** now working with synthetic data with demographics and beliefs

use temp.dta, replace
keep if variant == "beliefs + demographics"
tab qsa
drop if qsa == "Refused" | qsa == "Unknown"
gen synth_beliefs = 0
replace synth_beliefs = 1 if qsa == "Support" | qsa == "Somewhat Support"

logit synth_beliefs bidding_amount natgas nuclear college male household_size inc0000 age white repub indep noparty
eststo m3: mfx
esttab m1 m2 m3, se margin star(* 0.10 ** 0.05 *** 0.01)






































	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	










