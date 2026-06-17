	ssc install mixlogit
	
	* import dataset
	import delimited "${rawdir}\original_data.csv", clear


	****** Replicate TABLE 1 *********

	* add new rows representing the second round choices (their implicit answer to both)
	gen expand_n = 1
	replace expand_n = 3 if experiment==1
	expand expand_n
	drop expand_n
	bys id experiment: gen numround = _n

	replace cost=250 if numround==2 & vote==1
	replace cost=25 if numround==2 & vote==0
	replace cost=25 if numround==3 & vote==1 //implicit
	replace cost=250 if numround==3 & vote==0 //implicit
	
	replace vote=0 if numround==2 & cost==250 & numvotes==2
	replace vote=1 if numround==2 & cost==25 & numvotes==2
	

	///bounded sample
	// 1st round
	tab cost if experiment==1 & vote==1 & numround==1 //1st column
	tab cost if experiment==1 & numround==1 //2nd column
	// 2nd round
	tab cost if experiment==1 & vote==1 & numround==2 //1st column
	tab cost if experiment==1 & numround==2 //2nd column


	/// repeated sample
	//First Round
	tab cost if experiment==6 & vote==1 //1st column
	tab cost if experiment==6 //2nd column

	* Make data for "Propensity to vote Y over bidding_amount" figures
	preserve
		* Change experiment (bounded v. random) to match the values we use in our synthetic replication
		replace experiment = 0 if experiment ==1
		replace experiment = 1 if experiment ==6
		collapse (mean) actual_vote=vote, by(cost experiment)
		save  ${datadir}/actual_vote_ForestWTP.dta, replace
	restore





	****** Replicate TABLE 2 *********

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

	* ── Define the chosen indicator ───────────────────────────────────────────────
	gen chosen = (vote == 1 & alt == 1) | (vote == 0 & alt == 2)




	* ── Table 2: Conditional logit, bounded sample, 1st situation only ───────────
	clogit chosen COST_x ECOL_x SOCIAL_x BIOL_x CHEM_x ///
		if experiment == 1 & numround == 1, ///
		group(sit_id) vce(cluster id)
		
		
	* ── Repeated sample, 1st situation only ───────────
	clogit chosen COST_x ECOL_x SOCIAL_x BIOL_x CHEM_x ///
		if experiment == 6 & numround == 1, ///
		group(sit_id) vce(cluster id)
		
	* ── 1st and 2nd situations, bounded sample ────────────────────────────────────
	clogit chosen COST_x ECOL_x SOCIAL_x BIOL_x CHEM_x ///
		if experiment == 1 & numround <= 2, ///
		group(sit_id) vce (cluster id)

	//* ── All 3 situations ────────────────────────────────────────────────────────
	//clogit chosen COST_x ECOL_x SOCIAL_x BIOL_x CHEM_x ///
	//    if experiment == 1, ///
	//    group(sit_id) vce(cluster person_id)


	//logit vote cost ecolog social biol chem if experiment==1 & numround==1, noconstant //1st column
	//logit vote cost ecolog social biol chem if experiment==6, noconstant //2nd column
	//logit vote cost ecolog social biol chem if experiment==1, noconstant //3rd column






	/*

	****** Replicate TABLE 3 *********

	//mixlogit chosen ///
	 //   if experiment==1 & numround==1, ///
		//group(sit_id) id(id) ///
		//rand(COST_x ECOL_x SOCIAL_x BIOL_x CHEM_x) ///
		//nrep(200) // not exactly the same results because the model draws from random

	mixlogit chosen ///
		if experiment==1 & numround<=2, ///
		group(sit_id) id(id) ///
		rand(COST_x ECOL_x SOCIAL_x BIOL_x CHEM_x) ///
		nrep(2000) // not exactly the same results because the model draws from random

	//mixlogit chosen ///
		//if numround==1, ///
		//group(sit_id) id(id) ///
		//rand(COST_x ECOL_x SOCIAL_x BIOL_x CHEM_x) ///
		//nrep(100)
		
		

		
		
		
		
		
	*/	
		
		
	****** Replicate TABLE 4 *********

	capture drop ECOL_ana
	gen ECOL_ana   = ECOL_x 
	replace ECOL_ana = 0 if infl_ecolog ==1 | infl_ecolog==2

	capture drop SOCIAL_ana
	gen SOCIAL_ana = SOCIAL_x
	replace SOCIAL_ana = 0 if infl_social ==1 | infl_social==2


	* ── Column 1: Bounded, 1st situation ─────────────────────────────────────────
	clogit chosen COST_x ECOL_ana SOCIAL_ana BIOL_x CHEM_x ///
		if experiment==1 & numround==1, ///
		group(sit_id)
	estat ic
	est store boundcond1


	* ── Column 2: Repeated, 1st situation ────────────────────────────────────────
	clogit chosen COST_x ECOL_ana SOCIAL_ana BIOL_x CHEM_x ///
		if experiment==6 & numround==1, ///
		group(sit_id)
	estat ic
	est store repcond1

	* ── Column 3: Bounded, 1st and 2nd situations ────────────────────────────────
	clogit chosen COST_x ECOL_ana SOCIAL_ana BIOL_x CHEM_x ///
		if experiment==1 & numround<=2, ///
		group(sit_id)
	estat ic
	est store boundcond2


	* ── Column 3: Bounded, 1st and 2nd situations ────────────────────────────────
	clogit chosen COST_x ECOL_ana SOCIAL_ana BIOL_x CHEM_x ///
		if experiment==6 & numround<=2, ///
		group(sit_id)
	estat ic
	est store repcond2



/*
	****** Replicate TABLE 5 *********

	mixlogit chosen ///
		if experiment==1 & numround<=2, ///
		group(sit_id) id(id) ///
		rand(COST_x ECOL_ana SOCIAL_ana BIOL_x CHEM_x) ///
		nrep(2000) 
	est store boundrand2	
		
		*/
		
		
		
		
		
	****** Replicate TABLE 6 *********


	* ── WTP = -beta_ECOL / beta_COST ─────────────────────────────────────────────

	* WTP estimates from conditional logit with stated ANA:
	estimates restore boundcond1
	nlcom (-_b[ECOL_ana] / _b[COST_x])    // WTP for ecological acreage
	nlcom (-_b[SOCIAL_ana] / _b[COST_x])  // WTP for social acreage

	estimates restore repcond1
	nlcom (-_b[ECOL_ana] / _b[COST_x])    // WTP for ecological acreage
	nlcom (-_b[SOCIAL_ana] / _b[COST_x])  // WTP for social acreage

	estimates restore boundcond2
	nlcom (-_b[ECOL_ana] / _b[COST_x])    // WTP for ecological acreage
	nlcom (-_b[SOCIAL_ana] / _b[COST_x])  // WTP for social acreage

	estimates restore repcond2
	nlcom (-_b[ECOL_ana] / _b[COST_x])    // WTP for ecological acreage
	nlcom (-_b[SOCIAL_ana] / _b[COST_x])  // WTP for social acreage

	* WTP estimates from RPL with stated ANA:
	estimates restore boundrand2   // after running stated ANA model
	nlcom (wtp_ecol:   -_b[ECOL_ana]   / _b[COST_x]) ///
		  (wtp_social: -_b[SOCIAL_ana] / _b[COST_x])






















