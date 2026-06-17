* Project:		LLM for Contingent Valuation
* Author:		Alina Khindanova (edited by Trevor Woolley)
* Date created:	Nov 21, 2025
* Purpose:		Import raw LLM result data (made by Sankalpa) and produce figures
*******************************************************************************
global datadir "D:\Projects\LLM_CV\data"
global figdir "D:\Projects\LLM_CV\figures"
global tabdir "D:\Projects\LLM_CV\figures\tables"

graph set window fontface "Times New Roman"
graph set eps fontface "Times New Roman"

sysdir set PERSONAL "C:\Users\trevor_woolley\ado\personal\"
sysdir set PLUS "C:\Users\trevor_woolley\ado\plus\"

ssc install wtpcikr
ssc install grc1leg2
*******************************************************************************
							* Pull in data
*******************************************************************************
	use ${datadir}/working_data_Var3.dta, clear
	
*******************************************************************************
							* FIGURES
*******************************************************************************
	** main graphs
	*for actual data (I got the same results as in Table 2 from the paper)
// 	preserve
// 		tab qsa_actual_response
// 		drop if qsa_actual_response=="Refused to answer"
//		
// 		gen actual_qsa = 0
// 		replace actual_qsa = 1 if qsa_actual_response == "Support"
//
// 		collapse (mean) actual_qsa, by(bidding_amount)
// 		save  ${datadir}/actual_qsa.dta, replace
// 	restore
*******************************************************************************
	* for single belief Q+demographics synthetic data
	// Takes like two minutes to run
		forvalues i = 1/13 {
			preserve
				keep if beliefQ_id == `i'
				tab qsa // has "Somewhat Oppose" and "Somewhat Support" values
				drop if qsa == "Refused" | qsa == "Unknown"
				gen synth_beliefQ = 0
				replace synth_beliefQ = 1 if qsa == "Support" | qsa == "Somewhat Support"
				
				* First collapse by provider (LLM)
				// `i' is the belief question. There are 9.
				collapse (mean) synth_beliefQ_mean_`i'_ = synth_beliefQ (first) provider, by(provider_id bidding_amount)
				
				reshape wide synth_beliefQ_mean_`i'_  provider, i(bidding_amount) j(provider_id)
				gen synth_beliefQ_mean_`i' = (synth_beliefQ_mean_`i'_1 + synth_beliefQ_mean_`i'_2 + synth_beliefQ_mean_`i'_3 + synth_beliefQ_mean_`i'_4 + synth_beliefQ_mean_`i'_5 + synth_beliefQ_mean_`i'_6 + synth_beliefQ_mean_`i'_7 + synth_beliefQ_mean_`i'_8 + synth_beliefQ_mean_`i'_9)/9
				
				sort bidding_amount
				if `i' == 1 {
					save  ${datadir}/synth_beliefQ_byProvider_Var3.dta, replace
				}
				else {
					merge 1:1 bidding_amount using  ${datadir}/synth_beliefQ_byProvider_Var3.dta
					drop _merge
					save  ${datadir}/synth_beliefQ_byProvider_Var3.dta, replace
				}
			restore
		}
		
	
