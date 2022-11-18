clear
set more off
set scheme s1color

cd ${synthesis_root}

*Importing data
import delimited using data/raw/CPIAUCSL.csv, clear

destring date, replace

gen year = substr(date, 1,4)
destring year, replace

drop date

gen deflator = 100/cpiaucsl_nbd19990101
drop cpiaucsl_nbd19990101

tempfile d1
save `d1', replace

import excel "data/raw/Gene Synthesis Data.xlsx", sheet("By Firm Price") firstrow case(lower) clear

*Add Results Folder
cap mkdir results

*Dropping firms with no data and empty rows
drop if mi(firm) | mi(year)

*Merging in deflator
merge m:1 year using `d1', nogen keep(1 3) 

*Keeping Only Clonal Data
keep if synthesistype=="C"

*Deflated costperbase
gen costperbase_deflated = costperbase*deflator

label var costperbase "Cost per Base ($)"
label var costperbase_deflated "Cost per Base ($)"


gen ln_costperbase = ln(costperbase)
label var ln_costperbase "Ln(costperbase)"

gen ln_costperbase_deflated = ln(costperbase_deflated)
label var ln_costperbase_deflated "Ln(costperbase)"

gen log10_costperbase = log10(costperbase)
label var log10_costperbase "Log_10(costperbase)"

gen log10_costperbase_deflated = log10(costperbase_deflated)
label var log10_costperbase_deflated "Log_10(costperbase)"

gen log2_costperbase = ln(costperbase)/ln(2)
label var log2_costperbase "Log_2(costperbase)"

gen log2_costperbase_deflated = ln(costperbase_deflated)/ln(2)
label var log2_costperbase_deflated "Log_2(costperbase)"

save data/derived/cost_clonal_clean, replace
/*
replace firm = subinstr(firm, " ", "", .)

keep year firm costperbase

reshape wide costperbase , i(year) j(firm) string
*/

*All including Carlson curve
use data/derived/cost_clonal_clean, clear

encode firm, gen(firmcode)
xtset firmcode year


xtline costperbase, overlay recast(connected) plot1opts(msymbol(dh)) plot2opts(msymbol(dh)) plot3opts(msymbol(dh)) plot4opts(msymbol(dh)) plot5opts(msymbol(dh)) plot6opts(msymbol(dh)) plot7opts(msymbol(dh)) plot8opts(msymbol(dh))

graph export results/level_cost_all.png, replace

xtline ln_costperbase, overlay recast(connected) plot1opts(msymbol(dh)) plot2opts(msymbol(dh)) plot3opts(msymbol(dh)) plot4opts(msymbol(dh)) plot5opts(msymbol(dh)) plot6opts(msymbol(dh)) plot7opts(msymbol(dh)) plot8opts(msymbol(dh))

graph export results/ln_cost_all.png, replace


xtline log10_costperbase, overlay recast(connected) plot1opts(msymbol(dh)) plot2opts(msymbol(dh)) plot3opts(msymbol(dh)) plot4opts(msymbol(dh)) plot5opts(msymbol(dh)) plot6opts(msymbol(dh)) plot7opts(msymbol(dh)) plot8opts(msymbol(dh))

graph export results/log10_cost_all.png, replace


xtline log2_costperbase, overlay recast(connected) plot1opts(msymbol(dh)) plot2opts(msymbol(dh)) plot3opts(msymbol(dh)) plot4opts(msymbol(dh)) plot5opts(msymbol(dh)) plot6opts(msymbol(dh)) plot7opts(msymbol(dh)) plot8opts(msymbol(dh))

graph export results/log2_cost_all.png, replace

****Only firm costs 
drop if firm == "Carlson Average"

xtline costperbase, overlay recast(connected) plot1opts(msymbol(dh)) plot2opts(msymbol(dh)) plot3opts(msymbol(dh)) plot4opts(msymbol(dh)) plot5opts(msymbol(dh)) plot6opts(msymbol(dh)) plot7opts(msymbol(dh)) 

graph export results/level_cost_firms.png, replace

xtline ln_costperbase, overlay recast(connected) plot1opts(msymbol(dh)) plot2opts(msymbol(dh)) plot3opts(msymbol(dh)) plot4opts(msymbol(dh)) plot5opts(msymbol(dh)) plot6opts(msymbol(dh)) plot7opts(msymbol(dh))

graph export results/ln_cost_firms.png, replace


xtline log10_costperbase, overlay recast(connected) plot1opts(msymbol(dh)) plot2opts(msymbol(dh)) plot3opts(msymbol(dh)) plot4opts(msymbol(dh)) plot5opts(msymbol(dh)) plot6opts(msymbol(dh)) plot7opts(msymbol(dh))

graph export results/log10_cost_firms.png, replace

xtline log2_costperbase, overlay recast(connected) plot1opts(msymbol(dh)) plot2opts(msymbol(dh)) plot3opts(msymbol(dh)) plot4opts(msymbol(dh)) plot5opts(msymbol(dh)) plot6opts(msymbol(dh)) plot7opts(msymbol(dh))

graph export results/log2_cost_firms.png, replace


use data/derived/cost_clonal_clean, clear
encode firm, gen(firmcode)
xtset firmcode year

gen carlson = firm == "Carlson Average"

**Average vs Carlson average

collapse costperbase ln_costperbase log10_costperbase log2_costperbase, by(carlson year)

*Labelling

label var costperbase "Cost per Base ($)"
label var ln_costperbase "Ln(costperbase)"
label var log10_costperbase "Log_10(costperbase)"
label var log2_costperbase "Log_2(costperbase)"

label def carlson 0 "Firm Prices" 1 "Carlson Curve"
label val carlson carlson

xtset carlson year

xtline costperbase, overlay recast(connected) plot1opts(msymbol(dh)) plot2opts(msymbol(dh))
graph export results/ln_cost_firmvscarlson.png, replace


xtline costperbase if year >=2000, overlay recast(connected) plot1opts(msymbol(dh)) plot2opts(msymbol(dh))
graph export results/log2_cost_firmvscarlson.png, replace


xtline ln_costperbase, overlay recast(connected) plot1opts(msymbol(dh)) plot2opts(msymbol(dh))
graph export results/ln_cost_firmvscarlson.png, replace


xtline log10_costperbase, overlay recast(connected) plot1opts(msymbol(dh)) plot2opts(msymbol(dh))
graph export results/log10_cost_firmvscarlson.png, replace

xtline log2_costperbase, overlay recast(connected) plot1opts(msymbol(dh)) plot2opts(msymbol(dh))
graph export results/log2_cost_firmvscarlson.png, replace


*use `d1', clear
