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
	use ${datadir}/working_data.dta, clear
	
*******************************************************************************
							* FIGURES
*******************************************************************************
	** main graphs
	*for actual data (I got the same results as in Table 2 from the paper)
	preserve
		tab qsa_actual_response
		drop if qsa_actual_response=="Refused to answer"
		
		gen actual_qsa = 0
		replace actual_qsa = 1 if qsa_actual_response == "Support"

		collapse (mean) actual_qsa, by(bidding_amount)
		save  ${datadir}/actual_qsa.dta, replace
	restore
*******************************************************************************
	* for demographics only synthetic data
	preserve
		keep if variant=="demographics only"	
		tab qsa 
		drop if qsa == "Unknown"
		gen synth_qsa = 0
		replace synth_qsa = 1 if qsa == "Support"
		
		* First collapse by LLM (collapses LLM and sub-variant variation)
		collapse (mean) synth_qsa_mean = synth_qsa (median) synth_qsa_med = synth_qsa (first) provider_without = provider, by(provider_id bidding_amount) 
		
		reshape wide synth_qsa_mean synth_qsa_med provider_without, i(bidding_amount) j(provider_id)

// 		collapse (mean) synth_qsa (median) synth_qsa_med = synth_qsa (p1)  synth_qsa_p1 = synth_qsa (p5)  synth_qsa_p5 = synth_qsa (p95)  synth_qsa_p95 = synth_qsa (p99)  synth_qsa_p99 = synth_qsa, by(bidding_amount)
		save  ${datadir}/synth_demonly_byProvider.dta, replace
	restore
*******************************************************************************
	* for beliefs+demographics synthetic data
	preserve
		keep if variant=="beliefs + demographics"
		tab qsa // has "Somewhat Oppose" and "Somewhat Support" values
		drop if qsa == "Refused" | qsa == "Unknown"
		gen synth_beliefs = 0
		replace synth_beliefs = 1 if qsa == "Support" | qsa == "Somewhat Support"
		
		* First collapse by simulated person 
		collapse (mean) synth_beliefs_mean = synth_beliefs (median) synth_beliefs_med = synth_beliefs (first) provider_with = provider, by(provider_id bidding_amount) 
		
		reshape wide synth_beliefs_mean synth_beliefs_med provider_with, i(bidding_amount) j(provider_id)

// 		collapse (mean) synth_beliefs (median) synth_beliefs_med = synth_beliefs (p1)  synth_beliefs_p1 = synth_beliefs (p5) synth_beliefs_p5 = synth_beliefs (p95)  synth_beliefs_p95 = synth_beliefs (p99)  synth_beliefs_p99 = synth_beliefs, by(bidding_amount)
		save  ${datadir}/synth_beliefs_byProvider.dta, replace
	restore
