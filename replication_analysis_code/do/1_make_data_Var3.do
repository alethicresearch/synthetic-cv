* Project:		LLM for Contingent Valuation
* Author:		Alina Khindanova (edited by Trevor Woolley)
* Date created:	Nov 21, 2025
* Purpose:		Import raw LLM result data (made by Sankalpa) and produce figures
*******************************************************************************
global datadir "D:\Projects\LLM_CV\data"
global figdir "D:\Projects\LLM_CV\figures"
*******************************************************************************
						* IMPORTING DATASET
*******************************************************************************
	* Drop columns 5 and 6 from raw data
	// columns 5 and 6 from initial data (the ones with the promt) were too heavy, so in this part of the code I am just dropping these two columns
// 	import delimited using ${datadir}/data_first.csv, bindquotes(strict) maxquotedrows(unlimited) colrange(1:4)
// 	save part1.dta
//
// 	clear
// 	import delimited using ${datadir}/data_first.csv, bindquotes(strict) maxquotedrows(unlimited) colrange(7:)
// 	save part2.dta
//
// 	* Merge data
// 	use part1.dta, replace
// 	merge 1:1 _n using part2.dta
*******************************************************************************	
	use ${datadir}/Indiv_beliefs_data.dta, clear
	// Data created by Alina

	* Create unique simulated respondent-variant id
	// Should be unique for each caseid (simulated respondent), variant,
	// For collapsing provider (LLM model) and sub-variant variation later 
	egen person_beliefQ_id = group(caseid belief_question)

	* Create unique provider id	
	egen provider_id = group(provider)
*******************************************************************************

	* Clean variables	
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
*******************************************************************************
	egen beliefQ_response_id = group(belief_question)
	
	* Making belif Q variable that is unique per question (regardless of response)
	gen beliefQ_id = .
	replace beliefQ_id = 1 if strpos(belief_question, "* Question: Assuming global warming is happening, do you think it is")
	replace beliefQ_id = 2 if strpos(belief_question, "* Question: Do you think global warming should be a low, medium, high, or very high priority for the president and Congress?")
	replace beliefQ_id = 3 if strpos(belief_question, "* Question: Do you think that developing sources of clean energy should be a low, medium, high, or very high priority for the president and Congress?")
	replace beliefQ_id = 4 if strpos(belief_question, "* Question: How much do you support or oppose the following policy? Fund more research into renewable energy sources, such as solar and wind power")
	replace beliefQ_id = 5 if strpos(belief_question, "* Question: How much do you think global warming will harm future generations of people?")
	replace beliefQ_id = 6 if strpos(belief_question, "* Question: How much do you think global warming will harm people in developing countries?")
	replace beliefQ_id = 7 if strpos(belief_question, "* Question: How much do you think global warming will harm people in the United States?")
	replace beliefQ_id = 8 if strpos(belief_question, "* Question: How much do you think global warming will harm plant and animal species?")
	replace beliefQ_id = 9 if strpos(belief_question, "* Question: How much do you think global warming will harm you personally?")
	replace beliefQ_id = 10 if strpos(belief_question, "* Question: How often do you discuss global warming with your family and friends?")
	replace beliefQ_id = 11 if strpos(belief_question, "* Question: How worried are you about global warming?")
	replace beliefQ_id = 12 if strpos(belief_question, "* Question: Recently, you may have noticed that global warming has been getting some attention in the news.")
	replace beliefQ_id = 13 if strpos(belief_question, "* Question: Which comes closest to your own view?")

**************************** Save Data ****************************************
	save ${datadir}/working_data_var3.dta, replace
