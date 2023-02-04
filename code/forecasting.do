clear
set more off
set scheme s1color

cd ${synthesis_root}

*Saving CPI Data
import excel "data\raw\CPIAUCSL.xls", sheet("FRED Graph") cellrange(A11:B35) firstrow clear

gen year = year(observation_date)

sum CPIAUCSL if year == 2022
local cpi22 = r(mean)

gen deflator = `cpi22'/CPIAUCSL

keep year deflator

tempfile infl
save `infl', replace

*Importing genes data
import excel "data/raw/Gene Synthesis Data.xlsx", sheet("By Firm Price") firstrow case(lower) clear

*Merging in inflation data
merge m:1 year using `infl'

*Generating Inflation Adjust Cost
gen costperbase_real = costperbase*deflator

*Dropping firms with no data and empty rows
drop if mi(firm) | mi(year)

*Keeping only full gene synthesis data
keep if synthesistype=="C"
bysort firm: gen numyears = _N
keep if numyears > 1

label var costperbase "Cost per Base Nominal $"
label var costperbase_real "Cost per Base 2022 $"


*Gen log cost per base vars
foreach var of varlist costperbase costperbase_real{
	gen ln_`var' = ln(`var')
	gen log10_`var' = log10(`var')
	gen log2_`var' = ln(`var')/ln(2)
}


**Collapsing firm level data
gen carlson = firm == "Carlson Average"

*Generating relative time var
gen rel_year = year-1999 if carlson ==1
replace rel_year = year-2002 if carlson ==0

collapse costperbase* ln_costperbase* log10_costperbase* log2_costperbase*, by(carlson year rel_year)


label var costperbase "Cost per Base Nominal $"
label var log10_costperbase "Log_10(costperbase) Nominal $"
label var costperbase_real "Cost per Base 2022 $"
label var log10_costperbase_real "Log_10(costperbase) 2022 $"

*Firm data
*Real

*Breakpoint test to confirm piecewise point
preserve 

keep if carlson ==0
tsset year

reg log10_costperbase year
estat sbsingle 

restore

twoway (scatter costperbase_real year if carlson ==0, recast(connected) msymbol(Oh)) (lfit costperbase_real year if carlson==0 & year < 2011) (lfit costperbase_real year if carlson==0 & year >= 2011, lcolor(orange_red)), ytitle(Cost per Base 2022 $, size(medsmall)) legend(off) ylabel(, labsize(medsmall))
graph export results/cost_firms_fitted.png, replace

twoway (scatter log10_costperbase_real year if carlson ==0, recast(connected) msymbol(Oh)) (lfit log10_costperbase_real year if carlson==0 & year < 2011) (lfit log10_costperbase_real year if carlson==0 & year >= 2011, lcolor(orange_red)), ylabel(1 "10" .5 "3.2" 0 "1" -.5 "0.32" -1 "0.1", labsize(medsmall)) ytitle(Cost per Base 2022 $ (log scale)) legend(off) name(g1, replace) title(Firm Prices)
graph export results/log10_cost_firms_fitted.png, replace
*Carlson Data

*Real
twoway (scatter costperbase_real year if carlson ==1, recast(connected) msymbol(Oh)) (lfit costperbase_real year if carlson==1), ytitle(Cost per Base 2022 $, size(medsmall)) legend(off) ylabel(, labsize(medsmall))
graph export results/cost_carlson_fitted.png, replace


twoway (scatter log10_costperbase_real year if carlson ==1, recast(connected) msymbol(Oh)) (lfit log10_costperbase_real year if carlson==1), ylabel(2 "100" 1.7 "50" 1 "10"  0 "1" -1 "0.1" -2 "0.001", labsize(medsmall)) ytitle(Cost per Base 2022 $ (log scale)) legend(off) name(g2, replace) title(Carlson Prices)
graph export results/log10_cost_carlson_fitted.png, replace

graph combine g1 g2
graph export results/log10_cost_carlson_firm_fitted.png, replace

*Predictions

matrix prices = J(5,4,.)

mat prices[1,1] = 2017
mat prices[2,1] = 2022
mat prices[3,1] = 2027
mat prices[4,1] = 2032
mat prices[5,1] = 2037

************Carlson****************