*******************************************************************************

	* merging them all
	use  ${datadir}/actual_qsa.dta, clear
	merge 1:1 bidding_amount using  ${datadir}/synth_demonly_byProvider.dta
	drop _merge
	merge 1:1 bidding_amount using  ${datadir}/synth_beliefs_byProvider.dta

	* Plot Actual vs. Synth (without beliefs) by Provider
	// synth_qsa_mean2 synth_qsa_mean4 synth_qsa_mean6 synth_qsa_mean8 synth_qsa_mean10  synth_qsa_mean12 synth_qsa_mean14 synth_qsa_mean16 synth_qsa_mean18
	foreach whichone in "qsa" "beliefs" {
		if "`whichone'" == "qsa" {
			local with "without"
		}
		else if "`whichone'" == "beliefs" {
			local with "with"
		}
		twoway ///
		(line actual_qsa bidding_amount, lcolor(red)) ///
		(line synth_`whichone'_mean6 bidding_amount, lcolor(black) lpattern(solid)) ///
		(line synth_`whichone'_mean8 bidding_amount, lcolor(black) lpattern(longdash_dot)) ///
		(line synth_`whichone'_mean9 bidding_amount, lcolor(black) lpattern(dash_dot)) ///
		(line synth_`whichone'_mean1 bidding_amount, lcolor(gray) lpattern(dash)) ///
		(line synth_`whichone'_mean2 bidding_amount, lcolor(gray) lpattern(dash)) ///
		(line synth_`whichone'_mean3 bidding_amount, lcolor(gray) lpattern(dash)) ///
		(line synth_`whichone'_mean4 bidding_amount, lcolor(gray) lpattern(dash)) ///
		(line synth_`whichone'_mean5 bidding_amount, lcolor(gray) lpattern(dash)) ///
		(line synth_`whichone'_mean7 bidding_amount, lcolor(gray) lpattern(dash)) ///
		, legend(order(1 "actual" 2 "mistral-medium-3." 3 "kimi-k2" 4 "gpt-5-mini" ) ) ///
		ylabel(0(0.1)1) ///
		xtitle("Bid Amount ($)") ///
		ytitle("Share Approved") ///
		xlabel(5 35 45 65 85 105 135 155)
		
		graph export "${figdir}/bid_amount_actual_v_`with'beliefs.eps", replace
// 		graph export "${figdir}/bid_amount_actual_v_`with'beliefs.png", replace
	}
	// Best without beliefs: openrouter.moonshotai/kimi-k2 openrouter.openai/gpt-5-mini
	// Provider_ids: 8 and 9
	// Best with beliefs: openrouter.mistralai/mistral-medium-3.1 (provider_id: 6)

		
		

	*changing y-axis scale
	twoway ///
		(line actual_qsa bidding_amount, mcolor(blue) msymbol(o)) ///
		(line synth_qsa bidding_amount, mcolor(red) msymbol(+)) ///
		(line synth_beliefs bidding_amount, mcolor(green) msymbol(×)), ///
		legend(order(1 "Actual" 2 "Dem_only" 3 "Dem+beliefs")) ///
		title("Main Plot (rescaled)")
	
********************************************************************************
	/* LESSONS:
			1. Some models seemingly performed better without being fed beliefs: e.g. .moonshotai/kimi-k2 and openai/gpt-5-mini
			2. Few LLMs exhibit much of a "demand curve", but, when averaged across models, a downward slop might appear.
			3. All models got closer when adding beliefs except the two aformentioned.
			4. The tendency was to deflate WTP without beliefs and inflate with beliefs
	*/
********************************************************************************
********************************************************************************
* Study 1 WTP estimation — three blocks
*   1. Empirical replication (human respondents → matches Aldy's $163)
*   2. Demographics-only synthetic (no beliefs)
*   3. Demographics + all beliefs synthetic
*
* Data: ${datadir}/working_data.dta
* Variants: "demographics only" and "beliefs + demographics"
*
* Each block follows the working one-belief pattern:
*   keep relevant subsample → code outcome → logit → preserve → collapse to
*   caseid → wtpcikr with mymean(temppool) → save WTP results → restore.
*
* Output files:
*   ${datadir}/wtp_summary_actual.dta   (1 row: empirical)
*   ${datadir}/wtp_summary_qsa.dta      (10 rows: aggregated + 9 LLMs)
*   ${datadir}/wtp_summary_beliefs.dta  (10 rows: aggregated + 9 LLMs)
********************************************************************************

	* Mean covariate vector from Aldy's analytic sample (11 covariates, no bid)
	* Order: natgas nuclear college male household_size inc0000 age white repub indep noparty
	matrix temppool = (.3489318, .3346897, .2878942, .4821974, 2.816887, ///
					   7.222279, 48.81892, .7436419, .2655137, .242116, .1678535)

	* Aldy specification (bid is FIRST in varlist after wtpcikr, per the help)
	global aldy_rhs "bidding_amount natgas nuclear college male household_size inc0000 age white repub indep noparty"

********************************************************************************
* BLOCK 1 — Empirical replication
********************************************************************************

	use "${datadir}/working_data.dta", clear

	* Restrict to one row per human respondent (the actual response is invariant
	* across LLM runs within caseid).
	keep if variant == "demographics only"
	duplicates drop caseid, force

	drop if qsa_actual_response == "Refused to answer"
	gen actual_qsa = 0
	replace actual_qsa = 1 if qsa_actual_response == "Support"

	eststo clear
	logit actual_qsa ${aldy_rhs}
	eststo logit_truth

	* WTP at the empirical-mean covariate vector
	wtpcikr ${aldy_rhs}, reps(1000) mym(temppool)
	* Expected: $163, LB $127, UB $292

	clear
	set obs 1
	gen provider_id = .   // empirical = missing provider
	gen mean_WTP_actual = r(mean_WTP)
	gen mean_UB_actual  = r(mean_UB)
	gen mean_LB_actual  = r(mean_LB)
	gen CI_Mean_actual  = r(CI_Mean)
	save "${datadir}/wtp_summary_actual.dta", replace

	di as result "Empirical WTP saved."

********************************************************************************
* BLOCK 2 — Demographics-only synthetic (no beliefs)
*
* Outcome: synth_qsa = 1 if qsa == "Support", 0 otherwise (Aldy used binary;
* "Unknown" dropped).
********************************************************************************

	use "${datadir}/working_data.dta", clear
	keep if variant == "demographics only"
	tab qsa
	drop if qsa == "Unknown"
	gen synth_qsa = 0
	replace synth_qsa = 1 if qsa == "Support"

	* ─── Aggregated (all LLMs pooled) ──────────────────────────────────────────
	logit synth_qsa ${aldy_rhs}
	eststo logit_dem

	preserve
		merge m:1 caseid using "${datadir}/data_merge"
		
		collapse (mean) synth_qsa ${aldy_rhs} weight, by(caseid)
		
		wtpcikr ${aldy_rhs}, reps(1000) mym(temppool)
		return list
		
		clear
		set obs 1
		gen provider_id = 0   // aggregated
		gen with_without = "without"
		gen mean_WTP_qsa = r(mean_WTP)
		gen mean_UB_qsa  = r(mean_UB)
		gen mean_LB_qsa  = r(mean_LB)
		gen CI_Mean_qsa  = r(CI_Mean)
		save "${datadir}/wtp_summary_qsa.dta", replace
	restore

	* ─── Per-LLM ──────────────────────────────────────────────────────────────
	forvalues p = 1/9 {
		capture noisily logit synth_qsa ${aldy_rhs} if provider_id == `p'
		if _rc != 0 continue
		eststo logit_dem_`p'
		
		preserve
			keep if provider_id == `p'
			merge m:1 caseid using "${datadir}/data_merge"
			
			collapse (mean) synth_qsa ${aldy_rhs} weight, by(caseid)
			
			* Need to re-fit logit on the collapsed sample so wtpcikr pulls the
			* right e(b)/e(V). Otherwise it uses the panel-level logit above
			* with the wrong sample.
			capture noisily logit synth_qsa ${aldy_rhs}
			if _rc != 0 {
				restore
				continue
			}
			
			capture noisily wtpcikr ${aldy_rhs}, reps(1000) mym(temppool)
			if _rc != 0 {
				di as error "wtpcikr failed for provider `p' (no beliefs)"
				restore
				continue
			}
			
			clear
			set obs 1
			gen provider_id = `p'
			gen with_without = "without"
			gen mean_WTP_qsa = r(mean_WTP)
			gen mean_UB_qsa  = r(mean_UB)
			gen mean_LB_qsa  = r(mean_LB)
			gen CI_Mean_qsa  = r(CI_Mean)
			
			append using "${datadir}/wtp_summary_qsa.dta"
			save "${datadir}/wtp_summary_qsa.dta", replace
		restore
	}

	di as result "Demographics-only (no beliefs) WTP saved."

********************************************************************************
* BLOCK 3 — Demographics + all beliefs synthetic
*
* Outcome: synth_beliefs = 1 if qsa in {"Support", "Somewhat Support"}, else 0.
* "Refused" and "Unknown" dropped.
********************************************************************************

	use "${datadir}/working_data.dta", clear
	keep if variant == "beliefs + demographics"
	tab qsa
	drop if qsa == "Refused" | qsa == "Unknown"
	gen synth_beliefs = 0
	replace synth_beliefs = 1 if qsa == "Support" | qsa == "Somewhat Support"

	* ─── Aggregated ────────────────────────────────────────────────────────────
	logit synth_beliefs ${aldy_rhs}
	eststo logit_beliefs

	preserve
		merge m:1 caseid using "${datadir}/data_merge"
		
		collapse (mean) synth_beliefs ${aldy_rhs} weight, by(caseid)
		
		wtpcikr ${aldy_rhs}, reps(1000) mym(temppool)
		return list
		
		clear
		set obs 1
		gen provider_id = 0
		gen with_without = "with"
		gen mean_WTP_beliefs = r(mean_WTP)
		gen mean_UB_beliefs  = r(mean_UB)
		gen mean_LB_beliefs  = r(mean_LB)
		gen CI_Mean_beliefs  = r(CI_Mean)
		save "${datadir}/wtp_summary_beliefs.dta", replace
	restore

	* ─── Per-LLM ──────────────────────────────────────────────────────────────
	forvalues p = 1/9 {
		capture noisily logit synth_beliefs ${aldy_rhs} if provider_id == `p'
		if _rc != 0 continue
		eststo logit_beliefs_`p'
		
		preserve
			keep if provider_id == `p'
			merge m:1 caseid using "${datadir}/data_merge"
			
			collapse (mean) synth_beliefs ${aldy_rhs} weight, by(caseid)
			
			capture noisily logit synth_beliefs ${aldy_rhs}
			if _rc != 0 {
				restore
				continue
			}
			
			capture noisily wtpcikr ${aldy_rhs}, reps(1000) mym(temppool)
			if _rc != 0 {
				di as error "wtpcikr failed for provider `p' (with beliefs)"
				restore
				continue
			}
			
			clear
			set obs 1
			gen provider_id = `p'
			gen with_without = "with"
			gen mean_WTP_beliefs = r(mean_WTP)
			gen mean_UB_beliefs  = r(mean_UB)
			gen mean_LB_beliefs  = r(mean_LB)
			gen CI_Mean_beliefs  = r(CI_Mean)
			
			append using "${datadir}/wtp_summary_beliefs.dta"
			save "${datadir}/wtp_summary_beliefs.dta", replace
		restore
	}

	di as result "Demographics + beliefs WTP saved."
	di as result "All three WTP blocks complete."
	di as result ""
	di as result "Files saved:"
	di as result "  ${datadir}/wtp_summary_actual.dta"
	di as result "  ${datadir}/wtp_summary_qsa.dta"
	di as result "  ${datadir}/wtp_summary_beliefs.dta"
	
********************************************************************************
********************************************************************************
* TABLES BLOCK — Study 1 (Aldy 2012 / NCES) — panel-level only
* Run AFTER the WTP estimation block; assumes panel-level eststo'd estimates
* are still in memory and the three WTP .dta files exist.
*
* Produces four LaTeX tables:
*   tab_repl_logit_Study1.tex      -- empirical replication logit
*   tab_syn_logit_demonly.tex      -- synthetic logit, no beliefs
*   tab_syn_logit_withBeliefs.tex  -- synthetic logit, with beliefs
*   tab_syn_wtp_Study1.tex         -- WTP estimates (headline)
*   tab_slope_ratios_Study1.tex    -- bid-coefficient slope ratios
********************************************************************************

	global aldy_rhs "bidding_amount natgas nuclear college male household_size inc0000 age white repub indep noparty"

	global pname1 "deepseek-chat-v3.1"
	global pname2 "deepseek-r1"
	global pname3 "gemini-2.5-flash"
	global pname4 "gemini-2.5-flash-lite"
	global pname5 "llama-4-scout"
	global pname6 "mistral-medium-3.1"
	global pname7 "mistral-small-3.2-24b-instruct"
	global pname8 "kimi-k2"
	global pname9 "gpt-5-mini"

********************************************************************************
* TABLE 1 — Replication logit (empirical)
********************************************************************************

	preserve
		use "${datadir}/wtp_summary_actual.dta", clear
		local emp_wtp = mean_WTP_actual[1]
		local emp_lb  = mean_LB_actual[1]
		local emp_ub  = mean_UB_actual[1]
	restore

	label var bidding_amount  "Bid amount (\$)"
	label var natgas          "Natural gas treatment"
	label var nuclear         "Nuclear treatment"
	label var college         "College"
	label var male            "Male"
	label var household_size  "Household size"
	label var inc0000         "Income (\$10k)"
	label var age             "Age"
	label var white           "White"
	label var repub           "Republican"
	label var indep           "Independent"
	label var noparty         "No party"

	esttab logit_truth ///
		using "${tabdir}/tab_repl_logit_Study1.tex", replace ///
		booktabs label se star(* 0.10 ** 0.05 *** 0.01) ///
		b(%9.4f) se(%9.4f) ///
		mtitles("Empirical") ///
		scalars("ll Log-likelihood" "N Observations") ///
		nonotes ///
		addnotes("Binary logit replicating Table~2 of \textcite{Aldy2012}." ///
				 "Mean WTP via Krinsky-Robb (1{,}000 reps) at empirical mean covariates: \\$`: di %4.0f `emp_wtp'' (95\\% CI: \\$`: di %4.0f `emp_lb''--\\$`: di %4.0f `emp_ub'').")

	di as result "Wrote tab_repl_logit_Study1.tex"

	estimates restore logit_truth
	local emp_beta = _b[bidding_amount]
	di "Empirical bid coefficient: `emp_beta'"

********************************************************************************
* TABLE 2a / 2b — Synthetic logit (panel-level), long-format
* Rows = 9 LLMs + Aggregated + Empirical
* Cols = bid, natgas, nuclear, college, age, N, slope ratio
********************************************************************************

	foreach cond_lab in "demonly" "withBeliefs" {
		if "`cond_lab'" == "demonly" {
			local cond_title "Demographics only"
			local est_prefix "logit_dem"
			local est_agg    "logit_dem"
		}
		else {
			local cond_title "Demographics + beliefs"
			local est_prefix "logit_beliefs"
			local est_agg    "logit_beliefs"
		}
		
		matrix syn_res = J(10, 12, .)
		
		forvalues p = 1/9 {
			capture estimates restore `est_prefix'_`p'
			if _rc == 0 {
				matrix syn_res[`p', 1]  = _b[bidding_amount]
				matrix syn_res[`p', 2]  = _se[bidding_amount]
				matrix syn_res[`p', 3]  = _b[natgas]
				matrix syn_res[`p', 4]  = _se[natgas]
				matrix syn_res[`p', 5]  = _b[nuclear]
				matrix syn_res[`p', 6]  = _se[nuclear]
				matrix syn_res[`p', 7]  = _b[college]
				matrix syn_res[`p', 8]  = _se[college]
				matrix syn_res[`p', 9]  = _b[age]
				matrix syn_res[`p', 10] = _se[age]
				matrix syn_res[`p', 11] = e(N)
				matrix syn_res[`p', 12] = _b[bidding_amount] / `emp_beta'
			}
		}
		
		estimates restore `est_agg'
		matrix syn_res[10, 1]  = _b[bidding_amount]
		matrix syn_res[10, 2]  = _se[bidding_amount]
		matrix syn_res[10, 3]  = _b[natgas]
		matrix syn_res[10, 4]  = _se[natgas]
		matrix syn_res[10, 5]  = _b[nuclear]
		matrix syn_res[10, 6]  = _se[nuclear]
		matrix syn_res[10, 7]  = _b[college]
		matrix syn_res[10, 8]  = _se[college]
		matrix syn_res[10, 9]  = _b[age]
		matrix syn_res[10, 10] = _se[age]
		matrix syn_res[10, 11] = e(N)
		matrix syn_res[10, 12] = _b[bidding_amount] / `emp_beta'
		
		capture file close fh
		file open fh using "${tabdir}/tab_syn_logit_`cond_lab'.tex", write replace
		
		file write fh "\begin{table}[h]" _n
		file write fh "\centering" _n
		file write fh "\caption{Synthetic logit estimates, Study 1 (NCES): `cond_title'.}" _n
		file write fh "\label{tab:syn-logit-`cond_lab'}" _n
		file write fh "\begin{threeparttable}" _n
		file write fh "\footnotesize" _n
		file write fh "\begin{tabular}{lcccccrr}" _n
		file write fh "\toprule" _n
		file write fh "Model & Bid (\$) & NatGas & Nuclear & College & Age & N & $\hat\beta_{bid}/\hat\beta_{bid}^{emp}$ \\" _n
		file write fh "\midrule" _n
		
		forvalues r = 1/9 {
			local pn "${pname`r'}"
			local b1 = syn_res[`r', 1]
			local s1 = syn_res[`r', 2]
			local b2 = syn_res[`r', 3]
			local s2 = syn_res[`r', 4]
			local b3 = syn_res[`r', 5]
			local s3 = syn_res[`r', 6]
			local b4 = syn_res[`r', 7]
			local s4 = syn_res[`r', 8]
			local b5 = syn_res[`r', 9]
			local s5 = syn_res[`r', 10]
			local nobs  = syn_res[`r', 11]
			local ratio = syn_res[`r', 12]
			
			if !missing(`b1') {
				file write fh "`pn'"
				file write fh " & " %9.5f (`b1')
				file write fh " & " %7.3f (`b2')
				file write fh " & " %7.3f (`b3')
				file write fh " & " %7.3f (`b4')
				file write fh " & " %7.4f (`b5')
				file write fh " & " %9.0fc (`nobs')
				file write fh " & " %6.3f (`ratio')
				file write fh " \\" _n
				file write fh ""
				file write fh " & (" %9.5f (`s1') ")"
				file write fh " & (" %7.3f (`s2') ")"
				file write fh " & (" %7.3f (`s3') ")"
				file write fh " & (" %7.3f (`s4') ")"
				file write fh " & (" %7.4f (`s5') ")"
				file write fh " & & \\" _n
			}
			else {
				file write fh "`pn' & --- & --- & --- & --- & --- & --- & --- \\" _n
			}
		}
		
		file write fh "\midrule" _n
		local b1 = syn_res[10, 1]
		local s1 = syn_res[10, 2]
		local b2 = syn_res[10, 3]
		local s2 = syn_res[10, 4]
		local b3 = syn_res[10, 5]
		local s3 = syn_res[10, 6]
		local b4 = syn_res[10, 7]
		local s4 = syn_res[10, 8]
		local b5 = syn_res[10, 9]
		local s5 = syn_res[10, 10]
		local nobs  = syn_res[10, 11]
		local ratio = syn_res[10, 12]
		
		file write fh "Aggregated"
		file write fh " & " %9.5f (`b1')
		file write fh " & " %7.3f (`b2')
		file write fh " & " %7.3f (`b3')
		file write fh " & " %7.3f (`b4')
		file write fh " & " %7.4f (`b5')
		file write fh " & " %9.0fc (`nobs')
		file write fh " & " %6.3f (`ratio')
		file write fh " \\" _n
		file write fh ""
		file write fh " & (" %9.5f (`s1') ")"
		file write fh " & (" %7.3f (`s2') ")"
		file write fh " & (" %7.3f (`s3') ")"
		file write fh " & (" %7.3f (`s4') ")"
		file write fh " & (" %7.4f (`s5') ")"
		file write fh " & & \\" _n
		
		file write fh "\midrule" _n
		estimates restore logit_truth
		local eb1 = _b[bidding_amount]
		local es1 = _se[bidding_amount]
		local eb2 = _b[natgas]
		local es2 = _se[natgas]
		local eb3 = _b[nuclear]
		local es3 = _se[nuclear]
		local eb4 = _b[college]
		local es4 = _se[college]
		local eb5 = _b[age]
		local es5 = _se[age]
		local enobs = e(N)
		
		file write fh "Empirical (Aldy et al.)"
		file write fh " & " %9.5f (`eb1')
		file write fh " & " %7.3f (`eb2')
		file write fh " & " %7.3f (`eb3')
		file write fh " & " %7.3f (`eb4')
		file write fh " & " %7.4f (`eb5')
		file write fh " & " %9.0fc (`enobs')
		file write fh " & 1.000 \\" _n
		file write fh ""
		file write fh " & (" %9.5f (`es1') ")"
		file write fh " & (" %7.3f (`es2') ")"
		file write fh " & (" %7.3f (`es3') ")"
		file write fh " & (" %7.3f (`es4') ")"
		file write fh " & (" %7.4f (`es5') ")"
		file write fh " & & \\" _n
		
		file write fh "\bottomrule" _n
		file write fh "\end{tabular}" _n
		file write fh "\begin{tablenotes}\footnotesize" _n
		file write fh "\item \textit{Notes:} Binary logit estimates of the \textcite{Aldy2012} specification on synthetic responses, persona condition: `cond_title'. " _n
		file write fh "Standard errors in parentheses; one observation per persona-LLM-repetition cell. " _n
		file write fh "Final column reports the synthetic bid coefficient divided by the empirical bid coefficient; values below 1 in magnitude indicate slope compression. " _n
		file write fh "Coefficients shown are a subset; the full coefficient vector appears in the supplementary table. " _n
		file write fh "Empirical benchmark is the same specification on \textcite{Aldy2012} human-respondent data; WTP is computed on the collapsed-to-persona synthetic sample to match the empirical sample structure (see Table~\ref{tab:syn-wtp-Study1})." _n
		file write fh "\end{tablenotes}" _n
		file write fh "\end{threeparttable}" _n
		file write fh "\end{table}" _n
		file close fh
		
		di as result "Wrote tab_syn_logit_`cond_lab'.tex"
	}

********************************************************************************
* TABLE 3 — Synthetic WTP estimates (headline)
********************************************************************************

	use "${datadir}/wtp_summary_qsa.dta", clear
	rename mean_WTP_qsa wtp_d
	rename mean_LB_qsa  lb_d
	rename mean_UB_qsa  ub_d
	keep provider_id wtp_d lb_d ub_d
	tempfile demonly
	save `demonly'

	use "${datadir}/wtp_summary_beliefs.dta", clear
	rename mean_WTP_beliefs wtp_b
	rename mean_LB_beliefs  lb_b
	rename mean_UB_beliefs  ub_b
	keep provider_id wtp_b lb_b ub_b
	merge 1:1 provider_id using `demonly', nogen

	tempfile wtp_merged
	save `wtp_merged'

	use "${datadir}/wtp_summary_actual.dta", clear
	local emp_wtp = mean_WTP_actual[1]
	local emp_lb  = mean_LB_actual[1]
	local emp_ub  = mean_UB_actual[1]

	use `wtp_merged', clear

	capture file close fh
	file open fh using "${tabdir}/tab_syn_wtp_Study1.tex", write replace

	file write fh "\begin{table}[h]" _n
	file write fh "\centering" _n
	file write fh "\caption{Synthetic mean willingness to pay for the NCES policy (Study 1).}" _n
	file write fh "\label{tab:syn-wtp-Study1}" _n
	file write fh "\begin{threeparttable}" _n
	file write fh "\footnotesize" _n
	file write fh "\begin{tabular}{lcc}" _n
	file write fh "\toprule" _n
	file write fh "Model & Demographics only & + Beliefs \\" _n
	file write fh "\midrule" _n

	local row_ids "0 1 2 3 4 5 6 7 8 9"
	foreach p of local row_ids {
		if `p' == 0 local pn "AGGREGATED"
		else        local pn "${pname`p'}"
		
		qui sum wtp_d if provider_id == `p'
		local wd = r(mean)
		qui sum lb_d if provider_id == `p'
		local ld = r(mean)
		qui sum ub_d if provider_id == `p'
		local ud = r(mean)
		
		qui sum wtp_b if provider_id == `p'
		local wb = r(mean)
		qui sum lb_b if provider_id == `p'
		local lb = r(mean)
		qui sum ub_b if provider_id == `p'
		local ub = r(mean)
		
		file write fh "`pn'"
		if !missing(`wd') file write fh " & " %5.0f (`wd') " [" %5.0f (`ld') ", " %5.0f (`ud') "]"
		else              file write fh " & ---"
		if !missing(`wb') file write fh " & " %5.0f (`wb') " [" %5.0f (`lb') ", " %5.0f (`ub') "]"
		else              file write fh " & ---"
		file write fh " \\" _n
		
		if `p' == 0 file write fh "\midrule" _n
	}

	file write fh "\midrule" _n
	file write fh "Empirical (Aldy et al.) & \multicolumn{2}{c}{" %5.0f (`emp_wtp') " [" %5.0f (`emp_lb') ", " %5.0f (`emp_ub') "]} \\" _n
	file write fh "\bottomrule" _n
	file write fh "\end{tabular}" _n
	file write fh "\begin{tablenotes}\footnotesize" _n
	file write fh "\item \textit{Notes:} Mean WTP (\$/household/year) for the NCES policy. " _n
	file write fh "Bracketed values are 95\% confidence intervals from a Krinsky-Robb parametric bootstrap with 1{,}000 replications evaluated at the empirical mean covariate vector. " _n
	file write fh "``AGGREGATED'' pools synthetic responses across all nine LLMs. " _n
	file write fh "Synthetic samples are collapsed to one observation per persona prior to estimation, matching the empirical respondent-level sample structure. " _n
	file write fh "Empirical benchmark from \textcite{Aldy2012}." _n
	file write fh "\end{tablenotes}" _n
	file write fh "\end{threeparttable}" _n
	file write fh "\end{table}" _n
	file close fh

	di as result "Wrote tab_syn_wtp_Study1.tex"

********************************************************************************
* TABLE 4 — Slope ratios (panel-level bid coefficients)
********************************************************************************

	clear
	set obs 1
	gen byte prov_id    = .
	gen str20 condition = ""
	gen double beta_bid = .
	gen double se_bid   = .
	tempfile slope_s1
	save `slope_s1', emptyok

	* Demographics-only
	foreach which_id in 0 1 2 3 4 5 6 7 8 9 {
		if `which_id' == 0 {
			capture estimates restore logit_dem
		}
		else {
			capture estimates restore logit_dem_`which_id'
		}
		if _rc == 0 {
			local bb = _b[bidding_amount]
			local sb = _se[bidding_amount]
			preserve
				use `slope_s1', clear
				local nx = _N + 1
				set obs `nx'
				replace prov_id   = `which_id' in `nx'
				replace condition = "demonly" in `nx'
				replace beta_bid  = `bb' in `nx'
				replace se_bid    = `sb' in `nx'
				save `slope_s1', replace
			restore
		}
	}

	* With beliefs
	foreach which_id in 0 1 2 3 4 5 6 7 8 9 {
		if `which_id' == 0 {
			capture estimates restore logit_beliefs
		}
		else {
			capture estimates restore logit_beliefs_`which_id'
		}
		if _rc == 0 {
			local bb = _b[bidding_amount]
			local sb = _se[bidding_amount]
			preserve
				use `slope_s1', clear
				local nx = _N + 1
				set obs `nx'
				replace prov_id   = `which_id' in `nx'
				replace condition = "withBeliefs" in `nx'
				replace beta_bid  = `bb' in `nx'
				replace se_bid    = `sb' in `nx'
				save `slope_s1', replace
			restore
		}
	}

	use `slope_s1', clear
	drop if missing(prov_id) | missing(beta_bid)
	gen ratio = beta_bid / `emp_beta'

	save "${datadir}/slope_ratios_Study1.dta", replace

	capture file close fh
	file open fh using "${tabdir}/tab_slope_ratios_Study1.tex", write replace

	file write fh "\begin{table}[h]" _n
	file write fh "\centering" _n
	file write fh "\caption{Synthetic-to-empirical bid-coefficient ratios, Study 1.}" _n
	file write fh "\label{tab:slope-ratios-Study1}" _n
	file write fh "\begin{threeparttable}" _n
	file write fh "\footnotesize" _n
	file write fh "\begin{tabular}{lcc}" _n
	file write fh "\toprule" _n
	file write fh "Model & Demographics only & + Beliefs \\" _n
	file write fh "\midrule" _n

	foreach p of numlist 0 1 2 3 4 5 6 7 8 9 {
		if `p' == 0 local pn "AGGREGATED"
		else        local pn "${pname`p'}"
		
		qui sum ratio if prov_id == `p' & condition == "demonly"
		local r_d = r(mean)
		qui sum ratio if prov_id == `p' & condition == "withBeliefs"
		local r_b = r(mean)
		
		file write fh "`pn'"
		if !missing(`r_d') file write fh " & " %7.3f (`r_d')
		else               file write fh " & ---"
		if !missing(`r_b') file write fh " & " %7.3f (`r_b')
		else               file write fh " & ---"
		file write fh " \\" _n
		
		if `p' == 0 file write fh "\midrule" _n
	}

	file write fh "\bottomrule" _n
	file write fh "\end{tabular}" _n
	file write fh "\begin{tablenotes}\footnotesize" _n
	file write fh "\item \textit{Notes:} Ratio of synthetic to empirical bid coefficients from binary logit estimates of the \textcite{Aldy2012} specification. " _n
	file write fh "Values below 1 in magnitude indicate slope compression. " _n
	file write fh "A value near 0 indicates near-insensitivity to bid amount. " _n
	file write fh "Empirical bid coefficient used as denominator is from Table~\ref{tab:repl-logit-Study1}." _n
	file write fh "\end{tablenotes}" _n
	file write fh "\end{threeparttable}" _n
	file write fh "\end{table}" _n
	file close fh

	di as result "Wrote tab_slope_ratios_Study1.tex"
	di as result ""
	di as result "All Study 1 tables produced."

********************************************************************************
* Interval plots — Study 1 WTP (working_data.dta, no-belief and all-belief)
* Mirrors the structure of the Var3 (one-belief) interval plot.
*
* Reads: ${datadir}/wtp_summary_qsa.dta     (demographics only)
*        ${datadir}/wtp_summary_beliefs.dta (demographics + beliefs)
*
* Toggle below to drop llama-4-scout (provider_id 5) if its WTP estimates
* swamp the plot range.
********************************************************************************

	* Toggle: set to 1 to drop llama-4-scout; 0 to keep it (recommended for paper)
	local drop_llama 0

	* ── Append the two WTP files ───────────────────────────────────────────────
	use "${datadir}/wtp_summary_beliefs.dta", clear
	rename mean_WTP_beliefs mean_WTP_qsa
	rename mean_UB_beliefs  mean_UB_qsa
	rename mean_LB_beliefs  mean_LB_qsa
	rename CI_Mean_beliefs  CI_Mean_qsa
	gen with_beliefs = 1

	append using "${datadir}/wtp_summary_qsa.dta"
	replace with_beliefs = 0 if missing(with_beliefs)

	rename mean_WTP_qsa WTP_mean
	rename mean_UB_qsa  WTP_UB
	rename mean_LB_qsa  WTP_LB
	rename CI_Mean_qsa  WTP_CI

	sort provider_id with_beliefs

	* ── Provider labels (confirmed mapping for working_data.dta) ───────────────
	gen provider = ""
	replace provider = "openrouter.deepseek/deepseek-chat-v3.1"               if provider_id == 1
	replace provider = "openrouter.deepseek/deepseek-r1"                      if provider_id == 2
	replace provider = "openrouter.google/gemini-2.5-flash"                   if provider_id == 3
	replace provider = "openrouter.google/gemini-2.5-flash-lite"              if provider_id == 4
	replace provider = "openrouter.meta-llama/llama-4-scout"                  if provider_id == 5
	replace provider = "openrouter.mistralai/mistral-medium-3.1"              if provider_id == 6
	replace provider = "openrouter.mistralai/mistral-small-3.2-24b-instruct"  if provider_id == 7
	replace provider = "openrouter.moonshotai/kimi-k2"                        if provider_id == 8
	replace provider = "openrouter.openai/gpt-5-mini"                         if provider_id == 9

	* ── Optional drop of llama-4-scout ─────────────────────────────────────────
	if `drop_llama' == 1 {
		drop if provider_id == 5
		local fname_suffix "_noLlama"
	}
	else {
		local fname_suffix ""
	}

	* ── Add blank rows between LLM models to give them space ───────────────────
	* Each provider has 2 rows (with and without beliefs); insert a blank
	* between each provider's pair. With 10 providers (0-9) we need 9 blanks.
	* If llama-4-scout was dropped, we have 9 providers and need 8 blanks.

	quietly count
	local nobs = r(N)
	local providers_in_data = `nobs' / 2  // 2 rows per provider

	* Insert blanks at positions 3, 6, 9, ... (after each pair)
	* Loop builds the insertion positions
	forvalues g = 1/`=`providers_in_data' - 1' {
		local pos = 3 * `g'
		insobs 1, before(`pos')
	}

	gen row = _n

	* ── Build the ylabel string dynamically ────────────────────────────────────
	* Labels go at 1.5, 4.5, 7.5, ... (between each provider's two rows)
	local ylab ""
	local provider_list "0 1 2 3 4 5 6 7 8 9"
	if `drop_llama' == 1 local provider_list "0 1 2 3 4 6 7 8 9"

	local label_pos = 1.5
	foreach p of local provider_list {
		if `p' == 0      local name "AGGREGATED"
		if `p' == 1      local name "deepseek-chat-v3.1"
		if `p' == 2      local name "deepseek-r1"
		if `p' == 3      local name "gemini-2.5-flash"
		if `p' == 4      local name "gemini-2.5-flash-lite"
		if `p' == 5      local name "llama-4-scout"
		if `p' == 6      local name "mistral-medium-3.1"
		if `p' == 7      local name "mistral-small-3.2-24b-instruct"
		if `p' == 8      local name "kimi-k2"
		if `p' == 9      local name "gpt-5-mini"
		
		local ylab `"`ylab' `label_pos' "`name'""'
		local label_pos = `label_pos' + 3
	}

	* ── Figure out a sensible x-axis range ─────────────────────────────────────
	quietly sum WTP_LB
	local xmin = r(min)
	quietly sum WTP_UB
	local xmax = r(max)

	* Round to nearest 500 outside the data range
	local xmin_lab = floor(`xmin'/500)*500
	local xmax_lab = ceil(`xmax'/500)*500

	di "X-axis range: `xmin_lab' to `xmax_lab'"

********************************************************************************
* Interval Plot
********************************************************************************

	set scheme s1mono   // black and white

	twoway ///
		(rcap WTP_LB WTP_UB row, horizontal) ///
		(scatter row WTP_mean if with_beliefs == 0, mcolor(red)) ///
		(scatter row WTP_mean if with_beliefs == 1, mcolor(blue)) ///
		, ///
		legend(row(1) order(2 "w/o beliefs" 3 "w/ beliefs") pos(6)) ///
		ylabel(`ylab', angle(0) noticks) ///
		xtitle("WTP ($) of Synthetic Respondents") ///
		ytitle("LLM Provider") ///
		yscale(reverse) ///
		xline(163, lpattern(solid) lcolor(gs8)) ///
		xline(127, lpattern(dash)  lcolor(gs8)) ///
		xline(292, lpattern(dash)  lcolor(gs8)) ///
		xlabel(`xmin_lab'(500)`xmax_lab' 163) ///
		aspect(.5)

	graph export "${figdir}/dot_and_95CI_NCES`fname_suffix'.png", replace width(2000)
	graph export "${figdir}/dot_and_95CI_NCES`fname_suffix'.eps", replace