*******************************************************************************

	* merging them all
	use  ${datadir}/actual_qsa.dta, clear
	merge 1:1 bidding_amount using  ${datadir}/synth_demonly_byProvider.dta
	drop _merge
	merge 1:1 bidding_amount using  ${datadir}/synth_beliefs_byProvider.dta
	drop _merge
	merge 1:1 bidding_amount using  ${datadir}/synth_beliefQ_byProvider_Var3.dta

	* Plot Actual vs. Synth (without beliefs) by Provider
	// synth_qsa_mean2 synth_qsa_mean4 synth_qsa_mean6 synth_qsa_mean8 synth_qsa_mean10  synth_qsa_mean12 synth_qsa_mean14 synth_qsa_mean16 synth_qsa_mean18
	forval whichQ = 1/13 {
		 twoway ///
		(line actual_qsa bidding_amount, lcolor(red)) ///
		(line synth_beliefQ_mean_`whichQ'_9 bidding_amount, lcolor(black) lpattern(solid)) ///
		(line synth_beliefQ_mean_`whichQ' bidding_amount, lcolor(black) lpattern(longdash_dot)) ///
		(line synth_beliefQ_mean_`whichQ'_5 bidding_amount, lcolor(black) lpattern(dash_dot)) ///
		(line synth_beliefQ_mean_`whichQ'_6 bidding_amount, lcolor(gray) lpattern(dash)) ///
		(line synth_beliefQ_mean_`whichQ'_1 bidding_amount, lcolor(gray) lpattern(dash)) ///
		(line synth_beliefQ_mean_`whichQ'_2 bidding_amount, lcolor(gray) lpattern(dash)) ///
		(line synth_beliefQ_mean_`whichQ'_3 bidding_amount, lcolor(gray) lpattern(dash)) ///
		(line synth_beliefQ_mean_`whichQ'_4 bidding_amount, lcolor(gray) lpattern(dash)) ///
		(line synth_beliefQ_mean_`whichQ'_7 bidding_amount, lcolor(gray) lpattern(dash)) ///
		, legend(order(1 "actual" 2 "gpt-5-mini" 3 "kimi-k2" 4 "llama-4-scout" ) col(2) ) ///
		ylabel(0(0.1)1) ///
		xtitle("Bid Amount ($)") ///
		ytitle("") ///
		title("Belief Q `whichQ'") ///
		xlabel(5 35 45 65 85 105 135 155) ///
		saving(beliefQ_`whichQ', replace) 
		
		graph export "${figdir}/bid_amount_actual_v_beliefQ`whichQ'_Var3_v2.png", replace
	}
	
	// Best without beliefs: openrouter.moonshotai/kimi-k2 openrouter.openai/gpt-5-mini
	// ^ Provider_ids: 8 and 9
	// Best with beliefs: openrouter.mistralai/mistral-medium-3.1 
	// ^ provider_id: 6)
	// Best with any single belief Q: gpt-5-mini and llama-4-scout
	// But some questions throw them off.
	
	* Combine all these graphs into a single image
	grc1leg2 beliefQ_1.gph beliefQ_2.gph beliefQ_3.gph ///
	beliefQ_4.gph beliefQ_5.gph beliefQ_6.gph beliefQ_7.gph ///
	beliefQ_8.gph beliefQ_9.gph beliefQ_10.gph beliefQ_11.gph ///
	beliefQ_12.gph beliefQ_13.gph ///
	, col(3)  ysize(20) xsize(15) ///
	legendfrom(beliefQ_1.gph) ///
	pos(6) ring(0) noauto lxo(20)
	
// 	graph export "${figdir}/bid_amount_actual_v_beliefQ_Var3_v2.png", replace
	graph export "${figdir}/bid_amount_actual_v_beliefQ_Var3_v2.eps", replace
	
********************************************************************************
	/* LESSONS:
			1. Some models seemingly performed better without being fed beliefs: e.g. .moonshotai/kimi-k2 and openai/gpt-5-mini
			2. Few LLMs exhibit much of a "demand curve", but, when averaged across models, a downward slop might appear.
			3. All models got closer when adding beliefs except the two aformentioned.
			4. The tendency was to deflate WTP without beliefs and inflate with beliefs
	*/
********************************************************************************
						* LOGIT MODELS AND WTP
********************************************************************************
* Replicate the paper
********************************************************************************
// 	use ${datadir}/working_data_Var3.dta, replace
//
// // 	preserve
// 		keep if variant=="demographics only"
// 		duplicates drop caseid, force // 1010 distinct observations
//
// 		tab qsa_actual_response
// 		drop if qsa_actual_response == "Refused to answer"
// 		gen actual_qsa = 0
// 		replace actual_qsa = 1 if qsa_actual_response == "Support"
//
// 		eststo clear
// 		logit actual_qsa bidding_amount natgas nuclear college male household_size inc0000 age white repub indep noparty
// 		eststo logit_truth
// 		// the results are the same as in the paper!!
//
// 		merge m:1 caseid using ${datadir}/data_merge
//
// 		*Estimate WTP
// 		summarize natgas nuclear college male household_size inc0000 age white repub indep noparty
// 		matrix temppool=(.3489318,.3346897 ,.2878942 ,.4821974,2.816887,7.222279,48.81892,.7436419,.2655137,.242116,.1678535)
//
// 		wtpcikr bidding_amount natgas nuclear college male household_size inc0000 age white repub indep noparty, reps(1000) mym(temppool)
// 		// True distribution: $163; LB: $127; UB: $292
// 		clear
// 		set obs 1
// 		gen provider_id = . // Aggregate of all LLM results
// 		gen mean_WTP_actual = r(mean_WTP)
// 		gen mean_UB_actual   = r(mean_UB)
// 		gen mean_LB_actual   = r(mean_LB)
// 		gen CI_Mean_actual  = r(CI_Mean)
//
// 		save "${datadir}/wtp_summary_actual_Var3.dta", replace
// 	restore


********************************************************************************
* Logit model for synthetic data with individual belief Questions (plus demographics)
********************************************************************************
	
	use ${datadir}/working_data_Var3.dta, replace
	keep if variant == "beliefs + demographics"
	tab qsa
	drop if qsa == "Refused" | qsa == "Unknown"
	gen synth_beliefs = 0
	replace synth_beliefs = 1 if qsa == "Support" | qsa == "Somewhat Support"
	
	logit synth_beliefs bidding_amount natgas nuclear college male household_size inc0000 age white repub indep noparty 
	eststo logit_beliefs
	// Should  save these logit results
	
	esttab logit_truth logit_dem logit_beliefs ///
	using "$tabdir/logits_3models_Var3.tex" ///
	, replace se margin star(* 0.10 ** 0.05 *** 0.01)
		
	preserve
		merge m:1 caseid using ${datadir}/data_merge

		* Estimate WTP
		// Use sum stats from the actual data
		matrix temppool=(.3489318,.3346897 ,.2878942 ,.4821974,2.816887,7.222279,48.81892,.7436419,.2655137,.242116,.1678535)

		collapse (mean) synth_beliefs bidding_amount natgas nuclear college male household_size inc0000 age white repub indep noparty weight, by(caseid)

		wtpcikr bidding_amount natgas nuclear college male household_size inc0000 age white repub indep noparty, reps(1000) mym(temppool)
		// Super low average without belifs: $12; LB: 6.26; UB: 17.94
		
		clear
		set obs 1
		gen provider_id = 0 // Aggregate of all LLM results
		gen mean_WTP_beliefs = r(mean_WTP)
		gen mean_UB_beliefs   = r(mean_UB)
		gen mean_LB_beliefs   = r(mean_LB)
		gen CI_Mean_beliefs  = r(CI_Mean)

		save "${datadir}/wtp_summary_beliefs_Var3.dta", replace
	restore

	* Now for each LLM individually
	local i = 0
	forvalues provider_id = 1/9 {
		local i = `i' + 1
		logit synth_beliefs bidding_amount natgas nuclear college male household_size inc0000 age white repub indep noparty if provider_id == `i'
		eststo logit_beliefs_`i'
		// Should also save these logit results, but probably better for Appndx
		preserve
			merge m:1 caseid using ${datadir}/data_merge

			*Estimate WTP 
	// 		summarize natgas nuclear college male household_size inc0000 age white repub indep noparty
	// 		matrix temppool=(.3503336,.3359648,.2823324,.4809198, 2.809658,7.198874, 48.6494,.7407605,.2592496,.2373528,.171128)

			// Use sum stats from the actual data
			matrix temppool=(.3489318,.3346897 ,.2878942 ,.4821974,2.816887,7.222279,48.81892,.7436419,.2655137,.242116,.1678535)

			collapse (mean) synth_beliefs bidding_amount natgas nuclear college male household_size inc0000 age white repub indep noparty weight, by(caseid)

			wtpcikr bidding_amount natgas nuclear college male household_size inc0000 age white repub indep noparty, reps(1000) mym(temppool)
			return list
			// Super low average without belifs: $12; LB: 6.26; UB: 17.94
			// But just using the two best LLMs gives $215; LB: 199; UB: 233
			clear
			set obs 1
			gen provider_id = `i'
			gen with_without = "with"
			gen mean_WTP_beliefs = r(mean_WTP)
			gen mean_UB_beliefs   = r(mean_UB)
			gen mean_LB_beliefs   = r(mean_LB)
			gen CI_Mean_beliefs  = r(CI_Mean)

			append using "${datadir}/wtp_summary_beliefs_Var3.dta"
			save "${datadir}/wtp_summary_beliefs_Var3.dta", replace
		restore
	}
	
	esttab logit_beliefs_1 logit_beliefs_2  logit_beliefs_3  logit_beliefs_4  logit_beliefs_5 logit_beliefs_6 logit_beliefs_7 logit_beliefs_8 logit_beliefs_9  ///
	using "$tabdir/logit_beliefQ`i'_9models_Var3.tex" ///
	, se margin star(* 0.10 ** 0.05 *** 0.01)


********************************************************************************
**************************** Interval plots of these ***************************
********************************************************************************

	* Append data
	use "${datadir}/wtp_summary_beliefs_Var3.dta", clear
	rename mean_WTP_beliefs mean_WTP_qsa 
	rename mean_UB_beliefs mean_UB_qsa
	rename mean_LB_beliefs mean_LB_qsa
	rename CI_Mean_beliefs CI_Mean_qsa
	gen with_beliefs = 1 
	
	append using "${datadir}/wtp_summary_qsa_Var3.dta"
	replace with_beliefs = 0 if with_beliefs ==.
	rename mean_WTP_qsa WTP_mean
	rename mean_UB_qsa WTP_UB
	rename mean_LB_qsa WTP_LB
	rename CI_Mean_qsa WTP_CI
	
	sort provider_id with_beliefs
	
	gen provider = ""
	replace provider = "openrouter.deepseek/deepseek-chat-v3.1" if provider_id == 1
	replace provider = "openrouter.deepseek/deepseek-r1" if provider_id == 2
	replace provider = "openrouter.google/gemini-2.5-flash" if provider_id == 3
	replace provider = "openrouter.google/gemini-2.5-flash-lite" if provider_id == 4
	replace provider = "openrouter.meta-llama/llama-4-scout" if provider_id == 5
	replace provider = "openrouter.mistralai/mistral-medium-3.1" if provider_id == 6
	replace provider = "openrouter.mistralai/mistral-small-3.2-24b-instruct" if provider_id == 7
	replace provider = "openrouter.moonshotai/kimi-k2" if provider_id == 8
	replace provider = "openrouter.openai/gpt-5-mini" if provider_id == 9

	drop if provider_id ==5 // WTP estimates are ridiculous
	
	* Add blank rows between LLM models to give them space
	insobs 1, before(3)
	insobs 1, before(6)
	insobs 1, before(9)
	insobs 1, before(12)
	insobs 1, before(15)
	insobs 1, before(18)
	insobs 1, before(21)
	insobs 1, before(24)
	
	gen row = _n
	
	
******************************************************************************** 
*Interval Plots 

	set scheme s1mono // black and white

	twoway ///
	(rcap WTP_LB WTP_UB row, horizontal) /// code for 95% CI
	(scatter row WTP_mean if with_beliefs ==0, mcolor(red)) /// dot for group 1
	(scatter row WTP_mean if with_beliefs ==1, mcolor(blue)) /// dot for group 2
	, ///
	legend(row(1) order(2 "w/o beliefs" 3 "w/ beliefs") pos(6)) /// legend at 6 o'clock position
	ylabel(1.5 "AGGREGATED" 4.5 "deepseek-chat-v3.1" 7.5 "deepseek-r1" 10.5 "gemini-2.5-flash" 13.5 "gemini-2.5-flash-lite" 16.5 "mistral-medium-3.1" 19.5 "mistral-small-3.2-24b-instruct" 22.5 "kimi-k2" 25.5 "gpt-5-mini", angle(0) noticks) ///
	/// note that the labels are 1.5, 4.5, etc so they are between rows 1&2, 4&5, etc.
	/// also note that there is a space in between different rows by leaving out rows 3, 6, 9, and 12 
	xtitle("WTP ($) of Synthetic Respondents") /// 
	ytitle("LLM Provider") /// 
	yscale(reverse) /// y axis is flipped
	xline(163, lpattern(solid) lcolor(gs8)) ///
	xline(127, lpattern(dash) lcolor(gs8)) ///
	xline(292, lpattern(dash) lcolor(gs8)) ///
	xlabel(-1500(500)1000 163)
	/// aspect (next line) is how tall or wide the figure is
	aspect(.5)

	graph export "dot and 95 percent ci figure horiz_Var3.png", replace width(2000)
	//graph export "dot and 95 percent ci figure horiz.tif", replace width(2000)
		
	