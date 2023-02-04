clear
set more off
set scheme s1color

cd ${synthesis_root}

*Saving CPI Data
import excel "data/raw/CPIAUCSL.xls", sheet("FRED Graph") cellrange(A11:B35) firstrow clear

gen year = year(observation_date)

sum CPIAUCSL if year == 2022
local cpi22 = r(mean)

gen deflator = `cpi22'/CPIAUCSL

keep year deflator

tempfile infl
save `infl', replace


import excel "data/raw/Gene Synthesis Data.xlsx", sheet("By Firm Price") firstrow case(lower) clear

*Merging in inflation data
merge m:1 year using `infl'

*Generating Inflation Adjust Cost
gen costperbase_real = costperbase*deflator

*Dropping firms with no data and empty rows
drop if mi(firm) | mi(year)

keep if synthesistype=="C"

bysort firm: gen numyears = _N
keep if numyears > 1

*Gen log cost per base vars
foreach var of varlist costperbase costperbase_real{
	gen ln_`var' = ln(`var')
	gen log10_`var' = log10(`var')
	gen log2_`var' = ln(`var')/ln(2)
}

label var costperbase "Cost per Base Nominal $"
label var costperbase_real "Cost per Base 2022 $"

tempfile d1
save `d1'
/*
replace firm = subinstr(firm, " ", "", .)

keep year firm costperbase

reshape wide costperbase , i(year) j(firm) string
*/

*All including Carlson curve
use `d1', clear

encode firm, gen(firmcode)
xtset firmcode year

xtline costperbase_real, overlay recast(connected) plot1opts(msymbol(dh)) plot2opts(msymbol(dh)) plot3opts(msymbol(dh)) plot4opts(msymbol(dh)) plot5opts(msymbol(dh)) plot6opts(msymbol(dh)) plot7opts(msymbol(dh)) ylabel(, labsize(medsmall)) ytitle(, size(medsmall))


graph export results/level_cost_all.png, replace

xtline log10_costperbase_real, overlay recast(connected) plot1opts(msymbol(dh)) plot2opts(msymbol(dh)) plot3opts(msymbol(dh)) plot4opts(msymbol(dh)) plot5opts(msymbol(dh)) plot6opts(msymbol(dh)) plot7opts(msymbol(dh))  ylabel(2 "100" 1 "10" 0 "1" -1 "0.1" -2 "0.001", labsize(medsmall)) ytitle("Cost per Base 2022 $ (log scale)", size(medsmall))

graph export results/log10_cost_all.png, replace

****Only firm costs 
drop if firm == "Carlson Average"

xtline costperbase_real, overlay recast(connected) plot1opts(msymbol(dh)) plot2opts(msymbol(dh)) plot3opts(msymbol(dh)) plot4opts(msymbol(dh)) plot5opts(msymbol(dh)) plot6opts(msymbol(dh)) ylabel(, labsize(medsmall)) ytitle(, size(medsmall))

graph export results/level_cost_firms.png, replace


xtline log10_costperbase_real, overlay recast(connected) plot1opts(msymbol(dh)) plot2opts(msymbol(dh)) plot3opts(msymbol(dh)) plot4opts(msymbol(dh)) plot5opts(msymbol(dh)) plot6opts(msymbol(dh)) ylabel(1 "10" 0.5 "3.2" 0 "1" -0.5 "0.32" -1 "0.1", labsize(medsmall)) ytitle("Cost per Base 2022 $ (log scale)", size(medsmall))
graph export results/log10_cost_firms.png, replace


use `d1', clear
encode firm, gen(firmcode)
xtset firmcode year

gen carlson = firm == "Carlson Average"

**Average vs Carlson average

collapse costperbase* ln_costperbase* log10_costperbase* log2_costperbase*, by(carlson year)

*Labelling

label var costperbase "Cost per Base Nominal $"
label var costperbase_real "Cost per Base 2022 $"
label var log10_costperbase "Log_10(costperbase) Nominal $"
label var log10_costperbase_real "Log_10(costperbase) 2022 $"
label var ln_costperbase "Ln(costperbase) Nominal $"
label var ln_costperbase_real "Ln(costperbase) 2022 $"
label var log2_costperbase "Log_2(costperbase) Nominal $"
label var log2_costperbase_real "Log_2(costperbase) 2022 $"

label def carlson 0 "Firm Prices" 1 "Carlson Curve"
label val carlson carlson

xtset carlson year

xtline costperbase_real, overlay recast(connected) plot1opts(msymbol(dh)) plot2opts(msymbol(dh)) ylabel(, labsize(medsmall)) ytitle(, size(medsmall))
graph export results/cost_firmvscarlson.png, replace


xtline log10_costperbase_real, overlay recast(connected) plot1opts(msymbol(dh)) plot2opts(msymbol(dh)) ylabel(2 "100" 1 "10" 0 "1" -1 "0.1" -2 "0.001", labsize(medsmall)) ytitle("Cost per Base 2022 $ (log scale)", size(medsmall))
graph export results/log10_cost_firmvscarlson.png, replace