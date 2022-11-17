clear
set more off
set scheme s1color

cd ${synthesis_root}

import excel "data/Gene Synthesis Data.xlsx", sheet("By Firm Price") firstrow case(lower)

*Add Results Folder
cap mkdir results

*Dropping firms with no data and empty rows
drop if mi(firm) | mi(year)

keep if synthesistype=="C"

label var costperbase "Cost per Base ($)"

gen ln_costperbase = ln(costperbase)
label var ln_costperbase "Ln(costperbase)"

gen log10_costperbase = log10(costperbase)
label var log10_costperbase "Log_10(costperbase)"

gen log2_costperbase = ln(costperbase)/ln(2)
label var log2_costperbase "Log_2(costperbase)"

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


use `d1', clear
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