reg log10_costperbase_real rel_year if carlson==1, robust
local beta = e(b)[1,1]
local beta5 = r(table)[5,1]
local beta95 = r(table)[6,1]

*2017 Price
sum log10_costperbase_real if year ==2017 & carlson ==1
local 17_price = r(sum)
local 17_price_lev = 10^`17_price'

mat prices[1,2] = `17_price_lev'

*5 years prediction-2022
local pred = 10^(`17_price' + 5*`beta')
local ci5 = 10^(`17_price' + 5*`beta5')
local ci95 = 10^(`17_price' + 5*`beta95')
di `pred'
di `ci5'
di `ci95'

mat prices[2,2] = `pred'

*10 years prediction-2027
local pred = 10^(`17_price' + 10*`beta')
local ci5 = 10^(`17_price' + 10*`beta5')
local ci95 = 10^(`17_price' + 10*`beta95')
di `pred'
di `ci5'
di `ci95'

mat prices[3,2] = `pred'


*15 years-2032
local pred = 10^(`17_price' + 15*`beta')
local ci5 = 10^(`17_price' +15*`beta5')
local ci95 =10^(`17_price' + 15*`beta95')
di `pred'
di `ci5'
di `ci95'

mat prices[4,2] = `pred'

*20 years-2037
local pred = 10^(`17_price' + 20*`beta')
local ci5 = 10^(`17_price' +20*`beta5')
local ci95 = 10^(`17_price' + 20`beta95')
di `pred'
di `ci5'
di `ci95'

mat prices[5,2] = `pred'

***************Firm second trend****************
reg log10_costperbase_real rel_year if carlson==0 & year >= 2011

*Coeffs and CI
local beta = e(b)[1,1]
local beta5 = r(table)[5,1]
local beta95 = r(table)[6,1]

*2022 Price
sum log10_costperbase_real if year ==2022 & carlson ==0
local 22_price = r(sum)
local 22_price_lev = 10^`22_price'
di `22_price_lev'

mat prices[2,3] = `22_price_lev'

*5 years prediction-2027
local pred = 10^(`22_price' + 5*`beta')
local ci5 = 10^(`22_price' + 5*`beta5')
local ci95 = 10^(`22_price' + 5*`beta95')
di `pred'
di `ci5'
di `ci95'

mat prices[3,3] = `pred'


*10 years-2032
local pred = 10^(`22_price' + 10*`beta')
local ci5 = 10^(`22_price' + 10*`beta5')
local ci95 = 10^(`22_price' + 10*`beta95')
di `pred'
di `ci5'
di `ci95'

mat prices[4,3] = `pred'

*15 years-2037
local pred = 10^(`22_price' + 15*`beta')
local ci5 = 10^(`22_price' + 15*`beta5')
local ci95 = 10^(`22_price' + 15*`beta95')
di `pred'
di `ci5'
di `ci95'

mat prices[5,3] = `pred'

***************Firm first trend****************
reg log10_costperbase_real rel_year if carlson==0 & year < 2011

*Coeffs and CI
local beta = e(b)[1,1]
local beta5 = r(table)[5,1]
local beta95 = r(table)[6,1]

*2022 Price
sum log10_costperbase_real if year ==2022 & carlson ==0
local 22_price = r(sum)
local 22_price_lev = 10^`22_price'
di `22_price_lev'

mat prices[2,4] = `22_price_lev'

*5 years prediction-2027
local pred = 10^(`22_price' + 5*`beta')
local ci5 = 10^(`22_price' + 5*`beta5')
local ci95 = 10^(`22_price' + 5*`beta95')
di `pred'
di `ci5'
di `ci95'

mat prices[3,4] = `pred'


*10 years-2032
local pred = 10^(`22_price' + 10*`beta')
local ci5 = 10^(`22_price' + 10*`beta5')
local ci95 = 10^(`22_price' + 10*`beta95')
di `pred'
di `ci5'
di `ci95'

mat prices[4,4] = `pred'

*15 years-2037
local pred = 10^(`22_price' + 15*`beta')
local ci5 = 10^(`22_price' + 15*`beta5')
local ci95 = 10^(`22_price' + 15*`beta95')
di `pred'
di `ci5'
di `ci95'

mat prices[5,4] = `pred'

mat list prices

putexcel set results/price_forecast_table.xlsx, modify

putexcel A2 = matrix(prices)