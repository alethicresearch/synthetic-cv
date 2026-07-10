* Project:		LLM for Contingent Valuation
*******************************************************************************

global datadir "/Users/alinakhind/Downloads/"

*******************************************************************************
							* Pull in data
*******************************************************************************
	use ${datadir}/working_data.dta, clear
	
*******************************************************************************
					* Support/Oppose Robustness Check
*******************************************************************************
	
	* remove demographics only condition
	keep if variant == "beliefs + demographics"
	
	* create binary variable for answer choices
	gen support = 0
	replace support = 1 if qsa == "Support" | qsa == "Somewhat Support"
	
	* create numerical binary variable for subvariant
	gen order = 0
	replace order = 1 if sub_variant == "support_oppose"
	

	foreach m in openrouter.openai/gpt-5-mini openrouter.google/gemini-2.5-flash openrouter.google/gemini-2.5-flash-lite openrouter.deepseek/deepseek-chat-v3.1 openrouter.deepseek/deepseek-r1 openrouter.mistralai/mistral-medium-3.1 openrouter.mistralai/mistral-small-3.2-24b-instruct openrouter.moonshotai/kimi-k2 openrouter.meta-llama/llama-4-scout {
		
		quietly sum support if provider == "`m'" & order==1
		local support_first = r(mean)
		
		quietly sum support if provider == "`m'" & order==0
		local oppose_first = r(mean)
		
		local diff_pp = (`support_first' - `oppose_first') * 100
		
		* significance test with cluster-robust SE at respondent level
		reg support order if provider == "`m'", vce(cluster caseid)
		
		display "`m': support-first=`support_first' oppose-first=`oppose_first' diff=`diff_pp'"
	}
	
	* mean across models
	sum support if order==1
	sum support if order==0
