* Project:		LLM for Contingent Valuation
* Author:		Trevor Woolley)
* Date created:	March 8, 2026
* Purpose:		Import raw LLM result data (made by Kasra) and produce figures
*******************************************************************************
global datadir "D:\Projects\LLM_CV\data"
global figdir "D:\Projects\LLM_CV\figures"
global tabdir "D:\Projects\LLM_CV\figures\tables"
global rawdir "D:\Projects\LLM_CV\data\raw\Experiment2"

graph set window fontface "Times New Roman"

sysdir set PERSONAL "C:\Users\trevor_woolley\ado\personal\"
sysdir set PLUS "C:\Users\trevor_woolley\ado\plus\"

ssc install wtpcikr
ssc install grc1leg2
*******************************************************************************
							* Pull in data
*******************************************************************************
	use "${rawdir}\wtp_e_cleaned-v118", clear

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

	keep if prov==5
	
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

	keep if dataset_version ==6


	* ── Expand each observation to 2 rows (For=1, Against=0) ─────────────────────
	expand 2

	bysort sit_id: gen alt = _n   // alt=1 (For), alt=2 (Against)
	

	* ── For the "Against" alternative, all attributes = 0 (status quo) ────────────
	gen COST_x   = num_cost   * (alt == 1)
	gen ECOL_x   = ecolog   * (alt == 1)
	gen SOCIAL_x = social * (alt == 1)
	gen BIOL_x   = biol   * (alt == 1)
	gen CHEM_x   = chem   * (alt == 1)

	* ── Define the chosen indicator ───────────────────────────────────────────────
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

	* ── Column 1: Bounded, 1st situation ─────────────────────────────────────────
	clogit chosen COST_x ECOL_ana SOCIAL_ana BIOL_x CHEM_x ///
		if attempt<=3 & experiment ==0, ///
		group(sit_id)
	est store boundcond1

	
	* ── Column 1: Repeated, 1st situation ─────────────────────────────────────────
	clogit chosen COST_x ECOL_ana SOCIAL_ana BIOL_x CHEM_x ///
		if attempt<=2 & experiment ==1, ///
		group(sit_id)
	est store repcond1

	
	* WTP estimates from conditional logit with stated ANA:
	estimates restore boundcond1
	nlcom (-_b[ECOL_ana] / _b[COST_x])    // WTP for ecological acreage
	nlcom (-_b[SOCIAL_ana] / _b[COST_x])  // WTP for social acreage
	
	
	estimates restore repcond1
	nlcom (-_b[ECOL_ana] / _b[COST_x])    // WTP for ecological acreage
	nlcom (-_b[SOCIAL_ana] / _b[COST_x])  // WTP for social acreage
	
	
	
	


/*	
	* ── Column 3: Bounded, 1st and 2nd situations ────────────────────────────────
	clogit chosen COST_x ECOL_ana SOCIAL_ana BIOL_x CHEM_x ///
		if attempt<=2, ///
		group(sit_id)
	est store boundcond2

	* ── Column 3: Bounded, 1st and 2nd situations ────────────────────────────────
	clogit chosen COST_x ECOL_ana SOCIAL_ana BIOL_x CHEM_x, ///
		group(sit_id)
	estat ic
	est store boundcond3


	****** Replicate TABLE 5 *********

	//destring id, generate(num_id)

	//mixlogit chosen ///
		//if attempt<=2, ///
		//group(sit_id) id(num_id) ///
		//rand(COST_x ECOL_ana SOCIAL_ana BIOL_x CHEM_x) ///
		//nrep(100) 
	//est store boundrand2

	//mixlogit chosen, ///
		//group(sit_id) id(num_id) ///
		//rand(COST_x ECOL_ana SOCIAL_ana BIOL_x CHEM_x) ///
		//nrep(1000) 
	//est store boundrand3		






	****** Replicate TABLE 6 *********


	* ── WTP = -beta_ECOL / beta_COST ─────────────────────────────────────────────

	
	
/*
	estimates restore boundcond2
	nlcom (-_b[ECOL_ana] / _b[COST_x])    // WTP for ecological acreage
	nlcom (-_b[SOCIAL_ana] / _b[COST_x])  

	estimates restore boundcond3
	nlcom (-_b[ECOL_ana] / _b[COST_x])    // WTP for ecological acreage
	nlcom (-_b[SOCIAL_ana] / _b[COST_x])  

*/



