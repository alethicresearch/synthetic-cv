	use "${rawdir}\wtp_e_cleaned-v118", clear

	* work only with version v6.3-do-real-multi
	label list dataset_version		
// 	keep if dataset_version==9
	keep if dataset_version ==3
// 	keep if  dataset_version ==8

	* work with gpt-5-mini
	tab prov
	label list prov
	keep if prov==4

	* only first run, bounded experiment
	tab run
	label list experiment
	keep if experiment==0

	tab  ctx1_5_q28_cost_cat if attempt ==1
	tab  ctx1_5_q28_cost_cat if attempt ==2
	tab  ctx1_5_q28_cost_cat if attempt ==3

	// want to make vote variable binary
	label list syn_vote
	tab syn_vote
	replace syn_vote=0 if syn_vote==1
	replace syn_vote=1 if syn_vote==2
	tab syn_vote

	label define syn_vote ///
		1 "Vote for" ///
		0 "Vote against", modify

		
		
		
	****** Replicate TABLE 1 *********

	///bounded sample
	// 1st round
	tab ctx1_5_q28_cost_cat if experiment==0 & syn_vote==1 & attempt==1 
	tab ctx1_5_q28_cost_cat if experiment==0 & attempt==1
	// 2nd round
	tab ctx1_5_q28_cost_cat if experiment==0 & syn_vote==1 & attempt==2 //1st column
	tab ctx1_5_q28_cost_cat if experiment==0 & attempt==2 //2nd column
	// 3rd round
	tab ctx1_5_q28_cost_cat if experiment==0 & syn_vote==1 & attempt==3 //1st column
	tab ctx1_5_q28_cost_cat if experiment==0 & attempt==3 //2nd column



	****** Replicate TABLE 4 *********

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


	* ── Create a unique attempt identifier ──────────────────────────────────────
	// "attempt" is different each time person is presented with different cost
	// So there are three attempts per bounded respondent
	egen sit_id = group(id attempt)   // unique per person-attempt

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

	capture drop SOCIAL_ana
	gen SOCIAL_ana = SOCIAL_x
	replace SOCIAL_ana = 0 if qsa_syn_infl_social ==9 | qsa_syn_infl_social==10


	* ── Column 1: Bounded, 1st situation ─────────────────────────────────────────
	clogit chosen COST_x ECOL_ana SOCIAL_ana BIOL_x CHEM_x ///
		if attempt==1, ///
		group(sit_id)
	est store boundcond1

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

	* WTP estimates from conditional logit with stated ANA:
	estimates restore boundcond1
	nlcom (-_b[ECOL_ana] / _b[COST_x])    // WTP for ecological acreage
	nlcom (-_b[SOCIAL_ana] / _b[COST_x])  // WTP for social acreage
	
/*
	estimates restore boundcond2
	nlcom (-_b[ECOL_ana] / _b[COST_x])    // WTP for ecological acreage
	nlcom (-_b[SOCIAL_ana] / _b[COST_x])  

	estimates restore boundcond3
	nlcom (-_b[ECOL_ana] / _b[COST_x])    // WTP for ecological acreage
	nlcom (-_b[SOCIAL_ana] / _b[COST_x])  

*/



