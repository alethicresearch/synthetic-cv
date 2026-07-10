* Project:		LLM for Contingent Valuation
* Author:		Alina Khindanova (edited by Trevor Woolley)
* Date created:	Nov 21, 2025
* Purpose:		Import raw LLM result data (made by Sankalpa) and produce figures
*******************************************************************************
global datadir "D:\Projects\LLM_CV\data"
global figdir "D:\Projects\LLM_CV\figures"
global tabdir "D:\Projects\LLM_CV\figures\tables"
global rawdir "D:\Projects\LLM_CV\data\raw\Experiment2"

graph set window fontface "Times New Roman"
graph set eps fontface "Times New Roman"

sysdir set PERSONAL "C:\Users\trevor_woolley\ado\personal\"
sysdir set PLUS "C:\Users\trevor_woolley\ado\plus\"

ssc install wtpcikr
ssc install grc1leg2
ssc install estout, replace

*******************************************************************************
							* Pull in data
*******************************************************************************

	use "${rawdir}\wtp_e_cleaned-v118", clear
	
*******************************************************************************
							* FIGURES
*******************************************************************************
* Propensity to vote in favor given cost
*******************************************************************************
	* add new rows representing the second round choices (their implicit answer to both)
	gen expand_n = 1
	replace expand_n = 3 if experiment==0 & attempt==1
	expand expand_n
	drop expand_n
	bys id prov experiment attempt run_id dataset_version created_at: gen implicit = _n-1

	replace ctx1_5_q28_cost_cat=3 if implicit==1 & syn_vote ==2 //implicit
	replace ctx1_5_q28_cost_cat=6 if implicit==2 & syn_vote ==2 //implicit
	replace ctx1_5_q28_cost_cat=4 if implicit==1 & syn_vote==1 //implicit
	replace ctx1_5_q28_cost_cat=5 if implicit==2 & syn_vote==1 //implicit
	// Note that cost_cat is a code, not a meaningful value and that syn_vote is not yet coded intuitively--it will be redefined below
	
	* for single belief Q+demographics synthetic data
	forvalues i = 6/9 {
		preserve
			keep if dataset_version == `i'
			drop cost
			gen provider_id = prov +1
			
			label list syn_vote
			tab syn_vote
			replace syn_vote = . if syn_vote==0
			replace syn_vote=0 if syn_vote==1
			replace syn_vote=1 if syn_vote==2
			tab syn_vote

			label define syn_vote ///
				1 "Vote for" ///
				0 "Vote against", modify

			* code costs the same way as in the paper
			// Note that I dropped the other "cost" variable above
			// Also, note that "cost" in this paper is "bidding_amount" in the first paper
			label list ctx1_5_q28_cost_cat
			gen cost = .
			replace cost=100 if ctx1_5_q28_cost_cat==0
			replace cost=150 if ctx1_5_q28_cost_cat==1
			replace cost=200 if ctx1_5_q28_cost_cat==2
			replace cost=25 if ctx1_5_q28_cost_cat==3
			replace cost=250 if ctx1_5_q28_cost_cat==4
			replace cost=300 if ctx1_5_q28_cost_cat==5
			replace cost=5 if ctx1_5_q28_cost_cat==6
			replace cost=50 if ctx1_5_q28_cost_cat==7
			
			* First collapse by provider (LLM)
			collapse (mean) syn_vote_`i'_ = syn_vote, by(provider_id cost experiment)
			
			reshape wide syn_vote_`i'_ , i(cost experiment) j(provider_id)
			gen syn_vote_`i' = (syn_vote_`i'_1 + syn_vote_`i'_2 + syn_vote_`i'_3 + syn_vote_`i'_4 + syn_vote_`i'_5 + syn_vote_`i'_6 + syn_vote_`i'_7 + syn_vote_`i'_8 + syn_vote_`i'_9)/9
			// Note: The first number on syn_vote_#_# is the dataset_version (whether with or without beliefs, etc.) and the second number is the provider_id (which correspond to a list typed up lower on this do file and which are slightly different in this study from study 1)
			
			sort cost
			if `i' == 6 {
				save  ${datadir}/synth_byProvider_ForestWTP.dta, replace
			}
			else {
				merge 1:1 cost experiment using  ${datadir}/synth_byProvider_ForestWTP.dta
				drop _merge
				save  ${datadir}/synth_byProvider_ForestWTP.dta, replace
			}
		restore
		}
		
	
*******************************************************************************
	* merge them all
	use  ${datadir}/actual_vote_ForestWTP.dta, clear
	merge 1:1 cost experiment using  ${datadir}/synth_byProvider_ForestWTP.dta
	drop _merge
	// As expected, we don't have matches for cost = 10 & 300 because those aren't in the original data.
	drop if cost == 5 | cost==300
	sort experiment cost
		
	* Plot Actual vs. Synth (without beliefs) by Provider
	// synth_qsa_mean2 synth_qsa_mean4 synth_qsa_mean6 synth_qsa_mean8 synth_qsa_mean10  synth_qsa_mean12 synth_qsa_mean14 synth_qsa_mean16 synth_qsa_mean18

	foreach v in "without" "with" {
		if "`v'" == "with" {
			local i = 6
		}
		if "`v'" == "without" {
			local i = 9
		}

		foreach exp in "Bounded" "Random" {
			if "`exp'" == "Bounded" {
				local e = 0
				local xlabels = "xlabel(25 50(50)250)"
			}
			if "`exp'" == "Random" {
				local e = 1
				local xlabels = "xlabel(50(50)200)"
			}
			sort experiment cost
			twoway ///
			(line actual_vote cost, lcolor(red)) ///
			(line syn_vote_`i'_5 cost, lcolor(black) lpattern(solid)) ///
			(line syn_vote_`i'_6 cost, lcolor(black) lpattern(longdash_dot)) ///
			(line syn_vote_`i'_7 cost, lcolor(black) lpattern(dash_dot)) ///
			(line syn_vote_`i' cost, lcolor(gray) lpattern(dash)) ///
			(line syn_vote_`i'_1 cost, lcolor(gray) lpattern(dash)) ///
			(line syn_vote_`i'_2 cost, lcolor(gray) lpattern(dash)) ///
			(line syn_vote_`i'_3 cost, lcolor(gray) lpattern(dash)) ///
			(line syn_vote_`i'_4 cost, lcolor(gray) lpattern(dash)) ///
			(line syn_vote_`i'_9 cost, lcolor(gray) lpattern(dash)) ///
			if experiment == `e' ///
			, legend(order(1 "actual" 2 "gpt-5-mini" 3 "kimi-k2" 4 "llama-4-scout" ) col(2)) ///
			ylabel(0(0.1)1) ///
			xtitle("Bid Amount ($)") ///
			ytitle("Share Approved") ///
			title("`exp' Bids") ///
			`xlabels' ///
			saving(beliefQ_`exp'_`v', replace) 
			
			graph export "${figdir}/propensity_to_vote_`exp'_`v'Beliefs_ForestWTP.png", replace

		}
	}
	
	
	
	// Best without beliefs: openrouter.moonshotai/kimi-k2 openrouter.openai/gpt-5-mini
	// ^ Provider_ids: 8 and 9
	// Best with beliefs: openrouter.mistralai/mistral-medium-3.1 
	// ^ provider_id: 6)
	// Best with any single belief Q: gpt-5-mini and llama-4-scout
	// But some questions throw them off.
	
	* Combine the "without" beliefs graphs into a single image
	grc1leg2 beliefQ_Random_without.gph beliefQ_Bounded_without.gph ///
	, col(1) legendfrom(beliefQ_Random_without.gph) ysize(8) xsize(5)
	graph export "${figdir}/propensity_to_vote_withoutBeliefs_ForestWTP.eps", replace
	
	* Combine the "with" beliefs graphs into a single image
	grc1leg2 beliefQ_Random_with.gph beliefQ_Bounded_with.gph ///
	, col(1) legendfrom(beliefQ_Random_with.gph) ysize(8) xsize(5)
	graph export "${figdir}/propensity_to_vote_withBeliefs_ForestWTP.eps", replace
	
	
	
*******************************************************************************	
	
	* Mean absolute deviation calculations
	
	use  ${datadir}/actual_vote_ForestWTP.dta, clear
	merge 1:1 cost experiment using  ${datadir}/synth_byProvider_ForestWTP.dta
	drop _merge
	// As expected, we don't have matches for cost = 10 & 300 because those aren't in the original data.
	drop if cost == 5 | cost==300
	sort experiment cost
	
	// 0  "AGGREGATED"   1  "deepseek-chat-v3.1"  2  "deepseek-r1"   3  "gemini-2.5-flash"   4  "gemini-2.5-flash-lite"   5  "gpt-5-mini"   6  "kimi-k2"   7  "llama-4-scout"   8  "mistral-medium-3.1"   9  "mistral-small-3.2-24b-instruct"
	// first number: if 9 then without, if 6 then with.
	
	forvalues i=1/9 {
	gen abs_dev_without_`i' = abs(syn_vote_9_`i' - actual_vote)
	gen abs_dev_with_`i' = abs(syn_vote_6_`i' - actual_vote)
	}
	
	di as text _n "----- Mean Absolute Deviations: Bounded/Without ----------"
	preserve
	keep if experiment==0
	forvalues i=1/9 {
	mean(abs_dev_without_`i')
	}
	restore
	
	di as text _n "----- Mean Absolute Deviations: Random/Without ----------"
	preserve
	keep if experiment==1
	forvalues i=1/9 {
	mean(abs_dev_without_`i')
	}
	restore
	
	di as text _n "----- Mean Absolute Deviations: Bounded/With ----------"
	preserve
	keep if experiment==0
	forvalues i=1/9 {
	mean(abs_dev_with_`i')
	}
	restore
	
	di as text _n "----- Mean Absolute Deviations: Random/With ----------"
	preserve
	keep if experiment==1
	forvalues i=1/9 {
	mean(abs_dev_with_`i')
	}
	
	
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
********************************************************************************
* Logit model for synthetic data with individual belief Questions (plus demographics)
********************************************************************************
	
	use "${rawdir}\wtp_e_cleaned-v118", clear
	
	* add new rows representing the second round choices (their implicit answer to both)
	gen expand_n = 1
	replace expand_n = 3 if experiment==0 & attempt==1
	expand expand_n
	drop expand_n
	bys id prov experiment attempt run_id dataset_version created_at: gen implicit = _n-1

	replace ctx1_5_q28_cost_cat=3 if implicit==1 & syn_vote ==2 //implicit
	replace ctx1_5_q28_cost_cat=6 if implicit==2 & syn_vote ==2 //implicit
	replace ctx1_5_q28_cost_cat=4 if implicit==1 & syn_vote==1 //implicit
	replace ctx1_5_q28_cost_cat=5 if implicit==2 & syn_vote==1 //implicit
	// Note that cost_cat is a code, not a meaningful value and that syn_vote is not yet coded intuitively--it will be redefined below

	// want to make vote variable binary
	label list syn_vote
	tab syn_vote
	replace syn_vote = . if syn_vote==0
	replace syn_vote=0 if syn_vote==1
	replace syn_vote=1 if syn_vote==2
	tab syn_vote

	label define syn_vote ///
		1 "Vote for" ///
		0 "Vote against", modify

	* code costs the same way as in the paper
	// for repeated subsample we need to decode all treatment related variables

	label list ctx1_5_q28_cost_cat
	gen num_cost = .
	replace num_cost=100 if ctx1_5_q28_cost_cat==0
	replace num_cost=150 if ctx1_5_q28_cost_cat==1
	replace num_cost=200 if ctx1_5_q28_cost_cat==2
	replace num_cost=25 if ctx1_5_q28_cost_cat==3
	replace num_cost=250 if ctx1_5_q28_cost_cat==4
	replace num_cost=300 if ctx1_5_q28_cost_cat==5
	replace num_cost=5 if ctx1_5_q28_cost_cat==6
	replace num_cost=50 if ctx1_5_q28_cost_cat==7
	
	* ── Collapse runs down to the individual-attempt level ───────────────────


	* ── Create a unique attempt identifier ──────────────────────────────────────
	// "attempt" is different each time person is presented with different cost
	// So there are three attempts per bounded respondent
	egen sit_id = group(id attempt)   // unique per person-attempt
	
	* ── Collapse runs down to the individual-attempt level ───────────────────
	
// 	drop if syn_vote ==.
// 	collapse (mean) syn_vote vote (first) id attempt num_cost qsa_syn_infl_ecolog qsa_syn_infl_social ecolog social biol chem, by(sit_id ctx1_5_q28_cost_cat dataset_version experiment)
// 	replace syn_vote =1 if syn_vote>=.5
// 	replace syn_vote =0 if syn_vote<1
	
	* work only with version v6.3-do-real-multi
	label list dataset_version		
	//    6 v6.3-db-real-multi
	//    7 v6.3-db-syn-gpt-beliefs <--not as many observations
	//    8 v6.3-db-syn-multi-1:1 <-- forget about this one for now
	//    9 v6.3-do-real-multi

	foreach with_without in "with" "without" {
		global with_without = "`with_without'"
		preserve
			if "`with_without'" == "with" {
				keep if dataset_version ==6
			}
			else if "`with_without'" == "without" {
				keep if dataset_version ==9
			}

			* ── Expand each observation to 2 rows (For=1, Against=0)
			expand 2

			bysort sit_id: gen alt = _n   // alt=1 (For), alt=2 (Against)
			

			* ── For the "Against" alternative, all attributes = 0 (status quo)
			gen COST_x   = num_cost   * (alt == 1)
			gen ECOL_x   = ecolog   * (alt == 1)
			gen SOCIAL_x = social * (alt == 1)
			gen BIOL_x   = biol   * (alt == 1)
			gen CHEM_x   = chem   * (alt == 1)

			* ── Define the chosen indicator 
			gen chosen = (syn_vote == 1 & alt == 1) | (vote == 0 & alt == 2)


			* check ANA variables
			tab qsa_syn_infl_ecolog
			tab qsa_syn_infl_social
			label list qsa_syn_infl_ecolog
			label list qsa_syn_infl_social
			

			capture drop ECOL_ana
			gen ECOL_ana   = ECOL_x
			replace ECOL_ana = 0 if qsa_syn_infl_ecolog ==10 | qsa_syn_infl_ecolog ==11
			
			replace ECOL_ana =. if qsa_syn_infl_ecolog != 5 & (qsa_syn_infl_ecolog <10 | qsa_syn_infl_ecolog <12)

			capture drop SOCIAL_ana
			gen SOCIAL_ana = SOCIAL_x
			replace SOCIAL_ana = 0 if qsa_syn_infl_social ==9 | qsa_syn_infl_social==10
			
			replace SOCIAL_ana =. if qsa_syn_infl_social != 3 & (qsa_syn_infl_social <9 | qsa_syn_infl_social <11)
			

			*********** GET WTP **************

			* ── Column 1: Bounded, 1st situation
			clogit chosen COST_x ECOL_ana SOCIAL_ana BIOL_x CHEM_x ///
				if attempt<=3 & experiment ==0, ///
				group(sit_id)
			est store boundcond1

			
			* ── Column 1: Repeated, 1st situation
			clogit chosen COST_x ECOL_ana SOCIAL_ana BIOL_x CHEM_x ///
				if attempt<=3 & experiment ==1, ///
				group(sit_id)
			est store repcond1

		clear
			set obs 2
			gen provider_id = 0 // Aggregate of all LLM results
			gen experiment = "bounded" 
			replace experiment = "repeated" if _n>1
					
			* WTP estimates from conditional logit with stated ANA:
			estimates restore boundcond1
			nlcom (-_b[ECOL_ana] / _b[COST_x]), post    // WTP for ecological acreage
			gen ECOL_WTP = _b[_nl_1] 
			gen ECOL_UB = _b[_nl_1] + 1.96*_se[_nl_1]
			gen ECOL_LB = _b[_nl_1] - 1.96*_se[_nl_1]
		
			estimates restore boundcond1
			nlcom (-_b[SOCIAL_ana] / _b[COST_x]), post  // WTP for social acreage
			gen SOCIAL_WTP = _b[_nl_1]
			gen SOCIAL_UB = _b[_nl_1] + 1.96*_se[_nl_1]
			gen SOCIAL_LB = _b[_nl_1] - 1.96*_se[_nl_1]
		
			
			estimates restore repcond1
			nlcom (-_b[ECOL_ana] / _b[COST_x]), post    // WTP for ecological acreage
			replace ECOL_WTP = _b[_nl_1] if _n>1
			replace ECOL_UB = _b[_nl_1] + 1.96*_se[_nl_1] if _n>1
			replace ECOL_LB = _b[_nl_1] - 1.96*_se[_nl_1] if _n>1
			
			estimates restore repcond1
			nlcom (-_b[SOCIAL_ana] / _b[COST_x]), post  // WTP for social acreage
			replace SOCIAL_WTP = _b[_nl_1] if _n>1
			replace SOCIAL_UB = _b[_nl_1] + 1.96*_se[_nl_1] if _n>1
			replace SOCIAL_LB = _b[_nl_1] - 1.96*_se[_nl_1] if _n>1
		
			save "${datadir}/wtp_summary_${with_without}Beliefs_ForestWTP.dta", replace
		restore
	}
	
******** Now for each LLM individually
	use "${rawdir}\wtp_e_cleaned-v118", clear
	
	* add new rows representing the second round choices (their implicit answer to both)
	gen expand_n = 1
	replace expand_n = 3 if experiment==0 & attempt==1
	expand expand_n
	drop expand_n
	bys id prov experiment attempt run_id dataset_version created_at: gen implicit = _n-1

	replace ctx1_5_q28_cost_cat=3 if implicit==1 & syn_vote ==2 //implicit
	replace ctx1_5_q28_cost_cat=6 if implicit==2 & syn_vote ==2 //implicit
	replace ctx1_5_q28_cost_cat=4 if implicit==1 & syn_vote==1 //implicit
	replace ctx1_5_q28_cost_cat=5 if implicit==2 & syn_vote==1 //implicit
	// Note that cost_cat is a code, not a meaningful value and that syn_vote is not yet coded intuitively--it will be redefined below

	// want to make vote variable binary
	label list syn_vote
	tab syn_vote
	replace syn_vote = . if syn_vote==0
	replace syn_vote=0 if syn_vote==1
	replace syn_vote=1 if syn_vote==2
	tab syn_vote

	label define syn_vote ///
		1 "Vote for" ///
		0 "Vote against", modify

	* code costs the same way as in the paper
	// for repeated subsample we need to decode all treatment related variables

	label list ctx1_5_q28_cost_cat
	gen num_cost = .
	replace num_cost=100 if ctx1_5_q28_cost_cat==0
	replace num_cost=150 if ctx1_5_q28_cost_cat==1
	replace num_cost=200 if ctx1_5_q28_cost_cat==2
	replace num_cost=25 if ctx1_5_q28_cost_cat==3
	replace num_cost=250 if ctx1_5_q28_cost_cat==4
	replace num_cost=300 if ctx1_5_q28_cost_cat==5
	replace num_cost=5 if ctx1_5_q28_cost_cat==6
	replace num_cost=50 if ctx1_5_q28_cost_cat==7
	
	* ── Collapse runs down to the individual-attempt level ───────────────────


	* ── Create a unique attempt identifier ──────────────────────────────────────
	// "attempt" is different each time person is presented with different cost
	// So there are three attempts per bounded respondent
	egen sit_id = group(id attempt)   // unique per person-attempt
	
	* work with gpt-5-mini
	tab prov
	label list prov
// 		0 deepseek-chat-v3.1
// 		1 deepseek-r1
// 		2 gemini-2.5-flash
// 		3 gemini-2.5-flash-lite
// 		4 gpt-5-mini
// 		5 kimi-k2
// 		6 llama-4-scout
// 		7 mistral-medium-3.1
// 		8 mistral-small-3.2-24b-instruct

save "${datadir}\wtp_e_working4loop_v2", replace
// v2 means that I expanded the data to include implicit for/against

	forvalues prov = 1/9 {
		// takes like 5 min to run
			use "${datadir}/wtp_e_working4loop_v2", clear
			global prov = `prov'-1
			keep if prov == `prov'-1
			
		* ── Collapse runs down to the individual-attempt level ───────────────────
		
	// 	drop if syn_vote ==.
	// 	collapse (mean) syn_vote vote (first) id attempt num_cost qsa_syn_infl_ecolog qsa_syn_infl_social ecolog social biol chem, by(sit_id ctx1_5_q28_cost_cat dataset_version experiment)
	// 	replace syn_vote =1 if syn_vote>=.5
	// 	replace syn_vote =0 if syn_vote<1
		
		* work only with version v6.3-do-real-multi
		label list dataset_version		
		//    6 v6.3-db-real-multi
		//    7 v6.3-db-syn-gpt-beliefs <--not as many observations
		//    8 v6.3-db-syn-multi-1:1 <-- forget about this one for now
		//    9 v6.3-do-real-multi

		foreach with_without in "with" "without" {
			global with_without = "`with_without'"
			preserve
				if "`with_without'" == "with" {
					keep if dataset_version ==6
				}
				else if "`with_without'" == "without" {
					keep if dataset_version ==9
				}

				* ── Expand each observation to 2 rows (For=1, Against=0)
				expand 2

				bysort sit_id: gen alt = _n   // alt=1 (For), alt=2 (Against)
				

				* ── For the "Against" alternative, all attributes = 0 (status quo)
				gen COST_x   = num_cost   * (alt == 1)
				gen ECOL_x   = ecolog   * (alt == 1)
				gen SOCIAL_x = social * (alt == 1)
				gen BIOL_x   = biol   * (alt == 1)
				gen CHEM_x   = chem   * (alt == 1)

				* ── Define the chosen indicator 
				gen chosen = (syn_vote == 1 & alt == 1) | (vote == 0 & alt == 2)


				* check ANA variables
				tab qsa_syn_infl_ecolog
				tab qsa_syn_infl_social
				label list qsa_syn_infl_ecolog
				label list qsa_syn_infl_social
				

				capture drop ECOL_ana
				gen ECOL_ana   = ECOL_x
				replace ECOL_ana = 0 if qsa_syn_infl_ecolog ==10 | qsa_syn_infl_ecolog ==11
				
				replace ECOL_ana =. if qsa_syn_infl_ecolog != 5 & (qsa_syn_infl_ecolog <10 | qsa_syn_infl_ecolog <12)

				capture drop SOCIAL_ana
				gen SOCIAL_ana = SOCIAL_x
				replace SOCIAL_ana = 0 if qsa_syn_infl_social ==9 | qsa_syn_infl_social==10
				
				replace ECOL_ana =. if qsa_syn_infl_ecolog != 3 & (qsa_syn_infl_ecolog <9 | qsa_syn_infl_ecolog <11)
				

				*********** GET WTP **************

				* ── Column 1: Bounded, 1st situation
				clogit chosen COST_x ECOL_ana SOCIAL_ana BIOL_x CHEM_x ///
					if attempt<=3 & experiment ==0, ///
					group(sit_id)
				est store boundcond1

				
				* ── Column 1: Repeated, 1st situation
				clogit chosen COST_x ECOL_ana SOCIAL_ana BIOL_x CHEM_x ///
					if attempt<=3 & experiment ==1, ///
					group(sit_id)
				est store repcond1

			clear
				set obs 2
				gen provider_id = ${prov}+1 // Aggregate of all LLM results
				gen experiment = "bounded" 
				replace experiment = "repeated" if _n>1
						
				* WTP estimates from conditional logit with stated ANA:
				estimates restore boundcond1
				nlcom (-_b[ECOL_ana] / _b[COST_x]), post    // WTP for ecological acreage
				gen ECOL_WTP = _b[_nl_1] 
				gen ECOL_UB = _b[_nl_1] + 1.96*_se[_nl_1]
				gen ECOL_LB = _b[_nl_1] - 1.96*_se[_nl_1]
			
				estimates restore boundcond1
				nlcom (-_b[SOCIAL_ana] / _b[COST_x]), post  // WTP for social acreage
				gen SOCIAL_WTP = _b[_nl_1]
				gen SOCIAL_UB = _b[_nl_1] + 1.96*_se[_nl_1]
				gen SOCIAL_LB = _b[_nl_1] - 1.96*_se[_nl_1]
			
				
				estimates restore repcond1
				nlcom (-_b[ECOL_ana] / _b[COST_x]), post    // WTP for ecological acreage
				replace ECOL_WTP = _b[_nl_1] if _n>1
				replace ECOL_UB = _b[_nl_1] + 1.96*_se[_nl_1] if _n>1
				replace ECOL_LB = _b[_nl_1] - 1.96*_se[_nl_1] if _n>1
				
				estimates restore repcond1
				nlcom (-_b[SOCIAL_ana] / _b[COST_x]), post  // WTP for social acreage
				replace SOCIAL_WTP = _b[_nl_1] if _n>1
				replace SOCIAL_UB = _b[_nl_1] + 1.96*_se[_nl_1] if _n>1
				replace SOCIAL_LB = _b[_nl_1] - 1.96*_se[_nl_1] if _n>1
			
				save "${datadir}/wtp_prov${prov}_${with_without}Beliefs_ForestWTP.dta", replace
			restore
		}
	}

********************************************************************************
**************************** Interval plots of these ***************************
********************************************************************************

	* Append data
	use "${datadir}/wtp_summary_withBeliefs_ForestWTP.dta", clear
	forvalues prov = 1/9 {
		local prov_1 = `prov'-1
		append using "${datadir}/wtp_prov`prov_1'_withBeliefs_ForestWTP.dta"
	}
	gen with_beliefs = 1
	
	append using "${datadir}/wtp_summary_withoutBeliefs_ForestWTP.dta"
	forvalues prov = 1/9 {
		local prov_1 = `prov'-1
		append using "${datadir}/wtp_prov`prov_1'_withoutBeliefs_ForestWTP.dta"
	}
	replace with_beliefs = 0 if with_beliefs ==.

	
	sort provider_id experiment with_beliefs 
	
// 		0 deepseek-chat-v3.1
// 		1 deepseek-r1
// 		2 gemini-2.5-flash
// 		3 gemini-2.5-flash-lite
// 		4 gpt-5-mini
// 		5 kimi-k2
// 		6 llama-4-scout
// 		7 mistral-medium-3.1
// 		8 mistral-small-3.2-24b-instruct
	
	gen provider = ""
	replace provider = "openrouter.deepseek/deepseek-chat-v3.1" if provider_id == 1
	replace provider = "openrouter.deepseek/deepseek-r1" if provider_id == 2
	replace provider = "openrouter.google/gemini-2.5-flash" if provider_id == 3
	replace provider = "openrouter.google/gemini-2.5-flash-lite" if provider_id == 4
	replace provider = "openrouter.openai/gpt-5-mini" if provider_id == 5
	replace provider = "openrouter.moonshotai/kimi-k2" if provider_id == 6
	replace provider = "openrouter.meta-llama/llama-4-scout" if provider_id == 7
	replace provider = "openrouter.mistralai/mistral-medium-3.1" if provider_id == 8
	replace provider = "openrouter.mistralai/mistral-small-3.2-24b-instruct" if provider_id == 9
	
	* Add blank rows between LLM models to give them space
	insobs 1, before(5)
	insobs 1, before(10)
	insobs 1, before(15)
	insobs 1, before(20)
	insobs 1, before(25)
	insobs 1, before(30)
	insobs 1, before(35)
	insobs 1, before(40)
	insobs 1, before(45)
	
	gen row = _n
		 

********************************************************************************
*Interval Plots for attempt <=3 

	set scheme s1mono // black and white

	
***** Bounded
	twoway ///
	(rcap SOCIAL_LB SOCIAL_UB row if !(provider_id==7 & with_beliefs ==1), horizontal) /// code for 95% CI
	(scatter row SOCIAL_WTP if with_beliefs ==0, mcolor(red)) /// dot for group 1
	(scatter row SOCIAL_WTP if with_beliefs ==1, mcolor(blue)) /// dot for group 2
	if experiment=="bounded", ///
	legend(row(1) order(2 "w/o beliefs" 3 "w/ beliefs") pos(6)) /// legend at 6 o'clock position
	ylabel(1.5 "AGGREGATED" 6.5 "deepseek-chat-v3.1" 11.5 "deepseek-r1" 16.5 "gemini-2.5-flash" 21.5 "gemini-2.5-flash-lite" 26.5 "gpt-5-mini"  31.5 "kimi-k2" 36.5 "llama-4-scout"  41.5  "mistral-medium-3.1" 46.5 "mistral-small-3.2-24b-instruct", angle(0) noticks) ///
	/// note that the labels are 1.5, 4.5, etc so they are between rows 1&2, 4&5, etc.
	/// also note that there is a space in between different rows by leaving out rows 3, 6, 9, and 12 
	xtitle("WTP ($) of Synthetic Respondents") /// 
	ytitle("LLM Provider") /// 
	yscale(reverse) /// y axis is flipped
	xline(56.37, lpattern(solid) lcolor(gs8)) ///
	xline(75, lpattern(dash) lcolor(gs8)) ///
	xline(35, lpattern(dash) lcolor(gs8)) ///
	xline(0, lcolor(gs12) lwidth(thin)) ///
	xlabel(-750(150)-150 56.37 300)

	graph export "${figdir}\dot_and_95CI_bounded_ForestWTP_NoOutliers.png", replace width(2000)

***** Repeated
/*	
	* These are the real 
	xline(9.95, lpattern(solid) lcolor(gs8)) ///
	xline(5, lpattern(dash) lcolor(gs8)) ///
	xline(14, lpattern(dash) lcolor(gs8)) ///
*/
	
	twoway ///
	(rcap SOCIAL_LB SOCIAL_UB row if !(provider_id==3 & with_beliefs==1) & !(provider_id==5 & with_beliefs==1), horizontal) /// code for 95% CI
	(scatter row SOCIAL_WTP if with_beliefs ==0, mcolor(red)) /// dot for group 1
	(scatter row SOCIAL_WTP if with_beliefs ==1, mcolor(blue)) /// dot for group 2
	if experiment=="repeated", ///
	legend(row(1) order(2 "w/o beliefs" 3 "w/ beliefs") pos(6)) /// legend at 6 o'clock position
	ylabel(3.5 "AGGREGATED" 8.5 "deepseek-chat-v3.1" 13.5 "deepseek-r1" 18.5 "gemini-2.5-flash" 23.5 "gemini-2.5-flash-lite" 28.5 "gpt-5-mini"  33.5 "kimi-k2" 38.5 "llama-4-scout"  43.5  "mistral-medium-3.1" 48 "mistral-small-3.2-24b-instruct", angle(0) noticks) ///
	/// note that the labels are 1.5, 4.5, etc so they are between rows 1&2, 4&5, etc.
	/// also note that there is a space in between different rows by leaving out rows 3, 6, 9, and 12 
	xtitle("WTP ($) of Synthetic Respondents") /// 
	ytitle("LLM Provider") /// 
	yscale(reverse) /// y axis is flipped
	xline(9.95, lpattern(solid) lcolor(gs8)) ///
	xline(5, lpattern(dash) lcolor(gs8)) ///
	xline(14, lpattern(dash) lcolor(gs8)) ///
	xline(0, lcolor(gs12) lwidth(thin)) ///
	xlabel(-150 9.95 150(150)450)
/*		
	xline(56.37, lpattern(solid) lcolor(gs8)) ///
	xline(75, lpattern(dash) lcolor(gs8)) ///
	xline(35, lpattern(dash) lcolor(gs8)) ///

*/
	graph export "${figdir}\dot_and_95CI_repeated_ForestWTP_NoOutliers.png", replace width(2000)
		
		
		
********************************************************************************
* TABLES BLOCK — Study 2 (Giguere et al. 2020 replication)
* Append this to the end of the existing forest-WTP do-file.
*
* Produces four LaTeX tables:
*   tab_repl_clogit_Study2.tex   -- replication of empirical clogit (Table A1)
*   tab_syn_clogit_<design>_<cond>.tex (×4) -- synthetic clogit by design×cond
*   tab_syn_wtp_Study2.tex       -- synthetic WTP estimates (headline)
*   tab_slope_ratios_Study2.tex  -- synthetic-vs-empirical slope ratios
*
* Globals expected (set at top of master do-file):
*   $datadir, $rawdir, $tabdir
*
* Required packages: esttab, estout
* ssc install estout, replace
********************************************************************************


* Provider labels (match label list "prov" in source data)
local prov_labs ///
    `"1 "deepseek-chat-v3.1""' ///
    `"2 "deepseek-r1""' ///
    `"3 "gemini-2.5-flash""' ///
    `"4 "gemini-2.5-flash-lite""' ///
    `"5 "gpt-5-mini""' ///
    `"6 "kimi-k2""' ///
    `"7 "llama-4-scout""' ///
    `"8 "mistral-medium-3.1""' ///
    `"9 "mistral-small-3.2-24b-instruct""'

********************************************************************************
* TABLE 1 — Replication clogit (empirical/human respondents only)
* Unadjusted specification: COST_x ECOL_x SOCIAL_x BIOL_x CHEM_x
* Four columns: bounded × repeated, but here we report both with the same
* unadjusted spec since we chose "Unadjusted" as the headline.
********************************************************************************

import delimited "${datadir}/original_data.csv", clear

//add new rows representing the second round choices
gen expand_n = 1
replace expand_n = 2 if experiment==1
expand expand_n
drop expand_n
bys id experiment: gen numround = _n

replace cost=250 if numround==2 & vote==1
replace cost=25 if numround==2 & vote==0
replace vote=0 if cost==250 & numvotes==2
replace vote=1 if cost==25 & numvotes==2

* ── Create a unique situation identifier ──────────────────────────────────────
egen sit_id = group(id numround)   // unique per person-situation

* ── Expand each observation to 2 rows (For=1, Against=0) ─────────────────────
expand 2
bysort sit_id: gen alt = _n   // alt=1 (For), alt=2 (Against)

* ── For the "Against" alternative, all attributes = 0 (status quo) ────────────
gen COST_x   = cost   * (alt == 1)
gen ECOL_x   = ecolog   * (alt == 1)
gen SOCIAL_x = social * (alt == 1)
gen BIOL_x   = biol   * (alt == 1)
gen CHEM_x   = chem   * (alt == 1)

label var COST_x   "Cost (\$)"
label var ECOL_x   "Ecologically important acres"
label var SOCIAL_x "Socially important acres"
label var BIOL_x   "Biological treatment"
label var CHEM_x   "Chemical treatment"

* ── Define the chosen indicator ───────────────────────────────────────────────
gen chosen = (vote == 1 & alt == 1) | (vote == 0 & alt == 2)

eststo clear

* ── Table 2: Conditional logit, bounded sample, 1st situation only ───────────
eststo repl_bnd1: clogit chosen COST_x ECOL_x SOCIAL_x BIOL_x CHEM_x ///
    if experiment == 1 & numround == 1, ///
    group(sit_id) vce(cluster id)
estadd local design "Bounded1"	
	
* ── Repeated sample, 1st situation only ───────────
eststo repl_rep1: clogit chosen COST_x ECOL_x SOCIAL_x BIOL_x CHEM_x ///
    if experiment == 6 & numround == 1, ///
    group(sit_id) vce(cluster id)
estadd local design "Repeated1"
	
* ── 1st and 2nd situations, bounded sample ────────────────────────────────────
eststo repl_bnd2: clogit chosen COST_x ECOL_x SOCIAL_x BIOL_x CHEM_x ///
    if experiment == 1 & numround <= 2, ///
    group(sit_id) vce (cluster id)
estadd local design "Bounded2"

esttab repl_bnd1 repl_rep1 repl_bnd2 ///
 		using "${tabdir}/tab_repl_clogit_Study2_UPDATED.tex", replace ///
		booktabs label se star(* 0.10 ** 0.05 *** 0.01) ///
		b(%9.4f) se(%9.4f) ///
		mtitles("Bounded (1st)" "Random-cost (1st)" "Bounded (1st and 2nd)") ///
		scalars("ll Log-likelihood" "N Observations") ///
		nonotes ///
		addnotes("Conditional logit estimates on \textcite{Giguere2020} human-respondent data." ///
				 "ANA-adjusted specification.")
				 
				 
 	preserve
		clear
		set obs 2
		gen experiment = "bounded" in 1
		replace experiment = "repeated" in 2
		gen emp_beta_cost = .
		
		estimates restore repl_bnd
		replace emp_beta_cost = _b[COST_x] in 1
		
		estimates restore repl_rep
		replace emp_beta_cost = _b[COST_x] in 2
		
		save "${datadir}/empirical_bid_coefs_Study2.dta", replace
	restore



// ******* OLD CODE ********
// 	use "${datadir}/wtp_e_working4loop_v2", clear
//
// 	* Keep human-respondent data only. Per the do-file comments:
// 	*   dataset_version == 9 is "v6.3-do-real-multi" (the real responses)
// 	* If your empirical-only data live under a different version code, change here.
// 	keep if dataset_version == 9
//
// 	* Build the alt-specific attributes (mirrors the main loop)
// 	expand 2
// 	bysort sit_id: gen alt = _n
// 	gen COST_x   = num_cost * (alt == 1)
// 	gen ECOL_x   = ecolog   * (alt == 1)
// 	gen SOCIAL_x = social   * (alt == 1)
// 	gen BIOL_x   = biol     * (alt == 1)
// 	gen CHEM_x   = chem     * (alt == 1)
// 	gen chosen   = (syn_vote == 1 & alt == 1) | (vote == 0 & alt == 2)
//
// 	label var COST_x   "Cost (\$)"
// 	label var ECOL_x   "Ecologically important acres"
// 	label var SOCIAL_x "Socially important acres"
// 	label var BIOL_x   "Biological treatment"
// 	label var CHEM_x   "Chemical treatment"

// 	eststo clear
//
// 	* Column (1): Bounded design
// 	eststo repl_bnd: clogit chosen COST_x ECOL_x SOCIAL_x BIOL_x CHEM_x ///
// 		if attempt <= 3 & experiment == 0, group(sit_id)
// 	estadd local design "Bounded"
//
// 	* Column (2): Repeated (random-cost) design
// 	eststo repl_rep: clogit chosen COST_x ECOL_x SOCIAL_x BIOL_x CHEM_x ///
// 		if attempt <= 3 & experiment == 1, group(sit_id)
// 	estadd local design "Random-cost"
//
// 	esttab repl_bnd repl_rep ///
// 		using "${tabdir}/tab_repl_clogit_Study2.tex", replace ///
// 		booktabs label se star(* 0.10 ** 0.05 *** 0.01) ///
// 		b(%9.4f) se(%9.4f) ///
// 		mtitles("Bounded" "Random-cost") ///
// 		scalars("ll Log-likelihood" "N Observations") ///
// 		nonotes ///
// 		addnotes("Conditional logit estimates on \textcite{Giguere2020} human-respondent data." ///
// 				 "Unadjusted specification (no attribute-nonattendance correction).")
//		
// 	* Save the empirical bid coefficients for later use (Table 4 slope ratios)
// 	preserve
// 		clear
// 		set obs 2
// 		gen experiment = "bounded" in 1
// 		replace experiment = "repeated" in 2
// 		gen emp_beta_cost = .
//		
// 		estimates restore repl_bnd
// 		replace emp_beta_cost = _b[COST_x] in 1
//		
// 		estimates restore repl_rep
// 		replace emp_beta_cost = _b[COST_x] in 2
//		
// 		save "${datadir}/empirical_bid_coefs_Study2.dta", replace
// 	restore

********************************************************************************
* TABLE 2 — Synthetic clogit, long-format (rows = LLMs)
* Four tables, one per (design × condition).
* For each cell we re-run the clogit and collect:
*   COST_x, ECOL_x, SOCIAL_x, BIOL_x, CHEM_x, N, slope ratio
*
* Strategy: estimate per-provider, store results in matrices, then assemble
* a custom LaTeX table by hand (more reliable than esttab for this shape).
********************************************************************************

	* Loop over design × condition, building one table per combination
	foreach exp_val in 0 1 {
		if `exp_val' == 0 {
			local exp_lab "bounded"
			local exp_title "Bounded choice design"
		}
		else {
			local exp_lab "repeated"
			local exp_title "Random-cost design"
		}
		
		foreach with_without in "with" "without" {
			local cond_lab "`with_without'Beliefs"
			if "`with_without'" == "with" {
				local cond_title "Demographics + beliefs"
				local dv_code 6
			}
			else {
				local cond_title "Demographics only"
				local dv_code 9
			}
			
			* Empirical bid coefficient for this design (for slope ratio column)
			preserve
				use "${datadir}/empirical_bid_coefs_Study2.dta", clear
				if "`exp_lab'" == "bounded" {
					local emp_beta = emp_beta_cost[1]
				}
				else {
					local emp_beta = emp_beta_cost[2]
				}
			restore
			
			* Matrix to hold per-provider coefficients
			* Rows: 10 (one per provider, plus aggregated in row 10)
			* Cols: COST, COST_se, ECOL, ECOL_se, SOCIAL, SOCIAL_se, BIOL, BIOL_se,
			*       CHEM, CHEM_se, N, slope_ratio
			matrix syn_results = J(10, 12, .)
			local row_names ""
			
			* ─── Per-provider clogits ──────────────────────────────────────────
			forvalues p = 0/8 {
				use "${datadir}\wtp_e_working4loop_v2", clear
				keep if prov == `p'
				keep if dataset_version == `dv_code'
				keep if experiment == `exp_val'
				keep if attempt <= 3
				
				expand 2
				bysort sit_id: gen alt = _n
				gen COST_x   = num_cost * (alt == 1)
				gen ECOL_x   = ecolog   * (alt == 1)
				gen SOCIAL_x = social   * (alt == 1)
				gen BIOL_x   = biol     * (alt == 1)
				gen CHEM_x   = chem     * (alt == 1)
				gen chosen   = (syn_vote == 1 & alt == 1) | (vote == 0 & alt == 2)
				
				capture noisily clogit chosen COST_x ECOL_x SOCIAL_x BIOL_x CHEM_x, ///
					group(sit_id)
				
				if _rc == 0 {
					local row = `p' + 1
					matrix syn_results[`row', 1]  = _b[COST_x]
					matrix syn_results[`row', 2]  = _se[COST_x]
					matrix syn_results[`row', 3]  = _b[ECOL_x]
					matrix syn_results[`row', 4]  = _se[ECOL_x]
					matrix syn_results[`row', 5]  = _b[SOCIAL_x]
					matrix syn_results[`row', 6]  = _se[SOCIAL_x]
					matrix syn_results[`row', 7]  = _b[BIOL_x]
					matrix syn_results[`row', 8]  = _se[BIOL_x]
					matrix syn_results[`row', 9]  = _b[CHEM_x]
					matrix syn_results[`row', 10] = _se[CHEM_x]
					matrix syn_results[`row', 11] = e(N)
					matrix syn_results[`row', 12] = _b[COST_x] / `emp_beta'
				}
			}
			
			* ─── Aggregated (all providers pooled, same condition) ─────────────
			use "${datadir}\wtp_e_working4loop_v2", clear
			keep if dataset_version == `dv_code'
			keep if experiment == `exp_val'
			keep if attempt <= 3
			
			expand 2
			bysort prov sit_id: gen alt = _n
			gen COST_x   = num_cost * (alt == 1)
			gen ECOL_x   = ecolog   * (alt == 1)
			gen SOCIAL_x = social   * (alt == 1)
			gen BIOL_x   = biol     * (alt == 1)
			gen CHEM_x   = chem     * (alt == 1)
			gen chosen   = (syn_vote == 1 & alt == 1) | (vote == 0 & alt == 2)
			
			* For the pooled estimate we re-group by (prov, sit_id) so each
			* person-attempt-provider gets its own choice set.
			egen agg_sit = group(prov sit_id)
			clogit chosen COST_x ECOL_x SOCIAL_x BIOL_x CHEM_x, group(agg_sit)
			
			matrix syn_results[10, 1]  = _b[COST_x]
			matrix syn_results[10, 2]  = _se[COST_x]
			matrix syn_results[10, 3]  = _b[ECOL_x]
			matrix syn_results[10, 4]  = _se[ECOL_x]
			matrix syn_results[10, 5]  = _b[SOCIAL_x]
			matrix syn_results[10, 6]  = _se[SOCIAL_x]
			matrix syn_results[10, 7]  = _b[BIOL_x]
			matrix syn_results[10, 8]  = _se[BIOL_x]
			matrix syn_results[10, 9]  = _b[CHEM_x]
			matrix syn_results[10, 10] = _se[CHEM_x]
			matrix syn_results[10, 11] = e(N)
			matrix syn_results[10, 12] = _b[COST_x] / `emp_beta'
			
			* ─── Write the LaTeX table by hand ─────────────────────────────────
			local tabname "tab_syn_clogit_`exp_lab'_`cond_lab'.tex"
			local fh
			capture file close fh
			file open fh using "${tabdir}/`tabname'", write replace
			
			file write fh "\begin{table}[h]" _n
			file write fh "\centering" _n
			file write fh "\caption{Synthetic conditional logit estimates: `exp_title', `cond_title'.}" _n
			file write fh "\label{tab:syn-clogit-`exp_lab'-`cond_lab'}" _n
			file write fh "\begin{threeparttable}" _n
			file write fh "\footnotesize" _n
			file write fh "\begin{tabular}{lcccccccr}" _n
			file write fh "\toprule" _n
			file write fh "Model & COST & ECOL & SOCIAL & BIOL & CHEM & N & $\hat\beta_{COST}/\hat\beta_{COST}^{emp}$ \\" _n
			file write fh "\midrule" _n
			
			* Provider name lookup
			local pname1  "deepseek-chat-v3.1"
			local pname2  "deepseek-r1"
			local pname3  "gemini-2.5-flash"
			local pname4  "gemini-2.5-flash-lite"
			local pname5  "gpt-5-mini"
			local pname6  "kimi-k2"
			local pname7  "llama-4-scout"
			local pname8  "mistral-medium-3.1"
			local pname9  "mistral-small-3.2-24b-instruct"
			
			* Write per-provider rows: coefficient line, then SE line
			forvalues r = 1/9 {
				local pn "`pname`r''"
				local cost_b  = syn_results[`r', 1]
				local cost_se = syn_results[`r', 2]
				local ecol_b  = syn_results[`r', 3]
				local ecol_se = syn_results[`r', 4]
				local soc_b   = syn_results[`r', 5]
				local soc_se  = syn_results[`r', 6]
				local biol_b  = syn_results[`r', 7]
				local biol_se = syn_results[`r', 8]
				local chem_b  = syn_results[`r', 9]
				local chem_se = syn_results[`r', 10]
				local nobs    = syn_results[`r', 11]
				local ratio   = syn_results[`r', 12]
				
				* Coefficient row
				file write fh "`pn'"
				file write fh " & " %9.4f (`cost_b')
				file write fh " & " %9.2f (`ecol_b')
				file write fh " & " %9.2f (`soc_b')
				file write fh " & " %9.4f (`biol_b')
				file write fh " & " %9.4f (`chem_b')
				file write fh " & " %9.0fc (`nobs')
				file write fh " & " %6.3f (`ratio')
				file write fh " \\" _n
				
				* SE row (in parens)
				file write fh ""
				file write fh " & (" %9.4f (`cost_se') ")"
				file write fh " & (" %9.2f (`ecol_se') ")"
				file write fh " & (" %9.2f (`soc_se') ")"
				file write fh " & (" %9.4f (`biol_se') ")"
				file write fh " & (" %9.4f (`chem_se') ")"
				file write fh " & & \\" _n
			}
			
			* Aggregated row
			file write fh "\midrule" _n
			local cost_b  = syn_results[10, 1]
			local cost_se = syn_results[10, 2]
			local ecol_b  = syn_results[10, 3]
			local ecol_se = syn_results[10, 4]
			local soc_b   = syn_results[10, 5]
			local soc_se  = syn_results[10, 6]
			local biol_b  = syn_results[10, 7]
			local biol_se = syn_results[10, 8]
			local chem_b  = syn_results[10, 9]
			local chem_se = syn_results[10, 10]
			local nobs    = syn_results[10, 11]
			local ratio   = syn_results[10, 12]
			
			file write fh "Aggregated"
			file write fh " & " %9.4f (`cost_b')
			file write fh " & " %9.2f (`ecol_b')
			file write fh " & " %9.2f (`soc_b')
			file write fh " & " %9.4f (`biol_b')
			file write fh " & " %9.4f (`chem_b')
			file write fh " & " %9.0fc (`nobs')
			file write fh " & " %6.3f (`ratio')
			file write fh " \\" _n
			file write fh ""
			file write fh " & (" %9.4f (`cost_se') ")"
			file write fh " & (" %9.2f (`ecol_se') ")"
			file write fh " & (" %9.2f (`soc_se') ")"
			file write fh " & (" %9.4f (`biol_se') ")"
			file write fh " & (" %9.4f (`chem_se') ")"
			file write fh " & & \\" _n
			
			* Empirical benchmark row (from the replication estimates)
			file write fh "\midrule" _n
			estimates restore repl_`=cond("`exp_lab'"=="bounded","bnd","rep")'
			local emp_cost_b  = _b[COST_x]
			local emp_cost_se = _se[COST_x]
			local emp_ecol_b  = _b[ECOL_x]
			local emp_ecol_se = _se[ECOL_x]
			local emp_soc_b   = _b[SOCIAL_x]
			local emp_soc_se  = _se[SOCIAL_x]
			local emp_biol_b  = _b[BIOL_x]
			local emp_biol_se = _se[BIOL_x]
			local emp_chem_b  = _b[CHEM_x]
			local emp_chem_se = _se[CHEM_x]
			local emp_nobs    = e(N)
			
			file write fh "Empirical (Giguere et al.)"
			file write fh " & " %9.4f (`emp_cost_b')
			file write fh " & " %9.2f (`emp_ecol_b')
			file write fh " & " %9.2f (`emp_soc_b')
			file write fh " & " %9.4f (`emp_biol_b')
			file write fh " & " %9.4f (`emp_chem_b')
			file write fh " & " %9.0fc (`emp_nobs')
			file write fh " & 1.000 \\" _n
			file write fh ""
			file write fh " & (" %9.4f (`emp_cost_se') ")"
			file write fh " & (" %9.2f (`emp_ecol_se') ")"
			file write fh " & (" %9.2f (`emp_soc_se') ")"
			file write fh " & (" %9.4f (`emp_biol_se') ")"
			file write fh " & (" %9.4f (`emp_chem_se') ")"
			file write fh " & & \\" _n
			
			file write fh "\bottomrule" _n
			file write fh "\end{tabular}" _n
			file write fh "\begin{tablenotes}\footnotesize" _n
			file write fh "\item \textit{Notes:} Conditional logit estimates from `exp_title' choice data, persona condition: `cond_title'. " _n
			file write fh "Standard errors in parentheses. " _n
			file write fh "Final column reports the synthetic bid coefficient divided by the empirical bid coefficient; values below 1 indicate slope compression. " _n
			file write fh "Aggregated row pools synthetic responses across all nine LLMs; each (provider, respondent, attempt) cell forms its own choice set. " _n
			file write fh "Empirical benchmark is the same unadjusted specification estimated on \textcite{Giguere2020} human-respondent data." _n
			file write fh "\end{tablenotes}" _n
			file write fh "\end{threeparttable}" _n
			file write fh "\end{table}" _n
			file close fh
			
			di as result "Wrote `tabname'"
		}
	}

********************************************************************************
* TABLE 3 — Synthetic WTP estimates (headline)
* Reads the wtp_prov*_*Beliefs_ForestWTP.dta files saved by the main loop,
* appends them, and writes a LaTeX table with rows = providers,
* columns = (design × condition), each cell = "WTP [LB, UB]".
*
* NOTE: This block assumes the LB/UB convention has been fixed in the main
* loop (i.e., LB = WTP - 1.96*SE and UB = WTP + 1.96*SE).
********************************************************************************

	* Stack all per-provider WTP files for both conditions
	use "${datadir}/wtp_summary_withBeliefs_ForestWTP.dta", clear
	gen with_beliefs = 1

	forvalues p = 0/8 {
		append using "${datadir}/wtp_prov`p'_withBeliefs_ForestWTP.dta"
		replace with_beliefs = 1 if missing(with_beliefs)
	}

	append using "${datadir}/wtp_summary_withoutBeliefs_ForestWTP.dta"
	replace with_beliefs = 0 if missing(with_beliefs)

	forvalues p = 0/8 {
		append using "${datadir}/wtp_prov`p'_withoutBeliefs_ForestWTP.dta"
		replace with_beliefs = 0 if missing(with_beliefs)
	}

	* Provider labels
	gen provider = ""
	replace provider = "AGGREGATED"                       if provider_id == 0
	replace provider = "deepseek-chat-v3.1"               if provider_id == 1
	replace provider = "deepseek-r1"                      if provider_id == 2
	replace provider = "gemini-2.5-flash"                 if provider_id == 3
	replace provider = "gemini-2.5-flash-lite"            if provider_id == 4
	replace provider = "gpt-5-mini"                       if provider_id == 5
	replace provider = "kimi-k2"                          if provider_id == 6
	replace provider = "llama-4-scout"                    if provider_id == 7
	replace provider = "mistral-medium-3.1"               if provider_id == 8
	replace provider = "mistral-small-3.2-24b-instruct"   if provider_id == 9

	save "${datadir}/wtp_all_Study2_long.dta", replace

	* Write the table
	capture file close fh
	file open fh using "${tabdir}/tab_syn_wtp_Study2.tex", write replace

	file write fh "\begin{table}[h]" _n
	file write fh "\centering" _n
	file write fh "\caption{Synthetic willingness to pay for an additional acre of socially important forest treated (Study 2).}" _n
	file write fh "\label{tab:syn-wtp-Study2}" _n
	file write fh "\begin{threeparttable}" _n
	file write fh "\footnotesize" _n
	file write fh "\begin{tabular}{lcccc}" _n
	file write fh "\toprule" _n
	file write fh " & \multicolumn{2}{c}{Random-cost design} & \multicolumn{2}{c}{Bounded design} \\" _n
	file write fh "\cmidrule(lr){2-3} \cmidrule(lr){4-5}" _n
	file write fh "Model & w/o beliefs & w/ beliefs & w/o beliefs & w/ beliefs \\" _n
	file write fh "\midrule" _n

	* Row order: aggregated first, then 9 providers alphabetically by current id
	local provs 0 1 2 3 4 5 6 7 8 9
	local pname0  "AGGREGATED"
	local pname1  "deepseek-chat-v3.1"
	local pname2  "deepseek-r1"
	local pname3  "gemini-2.5-flash"
	local pname4  "gemini-2.5-flash-lite"
	local pname5  "gpt-5-mini"
	local pname6  "kimi-k2"
	local pname7  "llama-4-scout"
	local pname8  "mistral-medium-3.1"
	local pname9  "mistral-small-3.2-24b-instruct"

	foreach p of local provs {
		local pn "`pname`p''"
		
		* Random-cost ("repeated"), w/o beliefs
		qui sum SOCIAL_WTP if provider_id == `p' & experiment == "repeated" & with_beliefs == 0
		local wtp_rw0 = r(mean)
		qui sum SOCIAL_LB  if provider_id == `p' & experiment == "repeated" & with_beliefs == 0
		local lb_rw0  = r(mean)
		qui sum SOCIAL_UB  if provider_id == `p' & experiment == "repeated" & with_beliefs == 0
		local ub_rw0  = r(mean)
		
		* Random-cost, w/ beliefs
		qui sum SOCIAL_WTP if provider_id == `p' & experiment == "repeated" & with_beliefs == 1
		local wtp_rw1 = r(mean)
		qui sum SOCIAL_LB  if provider_id == `p' & experiment == "repeated" & with_beliefs == 1
		local lb_rw1  = r(mean)
		qui sum SOCIAL_UB  if provider_id == `p' & experiment == "repeated" & with_beliefs == 1
		local ub_rw1  = r(mean)
		
		* Bounded, w/o beliefs
		qui sum SOCIAL_WTP if provider_id == `p' & experiment == "bounded" & with_beliefs == 0
		local wtp_bw0 = r(mean)
		qui sum SOCIAL_LB  if provider_id == `p' & experiment == "bounded" & with_beliefs == 0
		local lb_bw0  = r(mean)
		qui sum SOCIAL_UB  if provider_id == `p' & experiment == "bounded" & with_beliefs == 0
		local ub_bw0  = r(mean)
		
		* Bounded, w/ beliefs
		qui sum SOCIAL_WTP if provider_id == `p' & experiment == "bounded" & with_beliefs == 1
		local wtp_bw1 = r(mean)
		qui sum SOCIAL_LB  if provider_id == `p' & experiment == "bounded" & with_beliefs == 1
		local lb_bw1  = r(mean)
		qui sum SOCIAL_UB  if provider_id == `p' & experiment == "bounded" & with_beliefs == 1
		local ub_bw1  = r(mean)
		
		* Aggregated row gets a midrule above it (already-displayed; we want it
		* formatted distinctively). Put it at the top with a rule below.
		file write fh "`pn'"
		file write fh " & " %6.1f (`wtp_rw0') " [" %6.1f (`ub_rw0') ", " %6.1f (`lb_rw0') "]"
		file write fh " & " %6.1f (`wtp_rw1') " [" %6.1f (`ub_rw1') ", " %6.1f (`lb_rw1') "]"
		file write fh " & " %6.1f (`wtp_bw0') " [" %6.1f (`ub_bw0') ", " %6.1f (`lb_bw0') "]"
		file write fh " & " %6.1f (`wtp_bw1') " [" %6.1f (`ub_bw1') ", " %6.1f (`lb_bw1') "]"
		file write fh " \\" _n
		
		if `p' == 0 {
			file write fh "\midrule" _n
		}
	}

	* Empirical benchmark row
	file write fh "\midrule" _n
	file write fh "Empirical (Giguere et al.) & \multicolumn{4}{c}{56.53 [24, 75]} \\" _n
	file write fh "\bottomrule" _n
	file write fh "\end{tabular}" _n
	file write fh "\begin{tablenotes}\footnotesize" _n
	file write fh "\item \textit{Notes:} Marginal WTP (\$/household/year) for an additional acre of socially important forest treated. " _n
	file write fh "Bracketed values are 95\% confidence intervals computed by the delta method via \texttt{nlcom}. " _n
	file write fh "``AGGREGATED'' pools synthetic responses across all nine LLMs and re-estimates the conditional logit on the pooled data. " _n
	file write fh "Empirical benchmark from \textcite{Giguere2020}." _n
	file write fh "\end{tablenotes}" _n
	file write fh "\end{threeparttable}" _n
	file write fh "\end{table}" _n
	file close fh

	di as result "Wrote tab_syn_wtp_Study2.tex"

********************************************************************************
* TABLE 4 — Synthetic-to-empirical slope ratios
* Compact cross-condition view of bid-coefficient compression.
* Reads the per-provider clogit estimates we just computed (via the matrix
* approach above), reconstructing them here from the synthetic clogit tables.
*
* Layout: rows = 10 providers + Aggregated; columns = 4 (design × condition).
* Each cell = β_COST^{syn} / β_COST^{emp}, with the SE-implied 95% CI of the
* ratio in brackets.
********************************************************************************

	* Re-run the per-provider clogits to capture β_COST and its SE,
	* keyed by (prov, dataset_version, experiment). Save to a small file
	* so this table block is self-contained.

	tempfile slope_collect
	preserve
		clear
		set obs 1
		gen byte prov_id  = .
		gen str10 design  = ""
		gen byte beliefs  = .
		gen double beta_c = .
		gen double se_c   = .
		save `slope_collect', emptyok replace
	restore

	foreach exp_val in 0 1 {
		if `exp_val' == 0 local design_lab "bounded"
		else              local design_lab "repeated"
		
		foreach dv_code in 6 9 {
			if `dv_code' == 6 local beliefs_val 1
			else              local beliefs_val 0
			
			forvalues p = 0/8 {
				use "${datadir}\wtp_e_working4loop_v2", clear
				keep if prov == `p'
				keep if dataset_version == `dv_code'
				keep if experiment == `exp_val'
				keep if attempt <= 3
				
				count
				if r(N) == 0 continue
				
				expand 2
				bysort sit_id: gen alt = _n
				gen COST_x   = num_cost * (alt == 1)
				gen ECOL_x   = ecolog   * (alt == 1)
				gen SOCIAL_x = social   * (alt == 1)
				gen BIOL_x   = biol     * (alt == 1)
				gen CHEM_x   = chem     * (alt == 1)
				gen chosen   = (syn_vote == 1 & alt == 1) | (vote == 0 & alt == 2)
				
				capture noisily clogit chosen COST_x ECOL_x SOCIAL_x BIOL_x CHEM_x, ///
					group(sit_id)
				
				if _rc == 0 {
					local bc = _b[COST_x]
					local sc = _se[COST_x]
					
					preserve
						use `slope_collect', clear
						local newobs = _N + 1
						set obs `newobs'
						replace prov_id = `p'         in `newobs'
						replace design  = "`design_lab'" in `newobs'
						replace beliefs = `beliefs_val'  in `newobs'
						replace beta_c  = `bc'         in `newobs'
						replace se_c    = `sc'         in `newobs'
						save `slope_collect', replace
					restore
				}
			}
			
			* Aggregated
			use "${datadir}\wtp_e_working4loop_v2", clear
			keep if dataset_version == `dv_code'
			keep if experiment == `exp_val'
			keep if attempt <= 3
			
			expand 2
			bysort prov sit_id: gen alt = _n
			gen COST_x   = num_cost * (alt == 1)
			gen ECOL_x   = ecolog   * (alt == 1)
			gen SOCIAL_x = social   * (alt == 1)
			gen BIOL_x   = biol     * (alt == 1)
			gen CHEM_x   = chem     * (alt == 1)
			gen chosen   = (syn_vote == 1 & alt == 1) | (vote == 0 & alt == 2)
			egen agg_sit = group(prov sit_id)
			
			clogit chosen COST_x ECOL_x SOCIAL_x BIOL_x CHEM_x, group(agg_sit)
			
			local bc = _b[COST_x]
			local sc = _se[COST_x]
			
			preserve
				use `slope_collect', clear
				local newobs = _N + 1
				set obs `newobs'
				replace prov_id = -1            in `newobs'   // -1 = aggregated
				replace design  = "`design_lab'" in `newobs'
				replace beliefs = `beliefs_val'  in `newobs'
				replace beta_c  = `bc'         in `newobs'
				replace se_c    = `sc'         in `newobs'
				save `slope_collect', replace
			restore
		}
	}

	* Merge in empirical bid coef, compute ratio + delta-method CI
	use `slope_collect', clear
	drop if missing(prov_id)

	gen experiment = design
	merge m:1 experiment using "${datadir}/empirical_bid_coefs_Study2.dta", ///
		nogen keep(match)

	gen ratio    = beta_c / emp_beta_cost
	gen ratio_se = se_c   / abs(emp_beta_cost)
	gen ratio_lb = ratio - 1.96 * ratio_se
	gen ratio_ub = ratio + 1.96 * ratio_se

	save "${datadir}/slope_ratios_Study2.dta", replace

	* Write LaTeX
	capture file close fh
	file open fh using "${tabdir}/tab_slope_ratios_Study2.tex", write replace

	file write fh "\begin{table}[h]" _n
	file write fh "\centering" _n
	file write fh "\caption{Synthetic-to-empirical bid-coefficient ratios, Study 2.}" _n
	file write fh "\label{tab:slope-ratios-Study2}" _n
	file write fh "\begin{threeparttable}" _n
	file write fh "\footnotesize" _n
	file write fh "\begin{tabular}{lcccc}" _n
	file write fh "\toprule" _n
	file write fh " & \multicolumn{2}{c}{Random-cost} & \multicolumn{2}{c}{Bounded} \\" _n
	file write fh "\cmidrule(lr){2-3} \cmidrule(lr){4-5}" _n
	file write fh "Model & w/o beliefs & w/ beliefs & w/o beliefs & w/ beliefs \\" _n
	file write fh "\midrule" _n

	* Row order: aggregated, then providers 1-9
	local row_prov_ids "-1 0 1 2 3 4 5 6 7 8"
	local pname_1   "AGGREGATED"
	local pname0    "deepseek-chat-v3.1"
	local pname1    "deepseek-r1"
	local pname2    "gemini-2.5-flash"
	local pname3    "gemini-2.5-flash-lite"
	local pname4    "gpt-5-mini"
	local pname5    "kimi-k2"
	local pname6    "llama-4-scout"
	local pname7    "mistral-medium-3.1"
	local pname8    "mistral-small-3.2-24b-instruct"

	foreach p of local row_prov_ids {
		if `p' == -1 local pn "AGGREGATED"
		else         local pn "`pname`p''"
		
		qui sum ratio if prov_id == `p' & design == "repeated" & beliefs == 0
		local r_rw0 = r(mean)
		qui sum ratio if prov_id == `p' & design == "repeated" & beliefs == 1
		local r_rw1 = r(mean)
		qui sum ratio if prov_id == `p' & design == "bounded"  & beliefs == 0
		local r_bw0 = r(mean)
		qui sum ratio if prov_id == `p' & design == "bounded"  & beliefs == 1
		local r_bw1 = r(mean)
		
		file write fh "`pn'"
		file write fh " & " %6.3f (`r_rw0')
		file write fh " & " %6.3f (`r_rw1')
		file write fh " & " %6.3f (`r_bw0')
		file write fh " & " %6.3f (`r_bw1')
		file write fh " \\" _n
		
		if `p' == -1 file write fh "\midrule" _n
	}

	file write fh "\bottomrule" _n
	file write fh "\end{tabular}" _n
	file write fh "\begin{tablenotes}\footnotesize" _n
	file write fh "\item \textit{Notes:} Ratio of synthetic to empirical bid coefficients from conditional logit estimates. " _n
	file write fh "Values below 1 indicate that synthetic responses are less sensitive to cost than empirical responses (``slope compression''). " _n
	file write fh "A value of 0 indicates no sensitivity to cost; values above 1 indicate over-sensitivity. " _n
	file write fh "The empirical bid coefficients used as denominators are taken from the unadjusted conditional logit specifications reported in Table~\ref{tab:repl-clogit-Study2}." _n
	file write fh "\end{tablenotes}" _n
	file write fh "\end{threeparttable}" _n
	file write fh "\end{table}" _n
	file close fh

	di as result "Wrote tab_slope_ratios_Study2.tex"

	di as result "All four tables produced."
	
